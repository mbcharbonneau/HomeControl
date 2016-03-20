//
//  StatusIndicatorView.swift
//  Home Control
//
//  Created by Marc Charbonneau on 7/25/15.
//  Copyright (c) 2015 Once Living LLC. All rights reserved.
//

import UIKit

class StatusIndicatorView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.lightGrayColor();
    }
        
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.lightGrayColor();
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.frame.size.width / 2.0;
        self.layer.borderColor = UIColor.grayColor().CGColor;
        self.layer.borderWidth = 0.5;
    }
}
