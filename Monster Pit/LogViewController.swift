//
//  LogViewController.swift
//  Monster Pit
//
//  Created by Marc Charbonneau on 11/26/15.
//  Copyright © 2015 Downtown Software House. All rights reserved.
//

import UIKit

class LogViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.allowsSelection = false
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44.0
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(tableView, selector: "reloadData", name: Constants.MessagesChangedNotification, object: nil)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: Constants.MessagesChangedNotification, object: nil)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return LogController.sharedController.messages.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier("LogMessageCell", forIndexPath: indexPath) as? LogMessageCell else { fatalError() }
        cell.configureWithLogMessage(LogController.sharedController.messages[indexPath.row])
        return cell
    }
}
