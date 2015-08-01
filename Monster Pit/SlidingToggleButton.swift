//
//  SlidingToggleButton.swift
//  Monster Pit
//
//  Created by Marc Charbonneau on 7/26/15.
//  Copyright (c) 2015 Downtown Software House. All rights reserved.
//

import UIKit

class SlidingToggleButton: UIControl {
    
    // MARK: SlidingToggleButton
    
    var on: Bool = true {
        didSet {
            innerView?.backgroundColor = on ? UIColor.redColor() : UIColor.grayColor()
            sendActionsForControlEvents(UIControlEvents.ValueChanged)
        }
    }
    
    @IBInspectable var title: String = "" {
        didSet {
            titleLabel?.text = title
        }
    }
    
    func handlePan(gestureRecognizer: UIPanGestureRecognizer) {
        
        switch gestureRecognizer.state {
        case .Cancelled, .Ended:
            UIView.animateWithDuration( 0.5, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.0, options: UIViewAnimationOptions(0), animations: { () -> Void in
                    self.innerView!.frame = CGRect(origin: self.bounds.origin, size: self.innerView!.frame.size)
                }, completion: { (finished: Bool) -> Void in
                    gestureRecognizer.enabled = true
            })
        case .Changed:
            let translation = gestureRecognizer.translationInView(innerView!)
            let origin = CGPoint(x: translation.x, y: bounds.origin.y)
            
            if origin.x >= bounds.size.width {
                on = !on
                gestureRecognizer.enabled = false
            } else {
                innerView!.frame = CGRect(origin: origin, size: innerView!.frame.size)
            }
        default: ()
        }
    }
    
    // MARK: SlidingToggleButton Private
    
    private var innerView: UIView?
    private var titleLabel: UILabel?
    
    private func configure() {
        
        titleLabel = UILabel.new()
        titleLabel?.text = title
        titleLabel?.setTranslatesAutoresizingMaskIntoConstraints(false)
        titleLabel?.font = UIFont.systemFontOfSize(14.0)
        titleLabel?.textColor = UIColor.whiteColor()
        
        let pan = UIPanGestureRecognizer(target: self, action: Selector("handlePan:"))
        let frame = CGRect(origin: bounds.origin, size: CGSize(width: 100.0, height: bounds.height))
        
        innerView = UIView(frame: frame)
        innerView?.backgroundColor = UIColor.redColor()
        innerView?.addSubview(titleLabel!)
        innerView?.addGestureRecognizer(pan)

        let views: [String: UIView] = ["titleLabel": titleLabel!]
        
        innerView?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-5-[titleLabel]|", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
        innerView?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[titleLabel]|", options: NSLayoutFormatOptions(0), metrics: nil, views: views))

        addSubview(innerView!)
    }
    
    // MARK: UIView
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
}
