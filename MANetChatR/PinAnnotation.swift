//
//  PinAnnotation.swift
//  MANetChatR
//
//  Created by kolathee on 3/6/2560 BE.
//  Copyright © 2560 kolathee. All rights reserved.
//

import UIKit
import MapKit

class PinAnnotation: NSObject, MKAnnotation {
    var coordinate = CLLocationCoordinate2D()
    var pinType:String
    var title:String?
    var id:String?
    
    init (coordinate:CLLocationCoordinate2D ,pintype: String,id:String) {
        self.coordinate = coordinate
        self.pinType = pintype
        self.id = id
        
        if pinType == "red_pin" {
            title = "warning place!"
        } else if pinType == "green_pin" {
            title = "safe place"
        }
    }
    
    init (coordinate:CLLocationCoordinate2D ,username: String) {
        self.coordinate = coordinate
        self.pinType = "person_pin"
        self.title = username
    }

}
