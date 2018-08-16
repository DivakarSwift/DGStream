//
//  DGStreamUserDetailsFlowLayout.swift
//  DGStream
//
//  Created by Brandon on 8/14/18.
//  Copyright © 2018 Dataglance. All rights reserved.
//

import UIKit

class DGStreamUserDetailsFlowLayout: UICollectionViewFlowLayout {

    private var isSetup = false
    
    override func prepare() {
        super.prepare()
        if !isSetup {
            setup()
            isSetup = true
        }
    }
    
    private func setup() {
        scrollDirection = .horizontal
        minimumLineSpacing = 0
        itemSize = CGSize(width: collectionView?.bounds.width ?? 0, height: 50)
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
}
