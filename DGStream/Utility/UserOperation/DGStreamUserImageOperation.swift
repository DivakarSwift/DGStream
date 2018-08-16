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

let demoDetails1:[DGStreamUserDetail] = [DGStreamUserDetail(title: "Title:", value: "Technician", priority: 1),
                                         DGStreamUserDetail(title: "Facility:", value: "Simpson Nuclear Plant", priority: 3),
                                         DGStreamUserDetail(title: "Group:", value: "Electrical", priority: 2),
                                         DGStreamUserDetail(title: "Emp ID:", value: "0016", priority: 4),
                                         DGStreamUserDetail(title: "Supervisor:", value: "Ashok", priority: 5)]

let demoDetails2:[DGStreamUserDetail] = [DGStreamUserDetail(title: "Title:", value: "Master Engineer", priority: 1),
                                         DGStreamUserDetail(title: "Facility:", value: "Smith Power Plant", priority: 3),
                                         DGStreamUserDetail(title: "Group:", value: "Engineering", priority: 2),
                                         DGStreamUserDetail(title: "Clearance:", value: "YES", priority: 4),
                                         DGStreamUserDetail(title: "Supervisor:", value: "Ashok", priority: 5)]

let demoDetails3:[DGStreamUserDetail] = [DGStreamUserDetail(title: "Title:", value: "Analyst", priority: 1),
                                         DGStreamUserDetail(title: "Facility:", value: "Marine Platform 12", priority: 3),
                                         DGStreamUserDetail(title: "Group:", value: "Research", priority: 2)]

class DGStreamUserImageOperation: Operation {
    
    var user:DGStreamUser!
    var delegate:DGStreamUserImageOperationDelegate!
    
    init(user: DGStreamUser, delegate: DGStreamUserImageOperationDelegate) {
        super.init()
        self.user = user
        self.delegate = delegate
        
        let rand = arc4random_uniform(10)
        if rand % 2 == 0 {
            self.user.details = demoDetails1
        }
        else if rand % 3 == 0 {
            self.user.details = demoDetails2
        }
        else {
            self.user.details = demoDetails3
        }
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
