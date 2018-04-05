//
//  DGStreamRecordingCollection.swift
//  DGStream
//
//  Created by Brandon on 2/20/18.
//  Copyright © 2018 Dataglance. All rights reserved.
//

import UIKit

class DGStreamRecordingCollection: NSObject {
    
    var thumbnail: Data?
    var title: String!
    var documentNumber: String!
    var numberOfRecordings: Int16!
    var createdDate: Date!
    var createdBy: NSNumber!
    
    class func createDGStreamRecordingCollectionsFrom(protocols: [DGStreamRecordingCollectionProtocol]) -> [DGStreamRecordingCollection] {
        var recordingCollections: [DGStreamRecordingCollection] = []
        for proto in protocols {
            let recordingCollection = DGStreamRecordingCollection()
            recordingCollection.createdBy = proto.dgCreatedBy
            recordingCollection.createdDate = proto.dgCreatedDate
            recordingCollection.documentNumber = proto.dgDocumentNumber
            recordingCollection.numberOfRecordings = proto.dgNumberOfRecordings
            recordingCollection.thumbnail = proto.dgThumbnail
            recordingCollection.title = proto.dgTitle
            recordingCollections.append(recordingCollection)
        }
        return recordingCollections
    }
    
}

extension DGStreamRecordingCollection: DGStreamRecordingCollectionProtocol {
    var dgDocumentNumber: String {
        get {
            return self.documentNumber
        }
        set {
            self.documentNumber = self.dgDocumentNumber
        }
    }
    
    var dgTitle: String {
        get {
            return self.title
        }
        set {
            self.title = self.dgTitle
        }
    }
    
    var dgNumberOfRecordings: Int16 {
        get {
            return self.numberOfRecordings
        }
        set {
            self.numberOfRecordings = self.dgNumberOfRecordings
        }
    }
    
    var dgThumbnail: Data? {
        get {
            return self.thumbnail
        }
        set {
            self.thumbnail = self.dgThumbnail
        }
    }
    
    var dgCreatedDate: Date {
        get {
            return self.createdDate
        }
        set {
            self.createdDate = self.dgCreatedDate
        }
    }
    
    var dgCreatedBy: NSNumber {
        get {
            return self.createdBy
        }
        set {
            self.createdBy = self.dgCreatedBy
        }
    }
    
    
}
