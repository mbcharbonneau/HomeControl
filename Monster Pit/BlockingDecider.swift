//
//  BlockingDecider.swift
//  Monster Pit
//
//  Created by Marc Charbonneau on 7/25/15.
//  Copyright (c) 2015 Downtown Software House. All rights reserved.
//

import Foundation

class BlockingDecider: DecisionMakerProtocol {
    
    var name: String {
        get { return "Auto Enable" }
    }
    
    var blockOtherDeciders: Bool
    
    var state: State {
        get {
            return blockOtherDeciders ? State.Unknown : State.On
        }
    }
    
    init( blockOtherDeciders: Bool ) {
        self.blockOtherDeciders = blockOtherDeciders
    }
}
