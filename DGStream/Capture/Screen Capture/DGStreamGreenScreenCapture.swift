//
//  DGStreamGreenScreenCapture.swift
//  DGStream
//
//  Created by Brandon on 10/9/17.
//  Copyright © 2017 Dataglance. All rights reserved.
//

import UIKit
import Quickblox
import QuickbloxWebRTC

class DGStreamGreenScreenCapture: QBRTCVideoCapture {
    
    var view: UIView!
    var displayLink: CADisplayLink!
    var int:Int = 0
    
    init(view: UIView) {
        super.init()
        self.view = view
    }
    
    func willEnterForeground(notification: Notification) {
        displayLink.isPaused = false
    }
    
    func didEnterBackground(notification: Notification) {
        displayLink.isPaused = true
    }
    
    func screenshot() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(view.frame.size, true, 0.5)
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: false)
        if let image = UIGraphicsGetImageFromCurrentImageContext() {
            UIGraphicsEndImageContext()
            return self.imageWithImage(sourceImage: image, scaledToWidth: view.bounds.width)
        }
        print("No Screenshot")
        return nil
    }
    
    func imageWithImage (sourceImage:UIImage, scaledToWidth: CGFloat) -> UIImage {
        let oldWidth = sourceImage.size.width
        let scaleFactor = scaledToWidth / oldWidth
        
        let newHeight = sourceImage.size.height * scaleFactor
        let newWidth = oldWidth * scaleFactor
        
        UIGraphicsBeginImageContext(CGSize(width:newWidth, height:newHeight))
        sourceImage.draw(in: CGRect(x:0, y:0, width:newWidth, height:newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    func qb_sharedGPUContext() -> CIContext {
        var sharedContext: CIContext = CIContext()
        DispatchQueue.once(token: "fff") { () in
            let options = [kCIContextPriorityRequestLow: false]
            sharedContext = CIContext(options: options)
        }
        return sharedContext
    }
    
    func sendPixelBuffer(sender: CADisplayLink) {
        
        self.videoQueue.sync {
            
            autoreleasepool {
                
                if let image = self.screenshot() {
                    
                    let renderWidth = Int(image.size.width)
                    let renderHeight = Int(image.size.height)
                    
                    var buffer:CVPixelBuffer? = nil
                    
                    let pixelFormatType = kCVPixelFormatType_420YpCbCr8BiPlanarFullRange
                    
                    let status:CVReturn = CVPixelBufferCreate(kCFAllocatorDefault, renderWidth, renderHeight, pixelFormatType, nil, &buffer)
                    
                    if status == kCVReturnSuccess, let buff = buffer {
                        
                        CVPixelBufferLockBaseAddress(buff, CVPixelBufferLockFlags(rawValue: 0))
                        
                        let rImage:CIImage = CIImage(image: image, options: [:])!
                        
                        self.qb_sharedGPUContext().render(rImage, to: buff)
                        
                        CVPixelBufferUnlockBaseAddress(buff, CVPixelBufferLockFlags(rawValue: 0))
                        
                        let videoFrame = QBRTCVideoFrame.init(pixelBuffer: buff, videoRotation: ._0)
                        
                        super.send(videoFrame)
                        self.int += 1
//                        print("SENT VIDEO FRAME \(self.int)")
                        
                    }
                    else {
                        print("Failed to create buffer. \(status)")
                    }
                    
                }
                else {
                    print("Failed to take snapshot.")
                }
                
            }
            
        }
        
    }
    
    //MARK - QBRTCVideoCapture
    override func didSet(to videoTrack: QBRTCLocalVideoTrack!) {
        super.didSet(to: videoTrack)
        print("Did Set Video Track")
        displayLink = CADisplayLink(target: self, selector: #selector(sendPixelBuffer(sender:)))
        displayLink.add(to: .main, forMode: .defaultRunLoopMode)
        displayLink.preferredFramesPerSecond = 30
        
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground(notification:)), name: Notification.Name.UIApplicationWillEnterForeground, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground(notification:)), name: Notification.Name.UIApplicationDidEnterBackground, object: nil)
        
    }
    
    override func didRemove(from videoTrack: QBRTCLocalVideoTrack!) {
        super.didRemove(from: videoTrack)
        print("Did Remove Video Track")
        displayLink.isPaused = true
        displayLink.remove(from: .main, forMode: .defaultRunLoopMode)
        displayLink = nil
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIApplicationWillEnterForeground, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIApplicationDidEnterBackground, object: nil)
    }
}

