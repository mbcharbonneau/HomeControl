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
    
    // MARK: LocationController
    
    var beaconState = CLRegionState.Unknown
    var geofenceState = CLRegionState.Unknown
    
    // MARK: LocationController Private
    
    private let locationManager: CLLocationManager
    private let beaconRegion: CLBeaconRegion
    private let geofenceRegion: CLCircularRegion
    
    // MARK: NSObject
    
    override init() {

        let beaconUUID = NSUUID(UUIDString: Configuration.MonsterPit.BeaconUUID)
        let location = Configuration.MonsterPit.Location
        let radius = 50.0
        
        locationManager = CLLocationManager()
        beaconRegion = CLBeaconRegion(proximityUUID: beaconUUID, major: 0, minor: 0, identifier: "beacon")
        geofenceRegion = CLCircularRegion(center: location, radius: radius, identifier: "geofence")
        
        super.init()
        
        beaconRegion.notifyEntryStateOnDisplay = true
        beaconRegion.notifyOnEntry = true
        beaconRegion.notifyOnExit = true
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startRangingBeaconsInRegion( beaconRegion )
        locationManager.startMonitoringForRegion( beaconRegion )
        locationManager.startMonitoringForRegion( geofenceRegion )
        locationManager.requestStateForRegion( geofenceRegion )
    }
    
    // MARK: CLLocationManagerDelegate
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        locationManager.startRangingBeaconsInRegion( beaconRegion )
        locationManager.startMonitoringForRegion( beaconRegion )
        locationManager.startMonitoringForRegion( geofenceRegion )
        locationManager.requestStateForRegion( geofenceRegion )
    }
    
    func locationManager(manager: CLLocationManager!, didDetermineState state: CLRegionState, forRegion region: CLRegion!) {
        switch region.identifier {
        case beaconRegion.identifier:
            beaconState = state
            println( "iBeacon region changed: \(state)" )
        case geofenceRegion.identifier:
            geofenceState = state
            println( "Geofence region changed: \(state)" )
        default: ()
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName(Constants.ForceEvaluationNotification, object: self)
    }
    
    func locationManager(manager: CLLocationManager!, didRangeBeacons beacons: [AnyObject]!, inRegion region: CLBeaconRegion!) {
        // Only called in foreground mode.
        return
    }
}
