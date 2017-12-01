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
        label.textColor = UIColor.dgGray()
        
        if let title = title {
            label.text = title
        }
        
    }
    
}
