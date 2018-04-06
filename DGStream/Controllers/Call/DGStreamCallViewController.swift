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
import GLKit
import jot
import ReplayKit

typealias CellUpdateBlock = (_ cell: DGStreamCollectionViewCell) -> Void

enum CallMode {
    case stream
    case merge
    case share
    case board
}

enum DGStreamStampMode: Int {
    case off = 0
    case arrow = 1
    case box = 2
    case star = 3
    case smiley = 4
    
}

public class DGStreamCallViewController: UIViewController {
    
    static let kOpponentCollectionViewCellIdentifier = "OpponentCollectionViewCellIdentifier"
    static let kSharingViewControllerIdentifier = "SharingViewController"
    
    @IBOutlet weak var blackoutView: UIView!
    @IBOutlet weak var blackoutLabel: UILabel!
    
    @IBOutlet weak var blackoutButtonContainer: UIView!
    @IBOutlet weak var blackoutCancelButton: UIButton!
    @IBOutlet weak var blackoutCancelLabel: UILabel!
    @IBOutlet weak var blackoutCallBackButton: UIButton!
    @IBOutlet weak var blackoutCallBackLabel: UILabel!
    
    @IBOutlet weak var savedPhotoLabel: UILabel!
    var isShowingLabel = false
    
    @IBOutlet weak var statusBar: UIView!
    @IBOutlet weak var statusBarBackButton: UIButton!
    @IBOutlet weak var statusBarDoneButton: UIButton!
    @IBOutlet weak var statusBarTitle: UILabel!
    
    @IBOutlet weak var dropDownContainer: UIView!
    @IBOutlet weak var dropDownTopConstraint: NSLayoutConstraint!
    var dropDown:DGStreamDropDownMenu!
    var dropDownManager: DGStreamDropDownManager!
    
    var sizeCollectionView: UICollectionView!
    var colorCollectionView: UICollectionView!
    var stampCollectionView: UICollectionView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var localVideoViewContainer: UIView!
    var remoteVideoViewContainer: UIView!
    
    var remoteVideoViewContainerTopConstraint: NSLayoutConstraint!
    var remoteVideoViewContainerBottomConstraint: NSLayoutConstraint!
    var remoteVideoViewContainerLeftConstraint: NSLayoutConstraint!
    var remoteVideoViewContainerRightConstraint: NSLayoutConstraint!
    var remoteVideoViewContainerWidthConstraint: NSLayoutConstraint?
    var remoteVideoViewContainerHeightConstraint: NSLayoutConstraint?
    var remoteVideoViewContainerCenterXConstraint: NSLayoutConstraint?
    var remoteVideoViewContainerCenterYConstraint: NSLayoutConstraint?
    
    @IBOutlet weak var buttonsContainer: UIStackView!
    
    @IBOutlet weak var drawButtonContainer: UIView!
    @IBOutlet weak var drawButton: UIButton! //80
    
    @IBOutlet weak var mergeButtonContainer: UIView!
    @IBOutlet weak var mergeButton: UIButton! //10
    
    @IBOutlet weak var hangUpButtonContainer: UIView!
    @IBOutlet weak var hangUpButton: UIButton!
    
    @IBOutlet weak var shareScreenButtonContainer: UIView!
    @IBOutlet weak var shareScreenButton: UIButton!
    
    @IBOutlet weak var whiteBoardButtonContainer: UIView!
    @IBOutlet weak var whiteBoardButton: UIButton!
    
    @IBOutlet weak var freezeButtonContainer: UIView!
    @IBOutlet weak var freezeButton: UIButton!
    var freezeImageView: UIImageView?
    var isFrozen: Bool = false
    var freezeFrame: UIImage?
    var freezeRotation: QBRTCVideoRotation?
    @IBOutlet weak var freezeActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var snapshotButtonContainer: UIView!
    @IBOutlet weak var snapshotButton: UIButton!
    
    @IBOutlet weak var muteButtonContainer: UIView!
    @IBOutlet weak var muteButton: UIButton!
    
    @IBOutlet weak var chatButtonContainer: UIView!
    @IBOutlet weak var chatButton: UIButton!
    
    
    @IBOutlet weak var chatPeekViewContainer: UIView!
    var chatPeekView: DGStreamChatPeekView!
    
    @IBOutlet weak var paletteButtonContainer: UIView!
    
    @IBOutlet weak var paletteTextButtonContainer: UIView!
    
    @IBOutlet weak var paletteButton: UIButton!
    
    @IBOutlet weak var paletteTextButton: UIButton!

    var isShowingControls = true
    
    var isAudioCall = false
    
    @IBOutlet weak var audioCallContainer: UIView!
    @IBOutlet weak var audioCallLabel: UILabel!
    @IBOutlet weak var audioIndicatorContainer: UIView!
    
    var isChatShown = false
    var didHangUp = false
    var didOtherUserHangUp = false
    
    //var localVideoView:DGStreamVideoView?
    var isCentered:Bool = true
    
    var toolbar: UIToolbar!
    
    var users: [DGStreamUser] = []
    var selectedUser: NSNumber!
    
    var timeDuration: TimeInterval = 0.0
    var callTimer: Timer?
    var beepTimer: Timer?
    
    var cameraCapture: QBRTCCameraCapture!
    var videoViews: [UInt: UIView] = [:]
    var zoomedView: UIView!
    
    var dynamicEnable: UIButton!
    var videoEnabled: UIButton!
    
    var statsView: UIView!
    var isInitiator = false
    var isHelper = false
    var isDrawing = false
    var stampMode:DGStreamStampMode = .off
    var drawingUsers:[NSNumber] = []
    
    var screenCapture: DGStreamScreenCapture?
    var videoTextureCache: CVOpenGLESTextureCache?
    var background: GLKTextureInfo!
    
    var session:QBRTCSession?
    
    var callMode: CallMode = .stream
    var alertView: DGStreamAlertView?
    var jotVC: JotViewController?
    var localDrawImageView: UIImageView?
    var remoteDrawImageView: UIImageView?
    var isSettingText: Bool = false
    var drawSize:CGFloat = 24
    var drawColor:UIColor = .black
    var drawOperationQueue: DGStreamDrawOperationQueue = DGStreamDrawOperationQueue()
    var drawingTimer:Timer?
    var drawingWaitTimer:Timer?
    var chatVC: DGStreamChatViewController!
    @IBOutlet weak var chatContainer: UIView!
    @IBOutlet weak var chatContainerHeightConstraint: NSLayoutConstraint!
    
    var whiteBoardUsers:[NSNumber] = []
    var whiteBoardView:UIView?
    
    var videoOrientation: AVCaptureVideoOrientation = .portrait
    var bufferQueue: DispatchQueue?
    
    var recordingManager:DGStreamRecordingManager = DGStreamRecordingManager(orientation: .portrait)
    var isWaitingForOrientation: Bool = false
    var didRecord:Bool = false
    
    var localBroadcastView:QBRTCRemoteVideoView?
    var recordQueue:DispatchQueue?
    
    var recordedScreenshots:[String] = []
    var isBroadcasting:Bool = false
    var recorder = RPScreenRecorder.shared()
    
    var didViewLoad: Bool = false
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        if didViewLoad == false {
            self.localVideoViewContainer.backgroundColor = .clear
            self.didViewLoad = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(toggleControls))
            tap.delegate = self
            self.view.addGestureRecognizer(tap)
            
            self.blackoutView.backgroundColor = UIColor.dgBlueDark()
            
            self.savedPhotoLabel.clipsToBounds = true
            self.savedPhotoLabel.textColor = UIColor.dgDarkGray()
            self.savedPhotoLabel.backgroundColor = UIColor.white
            self.savedPhotoLabel.layer.cornerRadius = 6
            
            self.view.backgroundColor = UIColor.dgWhite()
            
            UIApplication.shared.isStatusBarHidden = true
            self.statusBar.backgroundColor = UIColor.dgGreen()
            self.statusBarTitle.textColor = UIColor.dgBlack()
            
            DGStreamCore.instance.presentedViewController = self
            
            if self.session == nil {
                print("NO SESSION!")
            }
            else {
                initCall()
                self.setUpButtons()
                self.setUpChat()
            }
        }
        
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.freezeActivityIndicator.isHidden = true
        
        self.statusBar.backgroundColor = UIColor.dgBlueDark()
        
        self.chatContainer.alpha = 0
        
        self.blackoutButtonContainer.alpha = 0
        
        if let user = DGStreamCore.instance.getOtherUserWith(userID: self.selectedUser), let username = user.username {
            if isAudioCall {
               self.blackoutLabel.text = "\(NSLocalizedString("Audio calling", comment: "Video/Audio calling (user_name)...")) \(username)..."
            }
            else {
                self.blackoutLabel.text = "\(NSLocalizedString("Video calling", comment: "Video/Audio calling (user_name)...")) \(username)..."
            }
        }
        
        self.hangUpButton.alpha = 1
        
        self.mergeButtonContainer.alpha = 0
        self.drawButtonContainer.alpha = 0
        self.whiteBoardButtonContainer.alpha = 0
        self.shareScreenButtonContainer.alpha = 0
        self.freezeButtonContainer.alpha = 0
        self.snapshotButtonContainer.alpha = 0
        self.chatButtonContainer.alpha = 0
        
        self.localVideoViewContainer.frame = frameForLocalVideo(isCenter: true)
        self.localVideoViewContainer.clipsToBounds = true
        self.localVideoViewContainer.layer.cornerRadius = self.localVideoViewContainer.frame.size.width / 2
        
        if self.isAudioCall {
            self.buttonsContainer.alpha = 0
        }
