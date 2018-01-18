//
//  DGStreamDrawOperation.swift
//  DGStream
//
//  Created by Brandon on 12/28/17.
//  Copyright © 2017 Dataglance. All rights reserved.
//

import UIKit
import Quickblox
import QuickbloxWebRTC

protocol DGStreamDrawOperationDelegate {
    func drawOperationDidFinish(operation: DGStreamDrawOperation)
    func drawOperationFailedWith(errorMessage: String)
}

class DGStreamDrawOperation: Operation {
    
    var delegate: DGStreamDrawOperationDelegate!
    var fileID: String!
    var currentUserID: NSNumber!
    var toUserIDs:[NSNumber]!
    var snapshot: UIImage!
    
    init(fileID: String, currentUserID: NSNumber, toUserIDs: [NSNumber], snapshot: UIImage) {
        self.fileID = fileID
        self.currentUserID = currentUserID
        self.toUserIDs = toUserIDs
        self.snapshot = snapshot
    }
    
    override func main() {
        
        if let imageData = UIImagePNGRepresentation(snapshot) {
            QBRequest.tUploadFile(imageData, fileName: fileID, contentType: "image/png", isPublic: true, successBlock: { (response, blob) in
                
                let drawImageMessage = QBChatMessage()
                drawImageMessage.text = "drawImage"
                drawImageMessage.senderID = self.currentUserID.uintValue
                drawImageMessage.recipientID = self.toUserIDs.first?.uintValue ?? 0
                
                let uploadedFileID: UInt = blob.id
                let attachment: QBChatAttachment = QBChatAttachment()
                attachment.type = "image"
                attachment.id = String(uploadedFileID)
                drawImageMessage.attachments = [attachment]
                
                QBChat.instance.sendSystemMessage(drawImageMessage, completion: { (error) in
                    print("Sent Freeze System Message With \(error?.localizedDescription ?? "No Error")")
                    self.delegate.drawOperationDidFinish(operation: self)
                })
                
            }, statusBlock: { (request, status) in
                
            }, errorBlock: { (response) in
                self.delegate.drawOperationFailedWith(errorMessage: "No Image")
            })
        }
        
//        let frozenImage = QBCOCustomObject()
//        frozenImage.className = "DrawImage"
//        frozenImage.createdAt = Date()
//        frozenImage.userID = currentUserID.uintValue
//        frozenImage.id = fileID
//
//        let imageFile = QBCOFile()
//        if let imageData = UIImagePNGRepresentation(snapshot) {
//
//            imageFile.contentType = "image/png"
//            imageFile.data = imageData
//            imageFile.name = "image"
//
//            let fields:NSMutableDictionary = NSMutableDictionary()
//            fields.setObject(imageFile, forKey: "image" as NSCopying)
//
//            frozenImage.fields = fields
//        }
//        else {
//            self.delegate.drawOperationFailedWith(errorMessage: "No Image")
//            return
//        }
//
//        QBRequest.createObject(frozenImage, successBlock: { (response, object) in
//
//            QBRequest.uploadFile(imageFile, className: "DrawImage", objectID: object?.id ?? "", fileFieldName: "image", successBlock: { (response, uploadInfo) in
//
//                if response.isSuccess, let object = object, let objectID = object.id {
//                    print("Uploaded File")
//                    DGStreamNotification.drawImage(with: objectID, from: self.currentUserID, to: self.toUserIDs, with: { (success, errorMessage) in
//                        print("drawImage \(success) \(errorMessage ?? "No Error")")
//                        if success {
//                            self.delegate.drawOperationDidFinish(operation: self)
//                        }
//                        else {
//                            self.delegate.drawOperationFailedWith(errorMessage: "Failed To Send Draw Notification")
//                        }
//                    })
//                }
//                else if let responseError = response.error, let error = responseError.error {
//                    print("Upload Failed with error \(error.localizedDescription)")
//                    self.delegate.drawOperationFailedWith(errorMessage: "Failed To Create Image Object")
//                }
//                else {
//                    self.delegate.drawOperationFailedWith(errorMessage: "Failed To Create Image Object")
//                }
//
//            }, statusBlock: { (response, status) in
//
//            }, errorBlock: { (error) in
//                print("DID FAIL TO UPLOAD IMAGE \(error.error?.error?.localizedDescription ?? "ERROR")")
//                self.delegate.drawOperationFailedWith(errorMessage: "Failed To Upload Image")
//            })
//
//        }, errorBlock: { (response) in
//            if let responseError = response.error, let error = responseError.error {
//                print("Upload Failed with error \(error.localizedDescription)")
//            }
//            self.delegate.drawOperationFailedWith(errorMessage: "Failed To Create Image Object")
//        })
        
    }

}
