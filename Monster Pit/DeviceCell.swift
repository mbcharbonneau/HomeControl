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
    }
}
