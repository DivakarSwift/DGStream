//
//  UIImageViewExtension.swift
//  DGStream
//
//  Created by Brandon on 12/3/17.
//  Copyright © 2017 Dataglance. All rights reserved.
//

import Foundation

extension UIImageView {
    func mergeImagesWith(newImage: UIImage) {
        let bottomImage = self.image
        let topImage = newImage
        
        let size = self.bounds.size
        UIGraphicsBeginImageContext(size)
        
        let areaSize = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        bottomImage!.draw(in: areaSize)
        
        topImage.draw(in: areaSize, blendMode: .normal, alpha: 0.8)
        
        let image:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        self.image = image
    }
}
