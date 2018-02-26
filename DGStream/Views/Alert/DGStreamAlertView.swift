//
//  DGStreamAlertView.swift
//  DGStream
//
//  Created by Brandon on 10/11/17.
//  Copyright © 2017 Dataglance. All rights reserved.
//

import UIKit

typealias DGStreamAlertBlock = (_ didAccept: Bool) -> Void

enum AlertMode {
    case error
    case incomingAudioCall
    case incomingVideoCall
    case mergeRequest
    case mergeDeclined
    case mergeCancelled
    case shareRequest
    case shareCancelled
}

class DGStreamAlertView: UIView {

    var alertBlock: DGStreamAlertBlock?
    
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var declineButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var alertTitleLabel: UILabel!
    @IBOutlet weak var alertTitleLabelContainer: UIView!
    @IBOutlet weak var alertMessageLabel: UILabel!
    
    var alertMode: AlertMode = .incomingVideoCall
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.container.clipsToBounds = true
        self.container.layer.cornerRadius = 6
        self.layer.cornerRadius = 6
        
        self.imageView.layer.cornerRadius = self.imageView.frame.size.width / 2
        
        self.acceptButton.layer.cornerRadius = self.acceptButton.frame.size.width / 2
        self.declineButton.layer.cornerRadius = self.declineButton.frame.size.width / 2
        
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowRadius = 6
        self.layer.shadowOpacity = 0.50
    }
    
    func configureFor(mode: AlertMode, fromUsername: String?, message: String?, isWaiting: Bool) {
        
        self.alertMode = mode
        
        if let username = fromUsername, let user = DGStreamCore.instance.getOtherUserWith(username: username), let imageData = user.image, let image = UIImage.init(data: imageData) {
            self.imageView.image = image
            self.imageView.isHidden = false
        }
        
        switch mode {
            
        case .error:
            
            self.alertTitleLabelContainer.backgroundColor = .red
            self.alertTitleLabel.text = NSLocalizedString("Error", comment: "")
            
            break
            
        case .incomingAudioCall:
            
            self.nameLabel.text = fromUsername
            
            self.alertTitleLabelContainer.backgroundColor = UIColor.dgGreen()
            self.alertTitleLabel.text = NSLocalizedString("Incoming audio call...", comment: "")
            
            let acceptImage = UIImage(named: "answer", in: Bundle(identifier: "com.dataglance.DGStream"), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
            let declineImage = UIImage(named: "hangup", in: Bundle(identifier: "com.dataglance.DGStream"), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
            
            self.acceptButton.setImage(acceptImage, for: .normal)
            self.acceptButton.backgroundColor = UIColor.dgGreen()
            self.acceptButton.tintColor = UIColor.dgWhite()
            self.acceptButton.imageEdgeInsets = UIEdgeInsetsMake(15, 15, 15, 15)
            
            self.declineButton.setImage(declineImage, for: .normal)
            self.declineButton.tintColor = UIColor.dgWhite()
            self.declineButton.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10)
            
            break
            
        case .incomingVideoCall:
            
            self.nameLabel.text = fromUsername
            
            self.alertTitleLabelContainer.backgroundColor = UIColor.dgGreen()
            self.alertTitleLabel.text = NSLocalizedString("Incoming video call...", comment: "")
            
            let acceptImage = UIImage(named: "answer", in: Bundle(identifier: "com.dataglance.DGStream"), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
            let declineImage = UIImage(named: "hangup", in: Bundle(identifier: "com.dataglance.DGStream"), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
            
            self.acceptButton.setImage(acceptImage, for: .normal)
            self.acceptButton.backgroundColor = UIColor.dgGreen()
            self.acceptButton.tintColor = UIColor.dgWhite()
            self.acceptButton.imageEdgeInsets = UIEdgeInsetsMake(15, 15, 15, 15)
            
            self.declineButton.setImage(declineImage, for: .normal)
            self.declineButton.tintColor = UIColor.dgWhite()
            self.declineButton.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10)
            
            break
            
        case .mergeCancelled:
            break
            
        case .mergeDeclined:
            
            DispatchQueue.main.async {
                self.nameLabel.text = fromUsername
                self.alertMessageLabel.text = message ?? ""
                self.alertMessageLabel.isHidden = false
                self.acceptButton.isHidden = true
                self.declineButton.isHidden = true
                self.cancelButton.isHidden = false
                
                self.cancelButton.setTitle(NSLocalizedString("OK", comment: "Acknowledged dismissal"), for: .normal)
            }
            
            break
            
        case .mergeRequest:
            
            self.nameLabel.text = fromUsername
            
            self.alertTitleLabelContainer.backgroundColor = UIColor.dgMergeMode()
            self.alertTitleLabel.text = "Merge Request..."
            
            self.acceptButton.isHidden = false
            self.declineButton.isHidden = false
            if isWaiting == false {
                self.cancelButton.isHidden = true
            }
            
            let acceptImage = UIImage(named: "merge", in: Bundle(identifier: "com.dataglance.DGStream"), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
            let declineImage = UIImage(named: "hangup", in: Bundle(identifier: "com.dataglance.DGStream"), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
            
            self.acceptButton.setImage(acceptImage, for: .normal)
            self.acceptButton.backgroundColor = UIColor.dgMergeMode()
            self.acceptButton.tintColor = UIColor.dgWhite()
            self.acceptButton.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10)
            self.acceptButton.backgroundColor = .yellow
            
            self.declineButton.setImage(declineImage, for: .normal)
            self.declineButton.tintColor = UIColor.dgWhite()
            self.declineButton.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10)
            
            break
            
        case .shareCancelled:
            break
            
        case .shareRequest:
            break
            
        }
        
        if let message = message {
            self.alertMessageLabel.text = message
        }
        
        if isWaiting {
            self.alertMessageLabel.isHidden = false
            self.acceptButton.isHidden = true
            self.declineButton.isHidden = true
            self.cancelButton.isHidden = false
        }
        else {
            self.alertMessageLabel.isHidden = true
            self.alertMessageLabel.text = ""
            self.acceptButton.isHidden = false
            self.declineButton.isHidden = false
            self.cancelButton.isHidden = true
        }
        
    }
    
    func presentWithin(viewController: UIViewController, fromUsername: String, block: @escaping DGStreamAlertBlock) {
        self.nameLabel.text = fromUsername
        self.alertBlock = block
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
    
    func dismiss() {
        UIView.animate(withDuration: 0.20, animations: {
            self.alpha = 0
        }) { (finished) in
            self.removeFromSuperview()
        }
    }
    
    @IBAction func acceptButtonTapped(_ sender: Any) {
        DispatchQueue.main.async {
            if let block = self.alertBlock {
                block(true)
                self.alertBlock = nil
            }
            self.dismiss()
        }
    }
    
    @IBAction func declineButtonTapped(_ sender: Any) {
        DispatchQueue.main.async {
            if let block = self.alertBlock {
                block(false)
                self.alertBlock = nil
            }
            self.dismiss()
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss()
    }
    
}
