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
}

class DGStreamUserHeader: UIView {

    var userImageButton: UIButton!
    
    @IBOutlet weak var userImageButtonContainer: UIView!
        
    @IBOutlet weak var detailContainer: UIView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var tagLabel: UILabel!
    
    @IBOutlet weak var lastSeenLabel: UILabel!
    
    @IBOutlet weak var sendBuzzButton: UIButton!
    
    @IBOutlet weak var addFavoriteButton: UIButton!
    
    var delegate: DGStreamUserHeaderDelegate!
    
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
        
        if let currentUser = DGStreamCore.instance.currentUser,
            let currentUserID = currentUser.userID,
            let userID = user.userID {
            
            if let imageData = user.image,
                let image = UIImage(data: imageData) {
                
                self.userImageButton = UIButton(type: .custom)
                self.userImageButton.boundInside(container: self.userImageButtonContainer)
                self.userImageButton.setImage(image, for: .normal)
                if userID == currentUserID {
                    self.userImageButton.addTarget(self, action: #selector(self.userImageTapped(_:)), for: .touchUpInside)
                }
                self.userImageButton.layer.cornerRadius = self.userImageButton.frame.size.width / 2
                self.userImageButton.clipsToBounds = true
                self.userImageButton.backgroundColor = UIColor.dgBlack()
                self.userImageButton.contentMode = .scaleAspectFill
                
            }
            else if let username = user.username {
                self.nameLabel.text = username
                
                let abrev = NSString(string: username).substring(to: 1)
                self.userImageButton = UIButton(type: .custom)
                self.userImageButton.boundInside(container: self.userImageButtonContainer)
                self.userImageButton.setTitle(abrev, for: .normal)
                if userID == currentUserID {
                    self.userImageButton.addTarget(self, action: #selector(self.userImageTapped(_:)), for: .touchUpInside)
                }
                self.userImageButton.layer.cornerRadius = self.userImageButton.frame.size.width / 2
                self.userImageButton.clipsToBounds = true
                self.userImageButton.backgroundColor = UIColor.dgBlack()
                self.userImageButton.titleLabel?.font = UIFont(name: "HelveticaNueue-Bold", size: 70)
                
            }
            
            self.tagLabel.text = "Developer (mock)"
            
            if let lastSeen = user.lastSeen {
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .short
                dateFormatter.timeStyle = .short
                
                var lastSeenText = ""
                if Display.pad {
                    lastSeenText = "\(NSLocalizedString("Last seen", comment: "Last seen (last_seen_date)")): \(dateFormatter.string(from: lastSeen))"
                }
                else {
                    lastSeenText = dateFormatter.string(from: lastSeen)
                }
                
                self.lastSeenLabel.text = lastSeenText
            }
            else {
                self.lastSeenLabel.text = "\(NSLocalizedString("Last seen", comment: "Last seen (last_seen_date)")): ?"
            }
            
            if userID == currentUserID {
                
            }
            else {
                
            }
            
        }
    }
    
    
    @IBAction func userImageTapped(_ sender: Any) {
        self.delegate.userImageButtonTapped()
    }
    
    @IBAction func sendBuzzButtonTapped(_ sender: Any) {
    }
    
    @IBAction func addFavoriteButtonTapped(_ sender: Any) {
    }
    

}
