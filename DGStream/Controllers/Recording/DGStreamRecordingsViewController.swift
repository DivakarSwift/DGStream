//
//  DGStreamRecordingsViewController.swift
//  DGStream
//
//  Created by Brandon on 2/21/18.
//  Copyright © 2018 Dataglance. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

protocol DGStreamRecordingsViewControllerDelegate {
    func recordingsViewController(_ vc: DGStreamRecordingsViewController, recordingSelected url: URL)
}

class DGStreamRecordingsViewController: UIViewController {
    
    @IBOutlet weak var navBar: UIView!
    @IBOutlet weak var navBarTitle: UILabel!
    @IBOutlet weak var navBarBackButton: UIButton!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var collection: DGStreamRecordingCollection!
    var recordings: [DGStreamRecording] = []
    var delegate: DGStreamRecordingsViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navBar.backgroundColor = UIColor.dgBlueDark()
        self.navBarBackButton.setTitle("Back", for: .normal)
        self.navBarTitle.text = "Recordings"
        loadRecordings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if delegate == nil {
            DGStreamCore.instance.presentedViewController = self
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadRecordings() {
        self.recordings = DGStreamRecording.createDGStreamRecordingsFor(protocols: DGStreamManager.instance.dataSource.streamManager(DGStreamManager.instance, recordingsForUserID: DGStreamCore.instance.currentUser?.userID ?? 0, documentNumber: self.collection.documentNumber, title: nil))
        self.collectionView.reloadData()
    }

    @IBAction func backButtonTapped(_ sender: Any) {
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        }
        else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
}

extension DGStreamRecordingsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.recordings.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! DGStreamRecordingCollectionViewCell
        cell.configureWith(recording: self.recordings[indexPath.item])
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let recording = self.recordings[indexPath.item]
        
        if let recordingURL = recording.url {
            
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            
            var extens = "mp4"
            
            if recording.isPhoto {
                extens = "jpeg"
            }
            
            let url = documentsDirectory.appendingPathComponent(recordingURL).appendingPathExtension(extens)
            
            if let delegate = self.delegate {
                delegate.recordingsViewController(self, recordingSelected: url)
                if let nav = self.navigationController {
                    nav.dismiss(animated: true, completion: nil)
                }
                self.dismiss(animated: true) {
                    
                }
                return
            }
            
            if recording.isPhoto {
                return
            }
            
            let avPlayer = AVPlayer(url: url)
            
            let avplayerVC = AVPlayerViewController()
            avplayerVC.player = avPlayer
            
            self.present(avplayerVC, animated: true, completion: {
                avPlayer.play()
            })
            
        }
        
    }
}
