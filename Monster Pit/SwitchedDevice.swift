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

    private var deciders = [DecisionMakerProtocol]()
    private var commandTask: NSURLSessionTask?
    
    var name: String {
        get { return self["name"] as! String }
    }

    var on: Bool {
        get { return self["on"] as! Bool }
        set( newState ) { self["on"] = newState }
    }
    
    var isBusy: Bool {
        get { return commandTask != nil && commandTask?.state != NSURLSessionTaskState.Completed }
    }

    func turnOn( finished: ( NSError? ) -> Void ) {
        sendCommand( "On", callback: { ( error: NSError? ) -> Void in
            if ( error == nil ) {
                self.on = true
            }
            finished( error )
        })
    }

    func turnOff( finished: ( NSError? ) -> Void ) {
        sendCommand( "Off", callback: { ( error: NSError? ) -> Void in
            if ( error == nil ) {
                self.on = false
            }
            finished( error )
        })
    }

    // MARK: SwitchedDevice Private
    
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
