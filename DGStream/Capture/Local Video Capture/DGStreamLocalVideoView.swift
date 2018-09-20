//
//  DGStreamLocalVideoView.swift
//  DGStream
//
//  Created by Brandon on 6/30/18.
//  Copyright © 2018 Dataglance. All rights reserved.
//

import UIKit
import AVFoundation
import GPUImage2

//let blendImageName = "gsBackground.png"

protocol DGStreamLocalVideoViewDelegate {
    func localVideo(frameToBroadcast: QBRTCVideoFrame)
    func localVideo(errorMessage: String)
}

class DGStreamLocalVideoView: UIView {

    var renderView:RenderView!
    var camera: Camera!
    var delegate: DGStreamLocalVideoViewDelegate!
    
    var filterOperation: FilterOperationInterface?
    
    var blendImage: PictureInput?
    var backgroundImage: UIImage!
    var slider: UISlider!
    var isFront: Bool = false
    var isChromaKey:Bool = false
    
    var removeIntensity: Float = 0.6
    var removeColor: UIColor = .green
    
    let whiteMultiplier = Float(0.05)
    
    var orientation:UIDeviceOrientation = .portrait
    
    func configureWith(orientation: UIDeviceOrientation, isFront: Bool, isChromaKey: Bool, removeColor: UIColor, removeIntensity: Float, delegate: DGStreamLocalVideoViewDelegate) {
        print("Configure View Called \(Date())")
        self.backgroundColor = .clear
        self.orientation = orientation
        self.isChromaKey = isChromaKey
        self.removeColor = removeColor
        self.removeIntensity = removeIntensity
        self.delegate = delegate
        self.isFront = isFront
        self.setUpFilter()
        self.addRenderView()
        self.setUpCamera()
        self.setUpRenderView()
    }
    
    func deconfigure() {
        self.delegate = nil
//        if let videoCamera = camera {
//            videoCamera.stopCapture()
//            videoCamera.removeAllTargets()
//            blendImage?.removeAllTargets()
//        }
        
        if let rv = self.renderView {
            rv.removeFromSuperview()
            self.renderView = nil
        }
        if let blendImage = self.blendImage {
            blendImage.removeAllTargets()
            self.blendImage = nil
        }
        if let videoCamera = self.camera {
            videoCamera.stopCapture()
            videoCamera.delegate = nil
            videoCamera.removeAllTargets()
            self.camera = nil
        }
    }
    
    func getAngleOffsetForOrientation() -> CGFloat {
        let orientation = UIDevice.current.orientation
        var angleOffset:Double = .pi
        if orientation == .portrait {
            angleOffset = .pi
        }
        else if orientation == .landscapeLeft {
            angleOffset = 0.0
        }
        else if orientation == .landscapeRight {
            angleOffset = .pi
        }
        else {
            angleOffset = .pi
        }
        return CGFloat(angleOffset)
    }
    
    func getOrientation() -> ImageOrientation {
        let orientation = UIDevice.current.orientation
        var portraitOrientation:ImageOrientation = .portraitUpsideDown
        if self.isFront == false {
            portraitOrientation = .portrait

        }
        var imageOrientation: ImageOrientation = .portraitUpsideDown
        if orientation == .portrait {
            imageOrientation = portraitOrientation
        }
        else if orientation == .landscapeRight {
            imageOrientation = .landscapeLeft
        }
        else if orientation == .landscapeLeft {
            imageOrientation = .landscapeRight
        }
        else {
            imageOrientation = portraitOrientation
        }
        return imageOrientation
    }
    
    func adjust(orientation: UIDeviceOrientation, newSize: CGSize) {
        self.orientation = orientation
        var imageOrientation: ImageOrientation = .portraitUpsideDown
        var portraitOrientation:ImageOrientation = .portraitUpsideDown
        if self.camera.location == .backFacing {
            portraitOrientation = .portrait
        }
        if orientation == .portrait {
            imageOrientation = portraitOrientation
        }
        else if orientation == .landscapeRight {
            imageOrientation = .landscapeLeft
        }
        else if orientation == .landscapeLeft {
            imageOrientation = .landscapeRight
        }
        else {
            imageOrientation = portraitOrientation
        }
        self.renderView.orientation = imageOrientation
        if let filter = self.filterOperation {
            self.blendImage = PictureInput(image: UIImage(color: .clear, size: self.bounds.size)!, smoothlyScaleOutput: true, orientation: imageOrientation)
            self.blendImage?.addTarget(filter.filter)
            self.blendImage?.processImage()
        }
    }
    
