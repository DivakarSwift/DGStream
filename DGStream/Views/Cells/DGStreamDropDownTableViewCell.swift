//
//  DGStreamDropDownTableViewCell.swift
//  DGStream
//
//  Created by Brandon on 12/29/17.
//  Copyright © 2017 Dataglance. All rights reserved.
//

import UIKit

class DGStreamDropDownTableViewCell: UITableViewCell {
    
    @IBOutlet weak var seperator: UIView!
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureWith(title: String) {
        self.label.text = title
        self.label.textColor = UIColor.dgButtonColor()
    }
    
    override func prepareForReuse() {
        self.label.text = ""
    }

}
