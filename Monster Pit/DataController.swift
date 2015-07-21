//
//  DataController.swift
//  Monster Pit
//
//  Created by Marc Charbonneau on 7/20/15.
//  Copyright (c) 2015 Downtown Software House. All rights reserved.
//

import Foundation

class DataController {
    
    var sensors = [RoomSensor]()
    
    func refresh(finished: () -> Void) {
        
        sensors.removeAll(keepCapacity: true)
        
        let livingRoom = RoomSensor( dictionary:["name": "Living Room"] )
        let bedroom = RoomSensor( dictionary:["name": "Bedroom"] )

        sensors += [livingRoom, bedroom]
        
        finished()
    }
}
