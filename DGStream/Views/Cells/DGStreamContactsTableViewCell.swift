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
    func userButtonTapped(userID: NSNumber)
}

class DGStreamContactsTableViewCell: UITableViewCell {

    @IBOutlet weak var abrevLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var videoCallButton: UIButton!
    @IBOutlet weak var audioCallButton: UIButton!
    @IBOutlet weak var numberLabel: UILabel!
    
    var contact: DGStreamContact!
    
    var delegate: DGStreamTableViewCellDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        self.numberLabel.backgroundColor = UIColor.dgBlueDark()
        self.numberLabel.layer.cornerRadius = self.numberLabel.frame.size.width / 2
        self.numberLabel.textColor = .white
        userImageView.layer.cornerRadius = userImageView.frame.size.width / 2
        userImageView.backgroundColor = UIColor.dgBlack()
        abrevLabel.textColor = .white
        nameLabel.textColor = UIColor.dgBlack()
        self.userImageView.layer.borderColor = UIColor.dgGray().cgColor
        self.setUpButtons()
    }

    func configureWith(contact: DGStreamContact, delegate: DGStreamTableViewCellDelegate) {
        self.delegate = delegate
        
        self.contact = contact
        
        self.numberLabel.alpha = 0
        
        if let userID = contact.userID, let user = DGStreamCore.instance.getOtherUserWith(userID: userID) {
            
            if let username = user.username, username != "" {
                let abrev = NSString(string: username).substring(to: 1)
                self.abrevLabel.text = abrev
                self.nameLabel.text = username
            }
            
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
        if let userID = user.userID, let contactUserID = self.contact.userID, userID == contactUserID {
            if isOnline {
                self.setOnline()
            }
            else {
                self.setOffline()
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
    
    @IBAction func userButtonTapped(_ sender: Any) {
        self.delegate.userButtonTapped(userID: self.contact.userID ?? 0)
    }
    
    override func prepareForReuse() {
        self.userImageView.layer.borderColor = UIColor.dgGray().cgColor
    }
    
}
