//
//  DGStreamFullLayout.swift
//  DGStream
//
//  Created by Brandon on 9/15/17.
//  Copyright © 2017 Dataglance. All rights reserved.
//

import Foundation

class DGStreamFullLayout: UICollectionViewFlowLayout {
    
    // here you can define the height of each cell
    let itemHeight: CGFloat = UIScreen.main.bounds.size.height
    
    override init() {
        super.init()
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLayout()
    }
    
    /**
     Sets up the layout for the collectionView. 1pt distance between each cell and 1pt distance between each row plus use a vertical layout
     */
    func setupLayout() {
        minimumInteritemSpacing = 0
        minimumLineSpacing = 0
        scrollDirection = .horizontal
    }
    
    /// here we define the width of each cell, creating a 2 column layout. In case you would create 3 columns, change the number 2 to 3
    func itemWidth() -> CGFloat {
        return UIScreen.main.bounds.size.width
    }
    
    override var itemSize: CGSize {
        set {
            self.itemSize = CGSize(width: itemWidth(), height: itemHeight)
        }
        get {
            return CGSize(width: itemWidth(), height: itemHeight)
        }
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        return collectionView!.contentOffset
    }
}
