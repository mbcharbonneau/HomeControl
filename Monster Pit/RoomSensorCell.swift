//
//  RoomSensorCell.swift
//  Monster Pit
//
//  Created by mbcharbonneau on 7/21/15.
//  Copyright (c) 2015 Downtown Software House. All rights reserved.
//

import UIKit

class RoomSensorCell: UICollectionViewCell {

    @IBOutlet weak private var nameLabel: UILabel?
    @IBOutlet weak private var tempLabel: UILabel?
    @IBOutlet weak private var humidityLabel: UILabel?
    @IBOutlet weak private var lightLabel: UILabel?

    func configureWithSensor( sensor: RoomSensor ) {

        let degreesF = celsiusToFahrenheit( sensor.temperature )
        let humidity = sensor.humidity * 100
        let light = sensor.light * 100

        nameLabel?.text = sensor.name
        tempLabel?.text = "\(degreesF) ℉"
        humidityLabel?.text = "\(humidity)%"
        lightLabel?.text = "\(light)%"
    }

    private func celsiusToFahrenheit( celsius: Double ) -> Double {
        return celsius * 9 / 5 + 32
    }
}
