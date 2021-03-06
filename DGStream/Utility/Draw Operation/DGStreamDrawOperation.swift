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
    var isUndo:Bool = false
    var increment:Int = 0
    
    init(fileID: String, currentUserID: NSNumber, toUserIDs: [NSNumber], isUndo: Bool, increment: Int, snapshot: UIImage) {
        super.init()
        self.fileID = fileID
        self.currentUserID = currentUserID
        self.toUserIDs = toUserIDs
        self.snapshot = snapshot
        self.isUndo = isUndo
        self.increment = increment
        //self.snapshot = self.imageWithImage(sourceImage: snapshot, scaledToWidth: UIScreen.main.bounds.size.width / 4)
    }
    
    func imageWithImage (sourceImage:UIImage, scaledToWidth: CGFloat) -> UIImage {
        let oldWidth = sourceImage.size.width
        let scaleFactor = scaledToWidth / oldWidth
        
        let newHeight = sourceImage.size.height * scaleFactor
        let newWidth = oldWidth * scaleFactor
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width:newWidth, height:newHeight), true, UIScreen.main.scale)
        sourceImage.draw(in: CGRect(x:0, y:0, width:newWidth, height:newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    override func main() {
        
        if let imageData = UIImagePNGRepresentation(snapshot) {
            QBRequest.tUploadFile(imageData, fileName: fileID, contentType: "image/png", isPublic: true, successBlock: { (response, blob) in
                
                let drawImageMessage = QBChatMessage()
                drawImageMessage.text = "drawImage"
                drawImageMessage.senderID = self.currentUserID.uintValue
                drawImageMessage.recipientID = self.toUserIDs.first?.uintValue ?? 0
                drawImageMessage.customParameters = ["isUndo": self.isUndo, "increment": self.increment]
                
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
        
    }

}
