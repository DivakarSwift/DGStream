//
//  DGStreamContactTableViewCell.swift
//  DGStream
//
//  Created by Brandon on 10/20/17.
//  Copyright © 2017 Dataglance. All rights reserved.
//

import UIKit

protocol DGStreamTableViewCellDelegate {
    func streamCallButtonTappedWith(userID: NSNumber, type: QBRTCConferenceType)
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
        self.numberLabel.backgroundColor = UIColor.dgGreen()
        self.numberLabel.layer.cornerRadius = self.numberLabel.frame.size.width / 2
        self.numberLabel.textColor = UIColor.dgBackground()
        userImageView.layer.cornerRadius = userImageView.frame.size.width / 2
        userImageView.backgroundColor = UIColor.dgDarkGray()
        abrevLabel.textColor = UIColor.dgBackground()
        nameLabel.textColor = UIColor.dgDarkGray()
        self.setUpButtons()
    }

    func configureWith(contact: DGStreamContact, delegate: DGStreamTableViewCellDelegate) {
        self.delegate = delegate
        
        self.contact = contact
        
        self.numberLabel.alpha = 0
        
        if let user = contact.user {
            
            if let username = user.username, username.characters.count >= 1 {
                let abrev = NSString(string: username).substring(to: 1)
                self.abrevLabel.text = abrev
                self.nameLabel.text = username
            }
            
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
        if let userID = self.contact.userID {
            self.delegate.streamCallButtonTappedWith(userID: userID, type: .video)
        }
    }
    
    @IBAction func audioCallButtonTapped(_ sender: Any) {
        if let userID = self.contact.userID {
            self.delegate.streamCallButtonTappedWith(userID: userID, type: .audio)
        }
    }
    
}
