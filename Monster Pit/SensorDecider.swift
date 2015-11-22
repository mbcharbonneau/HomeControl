//
//  SensorDecider.swift
//  Monster Pit
//
//  Created by Marc Charbonneau on 7/25/15.
//  Copyright (c) 2015 Downtown Software House. All rights reserved.
//

import Foundation

class SensorDecider: DecisionMakerProtocol {
    
    var sensor: RoomSensor
    
    var name: String {
        get { return "Light Level" }
    }
    
    var state: State {
        get {
            guard let light = sensor.light else { return State.Unknown }
            return light > 10.0 ? State.Off : State.On
        }
    }
    
    init( sensor: RoomSensor ) {
        self.sensor = sensor
    }
}
