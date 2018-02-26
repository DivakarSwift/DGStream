//
//  DGStreamRecording.swift
//  DGStream
//
//  Created by Brandon on 2/20/18.
//  Copyright © 2018 Dataglance. All rights reserved.
//

import UIKit

class DGStreamRecording: NSObject {
    
    var documentNumber: String?
    var createdDate: Date?
    var createdBy: NSNumber?
    var title: String?
    var url: String?
    var thumbnail: Data?
    
    class func createDGStreamRecordingsFor(protocols: [DGStreamRecordingProtocol]) -> [DGStreamRecording] {
        var recordings:[DGStreamRecording] = []
        for proto in protocols {
            let record = DGStreamRecording()
            record.documentNumber = proto.dgDocumentNumber
            record.thumbnail = proto.dgThumbnail
            record.createdBy = proto.dgCreatedBy
            record.createdDate = proto.dgCreatedDate
            record.title = proto.dgTitle
            record.url = proto.dgURL
            recordings.append(record)
        }
        return recordings
    }
    
}

extension DGStreamRecording: DGStreamRecordingProtocol {
    var dgDocumentNumber: String {
        get {
            return self.documentNumber ?? ""
        }
        set {
            self.documentNumber = self.dgDocumentNumber
        }
    }
    
    var dgTitle: String {
        get {
            return self.title ?? ""
        }
        set {
            self.title = self.dgTitle
        }
    }
    
    var dgURL: String {
        get {
            return self.url ?? ""
        }
        set {
            self.url = self.dgURL
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
            return self.createdDate ?? Date()
        }
        set {
            self.createdDate = self.dgCreatedDate
        }
    }
    
    var dgCreatedBy: NSNumber {
        get {
            return self.createdBy ?? 0
        }
        set {
            self.createdBy = self.dgCreatedBy
        }
    }
    
    
}
