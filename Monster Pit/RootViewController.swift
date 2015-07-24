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
    private var updateCellsTimer: NSTimer?
    private var updateDataTimer: NSTimer?
    
    // MARK: RootViewController

    func refreshDataSource( timer: NSTimer ) {

        dataController.refresh() {
            collectionView?.reloadData()
        }
    }
    
    func updateCells( timer: NSTimer ) {
        
        if let view = collectionView {
            
            for cell in view.visibleCells() as! [RoomSensorCell] {
                cell.updateTimeLabel()
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
}

