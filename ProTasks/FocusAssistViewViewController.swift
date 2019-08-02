//
//  FocusAssistViewViewController.swift
//  ProTasks
//
//  Created by Tema Sysoev on 02/08/2019.
//  Copyright © 2019 Tema Sysoev. All rights reserved.
//

import UIKit

class FocusAssistViewViewController: UIViewController {
    
    var addTaskVC = AddTaskViewController()
    
    var time = 25
    var timer = Timer()
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeProgress: UIProgressView!
    @IBOutlet weak var timeLabel: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameLabel.text = addTaskVC.nameTextField.text
        timeLabel.text = "\(time) mins left"
        timeProgress.progress = (25-Float(time))/25
        timer = Timer.scheduledTimer(timeInterval: 10, target: self,   selector: (#selector(FocusAssistViewViewController.updateTimer)), userInfo: nil, repeats: true)
    }
    @objc func updateTimer(){
        time -= 1
        timeLabel.text = "\(time) mins left"
        timeProgress.progress = (25-Float(time))/25
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
    }
    */

}
