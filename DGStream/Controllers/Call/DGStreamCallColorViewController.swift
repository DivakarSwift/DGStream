//
//  DGStreamCallColorViewController.swift
//  DGStream
//
//  Created by Brandon on 6/27/18.
//  Copyright © 2018 Dataglance. All rights reserved.
//

import UIKit

protocol DGStreamCallColorViewControllerDelegate {
    func mergeColorSelected(color: UIColor)
    func sizeSelected(size: CGFloat)
}

class DGStreamCallColorViewController: UIViewController {
    
    @IBOutlet weak var colorCollectionView: UICollectionView!
    
    var selectedIntensity: Float = 0.525
    var selectedColor: UIColor!
    var selectedSize: CGFloat!
    var selectedIndex: Int = 0
    
    var delegate: DGStreamCallColorViewControllerDelegate!
    
    let colors:[UIColor] = [.green, .blue, .red, .white, .black]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if let index = self.colors.index(of: self.selectedColor) {
            self.selectedIndex = index
        }
        
        let format = UICollectionViewFlowLayout()
        format.estimatedItemSize = CGSize(width: 44, height: 44)
        format.itemSize = CGSize(width: 44, height: 44)
        format.minimumInteritemSpacing = 10
        format.minimumLineSpacing = 10
        format.sectionInset = UIEdgeInsetsMake(0, 10, 0, 0)
        format.scrollDirection = .horizontal
        
        self.colorCollectionView.dataSource = self
        self.colorCollectionView.delegate = self
        self.colorCollectionView.setCollectionViewLayout(format, animated: false)
        self.colorCollectionView.collectionViewLayout = format
        self.colorCollectionView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.view.layoutIfNeeded()
        self.colorCollectionView.layoutIfNeeded()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func storeValues() {
        
        var color = ""
        if self.selectedColor == .green {
            color = "green"
        }
        else if self.selectedColor == .blue {
            color = "blue"
        }
        else if self.selectedColor == .red {
            color = "red"
        }
        else if self.selectedColor == .white {
            color = "white"
        }
        else {
            color = "black"
        }
        
        UserDefaults.standard.set(color, forKey: "MergeColor")
        UserDefaults.standard.set(self.selectedIntensity, forKey: "MergeIntensity")
        UserDefaults.standard.synchronize()
    }
    
//    func stringFor(color: UIColor) -> String {
//        var textValue = "Unknown"
//        if color == .black && self.mergeOptionsDelegate == nil {
//            textValue = "Black"
//        }
//        else if color == .black {
//            textValue = "Faded"
//        }
//        else if color == .white && self.mergeOptionsDelegate == nil {
//            textValue = "White"
//        }
//        else if color == .white {
//            textValue = "B&W"
//        }
//        else if color == .gray {
//            textValue = "Gray"
//        }
//        else if color == .red {
//            textValue = "Red"
//        }
//        else if color == .blue {
//            textValue = "Blue"
//        }
//        else if color == .green {
//            textValue = "Green"
//        }
//        else if color == .yellow {
//            textValue = "Yellow"
//        }
//        else if color == .orange {
//            textValue = "Orange"
//        }
//        else if color == .purple {
//            textValue = "Purple"
//        }
//        return textValue
//    }

}

extension DGStreamCallColorViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        defer {
            self.dismiss(animated: true, completion: nil)
        }
    
        let color = self.colors[indexPath.item]
        self.selectedColor = color
        self.delegate.mergeColorSelected(color: color)
        
//        let oldSelectedIndex = self.selectedIndex
//
//        if indexPath.item == oldSelectedIndex {
//            return
//        }
//
//        self.selectedIndex = indexPath.item
//
//        let color = self.colors[indexPath.item]
//        self.selectedColor = color
//        self.delegate.colorSelected(color: color)
//
//        // Remove The Old
//        if oldSelectedIndex != 100, let cell = collectionView.cellForItem(at: IndexPath(item: oldSelectedIndex, section: 0)) {
//            cell.contentView.layer.borderColor = UIColor.dgBlack().cgColor
//            cell.contentView.layer.borderWidth = 0.5
//        }
//
//        // Add the New
//        if let cell = collectionView.cellForItem(at: IndexPath(item: indexPath.item, section: 0)) {
//            cell.contentView.layer.borderColor = UIColor.dgBlueDark().cgColor
//            cell.contentView.layer.borderWidth = 4
//        }
        
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.colors.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        
        for sub in cell.contentView.subviews {
            sub.removeFromSuperview()
        }
        
        let color = self.colors[indexPath.item]
        cell.contentView.backgroundColor = color
        if color == .white {
            let subview = UIView(frame: CGRect(x: 4, y: 4, width: cell.contentView.bounds.size.width - 8, height: cell.contentView.bounds.size.height - 8))
            subview.layer.cornerRadius = subview.frame.size.width / 2
            subview.backgroundColor = .white
            _ = cell.contentView.addGradientBackground(firstColor: .white, secondColor: .black, height: cell.contentView.bounds.size.height)
            cell.contentView.addSubview(subview)
        }
        if color == .black {
            _ = cell.contentView.addGradientBackground(firstColor: .white, secondColor: .gray, height: cell.contentView.bounds.size.height)
        }
        
        if indexPath.item == self.selectedIndex {
            cell.contentView.layer.borderColor = UIColor.orange.cgColor
            cell.contentView.layer.borderWidth = 5.0
        }
        else {
            cell.contentView.layer.borderColor = UIColor.dgBlack().cgColor
            cell.contentView.layer.borderWidth = 0.5
        }
        
        cell.contentView.clipsToBounds = true
        cell.clipsToBounds = true
        cell.contentView.layer.cornerRadius = cell.contentView.frame.size.width / 2
        return cell
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
