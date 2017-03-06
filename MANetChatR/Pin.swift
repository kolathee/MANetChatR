//
//  Pin.swift
//  MANetChatR
//
//  Created by kolathee on 3/6/2560 BE.
//  Copyright © 2560 kolathee. All rights reserved.
//

import Foundation
import MapKit

class Pin : NSObject {
    
    private var _id:String
    private var _type:String
    private var _radius:Int
    private var _location:CLLocation
    
    init(id:String,pinType:String,radius:Int,location:CLLocation) {
        _id = id
        _type = pinType
        _radius = radius
        _location = location
    }
    
    var type:String {
        return self.type
    }
    
    var radius:Int {
        return self.radius
    }
    
    var location:CLLocation {
        return self.location
    }
    
    var id:String {
        return _id
    }
}
