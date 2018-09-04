//
//  DGStreamMediaViewController.swift
//  DGStream
//
//  Created by Brandon on 8/17/18.
//  Copyright © 2018 Dataglance. All rights reserved.
//

import UIKit
import AVKit
import MobileCoreServices

protocol DGStreamMediaViewControllerDelegate {
    func didSelect(photo: UIImage)
    func didSelect(video: URL)
    func didSelect(pdf: URL)
}

enum MediaType {
    case photo
    case video
    case document
}

class DGStreamMediaViewController: UIViewController {

    @IBOutlet weak var navBarView: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var tabBar: UIToolbar!
    @IBOutlet weak var addButtonItem: UIBarButtonItem!
    @IBOutlet weak var uploadButtonItem: UIBarButtonItem!
    @IBOutlet weak var deleteButtonItem: UIBarButtonItem!
    @IBOutlet weak var emptyLabel: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var collectionViewContainer: UIView!
    
    var shouldLoad = true
    
    var isSelecting = false
    
    var videoOrientation:UIDeviceOrientation = .portrait
    
    var isShare:Bool = false
    
    var recordings: [DGStreamRecording] = []
    
    var delegate: DGStreamMediaViewControllerDelegate?
    
    var selectedImageView: UIImageView?
    
    var tap: UITapGestureRecognizer?
    
    var mediaType: MediaType = .photo
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DGStreamCore.instance.presentedViewController = self
        
        self.navBarView.backgroundColor = UIColor.dgBlueDark()
        
        self.view.backgroundColor = UIColor.dgBG()
        
        self.collectionViewContainer.layer.borderColor = UIColor.dgBlack().cgColor
        self.collectionViewContainer.layer.borderWidth = 0.5
        
        if isShare {
            self.titleLabel.text = "Share"
            self.tabBar.isHidden = true
        }
        else {
            self.titleLabel.text = "Media"
        }
        
        self.deleteButtonItem.isEnabled = false
        
