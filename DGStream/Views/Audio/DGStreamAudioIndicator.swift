//
//  DGStreamAudioIndicator.swift
//  DGStream
//
//  Created by Brandon on 11/13/17.
//  Copyright © 2017 Dataglance. All rights reserved.
//

import UIKit

class DGStreamAudioIndicator: UIView {
    
    @IBOutlet weak var indicator1: UIView!
    @IBOutlet weak var indicator1TopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var indicator2: UIView!
    @IBOutlet weak var indicator2TopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var indicator3: UIView!
    @IBOutlet weak var indicator3TopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var indicator4: UIView!
    @IBOutlet weak var indicator4TopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var indicator5: UIView!
    @IBOutlet weak var indicator5TopConstraint: NSLayoutConstraint!

    var indicatorContraints:[NSLayoutConstraint] = []
    var container:UIView!
    var isAnimating = false
    
    func animateWithin(container: UIView) {
        self.boundInside(container: container)
        self.container = container
        self.indicatorContraints = [indicator1TopConstraint, indicator2TopConstraint, indicator3TopConstraint, indicator4TopConstraint, indicator5TopConstraint]
        startAnimating()
    }
    
    func startAnimating() {
        isAnimating = true
        animate()
    }
    
    func stopAnimation() {
        isAnimating = false
    }
    
    func animate() {
        let max = self.frame.size.height
        
        for constraint in self.indicatorContraints {
            let rand = arc4random_uniform(UInt32(max))
            constraint.constant = CGFloat(rand)
        }
        
        UIView.animate(withDuration: 0.55, animations: {
            self.container.layoutIfNeeded()
        }) { (finished) in
            if self.isAnimating {
                self.animate()
            }
        }
    }

}
