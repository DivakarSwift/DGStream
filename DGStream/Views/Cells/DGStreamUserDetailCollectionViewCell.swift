//
//  DGStreamUserDetailCollectionViewCell.swift
//  DGStream
//
//  Created by Brandon on 8/14/18.
//  Copyright © 2018 Dataglance. All rights reserved.
//

import UIKit

class DGStreamUserDetailCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var valueLabel: UILabel!
    
    func configureWith(detail: DGStreamUserDetail) {
        
        self.titleLabel.text = detail.title
        self.valueLabel.text = detail.value
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.titleLabel.text = ""
        self.valueLabel.text = ""
    }
    
}
