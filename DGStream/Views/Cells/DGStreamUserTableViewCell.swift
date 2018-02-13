//
//  DGStreamUserTableViewCell.swift
//  DGStream
//
//  Created by Brandon on 9/13/17.
//  Copyright © 2017 Dataglance. All rights reserved.
//

import UIKit

class DGStreamUserTableViewCell: UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var durationLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.title.text = ""
        self.dateLabel.text = ""
        self.durationLabel.text = ""
        self.title.textColor = UIColor.dgBlack()
        self.dateLabel.textColor = UIColor.dgBlack()
        self.durationLabel.textColor = UIColor.dgBlack()
    }
    
    func configureWith(recent: DGStreamRecent) {
        
        if let missed = recent.isMissed, missed == true {
            self.title.textColor = .red
            self.dateLabel.textColor = .red
            self.durationLabel.textColor = .red
        }
        
        var isIncoming:Bool = false
        
        if let currentUser = DGStreamCore.instance.currentUser, let currentUserID = currentUser.userID, let receiverID = recent.receiverID {
            if receiverID == currentUserID {
                isIncoming = true
            }
        }
        
        var audio = false
        if let isAudio = recent.isAudio {
            audio = isAudio
        }
        
        if audio {
            if isIncoming {
                self.title.text = NSLocalizedString("Incoming audio call...", bundle: Bundle(identifier: "DGStream")!, comment: "")
            }
            else {
                self.title.text = NSLocalizedString("Outgoing audio call...", bundle: Bundle(identifier: "DGStream")!, comment: "")
            }
        }
        else {
            if isIncoming {
                self.title.text = NSLocalizedString("Incoming video call...", bundle: Bundle(identifier: "DGStream")!, comment: "")
            }
            else {
                self.title.text = NSLocalizedString("Outgoing video call...", bundle: Bundle(identifier: "DGStream")!, comment: "")
            }
        }
        
        if let recentDate = recent.date {
            let dateFormatter = DateFormatter()
            dateFormatter.timeStyle = .short
            dateFormatter.dateStyle = .short
            self.dateLabel.text = dateFormatter.string(from: recentDate)
        }
        
        if let duration = recent.duration {
            self.durationLabel.text = "\(duration)m"
        }
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        self.title.text = ""
        self.dateLabel.text = ""
        self.durationLabel.text = ""
        self.title.textColor = UIColor.dgBlack()
        self.dateLabel.textColor = UIColor.dgBlack()
        self.durationLabel.textColor = UIColor.dgBlack()
    }

}
