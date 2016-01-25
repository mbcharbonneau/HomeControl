//
//  RootViewController.swift
//  Monster Pit TV
//
//  Created by Marc Charbonneau on 1/24/16.
//  Copyright © 2016 Downtown Software House. All rights reserved.
//

import UIKit

class RootViewController: UITableViewController {

    private var devices = [SwitchedDevice]()
    private var operationQueue = NSOperationQueue()
    
    private func reloadData() {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        operationQueue.maxConcurrentOperationCount = 1
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

