//
//  DGStreamDetailViewController.swift
//  DGStream
//
//  Created by Brandon on 8/2/18.
//  Copyright © 2018 Dataglance. All rights reserved.
//

import UIKit
import MobileCoreServices

class DGStreamDetailViewController: UIViewController {
    
    @IBOutlet weak var favoriteButton: UIButton!
    
    @IBOutlet weak var userButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tabBar: UITabBar!
    
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var userImage: UIImageView!
    
    @IBOutlet weak var onlineLabel: UILabel!
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var menuButton: UIButton!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var topContainer: UIView!
    
    @IBOutlet weak var bottomContainer: UIView!
    
    @IBOutlet weak var detailTitleContainer: UIView!
    
    @IBOutlet weak var videoCallButtonContainer: UIView!
    
    @IBOutlet weak var audioCallButtonContainer: UIView!
    
    @IBOutlet weak var messageButtonContainer: UIView!
    
    @IBOutlet weak var videoCallLabel: UILabel!
    
    @IBOutlet weak var audioCallLabel: UILabel!
    
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var abrevLabel: UILabel!
    
    @IBOutlet weak var navBarView: UIView!
    
    var videoOrientation:UIDeviceOrientation = .portrait
    
    var user: DGStreamUser?
    
    let itemHeight:CGFloat = {
        if Display.pad {
            return CGFloat(50)
        }
        else {
            return CGFloat(40)
        }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Detail Loaded")
        
        var items:[UITabBarItem] = []
        
        let help = UITabBarItem(title: "Support", image: UIImage(named: "info", in: Bundle(identifier: "com.dataglance.DGStream"), compatibleWith: nil), tag: 0)
        items.append(help)
        
        let camera = UITabBarItem(title: "Camera", image: UIImage(named: "capture", in: Bundle(identifier: "com.dataglance.DGStream"), compatibleWith: nil), tag: 1)
        items.append(camera)
        
        self.tabBar.tintColor = .orange
        self.tabBar.unselectedItemTintColor = .lightGray
        self.tabBar.setItems(items, animated: false)
        self.tabBar.delegate = self
        
        self.view.addObserver(self, forKeyPath: "frame", options: .new, context: nil)
        
        self.setUpViews()
        self.setUpButtons()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "UserDropDown" {
            
            let size = CGSize(width: 320, height: 270)
//            if Display.pad {
//                size = CGSize(width: 320, height: 270)
//            }
            
            let dropDownVC = segue.destination as! DGStreamUserDropDownViewController
            dropDownVC.preferredContentSize = size
            dropDownVC.modalPresentationStyle = .popover
            dropDownVC.popoverPresentationController!.delegate = self
            dropDownVC.isModalInPopover = false
            dropDownVC.delegate = self
        }
    }
    
    func setUpViews() {
        
        self.view.backgroundColor = UIColor.dgBG()
        
        self.navBarView.backgroundColor = UIColor.dgBlueDark()
        
        self.userImage.clipsToBounds = true
        self.userImage.layer.cornerRadius = self.userImage.frame.size.width / 2
        
        self.detailTitleContainer.backgroundColor = UIColor.dgBlueDark()

        self.topContainer.layer.borderColor = UIColor.dgBlack().cgColor
        self.topContainer.layer.borderWidth = 0.5
        
        self.bottomContainer.layer.borderWidth = 0.5
        self.bottomContainer.layer.borderColor = UIColor.dgBlack().cgColor
        
        self.titleLabel.text = ""
        
        self.stackView.alpha = 0
        
        self.videoCallButtonContainer.alpha = 0
        self.audioCallButtonContainer.alpha = 0
        self.messageButtonContainer.alpha = 0
        self.videoCallLabel.alpha = 0
        self.audioCallLabel.alpha = 0
        self.messageLabel.alpha = 0
        
    }
    
