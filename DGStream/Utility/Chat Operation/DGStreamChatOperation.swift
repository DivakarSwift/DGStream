//
//  DGStreamChatOperation.swift
//  DGStream
//
//  Created by Brandon on 2/26/18.
//  Copyright © 2018 Dataglance. All rights reserved.
//

import UIKit
import NMessenger

protocol DGStreamChatOperationDelegate {
    func didFinishOperationWith(messageNode: MessageNode?)
}

class DGStreamChatOperation: Operation {
    
    var message: QBChatMessage!
    var delegate: DGStreamChatOperationDelegate!
    
    init(message: QBChatMessage, delegate: DGStreamChatOperationDelegate) {
        self.message = message
        self.delegate = delegate
    }

    override func main() {
        super.main()
        
        var isIncomingMessage:Bool = true
        if let user = DGStreamCore.instance.currentUser, let currentUserID = user.userID, message.senderID == currentUserID.uintValue {
            isIncomingMessage = false
        }
        
        if let isImage = message.customParameters["isImage"] as? String, isImage == "true" || isImage == "Optional(true)" {
            message.attachments?.forEach({ (attachment) in
                
                if let id = attachment.id, let attachmentID = UInt(id) {
                    
                    let protos = DGStreamManager.instance.dataSource.streamManager(DGStreamManager.instance, imagesWithID: id)
                    
                    let images = DGStreamImage.createDGStreamImagesFor(protocols: protos)
                    
                    if let storedImage = images.first, let storedImageData = storedImage.imageData, let image = UIImage(data: storedImageData) {
                        // LOAD FROM CORE DATA
                        self.delegate.didFinishOperationWith(messageNode: self.createNodeFrom(image: image, isIncoming: isIncomingMessage))
                    }
                    else {
                        // DOWNLOAD
                        QBRequest.downloadFile(withID: attachmentID, successBlock: { (response, data) in
                            if let image = UIImage(data: data) {
                                
                                let storeImage = DGStreamImage()
                                storeImage.imageData = data
                                storeImage.id = id
                                
                                DGStreamManager.instance.dataStore.streamManager(DGStreamManager.instance, store: storeImage)
                                
                                self.delegate.didFinishOperationWith(messageNode: self.createNodeFrom(image: image, isIncoming: isIncomingMessage))
            
                            }
                            else {
                                self.delegate.didFinishOperationWith(messageNode: nil)
                            }
                        }, statusBlock: { (request, status) in
                            
                        }, errorBlock: { (response) in
                            print(response.error?.error?.localizedDescription ?? "No Error")
                            self.delegate.didFinishOperationWith(messageNode: nil)
                        })
                    }
                    
                }
                else {
                    self.delegate.didFinishOperationWith(messageNode: nil)
                }
            })
        }
        else {
            let date = message.dateSent ?? message.createdAt
            var textMessage = ""
            if let date = date {
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .short
                dateFormatter.timeStyle = .short
                textMessage.append("\(dateFormatter.string(from: date)): ")
            }
            textMessage.append(message.text ?? "")
            let textNode = TextContentNode(textMessageString: textMessage)
            textNode.isIncomingMessage = isIncomingMessage
            textNode.incomingTextFont = UIFont(name: "HelveticaNeue-Bold", size: 14)!
            textNode.outgoingTextFont = UIFont(name: "HelveticaNeue-Bold", size: 14)!
            textNode.insets = UIEdgeInsetsMake(8, 8, 8, 8)
            textNode.incomingTextColor = .white
            textNode.bubbleConfiguration = DGStreamChatBubble()
            
            let messageNode = MessageNode(content: textNode)
            messageNode.isIncomingMessage = isIncomingMessage
            messageNode.messageOffset = 10
            messageNode.cellPadding = UIEdgeInsetsMake(5, 0, 5, 0)
            
            self.delegate.didFinishOperationWith(messageNode: messageNode)
        }
    
    }
    
    func createNodeFrom(image: UIImage, isIncoming: Bool) -> MessageNode {
        let imageNode = ImageContentNode(image: image)
        imageNode.imageMessageNode.contentMode = .scaleAspectFit
        imageNode.bubbleConfiguration = DGStreamChatImageBubble() as BubbleConfigurationProtocol
        
        let messageNode = MessageNode(content: imageNode)
        messageNode.isIncomingMessage = isIncoming
        messageNode.messageOffset = 10
        messageNode.cellPadding = UIEdgeInsetsMake(5, 0, 5, 0)
        
        return messageNode
    }
}
