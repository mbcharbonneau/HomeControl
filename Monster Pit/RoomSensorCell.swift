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
            let tempString = NSString( format:"%.1f", celsiusToFahrenheit( degreesC ) )
            tempLabel?.text = "\(tempString) ℉"
        } else {
            tempLabel?.text = "-.- ℉"
        }
        
        if let humidity = sensor.humidity {
            let humidityString = NSString( format:"%.0f", humidity * 100.0 )
            humidityLabel?.text = "H: \(humidityString)%"
        } else {
            humidityLabel?.text = "H: -.-%"
        }
        
        if let light = sensor.light {
            let lightString = NSString( format:"%.0f", luxToPercent( light ) * 100.0 )
            lightLabel?.text = "L: \(lightString)%"
        } else {
            lightLabel?.text = "L: -.-%"
        }
        
        updateTimeLabel()
    }
    
    func updateTimeLabel() {
        
        let formatter = NSDateComponentsFormatter()
        formatter.unitsStyle = NSDateComponentsFormatterUnitsStyle.Short
        formatter.includesApproximationPhrase = false
        formatter.collapsesLargestUnit = false
        formatter.maximumUnitCount = 1
        formatter.allowedUnits = NSCalendarUnit.CalendarUnitHour | NSCalendarUnit.CalendarUnitMinute | NSCalendarUnit.CalendarUnitSecond | NSCalendarUnit.CalendarUnitDay
        
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
    
    private func luxToPercent( lux: Double ) -> Double {
        return min( lux / 60, 1.0 )
    }
}
