//
//  DGStreamUserHeader.swift
//  DGStream
//
//  Created by Brandon on 12/19/17.
//  Copyright © 2017 Dataglance. All rights reserved.
//

import UIKit

protocol DGStreamUserHeaderDelegate {
    func userImageButtonTapped()
    func didTapVideoCall()
    func didTapAudioCall()
    func didTapMessage()
}

class DGStreamUserHeader: UIView {

    var userImageButton: UIButton!
    
    @IBOutlet weak var userImageButtonContainer: UIView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var tagLabel: UILabel!
    
    @IBOutlet weak var lastSeenLabel: UILabel!
    
    @IBOutlet weak var videoCallButton: UIButton!
    @IBOutlet weak var audioCallButton: UIButton!
    @IBOutlet weak var messageButton: UIButton!
    
    var delegate: DGStreamUserHeaderDelegate!
    
    func configureWith(user: DGStreamUser) {
        
        userImageButtonContainer.backgroundColor = .clear
        
        self.nameLabel.textColor = UIColor.dgBlack()
        self.tagLabel.textColor = .lightGray
        self.lastSeenLabel.textColor = .lightGray
        
        self.videoCallButton.setImage(UIImage.init(named: "video", in: Bundle.init(identifier: "com.dataglance.DGStream"), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.videoCallButton.tintColor = UIColor.dgBackground()
        self.videoCallButton.backgroundColor = UIColor.dgBlueDark()
        self.videoCallButton.layer.cornerRadius = self.videoCallButton.frame.size.width / 2
        
        self.audioCallButton.setImage(UIImage.init(named: "audio", in: Bundle.init(identifier: "com.dataglance.DGStream"), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.audioCallButton.tintColor = UIColor.dgBackground()
        self.audioCallButton.backgroundColor = UIColor.dgBlueDark()
        self.audioCallButton.layer.cornerRadius = self.audioCallButton.frame.size.width / 2
        
        self.messageButton.setImage(UIImage.init(named: "message", in: Bundle.init(identifier: "com.dataglance.DGStream"), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.messageButton.tintColor = UIColor.dgBackground()
        self.messageButton.backgroundColor = UIColor.dgBlueDark()
        self.messageButton.layer.cornerRadius = self.messageButton.frame.size.width / 2
        
        _ = self.addGradientBackground(firstColor: .white, secondColor: .lightGray, height: self.frame.size.height * 3)
        
        if let currentUser = DGStreamCore.instance.currentUser,
            let currentUserID = currentUser.userID,
            let userID = user.userID {
            
            self.userImageButton = UIButton(type: .custom)
            self.userImageButton.layer.borderWidth = 0.5
            self.userImageButton.layer.borderColor = UIColor.dgBlack().cgColor
            self.userImageButton.clipsToBounds = true
            self.userImageButton.backgroundColor = UIColor.dgBlack()
            if userID == currentUserID {
                self.userImageButton.addTarget(self, action: #selector(self.userImageTapped(_:)), for: .touchUpInside)
            }
            
            if let imageData = user.image,
                let image = UIImage(data: imageData) {
                
                self.userImageButton.boundInside(container: self.userImageButtonContainer)
                self.userImageButton.setImage(image, for: .normal)
                self.userImageButton.contentMode = .scaleAspectFill
                
            }
            
            if let username = user.username {
                self.nameLabel.text = username
                
                if self.userImageButton.currentImage == nil {
                    let abrev = NSString(string: username).substring(to: 1)
                    self.userImageButton.boundInside(container: self.userImageButtonContainer)
                    self.userImageButton.setTitle(abrev, for: .normal)
                    
                    self.userImageButton.titleLabel?.font = UIFont(name: "HelveticaNueue-Bold", size: 70)
                }
                
            }
            
            self.tagLabel.text = "Master Technician"
            
            if let lastSeen = user.lastSeen {
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .short
                dateFormatter.timeStyle = .short
                
                let lastSeenText = dateFormatter.string(from: lastSeen)
                
                self.lastSeenLabel.text = lastSeenText
            }
            else {
                self.lastSeenLabel.text = "\(NSLocalizedString("Last seen", comment: "Last seen (last_seen_date)")): ?"
            }
            
            if userID == currentUserID {
                self.videoCallButton.alpha = 0
                self.audioCallButton.alpha = 0
                self.messageButton.alpha = 0
            }
            else {
                
            }
            
        }
        self.userImageButton.layer.cornerRadius = self.userImageButton.frame.size.width / 2
    }
    
    
    @IBAction func userImageTapped(_ sender: Any) {
        self.delegate.userImageButtonTapped()
    }
    
    @IBAction func sendBuzzButtonTapped(_ sender: Any) {
    }
    
    @IBAction func addFavoriteButtonTapped(_ sender: Any) {
    }
    
    @IBAction func videoCallButtonTapped(_ sender: Any) {
        self.delegate.didTapVideoCall()
    }
    
    @IBAction func audioCallButtonTapped(_ sender: Any) {
        self.delegate.didTapAudioCall()
    }
    
    @IBAction func messageButtonTapped(_ sender: Any) {
        self.delegate.didTapMessage()
    }
    
}
