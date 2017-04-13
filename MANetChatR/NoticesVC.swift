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
    
    let noticeRef = FIRDatabase.database().reference().child("notices").queryOrdered(byChild: "postedDate")
    
    struct Notice {
        let noticeId:String
        let title:String
        let detail:String
        let postedDate:Int
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
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot]{
                print(snapshot)
                for snap in snapshot {
                    if let notice = snap.value as? [String:AnyObject] {
                            let notice = Notice(noticeId: snap.key,
                                                title: notice[ "title" ] as! String,
                                                detail: notice[ "detail" ] as! String,
                                                postedDate: notice["postedDate"] as! Int
                                                )
                            self.notices.append(notice)
                            print(self.notices[self.notices.count-1].title)
                            print(self.notices[self.notices.count-1].detail)
                    }
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
