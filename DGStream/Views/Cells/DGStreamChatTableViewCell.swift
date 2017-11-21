//
//  DGStreamChatTableViewCell.swift
//  DGStream
//
//  Created by Brandon on 10/13/17.
//  Copyright © 2017 Dataglance. All rights reserved.
//

import UIKit

class DGStreamChatTableViewCell: UITableViewCell {
    
    @IBOutlet weak var bubbleEndConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var bubbleContainer: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.backgroundColor = UIColor.dgBackground()
    }

    func configureWith(chatMessage: DGStreamMessage) {
        bubbleContainer.backgroundColor = UIColor.dgDarkGray()
        bubbleContainer.layer.cornerRadius = 6
        self.messageLabel.text = chatMessage.message
        if let currentUser = DGStreamCore.instance.currentUser, let currentUserID = currentUser.userID, chatMessage.senderID == currentUserID {
            bubbleContainer.backgroundColor = UIColor.dgBlueDark()
        }
        else {
            bubbleContainer.backgroundColor = UIColor.dgGreen()
        }
        self.bubbleEndConstraint.constant = contentView.bounds.size.width / 2
        self.contentView.layoutIfNeeded()
    }

}
