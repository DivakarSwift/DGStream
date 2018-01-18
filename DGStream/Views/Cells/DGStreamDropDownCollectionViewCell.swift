//
//  DGStreamDropDownCollectionViewCell.swift
//  DGStream
//
//  Created by Brandon on 11/29/17.
//  Copyright © 2017 Dataglance. All rights reserved.
//

import UIKit

class DGStreamDropDownCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var label: UILabel!
    
    func configureWith(title: String?, color: UIColor) {
        
        label.clipsToBounds = true
        label.layer.cornerRadius = label.frame.size.width / 2
        
        label.backgroundColor = color
        label.textColor = UIColor.dgBlack()
        
        var font:UIFont
        if let title = title, let _ = UInt(title) {
            print("Title is number!")
            font = UIFont.systemFont(ofSize: 36)
        }
        else {
            print("Title is not a number!")
            font = UIFont.systemFont(ofSize: 42)
        }
        
        if let title = title {
            label.text = title
            label.font = font
        }
        
    }
    
}
