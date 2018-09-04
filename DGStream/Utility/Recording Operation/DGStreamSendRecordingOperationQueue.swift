//
//  DGStreamRecordingOperationQueue.swift
//  DGStream
//
//  Created by Brandon on 5/17/18.
//  Copyright © 2018 Dataglance. All rights reserved.
//

import UIKit
import Quickblox
import QuickbloxWebRTC

typealias SendRecordingOperationQueueCompletion = (_ success: Bool, _ errorMessage: String) -> Void
typealias SendRecordingOperationQueueBlock = (_ QBRTCVideoFrame: QBRTCVideoFrame) -> Void
typealias SendRecordingOperationQueueErrorBlock = (_ errorMessage: String) -> Void

class DGStreamSendRecordingOperationQueue: OperationQueue {
    
    var frames: [QBRTCVideoFrame] = []
    var fps: Int = 30
    var sendBlock: SendRecordingOperationQueueBlock?
    var completion: SendRecordingOperationQueueCompletion?
    var errorBlock: SendRecordingOperationQueueErrorBlock?
    var assetReader: AVAssetReader!
    var assetReaderOutput: AVAssetReaderTrackOutput!
    
    init(recordingURL: URL, sendBlock: @escaping SendRecordingOperationQueueBlock, errorBlock: @escaping SendRecordingOperationQueueErrorBlock, completion: @escaping SendRecordingOperationQueueCompletion) {
        super.init()
        self.sendBlock = sendBlock
        self.completion = completion
        self.errorBlock = errorBlock
        let asset = AVAsset(url: recordingURL)
        asset.loadValuesAsynchronously(forKeys: ["isReadable"]) {
            if let assetReader = try? AVAssetReader(asset: asset), let videoTrack = asset.tracks(withMediaType: AVMediaTypeVideo).first {
                self.fps = Int(videoTrack.nominalFrameRate)
                if self.fps > 33 {
                    self.fps /= 2
                }
                else if self.fps < 24 {
                    self.fps = 25
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
                else {
                    if let block = self.errorBlock {
                        block("Could not add output.")
                    }
                }
            }
        }
    }
    
    func stop() {
        self.cancelAllOperations()
        if self.assetReader != nil {
            self.assetReader.cancelReading()
        }
    }
    
    func loadNextFrames() {
        if let sampleBuffer = self.assetReaderOutput.copyNextSampleBuffer() {
            var bufferCopy: CMSampleBuffer?
            if CMSampleBufferCreateCopy(kCFAllocatorDefault, sampleBuffer, &bufferCopy) == noErr, let copy = bufferCopy {
                // SEND VIDEO FRAME
                if let pixelBuffer : CVPixelBuffer = CMSampleBufferGetImageBuffer(copy), let videoFrame = QBRTCVideoFrame(pixelBuffer: pixelBuffer, videoRotation: ._0), let sendBlock = self.sendBlock {
                    sendBlock(videoFrame)
                    print("Send Video Frame")
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