    func adjust(intensity: Float) {
        if self.isChromaKey, let filter = self.filterOperation {
            var trueIntentsity = intensity
            if self.removeColor == .white {
                trueIntentsity = self.whiteOffset(originalIntensity: intensity)
            }
            switch (filter.sliderConfiguration) {
            case .enabled(_, _, _): filter.updateBasedOnSliderValue(trueIntentsity)
            case .disabled: break
            }
            self.removeIntensity = intensity
        }
    }
    
    func adjust(color: UIColor) {
        if self.isChromaKey, let filter = self.filterOperation {
            self.removeColor = color
            switch (filter.sliderConfiguration) {
            case .enabled(_, _, _): filter.updateBasedOnSliderValue(self.removeIntensity)
            case .disabled: break
            }
        }
    }
    
    func addRenderView() {
        if let rv = self.renderView {
            rv.removeFromSuperview()
            self.renderView = nil
        }
        self.renderView = RenderView(frame: UIScreen.main.bounds)
        self.renderView.backgroundRenderColor = .transparent
        self.renderView.backgroundColor = .clear
        self.renderView.boundInside(container: self)
        self.renderView.fillMode = .stretch
        self.renderView.orientation = self.getOrientation()
        if self.isChromaKey, self.removeColor == .black {
            self.alpha = 0.5
        }
        else {
            self.alpha = 1.0
        }
    }
    
    func whiteOffset(originalIntensity: Float) -> Float {
        return originalIntensity - (originalIntensity * whiteMultiplier)
    }
    
    func setUpFilter() {
        print("Set Up Filter Called \(Date())")
        var maxValue:Float = 1.0
        var initialValue:Float = self.removeIntensity
        
        if !self.isChromaKey, self.removeColor == .black {
            maxValue = 0.0
            initialValue = 0.0
        }
        
        self.filterOperation = FilterOperation(
            filter:{ChromaKeyBlendGreen()},
            listName:"Chroma key blend (green)",
            titleName:"Chroma Key (Green)",
            sliderConfiguration:.enabled(minimumValue:0.0, maximumValue:maxValue, initialValue:initialValue),
            sliderUpdateCallback: {(filter, sliderValue) in
                if self.isChromaKey {
                    filter.thresholdSensitivity = sliderValue
                    if self.removeColor == .green {
                        filter.colorToReplace = .green
                        print("Color Set To Green")
                        self.alpha = 1.0
                    }
                    else if self.removeColor == .red {
                        filter.colorToReplace = .red
                        print("Color Set To Red")
                        self.alpha = 1.0
                    }
                    else if self.removeColor == .blue {
                        filter.colorToReplace = .blue
                        print("Color Set To Blue")
                        self.alpha = 1.0
                    }
                    else if self.removeColor == .white {
                        filter.colorToReplace = .white
                        filter.thresholdSensitivity = self.whiteOffset(originalIntensity: sliderValue)
                        print("Color Set To Blue")
                        self.alpha = 1.0
                    }
                    else {
                        print("NO COLOR")
                        filter.thresholdSensitivity = 0.0
                        self.alpha = 0.5
                    }
                }
                else {
                    filter.thresholdSensitivity = 0.0
                    self.alpha = 1.0
                }
        },
            filterOperationType:.blend
        )
    }
    
    func setUpCamera() {
        print("Set Up Camera Called \(Date())")
        var location: PhysicalCameraLocation
        if self.isFront {
            location = .frontFacing
        }
        else {
            location = .backFacing
        }
        
        do {
            camera = try Camera(sessionPreset:AVCaptureSessionPresetMedium, location: location)
            camera!.runBenchmark = true
            camera.delegate = self
        } catch {
            camera = nil
            print("Couldn't initialize camera with error: \(error)")
            self.delegate.localVideo(errorMessage: "Could not set up camera.\n\(error.localizedDescription)")
        }
    }
    
