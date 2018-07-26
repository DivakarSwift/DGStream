//
//  DGStreamImage.swift
//  DGStream
//
//  Created by Brandon on 7/20/18.
//  Copyright © 2018 Dataglance. All rights reserved.
//

import UIKit

class DGStreamImage: NSObject {
    
    var id: String?
    var imageData: Data?

    class func createDGStreamImagesFor(protocols: [DGStreamImageProtocol]) -> [DGStreamImage] {
        var images:[DGStreamImage] = []
        for proto in protocols {
            let image = DGStreamImage()
            image.imageData = proto.dgImageData
            image.id = proto.dgID
            images.append(image)
        }
        return images
    }
    
}

extension DGStreamImage: DGStreamImageProtocol {
    var dgImageData: Data? {
        get {
            return self.imageData
        }
        set {
            self.imageData = self.dgImageData
        }
    }
    
    
    var dgID: String {
        get {
            return self.id ?? ""
        }
        set {
            self.id = self.dgID
        }
    }
    
}


