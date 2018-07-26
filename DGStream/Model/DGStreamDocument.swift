//
//  DGStreamDocument.swift
//  DGStream
//
//  Created by Brandon on 7/5/18.
//  Copyright © 2018 Dataglance. All rights reserved.
//

import UIKit
import PDFKit

class DGStreamDocument: NSObject {

    var id: String?
    var title: String?
    var url: String?
    var thumbnail: Data?
    var createdDate: Date?
    var createdBy: NSNumber?
    
    class func createDGStreamDocumentFrom(pdfData: Data, fileID: String, createdBy: NSNumber, title: String) -> DGStreamDocument? {
        
        if #available(iOS 11.0, *) {
            var path = DGStreamFileManager.applicationDocumentsDirectory()
            path.appendPathComponent(fileID)
            path.appendPathExtension("pdf")
            do {
                try pdfData.write(to: path)
            }
            catch let error {
                print("COULD NOT WRITE PDF TO PATH \(error.localizedDescription)")
            }
        }
        
        let document = DGStreamDocument()
        document.id = fileID
        document.createdBy = createdBy
        document.createdDate = Date()
        document.title = title
        document.url = "\(fileID).pdf"
        
        return document
    }
    
    class func createDGStreamDocumentsFor(protocols: [DGStreamRecordingProtocol]) -> [DGStreamDocument] {
        var documents:[DGStreamDocument] = []
        for proto in protocols {
            let document = DGStreamDocument()
            document.thumbnail = proto.dgThumbnail
            document.createdBy = proto.dgCreatedBy
            document.createdDate = proto.dgCreatedDate
            document.title = proto.dgTitle
            document.url = proto.dgURL
            documents.append(document)
        }
        return documents
    }
    
    func pdfData() -> Data? {
        if #available(iOS 11.0, *) {
            let docDir = DGStreamFileManager.applicationDocumentsDirectory()
            let documentURL = docDir.appendingPathComponent(self.id!).appendingPathExtension("pdf")
            if let pdf = PDFDocument(url: documentURL) {
                return pdf.dataRepresentation()
            }
        }
        return nil
    }
    
}

extension DGStreamDocument: DGStreamDocumentProtocol {
//    var dgDocumentNumber: String {
//        get {
//            return self.documentNumber ?? ""
//        }
//        set {
//            self.documentNumber = self.dgDocumentNumber
//        }
//    }
    
    var dgID: String {
        get {
            return self.id ?? ""
        }
        set {
            self.id = self.dgID
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
