//
//  DeviceCell.swift
//  Monster Pit
//
//  Created by mbcharbonneau on 7/24/15.
//  Copyright (c) 2015 Downtown Software House. All rights reserved.
//

import UIKit

class DeviceCell: UICollectionViewCell {

    @IBOutlet weak private var nameLabel: UILabel?
    @IBOutlet weak private var deciderLabel: UILabel?
    @IBOutlet weak private var deviceSwitch: UISwitch?

    required init(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
        
        backgroundColor = UIColor.whiteColor()
        layer.cornerRadius = 6.0
    }

    func configureWithDevice( device: SwitchedDevice ) {

        nameLabel?.text = device.name
        deciderLabel?.text = deciderString( device.deciders )
        deviceSwitch?.setOn( device.on, animated: true )
        deviceSwitch?.enabled = !device.isBusy && device.online
    }
    
    func setSwitchTarget( target: AnyObject?, action: Selector, identifier: Int ) {
        
        deviceSwitch?.removeTarget( nil, action: nil, forControlEvents: UIControlEvents.ValueChanged )
        deviceSwitch?.addTarget( target, action: action, forControlEvents: UIControlEvents.ValueChanged )
        deviceSwitch?.tag = identifier
    }
    
    private func deciderString( deciders: [DecisionMakerProtocol] ) -> String {
        var string = String()
        
        for decider in deciders {
            if !string.isEmpty {
                string += ", "
            }
            string += "\(decider.name) (\(decider.state))"
        }
        
        return string.isEmpty ? "Manual Only" : string
    }
}
