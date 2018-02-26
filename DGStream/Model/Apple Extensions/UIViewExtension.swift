//
//  UIViewExtension.swift
//  DGStream
//
//  Created by Brandon on 9/14/17.
//  Copyright © 2017 Dataglance. All rights reserved.
//

import Foundation

extension UIView {
    func boundInside(container: UIView) {
        if superview != container {
            container.addSubview(self)
        }
        self.translatesAutoresizingMaskIntoConstraints = false
        let top = NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1.0, constant: 0.0)
        let left = NSLayoutConstraint(item: self, attribute: .left, relatedBy: .equal, toItem: container, attribute: .left, multiplier: 1.0, constant: 0.0)
        let bottom = NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: container, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        let right = NSLayoutConstraint(item: self, attribute: .right, relatedBy: .equal, toItem: container, attribute: .right, multiplier: 1.0, constant: 0.0)
        container.addConstraints([top, left, bottom, right])
        container.layoutIfNeeded()
    }
    
    func boundInsideAndGetConstraints(container: UIView) -> (top: NSLayoutConstraint, left: NSLayoutConstraint, bottom: NSLayoutConstraint, right: NSLayoutConstraint) {
        var returnConstraints:(top: NSLayoutConstraint, left: NSLayoutConstraint, bottom: NSLayoutConstraint, right: NSLayoutConstraint)
        if superview != container {
            container.addSubview(self)
        }
        self.translatesAutoresizingMaskIntoConstraints = false
        let top = NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1.0, constant: 0.0)
        returnConstraints.top = top
        let left = NSLayoutConstraint(item: self, attribute: .left, relatedBy: .equal, toItem: container, attribute: .left, multiplier: 1.0, constant: 0.0)
        returnConstraints.left = left
        let bottom = NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: container, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        returnConstraints.bottom = bottom
        let right = NSLayoutConstraint(item: self, attribute: .right, relatedBy: .equal, toItem: container, attribute: .right, multiplier: 1.0, constant: 0.0)
        returnConstraints.right = right
        container.addConstraints([top, left, bottom, right])
        container.layoutIfNeeded()
        return returnConstraints
    }
    
    func boundInCenterOf(container: UIView) -> (width: NSLayoutConstraint, height: NSLayoutConstraint, centerX: NSLayoutConstraint, centerY: NSLayoutConstraint) {
        
        var returnConstraints:(width: NSLayoutConstraint, height: NSLayoutConstraint, centerX: NSLayoutConstraint, centerY: NSLayoutConstraint)
        
        var hw:CGFloat = 0
        if container.bounds.size.width < container.bounds.size.height {
            hw = container.bounds.size.width
        }
        else {
            hw = container.bounds.size.height
        }
        if superview != container {
            container.addSubview(self)
        }
        self.translatesAutoresizingMaskIntoConstraints = false
        let width = NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: hw)
        returnConstraints.width = width
        let height = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: hw)
        returnConstraints.height = height
        let centerX = NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: container, attribute: .centerX, multiplier: 1.0, constant: 0.0)
        returnConstraints.centerX = centerX
        let centerY = NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: container, attribute: .centerY, multiplier: 1.0, constant: 0.0)
        returnConstraints.centerY = centerY
        container.addConstraints([centerX, centerY])
        container.layoutIfNeeded()
        self.addConstraints([width, height])
        self.layoutIfNeeded()
        return returnConstraints
    }
}

extension UIView {
    
    func boundTabBarAtBottomOf(container: UIView) {
        container.addSubview(self)
        self.translatesAutoresizingMaskIntoConstraints = false
        let left = NSLayoutConstraint(item: self, attribute: .left, relatedBy: .equal, toItem: container, attribute: .left, multiplier: 1.0, constant: 0.0)
        let bottom = NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: container, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        let right = NSLayoutConstraint(item: self, attribute: .right, relatedBy: .equal, toItem: container, attribute: .right, multiplier: 1.0, constant: 0.0)
        container.addConstraints([left, bottom, right])
        container.layoutIfNeeded()
    }
    
    func boundInCenterOf(container: UIView, hw: CGFloat) {
        if superview != container {
            container.addSubview(self)
        }
        self.translatesAutoresizingMaskIntoConstraints = false
        let width = NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: hw)
        let height = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: hw)
        let centerX = NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: container, attribute: .centerX, multiplier: 1.0, constant: 0.0)
        let centerY = NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: container, attribute: .centerY, multiplier: 1.0, constant: 0.0)
        container.addConstraints([centerX, centerY])
        container.layoutIfNeeded()
        self.addConstraints([width, height])
        self.layoutIfNeeded()
    }
    
    //    func boundCanvasInCenterOf(container: UIView, squareHW: CGFloat) -> NSLayoutConstraint {
    //        container.addSubview(self)
    //        self.translatesAutoresizingMaskIntoConstraints = false
    //        let width = NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: squareHW)
    //        let height = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: squareHW)
    //        let centerX = NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: container, attribute: .centerX, multiplier: 1.0, constant: 0.0)
    //        let centerY = NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: container, attribute: .centerY, multiplier: 1.0, constant: 0.0)
    //        container.addConstraints([centerX, centerY])
    //        container.layoutIfNeeded()
    //        self.addConstraints([width, height])
    //
    //        return centerY
    //    }
    
}

extension UIView {
    // Call as: subview.boundInside(superView)
    func boundInside(_ superView: UIView){
        self.translatesAutoresizingMaskIntoConstraints = false
        superView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[subview]-0-|", options: NSLayoutFormatOptions.directionLeadingToTrailing, metrics:nil, views:["subview":self]))
        superView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[subview]-0-|", options: NSLayoutFormatOptions.directionLeadingToTrailing, metrics:nil, views:["subview":self]))
    }
}
