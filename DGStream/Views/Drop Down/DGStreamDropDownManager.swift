//
//  DGStreamDropDownManager.swift
//  DGStream
//
//  Created by Brandon on 12/4/17.
//  Copyright © 2017 Dataglance. All rights reserved.
//

import UIKit

protocol DGStreamDropDownManagerDelegate {
    func dropDownManager(manager: DGStreamDropDownManager, sizeSelected size: String, index: Int)
    func dropDownManager(manager: DGStreamDropDownManager, colorSelected color: UIColor, index: Int)
    func dropDownManager(manager: DGStreamDropDownManager, stampSelected stamp: String)
}

class DGStreamDropDownManager: NSObject {
    
    let sizes:[String] = ["8", "12", "14", "18", "22", "26", "30", "34", "38", "42"]
    let colors:[UIColor] = [.black, .white, .gray, .red, .blue, .green, .yellow, .orange, .purple]
    let stamps:[String] = ["⟵", "⟷", "↰", "↱", "☐", "○", "△", "◇", "✔︎", "✘", "★", "❤︎", "Ω", "∞", "∅", "⊖", "✌︎", "✂︎", "⚑", "☉"]
    
    var selectedSizeIndex:Int = 0
    var selectedColorIndex:Int = 0
    
    var dropDownContainer: UIView!
    
    var collectionView: UICollectionView?
    
    var type: DGStreamDropDownType = DGStreamDropDownType(rawValue: 44)!
    
    var delegate: DGStreamDropDownManagerDelegate!
    
    func configureWith(container: UIView, type: DGStreamDropDownType, selectedSizeIndex: Int, selectedColorIndex: Int, delegate: DGStreamDropDownManagerDelegate) {
        self.selectedSizeIndex = selectedSizeIndex
        self.selectedColorIndex = selectedColorIndex
        self.delegate = delegate
        self.dropDownContainer = container
        container.backgroundColor = .clear
        self.collectionView = self.getDropDownViewFor(type: type)
        self.collectionView?.boundInside(container: container)
    }
    
    func loadFor(type: DGStreamDropDownType) {
        self.type = type
        self.collectionView?.reloadData()
    }
    
    func getDropDownViewFor(type: DGStreamDropDownType) -> UICollectionView {
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: 80, height: 80)
        flowLayout.minimumInteritemSpacing = 10
        flowLayout.minimumLineSpacing = 10
        flowLayout.scrollDirection = .vertical
        flowLayout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10)
        
        let collectionView = UICollectionView(frame: CGRect.init(x: 0, y: 0, width: self.dropDownContainer.bounds.size.width, height: self.dropDownContainer.bounds.size.height), collectionViewLayout: flowLayout)
        collectionView.tag = type.rawValue
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundView?.backgroundColor = .clear
        collectionView.backgroundColor = .clear
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        
        return collectionView
        
    }
}

extension DGStreamDropDownManager: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        var oldSelectedIndex:Int = 100
        if type == .size {
            oldSelectedIndex = self.selectedSizeIndex
            self.selectedSizeIndex = indexPath.item
            self.delegate.dropDownManager(manager: self, sizeSelected: sizes[self.selectedSizeIndex], index: self.selectedSizeIndex)
            
        }
        else if type == .color {
            oldSelectedIndex = self.selectedColorIndex
            self.selectedColorIndex = indexPath.item
            self.delegate.dropDownManager(manager: self, colorSelected: colors[self.selectedColorIndex], index: selectedColorIndex)
        }
        else if type == .stamp {
            self.delegate.dropDownManager(manager: self, stampSelected: stamps[indexPath.item])
        }
        
        // Remove The Old
        if oldSelectedIndex != 100, let cell = collectionView.cellForItem(at: IndexPath(item: oldSelectedIndex, section: 0)) {
            for subview in cell.contentView.subviews {
                if let label = subview as? UILabel {
                    label.layer.borderWidth = 0
                }
            }
        }
        
        // Add the New
        if type != .stamp, let cell = collectionView.cellForItem(at: IndexPath(item: indexPath.item, section: 0)) {
            for subview in cell.contentView.subviews {
                if let label = subview as? UILabel {
                    label.layer.borderColor = UIColor.dgBlueDark().cgColor
                    label.layer.borderWidth = 4
                }
            }
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        let tag = collectionView.tag
//        let type = DGStreamDropDownType(rawValue: tag)
        if type == .size {
            return self.sizes.count
        }
        else if type == .color {
            return self.colors.count
        }
        else if type == .stamp {
            return self.stamps.count
        }
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
//        let tag = collectionView.tag
//        let type = DGStreamDropDownType(rawValue: tag)
        
        let label = UILabel(frame: cell.contentView.frame)
        label.textAlignment = .center
        label.minimumScaleFactor = 0.5
        label.adjustsFontSizeToFitWidth = true
        label.boundInside(container: cell.contentView)
        label.clipsToBounds = true
        label.layer.cornerRadius = label.frame.size.width / 2
        label.layer.borderWidth = 0
        
        var title: String?
        var font = UIFont.systemFont(ofSize: 12)
        var color: UIColor = .white
        
        if type == .size {
            font = UIFont.systemFont(ofSize: 32)
            title = sizes[indexPath.item]
            color = .white
            if indexPath.item == self.selectedSizeIndex {
                label.layer.borderColor = UIColor.dgBlueDark().cgColor
                label.layer.borderWidth = 4
            }
        }
        else if type == .color {
            color = colors[indexPath.item]
            if indexPath.item == self.selectedColorIndex {
                label.layer.borderColor = UIColor.dgBlueDark().cgColor
                label.layer.borderWidth = 4
            }
        }
        else if type == .stamp {
            font = UIFont.systemFont(ofSize: 24)
            title = stamps[indexPath.item]
        }
        
        label.backgroundColor = color
        label.textColor = UIColor.dgBlack()
        
        if let title = title {
            label.text = title
            label.font = font
        }
        
        return cell
        
    }

}

//extension DGStreamDropDownManager {
//    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//        if keyPath == "frame" {
//
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.20, execute: {
//
//                if let size = self.sizeCollectionView {
//                    size.frame = CGRect(x: 0, y: 0, width: self.dropDownContainer.frame.size.width, height: 64)
//                    size.layoutIfNeeded()
//                    size.superview?.layoutIfNeeded()
//                }
//
//                if let color = self.colorCollectionView {
//                    color.frame = CGRect(x: 0, y: 0, width: self.dropDownContainer.frame.size.width, height: 64)
//                    color.layoutIfNeeded()
//                    color.superview?.layoutIfNeeded()
//                }
//
//                if let stamp = self.stampCollectionView {
//                    stamp.frame = CGRect(x: 0, y: 0, width: self.dropDownContainer.frame.size.width, height: 64)
//                    stamp.layoutIfNeeded()
//                    stamp.superview?.layoutIfNeeded()
//                }
//
//            })
//
//        }
//    }
//}
