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
    
    var time = 45
    var timer = Timer()
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeProgress: UIProgressView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    
    var taskName = String()
    var cancel = false
    @IBAction func closeAction(_ sender: Any) {
        
        dismiss(animated: true)
        cancel = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        taskName = Public.tasks[0]
        
        timeLabel.text = """
        \(taskName):
        \(time) mins left
        """
        timeProgress.progress = (45-Float(time))/45
        timer = Timer.scheduledTimer(timeInterval: 60, target: self,   selector: (#selector(FocusAssistViewViewController.updateTimer)), userInfo: nil, repeats: true)
        timeProgress.layer.cornerRadius = 20
        
    }
    @objc func updateTimer(){
        time -= 1
        timeLabel.text = """
        \(taskName):
        \(time) mins left
        """
        timeProgress.progress = (45-Float(time))/45
       
        if (time == 0)  {
            if cancel{
                
            }else{ AudioServicesPlayAlertSound(SystemSoundID(1005))
            dismiss(animated: true)
            }
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
