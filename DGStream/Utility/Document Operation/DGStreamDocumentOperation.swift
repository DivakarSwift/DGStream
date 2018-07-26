//
//  DGStreamDocumentOperation.swift
//  DGStream
//
//  Created by Brandon on 7/5/18.
//  Copyright © 2018 Dataglance. All rights reserved.
//

import UIKit

typealias DocumentOperationCompletion = (_ success: Bool, _ errorMessage: String) -> Void

class DGStreamDocumentOperation: NSObject {
    
    var fileID: String!
    var pdfData: Data!
    var currentUserID: NSNumber!
    var sendToUserID: NSNumber!

    init(fileID: String, pdfData: Data, currentUserID: NSNumber, sendToUserID: NSNumber) {
        self.fileID = fileID
        self.pdfData = pdfData
        self.currentUserID = currentUserID
        self.sendToUserID = sendToUserID
    }
    
    func sendPDFWith(completion: @escaping DocumentOperationCompletion) {
        QBRequest.tUploadFile(self.pdfData, fileName: self.fileID, contentType: "application/pdf", isPublic: true, successBlock: { (response, blob) in
            
            let documentShareMessage = QBChatMessage()
            documentShareMessage.text = "documentShare"
            documentShareMessage.senderID = self.currentUserID.uintValue
            documentShareMessage.recipientID = self.sendToUserID.uintValue
            
            let uploadedFileID: UInt = blob.id
            let attachment: QBChatAttachment = QBChatAttachment()
            attachment.type = "application/pdf"
            attachment.id = String(uploadedFileID)
            documentShareMessage.attachments = [attachment]
            
            QBChat.instance.sendSystemMessage(documentShareMessage, completion: { (error) in
                print("Sent Document Share Message With \(error?.localizedDescription ?? "No Error")")
            })
            
            completion(true, "")
            
        }, statusBlock: { (request, status) in
            
        }, errorBlock: { (response) in
            completion(false, "")
        })
    }
    
}
