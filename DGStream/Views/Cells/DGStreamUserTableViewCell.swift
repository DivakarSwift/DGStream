//
//  DGStreamUserTableViewCell.swift
//  DGStream
//
//  Created by Brandon on 9/13/17.
//  Copyright © 2017 Dataglance. All rights reserved.
//

import UIKit

class DGStreamUserTableViewCell: UITableViewCell {

    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var abrevLabel: UILabel!
    
    @IBOutlet weak var userImageView: UIImageView!
    
    @IBOutlet weak var selectedNumberLabel: UILabel!
    
    var selectedIndex:Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.contentView.backgroundColor = .clear
        self.backgroundColor = .clear
        self.backgroundView?.backgroundColor = .clear
        nameLabel.textColor = UIColor.dgBlack()
        abrevLabel.textColor = UIColor.dgWhite()
        self.userImageView.layer.cornerRadius = self.userImageView.frame.width / 2
        self.userImageView.backgroundColor = .lightGray
        selectedNumberLabel.layer.cornerRadius = selectedNumberLabel.frame.width / 2
        selectedNumberLabel.backgroundColor = UIColor.dgDarkGray()
        selectedNumberLabel.textColor = UIColor.dgWhite()
        
    }
    
    func configureWith(user: DGStreamUser) {
        if let username = user.username {
            let abrev = NSString(string: username).substring(to: 1)
            abrevLabel.text = abrev
            nameLabel.text = username
        }
        else {
            abrevLabel.text = "?"
        }
        
        if selectedIndex != 0 {
            self.selectedNumberLabel.text = "\(selectedIndex)"
            self.selectedNumberLabel.isHidden = false
        }
        else {
            self.selectedNumberLabel.text = ""
            self.selectedNumberLabel.isHidden = true
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
