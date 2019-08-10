//
//  FocusAssistViewViewController.swift
//  ProTasks
//
//  Created by Tema Sysoev on 02/08/2019.
//  Copyright © 2019 Tema Sysoev. All rights reserved.
//

import UIKit
import AVFoundation

class FocusAssistViewViewController: UIViewController {
    
    var addTaskVC = AddTaskViewController()
    
    var time = 25
    var timer = Timer()
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeProgress: UIProgressView!
    @IBOutlet weak var timeLabel: UILabel!
    
    var taskName = String()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        taskName = addTaskVC.nameTextField.text!
        nameLabel.text = taskName
        timeLabel.text = "\(time) mins left"
        timeProgress.progress = (25-Float(time))/25
        timer = Timer.scheduledTimer(timeInterval: 60, target: self,   selector: (#selector(FocusAssistViewViewController.updateTimer)), userInfo: nil, repeats: true)
        
        
    }
    @objc func updateTimer(){
        time -= 1
        timeLabel.text = "\(time) mins left"
        timeProgress.progress = (25-Float(time))/25
        if (time == 0) && (nameLabel.text != "Break time!") {
            AudioServicesPlayAlertSound(SystemSoundID(1005))
            time = 5
            timeLabel.text = "\(time) mins left"
            nameLabel.text = "Break time!"
        }
        if (time == 0) && (nameLabel.text == "Break time!") {
            AudioServicesPlayAlertSound(SystemSoundID(1005))
            time = 25
            timeLabel.text = "\(time) mins left"
            nameLabel.text = taskName
        }
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
