//
//  DGStreamDocumentCollectionViewCell.swift
//  DGStream
//
//  Created by Brandon on 7/5/18.
//  Copyright © 2018 Dataglance. All rights reserved.
//

import UIKit

class DGStreamDocumentCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var cellImageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    func configureWith(document: DGStreamDocument) {
        if let thumbnail = document.thumbnail, let image = UIImage(data: thumbnail) {
            self.cellImageView.image = image
        }
        if let title = document.title {
            self.label.text = title
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.cellImageView.image = nil
        self.label.text = nil
    }
}
