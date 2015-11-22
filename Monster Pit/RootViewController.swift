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
    
    @IBAction func toggleDeviceOnOff(sender: UISwitch) {
        
        let device = dataController.devices[sender.tag]

        // Switch the app into manual mode, but only if this device has some
        // deciders we're overriding.
        
        if device.deciders.count > 0 {
            dataController.enableAutoMode = false
            toggleAutoButton?.on = dataController.enableAutoMode
        }
        
        if sender.on {
            dataController.switchDevice(device, turnOn: true)
        } else {
            dataController.switchDevice(device, turnOn: false)
        }

        // Disable the UISwitch until the web request completes.
        
        sender.enabled = false
    }
    
    @IBAction func toggleAutoMode(sender: SlidingToggleButton) {
        dataController.enableAutoMode = sender.on
    }
    
    func refreshDataSource(timer: NSTimer) {
        
        dataController.refresh()
    }
    
    func refreshCellLabels(timer: NSTimer) {
        
        if let collectionView = collectionView {
            
            for cell in collectionView.visibleCells() {
                
                if let cell = cell as? RoomSensorCell {
                    cell.updateTimeLabel()
                } else if let cell = cell as? DeviceCell {
                    cell.updateDecidersLabel()
                }
            }
            
            if let label = updateLabel, date = dataController.lastUpdate {
                
                let formatter = NSDateComponentsFormatter()
                formatter.unitsStyle = NSDateComponentsFormatterUnitsStyle.Short
                formatter.includesApproximationPhrase = false
                formatter.collapsesLargestUnit = false
                formatter.maximumUnitCount = 1
                formatter.allowedUnits = [.Hour, .Minute, .Second, .Day]
                
                let time = formatter.stringFromDate( date, toDate:NSDate() )!
                label.text = "Last updated \(time) ago."
            }
        }
    }
    
    func scheduleNotifications(timer: NSTimer) {
        
        let notification = UILocalNotification()
        
        notification.fireDate = NSDate()
        notification.soundName = UILocalNotificationDefaultSoundName;
        
        switch notificationDevices.count {
        case 1:
            let device = notificationDevices[0]
            let action = device.on ? "on" : "off"
            notification.alertBody = "I turned \(action) \(device.name)."
        default:
            let turnedOn = notificationDevices.filter({ $0.on == true }).count
            let turnedOff = notificationDevices.filter({ $0.on == false }).count
            var actionString = ""
            
            if turnedOn > 0 {
                actionString += "I turned on \(turnedOn) devices. "
            }
            if turnedOff > 0 {
                actionString += "I turned off \(turnedOff) devices. "
            }
            
            notification.alertBody = actionString
        }
        
        UIApplication.sharedApplication().scheduleLocalNotification( notification )

        if let task = self.notificationTask {
            UIApplication.sharedApplication().endBackgroundTask(task)
        }
        
        notificationTask = nil
        notificationCoalescingTimer = nil
        notificationDevices.removeAll(keepCapacity: false)
    }
    
    // MARK: RootViewController Private
    
    private let dataController = DataController()
    private let sensorCellIdentifier = "SensorCell"
    private let deviceCellIdentifier = "DeviceCell"
    private let footerIdentifier = "Footer"
    private var updateCellsTimer: NSTimer?
    private var updateDataTimer: NSTimer?
    private var notificationCoalescingTimer: NSTimer?
    private var notificationDevices = [SwitchedDevice]()
    private var notificationTask: UIBackgroundTaskIdentifier?
    private weak var updateLabel: UILabel?
    
    @IBOutlet private weak var toggleAutoButton: SlidingToggleButton? {
        didSet {
            toggleAutoButton?.on = dataController.enableAutoMode
        }
    }
        
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView?.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        dataController.delegate = self
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
            let footer = collectionView.dequeueReusableSupplementaryViewOfKind( kind, withReuseIdentifier: footerIdentifier, forIndexPath: indexPath )
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
            return UIEdgeInsetsMake( 20.0, 20.0, 20.0, 20.0 )
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
    
    func dataControllerReloadedData(controller: DataController) {
        collectionView?.reloadData()
    }

    func dataControllerRefreshedSensors(controller: DataController) {
        collectionView?.reloadSections(NSIndexSet(index: 0))
    }
    
    func dataController(controller: DataController, toggledDevice: SwitchedDevice) {
        
        if let index = dataController.devices.indexOf(toggledDevice) {
            let path = NSIndexPath(forItem: index, inSection: 1)
            collectionView?.reloadItemsAtIndexPaths([path])
        }

        // If there are multiple notifications, group them into one (also it
        // takes several seconds for the switches to receive the command so 
        // there's no sense in showing a notification immediately).

        notificationCoalescingTimer?.invalidate()
        notificationDevices.append(toggledDevice)
        notificationCoalescingTimer = NSTimer(timeInterval: 5.0, target: self, selector: Selector("scheduleNotifications:"), userInfo: nil, repeats: false)
        NSRunLoop.currentRunLoop().addTimer(notificationCoalescingTimer!, forMode: NSRunLoopCommonModes)
        notificationTask = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler() {
            self.notificationCoalescingTimer?.fire()
        }
    }
}
