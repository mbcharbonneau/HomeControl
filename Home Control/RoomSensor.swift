//
//  RoomSensor.swift
//  Home Control
//
//  Created by Marc Charbonneau on 7/20/15.
//  Copyright (c) 2015 Once Living LLC. All rights reserved.
//

import Foundation
import Parse

class RoomSensor: PFObject, PFSubclassing {
    
    class func parseClassName() -> String {
        return "Sensor"
    }
    
    var name: String {
        get { return self["name"] as! String }
    }
    
    var temperature: Double? {
        get { return self["temp"] as? Double }
    }
    
    var humidity: Double? {
        get { return self["humidity"] as? Double }
    }
    
    var light: Double? {
        get { return self["light"] as? Double }
    }
}