    func changeTo(front: Bool) {
        var location: PhysicalCameraLocation = .backFacing
        if front {
            location = .frontFacing
        }

        self.renderView.orientation = self.getOrientation()
        
        do {
            camera = try Camera(sessionPreset:AVCaptureSessionPresetMedium, location: location)
            camera!.runBenchmark = true
            camera.delegate = self
        } catch {
            camera = nil
            print("Couldn't initialize camera with error: \(error)")
            self.delegate.localVideo(errorMessage: "Could not set up camera.\n\(error.localizedDescription)")
        }
        
        if front {
            // mirror
            self.renderView.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
        
        self.isFront = front
    }
    
    func beginChromaKey() {
        self.configureFor(callMode: .merge)
    }
    
    func stopChromaKey() {
        self.configureFor(callMode: .stream)
    }
    
    func setUpRenderView() {
        print("Set Up Render Called \(Date())")
        guard let videoCamera = self.camera else {
            print("Couldn't initialize camera!")
            return
        }
        
        videoCamera.stopCapture()
        
        // Configure the filter chain, ending with the view
        if let view = self.renderView, let filter = self.filterOperation {
            
            switch filter.filterOperationType {
            case .singleInput:
                self.camera.addTarget(filter.filter)
                filter.filter.addTarget(view)
            case .blend:
                self.camera.addTarget(filter.filter)
                self.blendImage = PictureInput(image: UIImage(color: .clear, size: self.bounds.size)!, smoothlyScaleOutput: true, orientation: self.getOrientation())
                self.blendImage?.addTarget(filter.filter)
                self.blendImage?.processImage()
                filter.filter.addTarget(view)
            case let .custom(filterSetupFunction:setupFunction):
                filter.configureCustomFilter(setupFunction(videoCamera, filter.filter, view))
            }
            
            videoCamera.startCapture()
            
            self.configureFor(callMode: .stream)
        }
        
        if self.isFront {
            // mirror
            self.renderView.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
    }
    
    func configureFor(callMode: CallMode) {
        var value:Float = 0.0
        if callMode == .merge {
            value = self.removeIntensity
        }
        if let filter = self.filterOperation {
            switch (filter.sliderConfiguration) {
            case .enabled(_, _, _): filter.updateBasedOnSliderValue(value)
            case .disabled: break
            }
        }
    }
    
    func updateWith(color: UIColor) {
        if let filter = self.filterOperation {
            
        }
    }

}

extension DGStreamLocalVideoView: CameraDelegate {
    func getOrientationForVideo() -> QBRTCVideoRotation {
        var orientation:QBRTCVideoRotation = ._90
        let deviceOrientation = self.orientation
        var adjustForPerspective = true
        if let callVC = self.delegate as? DGStreamCallViewController, callVC.callMode == .merge || (callVC.callMode == .perspective && callVC.isCurrentUserPerspective) {
            adjustForPerspective = false
        }
        if deviceOrientation == .portrait {
            orientation = ._90
        }
        else if deviceOrientation == .landscapeLeft {
            if adjustForPerspective {
                orientation = ._180
            }
            else {
                orientation = ._0
            }
        }
        else if deviceOrientation == .landscapeRight {
            if adjustForPerspective {
                orientation = ._0
            }
            else {
                orientation = ._180
            }
        }
        else {
            orientation = ._270
        }
        return orientation
    }
    
    func didCaptureBuffer(_ sampleBuffer: CMSampleBuffer) {
        var bufferCopy: CMSampleBuffer?
        if CMSampleBufferCreateCopy(kCFAllocatorDefault, sampleBuffer, &bufferCopy) == noErr, let copy = bufferCopy {
            
            // SEND AUDIO SAMPLE
            //            if connection.output is AVCaptureAudioDataOutput {
            //                self.delegate.recorder(self, audioSample: copy)
            //                print("AVCaptureAudioDataOutput!")
            //                return
            //            }
            let orientation = self.getOrientationForVideo()
            
            // SEND VIDEO FRAME
            if let pixelBuffer : CVPixelBuffer = CMSampleBufferGetImageBuffer(copy), let videoFrame = QBRTCVideoFrame(pixelBuffer: pixelBuffer, videoRotation: orientation) {
                if self.delegate != nil {
                    self.delegate.localVideo(frameToBroadcast: videoFrame)
                }
            }
            else {
                print("No Pixel Buffer")
            }
        }
        else {
            print("Failed To Copy")
        }
    }
}
