//
//  DGStreamUserHeader.swift
//  DGStream
//
//  Created by Brandon on 12/19/17.
//  Copyright © 2017 Dataglance. All rights reserved.
//

import UIKit

class DGStreamUserHeader: UIView {

    @IBOutlet weak var userImageButton: UIButton!
    
    @IBOutlet weak var abrevLabel: UILabel!
    
    @IBOutlet weak var detailContainer: UIView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var tagLabel: UILabel!
    
    @IBOutlet weak var lastSeenLabel: UILabel!
    
    @IBOutlet weak var sendBuzzButton: UIButton!
    
    @IBOutlet weak var addFavoriteButton: UIButton!
    
    func configureWith(user: DGStreamUser) {
        
        self.detailContainer.backgroundColor = .clear
        self.detailContainer.layer.cornerRadius = 6
        self.detailContainer.layer.borderWidth = 1
        self.detailContainer.layer.borderColor = UIColor.dgBlueDark().cgColor
        
        self.nameLabel.textColor = UIColor.dgBlack()
        self.tagLabel.textColor = UIColor.dgGray()
        self.lastSeenLabel.textColor = UIColor.dgBlack()
        
        self.sendBuzzButton.setTitleColor(UIColor.dgBlueDark(), for: .normal)
        self.addFavoriteButton.setTitleColor(UIColor.dgBlueDark(), for: .normal)
        
        self.userImageButton.layer.cornerRadius = self.userImageButton.frame.size.width / 2
        self.userImageButton.clipsToBounds = true
        self.userImageButton.backgroundColor = UIColor.dgBlack()
        
        if let currentUser = DGStreamCore.instance.currentUser,
            let currentUserID = currentUser.userID,
            let userID = user.userID {
            
            if let username = user.username {
                self.nameLabel.text = username
                
                let abrev = NSString(string: username).substring(to: 1)
                self.abrevLabel.text = abrev
                
            }
            
            self.tagLabel.text = "Developer"
            
            if let lastSeen = user.lastSeen {
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .short
                dateFormatter.timeStyle = .short
                
                var lastSeenText = ""
                if Display.pad {
                    lastSeenText = "Last seen: \(dateFormatter.string(from: lastSeen))"
                }
                else {
                    lastSeenText = dateFormatter.string(from: lastSeen)
                }
                
                self.lastSeenLabel.text = lastSeenText
            }
            else {
                self.lastSeenLabel.text = "Last seen: Unknown"
            }
            
            if userID == currentUserID {
                
            }
            else {
                
            }
            
        }
    }
    
    @IBAction func sendBuzzButtonTapped(_ sender: Any) {
    }
    
    @IBAction func addFavoriteButtonTapped(_ sender: Any) {
    }
    

}
