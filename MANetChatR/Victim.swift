//
//  Victim.swift
//  MANetChatR
//
//  Created by kolathee on 3/6/2560 BE.
//  Copyright © 2560 kolathee. All rights reserved.
//

import Foundation
import MapKit

class Victim:NSObject {
    private var _name:String
    private var _location:CLLocation
    
    init(name:String ,location:CLLocation) {
        _location = location
        _name = name
    }
    
    var name:String {
        return _name
    }
    
    var location:CLLocation {
        return _location
    }
}
