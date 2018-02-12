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
    @IBOutlet weak var messageButton: UIButton!
    @IBOutlet weak var numberLabel: UILabel!
    
    var delegate: DGStreamTableViewCellDelegate!
    
    var recent: DGStreamRecent!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.backgroundColor = .clear
        self.backgroundColor = .clear
        self.numberLabel.backgroundColor = UIColor.dgBlueDark()
        self.numberLabel.layer.cornerRadius = self.numberLabel.frame.size.width / 2
        self.numberLabel.textColor = .white
        userImageView.layer.cornerRadius = userImageView.frame.size.width / 2
        userImageView.backgroundColor = UIColor.dgBlack()
        abrevLabel.textColor = .white
        nameLabel.textColor = UIColor.dgBlack()
        dateLabel.textColor = UIColor.dgBlack()
        durationLabel.textColor = UIColor.dgBlack()
        self.userImageView.layer.borderColor = UIColor.dgGray().cgColor
        self.setUpButtons()
    }
    
//    func configureWith(contact: DGStreamContact, delegate: DGStreamTableViewCellDelegate) {
//        self.delegate = delegate
//        
//        self.numberLabel.alpha = 0
//        
//        if let user = contact.user, let username = user.username {
//            let abrev = NSString(string: username).substring(to: 1)
//            self.abrevLabel.text = abrev
//            self.nameLabel.text = username
//        }
//        
//        if let date = contact.lastContact {
//            let dateFormatter = DateFormatter()
//            dateFormatter.timeStyle = .short
//            dateFormatter.dateStyle = .short
//            self.dateLabel.text = dateFormatter.string(from: date)
//        }
//        
//    }

    func configureWith(recent: DGStreamRecent, delegate: DGStreamTableViewCellDelegate) {

        self.delegate = delegate

        self.recent = recent

        self.numberLabel.alpha = 0

        var isIncoming: Bool = false
        var otherUser: DGStreamUser?
        if let currentUser = DGStreamCore.instance.currentUser, let currentUserID = currentUser.userID, let receiverID = recent.receiverID {
            if receiverID == currentUserID {
                isIncoming = true
                if let senderID = recent.senderID, let user = DGStreamCore.instance.getOtherUserWith(userID: senderID) {
                    otherUser = user
                }
            }
            else {
                if let receiverID = recent.receiverID, let user = DGStreamCore.instance.getOtherUserWith(userID: receiverID) {
                    otherUser = user
                }
            }
        }

        if let user = otherUser, let username = user.username {
            let abrev = NSString(string: username).substring(to: 1)
            self.abrevLabel.text = abrev
            nameLabel.text = username
            var ringColor:UIColor
            if user.isOnline {
                ringColor = UIColor.dgGreen()
            }
            else {
                ringColor = UIColor.dgGray()
            }
            self.userImageView.layer.borderColor = ringColor.cgColor
            self.userImageView.layer.borderWidth = 2.5
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
        else {
            nameLabel.textColor = UIColor.dgBlack()
            dateLabel.textColor = UIColor.dgBlack()
        }

        if let duration = recent.duration {
            self.durationLabel.text = "\(duration)m"
        }
        else {
            self.durationLabel.text = ""
        }

        if isIncoming {

        }

    }
    
    func setUpButtons() {
        self.videoCallButton.setImage(UIImage.init(named: "video", in: Bundle.init(identifier: "com.dataglance.DGStream"), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.videoCallButton.backgroundColor = UIColor.dgBlueDark()
        self.videoCallButton.tintColor = UIColor.dgBackground()
        self.videoCallButton.layer.cornerRadius = self.videoCallButton.frame.size.width / 2
        
        self.audioCallButton.setImage(UIImage.init(named: "audio", in: Bundle.init(identifier: "com.dataglance.DGStream"), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.audioCallButton.backgroundColor = UIColor.dgBlueDark()
        self.audioCallButton.tintColor = UIColor.dgBackground()
        self.audioCallButton.layer.cornerRadius = self.audioCallButton.frame.size.width / 2
        
        self.messageButton.setImage(UIImage.init(named: "message", in: Bundle.init(identifier: "com.dataglance.DGStream"), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.messageButton.backgroundColor = UIColor.dgBlueDark()
        self.messageButton.tintColor = UIColor.dgBackground()
        self.messageButton.layer.cornerRadius = self.messageButton.frame.size.width / 2
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
    
    func update(user: DGStreamUser, forOnline isOnline: Bool) {
        if let currentUser = DGStreamCore.instance.currentUser,
            let currentUserID = currentUser.userID {
            var otherUserID: NSNumber = 0
            if let senderID = self.recent.senderID, senderID != currentUserID {
                otherUserID = senderID
            }
            else if let receiverID = self.recent.senderID {
                otherUserID = receiverID
            }
            if let userID = user.userID, userID == otherUserID {
                if isOnline {
                    self.setOnline()
                }
                else {
                    self.setOffline()
                }
            }
        }
    }
    
    func setOnline() {
        self.userImageView.layer.borderColor = UIColor.dgGreen().cgColor
        self.userImageView.layer.borderWidth = 2.5
    }
    
    func setOffline() {
        self.userImageView.layer.borderColor = UIColor.dgGray().cgColor
        self.userImageView.layer.borderWidth = 2.5
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
                
                let button = sender as? UIButton
                let buttonFrame = button?.frame ?? .zero
                
                self.delegate.streamCallButtonTappedWith(userID: userID, type: .video, cellIndex: self.tag, buttonFrame: buttonFrame)
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
            
            let button = sender as? UIButton
            let buttonFrame = button?.frame ?? .zero
            
            self.delegate.streamCallButtonTappedWith(userID: userID ?? NSNumber.init(value: 0), type: .audio, cellIndex: self.tag, buttonFrame: buttonFrame)
        }
    }
    
    @IBAction func messageButtonTapped(_ sender: Any) {
        if let currentUser = DGStreamCore.instance.currentUser, let currentUserID = currentUser.userID, let receiverID = self.recent.receiverID, let senderID = self.recent.senderID {
            
            var userID: NSNumber?
            if receiverID != currentUserID {
                userID = receiverID
            }
            else {
                userID = senderID
            }
            
            self.delegate.messageButtonTappedWith(userID: userID ?? 0)
        }
    }
    
    @IBAction func userButtonTapped(_ sender: Any) {
        
        var userID: NSNumber = 0.0
        if self.recent.senderID == DGStreamCore.instance.currentUser?.userID ?? 0 {
            userID = self.recent.receiverID!
        }
        else {
            userID = self.recent.senderID!
        }
        
        self.delegate.userButtonTapped(userID: userID)
    }
    
    override func prepareForReuse() {
        nameLabel.textColor = UIColor.dgDarkGray()
        dateLabel.textColor = UIColor.dgDarkGray()
        durationLabel.textColor = UIColor.dgDarkGray()
        self.userImageView.layer.borderColor = UIColor.dgGray().cgColor
    }
}
