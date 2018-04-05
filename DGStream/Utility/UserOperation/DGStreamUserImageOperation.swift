//
//  DGStreamUserImageOperation.swift
//  DGStream
//
//  Created by Brandon on 3/12/18.
//  Copyright © 2018 Dataglance. All rights reserved.
//

import UIKit

protocol DGStreamUserImageOperationDelegate {
    func userImageOperationDidFinish(user: DGStreamUser)
}

class DGStreamUserImageOperation: Operation {
    
    var user:DGStreamUser!
    var delegate:DGStreamUserImageOperationDelegate!
    
    init(user: DGStreamUser, delegate: DGStreamUserImageOperationDelegate) {
        super.init()
        self.user = user
        self.delegate = delegate
    }
    
    override func main() {
        
        if let userID = self.user.userID {
            
            let extendedRequest = NSMutableDictionary()
            extendedRequest.setObject(userID.uintValue, forKey: "user_id" as NSCopying)
            
            QBRequest.objects(withClassName: "UserImage", extendedRequest: extendedRequest, successBlock: { (response, objects, responsePage) in
                
                if let objects = objects, let object = objects.first, let objectID = object.id {
                    
                    QBRequest.downloadFile(fromClassName: "UserImage", objectID: objectID, fileFieldName: "image", successBlock: { (response, data) in
                        self.user.image = data
                        
                        if let currentUser = DGStreamCore.instance.currentUser,
                            let currentUserID = currentUser.userID, userID == currentUserID {
                            DGStreamCore.instance.currentUser = self.user
                        }
                        
                        self.delegate.userImageOperationDidFinish(user: self.user)
                    }, statusBlock: { (statusRequest, requestStatus) in
                        
                    }, errorBlock: { (errorResponse) in
                        self.delegate.userImageOperationDidFinish(user: self.user)
                    })
                    
                }
                else {
                    self.delegate.userImageOperationDidFinish(user: self.user)
                }
                
            }, errorBlock: { (response) in
                self.delegate.userImageOperationDidFinish(user: self.user)
            })
        }
    
    }

}
