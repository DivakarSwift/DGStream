//
//  DGStreamIncomingCallView.swift
//  DGStream
//
//  Created by Brandon on 9/14/17.
//  Copyright © 2017 Dataglance. All rights reserved.
//

import UIKit

typealias IncomingCallBlock = (_ didAccept: Bool) -> Void

class DGStreamIncomingCallView: UIView {

    @IBOutlet weak var incomingCallLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var declineButton: UIButton!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var container: UIView!
    
    var incomingCallBlock: IncomingCallBlock?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.container.clipsToBounds = true
        self.container.layer.cornerRadius = 6
        self.layer.cornerRadius = 6
        
        self.imageView.layer.cornerRadius = self.imageView.frame.size.width / 2
        
        self.acceptButton.layer.cornerRadius = self.acceptButton.frame.size.width / 2
        self.declineButton.layer.cornerRadius = self.declineButton.frame.size.width / 2
        
        let acceptImage = UIImage(named: "answer", in: Bundle(identifier: "com.dataglance.DGStream"), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        let declineImage = UIImage(named: "hangup", in: Bundle(identifier: "com.dataglance.DGStream"), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        
        self.acceptButton.setImage(acceptImage, for: .normal)
        self.acceptButton.tintColor = .white
        self.acceptButton.imageEdgeInsets = UIEdgeInsetsMake(15, 15, 15, 15)
        
        self.declineButton.setImage(declineImage, for: .normal)
        self.declineButton.tintColor = .white
        self.declineButton.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10)
        
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowRadius = 6
        self.layer.shadowOpacity = 0.50
    }
    
    func presentWithin(viewController: UIViewController, fromUsername: String, block: @escaping IncomingCallBlock) {
        self.incomingCallBlock = block
        self.nameLabel.text = fromUsername
        self.alpha = 0
        viewController.view.addSubview(self)
        viewController.view.bringSubview(toFront: self)
        self.translatesAutoresizingMaskIntoConstraints = false
        
        let vertConstraint = NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: viewController.view, attribute: .centerY, multiplier: 1.0, constant: 0.0)
        let horiConstraint = NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: viewController.view, attribute: .centerX, multiplier: 1.0, constant: 0.0)
        let widthConstraint = NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: self.frame.size.width - 10)
        let heightConstraint = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: self.frame.size.height - 10)
        
        self.addConstraints([widthConstraint, heightConstraint])
        viewController.view.addConstraints([vertConstraint, horiConstraint])
        viewController.view.layoutIfNeeded()
        
        widthConstraint.constant = self.frame.size.width
        heightConstraint.constant = self.frame.size.height
        UIView.animate(withDuration: 0.20) {
            self.alpha = 1
            self.layoutIfNeeded()
        }
    }
    
    @IBAction func acceptButtonTapped(_ sender: Any) {
        if let block = self.incomingCallBlock {
            block(true)
            self.incomingCallBlock = nil
        }
        dismiss()
    }
    
    @IBAction func declineButtonTapped(_ sender: Any) {
        if let block = self.incomingCallBlock {
            block(false)
            self.incomingCallBlock = nil
        }
        dismiss()
    }
    
    func dismiss() {
        UIView.animate(withDuration: 0.20, animations: { 
            self.alpha = 0
        }) { (finished) in
            self.removeFromSuperview()
        }
    }
    
}
