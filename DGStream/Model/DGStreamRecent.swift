//
//  DGStreamRecent.swift
//  DGStream
//
//  Created by Brandon on 10/20/17.
//  Copyright © 2017 Dataglance. All rights reserved.
//

import UIKit

class DGStreamRecent: NSObject {
    var recentID: String?
    var senderID: NSNumber?
    var receiverID: NSNumber?
    var date: Date?
    var duration: Double?
    var sender: DGStreamUser?
    var receiver: DGStreamUser?
    var isMissed: Bool?
    
    class func createDGStreamRecentsFrom(protocols: [DGStreamRecentProtocol]) -> [DGStreamRecent] {
        var recents:[DGStreamRecent] = []
        for proto in protocols {
            let recent = DGStreamRecent()
            recent.date = proto.dgDate
            recent.isMissed = proto.dgIsMissed
            if proto.dgReceiverID != 0 {
                recent.receiver = DGStreamUser.createDGStreamUserFrom(proto: DGStreamManager.instance.dataSource.streamManager(DGStreamManager.instance, userWithUserID: proto.dgReceiverID)!)
            }
            recent.receiverID = proto.dgReceiverID
            recent.recentID = proto.dgID
            if proto.dgSenderID != 0 {
                recent.sender = DGStreamUser.createDGStreamUserFrom(proto: DGStreamManager.instance.dataSource.streamManager(DGStreamManager.instance, userWithUserID: proto.dgSenderID)!)
            }
            recent.senderID = proto.dgSenderID
            recents.append(recent)
        }
        return recents
    }
    
}

extension DGStreamRecent: DGStreamRecentProtocol {
    var dgID: String {
        get {
            return self.recentID ?? ""
        }
        set {
            self.dgID = self.recentID ?? ""
        }
    }
    
    var dgSenderID: NSNumber {
        get {
            return self.senderID ?? NSNumber(value: 0)
        }
        set {
            self.dgSenderID = self.senderID ?? NSNumber(value: 0)
        }
    }
    
    var dgReceiverID: NSNumber {
        get {
            return self.receiverID ?? NSNumber(value: 0)
        }
        set {
            self.dgReceiverID = self.receiverID ?? NSNumber(value: 0)
        }
    }
    
    var dgDate: Date {
        get {
            return self.date ?? Date()
        }
        set {
            self.dgDate = self.date ?? Date()
        }
    }
    
    var dgIsMissed: Bool {
        get {
            return self.isMissed ?? false
        }
        set {
            self.dgIsMissed = self.isMissed ?? false
        }
    }
    
}
