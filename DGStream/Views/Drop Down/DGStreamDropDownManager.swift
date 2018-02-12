//
//  DGStreamDropDownManager.swift
//  DGStream
//
//  Created by Brandon on 12/4/17.
//  Copyright © 2017 Dataglance. All rights reserved.
//

import UIKit

protocol DGStreamDropDownManagerDelegate {
    func dropDownManager(manager: DGStreamDropDownManager, sizeSelected size: String)
    func dropDownManager(manager: DGStreamDropDownManager, colorSelected color: UIColor)
    func dropDownManager(manager: DGStreamDropDownManager, stampSelected stamp: String)
}

class DGStreamDropDownManager: NSObject {
    
    let sizes:[String] = ["14", "18", "22", "26", "30", "34", "48", "52", "56", "60"]
    let colors:[UIColor] = [.black, .white, .gray, .red, .blue, .green, .yellow, .orange, .purple]
    let stamps:[String] = ["⟵", "⟷", "↰", "↱", "☐", "○", "△", "◇", "✔︎", "✘", "★", "❤︎", "Ω", "∞", "∅", "⊖", "✌︎", "✂︎", "⚑", "☉"]
    
    var dropDownContainer: UIView!
    
    var sizeCollectionView: UICollectionView?
    var colorCollectionView: UICollectionView?
    var stampCollectionView: UICollectionView?
    
    var delegate: DGStreamDropDownManagerDelegate!
    
    func configureWith(container: UIView, delegate: DGStreamDropDownManagerDelegate) {
        self.delegate = delegate
        self.dropDownContainer = container
        self.dropDownContainer.addObserver(self, forKeyPath: "frame", options: .new, context: nil)
    }
    
    func getDropDownViewFor(type: DGStreamDropDownType) -> UICollectionView {
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: 44, height: 44)
        flowLayout.minimumInteritemSpacing = 10
        flowLayout.minimumLineSpacing = 10
        flowLayout.scrollDirection = .horizontal
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 0)
        
        let collectionView = UICollectionView(frame: CGRect.init(x: 0, y: 0, width: self.dropDownContainer.bounds.size.width, height: 64), collectionViewLayout: flowLayout)
        collectionView.tag = type.rawValue
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundView?.backgroundColor = UIColor.dgYellow()
        collectionView.backgroundColor = UIColor.dgYellow()
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        
        if type == .size {
            self.sizeCollectionView = collectionView
        }
        else if type == .color {
            self.colorCollectionView = collectionView
        }
        else if type == .stamp {
            self.stampCollectionView = collectionView
        }
        
        return collectionView
        
    }
}

extension DGStreamDropDownManager: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let tag = collectionView.tag
        let type = DGStreamDropDownType(rawValue: tag)
        if type == .size {
            self.delegate.dropDownManager(manager: self, sizeSelected: sizes[indexPath.item])
        }
        else if type == .color {
            self.delegate.dropDownManager(manager: self, colorSelected: colors[indexPath.item])
        }
        else if type == .stamp {
            self.delegate.dropDownManager(manager: self, stampSelected: stamps[indexPath.item])
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let tag = collectionView.tag
        let type = DGStreamDropDownType(rawValue: tag)
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
        let tag = collectionView.tag
        let type = DGStreamDropDownType(rawValue: tag)
        
        let label = UILabel(frame: cell.contentView.frame)
        label.textAlignment = .center
        label.minimumScaleFactor = 0.5
        label.adjustsFontSizeToFitWidth = true
        label.boundInside(container: cell.contentView)
        label.clipsToBounds = true
        label.layer.cornerRadius = label.frame.size.width / 2
        
        var title: String?
        var font = UIFont.systemFont(ofSize: 12)
        var color: UIColor = .white
        
        if type == .size {
            font = UIFont.systemFont(ofSize: 32)
            title = sizes[indexPath.item]
            color = .white
        }
        else if type == .color {
            color = colors[indexPath.item]
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

extension DGStreamDropDownManager {
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "frame" {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.20, execute: {
                
                if let size = self.sizeCollectionView {
                    size.frame = CGRect(x: 0, y: 0, width: self.dropDownContainer.frame.size.width, height: 64)
                    size.layoutIfNeeded()
                    size.superview?.layoutIfNeeded()
                }
                
                if let color = self.colorCollectionView {
                    color.frame = CGRect(x: 0, y: 0, width: self.dropDownContainer.frame.size.width, height: 64)
                    color.layoutIfNeeded()
                    color.superview?.layoutIfNeeded()
                }
                
                if let stamp = self.stampCollectionView {
                    stamp.frame = CGRect(x: 0, y: 0, width: self.dropDownContainer.frame.size.width, height: 64)
                    stamp.layoutIfNeeded()
                    stamp.superview?.layoutIfNeeded()
                }
                
            })
            
        }
    }
}
