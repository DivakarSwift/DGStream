//
//  DGStreamRecentsTableViewCell.swift
//  DGStream
//
//  Created by Brandon on 10/20/17.
//  Copyright © 2017 Dataglance. All rights reserved.
//

import UIKit

class DGStreamRecentsTableViewCell: UICollectionViewCell {
    
    @IBOutlet weak var accessoryButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var abrevLabel: UILabel!
    var gradient: CAGradientLayer?
    var delegate: DGStreamTableViewCellDelegate!
    var recent: DGStreamRecent!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.backgroundColor = .clear
        self.backgroundColor = .clear
        userImageView.backgroundColor = UIColor.dgBlack()
        abrevLabel.textColor = .white
        nameLabel.textColor = UIColor.dgBlack()
        dateLabel.textColor = .white
        self.userImageView.layer.cornerRadius = self.userImageView.frame.size.width / 2
        self.userImageView.layer.borderColor = UIColor.clear.cgColor
        self.userImageView.layer.borderWidth = 3
        
        //let accessoryImage = UIImage(named: "info", in: Bundle(identifier: "com.dataglance.DGStream"), compatibleWith: nil)
//        self.accessoryButton.setImage(accessoryImage?.withRenderingMode(.alwaysTemplate), for: .normal)
//        self.accessoryButton.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8)
//        self.accessoryButton.tintColor = UIColor.dgButtonColor()
//        self.accessoryButton.layer.borderColor = UIColor.dgButtonColor().cgColor
//        self.accessoryButton.layer.borderWidth = 0.5
//        self.accessoryButton.layer.cornerRadius = self.accessoryButton.frame.size.width / 2
        
        //self.setUpGradient()
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
            nameLabel.text = username
            let status = DGStreamCore.instance.onlineStatusFor(user: user)
            self.setOnline(status: status)
            if let imageData = user.image, let image = UIImage(data: imageData) {
                self.userImageView.image = image
            }
            else {
                let abrev = NSString(string: username).substring(to: 1)
                self.abrevLabel.text = abrev
            }
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

        if isIncoming {

        }

    }
    
    func setUpGradient() {
        if let gradient = self.gradient {
            gradient.removeFromSuperlayer()
        }
        let dark = UIColor(red: 0, green: 0, blue: 0, alpha: 0.10)
        self.gradient = self.addGradientBackground(firstColor: .clear, secondColor: dark, height: self.contentView.bounds.size.height)
    }
    
    func startSelection(animated: Bool) {
//        if animated {
//            UIView.animate(withDuration: 0.25) {
//                self.videoCallButton.alpha = 0
//                self.audioCallButton.alpha = 0
//            }
//        }
//        else {
//            self.videoCallButton.alpha = 0
//            self.audioCallButton.alpha = 0
//        }
    }
    
    func endSelection(animated: Bool) {
//        if animated {
//            UIView.animate(withDuration: 0.25) {
//                self.videoCallButton.alpha = 1
//                self.audioCallButton.alpha = 1
//                self.numberLabel.alpha = 0
//            }
//        }
//        else {
//            self.videoCallButton.alpha = 1
//            self.audioCallButton.alpha = 1
//            self.numberLabel.alpha = 0
//        }
    }
    
    func selectWith(count: Int, animate: Bool) {
//        self.videoCallButton.alpha = 0
//        self.audioCallButton.alpha = 0
//        self.numberLabel.text = "\(count)"
//        if animate {
//            UIView.animate(withDuration: 0.25) {
//                self.numberLabel.alpha = 1
//            }
//        }
//        else {
//            self.numberLabel.alpha = 1
//        }
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
                    self.setOnline(status: .online)
                }
                else {
                    self.setOffline()
                }
            }
        }
    }
    
    func setOnline(status: DGStreamOnlineStatus) {
        if status == .online {
            self.userImageView.layer.borderColor = UIColor.green.cgColor
        }
        else if status == .recent {
            self.userImageView.layer.borderColor = UIColor.yellow.cgColor
        }
        else if status == .away {
            self.userImageView.layer.borderColor = UIColor.orange.cgColor
        }
        else {
            self.userImageView.layer.borderColor = UIColor.clear.cgColor
        }
    }
    
    func setOffline() {
        self.userImageView.layer.borderColor = UIColor.clear.cgColor
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
    
    @IBAction func accessoryButtonTapped(_ sender: Any) {
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
        self.userImageView.image = nil
        self.nameLabel.text = ""
        dateLabel.text = ""
        self.userImageView.layer.borderColor = UIColor.clear.cgColor
    }
}
