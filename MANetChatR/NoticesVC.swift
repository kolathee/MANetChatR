//
//  NoticesVC.swift
//  MANetChatR
//
//  Created by kolathee on 3/7/2560 BE.
//  Copyright © 2560 kolathee. All rights reserved.
//

import UIKit
import FirebaseDatabase

class NoticesVC: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate {
    @IBOutlet weak var collectionView: UICollectionView!
    
    let noticeRef = FIRDatabase.database().reference(withPath: "notices")
    
    struct Notice {
        let noticeId:String
        let title:String
        let detail:String
    }
    
    var indexCollectionSelected:Int?
    var notices = [Notice]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func setup(){
        noticeRef.observe(.value, with: { (snapshot) in
            self.notices.removeAll()
            if let data = snapshot.value as? Dictionary<String,Array<String>>{
                print("HI")
                for (key,information) in data {
                    let notice = Notice(noticeId: key, title: information[0], detail: information[1])
                    self.notices.append(notice)
                }
            }
            print("*****")
            print(self.notices)
            self.collectionView.reloadData()
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return notices.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let notice = notices[indexPath.row]
        
        collectionView.backgroundColor = UIColor(red:0.95, green:0.95, blue:0.95, alpha:1.0)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "noticeCollectionCell", for: indexPath) as! NoticeCViewCell
        cell.title.text = notice.title
        cell.detail.text = notice.detail
        cell.backgroundColor = UIColor.white
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToNoticeView" {
            let cell = sender as! UICollectionViewCell
            let indexPath = self.collectionView!.indexPath(for: cell)
            
            let controller = segue.destination as! NoticeDetailVC
            controller.headtitle = notices[(indexPath?.row)!].title
            controller.detail = notices[(indexPath?.row)!].detail
            controller.noticeId = notices[(indexPath?.row)!].noticeId
        }
    }
}
