//
//  LocationController.swift
//  Monster Pit
//
//  Created by Marc Charbonneau on 7/25/15.
//  Copyright (c) 2015 Downtown Software House. All rights reserved.
//

import Foundation
import CoreLocation

class LocationController: NSObject, CLLocationManagerDelegate {
    
    // MARK: LocationController Private
    
    private let locationManager: CLLocationManager
    
    // MARK: NSObject
    
    override init() {

        locationManager = CLLocationManager()

        super.init()
        
        locationManager.delegate = self
    }
    
    // MARK: CLLocationManagerDelegate
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
    }
    
    func locationManager(manager: CLLocationManager!, didDetermineState state: CLRegionState, forRegion region: CLRegion!) {
        
    }
}