    func setUpButtons() {
        
        self.favoriteButton.setImage(self.favoriteButton.currentImage?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.favoriteButton.tintColor = .white
        
        let videoCallButton = UIButton(frame: self.videoCallButtonContainer.bounds)
        videoCallButton.boundInside(container: self.videoCallButtonContainer)
        videoCallButton.setImage(UIImage(named: "video", in: Bundle(identifier: "com.dataglance.DGStream"), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        videoCallButton.backgroundColor = .orange
        videoCallButton.tintColor = UIColor.dgBlack()
        videoCallButton.addTarget(self, action: #selector(videoCallButtonTapped), for: .touchUpInside)
        self.videoCallButtonContainer.clipsToBounds = true
        self.videoCallButtonContainer.layer.borderColor = UIColor.dgBlack().cgColor
        self.videoCallButtonContainer.layer.borderWidth = 1
        self.videoCallButtonContainer.layer.cornerRadius = self.videoCallButtonContainer.bounds.size.width / 2
        
        let audioCallButton = UIButton(frame: self.audioCallButtonContainer.bounds)
        audioCallButton.boundInside(container: self.audioCallButtonContainer)
        audioCallButton.setImage(UIImage(named: "audio", in: Bundle(identifier: "com.dataglance.DGStream"), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        audioCallButton.backgroundColor = .orange
        audioCallButton.tintColor = UIColor.dgBlack()
        audioCallButton.addTarget(self, action: #selector(audioCallButtonTapped), for: .touchUpInside)
        self.audioCallButtonContainer.clipsToBounds = true
        self.audioCallButtonContainer.layer.borderColor = UIColor.dgBlack().cgColor
        self.audioCallButtonContainer.layer.borderWidth = 1
        self.audioCallButtonContainer.layer.cornerRadius = self.audioCallButtonContainer.bounds.size.width / 2
        
        let messageButton = UIButton(frame: self.messageButtonContainer.bounds)
        messageButton.boundInside(container: self.messageButtonContainer)
        messageButton.setImage(UIImage(named: "message", in: Bundle(identifier: "com.dataglance.DGStream"), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        messageButton.backgroundColor = .orange
        messageButton.tintColor = UIColor.dgBlack()
        messageButton.addTarget(self, action: #selector(messageButtonTapped), for: .touchUpInside)
        self.messageButtonContainer.clipsToBounds = true
        self.messageButtonContainer.layer.borderColor = UIColor.dgBlack().cgColor
        self.messageButtonContainer.layer.borderWidth = 1
        self.messageButtonContainer.layer.cornerRadius = self.messageButtonContainer.bounds.size.width / 2
    }
    
    func load(user: DGStreamUser) {
        guard let userID = user.userID else { return }
        if userID == self.user?.userID {
            return
        }
        self.user = user
        self.usernameLabel.text = user.username
        self.titleLabel.text = user.username
        
        if let userImage = user.image, let image = UIImage(data: userImage){
            self.userImage.image = image
            self.userImage.alpha = 1
            self.userImage.clipsToBounds = true
            self.userImage.layer.cornerRadius = self.userImage.frame.size.width / 2
            self.userImage.layer.borderColor = UIColor.dgBlack().cgColor
            self.userImage.layer.borderWidth = 0.5
            self.abrevLabel.alpha = 0
        }
        else {
            self.userImage.image = nil
            let abrev = NSString(string: user.username ?? "??").substring(to: 1)
            self.abrevLabel.text = abrev
            self.abrevLabel.alpha = 1
        }
        if let lastSeen = user.lastSeen {
            let dateFormatter = DateFormatter()
            dateFormatter.timeStyle = .short
            dateFormatter.dateStyle = .short
            self.onlineLabel.text = dateFormatter.string(from: lastSeen)
        }
        self.loadCollectionView()
        self.stackView.alpha = 1
        self.videoCallButtonContainer.alpha = 1
        self.videoCallLabel.alpha = 1
        self.audioCallButtonContainer.alpha = 1
        self.audioCallLabel.alpha = 1
        self.messageButtonContainer.alpha = 1
        self.messageLabel.alpha = 1
        
        if DGStreamCore.instance.isFavorite(userID: userID) {
            self.favoriteButton.tintColor = .orange
        }
        else {
            self.favoriteButton.tintColor = .white
        }
    }
    
    func loadCollectionView() {
//        guard let split = self.splitViewController, let tab = split.viewControllers[0] as? DGStreamTabBarViewController else { return }
//        tab.canSelect = false
//        let layout = UICollectionViewFlowLayout()
//        layout.itemSize = CGSize(width: self.collectionView.bounds.width, height: 50)
//        layout.scrollDirection = .horizontal
//        self.collectionView.collectionViewLayout.invalidateLayout()
//        self.collectionView.setCollectionViewLayout(layout, animated: false) { (success) in
//            tab.canSelect = true
//            self.collectionView.reloadData()
//
//        }
        self.collectionView.collectionViewLayout.invalidateLayout()
        self.collectionView.reloadData()
    }
    
    
    @IBAction func menuButtonTapped(_ sender: Any) {
        if let split = self.splitViewController {
            if split.displayMode == .primaryHidden {
                split.preferredDisplayMode = .allVisible
            }
            else {
                split.preferredDisplayMode = .primaryHidden
            }
        }
    }
    
    @IBAction func favoriteButtonTapped(_ sender: Any) {
        
        guard let user = user, let userID = user.userID else { return }
        
        if DGStreamCore.instance.toggleFavoriteFor(userID: userID) {
            self.favoriteButton.tintColor = .orange
        }
        else {
            self.favoriteButton.tintColor = .white
        }
        
        guard let split = self.splitViewController,
            let tab = split.viewControllers[0] as? DGStreamTabBarViewController,
            tab.selectedItem == .favorites
            else { return }
        tab.loadFavorites(searchText: tab.searchBar.text)
        tab.collectionView.reloadData()
    }
    
    @IBAction func userButtonTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "UserDropDown", sender: nil)
    }
    
    func videoCallButtonTapped() {
        guard let user = user,
            let userID = user.userID,
            let split = self.splitViewController,
            let tab = split.viewControllers[0] as? DGStreamTabBarViewController
            else { return }
        tab.callUsers(userIDs: [userID], for: .video)
    }
    
    func audioCallButtonTapped() {
        guard let user = user,
            let userID = user.userID,
            let split = self.splitViewController,
            let tab = split.viewControllers[0] as? DGStreamTabBarViewController
            else { return }
        tab.callUsers(userIDs: [userID], for: .audio)
    }
    
    func messageButtonTapped() {
        guard let user = user,
            let userID = user.userID,
            let split = self.splitViewController,
            let tab = split.viewControllers[0] as? DGStreamTabBarViewController
            else { return }
        tab.messageButtonTappedWith(userID: userID)
    }
    
}

extension DGStreamDetailViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let user = user,
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? DGStreamUserDetailCollectionViewCell
        else { return UICollectionViewCell() }
        cell.configureWith(detail: user.details[indexPath.item])
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let user = user else { return 0 }
        return user.details.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width, height: itemHeight)
    }
    
}

extension DGStreamDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            if Display.phone {
                return 240
            }
            else {
                return 320
            }
        }
        else if indexPath.row == 1 {
            return 50
        }
        else if indexPath.row == 2 {
            if Display.phone {
                return 200
            }
            else {
                return 200
            }
        }
        else {
            return 0
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = "\(indexPath.row)"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: index) else { return UITableViewCell() }
//        if index == "1" {
//            cell.contentView.backgroundColor = UIColor.dgBlueDark()
//        }
        return cell
    }
}

extension DGStreamDetailViewController: UITabBarDelegate {
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if item.tag == 0 {
            
        }
        else {
            let alert = UIAlertController(title: "Choose Option", message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Video", style: .default, handler: { (action: UIAlertAction) in
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.view.tag = 99
                imagePicker.sourceType = .camera
                imagePicker.videoQuality = .type640x480
                imagePicker.allowsEditing = false
                imagePicker.mediaTypes = [kUTTypeMovie] as [String]
                imagePicker.modalPresentationStyle = .custom
                self.videoOrientation = UIDevice.current.orientation
                self.present(imagePicker, animated: true) {
                    tabBar.selectedItem = tabBar.items?.first
                    //self.navTitleLabel.text = NSLocalizedString("Contacts", comment: "")
                    self.collectionView.reloadData()
                }
            }))
            alert.addAction(UIAlertAction(title: "Photo", style: .default, handler: { (action: UIAlertAction) in
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.view.tag = 199
                imagePicker.sourceType = .camera
                imagePicker.allowsEditing = false
                imagePicker.modalPresentationStyle = .custom
                self.present(imagePicker, animated: true) {
                    tabBar.selectedItem = nil
                    //self.navTitleLabel.text = NSLocalizedString("Contacts", comment: "")
                    self.collectionView.reloadData()
                }
            }))
            alert.popoverPresentationController?.sourceView = self.view
            alert.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.size.width - 80, y: self.tabBar.frame.y, width: 44, height: 44)
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension DGStreamDetailViewController: DGStreamUserDropDownViewControllerDelegate {
    
    func mediaButtonTapped() {
        if let media = UIStoryboard(name: "Media", bundle: Bundle(identifier: "com.dataglance.DGStream")).instantiateInitialViewController() {
            self.present(media, animated: true, completion: nil)
        }
    }
    
    func userButtonTapped() {
        
        func presentActionsheet() {
            let alert = UIAlertController(title: "", message: "Choose Source", preferredStyle: .actionSheet)
            alert.popoverPresentationController?.sourceView = self.view
            //alert.popoverPresentationController?.sourceRect = self.rightButtonAnchorView.frame
            alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action: UIAlertAction) in
                guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
                    print("This device doesn't have a camera.")
                    return
                }
                
                let photoPicker = UIImagePickerController()
                photoPicker.sourceType = .camera
                photoPicker.delegate = self
                photoPicker.modalPresentationStyle = .custom
                self.present(photoPicker, animated: true) {
                    
                }
            }))
            alert.addAction(UIAlertAction(title: "Library", style: .default, handler: { (action: UIAlertAction) in
                guard UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) else {
                    print("This device doesn't have a camera.")
                    return
                }
                
                let photoPicker = UIImagePickerController()
                photoPicker.sourceType = .savedPhotosAlbum
                photoPicker.delegate = self
                photoPicker.modalPresentationStyle = .custom
                self.present(photoPicker, animated: true) {
                    
                }
            }))
            self.present(alert, animated: true) {
                
            }
        }
        
        if let presentedViewController = self.presentedViewController {
            presentedViewController.dismiss(animated: true, completion: {
                presentActionsheet()
            })
        }
        else {
            presentActionsheet()
        }
        
    }
    
    func logoutTapped() {
        DGStreamCore.instance.unregisterFromRemoteNotifications {
            QBChat.instance.disconnect { (error) in
                QBRequest.logOut(successBlock: { (response) in
                    UserDefaults.standard.removeObject(forKey: "LastUser")
                    UserDefaults.standard.synchronize()
                    self.dismiss(animated: false, completion: nil)
                }) { (errorResponse) in
                    
                }
            }
        }
    }
}

