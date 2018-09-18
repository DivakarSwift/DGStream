//
//  DGStreamDocumentView.swift
//  DGStream
//
//  Created by Brandon on 7/5/18.
//  Copyright © 2018 Dataglance. All rights reserved.
//

import UIKit
import PDFKit

class DGStreamDocumentView: UIView {
    
    var data: Data!
    var lastIndexSent: Int = 0
    var increment: Int = 0
    var recipientID: NSNumber!
    var shouldBroadcastPageChange: Bool = true
    var shouldBroadcastPageSelection: Bool = true

    func configureIn(container: UIView, pdfData: Data, recipientID: NSNumber) {
        self.boundInside(container: container)
        self.data = pdfData
        self.recipientID = recipientID
        self.setUpPDFView()
    }
    
    func deconfigure() {
        if #available(iOS 11.0, *) {
            NotificationCenter.default.removeObserver(self, name: Notification.Name.PDFViewPageChanged, object: nil)
        }
    }
    
    func setUpPDFView() {
        if #available(iOS 11.0, *) {
            let document = PDFDocument(data: self.data)
            document?.delegate = self
            let pdfView = PDFView(frame: self.bounds)
            pdfView.document = document
            pdfView.autoScales = true
            pdfView.displayDirection = .horizontal
            pdfView.displayMode = .singlePage
            pdfView.usePageViewController(true, withViewOptions: nil)
            pdfView.boundInside(container: self)
            pdfView.delegate = self
            DispatchQueue.main.async {
                pdfView.alpha = 1.0
                pdfView.layoutDocumentView()
                pdfView.backgroundColor = .black
                //pdfView.goToFirstPage(nil)
            }
            
            NotificationCenter.default.addObserver(forName: Notification.Name.PDFViewPageChanged, object: nil, queue: .main) { (notification) in
                
                if !self.shouldBroadcastPageChange {
                    return
                }
                
                guard let docView = notification.object as? PDFView, let currentPage = docView.currentPage, let pageRef = currentPage.pageRef else {
                    return
                }
                
                self.increment += 1
                
                let currentPageNumber = pageRef.pageNumber - 1 // -1 for index
                
                print("Broadcast - Current Page Number \(currentPageNumber)")
                let pageMessage = QBChatMessage()
                pageMessage.text = "pageChange"
                pageMessage.senderID = DGStreamCore.instance.currentUser?.userID?.uintValue ?? 0
                pageMessage.recipientID = self.recipientID.uintValue
                pageMessage.customParameters = ["index": currentPageNumber, "increment": self.increment]
                QBChat.instance.sendSystemMessage(pageMessage, completion: { (error) in
                    
                })
                
            }
            
//            NotificationCenter.default.addObserver(forName: Notification.Name.PDFViewSelectionChanged, object: nil, queue: .main) { (notification) in
//
//                if !self.shouldBroadcastPageSelection {
//                    return
//                }
//
//                guard let docView = notification.object as? PDFView, let currentSelection = docView.currentSelection, let string = currentSelection.string else {
//                    return
//                }
//
//                self.increment += 1
////
////                print("Broadcast - Current Page Number \(currentPageNumber)")
//                let pageMessage = QBChatMessage()
//                pageMessage.text = "pageSelection"
//                pageMessage.senderID = DGStreamCore.instance.currentUser?.userID?.uintValue ?? 0
//                pageMessage.recipientID = self.recipientID.uintValue
//                pageMessage.customParameters = ["string": string, "increment": self.increment]
//                QBChat.instance.sendSystemMessage(pageMessage, completion: { (error) in
//
//                })
//                
//            }
        }
    }
    
    func goToPage(index: Int) {
        for subview in self.subviews {
            if #available(iOS 11.0, *) {
                guard let pdfView = subview as? PDFView, let document = pdfView.document, let page = document.page(at: index), let pageRef = page.pageRef, pageRef.pageNumber != index else {
                    continue
                }
                pdfView.isUserInteractionEnabled = false
                shouldBroadcastPageChange = false
                pdfView.go(to: page)
                shouldBroadcastPageChange = true
                pdfView.isUserInteractionEnabled = true
                break
            }
            
        }
    }
    
    func goToPage(selection: String) {
        for subview in self.subviews {
            if #available(iOS 11.0, *) {
                guard let pdfView = subview as? PDFView, let document = pdfView.document, let page = pdfView.currentPage else {
                    continue
                }
                pdfView.isUserInteractionEnabled = false
                shouldBroadcastPageChange = false
                pdfView.clearSelection()
                if document.isFinding {
                    document.cancelFindString()
                }
                document.findString(selection, withOptions: .caseInsensitive)
                shouldBroadcastPageChange = true
                pdfView.isUserInteractionEnabled = true
                break
            }
            
        }
    }

}

@available(iOS 11.0, *)
extension DGStreamDocumentView: PDFViewDelegate, PDFDocumentDelegate {
    func pdfViewPerformGo(toPage sender: PDFView) {
        guard let page = sender.currentPage else {
            print("NO PAGE")
            return
        }
        print("\(page)")
        
    }
    func didMatchString(_ instance: PDFSelection) {
        for subview in self.subviews {
            guard let pdfView = subview as? PDFView else {
                continue
            }
            pdfView.setCurrentSelection(instance, animate: true)
        }
    }
}
