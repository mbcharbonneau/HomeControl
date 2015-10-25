//
//  Extensions.swift
//  Monster Pit
//
//  Created by Marc Charbonneau on 7/25/15.
//  Copyright (c) 2015 Downtown Software House. All rights reserved.
//

import Foundation
import CoreLocation

extension CLRegionState: CustomStringConvertible {
    public var description: String {
        switch self {
        case Unknown:
            return "Unknown"
        case Inside:
            return "Inside"
        case Outside:
            return "Outside"
        }
    }
}
