//
//  DGStreamRecordingManager.swift
//  DGStream
//
//  Created by Brandon on 3/30/18.
//  Copyright © 2018 Dataglance. All rights reserved.
//

import UIKit

class DGStreamRecordingManager: NSObject {
    
    var mainRecording: URL?
    var recordings: [URL] = []
    var recorder: DGStreamRecorder?
    var isRecording: Bool = false
    var orientation: UIInterfaceOrientation = .portrait

    init(orientation: UIInterfaceOrientation) {
        self.orientation = orientation
    }
    func startRecordingWith(localCaptureSession: AVCaptureSession, remoteRecorder: QBRTCRecorder?, bufferQueue:DispatchQueue, documentNumber: String, isMerged: Bool, delegate: DGStreamRecorderDelegate) {
        print("startRecordingWith")
        self.isRecording = true
        
        self.recorder = DGStreamRecorder(localCaptureSession: localCaptureSession, bufferQueue: bufferQueue, documentNumber: documentNumber, delegate: delegate)
        self.recorder?.startRecordingWith(remoteOrientation: .portrait, isMerged: isMerged)
    }
    
    func endRecording(completion: @escaping () -> Void) {
        if isRecording {
            print("endRecordingWith")
            self.recorder?.endRecordingWith(completion: { (url) in
                self.isRecording = false
                if let url = url {
                    self.recordings.append(url)
                }
                completion()
            })
        }
        else {
            completion()
        }
    }
    
    func finalizeRecording(completion: @escaping (_ url: URL?) -> Void) {
        let _ = DGStreamRecordingOperationQueue(recordings: self.recordings) { (success, errorMessage, url) in
            print("FINALIZED!")
            completion(url)
        }
    }

}
