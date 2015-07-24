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

    class func parseClassName() -> String {
        return "Device"
    }

    var name: String {
        get { return self["name"] as! String }
    }

    var state: Bool {
        get { return self["state"] as! Bool }
        set( newState ) {
            self["state"] = newState
        }
    }

    func turnOn( finished: () -> Void ) {
        sendCommand( "On", callback: finished )
    }

    func turnOff( finished: () -> Void ) {
        sendCommand( "Off", callback: finished )
    }

    private func makeURLForCommand( command: String ) -> String {
        let eventName = name.stringByReplacingOccurrencesOfString(" ", withString: "") + command
        return "https://maker.ifttt.com/trigger/\(eventName)/with/key/\(Configuration.IFTTT.ClientKey)"
    }

    private func sendCommand( command: String, callback: () -> Void ) {

        if let URL = NSURL( string: makeURLForCommand( command ) ) {

            let config = NSURLSessionConfiguration.defaultSessionConfiguration()
            let session = NSURLSession(configuration: config)
            let request = NSMutableURLRequest(URL: URL)

            request.HTTPMethod = "POST"

            session.downloadTaskWithRequest( request, completionHandler: { (location, response, error) -> Void in
                if ( error == nil ) {
                    callback()
                }
            })
        }
    }
}
