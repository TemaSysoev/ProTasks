//
//  AddTaskViewController.swift
//  SimpleTasks2
//
//  Created by Tema Sysoev on 30/04/2019.
//  Copyright © 2019 Tema Sysoev. All rights reserved.
//

import UIKit

import CoreData

class AddTaskViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var addButton: UIButton! //кнопка Done
    
    var mainVC = MainViewTableViewController() //Главный вью (список задач)
    
    
    
    @IBOutlet weak var nameTextField: UITextField!//ТекстФилд для имени задачи
    
    
    
    let darkModeColor = UIColor(red:0.12, green:0.13, blue:0.14, alpha:1.0)//Темный цвет
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.nameTextField.delegate = self
        nameTextField.becomeFirstResponder()//Включение клавиатуры при входе
        addButton.layer.cornerRadius = 6 //красивы углы у кнопки
        
        
    }
    
    @IBAction func returnButtonTapped(_ sender: Any) {//Добавление задачи по кнопке с клавиатуры
        addTaskAction()
    }
    
    
    @IBAction func addAction(_ sender: Any) { //добавление по обычной Done
        addTaskAction()
        
    }
    
    
    
    
    func addTaskAction() { //Добаление заадчи
        if nameTextField.text != "" {
            Public.newTaskPublic = "² " + nameTextField.text!
            
        } else { dismissAction() }
       
        
        Public.tasks.append(Public.newTaskPublic) //добавление в массив
        mainVC.tableView.reloadData() //Обновление TableView
        
        
        dismissAction() //закрытие экрана
    }
    
    @objc func dismissAction() {
        self.dismiss(animated: true)
    }
    
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
        let focusVS = segue.destination as! FocusAssistViewViewController //Ссылка на экран добавления задачи
        focusVS.addTaskVC = self
     }
     
}
