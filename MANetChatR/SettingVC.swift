//
//  SettingVC.swift
//  MANetChatR
//
//  Created by kolathee on 3/7/2560 BE.
//  Copyright © 2560 kolathee. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class SettignVC: UIViewController {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func signoutButtonTapped(_ sender: Any) {
        logout()
    }
    
    func logout(){
        do {
            //1.Logout
            try FIRAuth.auth()?.signOut()
            
            //2.Remove all observers
            let rootNodeReference = FIRDatabase.database().reference()
            rootNodeReference.removeAllObservers()
            
            //3.Remove all data
            appDelegate.clearAllData()
            
            //4.Show Login view
            dismiss(animated: false, completion: nil)
            
        } catch let logoutError {
            print(logoutError)
            showAlertMessage(title: "Fail to logout", message: "Please try again")
            return
        }
    }
    
    func showAlertMessage(title : String, message : String){
        let messageWindow = UIAlertController(title: title, message:message , preferredStyle: .alert)
        let action = UIAlertAction(title: "done", style: .cancel, handler: nil)
        messageWindow.addAction(action)
        self.present(messageWindow, animated: true, completion: nil)
    }

}
