//
//  DGStreamChatMessage.swift
//  DGStream
//
//  Created by Brandon on 10/13/17.
//  Copyright © 2017 Dataglance. All rights reserved.
//

import UIKit

class DGStreamMessage: NSObject {
    var id: String?
    var message: String!
    var senderID: NSNumber!
    var receiverID: NSNumber!
    var conversationID: String!
    var delivered: Date!
    var isSystem: Bool = false
    
    class func createDGStreamMessageFrom(proto: DGStreamMessageProtocol) -> DGStreamMessage {
        let message = DGStreamMessage()
        message.message = proto.dgMessage
        message.senderID = proto.dgSenderID
        message.receiverID = proto.dgReceiverID
        message.delivered = proto.dgDelivered
        return message
    }
    
    class func createDGStreamMessageFrom(chatMessage: QBChatMessage) -> DGStreamMessage {
        let message = DGStreamMessage()
        message.id = chatMessage.id
        message.message = chatMessage.text
        message.senderID = NSNumber(value: chatMessage.senderID)
        message.receiverID = NSNumber.init(value: chatMessage.recipientID)
        message.conversationID = chatMessage.dialogID ?? ""
        return message
    }
    
    class func createQuickbloxMessageFrom(message: DGStreamMessage) -> QBChatMessage {
        
        let sortedIDs = [message.receiverID, message.senderID].sorted { (first, second) -> Bool in
            return first.uintValue < second.uintValue
        }
        
        var dialogID = ""
        for sortedID in sortedIDs {
            dialogID.append(sortedID.stringValue)
        }
        
        let customParam = NSMutableDictionary()
        customParam.setObject("1", forKey: "send_to_chat" as NSCopying)
        
        let quickbloxMessage = QBChatMessage()
        quickbloxMessage.customParameters = customParam
        quickbloxMessage.dialogID = message.conversationID
        quickbloxMessage.createdAt = Date()
        quickbloxMessage.id = message.id
        quickbloxMessage.recipientID = message.receiverID.uintValue
        quickbloxMessage.senderID = message.senderID.uintValue
        quickbloxMessage.text = message.message
        return quickbloxMessage
    }
    
}

extension DGStreamMessage: DGStreamMessageProtocol {
    
    var dgConversationID: String {
        get {
            return self.conversationID
        }
        set {
            self.dgConversationID = self.conversationID
        }
    }
    
    var dgDelivered: Date {
        get {
            return self.delivered
        }
        set {
            self.dgDelivered = self.delivered
        }
    }
    
    var dgMessageID: String {
        get {
            return self.id ?? ""
        }
        set {
            self.dgMessageID = self.id ?? ""
        }
    }
    
    var dgSenderID: NSNumber {
        get {
            return self.senderID
        }
        set {
            self.dgSenderID = self.senderID
        }
    }
    
    var dgReceiverID: NSNumber {
        get {
            return self.receiverID
        }
        set {
            self.dgReceiverID = self.receiverID
        }
    }
    
    var dgMessage: String {
        get {
            return self.message
        }
        set {
            self.dgMessage = self.message
        }
    }
}
