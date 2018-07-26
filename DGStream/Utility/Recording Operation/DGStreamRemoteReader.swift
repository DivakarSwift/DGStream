//
//  DGStreamRemoteReader.swift
//  DGStream
//
//  Created by Brandon on 6/21/18.
//  Copyright © 2018 Dataglance. All rights reserved.
//

import UIKit
import Quickblox
import QuickbloxWebRTC

typealias RemoteReaderCompletionBlock = (_ success: Bool, _ errorMessage: String) -> Void
typealias RemoteReaderSendBlock = (_ pixelBuffer: CVPixelBuffer) -> Void

class DGStreamRemoteReader: NSObject {
    
    var frames: [QBRTCVideoFrame] = []
    var fps: Int = 30
    var sendBlock: RemoteReaderSendBlock?
    var completion: RemoteReaderCompletionBlock?
    var assetReader: AVAssetReader!
    var assetReaderOutput: AVAssetReaderTrackOutput!
    
    init(readURL: URL, sendBlock: @escaping RemoteReaderSendBlock, completion: @escaping RemoteReaderCompletionBlock) {
        super.init()
        self.sendBlock = sendBlock
        self.completion = completion
        
        let asset = AVAsset(url: readURL)
        asset.loadValuesAsynchronously(forKeys: ["isReadable"]) {
            if let assetReader = try? AVAssetReader(asset: asset), let videoTrack = asset.tracks(withMediaType: AVMediaTypeVideo).first {
                self.fps = Int(videoTrack.nominalFrameRate)
                if self.fps > 33 {
                    self.fps /= 2
                }
                print("Frame Rate = \(self.fps) from | \(videoTrack.nominalFrameRate) | \(videoTrack.minFrameDuration) | \(videoTrack.naturalTimeScale)")
                self.assetReader = assetReader
                let outputSettings:[String: Any] = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange]
                let readerOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: outputSettings)
                if assetReader.canAdd(readerOutput) {
                    self.assetReaderOutput = readerOutput
                    assetReader.add(readerOutput)
                    assetReader.timeRange = CMTimeRangeMake(kCMTimeZero, asset.duration)
                    assetReader.startReading()
                    self.loadNextFrames()
                }
            }
        }
    }
    
    func stop() {
        if self.assetReader != nil {
            self.assetReader.cancelReading()
        }
    }
    
    func loadNextFrames() {
        if let sampleBuffer = self.assetReaderOutput.copyNextSampleBuffer() {
            var bufferCopy: CMSampleBuffer?
            if CMSampleBufferCreateCopy(kCFAllocatorDefault, sampleBuffer, &bufferCopy) == noErr, let copy = bufferCopy {
                // SEND VIDEO FRAME
                if let pixelBuffer : CVPixelBuffer = CMSampleBufferGetImageBuffer(copy), let sendBlock = self.sendBlock {
                    sendBlock(pixelBuffer)
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(fps)) {
                        self.loadNextFrames()
                    }
                }
                else {
                    print("No Pixel Buffer")
                }
            }
        }
        else if let completion = self.completion {
            completion(true, "")
        }
    }
}
