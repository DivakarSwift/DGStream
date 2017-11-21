//
//  DGStreamCollectionViewCell.swift
//  DGStream
//
//  Created by Brandon on 9/11/17.
//  Copyright © 2017 Dataglance. All rights reserved.
//

import UIKit
import Quickblox
import QuickbloxWebRTC

class DGStreamCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var placeholderImageView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var muteButton: UIButton!
    @IBOutlet weak var statusLabel: UILabel!
    
    var videoView: UIView!
    var connectionState: QBRTCConnectionState = .unknown
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = .black
        self.statusLabel.text = ""
    }
    
    func set(videoView: UIView?) {
        if let view = videoView {
            
            if self.videoView != nil {
                self.videoView.removeFromSuperview()
            }
            
            self.videoView = view
            
            self.videoView.frame = self.bounds
            self.containerView.insertSubview(self.videoView, aboveSubview: self.statusLabel)
            print("Placed Video View in Cell")
        }
    
    }
    
    func set(connectionState: QBRTCConnectionState) {
        
        self.connectionState = connectionState
        
        var statusString = ""
        switch connectionState {
        case .new:
            statusString = "New"
            break
        case .pending:
            statusString = "Pending"
            break
        case .checking:
            statusString = "Checking"
            break
        case .connecting:
            statusString = "Connecting"
            break
        case .connected:
            statusString = "Connected"
            break
        case .closed:
            statusString = "Closed"
            break
        case .rejected:
            statusString = "Rejected"
            break
        case .noAnswer:
            statusString = "No Answer"
            break
        case .disconnected:
            statusString = "Disconnected"
            break
        case .disconnectTimeout:
            statusString = "Timed Out"
            break
        default:
            break
        }
        self.statusLabel.text = statusString
        self.muteButton.isHidden = !(connectionState == .connected)
    }
    
}
