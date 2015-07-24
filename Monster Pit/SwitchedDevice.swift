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

    func turnOn() {

    }

    func turnOff() {
        
    }
}
