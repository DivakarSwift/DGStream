//
//  DGStreamVideoView.swift
//  DGStream
//
//  Created by Brandon on 9/12/17.
//  Copyright © 2017 Dataglance. All rights reserved.
//

import UIKit
import AVFoundation

class DGStreamVideoView: UIView {

    var videoLayer: AVCaptureVideoPreviewLayer!
    var switchCameraButton: UIButton!
    var containerView: UIView!
    
    init(layer: AVCaptureVideoPreviewLayer, frame: CGRect) {
        super.init(frame: frame)
        self.frame = frame
        self.videoLayer = layer
        self.videoLayer.frame = frame
        layer.videoGravity = AVLayerVideoGravityResizeAspect
        let image = UIImage(named: "", in: Bundle(identifier: ""), compatibleWith: nil)
        
        self.switchCameraButton = UIButton(type: .custom)
        self.switchCameraButton.autoresizingMask = .flexibleRightMargin
        self.switchCameraButton.setImage(image, for: .normal)
        
        self.switchCameraButton.addTarget(self, action: #selector(didPressSwitchCamera(sender:)), for: .touchUpInside)
        
        self.containerView = UIView(frame: self.bounds)
        self.containerView.backgroundColor = .clear
        self.containerView.layer.insertSublayer(layer, at: 0)
        
        self.insertSubview(self.containerView, at: 0)
        self.addSubview(self.switchCameraButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        self.updateOrientationIfNeeded()
    }
    
    func didPressSwitchCamera(sender: UIButton) {
        
    }
    
    func updateOrientationIfNeeded() {
        if let previewLayerConnection = self.videoLayer.connection {
            let interfaceOrientation = UIApplication.shared.statusBarOrientation
            let videoOrientation = AVCaptureVideoOrientation(rawValue: interfaceOrientation.rawValue)
            
            if previewLayerConnection.isVideoOrientationSupported && previewLayerConnection.videoOrientation != videoOrientation {
                previewLayerConnection.videoOrientation = videoOrientation!
            }
        }
    }
}
