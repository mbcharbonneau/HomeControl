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

        nameLabel?.text = sensor.name

        if let degreesC = sensor.temperature {
            tempLabel?.text = "\(celsiusToFahrenheit( degreesC )) ℉"
        } else {
            tempLabel?.text = "0.0 ℉"
        }
        
        if let humidity = sensor.humidity {
            humidityLabel?.text = "\(humidity * 100.0)%"
        } else {
            humidityLabel?.text = "0.0%"
        }
        
        if let light = sensor.light {
            lightLabel?.text = "\(light * 100.0)%"
        } else {
            lightLabel?.text = "0.0%"
        }
    }

    private func celsiusToFahrenheit( celsius: Double ) -> Double {
        return celsius * 9 / 5 + 32
    }
}
