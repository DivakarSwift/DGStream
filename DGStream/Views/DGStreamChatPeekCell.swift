//
//  DGStreamChatPeekCell.swift
//  DGStream
//
//  Created by Brandon on 11/17/17.
//  Copyright © 2017 Dataglance. All rights reserved.
//

import UIKit

class DGStreamChatPeekCell: UIView {
    
    
    @IBOutlet weak var imageContainer: UIView!
    @IBOutlet weak var imageBlurView: UIVisualEffectView!
    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var messageBubble: UIView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var abrevLabel: UILabel!
    @IBOutlet weak var labelLeadingConstraint: NSLayoutConstraint!
    
    let kCellLabelPadding:CGFloat = 48
    
    
    func configureWith(message: DGStreamMessage) {
        if let user = DGStreamCore.instance.getOtherUserWith(userID: message.senderID), let username = user.username {
            
            self.backgroundColor = .clear
            
            self.imageContainer.clipsToBounds = true
            self.imageContainer.layer.cornerRadius = self.imageContainer.frame.size.width / 2
            
            self.messageBubble.backgroundColor = UIColor.dgChatPeekCellBubble()
            self.messageBubble.clipsToBounds = true
            self.messageBubble.layer.cornerRadius = 6
            
            if let userImageData = user.image, let userImage = UIImage.init(data: userImageData)  {
                self.image.image = userImage
                self.abrevLabel.text = ""
            }
            else {
                let abrev = NSString(string: username).substring(to: 1)
                self.abrevLabel.text = abrev
                self.image.backgroundColor = .white
            }
            
            self.image.alpha = 0.5
            
            self.label.text = message.message
            self.label.layoutIfNeeded()
            
            if self.label.frame.size.width > (300 - kCellLabelPadding) {
                self.labelLeadingConstraint.priority = 999
                self.layoutIfNeeded()
            }
            
        }
    }
}
