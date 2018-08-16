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

public protocol DGStreamUserDetailProtocol {
    var dgTitle: String { get }
    var dgValue: String { get }
    var dgPriority: Int { get }
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
    var dgIsAudio: Bool { get }
    var dgDuration: Double { get }
}

public protocol DGStreamContactProtocol {
    var dgUserID: NSNumber { get }
}

public protocol DGStreamRecordingCollectionProtocol {
    var dgDocumentNumber: String { get }
    var dgTitle: String { get }
    var dgNumberOfRecordings: Int16 { get }
    var dgThumbnail: Data? { get }
    var dgCreatedDate: Date { get }
    var dgCreatedBy: NSNumber { get }
}

public protocol DGStreamRecordingProtocol {
    var dgDocumentNumber: String { get }
    var dgTitle: String { get }
    var dgURL: String { get }
    var dgThumbnail: Data? { get }
    var dgCreatedDate: Date { get }
    var dgCreatedBy: NSNumber { get }
    var dgIsPhoto: Bool { get }
}

public protocol DGStreamDocumentProtocol {
    var dgID: String { get }
    var dgTitle: String { get }
    var dgURL: String { get }
    var dgThumbnail: Data? { get }
    var dgCreatedDate: Date { get }
    var dgCreatedBy: NSNumber { get }
}

public protocol DGStreamImageProtocol {
    var dgID: String { get }
    var dgImageData: Data? { get }
}
