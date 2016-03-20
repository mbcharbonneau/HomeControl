//
//  LogMessageCell.swift
//  Home Control
//
//  Created by Marc Charbonneau on 11/26/15.
//  Copyright © 2015 Once Living LLC. All rights reserved.
//

import UIKit

class LogMessageCell: UITableViewCell {
    
    @IBOutlet private var messageLabel: UILabel?
    @IBOutlet private var dateLabel: UILabel?
    
    static private let dateFormatter = NSDateFormatter()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        var token: dispatch_once_t = 0
        dispatch_once(&token) {
            LogMessageCell.dateFormatter.dateStyle = .ShortStyle
            LogMessageCell.dateFormatter.timeStyle = .MediumStyle
        }
    }
    
    func configureWithLogMessage(logMessage: LogMessage) {
        messageLabel?.text = logMessage.message
        dateLabel?.text = LogMessageCell.dateFormatter.stringFromDate(logMessage.date)
        messageLabel?.textColor = logMessage.archived ? UIColor.darkGrayColor() : UIColor.blackColor()
        backgroundColor = logMessage.archived ? UIColor(white: 0.96, alpha: 1.0) : UIColor.whiteColor()
    }
}
