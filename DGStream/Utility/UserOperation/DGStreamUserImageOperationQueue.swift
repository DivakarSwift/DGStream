//
//  DGStreamUserImageOperationQueue.swift
//  DGStream
//
//  Created by Brandon on 3/12/18.
//  Copyright © 2018 Dataglance. All rights reserved.
//

import UIKit

typealias UserImageOperationQueueCompletion = (_ success: Bool, _ errorMessage: String, _ users: [DGStreamUser]) -> Void

class DGStreamUserImageOperationQueue: OperationQueue {
    
    var users:[DGStreamUser] = []
    var imageUsers:[DGStreamUser] = []
    var completion:UserImageOperationQueueCompletion?
    
    init(users: [DGStreamUser], completion: @escaping UserImageOperationQueueCompletion) {
        super.init()
        self.users = users
        self.completion = completion
        loadNextUser()
    }
    
    func loadNextUser() {
        if let nextUser = self.users.first, let index = self.users.index(of: nextUser) {
            self.users.remove(at: index)
            self.addOperation(DGStreamUserImageOperation(user: nextUser, delegate: self))
        }
        else if let completion = self.completion {
            completion(true, "", self.imageUsers)
            self.completion = nil
        }
    }

}

extension DGStreamUserImageOperationQueue: DGStreamUserImageOperationDelegate {
    func userImageOperationDidFinish(user: DGStreamUser) {
        imageUsers.append(user)
        loadNextUser()
    }
}
