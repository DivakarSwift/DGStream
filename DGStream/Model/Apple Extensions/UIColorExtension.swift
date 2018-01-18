//
//  UIColorExtension.swift
//  DGStream
//
//  Created by Brandon on 9/14/17.
//  Copyright © 2017 Dataglance. All rights reserved.
//

import Foundation

extension UIColor {
    
    // Call Modes
    class func dgStreamMode() -> UIColor {
        return UIColor.dgGreen()
    }
    
    class func dgShareScreenMode() -> UIColor {
        return UIColor.orange
    }
    
    class func dgMergeMode() -> UIColor {
        return UIColor.dgYellow()
    }
    
    class func dgDrawMode() -> UIColor {
        return UIColor.dgBlueMedium()
    }
    
    class func dgWhiteBoardMode() -> UIColor {
        return UIColor.dgWhite()
    }
    
    class func dgBlack() -> UIColor {
        return UIColor(red: (85/255.0), green: (85/255.0), blue: (85/255.0), alpha: 1)
    }
    class func dgBlueDark() -> UIColor {
        return UIColor(red: (39/255.0), green: (100/255.0), blue: (156/255.0), alpha: 1.0)
    }
    class func dgChatPeekCellBubble() -> UIColor {
        return UIColor(red: (39/255.0), green: (100/255.0), blue: (156/255.0), alpha: 0.75)
    }
    class func dgBlueMedium() -> UIColor {
        return UIColor(red: (61/255.0), green: (174/255.0), blue: (235/255.0), alpha: 1.0)
    }
    class func dgBlueLight() -> UIColor {
        return UIColor(red: (225/255.0), green: (246/255.0), blue: (255/255.0), alpha: 1.0)
    }
    class func dgBlue() -> UIColor {
        return dgBlueMedium()
    }
    class func dgRed() -> UIColor {
        return UIColor(red: (235/255.0), green: (174/255.0), blue: (61/255.0), alpha: 1.0)
    }
    class func dgGreen() -> UIColor {
        return UIColor(red: (155/255.0), green: (225/255.0), blue: (100/255.0), alpha: 1.0)
    }
    class func dgYellow() -> UIColor {
        return UIColor(red: (200/255.0), green: (209/255.0), blue: (61/255.0), alpha: 1.0)
    }
    class func dgBackground() -> UIColor {
//        return UIColor(red: (218/255.0), green: (226/255.0), blue: (234/255.0), alpha: 1)
        return UIColor.dgWhite()
    }
    class func dgBackgroundHalf() -> UIColor {
        return UIColor(red: (218/255.0), green: (226/255.0), blue: (234/255.0), alpha: 0.5)
    }
}

extension UIColor {
    class func dgWhite() -> UIColor {
//        return UIColor(red: (230/255.0), green: (220/255.0), blue: (215/255.0), alpha: 1)
        return .white
    }
    class func dgDarkGray() -> UIColor {
//        return UIColor(red: (48/255.0), green: (57/255.0), blue: (64/255.0), alpha: 1)
        return UIColor.dgBlueDark()
    }
    class func dgGray() -> UIColor {
        return UIColor(red: (95/255.0), green: (114/255.0), blue: (127/255.0), alpha: 1)
    }
}
