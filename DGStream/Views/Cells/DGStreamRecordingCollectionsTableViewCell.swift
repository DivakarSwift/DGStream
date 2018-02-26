//
//  DGStreamRecordingCollectionsTableViewCell.swift
//  DGStream
//
//  Created by Brandon on 2/21/18.
//  Copyright © 2018 Dataglance. All rights reserved.
//

import UIKit

class DGStreamRecordingCollectionsTableViewCell: UITableViewCell {

    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.durationLabel.textColor = UIColor.dgBlack()
        self.titleLabel.textColor = UIColor.dgBlack()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureWith(collection: DGStreamRecordingCollection) {
        if let documentNumber = collection.documentNumber {
            self.titleLabel.text = "Document Number: \(documentNumber)"
        }
        //self.durationLabel.text = "\(collection.numberOfRecordings ?? 0)"
        if let thumbnail = collection.thumbnail, let image = UIImage(data: thumbnail) {
            self.thumbnailImageView.image = image
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.titleLabel.text = ""
        self.durationLabel.text = ""
    }

}
