//
//  DGStreamLocalVideoCapture.swift
//  DGStream
//
//  Created by Brandon on 4/24/18.
//  Copyright © 2018 Dataglance. All rights reserved.
//

import UIKit
import Quickblox
import QuickbloxWebRTC

class DGStreamLocalVideoCapture: QBRTCVideoCapture {
    
    var view: UIView!
    var displayLink: CADisplayLink!
    var int:Int = 0
    
    init(view: UIView) {
        super.init()
        self.view = view
    }
    
    func willEnterForeground(notification: Notification) {
        //displayLink.isPaused = false
    }
    
    func didEnterBackground(notification: Notification) {
        //displayLink.isPaused = true
    }
    
    func qb_sharedGPUContext() -> CIContext {
        var sharedContext: CIContext = CIContext()
        DispatchQueue.once(token: "vvv") { () in
            let options = [kCIContextPriorityRequestLow: false]
            sharedContext = CIContext(options: options)
        }
        return sharedContext
    }
    
    func send(videoFrame: QBRTCVideoFrame) {
        self.videoQueue.sync {
            super.send(videoFrame)
        }
    }
    
    //MARK - QBRTCVideoCapture
    override func didSet(to videoTrack: QBRTCLocalVideoTrack!) {
        super.didSet(to: videoTrack)
        print("Did Set Video Track")
//        displayLink = CADisplayLink(target: self, selector: #selector(sendPixelBuffer(sender:)))
//        displayLink.add(to: .main, forMode: .defaultRunLoopMode)
//        displayLink.preferredFramesPerSecond = 30
        
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground(notification:)), name: Notification.Name.UIApplicationWillEnterForeground, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground(notification:)), name: Notification.Name.UIApplicationDidEnterBackground, object: nil)
        
    }
    
    override func didRemove(from videoTrack: QBRTCLocalVideoTrack!) {
        super.didRemove(from: videoTrack)
        print("Did Remove Video Track")
//        displayLink.isPaused = true
//        displayLink.remove(from: .main, forMode: .defaultRunLoopMode)
//        displayLink = nil
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIApplicationWillEnterForeground, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIApplicationDidEnterBackground, object: nil)
    }
}
