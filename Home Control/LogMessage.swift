//
//  LogMessage.swift
//  Home Control
//
//  Created by Marc Charbonneau on 11/26/15.
//  Copyright © 2015 Once Living LLC. All rights reserved.
//

import Foundation

struct LogMessage {
    
    let message: String
    let date: NSDate
    let archived: Bool
    
    init(_ message: String) {
        self.message = message
        self.date = NSDate()
        self.archived = false
    }
    
    init?(_ dictionary: [String: AnyObject]) {
        guard let message = dictionary["message"] as? String else { return nil }
        guard let date = dictionary["date"] as? NSDate else { return nil }
        self.message = message
        self.date = date
        self.archived = true
    }
    
    func dictionary() -> [String: AnyObject] {
        return ["message": message, "date": date]
    }
}
