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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.contentView.backgroundColor = .clear
        self.backgroundColor = .clear
        nameLabel.textColor = UIColor.dgDarkGray()
        userImageView.backgroundColor = UIColor.dgDarkGray()
        abrevLabel.textColor = UIColor.dgBackground()
        userImageView.layer.cornerRadius = userImageView.frame.size.width / 2
    }

    func configureWith(conversation: DGStreamConversation) {
        if let userIDs = conversation.userIDs {
            for userID in userIDs {
                if let currentUser = DGStreamCore.instance.currentUser, let currentUserID = currentUser.userID, userID != currentUserID, let user = DGStreamCore.instance.getOtherUserWith(userID: userID), let username = user.username {
                    let abrev = NSString(string: username).substring(to: 1)
                    self.abrevLabel.text = abrev
                    self.nameLabel.text = username
                }
            }
        }
        else {
            self.nameLabel.text = "Unknown"
        }
    }

}
