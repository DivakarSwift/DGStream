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
    
    var filterOperation: FilterOperationInterface = FilterOperation(
        filter:{ChromaKeyBlendGreen()},
        listName:"Chroma key blend (green)",
        titleName:"Chroma Key (Green)",
        sliderConfiguration:.enabled(minimumValue:0.0, maximumValue:1.0, initialValue:0.6),
        sliderUpdateCallback: {(filter, sliderValue) in
            filter.thresholdSensitivity = sliderValue
    },
        filterOperationType:.blend
    )
    
    var blendImage: PictureInput?
    var backgroundImage: UIImage!
    var slider: UISlider!
    var isFront: Bool = false
    var isChromaKey:Bool = false
    
    var removeIntensity: Float = 0.6
    var removeColor: UIColor = .green
    
    func configureWith(orientation: UIDeviceOrientation, isFront: Bool, isChromaKey: Bool, removeColor: UIColor, removeIntensity: Float, delegate: DGStreamLocalVideoViewDelegate) {
        self.backgroundColor = .clear
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
        if let rv = self.renderView {
            rv.removeFromSuperview()
            self.renderView = nil
        }
        if let videoCamera = self.camera {
            self.delegate = nil
            videoCamera.stopCapture()
            videoCamera.removeAllTargets()
            blendImage?.removeAllTargets()
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
        self.blendImage = PictureInput(image: UIImage(color: .clear, size: self.bounds.size)!, smoothlyScaleOutput: true, orientation: imageOrientation)
        self.blendImage?.addTarget(self.filterOperation.filter)
        self.blendImage?.processImage()
    }
    
    func adjust(intensity: Float) {
        if self.isChromaKey {
            switch (self.filterOperation.sliderConfiguration) {
            case .enabled(_, _, _): self.filterOperation.updateBasedOnSliderValue(intensity)
            case .disabled: break
            }
        }
    }
    
    func addRenderView() {
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
    
    func setUpFilter() {
        
        var maxValue:Float = 1.0
        var initialValue:Float = self.removeIntensity
        
        if !self.isChromaKey || self.removeColor == .black {
            maxValue = 0.0
            initialValue = 0.0
        }
        
        if self.removeColor == .green {
            self.filterOperation = FilterOperation(
                filter:{ChromaKeyBlendGreen()},
                listName:"Chroma key blend (green)",
                titleName:"Chroma Key (Green)",
                sliderConfiguration:.enabled(minimumValue:0.0, maximumValue:maxValue, initialValue:initialValue),
                sliderUpdateCallback: {(filter, sliderValue) in
                    filter.thresholdSensitivity = sliderValue
            },
                filterOperationType:.blend
            )
        }
        else if self.removeColor == .blue {
            self.filterOperation = FilterOperation(
                filter:{ChromaKeyBlendBlue()},
                listName:"Chroma key blend (green)",
                titleName:"Chroma Key (Green)",
                sliderConfiguration:.enabled(minimumValue:0.0, maximumValue:maxValue, initialValue:initialValue),
                sliderUpdateCallback: {(filter, sliderValue) in
                    filter.thresholdSensitivity = sliderValue
                    filter.colorToReplace = .blue
            },
                filterOperationType:.blend
            )
        }
        else if self.removeColor == .red {
            self.filterOperation = FilterOperation(
                filter:{ChromaKeyBlendRed()},
                listName:"Chroma key blend (green)",
                titleName:"Chroma Key (Green)",
                sliderConfiguration:.enabled(minimumValue:0.0, maximumValue:maxValue, initialValue:initialValue),
                sliderUpdateCallback: {(filter, sliderValue) in
                    filter.thresholdSensitivity = sliderValue
                    filter.colorToReplace = .red
            },
                filterOperationType:.blend
            )
        }
        else if self.removeColor == .white {
            self.filterOperation = FilterOperation(
                filter:{ChromaKeyBlendWhite()},
                listName:"Chroma key blend (green)",
                titleName:"Chroma Key (Green)",
                sliderConfiguration:.enabled(minimumValue:0.0, maximumValue:maxValue, initialValue:initialValue),
                sliderUpdateCallback: {(filter, sliderValue) in
                    filter.thresholdSensitivity = sliderValue - 0.35
                    filter.colorToReplace = .white
            },
                filterOperationType:.blend
            )
        }
        else if self.removeColor == .black {
            self.filterOperation = FilterOperation(
                filter:{Sharpen()},
                listName:"Chroma key blend (green)",
                titleName:"Chroma Key (Green)",
                sliderConfiguration:.enabled(minimumValue:0.0, maximumValue:maxValue, initialValue:initialValue),
                sliderUpdateCallback: {(filter, sliderValue) in
                    filter.sharpness = 0.50
            },
                filterOperationType:.blend
            )
        }
    }
    
    func setUpCamera() {
        if self.isFront {
            do {
                camera = try Camera(sessionPreset:AVCaptureSessionPresetMedium, location: .frontFacing)
                camera!.runBenchmark = true
                camera.delegate = self
            } catch {
                camera = nil
                print("Couldn't initialize camera with error: \(error)")
                self.delegate.localVideo(errorMessage: "Could not set up camera.\n\(error.localizedDescription)")
            }
        }
        else {
            
            do {
                camera = try Camera(sessionPreset:AVCaptureSessionPresetMedium, location: .backFacing)
                camera!.runBenchmark = true
                camera.delegate = self
            } catch {
                camera = nil
                print("Couldn't initialize camera with error: \(error)")
                self.delegate.localVideo(errorMessage: "Could not set up camera.\n\(error.localizedDescription)")
            }
        }
    }
    
    func changeTo(front: Bool) {
        var location: PhysicalCameraLocation = .backFacing
        if front {
            location = .frontFacing
        }
        camera.location = location
        self.renderView.orientation = self.getOrientation()
    }
    
    func beginChromaKey() {
        self.configureFor(callMode: .merge)
    }
    
    func stopChromaKey() {
        self.configureFor(callMode: .stream)
    }
    
    func setUpRenderView() {
        guard let videoCamera = self.camera else {
            print("Couldn't initialize camera!")
            return
        }
        
        videoCamera.stopCapture()
        
        // Configure the filter chain, ending with the view
        if let view = self.renderView {
            
            switch self.filterOperation.filterOperationType {
            case .singleInput:
                self.camera.addTarget(self.filterOperation.filter)
                self.filterOperation.filter.addTarget(view)
            case .blend:
                self.camera.addTarget(self.filterOperation.filter)
                self.blendImage = PictureInput(image: UIImage(color: .clear, size: self.bounds.size)!, smoothlyScaleOutput: true, orientation: self.getOrientation())
                self.blendImage?.addTarget(self.filterOperation.filter)
                self.blendImage?.processImage()
                self.filterOperation.filter.addTarget(view)
            case let .custom(filterSetupFunction:setupFunction):
                self.filterOperation.configureCustomFilter(setupFunction(videoCamera, self.filterOperation.filter, view))
            }
            
            videoCamera.startCapture()
            
            self.configureFor(callMode: .stream)
        }
        
        if self.isFront {
            // mirror
            self.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
    }
    
    func configureFor(callMode: CallMode) {
        var value:Float = 0.0
        if callMode == .merge {
            value = self.removeIntensity
        }
        switch (self.filterOperation.sliderConfiguration) {
        case .enabled(_, _, _): self.filterOperation.updateBasedOnSliderValue(value)
        case .disabled: break
        }
    }

}

extension DGStreamLocalVideoView: CameraDelegate {
    func getOrientationForVideo() -> QBRTCVideoRotation {
        var orientation:QBRTCVideoRotation = ._90
        let deviceOrientation = UIApplication.shared.statusBarOrientation
        var adjustForPerspective = false
        if let callVC = self.delegate as? DGStreamCallViewController, callVC.callMode == .merge || (callVC.callMode == .perspective && callVC.isCurrentUserPerspective) {
            adjustForPerspective = true
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
            DispatchQueue.main.async {
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
        }
        else {
            print("Failed To Copy")
        }
    }
}
