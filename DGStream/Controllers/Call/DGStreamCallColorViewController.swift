//
//  DGStreamCallColorViewController.swift
//  DGStream
//
//  Created by Brandon on 6/27/18.
//  Copyright © 2018 Dataglance. All rights reserved.
//

import UIKit

protocol DGStreamCallColorViewControllerDelegate {
    func colorSelected(color: UIColor)
    func sizeSelected(size: CGFloat)
}

protocol DGStreamCallMergeOptionsDelegate {
    func mergeOptionSelected(color: UIColor, intensity: Float)
}

class DGStreamCallColorViewController: UIViewController {
    
    @IBOutlet weak var sizeSlider: UISlider!
    @IBOutlet weak var sliderLabel: UILabel!
    
    @IBOutlet weak var colorCollectionView: UICollectionView!
    
    var selectedIntensity: Float = 0.525
    var selectedColor: UIColor!
    var selectedSize: CGFloat!
    var selectedIndex: Int = 0
    
    var delegate: DGStreamCallColorViewControllerDelegate!
    var mergeOptionsDelegate: DGStreamCallMergeOptionsDelegate?
    
    let colors:[UIColor] = [.black, .white, .gray, .red, .blue, .green, .yellow, .orange, .purple]
    let mergeOptionColors:[UIColor] = [.green, .blue, .red, .white, .black]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        var collection:[UIColor] = []
        if self.mergeOptionsDelegate == nil {
            self.sizeSlider.minimumValue = 8
            self.sizeSlider.maximumValue = 40
            collection = self.colors
        }
        else {
            self.sizeSlider.minimumValue = 0.20
            self.sizeSlider.maximumValue = 0.80
            collection = self.mergeOptionColors
        }
        
        if let index = collection.index(of: self.selectedColor) {
            self.selectedIndex = index
        }
        
        let format = UICollectionViewFlowLayout()
        format.estimatedItemSize = CGSize(width: 50, height: 50)
        format.itemSize = CGSize(width: 50, height: 50)
        format.minimumInteritemSpacing = 10
        format.minimumLineSpacing = 10
        format.sectionInset = UIEdgeInsetsMake(0, 20, 0, 0)
        format.scrollDirection = .horizontal
        
