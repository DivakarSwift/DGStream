//
//  DGStreamRecordingCollectionsViewController.swift
//  DGStream
//
//  Created by Brandon on 2/21/18.
//  Copyright © 2018 Dataglance. All rights reserved.
//

import UIKit
import MobileCoreServices

protocol DGStreamRecordingCollectionsViewControllerDelegate {
    func recordingCollectionsViewController(_ vc: DGStreamRecordingCollectionsViewController, recordingSelected url: URL)
}

class DGStreamRecordingCollectionsViewController: UIViewController {
    
    @IBOutlet weak var navBarBackButton: UIButton!
    @IBOutlet weak var navBarTitle: UILabel!
    @IBOutlet weak var navBar: UIView!
    @IBOutlet weak var tableView: UITableView!
    var collections: [DGStreamRecordingCollection] = []
    var delegate:DGStreamRecordingCollectionsViewControllerDelegate?
    var isPhotos: Bool = false
    
    var videoOrientation: UIDeviceOrientation = .portrait
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navBar.backgroundColor = UIColor.dgBlueDark()
        self.navBarTitle.text = "Recording Collections"
        self.navBarBackButton.setTitle("Back", for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if delegate == nil {
            DGStreamCore.instance.presentedViewController = self
        }
        self.loadRecordingCollections()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "recordings",
            let vc = segue.destination as? DGStreamRecordingsViewController,
            let collection = sender as? DGStreamRecordingCollection {
            if self.delegate != nil {
                vc.delegate = self
            }
            vc.collection = collection
        }
    }
    
    func loadRecordingCollections() {
        let collections = DGStreamRecordingCollection.createDGStreamRecordingCollectionsFrom(protocols: DGStreamManager.instance.dataSource.streamManager(DGStreamManager.instance, recordingCollectionsForUserID: DGStreamCore.instance.currentUser?.userID ?? 0))
        self.collections = collections
        self.tableView.reloadData()
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
            nav.dismiss(animated: true) {
                
            }
        }
        else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func newButtonTapped(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.videoQuality = .type640x480
        imagePicker.allowsEditing = false
        imagePicker.mediaTypes = [kUTTypeMovie] as [String]
        imagePicker.modalPresentationStyle = .custom
        self.videoOrientation = UIDevice.current.orientation
        present(imagePicker, animated: true) {
            
        }
    }
    
}

extension DGStreamRecordingCollectionsViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        defer {
            picker.dismiss(animated: true, completion: nil)
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
                
                do {
                    try FileManager.default.removeItem(at: recordingURL)
                }
                catch let error {
                    print("ERROR Removing item \(error.localizedDescription)")
                }
                
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
                DGStreamManager.instance.dataStore.streamManager(DGStreamManager.instance, store: recording, into: recordingCollection)
            }
            
        }
        else {
            print("ERROR RETREIVING VIDEO")
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
                    resultClosure(nil)
                case .cancelled:
                    print("Export canceled")
                    resultClosure(nil)
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
    
}

extension DGStreamRecordingCollectionsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.collections.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! DGStreamRecordingCollectionsTableViewCell
        cell.configureWith(collection: self.collections[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "recordings", sender: self.collections[indexPath.row])
    }
}

extension DGStreamRecordingCollectionsViewController: DGStreamRecordingsViewControllerDelegate {
    func recordingsViewController(_ vc: DGStreamRecordingsViewController, recordingSelected url: URL) {
        self.dismiss(animated: true) {
            if let delegate = self.delegate {
                delegate.recordingCollectionsViewController(self, recordingSelected: url)
            }
        }
    }
}
