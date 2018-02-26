//
//  DGStreamSelectionViewController.swift
//  DGStream
//
//  Created by Brandon on 2/19/18.
//  Copyright © 2018 Dataglance. All rights reserved.
//

import UIKit
import AVFoundation

public enum LibraryMode: String {
    case collections = "Collections"
    case media = "Media"
}

public class DGStreamSelectionViewController: UIViewController {
    
    @IBOutlet weak var titleToolbar: UIToolbar!
    
    @IBOutlet weak var missingLabel: UILabel!
    
    public var libraryMode: LibraryMode = .collections
    
    var dismissFilterButton:UIButton!
    var data:[Any] = []
    var isSelectingCells: Bool = false
    var selectedMedia:[DGStreamRecording] = []
    var selectedCollections:[DGStreamRecordingCollection] = []
    var addActionButton: UIBarButtonItem!
    var isSwitchingMode: Bool = false
    var hasFilterOpen: Bool = false
    var nextViewController:UIViewController!
    var mediaCollection:DGStreamRecordingCollection?
    var addToButton:UIBarButtonItem?
    var firstSelectedAlbumView:DGStreamAlbumView?
    var wasPresentedFromCollections:Bool = false
    var addCollectionAlert: UIAlertController?
    var titleString:NSMutableAttributedString?
    
    let title: UIFont = {
        if Display.pad {
            return UIFont(name: "HelveticaNeue-Bold", size: 20)!
        }
        else {
            return UIFont(name: "HelveticaNeue-Bold", size: 18)!
        }
    }()
    
    func setMediaCollection(collection: DGStreamRecordingCollection) {
        self.wasPresentedFromCollections = true
        self.mediaCollection = collection
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        print("View Did Load")
        dismissFilterButton = UIButton(frame: self.view.bounds)
        missingLabel.alpha = 0
        self.view.sendSubview(toBack: self.dismissFilterButton)
        self.dismissFilterButton.isUserInteractionEnabled = false
        self.view.backgroundColor = UIColor.white
        self.titleToolbar.tintColor = .white
    }
    
