//
//  BeaconDecider.swift
//  Monster Pit
//
//  Created by Marc Charbonneau on 7/25/15.
//  Copyright (c) 2015 Downtown Software House. All rights reserved.
//

import Foundation

class BeaconDecider: DecisionMakerProtocol {
    
    var name: String {
        get { return "iBeacon" }
    }
    
    var state: State {
        get { return State.On }
    }
}
