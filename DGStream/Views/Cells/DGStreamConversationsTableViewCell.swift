//
//  DGStreamConversationsTableViewCell.swift
//  DGStream
//
//  Created by Brandon on 10/20/17.
//  Copyright © 2017 Dataglance. All rights reserved.
//

import UIKit

class DGStreamConversationsTableViewCell: UITableViewCell {

    @IBOutlet weak var accessoryButton: UIButton!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var abrevLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    var gradient: CAGradientLayer?
    var conversation: DGStreamConversation!
    var delegate: DGStreamTableViewCellDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.contentView.backgroundColor = .clear
        self.backgroundColor = .clear
        nameLabel.textColor = UIColor.dgBlack()
        userImageView.backgroundColor = UIColor.dgBlack()
        abrevLabel.textColor = .white
        userImageView.layer.cornerRadius = userImageView.frame.size.width / 2
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

    func configureWith(conversation: DGStreamConversation) {
        self.conversation = conversation
        if let userIDs = conversation.userIDs {
            for userID in userIDs {
                if let currentUser = DGStreamCore.instance.currentUser, let currentUserID = currentUser.userID, userID != currentUserID, let user = DGStreamCore.instance.getOtherUserWith(userID: userID), let username = user.username {
    
                    self.nameLabel.text = username
                    
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
            }
        }
        else {
            self.nameLabel.text = ""
        }
    }
    
    func setUpGradient() {
        if let gradient = self.gradient {
            gradient.removeFromSuperlayer()
        }
        let dark = UIColor(red: 0, green: 0, blue: 0, alpha: 0.10)
        self.gradient = self.addGradientBackground(firstColor: .clear, secondColor: dark, height: self.contentView.bounds.size.height)
    }
    
    func update(user: DGStreamUser, forOnline isOnline: Bool) {
        
        let otherUserID = self.conversation.userIDs.filter { (userID) -> Bool in
            return userID != DGStreamCore.instance.currentUser?.userID ?? 0
        }.first
        
        if let otherUserID = otherUserID, let userID = user.userID, otherUserID == userID {
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
    
    @IBAction func userButtonTapped(_ sender: Any) {
        
        let userID = self.conversation.userIDs.filter { (userID) -> Bool in
            return userID != DGStreamCore.instance.currentUser?.userID ?? 0
        }.first!
        
        self.delegate.userButtonTapped(userID: userID)
    }
    
    @IBAction func accessoryButtonTapped(_ sender: Any) {
        let userID = self.conversation.userIDs.filter { (userID) -> Bool in
            return userID != DGStreamCore.instance.currentUser?.userID ?? 0
            }.first!
        
        self.delegate.userButtonTapped(userID: userID)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.abrevLabel.text = ""
        self.nameLabel.text = ""
        self.userImageView.image = nil
        self.userImageView.layer.borderColor = UIColor.clear.cgColor
    }
    
}
