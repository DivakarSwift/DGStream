//
//  DGStreamScreenCapture.swift
//  DGStream
//
//  Created by Brandon on 9/11/17.
//  Copyright © 2017 Dataglance. All rights reserved.
//

import UIKit
import Quickblox
import QuickbloxWebRTC

protocol WhateverProtocol {
    func error(message: String)
}

//let isIPadPro = (MAX([[UIScreen mainScreen]bounds].size.width,[[UIScreen mainScreen] bounds].size.height) > 1024)
let isIpadPro:Bool = max(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height) > 1024

class DGStreamScreenCapture: QBRTCVideoCapture {
    
    var view: UIView!
    var displayLink: CADisplayLink!
    var int:Int = 0
    var delegate: WhateverProtocol?
    var isIpad = false
    var didAlert = false

    init(view: UIView) {
        super.init()
        self.view = view
        if Display.pad {
            isIpad = true
        }
        UIGraphicsBeginImageContextWithOptions(self.view.frame.size, false, 1.0)
        let context = UIGraphicsGetCurrentContext()
        context?.interpolationQuality = CGInterpolationQuality.medium
        context?.setFillColor(UIColor.clear.cgColor)
        context?.synchronize()
    }
    
    func willEnterForeground(notification: Notification) {
        displayLink.isPaused = false
    }
    
    func didEnterBackground(notification: Notification) {
        displayLink.isPaused = true
    }
    
//    func screenshot() -> UIImage? {
//        UIGraphicsBeginImageContextWithOptions(self.view.frame.size, true, 1.0)
//        self.view.drawHierarchy(in: self.view.bounds, afterScreenUpdates: false)
//        if let image = UIGraphicsGetImageFromCurrentImageContext() {
//            UIGraphicsEndImageContext()
//            return DGStreamScreenCapture.imageWithImage(sourceImage: image, scaledToWidth: view.bounds.width)
//        }
//        print("No Screenshot")
//        return nil
//    }
    func screenshot() -> UIImage? {
        
        if isIpadPro {
            return DGStreamScreenCapture.takeScreenshotOf(view: self.view)
        }
        
        if isIpad && didAlert == false && UIGraphicsGetCurrentContext() == nil {
            self.delegate?.error(message: "Nil Context")
            didAlert = true
        }
        self.view.drawHierarchy(in: self.view.bounds, afterScreenUpdates: false)
        if let image = UIGraphicsGetImageFromCurrentImageContext() {
            return image
        }
        else {
            if isIpad && didAlert == false {
                self.delegate?.error(message: "Could not create screenshot")
                didAlert = true
                return nil
            }
        }
        if isIpad && didAlert == false {
            self.delegate?.error(message: "No screenshot")
            didAlert = true
        }
        return nil
    }
    
    class func takeScreenshotOf(view: UIView) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(view.frame.size, true, 0.50)
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: false)
        if let image = UIGraphicsGetImageFromCurrentImageContext() {
            UIGraphicsEndImageContext()
            return DGStreamScreenCapture.imageWithImage(sourceImage: image, scaledToWidth: view.bounds.width / 4)
        }
        print("No Screenshot")
        return nil
        
//        guard let layer = UIApplication.shared.keyWindow?.layer else { return nil }
//        let renderer = UIGraphicsImageRenderer(size: layer.frame.size)
//        let image = renderer.image(actions: { context in
//            layer.render(in: context.cgContext)
//        })
//        return image
        
//        let bounds = UIScreen.main.bounds
//        UIGraphicsBeginImageContextWithOptions(bounds.size, true, 0.0)
//        yourUIViewController.view!.drawHierarchy(in: bounds, afterScreenUpdates: false)
//
//        let img = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        return
    }
    
    class func imageWithImage (sourceImage:UIImage, scaledToWidth: CGFloat) -> UIImage {
        let oldWidth = sourceImage.size.width
        let scaleFactor = scaledToWidth / oldWidth

        let newHeight = sourceImage.size.height * scaleFactor
        let newWidth = oldWidth * scaleFactor

        UIGraphicsBeginImageContextWithOptions(CGSize(width:newWidth, height:newHeight), true, UIScreen.main.scale)
        sourceImage.draw(in: CGRect(x:0, y:0, width:newWidth, height:newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    func qb_sharedGPUContext() -> CIContext {
        var sharedContext: CIContext = CIContext()
        DispatchQueue.once(token: "fff") { () in
            let options = [kCIContextPriorityRequestLow: NSNumber(value: true), kCIContextHighQualityDownsample: true]
            sharedContext = CIContext(options: options)
        }
        return sharedContext
    }
    
    func sendPixelBuffer(sender: CADisplayLink) {
        
        self.videoQueue.sync {
            
            autoreleasepool {
                
                print("Duration = \(displayLink.duration)")
                
                if let image = self.screenshot() {
                    
                    var renderWidth:Int = Int(image.size.width)
                    var renderHeight:Int = Int(image.size.height)
                    if isIpadPro {
                        renderWidth *= 2
                        renderHeight *= 2
                    }
                    
                    var buffer:CVPixelBuffer? = nil
                    
                    let pixelFormatType = kCVPixelFormatType_420YpCbCr8BiPlanarFullRange
                    
                    let status:CVReturn = CVPixelBufferCreate(kCFAllocatorDefault, renderWidth, renderHeight, pixelFormatType, nil, &buffer)
                    
                    if status == kCVReturnSuccess, let buff = buffer {
                        
                        CVPixelBufferLockBaseAddress(buff, CVPixelBufferLockFlags(rawValue: 0))
                        
                        let rImage:CIImage = CIImage(image: image, options: [:])!
                        
                        self.qb_sharedGPUContext().render(rImage, to: buff)
                        
                        CVPixelBufferUnlockBaseAddress(buff, CVPixelBufferLockFlags(rawValue: 0))
                        
                        let videoFrame = QBRTCVideoFrame.init(pixelBuffer: buff, videoRotation: ._0)
//                        super.adaptOutputFormat(toWidth: UInt(renderWidth), height: UInt(renderHeight), fps: 30)
                        super.send(videoFrame)
                        self.int += 1
//                        print("SENT VIDEO FRAME \(self.int)")
                        
                    }
                    else {
                        print("Failed to create buffer. \(status)")
                        if isIpad && didAlert == false {
                            self.delegate?.error(message: "Failed to create buffer. \(status)")
                            didAlert = true
                        }
                    }
                    
                }
                else {
                    print("Failed to take snapshot.")
                    if isIpad && didAlert == false {
                        self.delegate?.error(message: "Failed to take snapshot.")
                        didAlert = true
                    }
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
        displayLink.preferredFramesPerSecond = 60
        
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
