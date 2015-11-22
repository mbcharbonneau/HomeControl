//
//  DeviceOperation.swift
//  Monster Pit
//
//  Created by Marc Charbonneau on 11/21/15.
//  Copyright © 2015 Downtown Software House. All rights reserved.
//

import Foundation

enum DeviceCommand {
    case TurnOn
    case TurnOff
    
    func commandString() -> String {
        switch self {
        case TurnOn:
            return "On"
        case TurnOff:
            return "Off"
        }
    }
}

class DeviceOperation: NSOperation {

    // MARK: DeviceOperation
    
    let device: SwitchedDevice
    let command: DeviceCommand
    var error: ErrorType?
    
    required init(_ device: SwitchedDevice, command: DeviceCommand) {
        self.device = device
        self.command = command
    }
    
    // MARK: DeviceOperation Private
    
    private var commandTask: NSURLSessionTask?
    private var state: OperationState = .Ready {
        willSet {
            willChangeValueForKey(newValue.keyPath())
            willChangeValueForKey(state.keyPath())
        }
        didSet {
            didChangeValueForKey(oldValue.keyPath())
            didChangeValueForKey(state.keyPath())
        }
    }
    
    // MARK: NSOperation
    
    override var asynchronous: Bool { return true }
    override var ready: Bool { return super.ready && state == .Ready }
    override var executing: Bool { return state == .Executing }
    override var finished: Bool { return state == .Finished }

    override func start() {
        guard !cancelled else {
            state = .Finished
            return
        }
        
        state = .Executing
        main()
    }
    
    override func cancel() {
        super.cancel()
        commandTask?.cancel()
    }
    
    override func main() {
        
        let commandString = command.commandString()
        let eventName = device.name.stringByReplacingOccurrencesOfString(" ", withString: "") + commandString
        let URLString = "https://maker.ifttt.com/trigger/\(eventName)/with/key/\(Configuration.IFTTT.ClientKey)"
        guard let URL = NSURL(string: URLString) else { fatalError() }
        
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config)
        let request = NSMutableURLRequest(URL: URL)
        
        request.HTTPMethod = "POST"
        
        commandTask = session.dataTaskWithRequest(request) { (data: NSData?, response: NSURLResponse?, error: NSError?) in
            
            guard error == nil else {
                print("Command finished with error: \(error)")
                self.state = .Finished
                return
            }
            
            self.device.on = self.command == .TurnOn
            self.device.saveInBackgroundWithBlock() { (success, parseError) in
                if parseError != nil {
                    print("Parse save error: \(parseError)")
                } else {
                    print("Success! \(self.device.name) is now \(commandString.lowercaseString).")
                }
                
                self.state = .Finished
            }
        }
        
        print("Turning \(device.name) \(commandString.lowercaseString)...")
        commandTask?.resume()
    }
    
    private enum OperationState {
        case Ready
        case Executing
        case Finished
        
        func keyPath() -> String {
            switch self {
            case Ready:
                return "isReady"
            case Executing:
                return "isExecuting"
            case Finished:
                return "isFinished"
            }
        }
    }
}
