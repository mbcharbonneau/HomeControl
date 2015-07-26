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
    func dataController(controller: DataController, toggledDevice: SwitchedDevice )
}

class DataController: NSObject {
    
    // MARK: DataController
    
    var sensors = [RoomSensor]()
    var devices = [SwitchedDevice]()
    var lastUpdate: NSDate?
    weak var delegate: DataControllerDelegate?

    override init() {
        super.init()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("evaluateAutoDeciders:"), name: Constants.ForceEvaluationNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: Constants.ForceEvaluationNotification, object: nil)
    }
    
    func refresh() {

        dispatch_async( dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0 ) ) {

            let sensorQuery = PFQuery(className: "Sensor")
            let deviceQuery = PFQuery(className: "Device")

            let sensorResults = sensorQuery.findObjects()
            let deviceResults = deviceQuery.findObjects()

            dispatch_async( dispatch_get_main_queue() ) {

                if let sensors = sensorResults as? [RoomSensor], devices = deviceResults as? [SwitchedDevice] {
                    
                    for device in devices {
                        device.deciders = self.decidersForDevice( device )
                    }
                    
                    self.sensors = sensors
                    self.devices = devices
                    self.lastUpdate = NSDate()
                    self.delegate?.dataControllerRefreshed(self)
                }
            }
        }
    }
    
    func evaluateAutoDeciders(notification: NSNotification) {
        
        println("Evaluating deciders...")
        
        outerLoop: for device in devices {
            
            var turnOn = true
            
            for decider in device.deciders {
                
                if ( decider.state == State.Unknown ) {
                    break outerLoop
                }
                
                let decision = decider.state == State.On;
                turnOn = turnOn && decision;
            }
            
            if turnOn && !device.on {
                device.turnOn { ( error: NSError? ) -> Void in
                    if ( error == nil ) {
                        self.delegate?.dataController( self, toggledDevice: device )
                    }
                }
            } else if !turnOn && device.on {
                device.turnOff { ( error: NSError? ) -> Void in
                    if ( error == nil ) {
                        self.delegate?.dataController( self, toggledDevice: device )
                    }
                }
            }
        }
    }
    
    // MARK: DataController Private
    
    private let locationController = LocationController()
    
    private func decidersForDevice( device:SwitchedDevice ) -> [DecisionMakerProtocol] {
        let beacon = BeaconDecider( locationController: locationController )
        
        return [beacon]
    }

}
