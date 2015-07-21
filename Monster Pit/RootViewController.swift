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
    private let cellIdentifier = "SensorCell"
    private var timer: NSTimer?

    // MARK: RootViewController

    func refreshDataSource( timer: NSTimer ) {

        dataController.refresh() {
            collectionView?.reloadData()
        }
    }

    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        timer?.invalidate()
        timer = NSTimer.scheduledTimerWithTimeInterval(60.0, target:self, selector:Selector("refreshDataSource:"), userInfo:nil, repeats:true)
        timer?.fire()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        timer?.invalidate()
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

        cell.backgroundColor = UIColor.redColor()
        cell.configureWithSensor( sensor )
        
        return cell
    }
}

