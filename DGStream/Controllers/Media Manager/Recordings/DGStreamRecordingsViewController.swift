//
//  DGStreamRecordingCollectionsViewController.swift
//  DGStream
//
//  Created by Brandon on 2/16/18.
//  Copyright © 2018 Dataglance. All rights reserved.
//

import UIKit

public protocol DGStreamRecordingsViewControllerDelegate {
    func didSelect(collection: MMMediaCollectionProtocol, with initialRect: CGRect, and albumView: MMAlbumView?)
}

public class DGStreamRecordingCollectionsViewController: DGStreamSelectionViewController {
    
    @IBOutlet weak var mediaCollectionsCollectionView: UICollectionView!
    
    var selectedCellRect:CGRect?
    var selectedAlbumView:MMAlbumView?
    var isComingBackFromCollection: Bool = false
    
    public var delegate: DGStreamRecordingsViewControllerDelegate!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Constants.Colors.dgBackground
        self.mediaCollectionsCollectionView.backgroundView?.backgroundColor = .clear
        self.mediaCollectionsCollectionView.backgroundColor = .clear
        self.mediaCollectionsCollectionView.dataSource = self
        self.mediaCollectionsCollectionView.delegate = self
        self.mediaCollectionsCollectionView.setCollectionViewLayout(MMMediaCollectionsLayout.getLayout(), animated: true)
        self.setNavigationBar(animated: false)
        loadLibrary()
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isComingBackFromCollection {
            self.mediaCollectionsCollectionView.alpha = 0
        }
        selectedCellRect = nil
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        MMSDKManager.instance.delegate?.mediaManagerDidPresent(scene: .collections)
        MMSDKManager.instance.sdkDelegate = self
        if isComingBackFromCollection {
            UIView.animate(withDuration: Constants.Animation.duration, animations: {
                self.mediaCollectionsCollectionView.alpha = 1
            })
        }
    }
    
    override public func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let mediaVC = segue.destination as! MMMediaViewController
        mediaVC.wasPresentedFromCollections = true
        if let cover = selectedAlbumView {
            mediaVC.selectedAlbumView = cover
        }
        if let collection = sender as? DGStreamRecordingCollection {
            mediaVC.mediaCollection = collection
        }
        if let rect = selectedCellRect {
            mediaVC.initialRect = rect
        }
    }
    
    func backButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    override func deleteButtonTapped() {
        if isSelectingCells {
            var indecies:[IndexPath] = []
            if let collections = data as? [DGStreamRecordingCollection] {
                for collection in selectedCollections {
                    if let index = collections.index(of: collection) {
                        let indexPath = IndexPath(item: index, section: 0)
                        indecies.append(indexPath)
                        data.remove(at: index)
                        MMSDKManager.instance.dataStore.delete(collection: collection)
                    }
                }
            }
            super.deleteButtonTapped()
            mediaCollectionsCollectionView.deleteItems(at: indecies)
        }
    }
    
    override func filterButtonTapped(_ sender: Any) {
        MMSDKFilter.instance.filterMode = .collection
        let filterVC = MMFilterViewController()
        filterVC.delegate = self
        let nav = UINavigationController.init(rootViewController: filterVC)
        nav.navigationBar.isTranslucent = false
        nav.navigationBar.barTintColor = Constants.Colors.dgBlue
        nav.navigationBar.tintColor = .white
        if Display.pad {
            nav.modalPresentationStyle = .formSheet
        }
        else {
            nav.modalPresentationStyle = .custom
        }
        if let parent = MMSDKManager.instance.parentViewController {
            parent.present(nav, animated: true, completion: nil)
        }
    }
    
    override func addToButtonTapped(sender: Any) {
        let bundle = Bundle(identifier: "com.dataglance.MediaManagerSDK")
        let storyboard = UIStoryboard(name: "AddTo", bundle: bundle)
        let addToVC = storyboard.instantiateInitialViewController() as! MMAddToViewController
        var mediax:[DGStreamRecording] = []
        for collection in selectedCollections {
            var filters:[NSPredicate] = []
            if let collectionID = collection.id {
                filters.append(NSPredicate.init(format: "ANY collections.identifier == %@", collectionID))
            }
            let collectionMedia = MMSDKMedia.createMMSDKMediaFrom(protocols: MMSDKManager.instance.dataSource.getMediaWith(filters: filters, limit: nil))
            for media in collectionMedia {
                if let id = media.id {
                    let filtered = mediax.filter({ (filterMedia) -> Bool in
                        return filterMedia.id == id
                    }).first
                    if filtered == nil {
                        mediax.append(media)
                    }
                }
            }
        }
        addToVC.delegate = self
        addToVC.selectedMedia = mediax
        if Display.pad {
            addToVC.modalPresentationStyle = .popover
            if let barButton = sender as? UIBarButtonItem {
                addToVC.popoverPresentationController?.barButtonItem = barButton
            }
            else if let button = sender as? UIButton {
                addToVC.popoverPresentationController?.sourceView = button.superview
            }
        }
        else {
            addToVC.modalTransitionStyle = .coverVertical
            addToVC.modalPresentationStyle = .custom
        }
        present(addToVC, animated: true, completion: nil)
    }
    
    func loadLibrary() {
        data.removeAll()
        if libraryMode == .collections {
            data = MMSDKMediaCollection.createMMSDKMediaCollectionFrom(protocols: MMSDKManager.instance.dataSource.getCollectionsWith(filters: []))
        }
        DispatchQueue.main.async(execute: {
            self.mediaCollectionsCollectionView.reloadData()
            self.setNavigationBar(animated: false)
            if self.data.count == 0 {
                self.showMissingLabel()
            }
            else {
                self.hideMissingLabel()
            }
        })
    }
    
    
    // super overrides
    override func addBarButtonTapped(_ sender: Any) {
        MMSDKManager.instance.addButtonTapped(sender: sender)
    }
    override func insertItemAt(index: IndexPath) {
        self.mediaCollectionsCollectionView.insertItems(at: [index])
    }
    override func reloadItemAt(index: IndexPath) {
        self.mediaCollectionsCollectionView.reloadItems(at: [index])
    }
    override func cellFor(index: IndexPath) -> MMLibraryCollectionViewCell {
        return self.mediaCollectionsCollectionView.cellForItem(at: index) as! MMMediaCollectionsCell
    }
    override func visibleCells() -> [MMLibraryCollectionViewCell] {
        return self.mediaCollectionsCollectionView.visibleCells as! [MMMediaCollectionsCell]
    }
}

extension DGStreamRecordingCollectionsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.data.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell:MMMediaCollectionsCell = collectionView.cellForItem(at: indexPath) as! MMMediaCollectionsCell
        if isSelectingCells {
            if let cell = collectionView.cellForItem(at: indexPath) as? MMLibraryCollectionViewCell {
                let collection = data[indexPath.item] as! DGStreamRecordingCollection
                if selectedCollections.contains(collection), let idx = selectedCollections.index(of: collection) {
                    selectedCollections.remove(at: idx)
                    cell.was(selected: false)
                }
                else {
                    selectedCollections.append(collection)
                    cell.was(selected: true)
                }
            }
            MMSDKManager.instance.delegate?.mediaManagerDidChangeSelection(count: selectedCollections.count)
            setNavigationBar(animated: false)
        }
        else {
            if let layoutAttributes = collectionView.layoutAttributesForItem(at: indexPath) {
                let rect = collectionView.convert(layoutAttributes.frame, to: collectionView.superview)
                
                if let albumView = cell.albumView {
                    albumView.frame = rect
                    self.selectedAlbumView = albumView
                    self.view.addSubview(albumView)
                }
                
                self.selectedCellRect = rect
                
                let bundle = Bundle(identifier: "com.dataglance.MediaManagerSDK")
                let storyboard = UIStoryboard(name: "Media", bundle: bundle)
                let vc = storyboard.instantiateInitialViewController() as! MMMediaViewController
                vc.initialRect = self.selectedCellRect
                vc.selectedAlbumView = self.selectedAlbumView
                vc.mediaCollection = cell.mediaCollection
                vc.wasPresentedFromCollections = true
                vc.delegate = self
                vc.titleString = self.titleString
                
                UIView.animate(withDuration: 0.05, animations: {
                    self.mediaCollectionsCollectionView.alpha = 0
                }, completion: { (finished) in
                    self.navigationController?.pushViewController(vc, animated: false)
                })
                
            }
            
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath) as! MMMediaCollectionsCell
        cell.configureWith(collection: self.data[indexPath.row] as! DGStreamRecordingCollection)
        cell.tag = indexPath.item
        return cell
    }
}

//MARK:- Filter
extension DGStreamRecordingCollectionsViewController: MMFilterViewControllerDelegate {
    func applyFilter() {
        let filters = MMSDKFilter.instance.collection.filters()
        data = DGStreamRecordingCollection.createDGStreamRecordingCollectionFrom(protocols: [])
        mediaCollectionsCollectionView.reloadData()
        setNavigationBar(animated: false)
    }
    func applyFoundObjects() {
        loadLibrary()
    }
}

