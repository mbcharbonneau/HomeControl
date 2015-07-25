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
    @IBOutlet weak private var deviceSwitch: UISwitch?

    func configureWithDevice( device: SwitchedDevice ) {

        nameLabel?.text = device.name
        deviceSwitch?.enabled = !device.isBusy
        deviceSwitch?.setOn( device.on, animated: true )
    }
    
    func setSwitchTarget( target: AnyObject?, action: Selector, identifier: Int ) {
        
        deviceSwitch?.removeTarget( nil, action: nil, forControlEvents: UIControlEvents.ValueChanged )
        deviceSwitch?.addTarget( target, action: action, forControlEvents: UIControlEvents.ValueChanged )
        deviceSwitch?.tag = identifier
    }
}
