//
//  DGStreamSendRecordingOperation.swift
//  DGStream
//
//  Created by Brandon on 5/17/18.
//  Copyright © 2018 Dataglance. All rights reserved.
//

import UIKit

protocol DGStreamSendRecordingOperationDelegate {
    func send(frame: QBRTCVideoFrame)
    func didFinishSendingFrame()
}

class DGStreamSendRecordingOperation: Operation {
    
    var frame:QBRTCVideoFrame!
    var fps: Int = 30
    var delegate: DGStreamSendRecordingOperationDelegate!
    
    init(recordingFrame: QBRTCVideoFrame, delegate: DGStreamSendRecordingOperationDelegate) {
        super.init()
        self.frame = recordingFrame
        self.delegate = delegate
    }
    
    override func main() {
//        let oneSecond:Double = 1.0
//        var milliseconds:Double = oneSecond / Double(self.fps)
//        let millisecondsStringSplice = String(milliseconds).components(separatedBy: ".")
//        if millisecondsStringSplice.count > 1 {
//            let newMilliseconds = millisecondsStringSplice[0]
//            if let double = Double(newMilliseconds) {
//                milliseconds = double
//                print("Double")
//            }
//        }
//        let remainder = oneSecond.remainder(dividingBy: Double(self.fps))
//        print("Wait \(milliseconds) milliseconds")
        self.delegate.send(frame: self.frame)
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(33) + .microseconds(33)) {
            self.delegate.didFinishSendingFrame()
        }
        
    }

}
