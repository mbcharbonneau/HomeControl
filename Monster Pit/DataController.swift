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
    var devices = [SwitchedDevice]()
    var lastUpdate: NSDate?
    
    func refresh(finished: () -> Void) {

        dispatch_async( dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0 ) ) {

            let sensorQuery = PFQuery(className: "Sensor")
            let deviceQuery = PFQuery(className: "Device")

            let sensorResults = sensorQuery.findObjects()
            let deviceResults = deviceQuery.findObjects()

            dispatch_async( dispatch_get_main_queue() ) {

                if let sensors = sensorResults as? [RoomSensor], devices = deviceResults as? [SwitchedDevice] {
                    self.sensors = sensors
                    self.devices = devices
                    self.lastUpdate = NSDate()
                    finished()
                }
            }
        }
    }
}
