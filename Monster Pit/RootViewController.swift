//
//  RootViewController.swift
//  Monster Pit
//
//  Created by mbcharbonneau on 7/20/15.
//  Copyright (c) 2015 Downtown Software House. All rights reserved.
//

import UIKit

class RootViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, DataControllerDelegate {
    
    // MARK: RootViewController
    
    @IBAction func toggleDeviceOnOff( sender: UISwitch ) {
        
        dataController.enableAutoMode = false
        toggleAutoButton?.title = dataController.enableAutoMode ? "Automatic" : "Manual"
        
        let device = dataController.devices[sender.tag]
        let path = NSIndexPath(forItem: sender.tag, inSection: 1)
        
        if sender.on {
            device.turnOn { ( error: NSError? ) -> Void in
                self.collectionView?.reloadItemsAtIndexPaths([path])
            }
        } else {
            device.turnOff { ( error: NSError? ) -> Void in
                self.collectionView?.reloadItemsAtIndexPaths([path])
            }
        }

        sender.enabled = false
    }
    
    @IBAction func toggleAutoMode( sender: AnyObject! ) {
        dataController.enableAutoMode = !dataController.enableAutoMode
        toggleAutoButton?.title = dataController.enableAutoMode ? "Automatic" : "Manual"
    }
    
    func refreshDataSource( timer: NSTimer ) {
        
        dataController.refresh()
    }
    
    func refreshCellLabels( timer: NSTimer ) {
        
        if let collectionView = collectionView {
            
            for cell in collectionView.visibleCells() as! [UICollectionViewCell] {
                
                if let cell = cell as? RoomSensorCell {
                    cell.updateTimeLabel()
                }
            }
            
            if let label = updateLabel, date = dataController.lastUpdate {
                
                let formatter = NSDateComponentsFormatter()
                formatter.unitsStyle = NSDateComponentsFormatterUnitsStyle.Short
                formatter.includesApproximationPhrase = false
                formatter.collapsesLargestUnit = false
                formatter.maximumUnitCount = 1
                formatter.allowedUnits = NSCalendarUnit.CalendarUnitHour | NSCalendarUnit.CalendarUnitMinute | NSCalendarUnit.CalendarUnitSecond | NSCalendarUnit.CalendarUnitDay
                
                let time = formatter.stringFromDate( date, toDate:NSDate.new() )!
                label.text = "Last updated \(time) ago."
            }
        }
    }
    
    // MARK: RootViewController Private
    
    private let dataController = DataController()
    private let sensorCellIdentifier = "SensorCell"
    private let deviceCellIdentifier = "DeviceCell"
    private let footerIdentifier = "Footer"
    private var updateCellsTimer: NSTimer?
    private var updateDataTimer: NSTimer?
    private weak var updateLabel: UILabel?
    @IBOutlet private weak var toggleAutoButton: UIBarButtonItem?
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView?.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        dataController.delegate = self
        toggleAutoButton?.title = dataController.enableAutoMode ? "Automatic" : "Manual"
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        updateDataTimer?.invalidate()
        updateDataTimer = NSTimer.scheduledTimerWithTimeInterval(60.0, target:self, selector:Selector("refreshDataSource:"), userInfo:nil, repeats:true)
        updateDataTimer?.fire()
        
        updateCellsTimer?.invalidate()
        updateCellsTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target:self, selector:Selector("refreshCellLabels:"), userInfo:nil, repeats:true)
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        updateDataTimer?.invalidate()
        updateCellsTimer?.invalidate()
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 2
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return dataController.sensors.count
        case 1:
            return dataController.devices.count
        default:
            assert( false, "invalid section" )
        }
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        switch indexPath.section {
        case 0:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier( sensorCellIdentifier, forIndexPath: indexPath) as! RoomSensorCell
            cell.configureWithSensor( dataController.sensors[indexPath.row] )
            return cell

        case 1:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier( deviceCellIdentifier, forIndexPath: indexPath) as! DeviceCell
            cell.configureWithDevice( dataController.devices[indexPath.row] )
            cell.setSwitchTarget( self, action: Selector("toggleDeviceOnOff:"), identifier: indexPath.row )
            return cell
        default:
            assert( false, "invalid section" )
        }
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        switch kind {
        case UICollectionElementKindSectionFooter:
            let footer = collectionView.dequeueReusableSupplementaryViewOfKind( kind, withReuseIdentifier: footerIdentifier, forIndexPath: indexPath ) as! UICollectionReusableView
            if let label = footer.viewWithTag( 100 ) as? UILabel {
                updateLabel = label
            }
            return footer
        default:
            assert( false, "invalid element" )
        }
    }

    // MARK: UICollectionViewDelegateFlowLayout

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {

        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        let margins = layout.sectionInset.left + layout.sectionInset.right

        switch indexPath.section {
        case 0:
            let width = ( collectionView.frame.size.width - layout.minimumInteritemSpacing - margins ) / 2.0
            return CGSizeMake( width, width * 0.8 )
        case 1:
            return CGSizeMake( collectionView.frame.size.width - margins, 60.0 )
        default:
            assert( false, "invalid section" )
        }
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        switch section {
        case 0:
            return UIEdgeInsetsMake( 20.0, 20.0, 10.0, 20.0 )
        case 1:
            return UIEdgeInsetsMake( 0.0, 20.0, 20.0, 20.0 )
        default:
            assert( false, "invalid section" )
        }
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        switch section {
        case 0:
            return CGSizeZero
        case 1:
            return CGSizeMake( collectionView.frame.width, 34.0 )
        default:
            assert( false, "invalid section" )
        }
    }
    
    // MARK: DataControllerDelegate
    
    func dataControllerRefreshed(controller: DataController) {
        collectionView?.reloadData()
    }
    
    func dataController(controller: DataController, toggledDevice: SwitchedDevice) {
        collectionView?.reloadSections(NSIndexSet(index: 1))
        
        let interval: NSTimeInterval = 5.0
        let action = toggledDevice.on ? "on" : "off"
        let text = "I turned \(action) \(toggledDevice.name)."
        let notification = UILocalNotification()
        
        notification.fireDate = NSDate(timeIntervalSinceNow: interval)
        notification.alertBody = text
        
        UIApplication.sharedApplication().scheduleLocalNotification( notification )
    }
}
