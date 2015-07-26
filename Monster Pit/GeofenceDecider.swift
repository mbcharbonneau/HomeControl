//
//  GeofenceDecider.swift
//  Monster Pit
//
//  Created by Marc Charbonneau on 7/25/15.
//  Copyright (c) 2015 Downtown Software House. All rights reserved.
//

import Foundation
import CoreLocation

class GeofenceDecider: DecisionMakerProtocol {
    
    var locationController: LocationController
    
    init( locationController: LocationController ) {
        self.locationController = locationController
    }
    
    var name: String {
        get { return "Geofence" }
    }
    
    var state: State {
        get {
            switch locationController.geofenceState {
            case CLRegionState.Unknown:
                return State.Unknown
            case CLRegionState.Inside:
                return State.On
            case CLRegionState.Outside:
                return State.Off
            }
        }
    }
}
