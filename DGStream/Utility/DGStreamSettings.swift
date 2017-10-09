//
//  DGStreamSettings.swift
//  DGStream
//
//  Created by Brandon on 9/12/17.
//  Copyright © 2017 Dataglance. All rights reserved.
//

import UIKit
import Quickblox
import QuickbloxWebRTC

class DGStreamSettings: NSObject {
    
    static let instance = DGStreamSettings()
    
    var videoFormat: QBRTCVideoFormat?
    var mediaConfiguration: QBRTCMediaStreamConfiguration?
    var preferredCameraPosition: AVCaptureDevicePosition?
    var recordSettings: DGStreamRecordSettings?
    
    override init() {
        super.init()
    }
    
    func initialize() {
        load()
    }
    
    func load() {
        
        let defaults = UserDefaults.standard
        
        var position = AVCaptureDevicePosition(rawValue: defaults.integer(forKey: "kPreferredCameraPosition"))
        
        if position == .unspecified {
            position = .back
        }
        
        if let videoFormatData = defaults.object(forKey: "kVideoFormatKey") as? Data, let format = NSKeyedUnarchiver.unarchiveObject(with: videoFormatData) as? QBRTCVideoFormat {
            self.videoFormat = format
        }
        else {
            self.videoFormat = QBRTCVideoFormat(width: 640, height: 480, frameRate: 30, pixelFormat: .formatARGB)
        }
        
        if let mediaConfigData = defaults.object(forKey: "kMediaConfigKey") as? Data, let config = NSKeyedUnarchiver.unarchiveObject(with: mediaConfigData) as? QBRTCMediaStreamConfiguration {
            self.mediaConfiguration = config
        }
        else {
            self.mediaConfiguration = QBRTCMediaStreamConfiguration.init()
            self.mediaConfiguration?.videoCodec = .VP8
        }
        
        if let recordSettingsData = defaults.object(forKey: "kRecordSettingsKey") as? Data, let records = NSKeyedUnarchiver.unarchiveObject(with: recordSettingsData) as? DGStreamRecordSettings {
            self.recordSettings = records
        }
        else {
            self.recordSettings = DGStreamRecordSettings()
        }
        
    }
    
    func saveToDisk() {
        
        let defaults = UserDefaults.standard
        
        var videoFormatData: Data?
        if let format = videoFormat {
            videoFormatData = NSKeyedArchiver.archivedData(withRootObject: format)
        }
        
        var mediaConfigData: Data?
        if let config = mediaConfiguration {
            mediaConfigData = NSKeyedArchiver.archivedData(withRootObject: config)
        }
        
        var recordSettingsData: Data?
        if let records = recordSettings {
            recordSettingsData = NSKeyedArchiver.archivedData(withRootObject: records)
        }
        
        defaults.set(self.preferredCameraPosition, forKey: "kPreferredCameraPosition")
        
        if let value = videoFormatData {
            defaults.set(value, forKey: "kVideoFormatKey")
        }
        
        if let value = mediaConfigData {
            defaults.set(value, forKey: "kMediaConfigKey")
        }
        
        if let value = recordSettingsData {
            defaults.set(value, forKey: "kRecordSettingsKey")
        }
        
        defaults.synchronize()
        
    }

}
