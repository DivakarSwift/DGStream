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

    func configureIn(container: UIView, pdfData: Data) {
        self.boundInside(container: container)
        self.data = pdfData
        self.setUpPDFView()
    }
    
    func setUpPDFView() {
        if #available(iOS 11.0, *) {
            let document = PDFDocument(data: self.data)
            let pdfView = PDFView(frame: self.bounds)
            pdfView.document = document
            pdfView.autoScales = true
            pdfView.displayDirection = .horizontal
            pdfView.boundInside(container: self)
            DispatchQueue.main.async {
                pdfView.alpha = 1.0
                pdfView.layoutDocumentView()
                pdfView.backgroundColor = .black
                pdfView.goToFirstPage(nil)
            }
        }
    }

}
