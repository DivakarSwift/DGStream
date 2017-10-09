//
//  DGStreamCallViewController.swift
//  DGStream
//
//  Created by Brandon on 9/11/17.
//  Copyright © 2017 Dataglance. All rights reserved.
//

import UIKit
import Quickblox
import QuickbloxWebRTC
import KMZDrawView
import GLKit

typealias CellUpdateBlock = (_ cell: DGStreamCollectionViewCell) -> Void

public class DGStreamCallViewController: UIViewController {
    
    static let kOpponentCollectionViewCellIdentifier = "OpponentCollectionViewCellIdentifier"
    static let kSharingViewControllerIdentifier = "SharingViewController"
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var localVideoViewContainer: UIView!
    
    @IBOutlet weak var muteButton: UIButton!
    @IBOutlet weak var flipButton: UIButton!
    @IBOutlet weak var drawButton: UIButton!
    @IBOutlet weak var mergeButton: UIButton!
    
    
    var localVideoView:DGStreamVideoView?
    
    var toolbar: UIToolbar!
    
    var users: [DGStreamUser] = []
    var selectedItemIndexPath: NSIndexPath!
    
    var timeDuration: TimeInterval = 0.0
    var callTimer: Timer?
    var beepTimer: Timer?
    
    var cameraCapture: QBRTCCameraCapture!
    var videoViews: [UInt: UIView] = [:]
    var zoomedView: UIView!
    
    var dynamicEnable: UIButton!
    var videoEnabled: UIButton!
    
    var statsView: UIView!
    var shouldGetStats = false
    
    var screenCapture: DGStreamScreenCapture!
    var videoTextureCache: CVOpenGLESTextureCache?
    var background: GLKTextureInfo!
    var greenScreenVC:GSViewController!
    
    var session:QBRTCSession!
    
