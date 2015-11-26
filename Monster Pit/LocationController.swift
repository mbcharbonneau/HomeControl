//
//  LocationController.swift
//  Monster Pit
//
//  Created by Marc Charbonneau on 7/25/15.
//  Copyright (c) 2015 Downtown Software House. All rights reserved.
//

import UIKit
import CoreLocation

class LocationController: NSObject, CLLocationManagerDelegate {
    
    // MARK: LocationController
    
    var beaconState = CLRegionState.Unknown {
        didSet {
            LogController.sharedController.log( "iBeacon state change: \(beaconState)" )
            NSNotificationCenter.defaultCenter().postNotificationName(Constants.ForceEvaluationNotification, object: self)
        }
    }
    
    var geofenceState = CLRegionState.Unknown {
        didSet {
            LogController.sharedController.log( "Geofence state change: \(geofenceState)" )
            NSNotificationCenter.defaultCenter().postNotificationName(Constants.ForceEvaluationNotification, object: self)
        }
    }
    
    var isChanging: Bool {
        get { return beaconDebounceTimer != nil || geofenceDebounceTimer != nil }
    }

    // MARK: LocationController Private
    
    private let locationManager: CLLocationManager
    private let beaconRegion: CLBeaconRegion
    private let geofenceRegion: CLCircularRegion
    private var beaconDebounceTimer: NSTimer?
    private var changeBeaconStateTask: UIBackgroundTaskIdentifier?
    private var geofenceDebounceTimer: NSTimer?
    private var changeGeofenceTask: UIBackgroundTaskIdentifier?
    
    private var nextBeaconState = CLRegionState.Unknown {
        didSet {
            if beaconState == .Unknown {
                beaconState = nextBeaconState
            } else {
                beaconDebounceTimer?.invalidate()
                beaconDebounceTimer = NSTimer(timeInterval: 20.0, target: self, selector: "endDebounceTimer:", userInfo: nil, repeats: false)
                NSRunLoop.currentRunLoop().addTimer(beaconDebounceTimer!, forMode: NSRunLoopCommonModes)
                if changeBeaconStateTask == nil {
                    changeBeaconStateTask = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler() {
                        self.beaconDebounceTimer?.fire()
                    }
                }
                LogController.sharedController.log( "Debouncing iBeacon state change: \(nextBeaconState)" )
            }
        }
    }
    
    private var nextGeofenceState = CLRegionState.Unknown {
        didSet {
            if geofenceState == .Unknown {
                geofenceState = nextGeofenceState
            } else {
                geofenceDebounceTimer?.invalidate()
                geofenceDebounceTimer = NSTimer(timeInterval: 20.0, target: self, selector: "endDebounceTimer:", userInfo: nil, repeats: false)
                NSRunLoop.currentRunLoop().addTimer(geofenceDebounceTimer!, forMode: NSRunLoopCommonModes)
                if changeGeofenceTask == nil {
                    changeGeofenceTask = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler() {
                        self.geofenceDebounceTimer?.fire()
                    }
                }
                LogController.sharedController.log( "Debouncing Geofence state change: \(nextGeofenceState)" )
            }
        }
    }
    
    @objc private func endDebounceTimer(timer: NSTimer) {
        
        if timer == beaconDebounceTimer {
            beaconDebounceTimer = nil
            beaconState = nextBeaconState
            if let task = self.changeBeaconStateTask { UIApplication.sharedApplication().endBackgroundTask(task) }
            self.changeBeaconStateTask = nil
        } else if timer == geofenceDebounceTimer {
            geofenceDebounceTimer = nil
            geofenceState = nextGeofenceState
            if let task = self.changeGeofenceTask { UIApplication.sharedApplication().endBackgroundTask(task) }
            self.changeBeaconStateTask = nil
        }
    }
    
    // MARK: NSObject
    
    override init() {

        let beaconUUID = NSUUID(UUIDString: Configuration.MonsterPit.BeaconUUID)!
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
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        locationManager.startRangingBeaconsInRegion( beaconRegion )
        locationManager.startMonitoringForRegion( beaconRegion )
        locationManager.startMonitoringForRegion( geofenceRegion )
        locationManager.requestStateForRegion( geofenceRegion )
    }
    
    func locationManager(manager: CLLocationManager, didDetermineState state: CLRegionState, forRegion region: CLRegion) {
        switch region.identifier {
        case beaconRegion.identifier:
            nextBeaconState = state
        case geofenceRegion.identifier:
            nextGeofenceState = state
        default: ()
        }
    }
    
    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
        // Only called in foreground mode.
        return
    }
}