//        else if localVideoView == nil, self.cameraCapture != nil {
//
//            // Place Local Video On Top of Remote
//            self.localVideoView = DGStreamVideoView(layer: self.cameraCapture.previewLayer, frame: self.localVideoViewContainer.bounds)
//            self.localVideoView?.boundInside(container: self.localVideoViewContainer)
//            self.localVideoView?.alpha = 0.45
//            if let orientation = self.localVideoView?.updateOrientationIfNeeded() {
//                self.videoOrientation = orientation
//            }
//            self.localVideoView?.videoLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
//        }
        
        // Drop Down
        self.setDropDownView(isOrientationReset: false)
        
        self.remoteVideoViewContainer = UIView(frame: UIScreen.main.bounds)
        self.remoteVideoViewContainer.backgroundColor = .black
        self.remoteVideoViewContainer.clipsToBounds = true
        let results = self.remoteVideoViewContainer.boundInsideAndGetConstraints(container: self.view)
        self.remoteVideoViewContainerTopConstraint = results.top
        self.remoteVideoViewContainerBottomConstraint = results.bottom
        self.remoteVideoViewContainerLeftConstraint = results.left
        self.remoteVideoViewContainerRightConstraint = results.right
        self.view.sendSubview(toBack: self.remoteVideoViewContainer)
        
        self.chatPeekView = DGStreamChatPeekView()
        self.chatPeekView.configureWithin(container: self.chatPeekViewContainer)
        
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        
        NotificationCenter.default.addObserver(self, selector: #selector(deviceOrientationDidChange), name: Notification.Name.UIDeviceOrientationDidChange, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.session?.acceptCall(nil)
        }
    }
    
    func keyboardWillShow(notification: Notification) {
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
    
    func keyboardWillHide(notification: Notification) {
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
    
    func layoutRemoteViewHeirarchy() {
        DispatchQueue.main.async {
            if let videoView = self.videoViewWith(userID: self.selectedUser), self.remoteVideoViewContainer.subviews.contains(videoView) {
                self.remoteVideoViewContainer.bringSubview(toFront: videoView)
            }
            if let localVideoView = self.localBroadcastView, self.remoteVideoViewContainer.subviews.contains(localVideoView) {
                self.remoteVideoViewContainer.bringSubview(toFront: localVideoView)
            }
            if let whiteBoard = self.whiteBoardView, self.remoteVideoViewContainer.subviews.contains(whiteBoard) {
                self.remoteVideoViewContainer.bringSubview(toFront: whiteBoard)
            }
            if let remote = self.remoteDrawImageView, self.remoteVideoViewContainer.subviews.contains(remote) {
                self.remoteVideoViewContainer.bringSubview(toFront: remote)
            }
            if let local = self.localDrawImageView, self.remoteVideoViewContainer.subviews.contains(local) {
                self.remoteVideoViewContainer.bringSubview(toFront: local)
            }
            if let jot = self.jotVC, self.remoteVideoViewContainer.subviews.contains(jot.view) {
                self.remoteVideoViewContainer.bringSubview(toFront: jot.view)
            }
        }
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !self.isInitiator, let session = self.session {
            
            if let _ = self.videoViewWith(userID: self.selectedUser) {
                self.videoViews.removeValue(forKey: self.selectedUser.uintValue)
            }
            
            let qbVideoView = QBRTCRemoteVideoView(frame: self.remoteVideoViewContainer.bounds)
            qbVideoView.setVideoTrack(session.remoteVideoTrack(withUserID: self.selectedUser))
            qbVideoView.videoGravity = AVLayerVideoGravityResizeAspect
            
            self.videoViews[self.selectedUser.uintValue] = qbVideoView
            
            if selectedUser.uintValue == self.selectedUser.uintValue {
                let exists = self.remoteVideoViewContainer.subviews.filter({ (subview) -> Bool in
                    return subview is QBRTCRemoteVideoView
                }).first
                if exists == nil {
                    qbVideoView.boundInside(container: self.remoteVideoViewContainer)
                }
            }
            
            qbVideoView.setSize(self.remoteVideoViewContainer.bounds.size)
        }
        
        self.remoteVideoViewContainer.bringSubview(toFront: self.hangUpButton)
        self.remoteVideoViewContainer.bringSubview(toFront: self.mergeButton)
        self.remoteVideoViewContainer.bringSubview(toFront: self.drawButton)
        self.remoteVideoViewContainer.bringSubview(toFront: self.statusBar)
        
    }
    
    func deviceOrientationDidChange() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.20) {
            
            if UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight {
                let screenHeight = UIScreen.main.bounds.height
                let padding:CGFloat = 30
                let threshold = screenHeight - padding
                let oldHeight = self.chatContainer.frame.size.height
                var newHeight = oldHeight
                if oldHeight > threshold {
                    newHeight = threshold
                }
                self.chatContainerHeightConstraint.constant = newHeight
                self.chatContainer.layoutIfNeeded()
            }
            else {
                var height:CGFloat = 500
                if Display.pad {
                    height = 700
                }
                self.chatContainerHeightConstraint.constant = height
                self.chatContainer.layoutIfNeeded()
            }
            
            if self.dropDown != nil, self.dropDown.alpha != 0 {
                self.setDropDownView(isOrientationReset: true)
            }
            
            if self.callMode == .merge {
                
                //self.localBroadcastView?.boundInside(container: self.remoteVideoViewContainer)
                self.localBroadcastView?.setSize(self.remoteVideoViewContainer.bounds.size)
                
                if self.isFrozen == false {
                    self.localBroadcastView?.alpha = 0.50
                }
                
                if let remoteView = self.videoViewWith(userID: self.selectedUser) as? QBRTCRemoteVideoView {
                    remoteView.alpha = 1.0
                }
                
//                if let orientation = self.localVideoView?.updateOrientationIfNeeded() {
//                    self.videoOrientation = orientation
//                }
                //self.localBroadcastView?.videoLayer.videoGravity = AVLayerVideoGravityResize
            }
            else {
                self.localBroadcastView?.setSize(self.localVideoViewContainer.bounds.size)
//                if let orientation = self.localVideoView?.updateOrientationIfNeeded() {
//                    self.videoOrientation = orientation
//                }
                //self.localVideoView?.videoLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
            }
            
        }
        
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func initCall() {
        
        self.didHangUp = false
        self.didOtherUserHangUp = false
        
        self.timeDuration = 0.0
        
        self.statusBarTitle.alpha = 1
        
        // Set delegates
        QBRTCClient.instance().add(self)
        QBRTCAudioSession.instance().addDelegate(self)
        QBRTCAudioSession.instance().initialize { (config) in
            config.categoryOptions = [.defaultToSpeaker]
            if self.session?.conferenceType == .video {
                config.mode = AVAudioSessionModeVideoChat
            }
        }
        
        let format = QBRTCVideoFormat(width: 640, height: 480, frameRate: 30, pixelFormat: QBRTCPixelFormat.format420f)
        self.cameraCapture = QBRTCCameraCapture(videoFormat: format, position: .front)
        self.cameraCapture.startSession {
            print("START LOCAL SESSION")
            self.session?.localMediaStream.videoTrack.videoCapture = self.cameraCapture
            self.bufferQueue = self.cameraCapture.videoQueue
            DispatchQueue.main.async {
                self.recordingManager.startRecordingWith(localCaptureSession: self.cameraCapture.captureSession, remoteRecorder: self.session!.recorder!, bufferQueue: self.bufferQueue!, documentNumber: "01234-56789", isMerged: false, delegate: self)
            }
        }
        
        if isAudioCall {
            self.drawButtonContainer.isHidden = true
            self.mergeButtonContainer.isHidden = true
            self.freezeButtonContainer.isHidden = true
            self.snapshotButtonContainer.isHidden = true
            self.session?.localMediaStream.audioTrack.isEnabled = true
            self.session?.localMediaStream.videoTrack.isEnabled = false
            self.audioCallContainer.isHidden = false
            
            self.audioCallLabel.textColor = UIColor.dgWhite()
            
            if let user = DGStreamCore.instance.getOtherUserWith(userID: self.selectedUser), let username = user.username {
                let audioCallString = NSLocalizedString("Audio call with", comment: "Audio call with (user_name)")
                self.audioCallLabel.text = "\(audioCallString)\n\(username)"
            }
            else {
                self.audioCallLabel.text = NSLocalizedString("In Audio Call", comment: "")
            }
            
            if let audioIndicator = UINib(nibName: "DGStreamAudioIndicator", bundle: Bundle(identifier: "com.dataglance.DGStream")).instantiate(withOwner: self, options: nil).first as? DGStreamAudioIndicator {
                audioIndicator.animateWithin(container: self.audioIndicatorContainer)
                self.audioIndicatorContainer.alpha = 0
                self.audioCallLabel.alpha = 0
            }
            
        }
        else {
            self.session?.localMediaStream.audioTrack.isEnabled = true
            self.session?.localMediaStream.videoTrack.isEnabled = true
        }
        
        var users:[DGStreamUser] = []
        let currentUser = DGStreamCore.instance.currentUser!
        users.append(currentUser)
        
        for number in self.session?.opponentsIDs ?? [] {
            
            if currentUser.userID?.uintValue == number.uintValue {
                
                var initiator = DGStreamCore.instance.userDataSource?.userWith(id: self.session?.initiatorID.uintValue ?? 0)
                
                if initiator != nil {
                    initiator = DGStreamUser()
                    initiator?.userID = NSNumber(value: self.session?.initiatorID.uintValue ?? 0)
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
            
            self.users.remove(at: idx)
        }
        
        if let first = self.users.first, let firstUserID = first.userID {
            self.selectedUser = firstUserID
        }

        if let currentUser = DGStreamCore.instance.currentUser, let currentUserID = currentUser.userID {
            self.isInitiator = currentUserID.uintValue == self.session?.initiatorID.uintValue
        }
        
        if self.isInitiator {
            startCall()
        }
        else {
            acceptCall()
        }
    }
    
    func configureGUI() {
        
        if self.session?.conferenceType == .video {
            self.session?.localMediaStream.audioTrack.isEnabled = true
            self.session?.localMediaStream.videoTrack.isEnabled = true
            
            self.localBroadcastView?.frame = self.localVideoViewContainer.bounds
            localBroadcastView?.boundInside(container: self.localVideoViewContainer)
            self.localBroadcastView?.isHidden = false
        }
    }
    
    func setUpButtons() {
        
        self.buttonsContainer.layer.cornerRadius = 6
        self.buttonsContainer.layer.borderColor = UIColor.dgBlack().cgColor
        self.buttonsContainer.layer.borderWidth = 0.5
        
        let callPhoneImage = UIImage(named: "video", in: Bundle.init(identifier: "com.dataglance.DGStream"), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        
        let mergeImage = UIImage(named: "merge", in: Bundle(identifier: "com.dataglance.DGStream"), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        
        let drawImage = UIImage(named: "EditPencil", in: Bundle(identifier: "com.dataglance.DGStream"), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        
        let hangUpImage = UIImage(named: "hangup", in: Bundle.init(identifier: "com.dataglance.DGStream"), compatibleWith: nil)
        
        let whiteBoardImage = UIImage(named: "scratchpad", in: Bundle.init(identifier: "com.dataglance.DGStream"), compatibleWith: nil)
        
        let screenShare = UIImage.init(named: "record", in: Bundle.init(identifier: "com.dataglance.DGStream"), compatibleWith: nil)
        
        self.statusBarBackButton.setTitleColor(UIColor.dgBlack(), for: .normal)
        self.statusBarDoneButton.setTitleColor(UIColor.dgBlack(), for: .normal)
        
        // Hang up
        self.hangUpButton.setImage(hangUpImage?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.hangUpButton.tintColor = .white
        self.hangUpButton.backgroundColor = .red
        self.hangUpButton.alpha = 0
        self.hangUpButton.contentHorizontalAlignment = .fill
        self.hangUpButton.contentVerticalAlignment = .fill
        self.hangUpButton.contentMode = .scaleAspectFill
        self.hangUpButton.imageEdgeInsets =  UIEdgeInsetsMake(8, 8, 8, 8)
        self.hangUpButtonContainer.layer.cornerRadius = self.hangUpButtonContainer.frame.size.width / 2
        
        // Merge
        self.mergeButton.setImage(mergeImage?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.mergeButton.tintColor = .white
        self.mergeButton.alpha = 0
        self.mergeButton.contentVerticalAlignment = .fill
        self.mergeButton.contentHorizontalAlignment = .fill
        self.mergeButton.contentMode = .scaleAspectFill
        self.mergeButton.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8)
        self.mergeButton.backgroundColor = UIColor.dgBlueDark()
        
        // Draw
        self.drawButton.setImage(drawImage?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.drawButton.tintColor = .white
        self.drawButton.alpha = 0
        self.drawButton.contentHorizontalAlignment = .fill
        self.drawButton.contentVerticalAlignment = .fill
        self.drawButton.contentMode = .scaleAspectFill
        self.drawButton.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8)
        self.drawButton.backgroundColor = UIColor.dgBlueDark()
        
        // Screen share
        self.shareScreenButton.setImage(screenShare?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.shareScreenButton.tintColor = .white
        self.shareScreenButton.alpha = 0
        self.shareScreenButton.contentHorizontalAlignment = .fill
        self.shareScreenButton.contentVerticalAlignment = .fill
        self.shareScreenButton.contentMode = .scaleAspectFill
        self.shareScreenButton.imageEdgeInsets = UIEdgeInsetsMake(4, 4, 4, 4)
        self.shareScreenButton.backgroundColor = UIColor.dgBlueDark()
        
        // White Board
        self.whiteBoardButton.setImage(whiteBoardImage?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.whiteBoardButton.tintColor = .white
        self.whiteBoardButton.alpha = 0
        self.whiteBoardButton.contentHorizontalAlignment = .fill
        self.whiteBoardButton.contentVerticalAlignment = .fill
        self.whiteBoardButton.contentMode = .scaleAspectFill
        self.whiteBoardButton.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5)
        self.whiteBoardButton.backgroundColor = UIColor.dgBlueDark()
        
        // Freeze
        self.freezeButton.setImage(UIImage.init(named: "freeze", in: Bundle.init(identifier: "com.dataglance.DGStream"), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.freezeButton.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8)
        self.freezeButton.tintColor = .white
        self.freezeButton.contentHorizontalAlignment = .fill
        self.freezeButton.contentVerticalAlignment = .fill
        self.freezeButton.contentMode = .scaleAspectFill
        self.freezeButton.backgroundColor = UIColor.dgBlueDark()
        
        // Snapshot
        self.snapshotButton.setImage(UIImage.init(named: "capture", in: Bundle.init(identifier: "com.dataglance.DGStream"), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.snapshotButton.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8)
        self.snapshotButton.tintColor = .white
        self.snapshotButton.contentHorizontalAlignment = .fill
        self.snapshotButton.contentVerticalAlignment = .fill
        self.snapshotButton.contentMode = .scaleAspectFill
        self.snapshotButton.backgroundColor = UIColor.dgBlueDark()
        
        // Chat
        self.chatButtonContainer.layer.cornerRadius = 6
        self.chatButton.setImage(UIImage.init(named: "message", in: Bundle.init(identifier: "com.dataglance.DGStream"), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.chatButton.tintColor = .white
        self.chatButton.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8)
        self.chatButton.backgroundColor = UIColor.dgBlueDark()
        
        var hangUpButtonWH:CGFloat = 0
        var otherButtonsWH:CGFloat = 0
        var padding: CGFloat = 0
        let insets:UIEdgeInsets
        
        if Display.pad || Display.typeIsLike == .iphone6plus || Display.typeIsLike == .iphone7plus {
            padding = 20
            hangUpButtonWH = 80
            otherButtonsWH = 60
        }
        else {
            padding = 12
            hangUpButtonWH = 60
            otherButtonsWH = 40
        }
        
        let inset = hangUpButtonWH / 8
        insets = UIEdgeInsetsMake(inset, inset, inset, inset)
        
        self.blackoutCancelLabel.textColor = .white
        self.blackoutCallBackLabel.textColor = .white
        
        self.blackoutCancelButton.setTitle("X", for: .normal)
        self.blackoutCancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 60)
        self.blackoutCancelButton.setTitleColor(.white, for: .normal)
        self.blackoutCancelButton.layer.cornerRadius = self.blackoutCancelButton.frame.size.width / 2
        self.blackoutCancelButton.backgroundColor = UIColor.dgBlack()
        
        self.blackoutCallBackButton.setImage(callPhoneImage, for: .normal)
        self.blackoutCallBackButton.tintColor = .white
        self.blackoutCallBackButton.backgroundColor = UIColor.dgGreen()
        self.blackoutCallBackButton.layer.cornerRadius = self.blackoutCallBackButton.frame.size.width / 2
        self.blackoutCallBackButton.layer.borderColor = UIColor.dgBlack().cgColor
        self.blackoutCallBackButton.layer.borderWidth = 0.5
        
        self.view.layoutIfNeeded()
    }
    
    func setUpChat() {
        print("SET UP CHAT")
        self.chatContainer.layer.shadowColor = UIColor.black.cgColor
        self.chatContainer.layer.shadowOffset = CGSize(width: 1, height: 0)
        self.chatContainer.layer.shadowRadius = 4
        self.chatContainer.layer.shadowOpacity = 0.75
        self.chatVC.delegate = self
        self.chatVC.view.boundInside(container: self.chatContainer)
        self.chatVC.view.alpha = 0
        self.chatVC.didMove(toParentViewController: self)
        self.chatVC.loadData()
    }
    
    func setDropDownView(isOrientationReset: Bool) {
        
        if self.dropDown != nil {
            self.dropDown.removeFromSuperview()
            self.dropDown = nil
        }
        
        if self.dropDownManager != nil {
            self.dropDownManager = nil
        }
        
        self.dropDownManager = DGStreamDropDownManager()
        self.dropDownManager.configureWith(container: self.dropDownContainer, delegate: self)
        
        var dropDownViews:[UIView] = []
        let dropDownViewTitles:[String] = [NSLocalizedString("Size", comment: ""), NSLocalizedString("Color", comment: ""), NSLocalizedString("Stamps", comment: "")]
        
        dropDownViews.append(self.dropDownManager.getDropDownViewFor(type: .size))
        dropDownViews.append(self.dropDownManager.getDropDownViewFor(type: .color))
        dropDownViews.append(self.dropDownManager.getDropDownViewFor(type: .stamp))
        
        self.dropDown = DGStreamDropDownMenu(frame: self.dropDownContainer.frame, dropDownViews: dropDownViews, dropDownViewTitles: dropDownViewTitles)
        var size:CGFloat = 14
        if Display.pad {
            size = 24
        }
        self.dropDown.setLabel(font: UIFont(name: "HelveticaNeue-Bold", size: size)!)
        self.dropDown.setLabelColorWhen(normal: UIColor.dgBlack(), selected: UIColor.dgBlack(), disabled: UIColor.dgBlack())
        self.view.insertSubview(self.dropDown, belowSubview: self.statusBar)
        self.dropDown.setImageWhen(normal: UIImage.init(named: "down", in: Bundle.init(identifier: "com.dataglance.DGStream"), compatibleWith: nil), selected: UIImage.init(named: "up", in: Bundle.init(identifier: "com.dataglance.DGStream"), compatibleWith: nil), disabled: nil)
        
        self.dropDown.backgroundBlurEnabled = false
//        self.dropDown.blurEffectStyle = .light
//        let backgroundView = UIView()
//        backgroundView.backgroundColor = UIColor.black
//        self.dropDown.blurEffectView = backgroundView
//        self.dropDown.blurEffectViewAlpha = 0.50
        
        if isOrientationReset {
            self.showDropDown(animated: false)
        }
        else {
            self.dropDown.alpha = 0
        }
        
    }
    
    func animateButtons() {
        UIView.animate(withDuration: 0.25) {
            self.mergeButton.alpha = 1
            self.drawButton.alpha = 1
            self.hangUpButton.alpha = 1
            self.whiteBoardButton.alpha = 1
            self.shareScreenButton.alpha = 1
            self.freezeButtonContainer.alpha = 1
        }
    }
    
    func frameForLocalVideo(isCenter: Bool) -> CGRect {
        
        self.isCentered = isCenter
    
        var wh:CGFloat = 0
        var x: CGFloat = 0
        var y: CGFloat = 0
        
        // Calling Screen
        if isCenter {
            
            if Display.pad {
                wh = 248
            }
            else {
                wh = 188
            }
            
            let halfWH = wh / 2
            let halfScreenWidth = UIScreen.main.bounds.size.width / 2
            let halfScreenHeight = UIScreen.main.bounds.size.height / 2
            
            x = halfScreenWidth - halfWH
            y = halfScreenHeight - halfWH
            
        }
        // In-Call Screen
        else {
            if Display.pad {
                wh = 160
            }
            else {
                wh = 100
            }
            
            if self.isDrawing == true {
                y = 84
            }
            else {
                y = 40
            }
            
            x = 10
            
        }
        
        return CGRect(x: x, y: y, width: wh, height: wh)
        
    }
    
    func refreshVideoViews() {

    }
    
    func videoViewWith(userID: NSNumber) -> UIView? {
        
        if self.session?.conferenceType == .audio {
            return nil
        }
        
        var result = self.videoViews[userID.uintValue]
        
        if let currentUser = DGStreamCore.instance.currentUser, let currentUserID = currentUser.userID, currentUserID.int16Value == userID.int16Value {
            if result == nil {
                let videoView = DGStreamVideoView(layer: self.cameraCapture.previewLayer, frame: self.localVideoViewContainer.bounds)
                self.videoViews[userID.uintValue] = videoView
                //videoView.delegate = self
                //self.localVideoView = videoView
                
                return videoView
            }
        }
        else {
            var remoteVideoView: QBRTCRemoteVideoView? = nil
            
            if let remoteVideoTrack = session?.remoteVideoTrack(withUserID: userID) {
                if result == nil {
                    remoteVideoView = QBRTCRemoteVideoView(frame: CGRect(x: 2, y: 2, width: 2, height: 2))
                    remoteVideoView?.videoGravity = AVLayerVideoGravityResizeAspect
                    self.videoViews[userID.uintValue] = remoteVideoView
                    result = remoteVideoView
                }
                
                remoteVideoView?.setVideoTrack(remoteVideoTrack)
            }
    
        }
        
        return result
    }
    
    func startCall() {
        
        QBRTCConfig.setDTLSEnabled(true)
        QBRTCConfig.setDialingTimeInterval(3)
        
        self.beepTimer = Timer.scheduledTimer(timeInterval: QBRTCConfig.dialingTimeInterval(), target: self, selector: #selector(playCallingSound(sender:)), userInfo: nil, repeats: true)
        
        // Play Calling Sound
        
        let currentUser = DGStreamCore.instance.currentUser
        
        var username = ""
        if let currentUsername = currentUser?.username {
            username = currentUsername
        }
        
        let userInfo:[String: String] = ["username": username, "url": "http.quickblox.com", "param": "dev"]
        
        self.session?.startCall(userInfo)
    }
    
    func acceptCall() {
        self.session?.acceptCall(nil)
    }
    
    func showCallEndedWith(isHungUp: Bool) {
        
        var suffix = ""
        if isHungUp {
            suffix = NSLocalizedString("hung up", comment: "(user_name) hung up")
        }
        else {
            suffix = NSLocalizedString("was disconnected", comment: "(user_name) was disconnected")
        }
        
        if let user = DGStreamCore.instance.getOtherUserWith(userID: self.selectedUser), let username = user.username {
            self.blackoutLabel.text = "\(username) \(suffix)"
        }
        else {
            let otherUserString = NSLocalizedString("The other user", comment: "Default name for the other user in the call other than the current user")
            self.blackoutLabel.text = "\(otherUserString) \(suffix)"
        }
        
        self.statusBar.backgroundColor = UIColor.dgBlueDark()
        self.statusBarBackButton.alpha = 0
        
        self.statusBarTitle.alpha = 0
        
        self.buttonsContainer.alpha = 0
        self.hangUpButtonContainer.alpha = 0
        self.chatContainer.alpha = 0
        self.chatVC.view.alpha = 0
        
        self.hideDropDown(animated: false)
        
        let newFrame = self.frameForLocalVideo(isCenter: true)
        
        self.localBroadcastView?.frame = CGRect(x: 0, y: 0, width: newFrame.size.width, height: newFrame.size.height)
        //self.localBroadcastView?.videoLayer.frame = CGRect(x: 0, y: 0, width: newFrame.size.width, height: newFrame.size.height)
        self.localBroadcastView?.layoutIfNeeded()
        
        self.localVideoViewContainer.frame = newFrame
        self.localVideoViewContainer.layoutIfNeeded()
        self.localVideoViewContainer.layer.cornerRadius = newFrame.size.width / 2
        
        self.view.layoutIfNeeded()
        
        UIView.animate(withDuration: 0.25, animations: {
            if self.isAudioCall {
                self.audioIndicatorContainer.alpha = 0
                self.audioCallLabel.alpha = 0
            }
            self.blackoutView.alpha = 1
            self.blackoutButtonContainer.alpha = 1
        })
    }
    
    func sendOrientationRequest() {
        let message = QBChatMessage()
        message.text = "orientationRequest"
        message.senderID = UInt(DGStreamCore.instance.currentUser?.userID ?? 0)
        message.recipientID = self.selectedUser.uintValue
        QBChat.instance.sendSystemMessage(message, completion: { (error) in
            
        })
    }
    
    func sendOrientationUpdateTo(userID: NSNumber) {
        let orientation:UIInterfaceOrientation = UIApplication.shared.statusBarOrientation
        var orientationString = ""
        if orientation == .portrait {
            orientationString = "portrait"
        }
        else if orientation == .landscapeLeft {
            orientationString = "landscapeLeft"
        }
        else if orientation == .landscapeRight {
            orientationString = "landscapeRight"
        }
        else if orientation == .portraitUpsideDown {
            orientationString = "upsideDown"
        }
        
        let message = QBChatMessage()
        message.text = "orientationUpdate-\(orientationString)"
        message.senderID = UInt(DGStreamCore.instance.currentUser?.userID ?? 0)
        message.recipientID = userID.uintValue
        QBChat.instance.sendSystemMessage(message, completion: { (error) in
            
        })
    }
    
    func updateRecordingWith(orientation: UIInterfaceOrientation) {
        
        self.recordingManager.orientation = orientation
        
        if self.isWaitingForOrientation {
            self.isWaitingForOrientation = false
//            self.recordingManager.endRecording {
//                self.recordingManager.startRecordingWith(localCaptureSession: self.cameraCapture.captureSession, remoteRecorder: self.session!.recorder!, bufferQueue: self.bufferQueue!, documentNumber: "01234-56789", isMerged: self.callMode == .merge, delegate: self)
//            }
        }
        
//        let orientation = UIApplication.shared.statusBarOrientation
//        if orientation == .landscapeLeft {
//            recorder.setVideoRecording(._0)
//        }
//        else if orientation == .landscapeRight {
//            recorder.setVideoRecording(._180)
//        }
//        else if orientation == .portrait {
//            recorder.setVideoRecording(._270)
//        }
//        else {
//            recorder.setVideoRecording(._90)
//        }
        
//        if let recorder = self.session?.recorder {
//            if (self.oldOrientation == .landscapeLeft && orientation == .landscapeRight) || (self.oldOrientation == .landscapeRight && orientation == .landscapeLeft) {
//                recorder.setVideoRecording(._180)
//            }
//            else if (self.oldOrientation == .portrait && orientation == .portraitUpsideDown) || (self.oldOrientation == .portraitUpsideDown && orientation == .portrait) {
//                recorder.setVideoRecording(._180)
//            }
//            else if self.oldOrientation == .landscapeLeft && orientation == .portrait {
//                recorder.setVideoRecording(._270)
//            }
//            else if self.oldOrientation == .landscapeLeft && orientation == .portraitUpsideDown {
//                recorder.setVideoRecording(._90)
//            }
//            else if self.oldOrientation == .landscapeRight && orientation == .portrait {
//                recorder.setVideoRecording(._90)
//            }
//            else if self.oldOrientation == .landscapeRight && orientation == .portraitUpsideDown {
//                recorder.setVideoRecording(._270)
//            }
//            else if self.oldOrientation == .portrait && orientation == .landscapeLeft {
//                recorder.setVideoRecording(._90)
//            }
//            else if self.oldOrientation == .portrait && orientation == .landscapeRight {
//                recorder.setVideoRecording(._270)
//            }
//        }
//        
//        self.oldOrientation = orientation
        
    }
    
    //MARK:- Timers
    func playCallingSound(sender: Any) {
        
    }
    
    func refreshCallTime(sender: Timer) {
        if didHangUp == false {
            self.timeDuration += 1.0
            let extraTitle = self.formatTimeFor(seconds: self.timeDuration)
            self.statusBarTitle.text = extraTitle
        }
    }
    
    func getHoursMinutesSecondsFrom(seconds: Double) -> (hours: Int, minutes: Int, seconds: Int) {
        let secs = Int(seconds)
        let hours = secs / 3600
        let minutes = (secs % 3600) / 60
        let seconds = (secs % 3600) % 60
        return (hours, minutes, seconds)
    }
    
    func formatTimeFor(seconds: Double) -> String {
        let result = getHoursMinutesSecondsFrom(seconds: seconds)
        let hoursString = "\(result.hours)"
        var minutesString = "\(result.minutes)"
        if minutesString.characters.count == 1 {
            minutesString = "0\(result.minutes)"
        }
        var secondsString = "\(result.seconds)"
        if secondsString.characters.count == 1 {
            secondsString = "0\(result.seconds)"
        }
        var time = "\(hoursString):"
        if result.hours >= 1 {
            time.append("\(minutesString):\(secondsString)")
        }
        else {
            time = "\(minutesString):\(secondsString)"
        }
        return time
    }
    
    func captureScreen(screenView: UIView) {
        self.screenCapture = DGStreamScreenCapture(view: screenView)
        self.screenCapture?.view.contentMode = .scaleAspectFill
        self.session?.localMediaStream.videoTrack.videoCapture = self.screenCapture
    }
    
    func endScreenCapture() {
        self.screenCapture = nil
        self.session?.localMediaStream.videoTrack.videoCapture = self.cameraCapture
    }
    
    func removeBlackout() {
        
        self.blackoutView.alpha = 0.99
        
        let newFrame = frameForLocalVideo(isCenter: false)
        
        print("New Frame \(newFrame)")
        
        if self.isAudioCall {
            UIView.animate(withDuration: 0.35, animations: {
                self.statusBar.backgroundColor = UIColor.dgGreen()
                self.audioIndicatorContainer.alpha = 1
                self.audioCallLabel.alpha = 1
                self.blackoutView.alpha = 0
            }, completion: { (f) in
                
            })
        }
        else {
            
            UIView.animate(withDuration: 0.35, delay: 0.01, options: .curveEaseIn, animations: {
                
                self.statusBar.backgroundColor = UIColor.dgGreen()
                
                self.blackoutView.alpha = 0
                
                self.buttonsContainer.alpha = 1
                self.mergeButtonContainer.alpha = 1
                self.drawButtonContainer.alpha = 1
                self.whiteBoardButtonContainer.alpha = 1
                self.shareScreenButtonContainer.alpha = 1
                self.freezeButtonContainer.alpha = 1
                self.snapshotButtonContainer.alpha = 1
                self.chatButtonContainer.alpha = 1
                
                self.localBroadcastView?.frame = CGRect(x: 0, y: 0, width: newFrame.size.width, height: newFrame.size.height)
                self.localBroadcastView?.layoutIfNeeded()
                self.localVideoViewContainer?.frame = newFrame
                self.localVideoViewContainer?.layer.cornerRadius = newFrame.size.width / 2
                self.localVideoViewContainer?.layoutIfNeeded()
                
            }) { (f) in
                self.animateButtons()
            }
            
            self.freezeImageView = UIImageView.init(frame: self.remoteVideoViewContainer.bounds)
            self.freezeImageView?.image = nil
            self.freezeImageView?.boundInside(container: self.remoteVideoViewContainer)
            self.freezeImageView?.alpha = 0
            
        }
    
    }
    
    func showDropDown(animated: Bool) {
        self.setDropDownView(isOrientationReset: false)
        self.dropDown.backgroundColor = UIColor.dgYellow()
        self.dropDownTopConstraint.constant = 30
        self.view.layoutIfNeeded()
        let newRect = CGRect(x: 10, y: 84, width: self.localVideoViewContainer.frame.width, height: self.localVideoViewContainer.frame.height)
        if animated {
            UIView.animate(withDuration: 0.25) {
                self.dropDown.frame = self.dropDownContainer.frame
                self.dropDown.alpha = 1
                self.localVideoViewContainer.frame = newRect
            }
        }
        else {
            self.dropDown.frame = self.dropDownContainer.frame
            self.dropDown.alpha = 1
            self.localVideoViewContainer.frame = newRect
        }
    }
    
    func hideDropDown(animated: Bool) {
        self.dropDownTopConstraint.constant = 0
        self.view.layoutIfNeeded()
        let newRect = CGRect(x: 10, y: 40, width: self.localVideoViewContainer.frame.width, height: self.localVideoViewContainer.frame.height)
        if animated {
            UIView.animate(withDuration: 0.25, animations: {
                self.dropDown.backgroundColor = UIColor.dgGreen()
                self.dropDown.frame = self.dropDownContainer.frame
                self.dropDown.alpha = 0
                self.localVideoViewContainer.frame = newRect
            }, completion: { (f) in
                //self.dropDown.removeFromSuperview()
                //self.dropDown = nil
            })
        }
        else {
            self.dropDown.backgroundColor = UIColor.dgGreen()
            self.dropDown.frame = self.dropDownContainer.frame
            self.dropDown.alpha = 0
            self.localVideoViewContainer.frame = newRect
            //self.dropDown.removeFromSuperview()
            //self.dropDown = nil
        }
    }
    
    func toggleControls() {
        if self.isAudioCall == false {
            if self.chatVC.view.alpha == 1 {
                if self.chatVC.isKeyboardShown == false {
                    self.hideChatVC()
                }
            }
            else if self.isDrawing == false && self.callMode != .board {
                if self.isShowingControls {
                    self.hideControls()
                }
                else {
                    self.showControls()
                }
            }
        }
    }
    
    func showControls() {
        self.isShowingControls = true
        UIView.animate(withDuration: 0.25) {
            self.buttonsContainer.alpha = 1
            self.statusBar.alpha = 1
            self.hangUpButtonContainer.alpha = 1
            self.localVideoViewContainer.alpha = 1
        }
    }
    
    func hideControls() {
        self.isShowingControls = false
        UIView.animate(withDuration: 0.25) {
            self.buttonsContainer.alpha = 0
            self.statusBar.alpha = 0
            self.hangUpButtonContainer.alpha = 0
            self.localVideoViewContainer.alpha = 0
        }
    }
    
    //MARK:- Button Actions
    @IBAction func muteButtonTapped(_ sender: Any) {
        
    }

    @IBAction func flipButtonTapped(_ sender: Any) {
        
    }
    
    
    @IBAction func recordButtonTapped(_ sender: Any) {
//        DispatchQueue.main.async {
//            if self.isRecording {
//                self.didRecord = true
//                self.isRecording = false
//                self.shareScreenButton.backgroundColor = UIColor.dgBlueDark()
//                self.shareScreenButton.isEnabled = false
//                //                    self.recordingManager.endRecording {
//                //                        print("endRecording")
//                //                        //DGStreamRecording
//                //                        let writer = DGStreamRecordingWriter()
//                //                        writer.saveMovieToLibrary(withScreenshots: self.recordedScreenshots)
//                //                    }
//                let writer = DGStreamRecordingWriter()
//                writer.saveMovieToLibrary(withScreenshots: self.recordedScreenshots)
//
//            }
//            else {
//                self.shareScreenButton.backgroundColor = .red
//                self.recordingManager.startRecordingWith(localCaptureSession: self.cameraCapture.captureSession, remoteRecorder: self.session!.recorder!, bufferQueue: self.bufferQueue!, documentNumber: "01234-56789", isMerged: self.callMode == .merge, delegate: self)
//                self.isRecording = true
//                print("start recording")
//            }
//        }
        
    }
    
    @IBAction func drawButtonTapped(_ sender: Any) {
        if self.isDrawing {
            drawEndRequest()
        }
        else {
            drawRequest()
        }
    }
    
    @IBAction func whiteBoardButtonTapped(_ sender: Any) {
        // Hide video
        if self.whiteBoardUsers.contains(DGStreamCore.instance.currentUser?.userID ?? 0) {
            hideDropDown(animated: true)
            endWhiteBoardFor(userID: DGStreamCore.instance.currentUser?.userID ?? 0)
        }
        else {
            showDropDown(animated: true)
            startWhiteBoardFor(userID: DGStreamCore.instance.currentUser?.userID ?? 0)
        }
    }
    
    @IBAction func mergeButtonTapped(_ sender: Any) {
        
        if callMode == .merge {
            if let currentUser = DGStreamCore.instance.currentUser, let currentUserID = currentUser.userID {

                let unmergeMessage = QBChatMessage()
                unmergeMessage.text = "mergeEnd"
                unmergeMessage.senderID = currentUserID.uintValue
                unmergeMessage.recipientID = self.selectedUser.uintValue
                
                QBChat.instance.sendSystemMessage(unmergeMessage, completion: { (error) in
                    print("Sent Unmerge System Message With \(error?.localizedDescription ?? "No Error")")
                })
            }
            returnToStreamMode()
        }
        else {
            // Send push notification that asks the helper to merge with their reality
            if let currentUser = DGStreamCore.instance.currentUser, let currentUserID = currentUser.userID, let mergeRequestView = UINib(nibName: "DGStreamAlertView", bundle: Bundle(identifier: "com.dataglance.DGStream")).instantiate(withOwner: self, options: nil).first as? DGStreamAlertView {
                
                mergeRequestView.configureFor(mode: .mergeRequest, fromUsername: nil, message: NSLocalizedString("Waiting for response...", comment: ""),isWaiting: true)
                self.alertView = mergeRequestView
                DGStreamManager.instance.waitingForResponse = .merge
                mergeRequestView.presentWithin(viewController: self, fromUsername: NSLocalizedString("Merge", comment: ""), block: { (accepted) in })
                
                let mergeRequestMessage = QBChatMessage()
                mergeRequestMessage.text = "mergeRequest"
                mergeRequestMessage.senderID = currentUserID.uintValue
                mergeRequestMessage.recipientID = self.selectedUser.uintValue
                
                QBChat.instance.sendSystemMessage(mergeRequestMessage, completion: { (error) in
                    print("Sent Merge System Message With \(error?.localizedDescription ?? "No Error")")
                    if error != nil {
                        mergeRequestView.dismiss()
                        
                        let message = DGStreamMessage()
                        message.message = "Merge failed."
                        message.isSystem = true
                        self.chatPeekView.addCellWith(message: message)
                    }
                })
            }
        }
        
    }
    
    @IBAction func hangUpButtonTapped(_ sender: Any) {
        
        func closeOut() {
            if let timer = self.callTimer {
                timer.invalidate()
                self.callTimer = nil
            }
            if let timer = self.beepTimer {
                timer.invalidate()
                self.beepTimer = nil
            }
            DGStreamCore.instance.audioPlayer.stopAllSounds()
            self.didHangUp = true
            self.cameraCapture.stopSession {
                
            }
            self.cameraCapture = nil
            self.session?.hangUp(["hangup" : "hang up"])
            self.session = nil
            if let tab = self.navigationController?.viewControllers.first {
                DGStreamCore.instance.presentedViewController = nil
                DGStreamCore.instance.presentedViewController = tab
            }
            self.navigationController?.popViewController(animated: false)
            UIDevice.current.endGeneratingDeviceOrientationNotifications()
            NotificationCenter.default.removeObserver(self, name: Notification.Name.UIDeviceOrientationDidChange, object: nil)
            NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillHide, object: nil)
            NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillShow, object: nil)
        }
        
//        if self.recordingManager.isRecording {
//            self.recordingManager.endRecording {
//                self.recordingManager.finalizeRecording(completion: { (url) in
//                    closeOut()
//                })
//            }
//        }
//        else if self.recordingManager.recordings.count > 0 {
//            self.recordingManager.finalizeRecording(completion: { (url) in
//                closeOut()
//            })
//        }
//        else {
//            closeOut()
//        }
        closeOut()
    
    }
    
    func freeze() {
        
        // Other device has frozen the screen. This would be your screen.
        
        if let localView = self.localBroadcastView {
            if self.callMode == .merge {
                localView.alpha = 0.5
            }
            else {
                localView.alpha = 1.0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                if let image = DGStreamScreenCapture(view: self.remoteVideoViewContainer).screenshot() {
                    self.freezeFrame = image
                    self.isFrozen = true
                    localView.alpha = 0.0
                }
            }
        }
        
        if let user = DGStreamCore.instance.getOtherUserWith(userID: self.selectedUser), let username = user.username {
            let message = DGStreamMessage()
            message.message = "\(username) has frozen the screen."
            message.isSystem = true
            self.chatPeekView.addCellWith(message: message)
        }
        
        self.freezeButton.backgroundColor = UIColor.dgMergeMode()
        
        //self.jotVC?.view.alpha = 0

        // Freeze from remote
//        if let imageData = imageData, let image = UIImage(data: imageData) {
//
//            let freezeMessage = QBChatMessage()
//            freezeMessage.text = "didFreeze"
//            freezeMessage.senderID = DGStreamCore.instance.currentUser?.userID?.uintValue ?? 0
//            freezeMessage.recipientID = self.selectedUser.uintValue
//
//            QBChat.instance.sendSystemMessage(freezeMessage, completion: { (error) in
//                print("Sent Did Freeze System Message With \(error?.localizedDescription ?? "No Error")")
//            })
//
//            isFrozen = true
//            self.freezeImageView?.image = image
//            self.freezeImageView?.alpha = 1
//            print("frozen")
//            if let jot = self.jotVC, let freezeView = self.freezeImageView {
//                self.remoteVideoViewContainer.insertSubview(freezeView, belowSubview: jot.view)
//            }
//        }
        // Local Freeze
//        else {
//
//            let freezeMessage = QBChatMessage()
//            freezeMessage.text = "prepFreeze"
//            freezeMessage.senderID = DGStreamCore.instance.currentUser?.userID?.uintValue ?? 0
//            freezeMessage.recipientID = self.selectedUser.uintValue
//
//            QBChat.instance.sendSystemMessage(freezeMessage, completion: { (error) in
//                print("Sent Did Freeze System Message With \(error?.localizedDescription ?? "No Error")")
//            })
//
//            if let snapshot = DGStreamScreenCapture.takeScreenshotOf(view: self.remoteVideoViewContainer), let currentUser = DGStreamCore.instance.currentUser, let currentUserID = currentUser.userID, let imageData = UIImagePNGRepresentation(snapshot), let fileID = NSString.init(string: UUID().uuidString).components(separatedBy: "-").first {
//
//                isFrozen = true
//                self.freezeImageView?.image = snapshot
//                self.freezeImageView?.alpha = 1
//                print("frozen")
//                if let jot = self.jotVC, let freezeView = self.freezeImageView {
//                    self.remoteVideoViewContainer.insertSubview(freezeView, belowSubview: jot.view)
//                }
//
//                QBRequest.tUploadFile(imageData, fileName: fileID, contentType: "image/png", isPublic: true, successBlock: { (response, blob) in
//
//                    let freezeMessage = QBChatMessage()
//                    freezeMessage.text = "freeze"
//                    freezeMessage.senderID = currentUserID.uintValue
//                    freezeMessage.recipientID = self.selectedUser.uintValue
//
//                    let uploadedFileID: UInt = blob.id
//                    let attachment: QBChatAttachment = QBChatAttachment()
//                    attachment.type = "image"
//                    attachment.id = String(uploadedFileID)
//                    freezeMessage.attachments = [attachment]
//
//                    QBChat.instance.sendSystemMessage(freezeMessage, completion: { (error) in
//                        print("Sent Freeze System Message With \(error?.localizedDescription ?? "No Error")")
//                    })
//
//                }, statusBlock: { (request, status) in
//
//                }, errorBlock: { (response) in
//
//                })
//
//                self.jotVC?.view.alpha = 1
//
//            }
//
//        }
        
    }
    
    func unfreeze() {
        if self.callMode == .merge {
            self.localBroadcastView?.alpha = 0.5
        }
        else {
            self.localBroadcastView?.alpha = 1.0
        }
        self.freezeFrame = nil
        isFrozen = false
        self.freezeButton.backgroundColor = UIColor.dgBlueDark()
        self.freezeImageView?.image = nil
        self.freezeImageView?.alpha = 0
    }
    
    @IBAction func freezeButtonTapped(_ sender: Any) {
        
        if self.isFrozen {
            if self.callMode == .merge {
                self.localBroadcastView?.alpha = 0.5
            }
            else {
                self.localBroadcastView?.alpha = 1.0
            }
            self.freezeFrame = nil
            self.isFrozen = false
            let unfreezeMessage = QBChatMessage()
            unfreezeMessage.text = "unfreeze"
            unfreezeMessage.senderID = DGStreamCore.instance.currentUser?.userID?.uintValue ?? 0
            unfreezeMessage.recipientID = self.selectedUser.uintValue
            self.freezeButton.backgroundColor = UIColor.dgBlueDark()
            QBChat.instance.sendSystemMessage(unfreezeMessage, completion: { (error) in
                print("Sent Unfreeze System Message With \(error?.localizedDescription ?? "No Error")")
                //self.hideFreezeActivityIndicator()
            })
        }
        else {
            if self.callMode == .merge {
                self.localBroadcastView?.alpha = 0.5
            }
            else {
                self.localBroadcastView?.alpha = 1.0
            }
            if let image = DGStreamScreenCapture(view: self.remoteVideoViewContainer).screenshot() {
                self.freezeFrame = image
                self.isFrozen = true
                let freezeMessage = QBChatMessage()
                freezeMessage.text = "freeze"
                freezeMessage.senderID = DGStreamCore.instance.currentUser?.userID?.uintValue ?? 0
                freezeMessage.recipientID = self.selectedUser.uintValue
                self.freezeButton.backgroundColor = UIColor.dgMergeMode()
                QBChat.instance.sendSystemMessage(freezeMessage, completion: { (error) in
                    print("Sent Unfreeze System Message With \(error?.localizedDescription ?? "No Error")")
                    //self.hideFreezeActivityIndicator()
                    self.localBroadcastView?.alpha = 0.0
                })
            }
        }
        
//        showFreezeActivityIndicator()
//
//        if isFrozen, let currentUser = DGStreamCore.instance.currentUser, let currentUserID = currentUser.userID {
//
//            self.unfreeze()
//
//            let unfreezeMessage = QBChatMessage()
//            unfreezeMessage.text = "unfreeze"
//            unfreezeMessage.senderID = currentUserID.uintValue
//            unfreezeMessage.recipientID = self.selectedUser.uintValue
//
//            QBChat.instance.sendSystemMessage(unfreezeMessage, completion: { (error) in
//                print("Sent Unfreeze System Message With \(error?.localizedDescription ?? "No Error")")
//                self.hideFreezeActivityIndicator()
//            })
//
//        }
//        else {
//            //self.freeze(imageData: nil)
//        }
    }
    
    func showFreezeActivityIndicator() {
        self.freezeButton.setImage(nil, for: .normal)
        self.freezeButton.isEnabled = false
        self.freezeActivityIndicator.isHidden = false
        self.freezeActivityIndicator.startAnimating()
    }
    
    func hideFreezeActivityIndicator() {
        // The freeze is confirmed by other device
        if self.isFrozen {
            self.freezeButton.backgroundColor = UIColor.dgYellow()
            self.statusBar.backgroundColor = UIColor.dgYellow()
        }
        else {
            self.freezeButton.backgroundColor = UIColor.dgBlueDark()
            if self.isDrawing == false && self.callMode != .merge && self.callMode != .board {
                self.statusBar.backgroundColor = UIColor.dgGreen()
            }
        }
        self.freezeButton.setImage(UIImage.init(named: "freeze", in: Bundle.init(identifier: "com.dataglance.DGStream"), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.freezeButton.isEnabled = true
        self.freezeActivityIndicator.isHidden = true
        self.freezeActivityIndicator.stopAnimating()
    }
    
    @IBAction func snapshotButtonTapped(_ sender: Any) {
//        if let snapshot = DGStreamScreenCapture.takeScreenshotOf(view: self.remoteVideoViewContainer) {
//            let photoSaver = DGStreamPhotoSaver()
//            photoSaver.delegate = self
//            photoSaver.save(snapshot)
//        }
        if let snap = DGStreamScreenCapture(view: self.view).screenshot() {
            let photoSaver = DGStreamPhotoSaver()
            photoSaver.delegate = self
            photoSaver.save(snap)
        }
    }
    
    func finishedTakingSnapshot() {
        if isShowingLabel == false {
            self.isShowingLabel = true
            UIView.animate(withDuration: 0.18, animations: {
                self.savedPhotoLabel.alpha = 1
            }, completion: { (finished) in
                UIView.animate(withDuration: 0.18, delay: 2.0, options: .curveEaseInOut, animations: {
                    self.savedPhotoLabel.alpha = 0
                }, completion: { (finished) in
                    self.isShowingLabel = false
                })
            })
        }
    }
    
    @IBAction func chatButtonTapped(_ sender: Any) {
        toggleChat()
    }
    
    func toggleChat() {
        if self.isChatShown {
            self.hideChatVC()
        }
        else {
            self.showChatVC()
        }
    }
    
    func showChatVC() {
        // Fade out buttons
        self.isChatShown = true
        UIView.animate(withDuration: 0.25, animations: {
            self.view.layoutIfNeeded()
            self.chatContainer.alpha = 1
            self.chatVC.view.alpha = 1
        }) { (fi) in
            
        }
    }
    
    func hideChatVC() {
        // Dismiss ChatVC
        self.isChatShown = false
        UIView.animate(withDuration: 0.25, animations: {
            self.view.layoutIfNeeded()
            self.chatContainer.alpha = 0
            self.chatVC.view.alpha = 0
        }) { (fi) in
            
        }
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        if isSettingText {
            sendDrawing()
            endSettingText(cancelled: false)
        }
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        
        if self.isSettingText {
            self.endSettingText(cancelled: true)
        }
        else if self.callMode == .board {
            endWhiteBoardFor(userID: DGStreamCore.instance.currentUser?.userID ?? 0)
        }
        else if self.isDrawing {
            self.drawEndRequest()
        }
        else if self.callMode == .merge {
            if let currentUser = DGStreamCore.instance.currentUser, let currentUserID = currentUser.userID {
                
                let unmergeMessage = QBChatMessage()
                unmergeMessage.text = "unmerge"
                unmergeMessage.senderID = currentUserID.uintValue
                unmergeMessage.recipientID = self.selectedUser.uintValue
                
                QBChat.instance.sendSystemMessage(unmergeMessage, completion: { (error) in
                    print("Sent Unmerge System Message With \(error?.localizedDescription ?? "No Error")")
                })
                
            }
            returnToStreamMode()
        }
    
    }
    
    @IBAction func paletteTextButtonTapped(_ sender: Any) {
        if let jot = self.jotVC {
            if jot.state == .drawing {
                startSettingText()
                jot.state = .text
                self.paletteTextButton.setImage(UIImage.init(named: "EditPencil", in: Bundle.init(identifier: "com.dataglance.DGStream"), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
                self.paletteTextButton.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8)
            }
            else if jot.state == .text {
                jot.state = .drawing
                
                self.paletteTextButton.setImage(UIImage.init(named: "text", in: Bundle.init(identifier: "com.dataglance.DGStream"), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
                self.paletteTextButton.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 9)

            }
        }
    }
    
    @IBAction func blackoutCancelButtonTapped(_ sender: Any) {
        self.hangUpButtonTapped(sender)
    }
    
    @IBAction func blackoutCallBackButtonTapped(_ sender: Any) {
        self.blackoutButtonContainer.alpha = 0
        self.hangUpButtonContainer.alpha = 1
        self.navigationController?.popViewController(animated: false)
        if self.isAudioCall {
            NotificationCenter.default.post(name: Notification.Name("RestartAudioCall"), object: self.selectedUser)
        }
        else {
            NotificationCenter.default.post(name: Notification.Name("RestartVideoCall"), object: self.selectedUser)
        }
    }
    
    //MARK:- Switch Mode
    
    func playMergeSound() {
//        QBRTCAudioSession.instance().isAudioEnabled = false
//        DGStreamCore.instance.audioPlayer.ringForMerge()
    }
    
    func startMergeMode() {
        
        func merge() {
//            self.isWaitingForOrientation = true
//            self.sendOrientationRequest()
            
            DispatchQueue.main.async {
                
                self.endWhiteBoardFor(userID: DGStreamCore.instance.currentUser?.userID ?? 0)
                
                // Set Merge Mode
                self.callMode = .merge
                
                DGStreamCore.instance.audioPlayer.stopAllSounds()
                if QBRTCAudioSession.instance().isAudioEnabled == false {
                    QBRTCAudioSession.instance().isAudioEnabled = true
                }
                
                if let alertView = self.alertView {
                    alertView.dismiss()
                }
                
                print("\n\nStart Merge For Helper\n\n")
                
                self.isHelper = true
                
                self.statusBarBackButton.setTitle(NSLocalizedString("Cancel", comment: "Stop action"), for: .normal)
                
                UIView.animate(withDuration: 0.18) {
                    self.mergeButton.backgroundColor = UIColor.dgMergeMode()
                    self.statusBar.backgroundColor = UIColor.dgMergeMode()
                    self.statusBarBackButton.alpha = 1
                }
                
                // Remove LocalVideoVideo from container
//                if self.localVideoView != nil {
//                    self.localVideoView?.removeFromSuperview()
//                    self.localVideoView = nil
//                }
                
                // Place Local Video On Top of Remote
                self.localBroadcastView?.boundInside(container: self.remoteVideoViewContainer)
                self.localBroadcastView?.alpha = 0.50
                //self.localBroadcastView?.updateOrientationIfNeeded()
                //self.localVideoView?.videoLayer.videoGravity = AVLayerVideoGravityResize
                
                if let freezeImageView = self.freezeImageView {
                    self.remoteVideoViewContainer.insertSubview(freezeImageView, aboveSubview: self.remoteVideoViewContainer)
                }
                
                if let remoteVideo = self.videoViewWith(userID: self.selectedUser) as? QBRTCRemoteVideoView {
                    remoteVideo.alpha = 1
                    remoteVideo.videoGravity = AVLayerVideoGravityResize
                }
                
                if let localDrawView = self.localDrawImageView {
                    self.remoteVideoViewContainer.bringSubview(toFront: localDrawView)
                }
                
                if let remoteDrawView = self.remoteDrawImageView {
                    self.remoteVideoViewContainer.bringSubview(toFront: remoteDrawView)
                }
                
                if let jotVC = self.jotVC {
                    self.remoteVideoViewContainer.bringSubview(toFront: jotVC.view)
                }
                
                // Hide Local Video Container
//                self.localVideoViewContainer.isHidden = true
                
                // Set Transmission To Send Back Camera Video
                self.cameraCapture.configureSession {
                    self.cameraCapture.position = .back
                }
                //self.session?.localMediaStream.videoTrack.videoCapture = nil
                //self.session?.localMediaStream.videoTrack.videoCapture = self.cameraCapture
                
                QBRTCAudioSession.instance().initialize { (config) in
                    config.categoryOptions = [.defaultToSpeaker]
                    if self.session?.conferenceType == .video {
                        config.mode = AVAudioSessionModeVideoChat
                    }
                }
                self.session?.localMediaStream.audioTrack.isEnabled = true
                self.session?.localMediaStream.videoTrack.isEnabled = true
                
                self.whiteBoardButton.isEnabled = false
                //self.shareScreenButton.isEnabled = false
            }
        }
        
//        if self.recordingManager.isRecording {
//            self.recordingManager.endRecording {
//                merge()
//            }
//        }
//        else {
//            merge()
//        }
        
        merge()
        
    }
    
    func returnToStreamMode() {
                
        func toStream() {
            DGStreamCore.instance.audioPlayer.stopAllSounds()
            //        if QBRTCAudioSession.instance().isAudioEnabled == false {
            //            QBRTCAudioSession.instance().isAudioEnabled = true
            //        }
            
            UIView.animate(withDuration: 0.18) {
                self.mergeButton.backgroundColor = UIColor.dgBlueDark()
                self.mergeButton.isEnabled = true
                if !self.isDrawing {
                    self.drawButton.backgroundColor = UIColor.dgBlueDark()
                }
                self.drawButton.isEnabled = true
                self.whiteBoardButton.backgroundColor = UIColor.dgBlueDark()
                self.whiteBoardButton.isEnabled = true
                self.statusBar.backgroundColor = UIColor.dgStreamMode()
                self.statusBarBackButton.alpha = 0
            }
            
            if let alert = self.alertView {
                alert.dismiss()
            }
            
            self.callMode = .stream
            
            // Switch current device to merge mode
            self.localBroadcastView?.alpha = 1.0
            self.localBroadcastView?.boundInside(container: self.localVideoViewContainer)
            //self.localVideoView?.videoLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
            
            if let remoteVideo = self.videoViewWith(userID: self.selectedUser) as? QBRTCRemoteVideoView {
                remoteVideo.alpha = 1
                remoteVideo.videoGravity = AVLayerVideoGravityResizeAspect
            }
            
            if let localDrawView = self.localDrawImageView {
                self.remoteVideoViewContainer.bringSubview(toFront: localDrawView)
            }
            
            if let remoteDrawView = self.remoteDrawImageView {
                self.remoteVideoViewContainer.bringSubview(toFront: remoteDrawView)
            }
            
            if let jotVC = self.jotVC {
                self.remoteVideoViewContainer.bringSubview(toFront: jotVC.view)
            }
            
            self.localVideoViewContainer.isHidden = false
            
            self.cameraCapture.configureSession {
                self.cameraCapture.position = .front
            }
            //self.session?.localMediaStream.videoTrack.videoCapture = nil
            //self.session?.localMediaStream.videoTrack.videoCapture = self.cameraCapture
            self.session?.localMediaStream.audioTrack.isEnabled = true
            self.session?.localMediaStream.videoTrack.isEnabled = true
        }
        
//        if self.recordingManager.isRecording {
//            self.recordingManager.endRecording {
//                toStream()
//            }
//        }
//        else {
//            toStream()
//        }
        toStream()
    }
    
    //MARK:- Orientation
    
    func shouldAutorotateToInterfaceOrientation(interfaceOrientation: UIInterfaceOrientation) -> Bool {
        
        // Native video orientation is landscape with the button on the right.
        // The video processor rotates vide as needed, so don't autorotate also
        return interfaceOrientation == UIInterfaceOrientation.landscapeRight
    }
    
    //MARK:- Touches
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !self.isSettingText {
            sendDrawing()
        }
    }
    
    //MARK:- Draw Mode
    
    func startDrawingTimer() {
        self.drawingTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true, block: { (timer) in
            if !self.isSettingText {
                self.sendDrawing()
            }
        })
    }
    
    func endDrawingTimer() {
        if let timer = self.drawingTimer {
            timer.invalidate()
            self.drawingTimer = nil
        }
    }
    
    func drawRequest() {
        
        let currentUserID = DGStreamCore.instance.currentUser?.userID ?? NSNumber.init(value: 0)

        // Update the UI to indicate we are switching to Draw Mode
        //self.remoteVideoViewContainer.alpha = 0
        
        // Send the Draw Request to each other user
        let drawStartMessage = QBChatMessage()
        drawStartMessage.text = "drawStart"
        drawStartMessage.senderID = currentUserID.uintValue
        drawStartMessage.recipientID = self.selectedUser.uintValue
        
        QBChat.instance.sendSystemMessage(drawStartMessage) { (error) in
            print("Sent Draw Start System Message With \(error?.localizedDescription ?? "No Error")")
            if error != nil {
                self.drawFailedWith(errorMessage: error?.localizedDescription ?? "Error")
            }
        }
        
        // Wait for the callback in drawAccepted()
        
        // Check if all other users have accepted (later)
        setDrawUserWith(userID: currentUserID)
        
    }
    
    func drawAcceptedFor(userID: NSNumber) {
        
        let currentUserID = DGStreamCore.instance.currentUser?.userID ?? NSNumber.init(value: 0)
        
        // Check if all other users have accepted (later)
        setDrawUserWith(userID: currentUserID)
        
        // Remove alert and show container
        self.remoteVideoViewContainer.alpha = 1
    }
    
    func setDrawUserWith(userID: NSNumber) {
        
        // Flag user as a drawing user
        if !self.drawingUsers.contains(userID) {
            self.drawingUsers.append(userID)
        }

        // If they are the selected user, change the UI
        if userID == self.selectedUser {
            //updateFrameFor(mode: .draw)
            
            //placeLocalVideoViewInRemoteContainer()
            
        }
        // If they are current user, enter draw mode
        else if let currentUser = DGStreamCore.instance.currentUser, let currentUserID = currentUser.userID, userID == currentUserID {
            self.isDrawing = true
            showDropDown(animated: true)
            UIView.animate(withDuration: 0.25, animations: {
                self.drawButton.backgroundColor = UIColor.dgMergeMode()
                self.statusBar.backgroundColor = UIColor.dgMergeMode()
                self.statusBarBackButton.setTitle(NSLocalizedString("Cancel", comment: "Stop action"), for: .normal)
                self.statusBarBackButton.alpha = 1
            })
            
            if self.jotVC == nil {
                self.jotVC = JotViewController()
                self.jotVC?.delegate = self
                self.jotVC?.view.boundInside(container: self.remoteVideoViewContainer)
                self.jotVC?.view.backgroundColor = .clear
                self.jotVC?.drawingContainer.backgroundColor = .clear
                self.jotVC?.view.alpha = 1.0
                self.jotVC?.didMove(toParentViewController: self)
                self.jotVC?.state = .drawing
                self.jotVC?.drawingColor = self.drawColor
                self.jotVC?.drawingStrokeWidth = self.drawSize
                self.jotVC?.textColor = self.drawColor
                self.jotVC?.initialTextInsets = UIEdgeInsets(top: UIScreen.main.bounds.size.height / 2, left: 0, bottom: 0, right: 0)
                self.jotVC?.textEditingInsets = UIEdgeInsets(top: UIScreen.main.bounds.size.height / 2, left: 0, bottom: 0, right: 0)
            }
            
        }
        
        if let jot = self.jotVC {
            self.remoteVideoViewContainer.bringSubview(toFront: jot.view)
        }
        
    }
    
    func drawEndRequest() {
        
        // Update the UI to indicate we are switching to Draw Mode
        
        // Send the Draw Request to each other user
        let drawEndMessage = QBChatMessage()
        drawEndMessage.text = "drawEnd"
        drawEndMessage.senderID = DGStreamCore.instance.currentUser?.userID?.uintValue ?? 0
        drawEndMessage.recipientID = self.selectedUser.uintValue
        
        QBChat.instance.sendSystemMessage(drawEndMessage) { (error) in
            print("Sent Draw End System Message With \(error?.localizedDescription ?? "No Error")")
        }
        
        // Wait for the callback in drawEndAccepted()
        self.drawEndWith(userID: DGStreamCore.instance.currentUser?.userID ?? 0)
    }
    
    func drawEndAcceptedWith(userID: NSNumber) {
        
        // Check if all other users have accepted (later)
        let currentUserID = DGStreamCore.instance.currentUser?.userID ?? NSNumber(value: 0)
        
        drawEndWith(userID: currentUserID)
        
        // Remove alert and show container
        self.remoteVideoViewContainer.alpha = 1
    }
    
    func drawFailedWith(errorMessage: String) {
        
    }
    
    func drawEndWith(userID: NSNumber) {
        if let currentUser = DGStreamCore.instance.currentUser, let currentUserID = currentUser.userID, userID == currentUserID {
            
            self.hideDropDown(animated: true)
            
            UIView.animate(withDuration: 0.18) {
                self.drawButton.backgroundColor = UIColor.dgBlueDark()
                if self.callMode != .merge || self.callMode != .board {
                    self.statusBar.backgroundColor = UIColor.dgStreamMode()
                    self.statusBarBackButton.alpha = 0
                    
                    self.paletteButtonContainer.alpha = 0
                    self.paletteTextButtonContainer.alpha = 0
                }
            }
            
            self.isDrawing = false
            
            if let jot = self.jotVC {
                jot.view.removeFromSuperview()
                self.jotVC = nil
            }
            
            if let flat = self.localDrawImageView {
                flat.removeFromSuperview()
                self.localDrawImageView = nil
            }
            
            if let flat = self.remoteDrawImageView, !self.drawingUsers.contains(self.selectedUser) && !self.whiteBoardUsers.contains(self.selectedUser) {
                flat.removeFromSuperview()
                self.remoteDrawImageView = nil
            }
            
        }
        else {
            if let flat = self.remoteDrawImageView {
                flat.removeFromSuperview()
                self.remoteDrawImageView = nil
            }
        }
        
        if let index = self.drawingUsers.index(of: userID) {
            self.drawingUsers.remove(at: index)
        }
        
    }
    
    func sendDrawing() {
        if let currentUser = DGStreamCore.instance.currentUser, let currentUserID = currentUser.userID, let jot = self.jotVC, let snapshot = jot.renderImage(), let fileID = UUID().uuidString.components(separatedBy: "-").first {
            self.localDrawImageView?.mergeImagesWith(newImage: snapshot)
            self.drawOperationQueue.addDrawing(snapshot: snapshot, fromCurrentUser: currentUserID, toUsers: [self.selectedUser], withFileID: fileID)
        }
    }
    
    func drawWithImage(data: Data, fromUserID: NSNumber) {
        if let image = UIImage(data: data) {
            if self.remoteDrawImageView == nil {
                self.remoteDrawImageView = UIImageView(frame: self.remoteVideoViewContainer.bounds)
                self.remoteDrawImageView?.image = UIImage(color: .clear, size: self.remoteVideoViewContainer.bounds.size)
                self.remoteDrawImageView?.boundInside(container: self.remoteVideoViewContainer)
            }
            self.remoteVideoViewContainer.bringSubview(toFront: self.remoteDrawImageView!)
            if let jot = self.jotVC {
                self.remoteVideoViewContainer.bringSubview(toFront: jot.view)
            }
            self.remoteDrawImageView?.mergeImagesWith(newImage: image)
        }
    }
    
}

//MARK:- White Board Mode
extension DGStreamCallViewController {
    
    func startWhiteBoardFor(userID: NSNumber) {
        if userID == DGStreamCore.instance.currentUser?.userID ?? 0 {
            
            let whiteboardStartMessage = QBChatMessage()
            whiteboardStartMessage.text = "whiteboardStart"
            whiteboardStartMessage.senderID = userID.uintValue
            whiteboardStartMessage.recipientID = self.selectedUser.uintValue
            
            QBChat.instance.sendSystemMessage(whiteboardStartMessage, completion: { (error) in
                print("Sent White Board System Message With \(error?.localizedDescription ?? "No Error")")
            })
            
        }
        
        DispatchQueue.main.async {
            
            if !self.whiteBoardUsers.contains(userID) {
                self.whiteBoardUsers.append(userID)
            }
            
            if userID == DGStreamCore.instance.currentUser?.userID ?? 0 || userID == self.selectedUser, self.whiteBoardView == nil {
                self.whiteBoardView = UIView(frame: self.remoteVideoViewContainer.bounds)
                self.whiteBoardView?.tag = 1999
                self.whiteBoardView?.backgroundColor = .white
                self.whiteBoardView?.boundInside(container: self.remoteVideoViewContainer)
                //self.layoutRemoteViewHeirarchy()
            }
            
            if userID == DGStreamCore.instance.currentUser?.userID ?? 0 {
                self.showDropDown(animated: true)
                
                UIView.animate(withDuration: 0.18) {
                    self.whiteBoardButton.backgroundColor = UIColor.dgMergeMode()
                    self.statusBar.backgroundColor = UIColor.dgMergeMode()
                    self.drawButton.backgroundColor = UIColor.dgMergeMode()
                    self.drawButton.isEnabled = false
                    self.mergeButton.isEnabled = false
                    self.statusBarBackButton.alpha = 1
                    
                    self.paletteButtonContainer.alpha = 1
                    self.paletteTextButtonContainer.alpha = 1
                }
                
                // Add current user's draw view on top off stack
                if self.jotVC == nil {
                    self.jotVC = JotViewController()
                    self.jotVC?.delegate = self
                    self.jotVC?.view.boundInside(container: self.remoteVideoViewContainer)
                    self.jotVC?.view.backgroundColor = .clear
                    self.jotVC?.drawingContainer.backgroundColor = .clear
                    self.jotVC?.view.alpha = 1.0
                    self.jotVC?.didMove(toParentViewController: self)
                    self.jotVC?.state = .drawing
                    self.jotVC?.drawingColor = self.drawColor
                    self.jotVC?.textColor = self.drawColor
                    self.jotVC?.drawingStrokeWidth = self.drawSize
                    self.jotVC?.initialTextInsets = UIEdgeInsets(top: UIScreen.main.bounds.size.height / 2, left: 0, bottom: 0, right: 0)
                    self.jotVC?.textEditingInsets = UIEdgeInsets(top: UIScreen.main.bounds.size.height / 2, left: 0, bottom: 0, right: 0)
                }
                
                self.callMode = .board
                
            }
        
        }
        
    }
    
    func endWhiteBoardFor(userID: NSNumber) {
        if self.callMode == .board {
            if userID == DGStreamCore.instance.currentUser?.userID ?? 0 {
                
                let whiteboardEndMessage = QBChatMessage()
                whiteboardEndMessage.text = "whiteboardEnd"
                whiteboardEndMessage.senderID = userID.uintValue
                whiteboardEndMessage.recipientID = self.selectedUser.uintValue
                whiteboardEndMessage.customParameters = ["isDrawing":"\(self.isDrawing)"]
                QBChat.instance.sendSystemMessage(whiteboardEndMessage, completion: { (error) in
                    print("Sent Whiteboard End System Message With \(error?.localizedDescription ?? "No Error")")
                })
                
            }
            
            if userID == self.selectedUser, !self.drawingUsers.contains(self.selectedUser), let remote = self.remoteDrawImageView {
                remote.image = UIImage(color: .clear, size: remote.bounds.size)
            }
            
            if let index = self.whiteBoardUsers.index(of: userID) {
                self.whiteBoardUsers.remove(at: index)
            }
            
            // If other user is not in whiteboard then remove whiteboard
            if let white = self.whiteBoardView {
                var shouldRemoveWhiteBoard = true
                if userID == self.selectedUser && self.callMode == .board {
                    shouldRemoveWhiteBoard = false
                }
                else if self.whiteBoardUsers.contains(selectedUser) {
                    shouldRemoveWhiteBoard = false
                }
                if shouldRemoveWhiteBoard {
                    white.removeFromSuperview()
                    self.whiteBoardView = nil
                    //self.layoutRemoteViewHeirarchy()
                }
            }
            
            if userID == DGStreamCore.instance.currentUser?.userID ?? 0 {
                UIView.animate(withDuration: 0.18) {
                    self.whiteBoardButton.backgroundColor = UIColor.dgBlueDark()
                    if self.isDrawing == false {
                        self.drawButton.backgroundColor = UIColor.dgBlueDark()
                        self.statusBar.backgroundColor = UIColor.dgStreamMode()
                        self.statusBarBackButton.alpha = 0
                        self.paletteButtonContainer.alpha = 0
                        self.paletteTextButtonContainer.alpha = 0
                        self.drawEndWith(userID: userID)
                    }
                }
                
                // Add current user's draw view on top off stack
                if let jot = self.jotVC, self.isDrawing == false {
                    jot.view.removeFromSuperview()
                    self.jotVC = nil
                    if let local = self.localDrawImageView {
                        local.image = UIImage(color: .clear, size: self.remoteVideoViewContainer.bounds.size)
                    }
                }
                
                // Set new mode
                self.callMode = .stream
            }
            self.drawButton.isEnabled = true
            self.mergeButton.isEnabled = true
        }
        else if userID == self.selectedUser, let whiteboardView = self.whiteBoardView {
            whiteboardView.removeFromSuperview()
            self.whiteBoardView = nil
        }
        
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
            user.username = ""
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

//MARK:- QBRTCClientDelegate
extension DGStreamCallViewController: QBRTCClientDelegate {
    public func session(_ session: QBRTCBaseSession, updatedStatsReport report: QBRTCStatsReport, forUserID userID: NSNumber) {

    }
    
    public func session(_ session: QBRTCSession, userDidNotRespond userID: NSNumber) {
        //print("USER \(userID) DID NOT RESPOND")
        DGStreamCore.instance.audioPlayer.stopAllSounds()
        if session == self.session {
            let alert = UIAlertController(title: "No Response", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action: UIAlertAction) in
                alert.dismiss(animated: true, completion: nil)
                self.navigationController?.popViewController(animated: true)
            }))
            present(alert, animated: true, completion: nil)
        }
    }
    
    public func session(_ session: QBRTCSession, acceptedByUser userID: NSNumber, userInfo: [String : String]? = nil) {

    }
    
    public func session(_ session: QBRTCSession, rejectedByUser userID: NSNumber, userInfo: [String : String]? = nil) {
        print("REJECTED BY \(userID)")
        DGStreamCore.instance.audioPlayer.stopAllSounds()

        if session == self.session {
            let alert = UIAlertController(title: "Call Rejected", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action: UIAlertAction) in
                alert.dismiss(animated: true, completion: nil)
                self.navigationController?.popViewController(animated: true)
            }))
            present(alert, animated: true, completion: nil)
        }
    }
    
    public func session(_ session: QBRTCSession, hungUpByUser userID: NSNumber, userInfo: [String : String]? = nil) {
        if userID == self.selectedUser {
            self.didOtherUserHangUp = true
            self.showCallEndedWith(isHungUp: true)
        }
        DGStreamCore.instance.audioPlayer.stopAllSounds()
    }
    
    public func session(_ session: QBRTCBaseSession, receivedRemoteVideoTrack videoTrack: QBRTCVideoTrack, fromUser userID: NSNumber) {
        print("RECEIVED REMOTE VIDEO TRACK FROM \(userID)")
        if session == self.session {
            if let _ = self.videoViewWith(userID: userID) {
                self.videoViews.removeValue(forKey: userID.uintValue)
            }
            
            let qbVideoView = QBRTCRemoteVideoView(frame: self.remoteVideoViewContainer.bounds)
            qbVideoView.setVideoTrack(videoTrack)
            qbVideoView.videoGravity = AVLayerVideoGravityResizeAspect
            
            self.videoViews[userID.uintValue] = qbVideoView
            
            if selectedUser.uintValue == userID.uintValue {
                let exists = self.remoteVideoViewContainer.subviews.filter({ (subview) -> Bool in
                    return subview is QBRTCRemoteVideoView
                }).first
                if exists == nil {
                    qbVideoView.boundInside(container: self.remoteVideoViewContainer)
                }
            }
            self.remoteVideoViewContainer.bringSubview(toFront: self.hangUpButton)
            self.remoteVideoViewContainer.bringSubview(toFront: self.mergeButton)
            self.remoteVideoViewContainer.bringSubview(toFront: self.drawButton)
            self.remoteVideoViewContainer.bringSubview(toFront: self.statusBar)
            
            qbVideoView.setSize(self.remoteVideoViewContainer.bounds.size)
        }
    }
    
    public func session(_ session: QBRTCBaseSession, receivedRemoteAudioTrack audioTrack: QBRTCAudioTrack, fromUser userID: NSNumber) {
        //print("RECEIVED REMOTE AUDIO TRACK FROM \(userID)")
    }
    
    public func session(_ session: QBRTCBaseSession, startedConnectingToUser userID: NSNumber) {

    }
    
    public func session(_ session: QBRTCBaseSession, connectedToUser userID: NSNumber) {
        print("CONNECTED TO \(userID)")
        if session == self.session {
            
            if userID == selectedUser && blackoutView.alpha != 0 {
                DispatchQueue.main.async {
                    self.removeBlackout()
                }
            }
            
            if !self.chatVC.chatConversation.userIDs.contains(userID) {
                self.chatVC.chatConversation.userIDs.append(userID)
            }
            
            if let beep = self.beepTimer {
                beep.invalidate()
                self.beepTimer = nil
                // Stop All Sounds
            }
            
            if self.callTimer == nil {
                self.callTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(refreshCallTime(sender:)), userInfo: nil, repeats: true)
            }
        
        }
    }
    
    public func session(_ session: QBRTCBaseSession, disconnectedFromUser userID: NSNumber) {
        print("DISCONNECTED FROM \(userID)")
        if self.didOtherUserHangUp == false && userID == self.selectedUser {
            self.showCallEndedWith(isHungUp: false)
        }
        if let index = self.chatVC.chatConversation.userIDs.index(of: userID) {
            self.chatVC.chatConversation.userIDs.remove(at: index)
        }
        if let recent = DGStreamCore.instance.lastRecent {
            recent.duration = self.timeDuration
            DGStreamManager.instance.dataStore.streamManager(DGStreamManager.instance, store: recent)
        }
//        self.recorder.endRecordingWith {
//            
//        }
    }
    
    public func session(_ session: QBRTCBaseSession, connectionClosedForUser userID: NSNumber) {
    }
    
    public func session(_ session: QBRTCBaseSession, connectionFailedForUser userID: NSNumber) {
        print("CONNECTION FAILED FOR \(userID)")
    }
    
    public func session(_ session: QBRTCBaseSession, didChange state: QBRTCSessionState) {
        printSession(state: state)
    }
    
    public func session(_ session: QBRTCBaseSession, didChange state: QBRTCConnectionState, forUser userID: NSNumber) {
        printConnection(state: state, for: userID)
    }
    
    public func didReceiveNewSession(_ session: QBRTCSession, userInfo: [String : String]? = nil) {
        print("DID RECEIVE NEW SESSION")
    }
    
    public func sessionDidClose(_ session: QBRTCSession) {
        print("SESSION CLOSED")
    }
    
    func printSession(state: QBRTCSessionState) {
    }
    
    func printConnection(state: QBRTCConnectionState, for userID: NSNumber) {
//        if state == .checking {
//            print("|-CHECKING - \(userID)-|")
//        }
//        if state == .closed {
//            print("|-CLOSED - \(userID)-|")
//        }
//        if state == .connected {
//            print("|-CONNECTED - \(userID)-|")
//        }
//        if state == .connecting {
//            print("|-CONNECTING - \(userID)-|")
//        }
//        if state == .count {
//            print("|-COUNT - \(userID)-|")
//        }
//        if state == .disconnected {
//            print("|-DISCONNECTED - \(userID)-|")
//        }
//        if state == .disconnectTimeout {
//            print("|-DISCONNECT TIMEOUT - \(userID)-|")
//        }
//        if state == .failed {
//            print("|-FAILED - \(userID)-|")
//        }
//        if state == .hangUp {
//            print("|-HANGUP - \(userID)-|")
//        }
//        if state == .new {
//            print("|-NEW - \(userID)-|")
//        }
//        if state == .noAnswer {
//            print("|-NO ANSWER - \(userID)-|")
//        }
//        if state == .pending {
//            print("|-PENDING - \(userID)-|")
//        }
//        if state == .rejected {
//            print("|-REJECTED - \(userID)-|")
//        }
//        if state == .unknown {
//            print("|-UNKNOWN - \(userID)-|")
//        }
    }
    
}

extension DGStreamCallViewController: JotViewControllerDelegate {
    public func jotViewController(_ jotViewController: JotViewController!, isEditingText isEditing: Bool) {
        print("IS EDITING \(isEditing)")
        if let jot = self.jotVC, self.isSettingText {
            jot.state = .text
        }
    }
}

//MARK:- QBRTCAudioSessionDelegate
extension DGStreamCallViewController: QBRTCAudioSessionDelegate {
}

//MARK:- DGStreamPhotoSaverDelegate
extension DGStreamCallViewController: DGStreamPhotoSaverDelegate {
    public func didTakeSessionSnapshot(_ image: UIImage!) {
        
    }
    
    public func didSavePhoto(_ success: Bool) {
        if success {
            finishedTakingSnapshot()
        }
    }
}

extension DGStreamCallViewController: DGStreamChatViewControllerDelegate {
    func chat(viewController: DGStreamChatViewController, backButtonTapped sender: Any?) {
        hideChatVC()
    }
    func chat(viewController: DGStreamChatViewController, didReceiveMessage message: DGStreamMessage) {
        self.chatPeekView.addCellWith(message: message)
    }
}

extension DGStreamCallViewController: DGStreamDropDownManagerDelegate {
    
    func startSettingText() {
        self.isSettingText = true
        self.dropDown.hideMenu()
        self.hideDropDown(animated: true)
        self.paletteTextButtonContainer.alpha = 0
        self.localVideoViewContainer.alpha = 0
        UIView.animate(withDuration: 0.18) {
            self.statusBarBackButton.alpha = 1
            self.statusBarBackButton.setTitle(NSLocalizedString("Cancel", comment: "Stop action"), for: .normal)
            self.statusBarDoneButton.alpha = 1
            self.statusBarDoneButton.setTitle(NSLocalizedString("Done", comment: "Complete action"), for: .normal)
        }
    }
    
    func endSettingText(cancelled: Bool) {
        self.isSettingText = false
        self.showDropDown(animated: true)
        self.paletteTextButtonContainer.alpha = 1
        self.localVideoViewContainer.alpha = 1
        
        if let jot = self.jotVC, self.localDrawImageView == nil {
            self.localDrawImageView = UIImageView(frame: self.remoteVideoViewContainer.bounds)
            self.localDrawImageView?.image = UIImage()
            self.localDrawImageView?.boundInside(container: self.remoteVideoViewContainer)
            self.remoteVideoViewContainer.bringSubview(toFront: jot.view)
        }
        
        if let jot = self.jotVC {
            if cancelled {
                jot.clearText()
            }
            else {
                
                let stampImage = jot.renderImage()!
                
                self.drawOperationQueue.addDrawing(snapshot: stampImage, fromCurrentUser: DGStreamCore.instance.currentUser?.userID ?? 0, toUsers: [self.selectedUser], withFileID: UUID().uuidString.components(separatedBy: "-").first ?? "")
                
                self.localDrawImageView?.mergeImagesWith(newImage: stampImage)
            }
        }
        
        if let jot = self.jotVC {
            jot.state = .drawing
        }
        
        UIView.animate(withDuration: 0.18) {
            self.statusBarDoneButton.alpha = 0
            self.statusBarBackButton.setTitle(NSLocalizedString("Cancel", comment: "Stop action"), for: .normal)
        }
        
    }
    
    func dropDownManager(manager: DGStreamDropDownManager, sizeSelected size: String) {
        if let jot = self.jotVC, let float = UInt(size) {
            self.dropDown.hideMenu()
            self.drawSize = CGFloat(float)
            jot.drawingStrokeWidth = self.drawSize
        }
    }
    func dropDownManager(manager: DGStreamDropDownManager, colorSelected color: UIColor) {
        if let jot = self.jotVC {
            self.dropDown.hideMenu()
            self.drawColor = color
            jot.drawingColor = self.drawColor
        }
    }
    func dropDownManager(manager: DGStreamDropDownManager, stampSelected stamp: String) {
        
        if let jot = self.jotVC {
            
            if let image = jot.renderImage() {
                jot.draw(on: image)
            }
            
            jot.textColor = self.drawColor
            jot.fontSize = 250
            jot.textString = stamp
            jot.state = .text
            
            startSettingText()

        }
    }
}

extension DGStreamCallViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if self.isChatShown {
            return true
        }
        else if self.isDrawing == true || self.callMode == .board || self.blackoutView.alpha != 0 {
            return false
        }
        return true
    }
}

extension DGStreamCallViewController: DGStreamRecorderDelegate {
    func recorder(_ recorder: DGStreamRecorder, frameToBroadcast: QBRTCVideoFrame) {
        
        print("frameToBroadcast")
        if self.isBroadcasting == false {
            self.isBroadcasting = true
        }
        
        self.freezeRotation = frameToBroadcast.videoRotation
        
        // Places Local Video View if its not already there
        DispatchQueue.main.async {
            if self.localBroadcastView == nil {
                self.localBroadcastView = QBRTCRemoteVideoView(frame: self.localVideoViewContainer.frame)
                self.localBroadcastView?.setSize(self.localVideoViewContainer.frame.size)
                self.localBroadcastView?.boundInside(container:self.localVideoViewContainer)
                print("Placed Local BV")
            }
        }
        
        // Displays local camera feed to local video view
        if let vb = self.localBroadcastView {
            let vidfra = RTCVideoFrame(pixelBuffer: frameToBroadcast.pixelBuffer, rotation: frameToBroadcast.videoRotation, timeStampNs: 0)
            vb.renderFrame(vidfra)
            //print("Render Frame")
            if let lbv = self.localBroadcastView {
                DispatchQueue.main.async {
                    self.localVideoViewContainer.bringSubview(toFront: lbv)
                }
            }
        }
        
        // If there is a freeze frame send that, otherwise send the local camera feed
        if self.isFrozen, let image = self.freezeFrame {
            let renderWidth = Int(image.size.width)
            let renderHeight = Int(image.size.height)
            
            var buffer:CVPixelBuffer? = nil
            
            let pixelFormatType = kCVPixelFormatType_420YpCbCr8BiPlanarFullRange
            
            let status:CVReturn = CVPixelBufferCreate(kCFAllocatorDefault, renderWidth, renderHeight, pixelFormatType, nil, &buffer)
            
            if status == kCVReturnSuccess, let buff = buffer {
                
                CVPixelBufferLockBaseAddress(buff, CVPixelBufferLockFlags(rawValue: 0))
                
                let rImage:CIImage = CIImage(image: image, options: [:])!
                
                DGStreamScreenCapture(view: self.view).qb_sharedGPUContext().render(rImage, to: buff)
                
                CVPixelBufferUnlockBaseAddress(buff, CVPixelBufferLockFlags(rawValue: 0))
                
                //self.recordingManager.recorder?.writeSample(buffer: buff)
                
                let frame = QBRTCVideoFrame(pixelBuffer: buff, videoRotation: ._0)
                
                print("Send Freeze Frame")
                self.cameraCapture.send(frame)
                
            }
            else {
                print("Failed to create buffer. \(status)")
            }
        }
        else {
            if self.session != nil {
                self.cameraCapture.send(frameToBroadcast)
            }
        }

    }
}

