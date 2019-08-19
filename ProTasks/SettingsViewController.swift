//
//  SettingsViewController.swift
//  ProTasks
//
//  Created by Tema Sysoev on 14/08/2019.
//  Copyright © 2019 Tema Sysoev. All rights reserved.
//

import UIKit
import GameKit

class SettingsViewController: UIViewController, GKGameCenterControllerDelegate {
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
    var gcEnabled = Bool() // Check if the user has Game Center enabled
    var gcDefaultLeaderBoard = String() // Check the default leaderboardID
         
    var score = 0
         
    @IBOutlet weak var scoreLabel: UILabel!
    
    let LEADERBOARD_ID = "com.score.professionalsProTasks"
    func authenticateLocalPlayer() {
        let localPlayer: GKLocalPlayer = GKLocalPlayer.local
             
        localPlayer.authenticateHandler = {(ViewController, error) -> Void in
            if((ViewController) != nil) {
                // 1. Show login if player is not logged in
                self.present(ViewController!, animated: true, completion: nil)
            } else if (localPlayer.isAuthenticated) {
                // 2. Player is already authenticated & logged in, load game center
                self.gcEnabled = true
                     
                // Get the default leaderboard ID
                localPlayer.loadDefaultLeaderboardIdentifier(completionHandler: { (leaderboardIdentifer, error) in
                    if error != nil { print(error)
                    } else { self.gcDefaultLeaderBoard = leaderboardIdentifer! }
                })
                 
            } else {
                // 3. Game center is not enabled on the users device
                self.gcEnabled = false
                print("Local player could not be authenticated!")
                print(error)
            }
        }
    }
    @IBAction func checkGCLeaderboard(_ sender: AnyObject) {
        let gcVC = GKGameCenterViewController()
        gcVC.gameCenterDelegate = self
        gcVC.viewState = .leaderboards
        gcVC.leaderboardIdentifier = LEADERBOARD_ID
        present(gcVC, animated: true, completion: nil)
    }
    @IBAction func addScoreAndSubmitToGC(_ sender: AnyObject) {
        // Add 10 points to current score
        score = Public.doneTasksCouner
        scoreLabel.text = "\(score)"
     
        // Submit score to GC leaderboard
        let bestScoreInt = GKScore(leaderboardIdentifier: LEADERBOARD_ID)
        bestScoreInt.value = Int64(score)
        GKScore.report([bestScoreInt]) { (error) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                print("Best Score submitted to your Leaderboard!")
            }
        }
    }
    
    
    func saveDoneCounter(tasks:Int) {
        UserDefaults.standard.set(Public.tasks, forKey: "tasksCounter")
       // NSUbiquitousKeyValueStore.default.set(Public.doneTasksCouner, forKey: "tasksCounter")
        
    }
    func loadDoneCounter() -> Int {
        /*return Int(NSUbiquitousKeyValueStore.default.double(forKey: "tasksCounter"))*/
        //if NSUbiquitousKeyValueStore.default.double(forKey: "tasksCounter") != 0 {
            //return UserDefaults.standard.array(forKey:"tasksKey")!
           // return Int(NSUbiquitousKeyValueStore.default.double(forKey: "tasksCounter"))
        //} else {
          //  if UserDefaults.standard.double(forKey:"tasksCounter") != 0 {
                
                return Int(UserDefaults.standard.double(forKey:"tasksCounter"))
            //} else {
              //  return 0
           // }
            
        //}
    }
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        authenticateLocalPlayer()
        Public.doneTasksCouner = loadDoneCounter()
        
        score = Public.doneTasksCouner
        scoreLabel.text = "\(score)"
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
