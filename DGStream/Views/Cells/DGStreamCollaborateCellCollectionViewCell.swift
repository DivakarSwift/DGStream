//
//  DGStreamCollaborateCellCollectionViewCell.swift
//  DGStream
//
//  Created by Brandon on 8/13/18.
//  Copyright © 2018 Dataglance. All rights reserved.
//

import UIKit

enum CollaborateOption {
    case videoCall
    case audioCall
    case message
}

class DGStreamCollaborateCellCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var cellImageView: UIImageView!
    
    @IBOutlet weak var cellLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        cellImageView.backgroundColor = .clear
        cellLabel.text = ""
    }
    
    func configureWith(option: CollaborateOption) {
        
        if option == .videoCall {
            cellLabel.text = NSLocalizedString("Video Call", comment: "")
            cellImageView.backgroundColor = .clear
        }
        else if option == .audioCall {
            cellLabel.text = NSLocalizedString("Audio Call", comment: "")
        }
        else if option == .message {
            cellLabel.text = NSLocalizedString("Message", comment: "")
        }
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cellLabel.text = ""
    }

}
