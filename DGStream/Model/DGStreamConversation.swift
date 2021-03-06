//
//  DGStreamChatConversation.swift
//  DGStream
//
//  Created by Brandon on 10/18/17.
//  Copyright © 2017 Dataglance. All rights reserved.
//

import UIKit

public enum DGStreamConversationType: Int {
    case privateConversation = 0
    case groupConversation = 1
    case callConversation = 2
}

class DGStreamConversation: NSObject {
    var userIDs:[NSNumber]!
    var conversationID: String!
    var type: DGStreamConversationType!
    
    class func createDGStreamConversationsFrom(protocols: [DGStreamConversationProtocol]) -> [DGStreamConversation] {
        var conversations:[DGStreamConversation] = []
        for proto in protocols {
            conversations.append(DGStreamConversation.createDGStreamConversationFrom(proto: proto))
        }
        return conversations
    }
    
    class func createDGStreamConversationFrom(proto: DGStreamConversationProtocol) -> DGStreamConversation {
        let conversation = DGStreamConversation()
        conversation.conversationID = proto.dgConversationID
        conversation.type = proto.dgConversationType
        conversation.userIDs = proto.dgUserIDs
        return conversation
    }
    
    class func createDGStreamConversationsFrom(chatDialogs: [QBChatDialog]) -> [DGStreamConversation] {
        var conversations:[DGStreamConversation] = []
        for chatDialog in chatDialogs {
            let conversation = DGStreamConversation()
            conversation.conversationID = chatDialog.id!
            if chatDialog.type == .group {
                conversation.type = .groupConversation
            }
            else {
                conversation.type = .privateConversation
            }
            var userIDs:[NSNumber] = []
            if let occupantsIDs = chatDialog.occupantIDs {
                for occupantID in occupantsIDs {
                    userIDs.append(occupantID)
                }
            }
            conversation.userIDs = userIDs
            conversations.append(conversation)
        }
        return conversations
    }
}

extension DGStreamConversation: DGStreamConversationProtocol {
    var dgConversationID: String {
        get {
            return self.conversationID
        }
        set {
            self.dgConversationID = self.conversationID
        }
    }
    
    var dgUserIDs: [NSNumber] {
        get {
            return self.userIDs
        }
        set {
            self.userIDs = self.dgUserIDs
        }
    }
    
    var dgID: String {
        get {
            return self.conversationID
        }
        set {
            self.dgID = self.conversationID
        }
    }
    
    var dgConversationType: DGStreamConversationType {
        get {
            return self.type
        }
        set {
            self.dgConversationType = self.type
        }
    }
}
