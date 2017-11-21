//
//  DGStreamRecentsTableViewCell.swift
//  DGStream
//
//  Created by Brandon on 10/20/17.
//  Copyright © 2017 Dataglance. All rights reserved.
//

import UIKit

class DGStreamRecentsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var abrevLabel: UILabel!
    
    @IBOutlet weak var audioCallButton: UIButton!
    @IBOutlet weak var videoCallButton: UIButton!
    @IBOutlet weak var numberLabel: UILabel!
    
    var delegate: DGStreamTableViewCellDelegate!
    
    var recent: DGStreamRecent!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.backgroundColor = .clear
        self.backgroundColor = .clear
        self.numberLabel.backgroundColor = UIColor.dgGreen()
        self.numberLabel.layer.cornerRadius = self.numberLabel.frame.size.width / 2
        self.numberLabel.textColor = UIColor.dgBackground()
        userImageView.layer.cornerRadius = userImageView.frame.size.width / 2
        userImageView.backgroundColor = UIColor.dgDarkGray()
        abrevLabel.textColor = UIColor.dgBackground()
        nameLabel.textColor = UIColor.dgDarkGray()
        dateLabel.textColor = UIColor.dgDarkGray()
        durationLabel.textColor = UIColor.dgDarkGray()
        self.setUpButtons()
    }

    func configureWith(recent: DGStreamRecent, delegate: DGStreamTableViewCellDelegate) {
        
        self.delegate = delegate
        
        self.recent = recent
        
        self.numberLabel.alpha = 0
        
        var isIncoming: Bool = false
        var otherUser: DGStreamUser?
        if let currentUser = DGStreamCore.instance.currentUser, let currentUserID = currentUser.userID, let receiverID = recent.receiverID {
            if receiverID == currentUserID {
                isIncoming = true
                if let sender = recent.sender {
                    otherUser = sender
                }
                else if let senderID = recent.senderID, let user = DGStreamCore.instance.getOtherUserWith(userID: senderID) {
                    otherUser = user
                }
                
            }
            else {
                if let receiver = recent.receiver {
                    otherUser = receiver
                }
                else if let receiverID = recent.receiverID, let user = DGStreamCore.instance.getOtherUserWith(userID: receiverID) {
                    otherUser = user
                }
            }
        }
        
        if let user = otherUser, let username = user.username {
            let abrev = NSString(string: username).substring(to: 1)
            self.abrevLabel.text = abrev
            nameLabel.text = username
        }
        if let date = recent.date {
            let dateFormatter = DateFormatter()
            dateFormatter.timeStyle = .short
            dateFormatter.dateStyle = .short
            dateLabel.text = dateFormatter.string(from: date)
        }
        
        if let isMissed = recent.isMissed, isMissed == true {
            nameLabel.textColor = .red
            dateLabel.textColor = .red
        }
        
        if isIncoming {
            
        }
    
    }
    
    func setUpButtons() {
        self.videoCallButton.setImage(UIImage.init(named: "video", in: Bundle.init(identifier: "com.dataglance.DGStream"), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.videoCallButton.backgroundColor = UIColor.dgGreen()
        self.videoCallButton.tintColor = UIColor.dgBackground()
        self.videoCallButton.layer.cornerRadius = self.videoCallButton.frame.size.width / 2
        
        self.audioCallButton.setImage(UIImage.init(named: "audio", in: Bundle.init(identifier: "com.dataglance.DGStream"), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.audioCallButton.backgroundColor = UIColor.dgGreen()
        self.audioCallButton.tintColor = UIColor.dgBackground()
        self.audioCallButton.layer.cornerRadius = self.audioCallButton.frame.size.width / 2
    }
    
    func startSelection(animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.25) {
                self.videoCallButton.alpha = 0
                self.audioCallButton.alpha = 0
            }
        }
        else {
            self.videoCallButton.alpha = 0
            self.audioCallButton.alpha = 0
        }
    }
    
    func endSelection(animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.25) {
                self.videoCallButton.alpha = 1
                self.audioCallButton.alpha = 1
                self.numberLabel.alpha = 0
            }
        }
        else {
            self.videoCallButton.alpha = 1
            self.audioCallButton.alpha = 1
            self.numberLabel.alpha = 0
        }
    }
    
    func selectWith(count: Int, animate: Bool) {
        self.videoCallButton.alpha = 0
        self.audioCallButton.alpha = 0
        self.numberLabel.text = "\(count)"
        if animate {
            UIView.animate(withDuration: 0.25) {
                self.numberLabel.alpha = 1
            }
        }
        else {
            self.numberLabel.alpha = 1
        }
    }

    @IBAction func videoCallButtonTapped(_ sender: Any) {
        if let currentUser = DGStreamCore.instance.currentUser, let currentUserID = currentUser.userID, let receiverID = self.recent.receiverID, let senderID = self.recent.senderID {
            var userID: NSNumber?
            if receiverID != currentUserID {
                userID = receiverID
            }
            else {
                userID = senderID
            }
            if let userID = userID {
                self.delegate.streamCallButtonTappedWith(userID: userID, type: .video)
            }
        }
    }
    
    @IBAction func audioCallButtonTapped(_ sender: Any) {
        if let currentUser = DGStreamCore.instance.currentUser, let currentUserID = currentUser.userID, let receiverID = self.recent.receiverID, let senderID = self.recent.senderID {
            var userID: NSNumber?
            if receiverID != currentUserID {
                userID = receiverID
            }
            else {
                userID = senderID
            }
            if let userID = userID {
                self.delegate.streamCallButtonTappedWith(userID: userID, type: .audio)
            }
        }
    }
    
    override func prepareForReuse() {
        nameLabel.textColor = UIColor.dgDarkGray()
        dateLabel.textColor = UIColor.dgDarkGray()
        durationLabel.textColor = UIColor.dgDarkGray()
    }
}
