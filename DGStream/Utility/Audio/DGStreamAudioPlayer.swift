//
//  DGStreamAudioPlayer.swift
//  DGStream
//
//  Created by Brandon on 11/13/17.
//  Copyright © 2017 Dataglance. All rights reserved.
//

import UIKit
import AVFoundation

class DGStreamAudioPlayer: NSObject {

    var player:AVPlayer?
    
    var isOneRing = false
    
    override init() {
        super.init()
    }
    
    func ringFor(receiver: Bool) {
        
        var fileName = ""
        if receiver {
            fileName = "ReceiverRing"
        }
        else {
            fileName = "SenderRing"
        }
        if let path = Bundle.main.url(forResource: fileName, withExtension: "wav") {
            let playerItem = AVPlayerItem(url: path)
            self.player = AVPlayer(playerItem: playerItem)
            NotificationCenter.default.addObserver(self, selector: #selector(finishedPlaying), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
            self.player?.play()
        }
    }
    
    func ringForText() {
        let fileName = "TextRing"
        if let path = Bundle.main.url(forResource: fileName, withExtension: "wav") {
            let playerItem = AVPlayerItem(url: path)
            self.player = AVPlayer(playerItem: playerItem)
            NotificationCenter.default.addObserver(self, selector: #selector(finishedPlaying), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
            self.isOneRing = true
            self.player?.play()
        }
    }
    
    func ringForMerge() {
        let fileName = "MergeRing"
        if let path = Bundle.main.url(forResource: fileName, withExtension: "wav") {
            let playerItem = AVPlayerItem(url: path)
            self.player = AVPlayer(playerItem: playerItem)
            NotificationCenter.default.addObserver(self, selector: #selector(finishedPlaying), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
            self.isOneRing = true
            self.player?.play()
        }
    }
    
    func finishedPlaying() {
        if isOneRing {
            stopAllSounds()
        }
        else {
            self.player?.seek(to: kCMTimeZero)
            self.player?.play()
        }
    }
    
    func stopAllSounds() {
        if let player = self.player {
            self.isOneRing = false
            NotificationCenter.default.removeObserver(self, name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
            player.pause()
            self.player = nil
        }
    }
    
}
