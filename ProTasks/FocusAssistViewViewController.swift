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
    
    var time = Int()
    var timer = Timer()
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeProgress: UIProgressView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameLabel.text = addTaskVC.nameTextField.text
        
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
