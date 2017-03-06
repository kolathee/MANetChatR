//
//  NoticeDetailVC.swift
//  MANetChatR
//
//  Created by kolathee on 3/7/2560 BE.
//  Copyright © 2560 kolathee. All rights reserved.
//

import UIKit
import FirebaseDatabase

class NoticeDetailVC: UIViewController {

    var noticeId:String?
    var headtitle:String?
    var detail:String?
    
    let noticeRef = FIRDatabase.database().reference(withPath: "notices")
    
    @IBOutlet weak var outputTitleViewBox: UITextView!
    @IBOutlet weak var outputDetailViewBox: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        outputTitleViewBox.allowsEditingTextAttributes = false
        outputDetailViewBox.allowsEditingTextAttributes = false
        outputTitleViewBox.text = headtitle
        outputDetailViewBox.text = detail
    }
    
    @IBAction func trashButtonWasTapped(_ sender: Any) {
        noticeRef.child(noticeId!).removeValue()
        _ = navigationController?.popViewController(animated: true)
    }
}
