//
//  DGStreamRecordSettings.swift
//  DGStream
//
//  Created by Brandon on 9/12/17.
//  Copyright © 2017 Dataglance. All rights reserved.
//

import UIKit
import Quickblox
import QuickbloxWebRTC

let multiplier_coef:Double = 0.07
let motion_coef:UInt = 1

class DGStreamRecordSettings: NSObject {
    var isEnabled:Bool = false
    var width: UInt = 0
    var height: UInt = 0
    var fps: UInt = 0
    
    var rotation:QBRTCVideoRotation?
    
    /**
     *  Calculates estimated bitrate for width, height and fps.
     *
     *  @return Estimated video bitrate
     */
    func estimateBitrate() -> UInt? {
        let double = Double(width)*Double(height)*Double(fps)*Double(motion_coef)*multiplier_coef
        return UInt(double)
    }
    
    override init() {
        super.init()
        self.width = 640
        self.height = 480
        self.fps = 30
    }
}
