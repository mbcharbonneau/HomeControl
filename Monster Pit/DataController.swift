//
//  DataController.swift
//  Monster Pit
//
//  Created by Marc Charbonneau on 7/20/15.
//  Copyright (c) 2015 Downtown Software House. All rights reserved.
//

import Foundation
import Parse

class DataController {
    
    var sensors = [RoomSensor]()
    
    func refresh(finished: () -> Void) {
        
        let query = PFQuery(className: "Sensor")
        
        query.findObjectsInBackgroundWithBlock { (results: [AnyObject]?, error: NSError?) -> Void in
            
            if let objects = results {
                self.sensors = objects as! [RoomSensor]
                finished()
            }
        }
    }
}
