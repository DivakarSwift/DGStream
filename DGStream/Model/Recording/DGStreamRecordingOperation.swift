//
//  DGStreamRecordingOperation.swift
//  DGStream
//
//  Created by Brandon on 3/30/18.
//  Copyright © 2018 Dataglance. All rights reserved.
//

import UIKit

protocol DGStreamRecordingOperationDelegate {
    func recordingOperationDidFinish(recording: URL?)
}

class DGStreamRecordingOperation: Operation {
    
    var recording:URL!
    var nextRecording:URL!
    var delegate:DGStreamRecordingOperationDelegate!
    
    init(recording: URL, nextRecording: URL, delegate: DGStreamRecordingOperationDelegate) {
        super.init()
        self.recording = recording
        self.nextRecording = nextRecording
        self.delegate = delegate
    }
    
    override func main() {
        
        let firstAsset = AVURLAsset(url: self.recording, options: nil)
        let secondAsset = AVURLAsset(url: self.nextRecording, options: nil)
        
        let mixComposition = AVMutableComposition()
        
        // 2 - Create two video tracks
        var firstTrack = mixComposition.addMutableTrack(withMediaType: AVMediaTypeVideo,
                                                        preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
        do {
            try firstTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, firstAsset.duration),
                                           of: firstAsset.tracks(withMediaType: AVMediaTypeVideo)[0],
                                           at: kCMTimeZero)
        }
        catch let error {
            
        }
        
        var secondTrack = mixComposition.addMutableTrack(withMediaType: AVMediaTypeVideo,
                                                         preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
        
        do {
            try secondTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, secondAsset.duration),
                                            of: secondAsset.tracks(withMediaType: AVMediaTypeVideo)[0],
                                            at: firstAsset.duration)
        }
        catch let error {
            
        }
        
        // 2.1
        let mainInstruction = AVMutableVideoCompositionInstruction()
        mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeAdd(firstAsset.duration, secondAsset.duration))
        
        // 2.2
        let firstInstruction = videoCompositionInstructionForTrack(track: firstTrack, asset: firstAsset)
        firstInstruction.setOpacity(0.0, at: firstAsset.duration)
        let secondInstruction = videoCompositionInstructionForTrack(track: secondTrack, asset: secondAsset)
        
        // 2.3
        mainInstruction.layerInstructions = [firstInstruction, secondInstruction]
        let mainComposition = AVMutableVideoComposition()
        mainComposition.instructions = [mainInstruction]
        mainComposition.frameDuration = CMTimeMake(1, 30)
        mainComposition.renderSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        let myPathDocs = documentsDirectory.appending("overlapVideo.mp4")
        
        if FileManager.default.fileExists(atPath: myPathDocs) {
            print("Removing Previeous File")
            try? FileManager.default.removeItem(atPath: myPathDocs)
        }
        else {
            print("File Doesnt Exist")
        }
        
        let url = URL(fileURLWithPath: myPathDocs)
        
        let exporter = AVAssetExportSession(asset: mixComposition, presetName: AVCaptureSessionPresetHigh)
        exporter?.outputURL = url
        exporter?.videoComposition = mainComposition
        exporter?.outputFileType = AVFileTypeMPEG4;
        print("EXPORTING")
        exporter?.exportAsynchronously {
            print("FINISHED EXPORTING \(exporter?.error?.localizedDescription ?? "No Error")")
            self.delegate.recordingOperationDidFinish(recording: exporter?.outputURL)
        }
        
    }
    
    func videoCompositionInstructionForTrack(track: AVCompositionTrack, asset: AVAsset) -> AVMutableVideoCompositionLayerInstruction {
        let instruction = AVMutableVideoCompositionLayerInstruction(assetTrack: track)
        let assetTrack = asset.tracks(withMediaType: AVMediaTypeVideo)[0]
        
        let transform = assetTrack.preferredTransform
        let assetInfo = orientationFromTransform(transform: transform)
        
        var scaleToFitRatio = UIScreen.main.bounds.width / assetTrack.naturalSize.width
        if assetInfo.isPortrait {
            scaleToFitRatio = UIScreen.main.bounds.width / assetTrack.naturalSize.height
            let scaleFactor = CGAffineTransform(scaleX: scaleToFitRatio, y: scaleToFitRatio)
            instruction.setTransform(assetTrack.preferredTransform.concatenating(scaleFactor),
                                     at: kCMTimeZero)
        } else {
            let scaleFactor = CGAffineTransform(scaleX: scaleToFitRatio, y: scaleToFitRatio)
            var concat = assetTrack.preferredTransform.concatenating(scaleFactor).concatenating(CGAffineTransform(translationX: 0, y: UIScreen.main.bounds.width / 2))
            if assetInfo.orientation == .down {
                let fixUpsideDown = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
                let windowBounds = UIScreen.main.bounds
                let yFix = assetTrack.naturalSize.height + windowBounds.height
                let centerFix = CGAffineTransform(translationX: assetTrack.naturalSize.width, y: yFix)
                concat = fixUpsideDown.concatenating(centerFix).concatenating(scaleFactor)
            }
            instruction.setTransform(concat, at: kCMTimeZero)
        }
        return instruction
    }
    
    func orientationFromTransform(transform: CGAffineTransform) -> (orientation: UIImageOrientation, isPortrait: Bool) {
        var assetOrientation = UIImageOrientation.up
        var isPortrait = false
        if transform.a == 0 && transform.b == 1.0 && transform.c == -1.0 && transform.d == 0 {
            assetOrientation = .right
            isPortrait = true
        } else if transform.a == 0 && transform.b == -1.0 && transform.c == 1.0 && transform.d == 0 {
            assetOrientation = .left
            isPortrait = true
        } else if transform.a == 1.0 && transform.b == 0 && transform.c == 0 && transform.d == 1.0 {
            assetOrientation = .up
        } else if transform.a == -1.0 && transform.b == 0 && transform.c == 0 && transform.d == -1.0 {
            assetOrientation = .down
        }
        return (assetOrientation, isPortrait)
    }
    
}
