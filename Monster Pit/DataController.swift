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
    func dataControllerReloadedData(controller: DataController)
    func dataControllerRefreshedSensors(controller: DataController)
    func dataController(controller: DataController, toggledDevice: SwitchedDevice)
}

typealias RefreshCompletion = (Bool, ErrorType?) -> Void

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
        self.operationQueue.maxConcurrentOperationCount = 1
        super.init()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("evaluateDeciders:"), name: Constants.ForceEvaluationNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: Constants.ForceEvaluationNotification, object: nil)
    }
    
    func refresh(completion: RefreshCompletion?) {

        if sensors.isEmpty || devices.isEmpty {
            reloadData(completion)
        } else {
            refreshSensors(completion)
        }
    }
    
    func switchDevice(device: SwitchedDevice, turnOn: Bool) {
        
        let command = turnOn ? DeviceCommand.TurnOn : DeviceCommand.TurnOff
        let operation = DeviceOperation(device, command: command)
        let task = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler() { operation.cancel() }
        
        operation.completionBlock = {
            dispatch_async(dispatch_get_main_queue()) {
                self.delegate?.dataController(self, toggledDevice: device)
                UIApplication.sharedApplication().endBackgroundTask(task)
            }
        }
        
        operationQueue.addOperation(operation)
    }
    
    func evaluateDeciders(notification: NSNotification) {
                
        LogController.sharedController.log("Checking deciders...")
        
        guard operationQueue.operationCount == 0 else {
            
            LogController.sharedController.log("One or more devices are busy, postponing evaluation!")
            let time = dispatch_time(DISPATCH_TIME_NOW, Int64(3.0 * Double(NSEC_PER_SEC)))
            dispatch_after(time, dispatch_get_main_queue()) { [weak self] in
                self?.evaluateDeciders(notification)
            }
            return
        }
        
        var switchedOn = [SwitchedDevice]()
        var switchedOff = [SwitchedDevice]()
        
        outerLoop: for device in devices {

            if device.deciders.count == 0 || !device.online {
                continue
            }
                        
            var turnOn = true
            
            for decider in device.deciders {
                
                LogController.sharedController.log("\(decider.name) wants \(device.name) to be \(decider.state).")

                guard decider.state != .Unknown else { continue outerLoop }
                let decision = decider.state == State.On;
                turnOn = turnOn && decision;
            }

            if turnOn && !device.on {
                switchDevice(device, turnOn: true)
                switchedOn.append(device)
            } else if !turnOn && device.on {
                switchDevice(device, turnOn: false)
                switchedOff.append(device)
            }
        }
        
        if switchedOn.count > 0 {
            scheduleNotification(switchedOn, command: .TurnOn)
        }
        
        if switchedOff.count > 0 {
            scheduleNotification(switchedOff, command: .TurnOff)
        }
        
        LogController.sharedController.log("Finished evaluation!")
    }
    
    // MARK: DataController Private
    
    private let locationController = LocationController()
    private let operationQueue = NSOperationQueue()
    
    private func reloadData(completion: RefreshCompletion?) {
        
        dispatch_async( dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0 ) ) {
            
            let sensorQuery = PFQuery(className: "Sensor")
            let deviceQuery = PFQuery(className: "Device")
            
            sensorQuery.orderByAscending( "createdAt" )
            deviceQuery.orderByAscending( "createdAt" )
            
            deviceQuery.includeKey("sensor")
            
            var sensors: [RoomSensor]?
            var devices: [SwitchedDevice]?
            
            do {
                sensors = try sensorQuery.findObjects() as? [RoomSensor]
                devices = try deviceQuery.findObjects() as? [SwitchedDevice]
            } catch {
                LogController.sharedController.log("Parse fetch error: \(error)")
            }
            
            LogController.sharedController.log("Reloaded all data sources.")
            
            dispatch_async( dispatch_get_main_queue() ) {
                
                if let sensors = sensors, devices = devices {
                    
                    for device in devices {
                        device.deciders = self.decidersForDevice( device )
                    }
                    
                    self.sensors = sensors
                    self.devices = devices
                    self.lastUpdate = NSDate()
                    self.delegate?.dataControllerReloadedData(self)
                    
                    NSNotificationCenter.defaultCenter().postNotificationName(Constants.ForceEvaluationNotification, object: self)
                   
                    if let handler = completion {
                        handler(true, nil)
                    }
                }
            }
        }
    }
    
    private func refreshSensors(completion: RefreshCompletion?) {

        dispatch_async( dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0 ) ) {
            
            do {
                let deviceSensors = self.devices.filter({ return $0.sensor != nil }).map({ return $0.sensor!})
                let sensorObjects = self.sensors + deviceSensors
                try RoomSensor.fetchAll(sensorObjects)
            } catch {
                LogController.sharedController.log("Parse fetch error: \(error)")
            }
            
            LogController.sharedController.log("Refreshed sensors.")
            
            dispatch_async( dispatch_get_main_queue() ) {

                self.lastUpdate = NSDate()
                self.delegate?.dataControllerRefreshedSensors(self)

                NSNotificationCenter.defaultCenter().postNotificationName(Constants.ForceEvaluationNotification, object: self)
                
                if let handler = completion {
                    handler(true, nil)
                }
            }
        }
    }
    
    private func decidersForDevice(device: SwitchedDevice) -> [DecisionMakerProtocol] {
        
        guard enableAutoMode && device.online else { return [] }
        
        return device.deciderClasses.map() {
            
            switch $0 {
                case "BeaconDecider":
                    return BeaconDecider(locationController: locationController)
                case "GeofenceDecider":
                    return  GeofenceDecider(locationController: locationController)
                case "SensorDecider":
                    return SensorDecider(sensor: device.sensor!)
            default:
                fatalError("unknown decider!")
            }
        }
    }
    
    private func scheduleNotification(devices: [SwitchedDevice], command: DeviceCommand) {
        
        let notification = UILocalNotification()
        let actionName = command.commandString().lowercaseString
        
        notification.fireDate = NSDate()
        notification.soundName = UILocalNotificationDefaultSoundName;

        switch devices.count {
        case 1:
            let device = devices.first!
            notification.alertBody = "I turned \(actionName) \(device.name)."
        default:
            notification.alertBody = "I turned \(actionName) \(devices.count) devices."
        }
        
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
}
