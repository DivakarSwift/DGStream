//
//  DGStreamChatMessage.swift
//  DGStream
//
//  Created by Brandon on 10/13/17.
//  Copyright © 2017 Dataglance. All rights reserved.
//

import UIKit

typealias MessageCompletion = (_ message: DGStreamMessage) -> Void
typealias QBMessageCompletion = (_ message: QBChatMessage?) -> Void

class DGStreamMessage: NSObject {
    var id: String?
    var message: String!
    var senderID: NSNumber!
    var receiverID: NSNumber!
    var conversationID: String!
    var delivered: Date!
    var isSystem: Bool = false
    var image: UIImage?
    var imageID: String?
    
    class func createDGStreamMessageFrom(proto: DGStreamMessageProtocol) -> DGStreamMessage {
        let message = DGStreamMessage()
        message.message = proto.dgMessage
        message.senderID = proto.dgSenderID
        message.receiverID = proto.dgReceiverID
        message.delivered = proto.dgDelivered
        return message
    }
    
    class func createReceivedMessageFrom(chatMessage: QBChatMessage, completion: MessageCompletion) {
        
        let message = DGStreamMessage()
        message.id = chatMessage.id
        message.message = chatMessage.text
        message.senderID = NSNumber(value: chatMessage.senderID)
        message.receiverID = NSNumber.init(value: chatMessage.recipientID)
        message.conversationID = chatMessage.dialogID ?? ""
        
        chatMessage.attachments?.forEach({ (attachment) in
            message.imageID = attachment.id
        })
    }
    
    class func createQuickbloxMessageFrom(message: DGStreamMessage, completion: @escaping QBMessageCompletion) {
        
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
        
        if let image = message.image, let data = UIImagePNGRepresentation(image) {
            // IMAGE
            QBRequest.tUploadFile(data, fileName: "image.png", contentType: "image/png", isPublic: false, successBlock: {(response: QBResponse!, uploadedBlob: QBCBlob!) in
                let uploadedFileID: UInt = uploadedBlob.id
                let attachment: QBChatAttachment = QBChatAttachment()
                attachment.type = "image"
                attachment.id = String(uploadedFileID)
                customParam.setObject("true", forKey: "isImage" as NSCopying)
                quickbloxMessage.attachments = [attachment]
                completion(quickbloxMessage)
            }, statusBlock: {(request: QBRequest?, status: QBRequestStatus?) in
                
            }, errorBlock: {(response: QBResponse!) in
                print(response.error?.reasons ?? "NO REASON")
                completion(nil)
            })
        
            
        }
        else {
            // TEXT
            customParam.setObject("false", forKey: "isImage" as NSCopying)
            quickbloxMessage.text = message.message
            completion(quickbloxMessage)
        }

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
