//
//  MainViewTableViewController.swift
//  SimpleTasks2
//
//  Created by Tema Sysoev on 30/04/2019.
//  Copyright © 2019 Tema Sysoev. All rights reserved.
//

import UIKit
import UserNotifications
import CoreData
import CloudKit

extension CKError {
    public func isRecordNotFound() -> Bool {
        return isZoneNotFound() || isUnknownItem()
    }
    public func isZoneNotFound() -> Bool {
        return isSpecificErrorCode(code: .zoneNotFound)
    }
    public func isUnknownItem() -> Bool {
        return isSpecificErrorCode(code: .unknownItem)
    }
    public func isConflict() -> Bool {
        return isSpecificErrorCode(code: .serverRecordChanged)
    }
    public func isSpecificErrorCode(code: CKError.Code) -> Bool {
        var match = false
        if self.code == code {
            match = true
        }
        else if self.code == .partialFailure {
            guard let errors = partialErrorsByItemID else {
                return false
            }
            for (_, error) in errors {
                if let cke = error as? CKError {
                    if cke.code == code {
                        match = true
                        break
                    }
                }
            }
        }
        return match
    }
    
    public func getMergeRecords() -> (CKRecord?, CKRecord?) {
        if code == .serverRecordChanged {
            
            return (clientRecord, serverRecord)
        }
        guard code == .partialFailure else {
            return (nil, nil)
        }
        guard let errors = partialErrorsByItemID else {
            return (nil, nil)
        }
        for (_, error) in errors {
            if let cke = error as? CKError {
                if cke.code == .serverRecordChanged {
                    
                    return cke.getMergeRecords()
                }
            }
        }
        return (nil, nil)
    }
}

struct Public {
    static var tasks: [String] = [] //Массив задач
    static var newTaskPublic = String() //Новая задача
    static var doneTasksCouner = 0
}

typealias Animation = (UITableViewCell, IndexPath, UITableView) -> Void
final class Animator {
    private var hasAnimatedAllCells = false
    private let animation: Animation

    init(animation: @escaping Animation) {
        self.animation = animation
    }

    func animate(cell: UITableViewCell, at indexPath: IndexPath, in tableView: UITableView) {
        guard !hasAnimatedAllCells else {
            return
        }
        animation(cell, indexPath, tableView)
    }
}



class MainViewTableViewController: UITableViewController {
    enum AnimationFactory {

    static func makeFadeAnimation(duration: TimeInterval, delayFactor: Double) -> Animation {
        return { cell, indexPath, _ in
            cell.alpha = 0

            UIView.animate(
                withDuration: duration,
                delay: delayFactor * Double(indexPath.row),
                animations: {
                    cell.alpha = 1
            })
        }
    }
    
    static func makeMoveUpWithBounce(rowHeight: CGFloat, duration: TimeInterval, delayFactor: Double) -> Animation {
        return { cell, indexPath, tableView in
            cell.transform = CGAffineTransform(translationX: 0, y: rowHeight)

            UIView.animate(
                withDuration: duration,
                delay: delayFactor * Double(indexPath.row),
                usingSpringWithDamping: 0.4,
                initialSpringVelocity: 0.1,
                options: [.curveEaseInOut],
                animations: {
                    cell.transform = CGAffineTransform(translationX: 0, y: 0)
            })
        }
    }
    }
    
    @IBOutlet weak var navBar: UINavigationItem! //Заголовок
    @IBOutlet weak var addButtonItem: UIBarButtonItem! //Кнопка +
    @IBOutlet weak var sortButton: UIBarButtonItem!
    @IBOutlet weak var totalTasks: UIBarButtonItem!
    
    @IBOutlet weak var moreButton: UIBarButtonItem!
    
    @IBOutlet weak var bugButton: UIButton!
    
    
    
   
    let userDefults = UserDefaults.standard
    var animationSelector = 1
    func updateTasks(_ tasks: [String], _ counter: Int) -> [String] {
        
        var sTasks = tasks
        
        tableView.dataSource = sTasks as? UITableViewDataSource
        
    }
    func saveTasks(tasks:Array<Any>) { //Сохранение массива задач
        UserDefaults.standard.set(Public.tasks, forKey: "tasksKey")
        NSUbiquitousKeyValueStore.default.set(Public.tasks, forKey: "tasksKey")
        
    }
    func loadTasks() -> Array<Any>{ //Чтение массива задач
        if NSUbiquitousKeyValueStore.default.array(forKey: "tasksKey") != nil {
            //return UserDefaults.standard.array(forKey:"tasksKey")!
            return NSUbiquitousKeyValueStore.default.array(forKey: "tasksKey")!
        } else {
            if UserDefaults.standard.array(forKey:"tasksKey") != nil {
                
                return UserDefaults.standard.array(forKey:"tasksKey")!
            } else {
                return ["² 🤓"]
            }
            
        }
        
    }
    
    
   