    fileprivate func initialCall() {
        let settings = DGStreamSettings.instance
        
        if self.session.conferenceType == .video, let videoSettings = settings.videoFormat {
            self.cameraCapture = QBRTCCameraCapture(videoFormat: videoSettings, position: .front)
            self.cameraCapture.startSession({
                self.session.localMediaStream.videoTrack.videoCapture = self.cameraCapture
            })
        }
        
        self.session.localMediaStream.audioTrack.isEnabled = false
        self.session.localMediaStream.videoTrack.isEnabled = true
        
        if localVideoView == nil {
            
            self.localVideoView = DGStreamVideoView(layer: self.cameraCapture.previewLayer, frame: self.localVideoViewContainer.bounds)
            self.localVideoViewContainer.addSubview(self.localVideoView!)
            self.localVideoView?.isHidden = false
        }
        
        var users:[DGStreamUser] = []
        let currentUser = DGStreamCore.instance.currentUser!
        users.append(currentUser)
        
        for number in self.session.opponentsIDs {
            
            if currentUser.userID?.uintValue == number.uintValue {
                
                var initiator = DGStreamCore.instance.userDataSource?.userWith(id: self.session.initiatorID.uintValue)
                
                if initiator != nil {
                    initiator = DGStreamUser()
                    initiator?.userID = NSNumber(value: self.session.initiatorID.uintValue)
                }
                
                if let i = initiator {
                    users.append(i)
                }
                
                continue
                
            }
            
            var user = DGStreamCore.instance.userDataSource?.userWith(id: number.uintValue)
            if user != nil {
                user = DGStreamUser()
                user?.userID = NSNumber(value: number.uintValue)
            }
            
            if let u = user {
                users.append(u)
            }
        }
        
        self.users = users
        
        // remove current user
        if let idx = self.users.index(of: currentUser) {
            print("remove current user")
            self.users.remove(at: idx)
        }
        
        self.collectionView.setCollectionViewLayout(DGStreamFullLayout(), animated: false)
        self.collectionView.reloadData()
        
        let isInitiator = DGStreamCore.instance.currentUser.userID?.uintValue == self.session.initiatorID.uintValue
        if isInitiator {
            startCall()
        }
        else {
            acceptCall()
        }
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        DGStreamCore.instance.presentedViewController = self
        
        // Set delegates
        QBRTCClient.instance().add(self)
        QBRTCAudioSession.instance().addDelegate(self)
        QBRTCAudioSession.instance().initialize { (config) in
            config.categoryOptions = [.defaultToSpeaker]
            if self.session.conferenceType == .video {
                config.mode = AVAudioSessionModeVideoChat
            }
        }
        
        initialCall()
     
        self.title = "Connecting..."
        
        let mergeImage = UIImage(named: "merge", in: Bundle(identifier: "com.dataglance.DGStream"), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        
        let drawImage = UIImage(named: "draw", in: Bundle(identifier: "com.dataglance.DGStream"), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        
        let flipImage = UIImage(named: "flip", in: Bundle(identifier: "com.dataglance.DGStream"), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        
        let muteImage = UIImage(named: "mute", in: Bundle(identifier: "com.dataglance.DGStream"), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        
        self.mergeButton.setImage(mergeImage, for: .normal)
        self.mergeButton.tintColor = .white
        self.mergeButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, -8, 12)
        
        self.drawButton.setImage(drawImage, for: .normal)
        self.drawButton.tintColor = .white
        self.drawButton.imageEdgeInsets = UIEdgeInsetsMake(10, 0, 2, 0)
        
        self.flipButton.setImage(flipImage, for: .normal)
        self.flipButton.tintColor = .white
        self.flipButton.imageEdgeInsets = UIEdgeInsetsMake(10, 0, 0, 0)
        
        self.muteButton.setImage(muteImage, for: .normal)
        self.muteButton.tintColor = .white
        self.muteButton.imageEdgeInsets = UIEdgeInsetsMake(10, 0, 0, 0)
        
        let wh:CGFloat = 80
        let padding:CGFloat = 10
        self.localVideoViewContainer.frame = CGRect(x: UIScreen.main.bounds.size.width - (wh + padding), y: UIScreen.main.bounds.size.height - (wh + padding), width: wh, height: wh)
        self.localVideoViewContainer.layoutIfNeeded()
        
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.session.acceptCall(nil)
        }
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        let storyboard = UIStoryboard(name: "GreenScreen", bundle: Bundle(identifier: "com.dataglance.DGStream"))
//        let gsViewController = storyboard.instantiateInitialViewController() as! GSViewController
//        gsViewController.willMove(toParentViewController: self)
//        self.addChildViewController(gsViewController)
//        gsViewController.view.backgroundColor = .clear
//        gsViewController.view.alpha = 1.0
//        self.view.addSubview(gsViewController.view)
//        gsViewController.didMove(toParentViewController: self)
//        gsViewController.startSession(with: self.cameraCapture.captureSession.outputs[0] as! AVCaptureVideoDataOutput)
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureGUI() {
        
        if self.session.conferenceType == .video {
            self.session.localMediaStream.audioTrack.isEnabled = true
            self.session.localMediaStream.videoTrack.isEnabled = true
            
            if videoViews.count > 0 {
                let nsDictionary = NSDictionary.init(dictionary: videoViews)
                let key = nsDictionary.allKeys[0] as! UInt
                let videoView = videoViews[key]
                self.localVideoView = videoView as? DGStreamVideoView
                self.localVideoView?.frame = self.localVideoViewContainer.bounds
                videoView?.boundInside(container: self.localVideoViewContainer)
                
                
                //            self.localVideoView!.isHidden = !self.session.localMediaStream.videoTrack.isEnabled
                self.localVideoView?.isHidden = false
            }
            
        }
        
        //let device = QBRTCAudioSession.instance().currentAudioDevice
        
        
        // Set Up Buttons
        
        
        // Stats report view
        
        
        
        
    }
    
    func refreshVideoViews() {
        if let cells = self.collectionView.visibleCells as? [DGStreamCollectionViewCell] {
            for cell in cells {
                if let videoView = cell.videoView {
                    cell.set(videoView: videoView)
                }
            }
        }
    }
    
    func videoViewWith(userID: NSNumber) -> UIView? {
        
        if self.session.conferenceType == .audio {
            return nil
        }
        
        var result = self.videoViews[userID.uintValue]
        
        if let id = DGStreamCore.instance.currentUser.userID, id.int16Value == userID.int16Value {
            if result == nil {
                let videoView = DGStreamVideoView(layer: self.cameraCapture.previewLayer, frame: self.localVideoViewContainer.bounds)
                self.videoViews[userID.uintValue] = videoView
                //videoView.delegate = self
                self.localVideoView = videoView
                
                return self.localVideoView
            }
        }
        else {
            var remoteVideoView: QBRTCRemoteVideoView? = nil
            
            let remoteVideoTrack = session.remoteVideoTrack(withUserID: userID)
            
            
    
            if result == nil {
                remoteVideoView = QBRTCRemoteVideoView(frame: CGRect(x: 2, y: 2, width: 2, height: 2))
                remoteVideoView?.videoGravity = AVLayerVideoGravityResizeAspect
                self.videoViews[userID.uintValue] = remoteVideoView
                result = remoteVideoView
            }
            
            remoteVideoView?.setVideoTrack(remoteVideoTrack)
        }
        
        return result
    }
    
    func startCall() {
        self.beepTimer = Timer.scheduledTimer(timeInterval: QBRTCConfig.dialingTimeInterval(), target: self, selector: #selector(playCallingSound(sender:)), userInfo: nil, repeats: true)
        
        // Play Calling Sound
        
        let currentUser = DGStreamCore.instance.currentUser
        
        var username = "Unknown"
        if let currentUsername = currentUser?.username {
            username = currentUsername
        }
        
        let userInfo:[String: String] = ["username": username, "url": "http.quickblox.com", "param": "dev"]
        
        self.session.startCall(userInfo)
    }
    
    func acceptCall() {
        //[[QMSoundManager instance] stopAllSounds];
        //Accept call
        self.session.acceptCall(nil)
    }
    
    //MARK:- Timers
    func playCallingSound(sender: Any) {
        
    }
    
    func refreshCallTime(sender: Timer) {
        self.timeDuration += 1.0
        let extraTitle = "Call Time - \(self.timeDuration)"
        self.title = extraTitle
    }
    
    //MARK:- Button Actions
    @IBAction func muteButtonTapped(_ sender: Any) {
        
    }

    @IBAction func flipButtonTapped(_ sender: Any) {
        
    }
    
    @IBAction func drawButtonTapped(_ sender: Any) {
        
        if let currentUserID = DGStreamCore.instance.currentUser.userID {
            var cell: DGStreamCollectionViewCell?
            for (key, _) in videoViews {
                let userID = key
                if userID != currentUserID.uintValue {
                    if let user = self.users.filter({ (u) -> Bool in
                        return u.userID?.uintValue == userID
                    }).first {
                        if let idx = self.users.index(of: user) {
                            if let streamCell = self.collectionView.cellForItem(at: IndexPath(item: idx, section: 0)) as? DGStreamCollectionViewCell {
                                cell = streamCell
                            }
                        }
                    }
                    break
                }
            }
            
            if let cell = cell {
                let drawView = KMZDrawView(frame: cell.contentView.bounds)
                drawView.backgroundColor = .clear
                cell.videoView.addSubview(drawView)
                drawView.contentMode = .scaleAspectFill
                self.screenCapture = DGStreamScreenCapture(view: cell.videoView)
                self.screenCapture.view.contentMode = .scaleAspectFill
                self.session.localMediaStream.videoTrack.videoCapture = self.screenCapture
            }
            
        }
        
    }
    
    @IBAction func mergeButtonTapped(_ sender: Any) {
        
        if let currentUserID = DGStreamCore.instance.currentUser.userID {
            
            // Get the Cell
            var cell: DGStreamCollectionViewCell?
            for (key, _) in videoViews {
                let userID = key
                if userID != currentUserID.uintValue {
                    if let user = self.users.filter({ (u) -> Bool in
                        return u.userID?.uintValue == userID
                    }).first {
                        if let idx = self.users.index(of: user) {
                            if let streamCell = self.collectionView.cellForItem(at: IndexPath(item: idx, section: 0)) as? DGStreamCollectionViewCell {
                                cell = streamCell
                            }
                        }
                    }
                    break
                }
            }
            
            startMergeModeForHelper()
        }
    }
    
    //MARK:- Switch Mode
    func startMergeModeForHelper() {
        
        // Tell other device to switch to merge mode
        if let currentUserID = DGStreamCore.instance.currentUser.userID {
            DGStreamNotification.merge(from: currentUserID)
        }
        
        // Switch current device to merge mode
        self.localVideoViewContainer.alpha = 0.40
        if self.localVideoView != nil {
            self.localVideoView?.removeFromSuperview()
            self.localVideoView = nil
        }
        self.localVideoViewContainer.frame = UIScreen.main.bounds
        self.localVideoViewContainer.layoutIfNeeded()
        
        self.localVideoView = DGStreamVideoView(layer: self.cameraCapture.previewLayer, frame: self.localVideoViewContainer.bounds)
        self.localVideoViewContainer.addSubview(self.localVideoView!)
        
        self.cameraCapture.position = .back
        self.session.localMediaStream.videoTrack.videoCapture = nil
        self.session.localMediaStream.videoTrack.videoCapture = self.cameraCapture
    }
    
    func endMergeModeForHelper() {
        
        // Tell other device to switch to stream mode
        if let currentUserID = DGStreamCore.instance.currentUser.userID {
            DGStreamNotification.merge(from: currentUserID)
        }
        
        // Switch current device to stream mode
        self.localVideoViewContainer.alpha = 1.0
        if self.localVideoView != nil {
            self.localVideoView?.removeFromSuperview()
            self.localVideoView = nil
        }
        
        let wh:CGFloat = 80
        let padding:CGFloat = 10
        self.localVideoViewContainer.frame = CGRect(x: UIScreen.main.bounds.size.width - (wh + padding), y: UIScreen.main.bounds.size.height - (wh + padding), width: wh, height: wh)
        self.localVideoViewContainer.layoutIfNeeded()
        
        self.localVideoView = DGStreamVideoView(layer: self.cameraCapture.previewLayer, frame: self.localVideoViewContainer.bounds)
        self.localVideoViewContainer.addSubview(self.localVideoView!)
        
        self.cameraCapture.position = .front
        self.session.localMediaStream.videoTrack.videoCapture = nil
        self.session.localMediaStream.videoTrack.videoCapture = self.cameraCapture
    }
    
    func startMergeModeForHelp() {
        
        // Get the Cell
        if let currentUserID = DGStreamCore.instance.currentUser.userID {
            
            // Get the Cell
            var cell: DGStreamCollectionViewCell?
            for (key, _) in videoViews {
                let userID = key
                if userID != currentUserID.uintValue {
                    if let user = self.users.filter({ (u) -> Bool in
                        return u.userID?.uintValue == userID
                    }).first {
                        if let idx = self.users.index(of: user) {
                            if let streamCell = self.collectionView.cellForItem(at: IndexPath(item: idx, section: 0)) as? DGStreamCollectionViewCell {
                                cell = streamCell
                            }
                        }
                    }
                    break
                }
            }
            
            let videoView = cell?.videoView
            videoView?.alpha = 0.45
            
            // Switch current device to merge mode
            self.localVideoViewContainer.alpha = 1.0
            if self.localVideoView != nil {
                self.localVideoView?.removeFromSuperview()
                self.localVideoView = nil
            }
            self.localVideoViewContainer.frame = UIScreen.main.bounds
            self.localVideoViewContainer.layoutIfNeeded()
            
            self.localVideoView = DGStreamVideoView(layer: self.cameraCapture.previewLayer, frame: self.localVideoViewContainer.bounds)
            self.localVideoViewContainer.addSubview(self.localVideoView!)
            
            videoView?.frame = self.localVideoViewContainer.bounds
            self.localVideoViewContainer.addSubview(videoView!)
            
            self.cameraCapture.position = .back
            self.session.localMediaStream.videoTrack.videoCapture = nil
            self.session.localMediaStream.videoTrack.videoCapture = self.cameraCapture
        }
    }
    
    func endMergeModeForHelp() {
        
    }
    
    //MARK:- Orientation
    
    func shouldAutorotateToInterfaceOrientation(interfaceOrientation: UIInterfaceOrientation) -> Bool {
        
        // Native video orientation is landscape with the button on the right.
        // The video processor rotates vide as needed, so don't autorotate also
        return interfaceOrientation == UIInterfaceOrientation.landscapeRight
    }
    
    func deviceOrientationDidChange() {
//        
//        let orientation:UIDeviceOrientation = UIDevice.current.orientation
//        
//        // Don't update the reference orientation when the device orientation is
//        // face up/down or unknown.
//        if UIDeviceOrientationIsPortrait(orientation) {
//            self.processCapture.referenceOrientation = AVCaptureVideoOrientation.portrait
//        }
//        else if UIDeviceOrientationIsLandscape(orientation) {
//            self.processCapture.referenceOrientation = AVCaptureVideoOrientation.landscapeRight
//        }
    }
    
}

//MARK:- UICollectionView
extension DGStreamCallViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.users.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! DGStreamCollectionViewCell
        let user = self.users[indexPath.item]
        if let userID = user.userID, let videoView = self.videoViewWith(userID: userID) {
            cell.set(videoView: videoView)
        }
        return cell
    }
}

//MARK:- Transition To Size
extension DGStreamCallViewController {
    override public func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil) { (context) in
            self.refreshVideoViews()
        }
    }
    func indexPathAt(userID: NSNumber) -> IndexPath {
        var user:DGStreamUser
        if let foundUser = DGStreamCore.instance.userDataSource?.userWith(id: userID.uintValue) {
            user = foundUser
        }
        else {
            user = DGStreamUser()
            user.username = "Unknown"
            user.userID = userID
            user.id = UUID().uuidString
        }
        var indexPath = IndexPath(row: 0, section: 0)
        if let idx = self.users.index(of: user) {
            indexPath = IndexPath(row: idx, section: 0)
        }
        return indexPath
    }
    func performUpdate(userID: NSNumber, block: CellUpdateBlock) {
        let indexPath = self.indexPathAt(userID: userID)
        if let cell = self.collectionView.cellForItem(at: indexPath) as? DGStreamCollectionViewCell {
            block(cell)
        }
    }
}

