//
//  DataController.swift
//  Monster Pit
//
//  Created by Marc Charbonneau on 7/20/15.
//  Copyright (c) 2015 Downtown Software House. All rights reserved.
//

import Foundation
import Parse

protocol DataControllerDelegate: class {
    func dataControllerRefreshed(controller: DataController)
    func dataController(controller: DataController, toggledDevices: [SwitchedDevice])
}

class DataController {
    
    // MARK: DataController
    
    var sensors = [RoomSensor]()
    var devices = [SwitchedDevice]()
    var lastUpdate: NSDate?
    weak var delegate: DataControllerDelegate?

    func refresh() {

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
                    self.delegate?.dataControllerRefreshed(self)
                }
            }
        }
    }
    
    func evaluateAutoDeciders(insideGeofence: State, insideOffBeacon: State) {
        
//        var changes = 0
//        
//        for device in devices {
//            
//            var turnOn = true
//            var confused = false
//            
//            for decider in device.deciders {
//                
//                if ( decider.state == State.Unknown ) {
//                    confused = true
//                    break
//                }
//                
//                let decision = decider.state == State.On;
//                turnOn = turnOn && decision;
//            }
//            
//            if confused {
//                continue
//            }
//            
//            if turnOn && !device.on {
//                device.turnOn { ( error: NSError? ) -> Void in
//                    self.collectionView?.reloadItemsAtIndexPaths([path])
//                    device.saveInBackgroundWithBlock( nil )
//                }
//            } else if !turnOn && device.on {
//                
//            }
//        }
    }
}
