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
    
    // MARK: NSObject
    
    override func isEqual(object: AnyObject?) -> Bool {
        guard let other = object as? SwitchedDevice else { return false }
        return other.name == name
    }
    
    // MARK: PFSubclassing
 
    class func parseClassName() -> String {
        return "Device"
    }
}

func ==(lhs: SwitchedDevice, rhs: SwitchedDevice) -> Bool {
    return lhs.isEqual(rhs)
}