        self.setUpButtons()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if shouldLoad {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.20) {
                self.load(mediaType: .photo)
            }
        }
        shouldLoad = false
    }
    
    func setUpButtons() {
        
        self.backButton.setTitleColor(.white, for: .normal)
        
        self.segmentedControl.addTarget(self, action: #selector(segmentedValueChanged), for: .valueChanged)
        self.segmentedControl.tintColor = .orange
                
        self.addButtonItem.tintColor = .orange
        
        self.uploadButtonItem.tintColor = .orange
        self.uploadButtonItem.isEnabled = false
        self.deleteButtonItem.tintColor = .orange
        self.deleteButtonItem.isEnabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func load(mediaType: MediaType) {
//        guard let currentUser = DGStreamCore.instance.currentUser, let currentUserID = currentUser.userID else {
//            return
//        }
//        let userPredicate = NSPredicate(format: "createdBy == \"\(currentUserID)\"")
//        var boolString = "false"
//        if isPhoto {
//            boolString = "true"
//        }
//        let isPhotoPredicate = NSPredicate(format: "isPhoto == \(boolString)")
//        self.recordings = DGStreamRecording.createDGStreamRecordingsFor(protocols: DGStreamManager.instance.dataSource.streamManager(DGStreamManager.instance, recordingsWithPredicates: [userPredicate, isPhotoPredicate]))
//        self.collectionView.reloadData()
        
        guard let currentUser = DGStreamCore.instance.currentUser, let currentUserID = currentUser.userID else {
            return
        }
        
        self.isSelecting = false
        self.selectButton.setTitle("Select", for: .normal)
        self.deleteButtonItem.isEnabled = false
        
        let userPredicate = NSPredicate(format: "createdBy == \"\(currentUserID)\"")
        var isPhoto = "false"
        var isDocument = "false"
        if mediaType == .photo {
            isPhoto = "true"
        }
        else if mediaType == .document {
            isDocument = "true"
        }
        let isPhotoPredicate = NSPredicate(format: "isPhoto == \(isPhoto)")
        let isDocumentPredicate = NSPredicate(format: "isDocument == \(isDocument)")
        let predicates = [userPredicate, isPhotoPredicate, isDocumentPredicate]
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        
        NotificationCenter.default.post(name: Notification.Name("DGStreamLoad"), object: compoundPredicate)
    }
    
    func loadDocuments() {
        
    }
    
    func segmentedValueChanged() {
        self.addButtonItem.isEnabled = true
        let segment = self.segmentedControl.selectedSegmentIndex
        if segment == 0 {
            self.mediaType = .photo
            if self.recordings.count == 0 {
                self.emptyLabel.text = "No Photos"
            }
        }
        else if segment == 1 {
            self.mediaType = .video
            if self.recordings.count == 0 {
                self.emptyLabel.text = "No Videos"
            }
        }
        else if segment == 2 {
            self.mediaType = .document
            self.emptyLabel.text = "No Documents"
            self.addButtonItem.isEnabled = false
        }
        self.load(mediaType: self.mediaType)
    }
    
    @IBAction func showLocalValueChanged(_ sender: Any) {
        
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func selectButtonTapped(_ sender: Any) {
        if self.isSelecting {
            self.addButtonItem.isEnabled = true
            self.deleteButtonItem.isEnabled = false
            self.uploadButtonItem.isEnabled = false
            self.isSelecting = false
            self.selectButton.setTitle("Select", for: .normal)
        }
        else {
            self.addButtonItem.isEnabled = false
            self.isSelecting = true
            self.selectButton.setTitle("Done", for: .normal)
        }
        NotificationCenter.default.post(name: Notification.Name("DGStreamSelect"), object: self.isSelecting)
    }
    
    @IBAction func addButtonTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Choose Source", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action: UIAlertAction) in
            
            if self.mediaType == .photo {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.view.tag = 199
                imagePicker.sourceType = .camera
                imagePicker.videoQuality = .type640x480
                imagePicker.allowsEditing = false
                imagePicker.modalPresentationStyle = .custom
                self.videoOrientation = UIDevice.current.orientation
                self.shouldLoad = false
                self.present(imagePicker, animated: true) {
                }
            }
            else if self.mediaType == .video {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.view.tag = 99
                imagePicker.sourceType = .camera
                imagePicker.videoQuality = .type640x480
                imagePicker.allowsEditing = false
                imagePicker.mediaTypes = [kUTTypeMovie] as [String]
                imagePicker.modalPresentationStyle = .custom
                self.videoOrientation = UIDevice.current.orientation
                self.shouldLoad = false
                self.present(imagePicker, animated: true) {
                }
            }
            
        }))
        alert.addAction(UIAlertAction(title: "Local", style: .default, handler: { (action: UIAlertAction) in
            
            if self.mediaType == .photo {
                let videoPicker = UIImagePickerController()
                videoPicker.delegate = self
                videoPicker.sourceType = .photoLibrary
                videoPicker.view.tag = 199
                self.shouldLoad = false
                self.present(videoPicker, animated: true, completion: nil)
            }
            else if self.mediaType == .video {
                let videoPicker = UIImagePickerController()
                videoPicker.delegate = self
                videoPicker.sourceType = .photoLibrary
                videoPicker.mediaTypes = [kUTTypeMovie as String]
                videoPicker.view.tag = 99
                self.shouldLoad = false
                self.present(videoPicker, animated: true, completion: nil)
            }
            
        }))
        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.barButtonItem = self.addButtonItem
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func deleteButtonTapped(_ sender: Any) {
        NotificationCenter.default.post(name: Notification.Name("DGStreamDelete"), object: nil)
        self.isSelecting = false
        self.selectButton.setTitle("Select", for: .normal)
        self.deleteButtonItem.isEnabled = false
        self.addButtonItem.isEnabled = true
        self.uploadButtonItem.isEnabled = false
    }
    
    func didSelect(recording: DGStreamRecording) {
        
        if self.isSelecting {
            self.deleteButtonItem.isEnabled = true
            self.uploadButtonItem.isEnabled = true
        }
        
        if recording.isPhoto {
            guard let recordingUrl = recording.url else {
                print("NO RECORDING URL")
                return
            }
            let url = DGStreamFileManager.createPathFor(mediaType: .photo, fileName: recordingUrl)!
            let urlString = NSString(string: url.absoluteString).substring(from: 7).replacingOccurrences(of: "%20", with: " ")
            
//            guard let imageData = FileManager.default.contents(atPath: url.absoluteString) else {
//                print("NO IMAGE DATA")
//                return
//            }
            
            guard let image = UIImage.init(contentsOfFile: urlString) else {
                print("NO IMAGE!")
                return
            }
            
            if self.isShare {
                self.dismiss(animated: true) {
                    self.delegate?.didSelect(photo: image)
                }
            }
            else {
                self.selectedImageView = UIImageView(frame: self.view.bounds)
                self.selectedImageView?.image = image
                self.selectedImageView?.boundInside(container: self.view)
                self.view.bringSubview(toFront: self.selectedImageView!)
                self.tap = UITapGestureRecognizer(target: self, action: #selector(removeImage))
                self.tap?.delegate = self
                self.view.addGestureRecognizer(self.tap!)
            }
            
        }
        else if recording.isDocument {
            guard let recordingUrl = recording.url else {
                print("NO RECORDING URL")
                return
            }
            let url = DGStreamFileManager.createPathFor(mediaType: .document, fileName: recordingUrl)!
            if self.isShare {
                self.dismiss(animated: true) {
                    self.delegate?.didSelect(pdf: url)
                }
            }
        }
        else {
            guard let recordingUrl = recording.url else {
                print("NO RECORDING URL")
                return
            }
            let url = DGStreamFileManager.createPathFor(mediaType: .video, fileName: recordingUrl)!
            if self.isShare {
                self.dismiss(animated: true) {
                    self.delegate?.didSelect(video: url)
                }
            }
            else {
                let asset = AVAsset(url: url)
                let playerItem = AVPlayerItem(asset: asset)
                
                let avPlayerVC = AVPlayerViewController()
                
                let player = AVPlayer(playerItem: playerItem)
                
                avPlayerVC.player = player
                
                self.present(avPlayerVC, animated: true) {
                    player.play()
                }
            }
            
        }
        
    }
    
    func removeImage() {
        self.selectedImageView?.removeFromSuperview()
        self.selectedImageView = nil
        if let t = self.tap {
            self.view.removeGestureRecognizer(t)
            self.tap = nil
        }
    }

}

extension DGStreamMediaViewController: UIGestureRecognizerDelegate {
    
}

extension DGStreamMediaViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
                
                var recordingURL = DGStreamFileManager.createPathFor(mediaType: .video, fileName: recordingTitle)!
                recordingURL.deletePathExtension()
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
                                    
                                    if self.mediaType == .photo {
                                        self.load(mediaType: .photo)
                                    }
                                    else if self.mediaType == .video {
                                        self.load(mediaType: .video)
                                    }
                                    
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
            
            let path = DGStreamFileManager.createPathFor(mediaType: .photo, fileName: recordingTitle)!
            
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