    @IBAction func showAddTask(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: "", preferredStyle: .alert)
        alert.view.layer.bounds = CGRect(x: 0, y: 0, width: 10, height: 10)
        alert.view.tintColor = UIColor(named: "ProTasksC")
        alert.addTextField { (textField) in
            textField.text = "² "
            textField.borderStyle = .none
            textField.backgroundColor = .systemBackground
            
        }
        alert.addAction(UIAlertAction(title: "+", style: .default, handler: { [weak alert] (_) in
            if alert?.textFields![0].text != "² " {
                Public.tasks.append((alert?.textFields![0].text!)!)
            }
            self.animationSelector = 1
            self.tableView.reloadData()
            
            
            
        }))
        self.present(alert, animated: true, completion: nil)
        self.saveTasks(tasks: Public.tasks) //Сохраниние при добавлении новой задачи
        NSUbiquitousKeyValueStore.default.synchronize()
        self.animationSelector = 0
        self.totalTasks.title = ""
    }
    
    @IBAction func sortTasks(_ sender: Any) {
        Public.tasks.sort(by: >)
        self.animationSelector = 2
        self.tableView.reloadData()
        self.saveTasks(tasks: Public.tasks)
        NSUbiquitousKeyValueStore.default.synchronize()
        self.totalTasks.title = ""
    }
// MARK: - viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationBar.tintColor = UIColor(named: "ProTasksC")
        self.navigationController?.toolbar.tintColor = UIColor(named: "ProTasksC")
        NSUbiquitousKeyValueStore.default.synchronize()
        Public.tasks = loadTasks() as! [String] //Загрузка списка задач
        
        
       
        print(Public.doneTasksCouner)
        self.totalTasks.title = ""
        tableView.dataSource = self
        tableView.delegate = self
        
    }
    
    
    // MARK: - Table view data source
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        return Public.tasks.count
       
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) //Создание ячеки и привязка по индентификатору к StoryBoard
        switch animationSelector {
        case 1:
            let animation1 = AnimationFactory.makeMoveUpWithBounce(rowHeight: cell.frame.height/9, duration: 1.0, delayFactor: 0.05)
            let animator = Animator(animation: animation1)
            animator.animate(cell: cell, at: indexPath, in: tableView)
        case 2:
            let animation = AnimationFactory.makeFadeAnimation(duration: 0.5, delayFactor: 0.05)
            let animator = Animator(animation: animation)
            animator.animate(cell: cell, at: indexPath, in: tableView)
        default:
            print("No animation")
            
        }
        let task = Public.tasks[indexPath.row] //Новый элемент массива
        
        cell.textLabel?.text = task
        cell.selectionStyle = UITableViewCell.SelectionStyle.none //отключения выбора ячейки
        saveTasks(tasks: Public.tasks)
        return cell
    }
    
    
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        
        return true
    }
    
    
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.tableView.beginUpdates()
            Public.tasks.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
            self.tableView.endUpdates()
        } else if editingStyle == .insert {
            
        }
        
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        //Свайп влево для Завершения
        let done = doneAction(at: indexPath)
        userDefults.set(Public.tasks, forKey: "TasksKey")
        userDefults.synchronize()
        self.totalTasks.title = "\(Public.doneTasksCouner)"
        return UISwipeActionsConfiguration(actions: [done])
    }
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        //Свайп вправо для Приоретета
        let pushUp = pushUpAction(at: indexPath)
        self.totalTasks.title = ""
        return UISwipeActionsConfiguration(actions: [pushUp])
    }
    
    func pushUpAction(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: "↑"){_,_,_ in
            NSUbiquitousKeyValueStore.default.synchronize()
            let movingElement = Public.tasks.remove(at: indexPath.row)
            let index = IndexPath(row: 0, section: 0) //Первая позиция
            Public.tasks.insert(movingElement, at: 0)
            var task = Array(Public.tasks[0])
            
            
            if task[0] == "⁰" {
                
            }
            if task[0] == "¹" {
                task[0] = "⁰"
            }
            if task[0] == "²" {
                task[0] = "¹"
            }
            Public.tasks[0] = String(task)
            
            
            self.tableView.reloadData()
            self.tableView.cellForRow(at: index)?.textLabel!.font = UIFont.boldSystemFont(ofSize: 18.0) //Изменение шрифта задачи
            self.saveTasks(tasks: Public.tasks)
        }
        action.backgroundColor =  UIColor(named: "ProTasksColor")//UIColor(red:0.50, green:0.50, blue:0.50, alpha:1.0)//Задание цвета свайпа
        
        return action
    }
    func doneAction(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: "✓"){_,_,_ in
            
            Public.tasks.remove(at: indexPath.row)
            NSUbiquitousKeyValueStore.default.synchronize()
            self.tableView.reloadData()
            Public.doneTasksCouner += 1
            print(Public.doneTasksCouner)
            self.totalTasks.title = "\(Public.doneTasksCouner)"
            self.saveDoneCounter(tasks: Public.doneTasksCouner)
            self.saveTasks(tasks: Public.tasks)
        }
        action.backgroundColor = UIColor(named: "ProTasksColor")
        
        return action
    }
    
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        
    }
    
    
    
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       
    }
    
    
}