    func setNavigationBar(animated: Bool) {
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 20, width: 320, height: 44))
        titleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 12)
        titleLabel.textColor = UIColor.white
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        titleLabel.lineBreakMode = .byWordWrapping
        
        var text = ""
        if self.libraryMode == .collections {
            text = "Collections"
        }
        else if let collection = self.mediaCollection, self.libraryMode == .media, let name = collection.name, wasPresentedFromCollections {
            text = name
        }
        else {
            text = "Library"
        }
        
        let rangeLength = text.characters.count
        text.append("\n")
        
        if isSelectingCells {
            if libraryMode == .collections {
                text.append("\(self.selectedCollections.count) Collections Selected")
            }
            else {
                text.append("\(self.selectedMedia.count) Media Selected")
            }
        }
        else {
            let subTitle = "\(data.count)"
            text.append(subTitle)
        }
        
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(NSFontAttributeName, value: title, range: NSRange.init(location: 0, length: rangeLength))
        titleString = attributedString
        titleLabel.attributedText = attributedString
        
        //let refresh = UIBarButtonItem(image: UIImage.init(named: "CloudRefresh", in: Bundle.init(identifier: "com.dataglance.MediaManagerSDK"), compatibleWith: nil), style: .plain, target: self, action: nil)
        
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        let titleItem = UIBarButtonItem(customView: titleLabel)
        
        let addBarButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addBarButtonTapped(_:)))
        
        self.titleToolbar.setItems([flex, titleItem, flex, addBarButton], animated: animated)
    }
    
    func showTabBar() {
        // override
    }
    
    func hideTabBar() {
        // override
    }
    
    func allMediaButtonTapped() {
        // override
    }
    
    func previewButtonTapped() {
        // override
    }
    
    func captureButtonTapped() {
        // override
    }
    
    func addToButtonTapped(sender: Any) {
        // override
    }
    
    func deleteButtonTapped() {
        //self.endSelectingCells()
    }
    
    func filterButtonTapped(_ sender: Any) {
        // override
    }
    
    func showMissingLabel() {
        var missingText = "No Media"
        if libraryMode == .collections {
            missingText = "No Collections"
        }
        //        missingText.append("\nFind collections by using the ")
        missingLabel.text = missingText
        view.bringSubview(toFront: missingLabel)
        UIView.animate(withDuration: 0.25, animations: {
            self.missingLabel.alpha = 1
        })
    }
    
    func hideMissingLabel() {
        UIView.animate(withDuration: 0.25, animations: {
            self.missingLabel.alpha = 0
        })
    }
    
    func nextViewControllerAt(point: CGPoint, with indexPath: IndexPath) -> UIViewController? {
        return nil
    }
    
    func dismissFilterButtonTapped() {
        self.view.sendSubview(toBack: self.dismissFilterButton)
        if self.hasFilterOpen {
            self.hasFilterOpen = false
            self.dismissFilterButton.isUserInteractionEnabled = false
            self.view.sendSubview(toBack: self.dismissFilterButton)
        }
        else {
            self.hasFilterOpen = true
            self.dismissFilterButton.isUserInteractionEnabled = true
            self.view.bringSubview(toFront: self.dismissFilterButton)
        }
    }
    
    func selectButtonTapped(_ sender: UIBarButtonItem) {
        if isSelectingCells {
            endSelectingCells()
        }
        else {
            beginSelectingCells()
        }
        setNavigationBar(animated: false)
    }
    
    func cancelButtonTapped() {
        if isSelectingCells {
            endSelectingCells()
        }
        setNavigationBar(animated: false)
    }
    
    func addButtonTapped(_ sender: Any) {
        if isSelectingCells {
            displayAction(sender: sender)
        }
        else if libraryMode == .collections {
            displayAddCollection()
        }
        else {
            displayAddMedia(sender: sender)
        }
    }
    
    func displayAction(sender: Any) {
        print("Display Action")
        let applicationActivities = DGStreamActivity.getAllApplicationActivitiesFor(delegate: self)
        
        let activityVC = UIActivityViewController(activityItems: getMediaImagesForSelected(), applicationActivities: applicationActivities)
        activityVC.modalPresentationStyle = .popover
        if let barButton = sender as? UIBarButtonItem {
            activityVC.popoverPresentationController?.barButtonItem = barButton
            activityVC.popoverPresentationController?.sourceView = self.view
        }
        else if let button = sender as? UIButton {
            if let transitionView = DGStreamManager.instance.parentViewController?.view {
                let rect = self.view.convert(button.frame, to: transitionView)
                activityVC.popoverPresentationController?.sourceRect = rect
                activityVC.popoverPresentationController?.sourceView = transitionView
            }
        }
        //        let exclude:[UIActivityType] = [.assignToContact, .copyToPasteboard, .openInIBooks, .saveToCameraRoll, UIActivityType(rawValue: "com.apple.mobilenotes.SharingExtension")]
        //        activityVC.excludedActivityTypes = exclude
        activityVC.view.alpha = 1
        present(activityVC, animated: true, completion: nil)
    }
    
    func displayAddCollection() {
        let addAlert = UIAlertController(title: nil, message: "New Collection", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action: UIAlertAction) in
            addAlert.dismiss(animated: true, completion: nil)
        }
        let addMediaAction = UIAlertAction(title: "Add", style: .default) { (action: UIAlertAction) in
            self.createNewCollectionFrom(alert: addAlert)
        }
        addAlert.addAction(cancelAction)
        addAlert.addAction(addMediaAction)
        addAlert.addTextField { (textField) in
            textField.placeholder = "Enter Collection Name..."
            textField.returnKeyType = .done
            textField.keyboardType = .alphabet
            textField.delegate = self
        }
        addCollectionAlert = addAlert
        present(addAlert, animated: true) {
            
        }
    }
    
    func displayAddMedia(sender: Any) {
        // override
    }
    
    func addBarButtonTapped(_ sender: Any) {
        // override
    }
    
}

