//
//  SwitchedDevice.swift
//  Monster Pit
//
//  Created by mbcharbonneau on 7/24/15.
//  Copyright (c) 2015 Downtown Software House. All rights reserved.
//

import UIKit
import Parse

class SwitchedDevice: PFObject, PFSubclassing {
    
    // MARK: SwitchedDevice

    var deciders = [DecisionMakerProtocol]()
    
    var name: String {
        get { return self["name"] as! String }
    }

    var on: Bool {
        get { return self["on"] as! Bool }
        set { self["on"] = newValue }
    }
    
    var deciderClasses: [String] {
        get { return self["deciderTypes"] as! [String] }
    }
    
    var online: Bool {
        get { return self["online"] as! Bool }
        set { self["online"] = newValue }
    }
    
    var isBusy: Bool {
        get { return backgroundTask != nil }
    }

    func turnOn( finished: ( NSError? ) -> Void ) {
        switchDevice(true, completionBlock: finished)
    }

    func turnOff( finished: ( NSError? ) -> Void ) {
        switchDevice(false, completionBlock: finished)
    }

    // MARK: SwitchedDevice Private
    
    private var commandTask: NSURLSessionTask?
    private var backgroundTask: UIBackgroundTaskIdentifier?
    
    private func switchDevice( turnOn: Bool, completionBlock: ( NSError? ) -> Void ) {
        
        if backgroundTask != nil {
            println("\(name) was sent a command before the previous command finished!")
            return
        }
        
        backgroundTask = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler {
            println("\(self.name) background task expired!")
            UIApplication.sharedApplication().endBackgroundTask(self.backgroundTask!)
            self.backgroundTask = nil
        }
        
        let command = turnOn ? "On" : "Off"
        let callback = { ( error: NSError? ) -> Void in
            
            if error == nil {
                self.on = turnOn
                self.saveInBackgroundWithBlock() { (success: Bool, parseError: NSError?) -> Void in
                    if parseError != nil {
                        println("Parse save error: \(parseError)")
                    }
                    completionBlock( error )
                    println("Success! \(self.name) is now \(command.lowercaseString).")
                    UIApplication.sharedApplication().endBackgroundTask(self.backgroundTask!)
                    self.backgroundTask = nil
                }

            } else {
                println("Command finished with error: \(error)")
                completionBlock( error )
                UIApplication.sharedApplication().endBackgroundTask(self.backgroundTask!)
                self.backgroundTask = nil
            }
        }
        
        println("Turning \(self.name) \(command.lowercaseString)...")
        sendCommand(command, callback: callback)
    }
    
    private func makeURLForCommand( command: String ) -> String {
        let eventName = name.stringByReplacingOccurrencesOfString(" ", withString: "") + command
        return "https://maker.ifttt.com/trigger/\(eventName)/with/key/\(Configuration.IFTTT.ClientKey)"
    }

    private func sendCommand( command: String, callback: ( NSError? ) -> Void ) {

        if let URL = NSURL( string: makeURLForCommand( command ) ) {

            let config = NSURLSessionConfiguration.defaultSessionConfiguration()
            let session = NSURLSession(configuration: config)
            let request = NSMutableURLRequest(URL: URL)

            request.HTTPMethod = "POST"

            commandTask = session.dataTaskWithRequest( request, completionHandler: { ( data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                dispatch_async( dispatch_get_main_queue(), { () -> Void in
                    if let error = error {
                        println("HTTP error: \(error)")
                    } else {
                        println("Finished request: \(response?.URL as NSURL!)")
                    }
                    callback( error )
                    self.commandTask = nil
                })
            })
            
            commandTask?.resume()
        }
    }
    
    // MARK: PFSubclassing
 
    class func parseClassName() -> String {
        return "Device"
    }
}
