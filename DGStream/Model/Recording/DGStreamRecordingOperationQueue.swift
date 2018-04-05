//
//  DGStreamRecordingOperationQueue.swift
//  DGStream
//
//  Created by Brandon on 3/30/18.
//  Copyright © 2018 Dataglance. All rights reserved.
//

import UIKit

typealias RecordingOperationQueueCompletion = (_ success: Bool, _ errorMessage: String, _ recording: URL?) -> Void

class DGStreamRecordingOperationQueue: OperationQueue {
    
    var recording:URL?
    var recordings:[URL] = []
    var completion:RecordingOperationQueueCompletion?
    
    init(recordings: [URL], completion: @escaping RecordingOperationQueueCompletion) {
        super.init()
        self.recordings = recordings
        self.completion = completion
        joinNextRecording()
    }
    
    func joinNextRecording() {
        if let nextRecording = self.recordings.first, let index = self.recordings.index(of: nextRecording) {
            self.recordings.remove(at: index)
            if self.recording == nil {
                self.recording = nextRecording
            }
            else {
                self.addOperation(DGStreamRecordingOperation(recording: self.recording!, nextRecording: nextRecording, delegate: self))
            }
        }
        else if let completion = self.completion {
            completion(true, "", self.recording)
            self.completion = nil
        }
    }
    
}

extension DGStreamRecordingOperationQueue: DGStreamRecordingOperationDelegate {
    func recordingOperationDidFinish(recording: URL?) {
        print("recordingOperationDidFinish \(recording)")
        if let r = recording {
           self.recording = r
        }
    }
}