//MARK:- Capture
extension DGStreamRecordingCollectionsViewController: MMWorkflowControllerAddDelegate {
    func add(media: [DGStreamRecording]) {
        // Refresh cells of the collections the media belong to in order to show latest media on top
    }
}

//MARK:- Add To
extension DGStreamRecordingCollectionsViewController: MMAddToViewControllerDelegate {
    func didAddTo(collections: [DGStreamRecordingCollection]) {
        
        var dataCollections = data as! [DGStreamRecordingCollection]
        
        for collection in collections {
            if let collectionID = collection.id {
                for (index, dataCollection) in dataCollections.enumerated() {
                    if let dataCollectionID = dataCollection.id {
                        if collectionID == dataCollectionID {
                            dataCollections.remove(at: index)
                            dataCollections.insert(collection, at: index)
                        }
                    }
                }
            }
        }
        
        data = dataCollections
        
        for (_, cell) in mediaCollectionsCollectionView.visibleCells.enumerated() {
            if let collectionCell = cell as? MMMediaCollectionsCell, let cellCollection = collectionCell.mediaCollection, let cellCollectionID = cellCollection.id {
                for collection in collections {
                    if let collectionID = collection.id, collectionID == cellCollectionID {
                        
                        var filters:[NSPredicate] = []
                        if let collectionID = collection.id {
                            filters.append(NSPredicate.init(format: "ANY collections.identifier == %@", collectionID))
                        }
                        
                        if let collection = MMSDKMediaCollection.createMMSDKMediaCollectionFrom(protocols: MMSDKManager.instance.dataSource.getCollectionsWith(filters: filters)).first {
                            collectionCell.configureWith(collection: collection)
                        }
                    }
                }
            }
        }
        
        endSelectingCells()
        
    }
}

extension DGStreamRecordingCollectionsViewController: MMMediaViewControllerDelegate {
    func reloadCollectionsWith(ids: [String]) {
        self.isComingBackFromCollection = true
        for id in ids {
            let collections: [DGStreamRecordingCollection] = data as? [DGStreamRecordingCollection] ?? []
            for (collectionIndex, collection) in collections.enumerated() {
                if collection.id == id {
                    if let cell = mediaCollectionsCollectionView.cellForItem(at: IndexPath(item: collectionIndex, section: 0)) as? MMMediaCollectionsCell {
                        var filters:[NSPredicate] = []
                        if let collectionID = collection.id {
                            filters.append(NSPredicate.init(format: "identifier == %@", collectionID))
                        }
                        if let collection = MMSDKMediaCollection.createMMSDKMediaCollectionFrom(protocols: MMSDKManager.instance.dataSource.getCollectionsWith(filters: filters)).first {
                            cell.configureWith(collection: collection)
                        }
                    }
                }
            }
        }
    }
}

extension DGStreamRecordingCollectionsViewController: MMSDKDelegate {
    public func mmActionButtonTapped(sender: Any) {
        displayAction(sender: sender)
    }
    public func mmAddButtonTapped(sender: Any) {
        addButtonTapped(sender)
    }
    public func mmBackButtonTapped(sender: Any) {
        
    }
    public func mmCancelButtonTapped(sender: Any) {
        cancelButtonTapped()
    }
    public func mmDoneButtonTapped(sender: Any) {
        
    }
    public func mmFilterButtonTapped(sender: Any) {
        filterButtonTapped(sender)
    }
    public func mmSelectButtonTapped(sender: Any) {
        if let barButton = sender as? UIBarButtonItem {
            selectButtonTapped(barButton)
        }
        else {
            selectButtonTapped(UIBarButtonItem())
        }
    }
    public func mmSortButtonTapped(sender: Any) {
        
    }
    public func mmSortSelectedWith(option: String) {
        
    }
    
    public func mmAddToButtonTapped(sender: Any) {
        addToButtonTapped(sender: sender)
    }
    public func mmCaptureButtonTapped(sender: Any) {
        
    }
    public func mmCollectionsButtonTapped(sender: Any) {
        
    }
    public func mmDeleteButtonTapped(sender: Any) {
        deleteButtonTapped()
    }
    public func mmLibraryButtonTapped(sender: Any) {
        
    }
    public func mmMapButtonTapped(sender: Any) {
        
    }
    public func mmPreviewButtonTapped(sender: Any) {
        
    }
}