        self.colorCollectionView.dataSource = self
        self.colorCollectionView.delegate = self
        self.colorCollectionView.setCollectionViewLayout(format, animated: false)
        self.colorCollectionView.collectionViewLayout = format
        self.colorCollectionView.reloadData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.mergeOptionsDelegate != nil {
            if self.selectedColor == .black {
                self.sliderLabel.text = "N/A"
                self.sizeSlider.isEnabled = false
                self.sizeSlider.alpha = 0.0
            }
            else {
                self.sizeSlider.setValue(self.selectedIntensity, animated: false)
                self.sizeSlider.value = self.selectedIntensity
                self.sliderLabel.text = self.stringForSliderValue()
            }
        }
        else {
            self.sizeSlider.setValue(Float(self.selectedSize), animated: false)
            self.sizeSlider.value = Float(self.selectedSize)
            self.sliderLabel.text = "\(Int(self.selectedSize))"
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sizeSliderValueChanged(_ sender: Any) {
        let value = self.sizeSlider.value
        if let mergeOptionsDelegate = self.mergeOptionsDelegate {
            self.sliderLabel.text = self.stringForSliderValue()
            self.selectedIntensity = value
            mergeOptionsDelegate.mergeOptionSelected(color: self.selectedColor, intensity: value)
        }
        else {
            self.sliderLabel.text = "\(Int(value))"
            self.selectedSize = CGFloat(Int(value))
            self.delegate.sizeSelected(size: CGFloat(value))
        }
    }
    
    @IBAction func touchUpInside(_ sender: Any) {
        if self.mergeOptionsDelegate != nil {
            self.storeValues()
        }
    }
    
    @IBAction func touchUpOutside(_ sender: Any) {
        if self.mergeOptionsDelegate != nil {
            self.storeValues()
        }
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
    
    func stringForSliderValue() -> String {
        print(self.sizeSlider.value)
        let stringValue = String(self.sizeSlider.value)
        print("String \(stringValue)")
        let splice = stringValue.components(separatedBy: ".")[1]
        let spliceString = NSString(string: splice)
        var string = ""
        if spliceString.length > 1 {
            string = NSString(string: spliceString).substring(to: 2)
        }
        else {
            string = NSString(string: spliceString).substring(to: 1)
            string.append("0")
        }
        return "\(string)%"
    }
    
    func stringFor(color: UIColor) -> String {
        var textValue = "Unknown"
        if color == .black && self.mergeOptionsDelegate == nil {
            textValue = "Black"
        }
        else if color == .black {
            textValue = "Faded"
        }
        else if color == .white && self.mergeOptionsDelegate == nil {
            textValue = "White"
        }
        else if color == .white {
            textValue = "B&W"
        }
        else if color == .gray {
            textValue = "Gray"
        }
        else if color == .red {
            textValue = "Red"
        }
        else if color == .blue {
            textValue = "Blue"
        }
        else if color == .green {
            textValue = "Green"
        }
        else if color == .yellow {
            textValue = "Yellow"
        }
        else if color == .orange {
            textValue = "Orange"
        }
        else if color == .purple {
            textValue = "Purple"
        }
        return textValue
    }

}

extension DGStreamCallColorViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let oldSelectedIndex = self.selectedIndex
        
        if indexPath.item == oldSelectedIndex {
            return
        }
        
        self.selectedIndex = indexPath.item
        
        if let mergeOptionsDelegate = self.mergeOptionsDelegate {
            let color = self.mergeOptionColors[indexPath.item]
            self.selectedColor = color
            if self.selectedColor == .black {
                self.sizeSlider.isEnabled = false
                self.sizeSlider.alpha = 0.0
                self.sliderLabel.text = "N/A"
            }
            else {
                self.sizeSlider.isEnabled = true
                self.sizeSlider.alpha = 1.0
                self.sliderLabel.text = self.stringForSliderValue()
            }
            mergeOptionsDelegate.mergeOptionSelected(color: self.selectedColor, intensity: self.selectedIntensity)
            self.storeValues()
        }
        else {
            let color = self.colors[indexPath.item]
            self.selectedColor = color
            self.delegate.colorSelected(color: color)
        }
        
        // Remove The Old
        if oldSelectedIndex != 100, let cell = collectionView.cellForItem(at: IndexPath(item: oldSelectedIndex, section: 0)) {
            cell.contentView.layer.borderColor = UIColor.dgBlack().cgColor
            cell.contentView.layer.borderWidth = 0.5
        }
        
        // Add the New
        if let cell = collectionView.cellForItem(at: IndexPath(item: indexPath.item, section: 0)) {
            cell.contentView.layer.borderColor = UIColor.dgBlueDark().cgColor
            cell.contentView.layer.borderWidth = 4
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.mergeOptionsDelegate == nil {
            return self.colors.count
        }
        else {
            return self.mergeOptionColors.count
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        var color: UIColor
        if self.mergeOptionsDelegate == nil {
            color = self.colors[indexPath.item]
        }
        else {
            color = self.mergeOptionColors[indexPath.item]
        }
        cell.contentView.backgroundColor = color
        if color == .white && self.mergeOptionsDelegate != nil {
            let subview = UIView(frame: CGRect(x: 4, y: 4, width: cell.contentView.bounds.size.width - 8, height: cell.contentView.bounds.size.height - 8))
            subview.layer.cornerRadius = subview.frame.size.width / 2
            subview.backgroundColor = .white
            _ = cell.contentView.addGradientBackground(firstColor: .white, secondColor: .black, height: cell.contentView.bounds.size.height)
            cell.contentView.addSubview(subview)
        }
        if color == .black && self.mergeOptionsDelegate != nil {
            _ = cell.contentView.addGradientBackground(firstColor: .white, secondColor: .gray, height: cell.contentView.bounds.size.height)
        }
        if color == self.selectedColor {
            cell.contentView.layer.borderColor = UIColor.dgBlueDark().cgColor
            cell.contentView.layer.borderWidth = 4
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
