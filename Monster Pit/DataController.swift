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
    var enableAutoMode: Bool {
        didSet {
            for device in devices {
                for decider in device.deciders {
                    if let decider = decider as? BlockingDecider {
                        decider.blockOtherDeciders = !self.enableAutoMode
                    }
                }
            }
            let defaults = NSUserDefaults.standardUserDefaults()
            let center = NSNotificationCenter.defaultCenter()
            defaults.setBool( self.enableAutoMode, forKey: Constants.EnableAutoModeDefaultsKey )
            defaults.synchronize()
            center.postNotificationName(Constants.ForceEvaluationNotification, object: self)
        }
    }

    override init() {
        self.enableAutoMode = NSUserDefaults.standardUserDefaults().boolForKey(Constants.EnableAutoModeDefaultsKey)
        super.init()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("evaluateDeciders:"), name: Constants.ForceEvaluationNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: Constants.ForceEvaluationNotification, object: nil)
    }
    
    func refresh() {

        dispatch_async( dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0 ) ) {

            let sensorQuery = PFQuery(className: "Sensor")
            let deviceQuery = PFQuery(className: "Device")
            
            sensorQuery.orderByAscending( "createdAt" )
            deviceQuery.orderByAscending( "createdAt" )

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
                    
                    NSNotificationCenter.defaultCenter().postNotificationName(Constants.ForceEvaluationNotification, object: self)
                }
            }
        }
    }
    
    func evaluateDeciders(notification: NSNotification) {
        
        outerLoop: for device in devices {
            
            var turnOn = true
            
            for decider in device.deciders {
                
                println( "\(decider.name) wants \(device.name) to be \(decider.state)." );
                
                if ( decider.state == State.Unknown ) {
                    continue outerLoop
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
        
        var array = [DecisionMakerProtocol]()
        let types = device.deciderClasses
        
        if contains( types, "BlockingDecider" ) {
            let blocker = BlockingDecider( blockOtherDeciders: !self.enableAutoMode )
            array.append( blocker )
        }

        if contains( types, "BeaconDecider" ) {
            let beacon = BeaconDecider( locationController: locationController )
            array.append( beacon )
        }
        
        if contains( types, "GeofenceDecider" ) {
            let geofence = GeofenceDecider( locationController: locationController )
            array.append( geofence )
        }
                
        return array
    }
}
