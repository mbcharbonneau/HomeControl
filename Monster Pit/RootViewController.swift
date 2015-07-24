//
//  RootViewController.swift
//  Monster Pit
//
//  Created by mbcharbonneau on 7/20/15.
//  Copyright (c) 2015 Downtown Software House. All rights reserved.
//

import UIKit

class RootViewController: UICollectionViewController {

    private let dataController = DataController()
    private let colorGenerator = ColorGenerator()
    private let cellIdentifier = "SensorCell"
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
            
            for cell in collectionView.visibleCells() as! [RoomSensorCell] {
                cell.updateTimeLabel()
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
        
        if let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            
            let margins = layout.sectionInset.left + layout.sectionInset.right
            let width = ( layout.collectionViewContentSize().width - layout.minimumInteritemSpacing - margins ) / 2.0
            layout.itemSize = CGSizeMake( width, width * 0.8 )
        }
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
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataController.sensors.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier( cellIdentifier, forIndexPath: indexPath) as! RoomSensorCell
        let sensor = dataController.sensors[indexPath.row]

        if ( cell.backgroundColor == nil ) {
            cell.backgroundColor = colorGenerator.randomColor()
        }
        
        cell.configureWithSensor( sensor )
        
        return cell
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
            assert(false, "no view for this element!")
        }
    }
}

