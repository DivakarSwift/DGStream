//
//  DGStreamChatOperationQueue.swift
//  DGStream
//
//  Created by Brandon on 2/26/18.
//  Copyright © 2018 Dataglance. All rights reserved.
//

import UIKit
import NMessenger

typealias ChatOperationQueueCompletion = (_ messageNodes: [MessageNode]) -> Void

class DGStreamChatOperationQueue: OperationQueue {
    
    var messages: [QBChatMessage] = []
    var messageNodes:[MessageNode] = []
    var completion: ChatOperationQueueCompletion!
    
    func getMessageNodesFor(messages: [QBChatMessage], with completion: @escaping ChatOperationQueueCompletion) {
        self.completion = completion
        self.messages = messages
        self.loadNextMessage()
    }
    
    func loadNextMessage() {
        if let nextMessage = self.messages.first, let index = self.messages.index(of: nextMessage) {
            self.messages.remove(at: index)
            self.addOperation(DGStreamChatOperation(message: nextMessage, delegate: self))
        }
        else if let completion = self.completion {
            completion(self.messageNodes)
            self.completion = nil
        }
    }

}

extension DGStreamChatOperationQueue: DGStreamChatOperationDelegate {
    func didFinishOperationWith(messageNode: MessageNode?) {
        if let node = messageNode {
            self.messageNodes.append(node)
        }
        loadNextMessage()
    }
}
