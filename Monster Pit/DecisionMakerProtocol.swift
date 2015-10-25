//
//  DecisionMakerProtocol.swift
//  Monster Pit
//
//  Created by Marc Charbonneau on 7/25/15.
//  Copyright (c) 2015 Downtown Software House. All rights reserved.
//

import Foundation

enum State: CustomStringConvertible {
    case On
    case Off
    case Unknown
    
    var description: String {
        switch self {
        case Unknown:
            return "?"
        case On:
            return "on"
        case Off:
            return "off"
        }
    }
}

protocol DecisionMakerProtocol {
    var name: String { get }
    var state: State { get }
}
