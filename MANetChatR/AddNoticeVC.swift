//
//  AddNoticeVC.swift
//  MANetChatR
//
//  Created by kolathee on 3/7/2560 BE.
//  Copyright © 2560 kolathee. All rights reserved.
//

import UIKit
import FirebaseDatabase

class AddNoticeVC: UIViewController, UITextViewDelegate {

    @IBOutlet weak var inputTitleTextBox: UITextView!
    @IBOutlet weak var inputDetailTextBox: UITextView!
    @IBOutlet weak var doneButton: UIButton!
    
    let noticesRef = FIRDatabase.database().reference(withPath: "notices")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        doneButton.titleLabel?.textColor = UIColor.lightGray
        doneButton.isEnabled = false
        inputTitleTextBox.textColor = UIColor.lightGray
        inputTitleTextBox.becomeFirstResponder()
        let begin = inputTitleTextBox.beginningOfDocument
        inputTitleTextBox.selectedTextRange = inputTitleTextBox.textRange(from: begin, to: begin)
        
        inputDetailTextBox.textColor = UIColor.lightGray
        let begin2 = inputDetailTextBox.beginningOfDocument
        inputDetailTextBox.selectedTextRange = inputDetailTextBox.textRange(from: begin2, to: begin2)
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        if self.view.window != nil {
            if textView.textColor == UIColor.lightGray {
                textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
            }
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let currentText = textView.text as NSString?
        let updatedText = currentText?.replacingCharacters(in: range, with: text)
        
        if (updatedText?.isEmpty)! {
            if textView.restorationIdentifier == "inputNoticeTitleTextBox" {
                textView.text = "Please fill your title ..."
            }else{
                textView.text = "Enter your information ..."
            }
            textView.textColor = UIColor.lightGray
            let begin = textView.beginningOfDocument
            textView.selectedTextRange = textView.textRange(from: begin, to: begin)
            doneButton.isEnabled = false
            return false
            
        } else if textView.textColor == UIColor.lightGray && !text.isEmpty {
            textView.text = nil
            textView.textColor = UIColor.black
        }
        
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if (inputTitleTextBox.textColor != UIColor.lightGray) && (inputDetailTextBox.textColor != UIColor.lightGray) {
            doneButton.isEnabled = true
        }
    }
    
    @IBAction func cancelButtonWasTapped(_ sender: Any) {
        inputDetailTextBox.resignFirstResponder()
        inputTitleTextBox.resignFirstResponder()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonWasTapped(_ sender: Any) {
        let noticeId = noticesRef.childByAutoId().key
        noticesRef.child(noticeId).setValue([inputTitleTextBox.text,inputDetailTextBox.text,FIRServerValue.timestamp()])
        dismiss(animated: true, completion: nil)
    }

}
