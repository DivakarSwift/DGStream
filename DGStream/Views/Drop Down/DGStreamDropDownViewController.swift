//
//  DGStreamDropDownViewController.swift
//  DGStream
//
//  Created by Brandon on 11/29/17.
//  Copyright © 2017 Dataglance. All rights reserved.
//

import UIKit

enum DGStreamDropDownType: Int {
    case size = 33
    case color = 44
    case stamp = 55
}

protocol DGStreamDropDownViewControllerDelegate {
    func dropDownViewController(viewController: DGStreamDropDownViewController, sizeSelected size: String)
    func dropDownViewController(viewController: DGStreamDropDownViewController, colorSelected color: UIColor)
    func dropDownViewController(viewController: DGStreamDropDownViewController, stampSelected stamp: String)
}

class DGStreamDropDownViewController: UIViewController {
    
    let sizes:[String] = ["14", "18", "22", "26", "30", "34", "48", "52", "56", "60"]
    let colors:[UIColor] = [.black, .white, .gray, .red, .blue, .green, .yellow, .orange, .purple]
    let stamps:[String] = ["⟵", "⟷", "↰", "↱", "☐", "○", "△", "◇", "✔︎", "✘", "★", "❤︎", "Ω", "∞", "∅", "⊖", "✌︎", "✄", "⚐", "☯"]
    
    var type: DGStreamDropDownType!
    
    var delegate:DGStreamDropDownViewControllerDelegate!

    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    func configureFor(type: DGStreamDropDownType) {
        self.type = type
        self.collectionView.reloadData()
    }

}

extension DGStreamDropDownViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.type == .size {
            self.delegate.dropDownViewController(viewController: self, sizeSelected: sizes[indexPath.item])
        }
        else if self.type == .color {
            self.delegate.dropDownViewController(viewController: self, colorSelected: colors[indexPath.item])
        }
        else if self.type == .stamp {
            self.delegate.dropDownViewController(viewController: self, stampSelected: stamps[indexPath.item])
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.type == .size {
            return self.sizes.count
        }
        else if self.type == .color {
            return self.colors.count
        }
        else if self.type == .stamp {
            return self.stamps.count
        }
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? DGStreamDropDownCollectionViewCell {
            if self.type == .size {
                cell.configureWith(title: sizes[indexPath.item], color: .white)
            }
            else if self.type == .color {
                cell.configureWith(title: nil, color: colors[indexPath.item])
            }
            else if self.type == .stamp {
                cell.configureWith(title: stamps[indexPath.item], color: .white)
            }
            return cell
        }
        return UICollectionViewCell()
    }
}
