//
//  DGStreamProtocols.swift
//  DGStream
//
//  Created by Brandon on 9/8/17.
//  Copyright © 2017 Dataglance. All rights reserved.
//

import UIKit

public protocol DGStreamUserProtocol {
    var dgUsername: String { get }
    var dgUserID: NSNumber { get }
    var dgID: String { get }
    var dgImage: Data? { get }
}

public protocol DGStreamConversationProtocol {
    var dgConversationID: String { get }
    var dgUserIDs: [NSNumber] { get }
    var dgConversationType: DGStreamConversationType { get }
}

public protocol DGStreamMessageProtocol {
    var dgConversationID: String { get }
    var dgSenderID: NSNumber { get }
    var dgReceiverID: NSNumber { get }
    var dgMessage: String { get }
    var dgMessageID: String { get }
    var dgDelivered: Date { get }
}

public protocol DGStreamRecentProtocol {
    var dgID: String { get }
    var dgSenderID: NSNumber { get }
    var dgReceiverID: NSNumber { get }
    var dgDate: Date { get }
    var dgIsMissed: Bool { get }
}

public protocol DGStreamContactProtocol {
    var dgUserID: NSNumber { get }
}
