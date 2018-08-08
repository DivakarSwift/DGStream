//
//  DGStreamCollectionViewLayoutTable.swift
//  DGStream
//
//  Created by Brandon on 8/3/18.
//  Copyright © 2018 Dataglance. All rights reserved.
//

import UIKit

class DGStreamCollectionViewLayoutTable: UICollectionViewFlowLayout {
    
    private var isSetup = false
    
    override func prepare() {
        super.prepare()
        if !isSetup {
            setup()
            isSetup = true
        }
    }
    
    private func setup() {
        scrollDirection = .vertical
        minimumLineSpacing = 0
        itemSize = CGSize(width: collectionView!.bounds.width, height: 60)
        
        let inset:CGFloat = 0
        collectionView!.contentInset = .init(top: 0, left: inset, bottom: 0, right: inset)
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return false
    }

}
