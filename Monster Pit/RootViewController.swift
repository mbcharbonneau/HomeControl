//
//  RootViewController.swift
//  Monster Pit
//
//  Created by mbcharbonneau on 7/20/15.
//  Copyright (c) 2015 Downtown Software House. All rights reserved.
//

import UIKit

class RootViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    private let dataController = DataController()
    private let colorGenerator = ColorGenerator()
    private let sensorCellIdentifier = "SensorCell"
    private let deviceCellIdentifier = "DeviceCell"
    private let footerIdentifier = "Footer"
    private var updateCellsTimer: NSTimer?
    private var updateDataTimer: NSTimer?
    private weak var updateLabel: UILabel?
    
    // MARK: RootViewController

    func refreshDataSource( timer: NSTimer ) {

        dataController.refresh() {
            collectionView?.reloadData()
        }
    }
    
    func updateCells( timer: NSTimer ) {
        
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

    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()

        colorGenerator.saturation = 0.3
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        updateDataTimer?.invalidate()
        updateDataTimer = NSTimer.scheduledTimerWithTimeInterval(60.0, target:self, selector:Selector("refreshDataSource:"), userInfo:nil, repeats:true)
        updateDataTimer?.fire()
        
        updateCellsTimer?.invalidate()
        updateCellsTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target:self, selector:Selector("updateCells:"), userInfo:nil, repeats:true)
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

            if ( cell.backgroundColor == nil ) {
                cell.backgroundColor = colorGenerator.randomColor()
            }

            cell.configureWithSensor( dataController.sensors[indexPath.row] )
            
            return cell

        case 1:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier( deviceCellIdentifier, forIndexPath: indexPath) as! DeviceCell

            if ( cell.backgroundColor == nil ) {
                cell.backgroundColor = colorGenerator.randomColor()
            }

            cell.configureWithDevice( dataController.devices[indexPath.row] )

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
            return CGSizeMake( collectionView.frame.size.width - margins, 50.0 )
        default:
            assert( false, "invalid section" )
        }
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        switch section {
        case 0:
            return UIEdgeInsetsMake( 40.0, 20.0, 20.0, 20.0 )
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
            return CGSizeMake( collectionView.frame.width, 10.0 )
        default:
            assert( false, "invalid section" )
        }
    }
}
