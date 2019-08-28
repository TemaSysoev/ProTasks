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
         
    @IBOutlet weak var leaderboardButton: UIButton!
   
    
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
                    if error != nil { print(error as Any)
                    } else { self.gcDefaultLeaderBoard = leaderboardIdentifer! }
                })
                 
            } else {
                // 3. Game center is not enabled on the users device
                self.gcEnabled = false
                print("Local player could not be authenticated!")
                print(error as Any)
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
    
    
    
    func saveAndSync(tasks:Array<Any>) { //Сохранение массива задач
        var syncTasks: [Any] = Public.tasks
        syncTasks.append(Public.doneTasksCouner)
        UserDefaults.standard.set(syncTasks, forKey: "Key")
        NSUbiquitousKeyValueStore.default.set(syncTasks, forKey: "Key")
        
    }
    func loadTasks() -> [String]{
        if NSUbiquitousKeyValueStore.default.array(forKey: "Key") != nil {
            var syncedTasks = NSUbiquitousKeyValueStore.default.array(forKey: "Key")
            let total = (syncedTasks?.count)!
            syncedTasks?.remove(at: total - 1)
            return syncedTasks as! [String]
        } else {
            if UserDefaults.standard.array(forKey: "Key") != nil {
                var syncedTasksE = UserDefaults.standard.array(forKey: "Key")
                let total = (syncedTasksE?.count)!
                syncedTasksE?.remove(at: total - 1)
                
                return syncedTasksE as! [String]
            } else {
                return ["² Welcome!"]
            }
        }
    }
    func loadTasksCounter() -> Int{
        if NSUbiquitousKeyValueStore.default.array(forKey: "Key") != nil {
            let syncedTasks = NSUbiquitousKeyValueStore.default.array(forKey: "Key")
            let total = syncedTasks?.count
            let counter: Int = (syncedTasks![total! - 1] as! Int)
            return counter
        } else {
            if UserDefaults.standard.array(forKey: "Key") != nil {
                let syncedTasks = UserDefaults.standard.array(forKey: "Key")
                let total = syncedTasks?.count
                
                let counter: Int = (syncedTasks![total! - 1] as! Int)
                return counter
                
                
                
            } else {
                return 0
            }
        }
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        authenticateLocalPlayer()
        Public.doneTasksCouner = loadTasksCounter()
        leaderboardButton.layer.cornerRadius = 6
        score = Public.doneTasksCouner
       
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