//MARK:- Statistics
extension DGStreamCallViewController {
    func updateStatsView() {
        if shouldGetStats {
            shouldGetStats = false
        }
        else {
            shouldGetStats = true
        }
        if statsView.isHidden {
            statsView.isHidden = false
        }
        else {
            statsView.isHidden = true
        }
    }
}

//MARK:- QBRTCClientDelegate
extension DGStreamCallViewController: QBRTCClientDelegate {
    public func session(_ session: QBRTCBaseSession, updatedStatsReport report: QBRTCStatsReport, forUserID userID: NSNumber) {
        if session == self.session {
            let result = report.statsString()
            print(result)
        }
    }
    
    public func session(_ session: QBRTCSession, userDidNotRespond userID: NSNumber) {
        print("USER \(userID) DID NOT RESPOND")
        if session == self.session {
            self.performUpdate(userID: userID) { (cell) in
                cell.connectionState = self.session.connectionState(forUser: userID)
            }
            let alert = UIAlertController(title: "No Response", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action: UIAlertAction) in
                alert.dismiss(animated: true, completion: nil)
                self.dismiss(animated: true, completion: nil)
            }))
            present(alert, animated: true, completion: nil)
        }
    }
    
    public func session(_ session: QBRTCSession, acceptedByUser userID: NSNumber, userInfo: [String : String]? = nil) {
        print("ACCEPTED BY \(userID)")
        if session == self.session {
            self.performUpdate(userID: userID) { (cell) in
                cell.connectionState = self.session.connectionState(forUser: userID)
            }
        }
        let alert = UIAlertController(title: "MERGE NOW \(userInfo)", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action: UIAlertAction) in
            alert.dismiss(animated: false, completion: {
                
            })
        }))
        present(alert, animated: true, completion: nil)
    }
    
    public func session(_ session: QBRTCSession, rejectedByUser userID: NSNumber, userInfo: [String : String]? = nil) {
        print("REJECTED BY \(userID)")
        if session == self.session {
            self.performUpdate(userID: userID) { (cell) in
                cell.connectionState = self.session.connectionState(forUser: userID)
            }
            let alert = UIAlertController(title: "Call Rejected", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action: UIAlertAction) in
                alert.dismiss(animated: true, completion: nil)
                self.dismiss(animated: true, completion: nil)
            }))
            present(alert, animated: true, completion: nil)
        }
    }
    
    public func session(_ session: QBRTCSession, hungUpByUser userID: NSNumber, userInfo: [String : String]? = nil) {
        print("\(userID) HUNG UP")
        if session == self.session {
            self.performUpdate(userID: userID) { (cell) in
                cell.connectionState = self.session.connectionState(forUser: userID)
            }
        }
    }
    
    public func session(_ session: QBRTCBaseSession, receivedRemoteVideoTrack videoTrack: QBRTCVideoTrack, fromUser userID: NSNumber) {
        print("RECEIVED REMOTE VIDEO TRACK FROM \(userID)")
        if session == self.session {
            self.performUpdate(userID: userID) { (cell) in
                cell.connectionState = self.session.connectionState(forUser: userID)
                if let _ = self.videoViewWith(userID: userID) {
                    self.videoViews.removeValue(forKey: userID.uintValue)
                    
                    let qbVideoView = QBRTCRemoteVideoView(frame: cell.containerView.bounds)
                    qbVideoView.setVideoTrack(videoTrack)
                    qbVideoView.videoGravity = AVLayerVideoGravityResize
                    
                    
                    self.videoViews[userID.uintValue] = qbVideoView
                    
                    cell.set(videoView: qbVideoView)
                }
            }
        }
    }
    
    public func session(_ session: QBRTCBaseSession, receivedRemoteAudioTrack audioTrack: QBRTCAudioTrack, fromUser userID: NSNumber) {
        print("RECEIVED REMOTE AUDIO TRACK FROM \(userID)")
    }
    
    public func session(_ session: QBRTCBaseSession, startedConnectingToUser userID: NSNumber) {
        print("STARTED CONNECTING TO \(userID)")
        if session == self.session {
            self.performUpdate(userID: userID) { (cell) in
                cell.connectionState = self.session.connectionState(forUser: userID)
            }
        }
    }
    
    public func session(_ session: QBRTCBaseSession, connectedToUser userID: NSNumber) {
        print("CONNECTED TO \(userID)")
        if session == self.session {
            if let beep = self.beepTimer {
                beep.invalidate()
                self.beepTimer = nil
                // Stop All Sounds
            }
            
            if self.callTimer == nil {
                self.callTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(refreshCallTime(sender:)), userInfo: nil, repeats: true)
            }
            
            self.performUpdate(userID: userID) { (cell) in
                cell.connectionState = self.session.connectionState(forUser: userID)
            }
        }
    }
    
    public func session(_ session: QBRTCBaseSession, disconnectedFromUser userID: NSNumber) {
        print("DISCONNECTED FROM \(userID)")
        if session == self.session {
            self.performUpdate(userID: userID) { (cell) in
                cell.connectionState = self.session.connectionState(forUser: userID)
            }
        }
    }
    
    public func session(_ session: QBRTCBaseSession, connectionClosedForUser userID: NSNumber) {
        print("CONNECTIONG CLOSED FOR \(userID)")
        if session == self.session {
            self.performUpdate(userID: userID) { (cell) in
                cell.connectionState = self.session.connectionState(forUser: userID)
                self.videoViews.removeValue(forKey: userID.uintValue)
                cell.set(videoView: nil)
            }
            let alert = UIAlertController(title: "Session Closed", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action: UIAlertAction) in
                alert.dismiss(animated: true, completion: nil)
            }))
            present(alert, animated: true, completion: nil)
        }
    }
    
    public func session(_ session: QBRTCBaseSession, connectionFailedForUser userID: NSNumber) {
        print("CONNECTION FAILED FOR \(userID)")
        if session == self.session {
            self.performUpdate(userID: userID) { (cell) in
                cell.connectionState = self.session.connectionState(forUser: userID)
            }
        }
    }
    
    public func session(_ session: QBRTCBaseSession, didChange state: QBRTCSessionState) {
        printSession(state: state)
    }
    
    public func session(_ session: QBRTCBaseSession, didChange state: QBRTCConnectionState, forUser userID: NSNumber) {
        printConnection(state: state, for: userID)
        if session == self.session {
            self.performUpdate(userID: userID) { (cell) in
                cell.connectionState = self.session.connectionState(forUser: userID)
            }
        }
    }
    
    public func didReceiveNewSession(_ session: QBRTCSession, userInfo: [String : String]? = nil) {
        print("DID RECEIVE NEW SESSION")
    }
    
    public func sessionDidClose(_ session: QBRTCSession) {
        print("SESSION CLOSED")
        if session == self.session {
            let alert = UIAlertController(title: "Session Closed", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action: UIAlertAction) in
                alert.dismiss(animated: true, completion: nil)
                self.dismiss(animated: true, completion: nil)
            }))
            present(alert, animated: true, completion: nil)
        }
    }
    
    func printSession(state: QBRTCSessionState) {
        if state == .closed {
            print("|-CLOSED-|")
        }
        if state == .connected {
            print("|-CONNECTED-|")
        }
        if state == .connecting {
            print("|-CONNECTING-|")
        }
        if state == .new {
            print("|-NEW-|")
        }
        if state == .pending {
            print("|-PENDING-|")
        }
    }
    
    func printConnection(state: QBRTCConnectionState, for userID: NSNumber) {
        if state == .checking {
            print("|-CHECKING - \(userID)-|")
        }
        if state == .closed {
            print("|-CLOSED - \(userID)-|")
        }
        if state == .connected {
            print("|-CONNECTED - \(userID)-|")
        }
        if state == .connecting {
            print("|-CONNECTING - \(userID)-|")
        }
        if state == .count {
            print("|-COUNT - \(userID)-|")
        }
        if state == .disconnected {
            print("|-DISCONNECTED - \(userID)-|")
        }
        if state == .disconnectTimeout {
            print("|-DISCONNECT TIMEOUT - \(userID)-|")
        }
        if state == .failed {
            print("|-FAILED - \(userID)-|")
        }
        if state == .hangUp {
            print("|-HANGUP - \(userID)-|")
        }
        if state == .new {
            print("|-NEW - \(userID)-|")
        }
        if state == .noAnswer {
            print("|-NO ANSWER - \(userID)-|")
        }
        if state == .pending {
            print("|-PENDING - \(userID)-|")
        }
        if state == .rejected {
            print("|-REJECTED - \(userID)-|")
        }
        if state == .unknown {
            print("|-UNKNOWN - \(userID)-|")
        }
    }
    
}

//MARK:- QBRTCAudioSessionDelegate
extension DGStreamCallViewController: QBRTCAudioSessionDelegate {
    
}
