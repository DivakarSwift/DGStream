//
//  DGStreamUserOperation.swift
//  DGStream
//
//  Created by Brandon on 9/13/17.
//  Copyright © 2017 Dataglance. All rights reserved.
//

import UIKit
import Quickblox
import QuickbloxWebRTC

protocol DGStreamUserOperationDelegate {
    func userOperationDidFinishPageWith(users: [DGStreamUser])
    func userOperationDidFinishLastPageWith(users: [DGStreamUser])
    func userOperationFailedWith(errorMessage: String)
}

class DGStreamUserOperation: Operation {
    
    var delegate: DGStreamUserOperationDelegate!
    var tags:[String]!
    var page:QBGeneralResponsePage!
    
    init(tags: [String], page: QBGeneralResponsePage, delegate: DGStreamUserOperationDelegate) {
        self.tags = tags
        self.page = page
        self.delegate = delegate
    }
    
    override func main() {
        QBRequest.users(withTags: self.tags, page: self.page, successBlock: { (response, page, users) in
            if !self.isCancelled, response.isSuccess {
                
                page.currentPage += 1

                if page.currentPage * page.perPage >= page.totalEntries {
                    // Last page
                    self.delegate.userOperationDidFinishLastPageWith(users: DGStreamUser.usersFrom(users: users))
                }
                else {
                    self.delegate.userOperationDidFinishPageWith(users: DGStreamUser.usersFrom(users: users))
                }
                
            }
            else {
                self.delegate.userOperationDidFinishPageWith(users: [])
            }
        }) { (response) in

            var errorMessage = "Error"
            
            let status = response.status
            if status == .badRequest {
                errorMessage = "Bad Request"
            }
            else if status == .cancelled {
                errorMessage = "Cancelled"
            }
            else if status == .forbidden {
                errorMessage = "Forbidden"
            }
            else if status == .notFound {
                errorMessage = "Not Found"
            }
            else if status == .serverError {
                errorMessage = "Server Error"
            }
            else if status == .unAuthorized {
                errorMessage = "Unauthorized"
            }
            else if status == .unknown {
                errorMessage = "Unknown Error"
            }
            else if status == .validationFailed {
                errorMessage = "Validation Failed"
            }
            else {
                errorMessage = "Unknown Error \(status.rawValue)"
            }
            
            self.delegate.userOperationFailedWith(errorMessage: errorMessage)
        }
    }
    
}
