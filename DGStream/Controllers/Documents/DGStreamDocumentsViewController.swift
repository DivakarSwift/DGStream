//
//  DGStreamDocumentsViewController.swift
//  DGStream
//
//  Created by Brandon on 7/5/18.
//  Copyright © 2018 Dataglance. All rights reserved.
//

import UIKit

protocol DGStreamDocumentsViewControllerDelegate {
    func didSelect(document: DGStreamDocument)
}

class DGStreamDocumentsViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var navBar: UIView!
    @IBOutlet weak var navBarTitle: UILabel!
    @IBOutlet weak var navBarBackButton: UIButton!
    
    var documents: [DGStreamDocument] = []
    var delegate: DGStreamDocumentsViewControllerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let id = "8998848"
        let document = DGStreamDocument()
        document.createdBy = DGStreamCore.instance.currentUser?.userID
        document.createdDate = Date()
        document.id = id
        document.title = "!Bizcards.pdf"
        document.url = "\(id).pdf"
        self.documents.append(document)
        self.collectionView.reloadData()
        
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension DGStreamDocumentsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let document = self.documents[indexPath.item]
        self.delegate.didSelect(document: document)
        self.dismiss(animated: false, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.documents.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let document = self.documents[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! DGStreamDocumentCollectionViewCell
        cell.configureWith(document: document)
        cell.cellImageView.backgroundColor = .black
        return cell
    }
    
}
