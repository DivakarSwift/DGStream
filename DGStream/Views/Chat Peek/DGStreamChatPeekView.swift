//
//  DGStreamChatPeekView.swift
//  DGStream
//
//  Created by Brandon on 11/17/17.
//  Copyright © 2017 Dataglance. All rights reserved.
//

import UIKit

let kCellHeight:CGFloat = 30
let kCellPadding:CGFloat = 4

class DGStreamChatPeekView: UIView {

    var cells:[DGStreamChatPeekCell] = []
    
    func configureWithin(container: UIView) {
        container.backgroundColor = .clear
        self.backgroundColor = .clear
        self.boundInside(container: container)
    }
    
    func addCellWith(message: DGStreamMessage) {
        if let cell = UINib(nibName: "DGStreamChatPeekCell", bundle: Bundle(identifier: "com.dataglance.DGStream")).instantiate(withOwner: self, options: nil).first as? DGStreamChatPeekCell {
            cell.alpha = 0
            cell.configureWith(message: message)
            add(cell: cell)
        }
    }
    
    func add(cell: DGStreamChatPeekCell) {
        
        // Give new cell it's initial frame
        cell.frame = CGRect(x: 0, y: self.bounds.size.height, width: self.bounds.size.width, height: kCellHeight)
        
        // Add it to cells
        cells.append(cell)
        
        // Add new cell to view
        addSubview(cell)
        
        self.layoutIfNeeded()
        
        // Animate up from bottom
        // Animate all cells accordingly
        UIView.animate(withDuration: 0.18, delay: 0.05, options: .curveEaseIn, animations: {
            
            cell.alpha = 1
            
            for cell in self.cells {
                cell.frame = CGRect(x: 0, y: cell.frame.origin.y - (kCellHeight + kCellPadding), width: cell.frame.size.width, height: cell.frame.size.height)
                cell.layoutIfNeeded()
            }
            
        }) { (f) in
            // Fade out after 3 seconds
            UIView.animate(withDuration: 0.25, delay: 6.0, options: .curveEaseOut, animations: {
                cell.alpha = 0
            }, completion: { (fi) in
                cell.removeFromSuperview()
            })
        }
    }

}
