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
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        dataController.refresh() {
            collectionView?.reloadData()
        }
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataController.sensors.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier( cellIdentifier, forIndexPath: indexPath) as! UICollectionViewCell
        
        cell.backgroundColor = UIColor.redColor()
        
        return cell
    }
}

