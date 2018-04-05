//
//  DGStreamRecordingTrim.swift
//  DGStream
//
//  Created by Brandon on 4/2/18.
//  Copyright © 2018 Dataglance. All rights reserved.
//

import UIKit

class DGStreamRecordingTrim: NSObject {

    typealias TrimCompletion = (Error?) -> ()
    
    typealias TrimPoints = [(CMTime, CMTime)]
    
    func verifyPresetForAsset(preset: String, asset: AVAsset) -> Bool {
        let compatiblePresets = AVAssetExportSession.exportPresets(compatibleWith: asset)
        let filteredPresets = compatiblePresets.filter { $0 == preset }
        
        return filteredPresets.count > 0 || preset == AVAssetExportPresetPassthrough
    }
    
    func removeFileAtURLIfExists(url: NSURL) {
        if let filePath = url.path {
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: filePath) {
                try? fileManager.removeItem(atPath: filePath)
            }
        }
    }
    
    func trimVideo(sourceURL: URL, destinationURL: URL, trimPoints: TrimPoints, completion: TrimCompletion?) {
//        assert(sourceURL.fileURL)
//        assert(destinationURL.fileURL)
        
        let options = [ AVURLAssetPreferPreciseDurationAndTimingKey: true ]
        let asset = AVURLAsset(url: sourceURL, options: options)
        let preferredPreset = AVAssetExportPresetPassthrough
        if verifyPresetForAsset(preset: preferredPreset, asset: asset) {
            let composition = AVMutableComposition()
            let videoCompTrack = composition.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: CMPersistentTrackID())
            //_ = composition.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: CMPersistentTrackID())
            
            let assetVideoTrack: AVAssetTrack = asset.tracks(withMediaType: AVMediaTypeVideo).first as! AVAssetTrack
            let assetAudioTrack: AVAssetTrack = asset.tracks(withMediaType: AVMediaTypeAudio).first as! AVAssetTrack
            
            var compError: Error?
            
            var accumulatedTime = kCMTimeZero
            for (startTimeForCurrentSlice, endTimeForCurrentSlice) in trimPoints {
                let durationOfCurrentSlice = CMTimeSubtract(endTimeForCurrentSlice, startTimeForCurrentSlice)
                let timeRangeForCurrentSlice = CMTimeRangeMake(startTimeForCurrentSlice, durationOfCurrentSlice)
                
                do {
                    try videoCompTrack.insertTimeRange(timeRangeForCurrentSlice, of: assetVideoTrack, at: accumulatedTime)

                }
                catch let error {
                    compError = error
                }
//                audioCompTrack.insertTimeRange(timeRangeForCurrentSlice, ofTrack: assetAudioTrack, atTime: accumulatedTime, error: &compError)
                
                if compError != nil {
                    NSLog("error during composition: \(compError?.localizedDescription ?? "no error")")
                    if let completion = completion {
                        completion(compError)
                    }
                }
                
                accumulatedTime = CMTimeAdd(accumulatedTime, durationOfCurrentSlice)
            }
            
            let exportSession = AVAssetExportSession(asset: composition, presetName: preferredPreset)
            exportSession?.outputURL = destinationURL
            exportSession?.outputFileType = AVFileTypeAppleM4V
            exportSession?.shouldOptimizeForNetworkUse = true
            
            removeFileAtURLIfExists(url: destinationURL as NSURL)
            
            exportSession?.exportAsynchronously(completionHandler: { () -> Void in
                if let completion = completion {
                    completion(exportSession?.error)
                }
            })
        } else {
            NSLog("Could not find a suitable export preset for the input video")
            let error = NSError(domain: "org.linuxguy.VideoLab", code: -1, userInfo: nil)
            if let completion = completion {
                completion(error)
            }
        }
    }

    func getRemoteRecordingFor(tempRecording: DGStreamTempRecording) {
        
        let sem = DispatchSemaphore(value: 0)
        
        let documentDirectory = DGStreamFileManager.applicationDocumentsDirectory()
        let fileName = "\(tempRecording.id)-remote"
        let destinationURL = documentDirectory.appendingPathComponent("\(fileName).mp4")
    
        let trimPoints:TrimPoints = [(tempRecording.startTime, tempRecording.endTime)]
        
        trimVideo(sourceURL: tempRecording.localURL, destinationURL: destinationURL, trimPoints: trimPoints) { error in
            if let error = error {
                NSLog("Failure: \(error)")
            } else {
                NSLog("Success")
            }
            
            sem.signal()
        }
    }
}
