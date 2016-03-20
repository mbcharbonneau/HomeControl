//
//  BeaconDecider.swift
//  Home Control
//
//  Created by Marc Charbonneau on 7/25/15.
//  Copyright (c) 2015 Once Living LLC. All rights reserved.
//

import Foundation
import CoreLocation

class BeaconDecider: DecisionMakerProtocol {
    
    var locationController: LocationController
    
    init( locationController: LocationController ) {
        self.locationController = locationController
    }
    
    var name: String {
        get { return "iBeacon" }
    }
    
    var state: State {
        get {
            switch locationController.beaconState {
            case CLRegionState.Unknown:
                return State.Unknown
            case CLRegionState.Inside:
                return State.Off
            case CLRegionState.Outside:
                return State.On
            }
        }
    }
}