extension DGStreamDetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true) {
            
        }
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        defer {
            picker.dismiss(animated: true)
        }
        
        if picker.view.tag == 99 {
            
            guard let image = info[UIImagePickerControllerMediaURL] as? URL else {
                return
            }
            
            if let url = info[UIImagePickerControllerMediaURL] as? URL {
                
                let recordingTitle = UUID().uuidString.components(separatedBy: "-").first!
                
                var recordingURL = DGStreamFileManager.applicationDocumentsDirectory()
                recordingURL.appendPathComponent("\(recordingTitle)")
                recordingURL.appendPathExtension("mov")
                
                do {
                    try FileManager.default.moveItem(at: url, to: recordingURL)
                }
                catch let error {
                    print("ERROR Moving item \(error.localizedDescription)")
                }
                
                encodeVideo(videoUrl: recordingURL) { (resultURL) in
                    if let encodedURL = resultURL {
                        let avAsset = AVAsset(url: encodedURL)
                        let assetGenerator = AVAssetImageGenerator(asset: avAsset)
                        assetGenerator.generateCGImagesAsynchronously(forTimes: [kCMTimeZero as NSValue], completionHandler: { (time, image, time2, result, error) in
                            
                            if error == nil, let image = image {
                                
                                let originalThumbnail = UIImage(cgImage: image)
                                
                                var newThumbnail: UIImage!
                                
                                if self.videoOrientation == .portrait {
                                    newThumbnail = originalThumbnail.rotated(by:  Measurement(value: 90.0, unit: .degrees))
                                }
                                else if self.videoOrientation == .landscapeRight {
                                    newThumbnail = originalThumbnail.rotated(by:  Measurement(value: 180.0, unit: .degrees))
                                }
                                else if self.videoOrientation == .portraitUpsideDown {
                                    newThumbnail = originalThumbnail.rotated(by:  Measurement(value: 270.0, unit: .degrees))
                                }
                                else {
                                    newThumbnail = originalThumbnail
                                }
                                
                                if let error = error {
                                    print("Failed To Merge Audio and Video \(error.localizedDescription)")
                                }
                                print("MERGED AUDIO AND VIDEO")
                                let thumbnailData = UIImageJPEGRepresentation(newThumbnail, 0.5)
                                DispatchQueue.main.async {
                                    saveRecordingsWith(fileName: recordingTitle, thumbnail: thumbnailData)
                                }
                                
                                
                            }
                            
                        })
                    }
                }
                
                func saveRecordingsWith(fileName: String, thumbnail: Data?) {
                    
                    print("SAVING RECORDING")
                    
                    let date = Date()
                    
                    let recordingCollection = DGStreamRecordingCollection()
                    recordingCollection.createdBy = DGStreamCore.instance.currentUser?.userID ?? 0
                    recordingCollection.createdDate = date
                    recordingCollection.documentNumber = "01234-56789"
                    recordingCollection.numberOfRecordings = Int16(1)
                    recordingCollection.thumbnail = thumbnail
                    recordingCollection.title = "01234-56789"
                    
                    let recording = DGStreamRecording()
                    recording.createdBy = DGStreamCore.instance.currentUser?.userID ?? 0
                    recording.createdDate = date
                    recording.documentNumber = "01234-56789"
                    recording.title = fileName
                    recording.thumbnail = thumbnail
                    recording.url = fileName
                    recording.isPhoto = false
                    DGStreamManager.instance.dataStore.streamManager(DGStreamManager.instance, store: recording, into: recordingCollection)
                }
                
            }
            
        }
        else if picker.view.tag == 199 {
            guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
                return
            }
            
            let recordingTitle = UUID().uuidString.components(separatedBy: "-").first!
            
            func saveRecordingsWith(fileName: String, thumbnail: Data?) {
                
                print("SAVING RECORDING")
                
                let date = Date()
                
                let recordingCollection = DGStreamRecordingCollection()
                recordingCollection.createdBy = DGStreamCore.instance.currentUser?.userID ?? 0
                recordingCollection.createdDate = date
                recordingCollection.documentNumber = "01234-56789"
                recordingCollection.numberOfRecordings = Int16(1)
                recordingCollection.thumbnail = thumbnail
                recordingCollection.title = "01234-56789"
                
                let recording = DGStreamRecording()
                recording.createdBy = DGStreamCore.instance.currentUser?.userID ?? 0
                recording.createdDate = date
                recording.documentNumber = "01234-56789"
                recording.title = fileName
                recording.thumbnail = thumbnail
                recording.url = fileName
                recording.isPhoto = true
                DGStreamManager.instance.dataStore.streamManager(DGStreamManager.instance, store: recording, into: recordingCollection)
            }
            
            var path = DGStreamFileManager.applicationDocumentsDirectory()
            path.appendPathComponent(recordingTitle)
            path.appendPathExtension("jpeg")
            
            if let data = UIImageJPEGRepresentation(image, 1.0),
                !FileManager.default.fileExists(atPath: path.path) {
                do {
                    // writes the image data to disk
                    try data.write(to: path)
                    print("file saved")
                } catch {
                    print("error saving file:", error)
                }
            }
            
            saveRecordingsWith(fileName: recordingTitle, thumbnail: UIImageJPEGRepresentation(image, 0.5))
        }
        else {
            print(info)
            // get the image
            guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
                return
            }
            
            let newWidth = image.size.width / 2
            let newHeight = image.size.height / 2
            
            let smallerImage = UIImage.resizeImage(image: image, targetSize: CGSize(width: newWidth, height: newHeight))
            
            // do something with it
            self.sendUser(image: smallerImage)
        }
    }
    
    func encodeVideo(videoUrl: URL, outputUrl: URL? = nil, resultClosure: @escaping (URL?) -> Void ) {
        
        var finalOutputUrl: URL? = outputUrl
        
        if finalOutputUrl == nil {
            var url = videoUrl
            url.deletePathExtension()
            url.appendPathExtension("mp4")
            finalOutputUrl = url
        }
        
        if FileManager.default.fileExists(atPath: finalOutputUrl!.path) {
            print("Converted file already exists \(finalOutputUrl!.path)")
            resultClosure(finalOutputUrl)
            return
        }
        
        let asset = AVURLAsset(url: videoUrl)
        if let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetPassthrough) {
            exportSession.outputURL = finalOutputUrl!
            exportSession.outputFileType = AVFileTypeMPEG4
            let start = CMTimeMakeWithSeconds(0.0, 0)
            let range = CMTimeRangeMake(start, asset.duration)
            exportSession.timeRange = range
            exportSession.shouldOptimizeForNetworkUse = true
            exportSession.exportAsynchronously() {
                
                switch exportSession.status {
                case .failed:
                    print("Export failed: \(exportSession.error != nil ? exportSession.error!.localizedDescription : "No Error Info")")
                case .cancelled:
                    print("Export canceled")
                case .completed:
                    resultClosure(finalOutputUrl!)
                default:
                    break
                }
            }
        } else {
            resultClosure(nil)
        }
    }
    
    func sendUser(image: UIImage) {
        
        if let currentUser = DGStreamCore.instance.currentUser,
            let currentUserID = currentUser.userID,
            let fileID = UUID().uuidString.components(separatedBy: "-").first {
            
            func uploadUserImage(userID: NSNumber, fileID: String) {
                
                print("UPLOADING USER IMAGE")
                
                let userImage = QBCOCustomObject()
                userImage.className = "UserImage"
                userImage.createdAt = Date()
                userImage.userID = userID.uintValue
                userImage.id = fileID
                
                let imageFile = QBCOFile()
                if let imageData = UIImagePNGRepresentation(image) {
                    
                    imageFile.contentType = "image/png"
                    imageFile.data = imageData
                    imageFile.name = "image"
                    
                    let fields:NSMutableDictionary = NSMutableDictionary()
                    fields.setObject(imageFile, forKey: "image" as NSCopying)
                    
                    userImage.fields = fields
                }
                else {
                    
                }
                
                QBRequest.createObject(userImage, successBlock: { (response, object) in
                    
                    QBRequest.uploadFile(imageFile, className: "UserImage", objectID: object?.id ?? "", fileFieldName: "image", successBlock: { (response, uploadInfo) in
                        
                        if response.isSuccess, let object = object, let objectID = object.id {
                            print("SUCCESSFULLY UPLOADED USER IMAGE")
                            currentUser.image = UIImagePNGRepresentation(image)
                            //self.rightButton.setImage(image, for: .normal)
                        }
                        else if let responseError = response.error, let error = responseError.error {
                            print("Upload Failed with error \(error.localizedDescription)")
                            //self.delegate.drawOperationFailedWith(errorMessage: "Failed To Create Image Object")
                        }
                        else {
                            //self.delegate.drawOperationFailedWith(errorMessage: "Failed To Create Image Object")
                        }
                        
                    }, statusBlock: { (response, status) in
                        
                    }, errorBlock: { (error) in
                        print("DID FAIL TO UPLOAD IMAGE \(error.error?.error?.localizedDescription ?? "ERROR")")
                        // self.delegate.drawOperationFailedWith(errorMessage: "Failed To Upload Image")
                    })
                    
                }, errorBlock: { (response) in
                    if let responseError = response.error, let error = responseError.error {
                        print("Upload Failed with error \(error.localizedDescription)")
                    }
                    //self.delegate.drawOperationFailedWith(errorMessage: "Failed To Create Image Object")
                })
                
            }
            
            let extendedRequest = NSMutableDictionary()
            extendedRequest.setObject(currentUser.userID?.uintValue ?? 0, forKey: "user_id" as NSCopying)
            
            QBRequest.objects(withClassName: "UserImage", extendedRequest: extendedRequest, successBlock: { (response, objects, responsePage) in
                
                // Already Exists, Delete
                if let object = objects?.first, let objectID = object.id {
                    QBRequest.deleteObject(withID: objectID, className: "UserImage", successBlock: { (response) in
                        uploadUserImage(userID: currentUserID, fileID: fileID)
                    }, errorBlock: { (errorResponse) in
                        uploadUserImage(userID: currentUserID, fileID: fileID)
                    })
                }
                else {
                    // Doesn't Already Exist, Create
                    uploadUserImage(userID: currentUserID, fileID: fileID)
                }
                
            }, errorBlock: { (errorResponse) in
                
            })
            
        }
        
    }
    
}

extension DGStreamDetailViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

extension DGStreamDetailViewController {
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "frame" {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.10) {
                self.loadCollectionView()
                if let split = self.splitViewController, let tab = split.viewControllers[0] as? DGStreamTabBarViewController {
                    tab.setLayout()
                }
            }
        }
    }
}
