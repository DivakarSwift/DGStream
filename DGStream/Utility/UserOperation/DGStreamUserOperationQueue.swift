//
//  DGStreamUserOperationQueue.swift
//  DGStream
//
//  Created by Brandon on 9/13/17.
//  Copyright © 2017 Dataglance. All rights reserved.
//

import UIKit
import Quickblox
import QuickbloxWebRTC

typealias UserOperationQueueCompletion = (_ success: Bool, _ errorMessage: String, _ users: [DGStreamUser]) -> Void

class DGStreamUserOperationQueue: OperationQueue {
    
    var tags:[String] = []
    var users: [DGStreamUser] = []
    var currentPage:UInt = 0
    var completion: UserOperationQueueCompletion?
    

    func getUsersWith(tags: [String], completion: @escaping UserOperationQueueCompletion) {
        self.completion = completion
        self.tags = tags
        loadNextPage()
    }
    
    func loadNextPage() {
        currentPage += 1
        let nextPage = QBGeneralResponsePage(currentPage: currentPage, perPage: 10)
        let operation = DGStreamUserOperation(tags: self.tags, page: nextPage, delegate: self)
        addOperation(operation)
    }
}

extension DGStreamUserOperationQueue: DGStreamUserOperationDelegate {
    func userOperationDidFinishPageWith(users: [DGStreamUser]) {
        self.users.append(contentsOf: users)
        loadNextPage()
    }
    func userOperationDidFinishLastPageWith(users: [DGStreamUser]) {
        if let completion = self.completion {
            self.users.append(contentsOf: users)
            completion(true, "", self.users)
            self.completion = nil
        }
    }
    func userOperationFailedWith(errorMessage: String) {
        if let completion = self.completion {
            completion(false, errorMessage, [])
            self.completion = nil
        }
    }
}
