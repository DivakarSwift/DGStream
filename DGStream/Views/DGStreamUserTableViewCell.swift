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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.userImageView.layer.cornerRadius = self.userImageView.frame.width / 2
        self.userImageView.backgroundColor = .lightGray
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
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
