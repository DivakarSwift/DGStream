//
//  DGStreamAudioVideoMerger.swift
//  DGStream
//
//  Created by Brandon on 4/16/18.
//  Copyright © 2018 Dataglance. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import AssetsLibrary

class DGStreamAudioVideoMerger: NSObject {
    func mergeVideoAndAudio(videoUrl: URL,
                            audioUrl: URL,
                            fileName: String,
                            completion: @escaping (_ error: Error?, _ errorMessage: String?, _ url: URL?) -> Void) {
        
        let mixComposition = AVMutableComposition()
        var mutableCompositionVideoTrack = [AVMutableCompositionTrack]()
        var mutableCompositionAudioTrack = [AVMutableCompositionTrack]()
        var mutableCompositionAudioOfVideoTrack = [AVMutableCompositionTrack]()
        //start merge
        
        let aVideoAsset = AVAsset(url: videoUrl)
        let aAudioAsset = AVAsset(url: audioUrl)
        
        if aVideoAsset.tracks.count == 0 {
            let errorMessage = "No Video Tracks."
            completion(nil, errorMessage, nil)
            return
        }
        
        let compositionAddVideo = mixComposition.addMutableTrack(withMediaType: AVMediaTypeVideo,
                                                                       preferredTrackID: kCMPersistentTrackID_Invalid)
        
        let compositionAddAudio = mixComposition.addMutableTrack(withMediaType: AVMediaTypeAudio,
                                                                     preferredTrackID: kCMPersistentTrackID_Invalid)
        
        let compositionAddAudioOfVideo = mixComposition.addMutableTrack(withMediaType: AVMediaTypeAudio,
                                                                            preferredTrackID: kCMPersistentTrackID_Invalid)
        
        let aVideoAssetTrack: AVAssetTrack = aVideoAsset.tracks(withMediaType: AVMediaTypeVideo)[0]
        let aAudioOfVideoAssetTrack: AVAssetTrack? = aVideoAsset.tracks(withMediaType: AVMediaTypeAudio).first
        let aAudioAssetTrack: AVAssetTrack = aAudioAsset.tracks(withMediaType: AVMediaTypeAudio)[0]
        
        // Default must have tranformation
        compositionAddVideo.preferredTransform = aVideoAssetTrack.preferredTransform
        
//        if shouldFlipHorizontally {
//            // Flip video horizontally
//            var frontalTransform: CGAffineTransform = CGAffineTransform(scaleX: -1.0, y: 1.0)
//            frontalTransform = frontalTransform.translatedBy(x: -aVideoAssetTrack.naturalSize.width, y: 0.0)
//            frontalTransform = frontalTransform.translatedBy(x: 0.0, y: -aVideoAssetTrack.naturalSize.width)
//            compositionAddVideo.preferredTransform = frontalTransform
//        }
        
        mutableCompositionVideoTrack.append(compositionAddVideo)
        mutableCompositionAudioTrack.append(compositionAddAudio)
        mutableCompositionAudioOfVideoTrack.append(compositionAddAudioOfVideo)
        
        do {
            try mutableCompositionVideoTrack[0].insertTimeRange(CMTimeRangeMake(kCMTimeZero,
                                                                                aVideoAssetTrack.timeRange.duration),
                                                                of: aVideoAssetTrack,
                                                                at: kCMTimeZero)
            
            //In my case my audio file is longer then video file so i took videoAsset duration
            //instead of audioAsset duration
            try mutableCompositionAudioTrack[0].insertTimeRange(CMTimeRangeMake(kCMTimeZero,
                                                                                aVideoAssetTrack.timeRange.duration),
                                                                of: aAudioAssetTrack,
                                                                at: kCMTimeZero)
            
            // adding audio (of the video if exists) asset to the final composition
            if let aAudioOfVideoAssetTrack = aAudioOfVideoAssetTrack {
                try mutableCompositionAudioOfVideoTrack[0].insertTimeRange(CMTimeRangeMake(kCMTimeZero,
                                                                                           aVideoAssetTrack.timeRange.duration),
                                                                           of: aAudioOfVideoAssetTrack,
                                                                           at: kCMTimeZero)
            }
            
        } catch {
            print(error.localizedDescription)
        }
        
        // Exporting
        let savePathUrl: URL = URL(fileURLWithPath: NSHomeDirectory() + "/Documents/\(fileName).mp4")
        do { // delete old video
            try FileManager.default.removeItem(at: savePathUrl)
        } catch { print(error.localizedDescription) }
        
        let assetExport: AVAssetExportSession = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetMediumQuality)!
        assetExport.outputFileType = AVFileTypeMPEG4
        assetExport.outputURL = savePathUrl
        assetExport.shouldOptimizeForNetworkUse = true
        assetExport.exportAsynchronously { () -> Void in
            switch assetExport.status {
            case AVAssetExportSessionStatus.completed:
                print("success")
                completion(nil, nil, savePathUrl)
            case AVAssetExportSessionStatus.failed:
                print("failed \(assetExport.error?.localizedDescription ?? "error nil")")
                completion(assetExport.error, nil, nil)
            case AVAssetExportSessionStatus.cancelled:
                print("cancelled \(assetExport.error?.localizedDescription ?? "error nil")")
                completion(assetExport.error, nil, nil)
            default:
                print("complete")
                completion(assetExport.error, nil, nil)
            }
        }
        
    }
}
