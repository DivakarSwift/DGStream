//
//  UIScreenExtension.swift
//  DGStream
//
//  Created by Brandon on 9/15/17.
//  Copyright © 2017 Dataglance. All rights reserved.
//

import Foundation

extension UIScreen {
    func fullScreenSquare() -> CGRect {
        var hw:CGFloat = 0
        var isLandscape = false
        if UIScreen.main.bounds.size.width < UIScreen.main.bounds.size.height {
            hw = UIScreen.main.bounds.size.width
        }
        else {
            isLandscape = true
            hw = UIScreen.main.bounds.size.height
        }
        
        var x:CGFloat = 0
        var y:CGFloat = 0
        if isLandscape {
            x = (UIScreen.main.bounds.size.width / 2) - (hw / 2)
        }
        else {
            y = (UIScreen.main.bounds.size.height / 2) - (hw / 2)
        }
        return CGRect(x: x, y: y, width: hw, height: hw)
    }
    func isLandscape() -> Bool {
        return UIScreen.main.bounds.size.width > UIScreen.main.bounds.size.height
    }
}
