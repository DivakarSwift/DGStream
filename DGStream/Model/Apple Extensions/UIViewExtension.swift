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
        container.addSubview(self)
        self.translatesAutoresizingMaskIntoConstraints = false
        let top = NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1.0, constant: 0.0)
        let left = NSLayoutConstraint(item: self, attribute: .left, relatedBy: .equal, toItem: container, attribute: .left, multiplier: 1.0, constant: 0.0)
        let bottom = NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: container, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        let right = NSLayoutConstraint(item: self, attribute: .right, relatedBy: .equal, toItem: container, attribute: .right, multiplier: 1.0, constant: 0.0)
        container.addConstraints([top, left, bottom, right])
        container.layoutIfNeeded()
    }
}
