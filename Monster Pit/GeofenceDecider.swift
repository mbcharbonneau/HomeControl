//
//  GeofenceDecider.swift
//  Monster Pit
//
//  Created by Marc Charbonneau on 7/25/15.
//  Copyright (c) 2015 Downtown Software House. All rights reserved.
//

import Foundation

class GeofenceDecider: DecisionMakerProtocol {
    
    var name: String {
        get { return "Geofence" }
    }
    
    var state: State {
        get { return State.On }
    }
}
