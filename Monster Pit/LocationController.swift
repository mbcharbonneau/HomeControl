//
//  LocationController.swift
//  Monster Pit
//
//  Created by Marc Charbonneau on 7/25/15.
//  Copyright (c) 2015 Downtown Software House. All rights reserved.
//

import UIKit
import CoreLocation

extension CLProximity: CustomStringConvertible {
    public var description: String {
        switch self {
        case .Unknown:
            return "unknown"
        case .Immediate:
            return "immediate"
        case .Near:
            return "near"
        case .Far:
            return "far"
        }
    }
}

class LocationController: NSObject, LoggingObject, CLLocationManagerDelegate {
    
    // MARK: LocationController
    
    private(set) var beaconState = CLRegionState.Unknown {
        didSet {
            log("iBeacon state change: \(beaconState)")
            NSNotificationCenter.defaultCenter().postNotificationName(Constants.ForceEvaluationNotification, object: self)
        }
    }
    
    private(set) var geofenceState = CLRegionState.Unknown {
        didSet {
            log("Geofence state change: \(geofenceState)")
            NSNotificationCenter.defaultCenter().postNotificationName(Constants.ForceEvaluationNotification, object: self)
        }
    }
    
    func requestLocationUpdate() {
        locationManager.requestLocation()
        locationManager.requestStateForRegion(beaconRegion)
        locationManager.requestStateForRegion(geofenceRegion)
    }
    
    // MARK: LocationController Private
    
    private let locationManager: CLLocationManager
    private let beaconRegion: CLBeaconRegion
    private let geofenceRegion: CLCircularRegion
    
    private func beginRegionMonitoring() {
        locationManager.startRangingBeaconsInRegion(beaconRegion)
        locationManager.startMonitoringForRegion(beaconRegion)
        locationManager.startMonitoringForRegion(geofenceRegion)
        locationManager.requestStateForRegion(geofenceRegion)
        locationManager.requestStateForRegion(beaconRegion)
    }
    
    // MARK: NSObject
    
    override init() {

        let beaconUUID = NSUUID(UUIDString: Configuration.MonsterPit.BeaconUUID)!
        let location = Configuration.MonsterPit.Location
        let radius = 50.0
        
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        beaconRegion = CLBeaconRegion(proximityUUID: beaconUUID, major: 0, minor: 0, identifier: "beacon")
        geofenceRegion = CLCircularRegion(center: location, radius: radius, identifier: "geofence")
        
        super.init()
        
        beaconRegion.notifyEntryStateOnDisplay = true
        beaconRegion.notifyOnEntry = true
        beaconRegion.notifyOnExit = true
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        
        beginRegionMonitoring()
    }
    
    // MARK: CLLocationManagerDelegate
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last!
        let coordinate = location.coordinate
        log("Found location.")
        geofenceState = geofenceRegion.containsCoordinate(coordinate) ? .Inside : .Outside
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        log("Changed location authorization status.")
        beginRegionMonitoring()
    }
    
    func locationManager(manager: CLLocationManager, didDetermineState state: CLRegionState, forRegion region: CLRegion) {
        switch region.identifier {
        case beaconRegion.identifier:
            beaconState = state
        case geofenceRegion.identifier:
            geofenceState = state
        default: ()
        }
    }
    
    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
        // Only called in foreground mode.
        guard let beacon = beacons.first else { return }
        log("iBeacon is now \(beacon.proximity)")
        return
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        log("Location manager error: \(error).")
    }
}