extension DGStreamSelectionViewController {
    func insertItemAt(index: IndexPath) {
        // override
    }
    func reloadItemAt(index: IndexPath) {
        // override
    }
    func cellFor(index: IndexPath) -> MMLibraryCollectionViewCell {
        return MMLibraryCollectionViewCell() // override
    }
    func visibleCells() -> [MMLibraryCollectionViewCell] {
        return [] // override
    }
}

extension DGStreamSelectionViewController { //MARK: - Selection
    func beginSelectingCells() {
        firstSelectedAlbumView = nil
        selectedMedia.removeAll()
        selectedCollections.removeAll()
        isSelectingCells = true
        //MMSDKManager.instance.delegate?.mediaManager(isSelecting: isSelectingCells)
        for cell in self.visibleCells() {
            cell.beginSelectionMode()
        }
    }
    func endSelectingCells() {
        firstSelectedAlbumView = nil
        selectedMedia.removeAll()
        selectedCollections.removeAll()
        isSelectingCells = false
        //MMSDKManager.instance.delegate?.mediaManager(isSelecting: isSelectingCells)
        for cell in self.visibleCells() {
            cell.endSelectionMode()
        }
    }
    func getMediaForSelected() -> [DGStreamRecording] {
        var media:[MMSDKMedia] = []
        if libraryMode == .collections {
            media = MMSDKMedia.createMMSDKMediaFrom(protocols: MMSDKManager.instance.dataSource.getMediaWith(filters: [], limit: nil))
        }
        else {
            media = selectedMedia
        }
        var copiedMedia:[DGStreamRecording] = []
        for m in media {
            let copy = m.deepCopy()
            copiedMedia.append(copy)
        }
        return copiedMedia
    }
    func getMediaImagesForSelected() -> [UIImage] {
        var images:[UIImage] = []
        for media in selectedMedia {
            if let type = media.type, Constants.Media.MMMediaType(rawValue: type) == .photo, let path = MMFileManager.libraryPathWith(media: media)?.appendingPathComponent("_copy") {
                do {
                    let imageData = try Data(contentsOf: path)
                    if let image = UIImage(data: imageData) {
                        images.append(image)
                    }
                } catch { }
            }
        }
        return images
    }
}

extension DGStreamSelectionViewController: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let alert = addCollectionAlert {
            alert.removeFromParentViewController()
        }
        return true
    }
    func createNewCollectionFrom(alert: UIAlertController) {
        print("\nCreate New Collection\n")
        if let textFields = alert.textFields, let textField = textFields.first {
            let newCollection = MMSDKMediaCollection()
            newCollection.id = UUID().uuidString
            let date = Date()
            newCollection.createdDate = date
            newCollection.createdDay = date.trimTime().timeIntervalSince1970
            if let text = textField.text, text.characters.count > 0 {
                newCollection.name = text
            }
            else {
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .short
                dateFormatter.timeStyle = .short
                let dateString = dateFormatter.string(from: date)
                newCollection.name = dateString
            }
            print("Store Collection \(newCollection)")
            MMSDKManager.instance.dataStore.storeCollection(newCollection)
            self.data.insert(newCollection, at: 0)
            self.insertItemAt(index: IndexPath(item: 0, section: 0))
        }
    }
    
}

extension DGStreamSelectionViewController: DGStreamActivityDelegate {
    func didSelect(activity: DGStreamActivity) {
        if let name = activity.title {
            if name == "Sync" {
                
            }
            else {
                let template = MMSDKTemplate()
                template.name = name
                let workflow = MMWorkflowController()
                workflow.temporaryCollection = getMediaForSelected()
                workflow.currentStep = .form
                workflow.setTemplateWith(name: name)
                workflow.viewDidLoad()
                workflow.modalPresentationStyle = .custom
                present(workflow, animated: true, completion: nil)
            }
        }
    }
}
