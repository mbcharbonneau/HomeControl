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
            let color = on ? tintColor : UIColor.lightGrayColor()
            titleLabel?.textColor = color
            actionLabel?.text = on ? offActionMessage : onActionMessage
            innerView?.layer.borderColor = color.CGColor
            leftView?.backgroundColor = color
            imageView?.tintColor = color
            sendActionsForControlEvents(UIControlEvents.ValueChanged)
        }
    }
    
    @IBInspectable var title: String = "" {
        didSet { titleLabel?.text = title }
    }
    
    @IBInspectable var onActionMessage: String = ""
    
    @IBInspectable var offActionMessage: String = "" {
        didSet { actionLabel?.text = offActionMessage }
    }
    
    @IBInspectable var image: UIImage? {
        get { return imageView?.image }
        set { imageView?.image = newValue?.imageWithRenderingMode(.AlwaysTemplate) }
    }
    
    func handlePan(gestureRecognizer: UIPanGestureRecognizer) {
        
        switch gestureRecognizer.state {
        case .Cancelled, .Ended:
            UIView.animateWithDuration( 0.5, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.0, options: UIViewAnimationOptions(), animations: { () -> Void in
                self.innerView?.frame = CGRect(origin: self.innerViewOrigin, size: self.innerView!.frame.size)
                self.actionLabel?.alpha = 0.0
                }, completion: { (finished: Bool) -> Void in
                    gestureRecognizer.enabled = true
            })
        case .Changed:
            let translation = gestureRecognizer.translationInView(innerView!)
            let origin = CGPoint(x: translation.x + innerViewOrigin.x, y: bounds.origin.y)
            
            if origin.x >= bounds.maxX - hiddenSpacing {
                on = !on
                gestureRecognizer.enabled = false
            } else if gestureRecognizer.velocityInView(innerView!).x > 0 {
                innerView?.frame = CGRect(origin: origin, size: innerView!.frame.size)
                self.actionLabel?.alpha = (hiddenSpacing + origin.x) / hiddenSpacing
            }
        default: ()
        }
    }
    
    // MARK: SlidingToggleButton Private
    
    private let hiddenSpacing: CGFloat = 90.0
    private let leftViewWidth: CGFloat = 3.0
    private let elementSpacing: CGFloat = 5.0
    private var innerViewOrigin: CGPoint {
        get { return CGPoint(x: bounds.minX - hiddenSpacing, y: bounds.minY) }
    }
    
    private var innerView: UIView?
    private var titleLabel: UILabel?
    private var actionLabel: UILabel?
    private var imageView: UIImageView?
    private var leftView: UIView?
    
    private func configure() {
        
        titleLabel = UILabel()
        titleLabel?.text = title
        titleLabel?.translatesAutoresizingMaskIntoConstraints = false
        titleLabel?.font = UIFont.systemFontOfSize(16.0)
        titleLabel?.textColor = tintColor
        titleLabel?.textAlignment = NSTextAlignment.Left
        
        imageView = UIImageView()
        imageView?.translatesAutoresizingMaskIntoConstraints = false
        imageView?.tintColor = tintColor
        
        leftView = UIView()
        leftView?.translatesAutoresizingMaskIntoConstraints = false
        leftView?.backgroundColor = tintColor
        leftView?.layer.cornerRadius = leftViewWidth / 2.0
        
        actionLabel = UILabel()
        actionLabel?.translatesAutoresizingMaskIntoConstraints = false
        actionLabel?.numberOfLines = 2
        actionLabel?.font = UIFont.systemFontOfSize(12.0)
        actionLabel?.textColor = UIColor.darkGrayColor()
        actionLabel?.alpha = 0.0
  
        let pan = UIPanGestureRecognizer(target: self, action: Selector("handlePan:"))
        let frame = CGRect(origin: innerViewOrigin, size: CGSize(width: 240.0, height: bounds.height))
        
        innerView = UIView(frame: frame)
        innerView?.addSubview(titleLabel!)
        innerView?.addSubview(imageView!)
        innerView?.addSubview(leftView!)
        innerView?.addSubview(actionLabel!)
        innerView?.addGestureRecognizer(pan)

        let metrics: [String: CGFloat] = ["leftViewWidth": leftViewWidth, "space": elementSpacing, "hidden": hiddenSpacing]
        let views: [String: UIView] = ["titleLabel": titleLabel!, "imageView": imageView!, "leftView": leftView!, "actionLabel": actionLabel!]
        
        imageView?.addConstraint(NSLayoutConstraint(item: imageView!, attribute: .Width, relatedBy: .Equal, toItem: imageView!, attribute: .Height, multiplier: 1.0, constant: 0.0))
        
        innerView?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[actionLabel(hidden)]-(space)-[leftView(leftViewWidth)]-(space)-[imageView]-(space)-[titleLabel]|", options: NSLayoutFormatOptions(), metrics: metrics, views: views))
        innerView?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[titleLabel]|", options: NSLayoutFormatOptions(), metrics: metrics, views: views))
        innerView?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-(2)-[imageView]-(2)-|", options: NSLayoutFormatOptions(), metrics: metrics, views: views))
        innerView?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[leftView]|", options: NSLayoutFormatOptions(), metrics: metrics, views: views))
        innerView?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[actionLabel]|", options: NSLayoutFormatOptions(), metrics: metrics, views: views))

        backgroundColor = UIColor.clearColor()
        addSubview(innerView!)
    }
    
    // MARK: UIView
    
    override func tintColorDidChange() {
        super.tintColorDidChange()
        titleLabel?.textColor = tintColor
        imageView?.tintColor = tintColor
        leftView?.backgroundColor = tintColor
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
}
