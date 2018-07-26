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
    
    var gradient: CAGradientLayer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        self.title.text = ""
        self.dateLabel.text = ""
        self.durationLabel.text = ""
        self.title.textColor = .white
        self.dateLabel.textColor = .white
        self.durationLabel.textColor = .white
        
        self.setUpGradient()
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
                self.title.text = NSLocalizedString("Incoming audio call...", comment: "")
            }
            else {
                self.title.text = NSLocalizedString("Outgoing audio call...", comment: "")
            }
        }
        else {
            if isIncoming {
                self.title.text = NSLocalizedString("Incoming video call...", comment: "")
            }
            else {
                self.title.text = NSLocalizedString("Outgoing video call...", comment: "")
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
    
    func setUpGradient() {
        if let gradient = self.gradient {
            gradient.removeFromSuperlayer()
        }
        let dark = UIColor(red: 0, green: 0, blue: 0, alpha: 0.10)
        self.gradient = self.addGradientBackground(firstColor: .clear, secondColor: dark, height: self.contentView.bounds.size.height)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        self.title.text = ""
        self.dateLabel.text = ""
        self.durationLabel.text = ""
        self.title.textColor = .white
        self.dateLabel.textColor = .white
        self.durationLabel.textColor = .white
    }

}
