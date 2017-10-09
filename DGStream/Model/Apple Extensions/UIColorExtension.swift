//
//  UIColorExtension.swift
//  DGStream
//
//  Created by Brandon on 9/14/17.
//  Copyright © 2017 Dataglance. All rights reserved.
//

import Foundation

extension UIColor {
    class func dgBlack() -> UIColor {
        return UIColor(red: (85/255.0), green: (85/255.0), blue: (85/255.0), alpha: 1)
    }
    class func dgBlueDark() -> UIColor {
        return UIColor(red: (39/255.0), green: (100/255.0), blue: (156/255.0), alpha: 1.0)
    }
    class func dgBlueMedium() -> UIColor {
        return UIColor(red: (61/255.0), green: (174/255.0), blue: (235/255.0), alpha: 1.0)
    }
    class func dgBlueLight() -> UIColor {
        return UIColor(red: (225/255.0), green: (246/255.0), blue: (255/255.0), alpha: 1.0)
    }
    class func dgCellImageBlue() -> UIColor {
        return dgBlueMedium()
    }
    class func dgCellImageRed() -> UIColor {
        return UIColor(red: (235/255.0), green: (174/255.0), blue: (61/255.0), alpha: 1.0)
    }
    class func dgCellImageGreen() -> UIColor {
        return UIColor(red: (155/255.0), green: (254/255.0), blue: (101/255.0), alpha: 1.0)
    }
    class func dgCellImageYellow() -> UIColor {
        return UIColor(red: (200/255.0), green: (209/255.0), blue: (61/255.0), alpha: 1.0)
    }
    class func dgBackground() -> UIColor {
        return UIColor(red: (218/255.0), green: (226/255.0), blue: (234/255.0), alpha: 1)
    }
    class func dgBackgroundHalf() -> UIColor {
        return UIColor(red: (218/255.0), green: (226/255.0), blue: (234/255.0), alpha: 0.5)
    }
}
