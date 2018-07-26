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
    var increment: Int = 0
    
    func addDrawing(snapshot: UIImage, fromCurrentUser: NSNumber, toUsers: [NSNumber], isUndo: Bool, withFileID fileID: String) {
        let drawOperation = DGStreamDrawOperation(fileID: fileID, currentUserID: fromCurrentUser, toUserIDs: toUsers, isUndo: isUndo, increment: self.increment, snapshot: snapshot)
        drawOperation.delegate = self
        drawOperations.append(drawOperation)
        loadNextDrawing()
//        if self.operationCount == 0 {
//            loadNextDrawing()
//        }
    }
    
    func loadNextDrawing() {
        increment += 1
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
        print(errorMessage)
        
    }
}
