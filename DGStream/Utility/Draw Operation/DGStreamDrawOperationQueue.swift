//
//  DGStreamDrawOperationQueue.swift
//  DGStream
//
//  Created by Brandon on 12/28/17.
//  Copyright © 2017 Dataglance. All rights reserved.
//

import UIKit

typealias DrawOperationQueueCompletion = (_ success: Bool, _ errorMessage: String) -> Void

class DGStreamDrawOperationQueue: OperationQueue {
    
    var drawOperations:[DGStreamDrawOperation] = []
    var completion: DrawOperationQueueCompletion?
    
    func addDrawing(snapshot: UIImage, fromCurrentUser: NSNumber, toUsers: [NSNumber], withFileID fileID: String) {
        let drawOperation = DGStreamDrawOperation(fileID: fileID, currentUserID: fromCurrentUser, toUserIDs: toUsers, snapshot: snapshot)
        drawOperation.delegate = self
        drawOperations.append(drawOperation)
        if self.operationCount == 0 {
            loadNextDrawing()
        }
    }
    
    func loadNextDrawing() {
        if let drawing = drawOperations.popLast() {
            addOperation(drawing)
        }
        else {
            if let completion = self.completion {
                completion(true, "")
                self.completion = nil
            }
        }
    }

}

extension DGStreamDrawOperationQueue: DGStreamDrawOperationDelegate {
    func drawOperationDidFinish(operation: DGStreamDrawOperation) {
        if let index = self.drawOperations.index(of: operation) {
            self.drawOperations.remove(at: index)
        }
        loadNextDrawing()
    }
    func drawOperationFailedWith(errorMessage: String) {
        print("FAILED TO DRAW!")
        
    }
}
