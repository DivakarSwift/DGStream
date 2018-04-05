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
                    
                    QBRequest.downloadFile(withID: attachmentID, successBlock: { (response, data) in
                        if let image = UIImage(data: data) {
                            
                            let imageNode = ImageContentNode(image: image)
                            imageNode.imageMessageNode.contentMode = .scaleAspectFit
                            imageNode.bubbleConfiguration = DGStreamChatImageBubble() as BubbleConfigurationProtocol
                            
                            let messageNode = MessageNode(content: imageNode)
                            messageNode.isIncomingMessage = isIncomingMessage
                            messageNode.messageOffset = 10
                            messageNode.cellPadding = UIEdgeInsetsMake(5, 0, 5, 0)
                            
                            self.delegate.didFinishOperationWith(messageNode: messageNode)
                            
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
                else {
                    self.delegate.didFinishOperationWith(messageNode: nil)
                }
            })
        }
        else {
            
            let textNode = TextContentNode(textMessageString: message.text ?? "")
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
}
