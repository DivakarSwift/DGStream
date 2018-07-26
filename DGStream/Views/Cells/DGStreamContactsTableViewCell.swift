//
//  DGStreamContactTableViewCell.swift
//  DGStream
//
//  Created by Brandon on 10/20/17.
//  Copyright © 2017 Dataglance. All rights reserved.
//

import UIKit

protocol DGStreamTableViewCellDelegate {
    func streamCallButtonTappedWith(userID: NSNumber, type: QBRTCConferenceType, cellIndex: Int, buttonFrame: CGRect)
    func messageButtonTappedWith(userID:NSNumber)
    func userButtonTapped(userID: NSNumber)
}

class DGStreamContactsTableViewCell: UITableViewCell {

    @IBOutlet weak var accessoryButton: UIButton!
    @IBOutlet weak var abrevLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    var gradient: CAGradientLayer?
    var contact: DGStreamContact!
    var delegate: DGStreamTableViewCellDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        userImageView.backgroundColor = UIColor.dgBlack()
        abrevLabel.textColor = .white
        nameLabel.textColor = UIColor.dgBlack()
        self.nameLabel.shadowColor = .white
        self.userImageView.layer.cornerRadius = self.userImageView.frame.size.width / 2
        self.userImageView.layer.borderColor = UIColor.clear.cgColor
        self.userImageView.layer.borderWidth = 3
        
        let accessoryImage = UIImage(named: "info", in: Bundle(identifier: "com.dataglance.DGStream"), compatibleWith: nil)
        self.accessoryButton.setImage(accessoryImage?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.accessoryButton.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8)
        self.accessoryButton.tintColor = UIColor.dgButtonColor()
        self.accessoryButton.layer.borderColor = UIColor.dgButtonColor().cgColor
        self.accessoryButton.layer.borderWidth = 0.5
        self.accessoryButton.layer.cornerRadius = self.accessoryButton.frame.size.width / 2
        
        self.setUpGradient()
    }

    func configureWith(contact: DGStreamContact, delegate: DGStreamTableViewCellDelegate) {
        self.delegate = delegate
        
        self.contact = contact
        
        if let userID = contact.userID, let user = DGStreamCore.instance.getOtherUserWith(userID: userID) {
            
            if let username = user.username, username != "" {
                self.nameLabel.text = username
            }
            
            self.setOnline(status: DGStreamCore.instance.onlineStatusFor(user: user))
            
            if let imageData = user.image, let image = UIImage(data: imageData) {
                self.userImageView.image = image
            }
            else if let username = user.username {
                let abrev = NSString(string: username).substring(to: 1)
                self.abrevLabel.text = abrev
            }
            
        }
        
    }
    
    func setUpGradient() {
        if let gradient = self.gradient {
            gradient.removeFromSuperlayer()
        }
        let dark = UIColor(red: 0, green: 0, blue: 0, alpha: 0.10)
        self.gradient = self.addGradientBackground(firstColor: .clear, secondColor: dark, height: self.contentView.bounds.size.height + 20)
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
        if let userID = user.userID, let contactUserID = self.contact.userID, userID == contactUserID {
            if isOnline {
                self.setOnline(status: .online)
            }
            else {
                self.setOffline()
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
        
        let button = sender as? UIButton
        let buttonFrame = button?.frame ?? .zero
        
        if let userID = self.contact.userID {
            self.delegate.streamCallButtonTappedWith(userID: userID, type: .video, cellIndex: self.tag, buttonFrame: buttonFrame)
        }
    }
    
    @IBAction func audioCallButtonTapped(_ sender: Any) {
        
        let button = sender as? UIButton
        let buttonFrame = button?.frame ?? .zero
        
        if let userID = self.contact.userID {
            self.delegate.streamCallButtonTappedWith(userID: userID, type: .audio, cellIndex: self.tag, buttonFrame: buttonFrame)
        }
    }
    
    @IBAction func messageButtonTapped(_ sender: Any) {
        self.delegate.messageButtonTappedWith(userID: self.contact.userID ?? 0)
    }
    
    @IBAction func userButtonTapped(_ sender: Any) {
        self.delegate.userButtonTapped(userID: self.contact.userID ?? 0)
    }
    
    @IBAction func accessoryButtonTapped(_ sender: Any) {
        self.delegate.userButtonTapped(userID: self.contact.userID ?? 0)
    }
    
    override func prepareForReuse() {
        self.userImageView.image = nil
        self.nameLabel.text = ""
        self.abrevLabel.text = ""
        self.userImageView.layer.borderColor = UIColor.clear.cgColor
    }
    
}
