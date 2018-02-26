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
        
        if message.isSystem {
            
            if let image = UIImage(named: "info", in: Bundle.init(identifier: "com.dataglance.DGStream"), compatibleWith: nil) {
                self.image.alpha = 0
                self.abrevLabel.alpha = 0
                self.imageButton.setImage(image.withRenderingMode(.alwaysTemplate), for: .normal)
                self.imageButton.backgroundColor = UIColor.dgBlueDark()
                self.imageButton.tintColor = .white
                self.imageButton.imageEdgeInsets = UIEdgeInsetsMake(4, 4, 4, 4)
            }
            
        }
        else if let user = DGStreamCore.instance.getOtherUserWith(userID: message.senderID), let username = user.username {
            
            if let userImageData = user.image, let userImage = UIImage.init(data: userImageData)  {
                self.image.image = userImage
                self.abrevLabel.text = ""
            }
            else {
                let abrev = NSString(string: username).substring(to: 1)
                self.abrevLabel.text = abrev
                self.abrevLabel.textColor = .white
            }
            
        }
        
        self.backgroundColor = .clear
        
        self.image.backgroundColor = UIColor.dgBlueDark()
        
        self.imageContainer.clipsToBounds = true
        self.imageContainer.layer.cornerRadius = self.imageContainer.frame.size.width / 2
        
        self.messageBubble.backgroundColor = UIColor.dgChatPeekCellBubble()
        self.messageBubble.clipsToBounds = true
        self.messageBubble.layer.cornerRadius = 6
        
        self.label.text = message.message
        self.label.textColor = .white
        self.label.layoutIfNeeded()
        
        if self.label.frame.size.width > (300 - kCellLabelPadding) {
            self.labelLeadingConstraint.priority = 999
            self.layoutIfNeeded()
        }
    }
}
