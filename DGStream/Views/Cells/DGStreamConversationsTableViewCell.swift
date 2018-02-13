//
//  DGStreamConversationsTableViewCell.swift
//  DGStream
//
//  Created by Brandon on 10/20/17.
//  Copyright © 2017 Dataglance. All rights reserved.
//

import UIKit

class DGStreamConversationsTableViewCell: UITableViewCell {

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var abrevLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
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
    }

    func configureWith(conversation: DGStreamConversation) {
        self.conversation = conversation
        if let userIDs = conversation.userIDs {
            for userID in userIDs {
                if let currentUser = DGStreamCore.instance.currentUser, let currentUserID = currentUser.userID, userID != currentUserID, let user = DGStreamCore.instance.getOtherUserWith(userID: userID), let username = user.username {
                    let abrev = NSString(string: username).substring(to: 1)
                    self.abrevLabel.text = abrev
                    self.nameLabel.text = username
                    
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
        }
        else {
            self.nameLabel.text = ""
        }
    }
    
    func update(user: DGStreamUser, forOnline isOnline: Bool) {
        
        let otherUserID = self.conversation.userIDs.filter { (userID) -> Bool in
            return userID != DGStreamCore.instance.currentUser?.userID ?? 0
        }.first
        
        if let otherUserID = otherUserID, let userID = user.userID, otherUserID == userID {
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
    
    @IBAction func userButtonTapped(_ sender: Any) {
        
        let userID = self.conversation.userIDs.filter { (userID) -> Bool in
            return userID != DGStreamCore.instance.currentUser?.userID ?? 0
        }.first!
        
        self.delegate.userButtonTapped(userID: userID)
    }
    
}
