//
//  DGStreamCallStampsViewController.swift
//  DGStream
//
//  Created by Brandon on 6/27/18.
//  Copyright © 2018 Dataglance. All rights reserved.
//

import UIKit

protocol DGStreamCallStampsViewControllerDelegate {
    func stampSelected(stamp: String)
}

class DGStreamCallStampsViewController: UIViewController {
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let stamps:[String] = ["⟵", "⟷", "↰", "↱", "☐", "○", "△", "◇", "✔︎", "✘", "★", "❤︎", "Ω", "∞", "∅", "⊖", "✌︎", "✂︎", "⚑", "☉"]
    
    var selectedColor = UIColor.dgBlack()
    
    var delegate: DGStreamCallStampsViewControllerDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let format = UICollectionViewFlowLayout()
        format.estimatedItemSize = CGSize(width: 140, height: 140)
        format.itemSize = CGSize(width: 140, height: 140)
        format.minimumInteritemSpacing = 20
        format.minimumLineSpacing = 20
        format.sectionInset = UIEdgeInsetsMake(0, 20, 0, 20)
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.setCollectionViewLayout(format, animated: false)
        self.collectionView.collectionViewLayout = format
        self.collectionView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension DGStreamCallStampsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let stamp = self.stamps[indexPath.item]
        self.dismiss(animated: false, completion: nil)
        self.delegate.stampSelected(stamp: stamp)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.stamps.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        let stamp = self.stamps[indexPath.item]
        
        for subview in cell.contentView.subviews {
            if let label = subview as? UILabel {
                label.removeFromSuperview()
            }
        }
        
        let label = UILabel(frame: cell.contentView.bounds)
        label.text = stamp
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 32)
        label.textColor = self.selectedColor
        
        label.boundInside(container: cell.contentView)
        
        return cell
    }
}
