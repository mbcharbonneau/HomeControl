//
//  LogController.swift
//  Monster Pit
//
//  Created by Marc Charbonneau on 11/26/15.
//  Copyright © 2015 Downtown Software House. All rights reserved.
//

import Foundation

protocol LoggingObject {
    func log(message: String) -> Void
}

extension LoggingObject {
    func log(message: String) {
        LogController.sharedController.log(message)
    }
}

class LogController: LoggingObject {
    
    static let sharedController = LogController()
    
    var messages = [LogMessage]()
    
    init() {
        let defaults = NSUserDefaults.standardUserDefaults()
        if let array = defaults.arrayForKey(Constants.LogMessagesDefaultsKey) as? [[String: AnyObject]] {
            let logs = array.map({ return LogMessage($0)! })
            messages.appendContentsOf(logs)
        }
    }
    
    func log(logMessage: LogMessage) {
        print(logMessage.message)
        messages.insert(logMessage, atIndex: 0)
        if messages.count > 200 {
            messages.removeRange(Range<Int>(start: 199, end: messages.count))
        }
        NSNotificationCenter.defaultCenter().postNotificationName(Constants.MessagesChangedNotification, object: self)
        save()
    }
    
    func log(message: String) {
        log(LogMessage(message))
    }
    
    private func save() {
        let defaults = NSUserDefaults.standardUserDefaults()
        let array = messages.map({ return $0.dictionary() })
        defaults.setObject(array, forKey: Constants.LogMessagesDefaultsKey)
        defaults.synchronize()
    }
}
