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
    @IBOutlet weak private var lastUpdatedLabel: UILabel?
    
    private var lastUpdate: NSDate?
    
    func configureWithSensor( sensor: RoomSensor ) {

        nameLabel?.text = sensor.name
        lastUpdate = sensor.updatedAt

        if let degreesC = sensor.temperature {
            tempLabel?.text = "\(celsiusToFahrenheit( degreesC )) ℉"
        } else {
            tempLabel?.text = "0.0 ℉"
        }
        
        if let humidity = sensor.humidity {
            humidityLabel?.text = "\(humidity * 100.0)% H"
        } else {
            humidityLabel?.text = "0.0% H"
        }
        
        if let light = sensor.light {
            lightLabel?.text = "\(light * 100.0)% L"
        } else {
            lightLabel?.text = "0.0% L"
        }
        
        updateTimeLabel()
    }
    
    func updateTimeLabel() {
        
        let formatter = NSDateComponentsFormatter()
        formatter.unitsStyle = NSDateComponentsFormatterUnitsStyle.Short
        formatter.includesApproximationPhrase = false
        formatter.collapsesLargestUnit = false
        formatter.maximumUnitCount = 1
        formatter.allowedUnits = NSCalendarUnit.CalendarUnitMinute | NSCalendarUnit.CalendarUnitSecond | NSCalendarUnit.CalendarUnitDay
        
        if let date = lastUpdate {
            let string = formatter.stringFromDate( date, toDate:NSDate.new() )!
            lastUpdatedLabel?.text = "Updated \(string) ago"
        } else {
            lastUpdatedLabel?.text = ""
        }
    }
    
    private func celsiusToFahrenheit( celsius: Double ) -> Double {
        return celsius * 9 / 5 + 32
    }
}
