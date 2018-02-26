//
//  DGStreamRecordingCollectionsLayout.swift
//  DGStream
//
//  Created by Brandon on 2/20/18.
//  Copyright © 2018 Dataglance. All rights reserved.
//

import UIKit

class DGStreamRecordingCollectionsLayout: UICollectionViewLayout {
    
    var targetCenter:CGPoint?
    var stackCount: Int = 3
    var itemSize:CGSize = CGSize(width: 140, height: 140)
    var attributesArray:[UICollectionViewLayoutAttributes] = []
    
    static let iPadPadding:CGFloat = 20
    static let iPadNumberPerWidthLandscape:CGFloat = 6
    static let iPadNumberPerWidthPortrait:CGFloat = 4
    static let iPhonePadding:CGFloat = 20
    static let iPhoneNumberPerWidthLandscape:CGFloat = 4
    static let iPhoneNumberPerWidthPortrait:CGFloat = 2
    static let cornerRadius:CGFloat = 6
    let sizeDifferenceForAlbumThumbnailImages:CGFloat = {
        if Display.pad {
            return 8
        }
        else {
            return 14
        }
    }()
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func prepare() {
        super.prepare()
        let size = self.collectionView!.bounds.size
        
        var center:CGPoint
        if let targetCenter = self.targetCenter, targetCenter.x > 0 {
            center = targetCenter
        }
        else {
            center = CGPoint(x: size.width / 2.0, y: 60)
        }
        
        center = CGPoint(x: center.x, y: center.y + 2)
        
        // we only display one section in this layout (GET FROM COLLECTIONS COUNT)
        if let itemCount = self.collectionView?.numberOfItems(inSection: 0) {
            for i in 0..<itemCount {
                
                let attributes:UICollectionViewLayoutAttributes = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: i, section: 0))
                
                if i >= stackCount {
                    attributes.alpha = 0.0
                }
                else {
                    attributes.alpha = 1.0
                }
                
                switch i {
                    
                case 0:
                    
                    attributes.center = CGPoint(x: center.x, y: center.y + sizeDifferenceForAlbumThumbnailImages * 2)
                    attributes.size = itemSize;
                    
                    break
                    
                case 1:
                    
                    attributes.center = CGPoint(x: center.x, y: center.y + sizeDifferenceForAlbumThumbnailImages)
                    attributes.size = CGSize(width: itemSize.width - sizeDifferenceForAlbumThumbnailImages, height: itemSize.height - sizeDifferenceForAlbumThumbnailImages)
                    
                    break
                    
                case 2:
                    
                    attributes.center = center
                    attributes.size = CGSize(width: itemSize.width - sizeDifferenceForAlbumThumbnailImages * 2, height: itemSize.height - sizeDifferenceForAlbumThumbnailImages * 2)
                    
                    break
                    
                default: break
                    
                }
                attributes.zIndex = itemCount - i
                attributesArray.append(attributes)
            }
        }
    }
    
    override func invalidateLayout() {
        super.invalidateLayout()
        attributesArray.removeAll()
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        let bounds = self.collectionView?.bounds
        return newBounds.width != bounds?.width || newBounds.height != bounds?.height
    }
    
    override var collectionViewContentSize: CGSize {
        return self.collectionView!.bounds.size
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return attributesArray[indexPath.item]
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return attributesArray
    }
}

extension DGStreamRecordingCollectionsLayout {
    class func getLayout() -> UICollectionViewLayout {
        var cellPadding:CGFloat = 0
        var numberOfCells:CGFloat = 0
        if Display.pad {
            cellPadding = iPadPadding
            if UIApplication.shared.statusBarOrientation.isLandscape {
                numberOfCells = iPadNumberPerWidthLandscape
            }
            else {
                numberOfCells = iPadNumberPerWidthPortrait
            }
        }
        else {
            cellPadding = iPhonePadding
            if UIApplication.shared.statusBarOrientation.isLandscape {
                numberOfCells = iPhoneNumberPerWidthLandscape
            }
            else {
                numberOfCells = iPhoneNumberPerWidthPortrait
            }
        }
        let screenWidth = UIScreen.main.bounds.width - (cellPadding * 2)
        let layout = UICollectionViewFlowLayout()
        let hw = (screenWidth / numberOfCells) - cellPadding
        let size = CGSize(width: hw, height: hw + (hw * 0.25))
        layout.itemSize = size
        layout.minimumInteritemSpacing = cellPadding
        layout.minimumLineSpacing = cellPadding
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsetsMake(cellPadding, cellPadding, 0, cellPadding)
        return layout
    }
}
