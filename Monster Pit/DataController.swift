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
            if enableAutoMode == oldValue {
                return
            }
            for device in devices {
                device.deciders = decidersForDevice( device )
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

        if isEmpty(sensors) || isEmpty(devices) {
            reloadAllData()
        } else {
            refreshExistingObjects()
        }
    }
    
    func evaluateDeciders(notification: NSNotification) {
                
        println("Checking deciders...")
        
        if devices.filter( { $0.isBusy } ).count > 0 {
            println("One or more devices are busy, postponing evaluation!")
            let time = dispatch_time(DISPATCH_TIME_NOW, Int64(3.0 * Double(NSEC_PER_SEC)))
            dispatch_after(time, dispatch_get_main_queue()) { [weak self] in
                self?.evaluateDeciders(notification)
            }
            return
        }
        
        if !deviceUpdateLock.tryLock() {
            println("Can't evaluate devices during an update!")
            return
        }
        
        outerLoop: for device in devices {

            if device.deciders.count == 0 || !device.online {
                continue
            }
                        
            var turnOn = true
            
            for decider in device.deciders {
                
                println( "\t\(decider.name) wants \(device.name) to be \(decider.state)." );
                
                if ( decider.state == State.Unknown ) {
                    continue outerLoop
                }
                
                let decision = decider.state == State.On;
                turnOn = turnOn && decision;
            }
            
            let completionBlock = { ( error: NSError? ) -> Void in
                if ( error == nil ) {
                    self.delegate?.dataController( self, toggledDevice: device )
                }
                self.deviceUpdateLock.unlock()
            }
            
            if turnOn && !device.on {
                self.deviceUpdateLock.lock()
                device.turnOn( completionBlock )
            } else if !turnOn && device.on {
                self.deviceUpdateLock.lock()
                device.turnOff( completionBlock )
            }
        }
        
        deviceUpdateLock.unlock()
        
        println("Done!")
    }
    
    // MARK: DataController Private
    
    private let locationController = LocationController()
    private let deviceUpdateLock = NSRecursiveLock()
    
    private func reloadAllData() {
        
        dispatch_async( dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0 ) ) {
            
            let sensorQuery = PFQuery(className: "Sensor")
            let deviceQuery = PFQuery(className: "Device")
            
            sensorQuery.orderByAscending( "createdAt" )
            deviceQuery.orderByAscending( "createdAt" )
            
            let sensorResults = sensorQuery.findObjects()
            let deviceResults = deviceQuery.findObjects()
            
            println("Reloaded all data sources.")
            
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
    
    private func refreshExistingObjects() {

        dispatch_async( dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0 ) ) {
            
            self.deviceUpdateLock.lock()
            SwitchedDevice.fetchAll(self.devices)
            RoomSensor.fetchAll(self.sensors)
            self.deviceUpdateLock.unlock()
            
            println("Refreshed existing objects.")
            
            dispatch_async( dispatch_get_main_queue() ) {

                for device in self.devices {
                    device.deciders = self.decidersForDevice( device )
                }

                self.lastUpdate = NSDate()
                self.delegate?.dataControllerRefreshed(self)

                NSNotificationCenter.defaultCenter().postNotificationName(Constants.ForceEvaluationNotification, object: self)
            }
        }
    }
    
    private func decidersForDevice( device:SwitchedDevice ) -> [DecisionMakerProtocol] {
        
        if !enableAutoMode || !device.online {
            return []
        }
        
        var array = [DecisionMakerProtocol]()
        let types = device.deciderClasses
        
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
