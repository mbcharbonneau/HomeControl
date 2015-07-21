//
//  RoomSensor.swift
//  Monster Pit
//
//  Created by Marc Charbonneau on 7/20/15.
//  Copyright (c) 2015 Downtown Software House. All rights reserved.
//

import Foundation

struct RoomSensor {
    
    var name: String
    var lastUpdate: NSDate
    var temperature: Double
    var humidity: Double
    var light: Double
    
    init( dictionary: NSDictionary ) {
    
        name = dictionary["name"] as! String
        lastUpdate = NSDate.new()
        temperature = 0.0
        humidity = 0.0
        light = 0.0
    }
}
