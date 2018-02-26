//
//  DGStreamRecordingCollectionViewCell.swift
//  DGStream
//
//  Created by Brandon on 2/22/18.
//  Copyright © 2018 Dataglance. All rights reserved.
//

import UIKit

class DGStreamRecordingCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    func configureWith(recording: DGStreamRecording) {
        if let thumbnail = recording.thumbnail, let image = UIImage(data: thumbnail) {
            self.thumbnailImageView.image = image
        }
        else {
            self.thumbnailImageView.backgroundColor = .black
        }
        
        var title = ""
        if let date = recording.createdDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .short
            title = dateFormatter.string(from: date)
        }
        else if let recordingTitle = recording.title {
            title = recordingTitle
        }
        self.titleLabel.text = title
    }
    
    override func prepareForReuse() {
        self.thumbnailImageView.image = nil
        self.thumbnailImageView.backgroundColor = .clear
    }
}
