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

typealias CellUpdateBlock = (_ cell: DGStreamCollectionViewCell) -> Void

enum CallMode {
    case stream
    case merge
    case draw
    case share
    case board
}

enum MMPaletteMode: Int {
    case color = 0
    case size = 1
}

public class DGStreamCallViewController: UIViewController {
    
    static let kOpponentCollectionViewCellIdentifier = "OpponentCollectionViewCellIdentifier"
    static let kSharingViewControllerIdentifier = "SharingViewController"
    
    @IBOutlet weak var savedPhotoLabel: UILabel!
    var isShowingLabel = false
    
    @IBOutlet weak var statusBar: UIView!
    @IBOutlet weak var statusBarBackButton: UIButton!
    @IBOutlet weak var statusBarTitle: UILabel!
    
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
    
    @IBOutlet weak var buttonsContainer: UIView!
    @IBOutlet weak var buttonsContainerHeightConstraint: NSLayoutConstraint!
    
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
    
    @IBOutlet weak var snapshotButtonContainer: UIView!
    @IBOutlet weak var snapshotButton: UIButton!
    
    @IBOutlet weak var muteButtonContainer: UIView!
    @IBOutlet weak var muteButton: UIButton!
    
    @IBOutlet weak var chatButtonContainer: UIView!
    @IBOutlet weak var chatButton: UIButton!
    
    
    @IBOutlet weak var chatPeekViewContainer: UIView!
    var chatPeekView: DGStreamChatPeekView!
    
    @IBOutlet weak var paletteBackgroundView: UIView!
    
    @IBOutlet weak var paletteButtonContainer: UIView!
    
    @IBOutlet weak var paletteTextButtonContainer: UIView!
    
    @IBOutlet weak var paletteDismissButton: UIButton!
    
    var paletteMode: MMPaletteMode = .color
    
    var isShowingPalette = false
    
    @IBOutlet weak var paletteButton: UIButton!
    
    @IBOutlet weak var paletteTextButton: UIButton!
    
    @IBOutlet weak var paletteContainer: UIView!
    
    @IBOutlet weak var paletteColorButton: UIButton!
    
    @IBOutlet weak var paletteSizeButton: UIButton!
    
    @IBOutlet weak var paletteColorContainer: UIView!
    
    @IBOutlet weak var paletteSizeContainer: UIView!
    
    var paletteSectionButtons: [UIButton] = []
    var paletteColorContainers: [UIView] = []
    
    @IBOutlet weak var paletteColor1Container: UIView!
    @IBOutlet weak var paletteColor2Container: UIView!
    @IBOutlet weak var paletteColor3Container: UIView!
    @IBOutlet weak var paletteColor4Container: UIView!
    
    var paletteColorIndicators:[UIView] = []
    @IBOutlet weak var paletteColor1Indicator: UIView!
    @IBOutlet weak var paletteColor2Indicator: UIView!
    @IBOutlet weak var paletteColor3Indicator: UIView!
    @IBOutlet weak var paletteColor4Indicator: UIView!
    
    
    var paletteSizeButtons:[UIButton] = []
    
    @IBOutlet weak var paletteSizeButton42: UIButton!
    @IBOutlet weak var paletteSizeButton38: UIButton!
    @IBOutlet weak var paletteSizeButton34: UIButton!
    @IBOutlet weak var paletteSizeButton30: UIButton!
    @IBOutlet weak var paletteSizeButton26: UIButton!
    @IBOutlet weak var paletteSizeButton22: UIButton!
    @IBOutlet weak var paletteSizeButton18: UIButton!
    @IBOutlet weak var paletteSizeButton14: UIButton!
    @IBOutlet weak var paletteSizeButton10: UIButton!
    @IBOutlet weak var paletteSizeButton6: UIButton!
    
    var isErasing = false

    @IBOutlet weak var paletteEraserButtonContainer: UIView!
    @IBOutlet weak var paletteEraserButtonLabel: UILabel!
    @IBOutlet weak var paletteEraserButton: UIButton!
    
    var isAudioCall = false
    
    @IBOutlet weak var audioCallContainer: UIView!
    @IBOutlet weak var audioCallLabel: UILabel!
    @IBOutlet weak var audioIndicatorContainer: UIView!
    
    var isChatShown = false
    var didHangUp = false
    
    var localVideoView:DGStreamVideoView?
    
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
    
    var screenCapture: DGStreamScreenCapture?
    var videoTextureCache: CVOpenGLESTextureCache?
    var background: GLKTextureInfo!
    var greenScreenVC:GSViewController!
    
    var session:QBRTCSession!
    
    var callMode: CallMode = .stream
    var alertView: DGStreamAlertView?
    var jotVC: JotViewController?
    var drawView: UIView?
    
    var chatVC: DGStreamChatViewController!
    
    var whiteBoardSessions:[DGStreamWhiteBoardSession] = []
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        self.savedPhotoLabel.clipsToBounds = true
        self.savedPhotoLabel.textColor = UIColor.dgDarkGray()
        self.savedPhotoLabel.backgroundColor = UIColor.white
        self.savedPhotoLabel.layer.cornerRadius = 6
        
        self.paletteSectionButtons = [self.paletteColorButton, self.paletteSizeButton]
        
        self.paletteColorContainers = [self.paletteColor1Container, self.paletteColor2Container, self.paletteColor3Container, self.paletteColor4Container]
        
        self.paletteSizeButtons.append(self.paletteSizeButton42)
        self.paletteSizeButtons.append(self.paletteSizeButton38)
        self.paletteSizeButtons.append(self.paletteSizeButton34)
        self.paletteSizeButtons.append(self.paletteSizeButton30)
        self.paletteSizeButtons.append(self.paletteSizeButton26)
        self.paletteSizeButtons.append(self.paletteSizeButton22)
        self.paletteSizeButtons.append(self.paletteSizeButton18)
        self.paletteSizeButtons.append(self.paletteSizeButton14)
        self.paletteSizeButtons.append(self.paletteSizeButton10)
        self.paletteSizeButtons.append(self.paletteSizeButton6)
        
        self.paletteColorIndicators = [self.paletteColor1Indicator, self.paletteColor2Indicator, self.paletteColor3Indicator, self.paletteColor4Indicator]
        
        self.setPalette()
        
        self.view.backgroundColor = UIColor.dgWhite()
        
        UIApplication.shared.isStatusBarHidden = true
        self.statusBar.backgroundColor = UIColor.dgGreen()
        self.statusBarTitle.textColor = UIColor.dgBlack()
        
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
        
        initCall()
        self.setUpButtons()
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.remoteVideoViewContainer = UIView(frame: UIScreen.main.bounds)
        self.remoteVideoViewContainer.backgroundColor = .black
        self.remoteVideoViewContainer.clipsToBounds = true
        let returnedConstraints = self.remoteVideoViewContainer.boundInCenterOf(container: self.view)
//        self.remoteVideoViewContainerTopConstraint = returnedConstraints.top
//        self.remoteVideoViewContainerLeftConstraint = returnedConstraints.left
//        self.remoteVideoViewContainerRightConstraint = returnedConstraints.right
//        self.remoteVideoViewContainerBottomConstraint = returnedConstraints.bottom
        self.view.sendSubview(toBack: self.remoteVideoViewContainer)
        
        self.chatPeekView = DGStreamChatPeekView()
        self.chatPeekView.configureWithin(container: self.chatPeekViewContainer)
        
        NotificationCenter.default.addObserver(self, selector: #selector(deviceOrientationDidChange), name: Notification.Name.UIDeviceOrientationDidChange, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.session.acceptCall(nil)
        }
    }
    
    func keyboardWillShow(notification: Notification) {
        
    }
    
    func keyboardWillHide(notification: Notification) {
        
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.isStatusBarHidden = false
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.chatVC.delegate = self
        self.chatVC.view.boundInside(container: self.buttonsContainer)
        self.chatVC.view.alpha = 0
        self.chatVC.didMove(toParentViewController: self)
        
        if !self.isInitiator {
            
            if let _ = self.videoViewWith(userID: self.selectedUser) {
                self.videoViews.removeValue(forKey: self.selectedUser.uintValue)
            }
            
            let qbVideoView = QBRTCRemoteVideoView(frame: self.remoteVideoViewContainer.bounds)
            qbVideoView.setVideoTrack(self.session.remoteVideoTrack(withUserID: self.selectedUser))
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.20) {
            self.animateButtons()
        }
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func initCall() {
        let settings = DGStreamSettings.instance
        
        if self.session.conferenceType == .video, let videoSettings = settings.videoFormat {
            self.cameraCapture = QBRTCCameraCapture(videoFormat: videoSettings, position: .front)
            self.cameraCapture.startSession({
                self.session.localMediaStream.videoTrack.videoCapture = self.cameraCapture
            })
        }
        
        if isAudioCall {
            self.drawButtonContainer.isHidden = true
            self.mergeButtonContainer.isHidden = true
            self.freezeButtonContainer.isHidden = true
            self.snapshotButtonContainer.isHidden = true
            self.session.localMediaStream.audioTrack.isEnabled = true
            self.session.localMediaStream.videoTrack.isEnabled = false
            self.audioCallContainer.isHidden = false
            
            self.audioCallLabel.textColor = UIColor.dgWhite()
            
            if let user = DGStreamCore.instance.getOtherUserWith(userID: self.selectedUser), let username = user.username {
                self.audioCallLabel.text = "Audio Call\nwith\n\(username)"
            }
            else {
                self.audioCallLabel.text = "In\nAudio Call"
            }
            
            if let audioIndicator = UINib(nibName: "DGStreamAudioIndicator", bundle: Bundle(identifier: "com.dataglance.DGStream")).instantiate(withOwner: self, options: nil).first as? DGStreamAudioIndicator {
                audioIndicator.animateWithin(container: self.audioIndicatorContainer)
            }
            
        }
        else {
            self.session.localMediaStream.audioTrack.isEnabled = true
            self.session.localMediaStream.videoTrack.isEnabled = true
        }
        
        if localVideoView == nil && self.isAudioCall == false {
            
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
            
            self.users.remove(at: idx)
        }
        
        if let first = self.users.first, let firstUserID = first.userID {
            self.selectedUser = firstUserID
        }
        
        self.collectionView.setCollectionViewLayout(DGStreamFullLayout(), animated: false)
        self.collectionView.reloadData()

        if let currentUser = DGStreamCore.instance.currentUser, let currentUserID = currentUser.userID {
            self.isInitiator = currentUserID.uintValue == self.session.initiatorID.uintValue
        }
        
        if self.isInitiator {
            startCall()
        }
        else {
            acceptCall()
        }
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
    }
    
    func setUpButtons() {
        
        self.buttonsContainer.layer.cornerRadius = 6
        self.buttonsContainer.backgroundColor = .clear
        
        let mergeImage = UIImage(named: "merge", in: Bundle(identifier: "com.dataglance.DGStream"), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        
        let drawImage = UIImage(named: "EditPencil", in: Bundle(identifier: "com.dataglance.DGStream"), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        
        let hangUpImage = UIImage(named: "hangup", in: Bundle.init(identifier: "com.dataglance.DGStream"), compatibleWith: nil)
        
        let whiteBoardImage = UIImage(named: "scratchpad", in: Bundle.init(identifier: "com.dataglance.DGStream"), compatibleWith: nil)
        
        let screenShare = UIImage(named: "screenshare", in: Bundle.init(identifier: "com.dataglance.DGStream"), compatibleWith: nil)
        
        self.statusBarBackButton.setTitleColor(UIColor.dgBlack(), for: .normal)
        
        // Hang up
        self.hangUpButton.setImage(hangUpImage?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.hangUpButton.tintColor = UIColor.dgBackground()
        self.hangUpButton.backgroundColor = .red
        self.hangUpButton.alpha = 0
        self.hangUpButton.contentHorizontalAlignment = .fill
        self.hangUpButton.contentVerticalAlignment = .fill
        self.hangUpButton.contentMode = .scaleAspectFill
        self.hangUpButton.imageEdgeInsets =  UIEdgeInsetsMake(8, 8, 8, 8)
        
        // Merge
        self.mergeButton.setImage(mergeImage?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.mergeButton.tintColor = UIColor.dgBlueDark()
        self.mergeButton.alpha = 0
        self.mergeButton.contentVerticalAlignment = .fill
        self.mergeButton.contentHorizontalAlignment = .fill
        self.mergeButton.contentMode = .scaleAspectFill
        self.mergeButton.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8)
        
        // Draw
        self.drawButton.setImage(drawImage?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.drawButton.tintColor = UIColor.dgBlueDark()
        self.drawButton.alpha = 0
        self.drawButton.contentHorizontalAlignment = .fill
        self.drawButton.contentVerticalAlignment = .fill
        self.drawButton.contentMode = .scaleAspectFill
        self.drawButton.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8)
        
        // Screen share
        self.shareScreenButton.setImage(screenShare?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.shareScreenButton.tintColor = UIColor.dgBlueDark()
        self.shareScreenButton.alpha = 0
        self.shareScreenButton.contentHorizontalAlignment = .fill
        self.shareScreenButton.contentVerticalAlignment = .fill
        self.shareScreenButton.contentMode = .scaleAspectFill
        self.shareScreenButton.imageEdgeInsets = UIEdgeInsetsMake(4, 4, 4, 4)
        
        // White Board
        self.whiteBoardButton.setImage(whiteBoardImage?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.whiteBoardButton.tintColor = UIColor.dgBlueDark()
        self.whiteBoardButton.alpha = 0
        self.whiteBoardButton.contentHorizontalAlignment = .fill
        self.whiteBoardButton.contentVerticalAlignment = .fill
        self.whiteBoardButton.contentMode = .scaleAspectFill
        self.whiteBoardButton.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5)
        
        // Freeze
        self.freezeButtonContainer.layer.cornerRadius = self.freezeButtonContainer.frame.size.width / 2
        self.freezeButton.setImage(UIImage.init(named: "freeze", in: Bundle.init(identifier: "com.dataglance.DGStream"), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.freezeButton.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8)
        self.freezeButton.tintColor = UIColor.dgBlueDark()
        self.freezeButton.contentHorizontalAlignment = .fill
        self.freezeButton.contentVerticalAlignment = .fill
        self.freezeButton.contentMode = .scaleAspectFill
        
        // Snapshot
        self.snapshotButtonContainer.layer.cornerRadius = self.freezeButtonContainer.frame.size.width / 2
        self.snapshotButton.setImage(UIImage.init(named: "capture", in: Bundle.init(identifier: "com.dataglance.DGStream"), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.snapshotButton.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8)
        self.snapshotButton.tintColor = UIColor.dgBlueDark()
        self.snapshotButton.contentHorizontalAlignment = .fill
        self.snapshotButton.contentVerticalAlignment = .fill
        self.snapshotButton.contentMode = .scaleAspectFill
        
        // Chat
        self.chatButtonContainer.layer.cornerRadius = 6
        self.chatButton.setImage(UIImage.init(named: "message", in: Bundle.init(identifier: "com.dataglance.DGStream"), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.chatButton.tintColor = UIColor.dgBlueDark()
        self.chatButton.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8)
        
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
    
//        self.hangUpButtonWidthConstraint.constant = hangUpButtonWH
//        self.hangUpButtonHeightConstraint.constant = hangUpButtonWH
        //self.hangUpButton.imageEdgeInsets = insets
        self.hangUpButton.layoutIfNeeded()
        self.hangUpButtonContainer.layer.cornerRadius = hangUpButtonContainer.frame.size.width / 2
        
//        self.mergeButtonRightConstraint.constant = padding
//        self.mergeButtonWidthConstraint.constant = otherButtonsWH
//        self.mergeButtonHeightConstraint.constant = otherButtonsWH
        //self.mergeButton.imageEdgeInsets = insets
        self.mergeButton.layoutIfNeeded()
        self.mergeButtonContainer.layer.cornerRadius = self.mergeButtonContainer.frame.size.width / 2
        
//        self.drawButtonLeftConstraint.constant = padding
//        self.drawButtonWidthConstraint.constant = otherButtonsWH
//        self.drawButtonHeightConstraint.constant = otherButtonsWH
        //self.drawButton.imageEdgeInsets = insets
        self.drawButton.layoutIfNeeded()
        self.drawButtonContainer.layer.cornerRadius = self.drawButtonContainer.frame.size.width / 2
        
//        self.shareScreenButtonRightConstraint.constant = padding
//        self.shareScreenWidthConstraint.constant = otherButtonsWH
//        self.shareScreenHeightConstraint.constant = otherButtonsWH
        //self.shareScreenButton.imageEdgeInsets = insets
        self.shareScreenButton.layoutIfNeeded()
        self.shareScreenButtonContainer.layer.cornerRadius = self.shareScreenButtonContainer.frame.size.width / 2
        
//        self.whiteBoardButtonLeftConstraint.constant = padding
//        self.whiteBoardButtonWidthConstraint.constant = otherButtonsWH
//        self.whiteBoardButtonHeightConstraint.constant = otherButtonsWH
        //self.whiteBoardButton.imageEdgeInsets = insets
        self.whiteBoardButton.layoutIfNeeded()
        self.whiteBoardButtonContainer.layer.cornerRadius = self.whiteBoardButtonContainer.frame.size.width / 2
        
        self.muteButtonContainer.layoutIfNeeded()
        self.muteButtonContainer.layer.cornerRadius = self.muteButtonContainer.frame.size.width / 2
        
        self.chatButtonContainer.layoutIfNeeded()
        self.chatButtonContainer.layer.cornerRadius = self.chatButtonContainer.frame.size.width / 2
        
        self.view.layoutIfNeeded()
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
        
        if let currentUser = DGStreamCore.instance.currentUser, let currentUserID = currentUser.userID, currentUserID.int16Value == userID.int16Value {
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
        self.session.localMediaStream.videoTrack.videoCapture = self.screenCapture
    }
    
    func endScreenCapture() {
        self.screenCapture = nil
        self.session.localMediaStream.videoTrack.videoCapture = self.cameraCapture
    }
    
    //MARK:- Button Actions
    @IBAction func muteButtonTapped(_ sender: Any) {
        
    }

    @IBAction func flipButtonTapped(_ sender: Any) {
        
    }
    
    @IBAction func drawButtonTapped(_ sender: Any) {
        if self.callMode == .draw || self.isDrawing {
            endDrawMode()
        }
        else {
            startDrawMode()
        }
    }
    
    func startDrawMode() {
        
        self.statusBarBackButton.setTitle("Cancel", for: .normal)
        
        UIView.animate(withDuration: 0.18) {
            self.drawButtonContainer.backgroundColor = UIColor.dgMergeMode()
            self.statusBar.backgroundColor = UIColor.dgMergeMode()
            self.statusBarBackButton.alpha = 1
            
            self.paletteButtonContainer.alpha = 1
            self.paletteTextButtonContainer.alpha = 1
        }

        if self.callMode == .merge {
            self.isDrawing = true
        }
        else {
            self.callMode = .draw
        }
        
        self.jotVC = JotViewController()
        self.jotVC?.delegate = self
        self.jotVC?.view.boundInside(container: self.remoteVideoViewContainer)
        self.jotVC?.view.contentMode = .scaleAspectFill
        self.jotVC?.didMove(toParentViewController: self)
        self.jotVC?.state = .drawing
        self.jotVC?.drawingColor = UIColor.red
        self.jotVC?.textColor = UIColor.red
        self.jotVC?.initialTextInsets = UIEdgeInsets(top: UIScreen.main.bounds.size.height / 2, left: 0, bottom: 0, right: 0)
        self.jotVC?.textEditingInsets = UIEdgeInsets(top: UIScreen.main.bounds.size.height / 2, left: 0, bottom: 0, right: 0)
        
        captureScreen(screenView: self.remoteVideoViewContainer)
    }
    
    func endDrawMode() {
        
        hidePalette()
        
        UIView.animate(withDuration: 0.18) {
            self.drawButtonContainer.backgroundColor = .clear
            self.statusBar.backgroundColor = UIColor.dgStreamMode()
            self.statusBarBackButton.alpha = 0
            
            self.paletteButtonContainer.alpha = 0
            self.paletteTextButtonContainer.alpha = 0
    
        }
        
        if self.callMode == .merge {
            self.isDrawing = false
        }
        else {
            self.callMode = .stream
        }
        
        if let jot = self.jotVC {
            jot.view.removeFromSuperview()
            self.jotVC = nil
        }
        
        self.endScreenCapture()
    }
    
    @IBAction func whiteBoardButtonTapped(_ sender: Any) {
        // Hide video
        if callMode == .board {
            endWhiteBoard()
        }
        else {
            startWhiteBoard()
        }
    }
    
    @IBAction func mergeButtonTapped(_ sender: Any) {
        
        if callMode == .merge {
            if let currentUser = DGStreamCore.instance.currentUser, let currentUserID = currentUser.userID {
                DGStreamNotification.unmerge(from: currentUserID, with: { (success, errorMessage) in
                    
                })
            }
            returnToStreamMode()
        }
        else {
            // Send push notification that asks the helper to merge with their reality
            if let currentUser = DGStreamCore.instance.currentUser, let currentUserID = currentUser.userID, let mergeRequestView = UINib(nibName: "DGStreamAlertView", bundle: Bundle(identifier: "com.dataglance.DGStream")).instantiate(withOwner: self, options: nil).first as? DGStreamAlertView {
                mergeRequestView.configureFor(mode: .mergeRequest, fromUsername: nil, message: "Waiting For Response...",isWaiting: true)
                self.alertView = mergeRequestView
                DGStreamManager.instance.waitingForResponse = .merge
                mergeRequestView.presentWithin(viewController: self, fromUsername: "Merge", block: { (accepted) in })
                DGStreamNotification.merge(from: currentUserID, with: { (success, errorMessage) in
                    if !success {
                        
                        mergeRequestView.dismiss()
                        
                        if let alert = UINib(nibName: "DGStreamAlertView", bundle: Bundle(identifier: "com.dataglance.DGStream")).instantiate(withOwner: self, options: nil).first as? DGStreamAlertView {
                            alert.configureFor(mode: .error, fromUsername: nil, message: errorMessage ?? "Error", isWaiting: false)
                            alert.presentWithin(viewController: self, fromUsername: "", block: { (accepted) in
                                alert.dismiss()
                            })
                        }
                    }
                    else {
                        print("Successfully Pushed Merge Notification")
                    }
                })
            }
        }
        
    }
    
    @IBAction func hangUpButtonTapped(_ sender: Any) {
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
        self.session.hangUp(["hangup" : "hang up"])
        self.navigationController?.popViewController(animated: true)
    }
    
    func freezeWith(imageData: Data) {
        if let image = UIImage(data: imageData) {
            isFrozen = true
            self.freezeButtonContainer.backgroundColor = UIColor.dgYellow()
            self.freezeImageView = UIImageView.init(frame: self.remoteVideoViewContainer.bounds)
            self.freezeImageView?.image = image
            self.freezeImageView?.boundInside(container: self.remoteVideoViewContainer)
            print("frozen")
            if let jot = self.jotVC, let freezeView = self.freezeImageView {
                self.remoteVideoViewContainer.insertSubview(freezeView, belowSubview: jot.view)
            }
        }
    }
    
    @IBAction func freezeButtonTapped(_ sender: Any) {
        if isFrozen {
            
            self.unfreeze()
            
//            DGStreamNotification.unfreeze(for: [self.selectedUser], with: { (success, errorMessage) in
//                if success {
//                    print("Sent Push!")
//                }
//                else if let message = errorMessage {
//                    print("Failed To Unfreeze with \(message)")
//                }
//            })
            
        }
        else if let screenshot = DGStreamScreenCapture.takeScreenshotOf(view: self.remoteVideoViewContainer) {
            
            // Set frozen for local
            isFrozen = true
            self.freezeButtonContainer.backgroundColor = UIColor.dgYellow()
            self.freezeImageView = UIImageView.init(frame: self.remoteVideoViewContainer.bounds)
            self.freezeImageView?.image = screenshot
            self.freezeImageView?.boundInside(container: self.remoteVideoViewContainer)
            
            if let jot = self.jotVC, let freezeView = self.freezeImageView {
                self.remoteVideoViewContainer.insertSubview(freezeView, belowSubview: jot.view)
            }
            
            captureScreen(screenView: self.remoteVideoViewContainer)
            
            // Create file
//            if let currentUser = DGStreamCore.instance.currentUser, let currentUserID = currentUser.userID {
//
////                let fileID = UUID().uuidString.components(separatedBy: "-").first!
////
////                let frozenImage = QBCOCustomObject()
////                frozenImage.className = "FrozenImage"
////                frozenImage.createdAt = Date()
////                frozenImage.userID = currentUserID.uintValue
////                frozenImage.id = fileID
////
////                let imageFile = QBCOFile()
////                if let imageData = UIImageJPEGRepresentation(screenshot, 1.0) {
////
////                    imageFile.contentType = "image/jpeg"
////                    imageFile.data = imageData
////                    imageFile.name = "image"
////
////                    let fields:NSMutableDictionary = NSMutableDictionary()
////                    fields.setObject(imageFile, forKey: "image" as NSCopying)
////
////                    frozenImage.fields = fields
////                }
//
////                QBRequest.createObject(frozenImage, successBlock: { (response, object) in
////
////                    QBRequest.uploadFile(imageFile, className: "FrozenImage", objectID: object?.id ?? "", fileFieldName: "image", successBlock: { (response, uploadInfo) in
////                        if response.isSuccess {
////                            print("DID UPLOAD IMAGE")
////                        }
////                    }, statusBlock: { (response, status) in
////
////                    }, errorBlock: { (error) in
////                        print("DID FAIL TO UPLOAD IMAGE \(error.error?.error?.localizedDescription ?? "ERROR")")
////                    })
////
////                    if response.isSuccess, let object = object, let objectID = object.id {
////                        print("Uploaded File")
////                        DGStreamNotification.freeze(with: objectID, for: [self.selectedUser], with: { (success, errorMessage) in
////                            if success {
////                                print("Sent Push!")
////                            }
////                            else if let message = errorMessage {
////                                print(message)
////                            }
////                        })
////                    }
////                    else if let responseError = response.error, let error = responseError.error {
////                        print("Upload Failed with error \(error.localizedDescription)")
////                    }
////                }, errorBlock: { (response) in
////                    if let responseError = response.error, let error = responseError.error {
////                        print("Upload Failed with error \(error.localizedDescription)")
////                    }
////                })
//
//            }
            
        }
        else {
            // couldnt take snapshot
        }
    }
    
    func unfreeze() {
        isFrozen = false
        self.freezeButtonContainer.backgroundColor = .clear
        self.freezeImageView?.removeFromSuperview()
        self.freezeImageView = nil
        self.endScreenCapture()
        if self.callMode == .draw || (self.callMode == .merge && self.isDrawing) {
            self.captureScreen(screenView: self.remoteVideoViewContainer)
        }
    }
    
    @IBAction func snapshotButtonTapped(_ sender: Any) {
        if let snapshot = DGStreamScreenCapture.takeScreenshotOf(view: self.remoteVideoViewContainer) {
            let photoSaver = DGStreamPhotoSaver()
            photoSaver.delegate = self
            photoSaver.save(snapshot)
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
        showChatVC()
    }
    
    func showChatVC() {
        // Fade out buttons
        UIView.animate(withDuration: 0.14, animations: {
            self.hangUpButtonContainer.alpha = 0
            self.mergeButtonContainer.alpha = 0
            self.drawButtonContainer.alpha = 0
            self.whiteBoardButtonContainer.alpha = 0
            self.shareScreenButtonContainer.alpha = 0
        }) { (fi) in
            
            self.buttonsContainerHeightConstraint.constant = UIScreen.main.bounds.size.height - 40
            UIView.animate(withDuration: 0.46, animations: {
                self.view.layoutIfNeeded()
                self.chatVC.view.alpha = 1
            }) { (fi) in
                
            }
        }
    }
    
    func hideChatVC() {
        // Dismiss ChatVC
        self.buttonsContainerHeightConstraint.constant = 100
        UIView.animate(withDuration: 0.46, animations: {
            self.view.layoutIfNeeded()
            self.chatVC.view.alpha = 0
        }) { (fi) in
            // Fade in buttons
            UIView.animate(withDuration: 0.14, animations: {
                self.hangUpButtonContainer.alpha = 1
                self.mergeButtonContainer.alpha = 1
                self.drawButtonContainer.alpha = 1
                self.whiteBoardButtonContainer.alpha = 1
                self.shareScreenButtonContainer.alpha = 1
            }) { (fi) in
                
            }
        }
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        switch callMode {
        case .draw:
            endDrawMode()
            break
        case .merge:
            if let currentUser = DGStreamCore.instance.currentUser, let currentUserID = currentUser.userID {
                DGStreamNotification.unmerge(from: currentUserID, with: { (success, errorMessage) in
                    
                })
            }
            returnToStreamMode()
            break
        case .share:
            break
        case .board:
            endWhiteBoard()
            break
        case .stream:
            self.navigationController?.popViewController(animated: true)
            break
        }
    }
    
    @IBAction func paletteButtonTapped(_ sender: Any) {
        showPalette()
    }
    
    @IBAction func paletteTextButtonTapped(_ sender: Any) {
        if let jot = self.jotVC {
            if jot.state == .drawing {
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
    
    //MARK:- Switch Mode
    
    func updateFrameFor(mode: CallMode) {

        if mode == .stream {
            if let width = self.remoteVideoViewContainerWidthConstraint,
                let height = self.remoteVideoViewContainerHeightConstraint,
                let centerX = self.remoteVideoViewContainerCenterXConstraint,
                let centerY = self.remoteVideoViewContainerCenterYConstraint {
                NSLayoutConstraint.deactivate([width, height, centerX, centerY])
            }
            NSLayoutConstraint.activate([self.remoteVideoViewContainerTopConstraint, self.remoteVideoViewContainerLeftConstraint, self.remoteVideoViewContainerBottomConstraint, self.remoteVideoViewContainerRightConstraint])
        }
        else {
            NSLayoutConstraint.deactivate([self.remoteVideoViewContainerTopConstraint, self.remoteVideoViewContainerLeftConstraint, self.remoteVideoViewContainerBottomConstraint, self.remoteVideoViewContainerRightConstraint])
            
            if self.remoteVideoViewContainerCenterXConstraint == nil {
                let returnedConstraints = self.remoteVideoViewContainer.boundInCenterOf(container: self.view)
                self.remoteVideoViewContainerWidthConstraint = returnedConstraints.width
                self.remoteVideoViewContainerHeightConstraint = returnedConstraints.height
                self.remoteVideoViewContainerCenterXConstraint = returnedConstraints.centerX
                self.remoteVideoViewContainerCenterYConstraint = returnedConstraints.centerY
            }
            else {
                NSLayoutConstraint.activate([self.remoteVideoViewContainerTopConstraint, self.remoteVideoViewContainerLeftConstraint, self.remoteVideoViewContainerBottomConstraint, self.remoteVideoViewContainerRightConstraint])
            }
        }
        self.view.layoutIfNeeded()
        if let remoteVideo = self.videoViewWith(userID: self.selectedUser) as? QBRTCRemoteVideoView {
            remoteVideo.setSize(self.remoteVideoViewContainer.bounds.size)
            remoteVideo.layoutIfNeeded()
        }
        
    }
    
    func startMergeModeForHelper() {
        
        DGStreamCore.instance.audioPlayer.stopAllSounds()
        if QBRTCAudioSession.instance().isAudioEnabled == false {
            QBRTCAudioSession.instance().isAudioEnabled = true
        }
        
        print("Start Merge For Helper")
        
        self.isHelper = true
        
        self.statusBarBackButton.setTitle("Cancel", for: .normal)
        
        UIView.animate(withDuration: 0.18) {
            self.mergeButtonContainer.backgroundColor = UIColor.dgMergeMode()
            self.statusBar.backgroundColor = UIColor.dgMergeMode()
            self.statusBarBackButton.alpha = 1
        }
        
        // Set Merge Mode
        self.callMode = .merge
        
        // Remove LocalVideoVideo from container
        if self.localVideoView != nil {
            self.localVideoView?.removeFromSuperview()
            self.localVideoView = nil
        }
        
        // Hide Local Video Container
        self.localVideoViewContainer.isHidden = true
        
        // Place Local Video On Top of Remote
        self.localVideoView = DGStreamVideoView(layer: self.cameraCapture.previewLayer, frame: self.remoteVideoViewContainer.bounds)
        self.localVideoView?.boundInside(container: self.remoteVideoViewContainer)
        self.localVideoView?.alpha = 0.45
        self.localVideoView?.updateOrientationIfNeeded()
        self.localVideoView?.videoLayer.videoGravity = AVLayerVideoGravityResize
        
        if let remoteVideo = self.videoViewWith(userID: self.selectedUser) as? QBRTCRemoteVideoView {
            remoteVideo.alpha = 1
            remoteVideo.videoGravity = AVLayerVideoGravityResize
        }
        
        // Set Transmission To Send Back Camera Video
        self.cameraCapture.position = .back
        self.session.localMediaStream.videoTrack.videoCapture = nil
        self.session.localMediaStream.videoTrack.videoCapture = self.cameraCapture
        
        QBRTCAudioSession.instance().initialize { (config) in
            config.categoryOptions = [.defaultToSpeaker]
            if self.session.conferenceType == .video {
                config.mode = AVAudioSessionModeVideoChat
            }
        }
        self.session.localMediaStream.audioTrack.isEnabled = true
        self.session.localMediaStream.videoTrack.isEnabled = true
        
    }
    
    func startMergeModeForHelp() {
        
        DGStreamCore.instance.audioPlayer.stopAllSounds()
        if QBRTCAudioSession.instance().isAudioEnabled == false {
            QBRTCAudioSession.instance().isAudioEnabled = true
        }
        
        print("Start Merge For Help")
        
        self.isHelper = false
        
        self.statusBarBackButton.setTitle("Cancel", for: .normal)
        
        UIView.animate(withDuration: 0.18) {
            self.mergeButtonContainer.backgroundColor = UIColor.dgMergeMode()
            self.statusBar.backgroundColor = UIColor.dgMergeMode()
            self.statusBarBackButton.alpha = 1
        }
        
        if let alert = self.alertView {
            alert.dismiss()
        }
        
        self.callMode = .merge
        
        // Place Local Video Below Remote Video
        if self.localVideoView != nil {
            self.localVideoView?.removeFromSuperview()
            self.localVideoView = nil
        }
        
        self.localVideoView = DGStreamVideoView(layer: self.cameraCapture.previewLayer, frame: self.remoteVideoViewContainer.bounds)
        self.localVideoView?.boundInside(container: self.remoteVideoViewContainer)
        self.localVideoView?.alpha = 1.0
        self.localVideoView?.updateOrientationIfNeeded()
        self.localVideoView?.videoLayer.videoGravity = AVLayerVideoGravityResize
        
        self.remoteVideoViewContainer.sendSubview(toBack: self.localVideoView!)
        
        // Fade Remote Video On Top Of Local Video
        if let remoteVideo = self.videoViewWith(userID: self.selectedUser) as? QBRTCRemoteVideoView {
            remoteVideo.alpha = 0.45
            remoteVideo.videoGravity = AVLayerVideoGravityResize
        }
        
        // Hide Local Video Container
        self.localVideoViewContainer.isHidden = true
        
        // Set Transmission To Send Back Camera Video
        self.cameraCapture.position = .back
        self.session.localMediaStream.videoTrack.videoCapture = nil
        self.session.localMediaStream.videoTrack.videoCapture = self.cameraCapture
    }
    
    func playMergeSound() {
        QBRTCAudioSession.instance().isAudioEnabled = false
        DGStreamCore.instance.audioPlayer.ringForMerge()
    }
    
    func returnToStreamMode() {
        
        DGStreamCore.instance.audioPlayer.stopAllSounds()
        if QBRTCAudioSession.instance().isAudioEnabled == false {
            QBRTCAudioSession.instance().isAudioEnabled = true
        }
        
        UIView.animate(withDuration: 0.18) {
            self.mergeButtonContainer.backgroundColor = .clear
            self.drawButtonContainer.backgroundColor = .clear
            self.statusBar.backgroundColor = UIColor.dgStreamMode()
            self.statusBarBackButton.alpha = 0
        }
        
        if let alert = self.alertView {
            alert.dismiss()
        }
        
        self.callMode = .stream
        self.isDrawing = false
        
        if let jot = self.jotVC {
            jot.view.removeFromSuperview()
            self.jotVC = nil
        }

        // Switch current device to merge mode
        self.localVideoViewContainer.alpha = 1.0
        if self.localVideoView != nil {
            self.localVideoView?.removeFromSuperview()
            self.localVideoView = nil
        }
        
        self.localVideoView = DGStreamVideoView(layer: self.cameraCapture.previewLayer, frame: self.localVideoViewContainer.bounds)
        self.localVideoViewContainer.addSubview(self.localVideoView!)
        self.localVideoView?.alpha = 1
        self.localVideoView?.videoLayer.videoGravity = AVLayerVideoGravityResizeAspect
        
        if let remoteVideo = self.videoViewWith(userID: self.selectedUser) as? QBRTCRemoteVideoView {
            remoteVideo.alpha = 1
            remoteVideo.videoGravity = AVLayerVideoGravityResizeAspect
        }
        
        self.localVideoViewContainer.isHidden = false
        
        self.cameraCapture.position = .front
        self.session.localMediaStream.videoTrack.videoCapture = nil
        self.session.localMediaStream.videoTrack.videoCapture = self.cameraCapture
        self.session.localMediaStream.audioTrack.isEnabled = true
        self.session.localMediaStream.videoTrack.isEnabled = true
    }
    
    //MARK:- Palette
    
    
    
    @IBAction func dismissPaletteButtonTapped(_ sender: Any) {
        hidePalette()
    }
    
    
    
    
    func setPalette() {
        
        self.paletteTextButton.setImage(UIImage.init(named: "text", in: Bundle.init(identifier: "com.dataglance.DGStream"), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.paletteTextButton.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8)
        self.paletteTextButton.tintColor = UIColor.dgBlueDark()
        
        self.paletteButton.setImage(UIImage.init(named: "palette", in: Bundle.init(identifier: "com.dataglance.DGStream"), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.paletteButton.imageEdgeInsets = UIEdgeInsetsMake(4, 4, 4, 4)
        self.paletteButton.tintColor = UIColor.dgBlueDark()
        
        self.paletteContainer.alpha = 0
        self.paletteDismissButton.alpha = 0
        self.paletteBackgroundView.alpha = 0
        
        self.paletteTextButtonContainer.clipsToBounds = true
        self.paletteTextButtonContainer.layer.cornerRadius = self.paletteTextButtonContainer.frame.size.width / 2
        self.paletteTextButtonContainer.alpha = 0
        self.paletteButtonContainer.clipsToBounds = true
        self.paletteButtonContainer.layer.cornerRadius = self.paletteButtonContainer.frame.size.width / 2
        self.paletteButtonContainer.alpha = 0
        
        self.paletteDismissButton.layer.cornerRadius = self.paletteDismissButton.frame.size.width / 2
        self.paletteDismissButton.backgroundColor = .black
        self.paletteContainer.bringSubview(toFront: self.paletteDismissButton)
        
        self.paletteColorContainer.backgroundColor = .white
        self.paletteColorContainer.layer.cornerRadius = 6
        self.paletteColorContainer.layer.borderColor = UIColor.black.cgColor
        self.paletteColorContainer.layer.borderWidth = 0.25
        
        self.paletteSizeContainer.backgroundColor = .white
        self.paletteSizeContainer.layer.cornerRadius = 6
        self.paletteSizeContainer.layer.borderColor = UIColor.black.cgColor
        self.paletteSizeContainer.layer.borderWidth = 0.25
        self.paletteSizeContainer.alpha = 0
        
        self.paletteEraserButtonLabel.layer.cornerRadius = 6
        self.paletteEraserButtonLabel.clipsToBounds = true
        
        for button in paletteSectionButtons {
            if button.tag == 0 {
                button.backgroundColor = UIColor.dgBlueDark()
                button.layer.cornerRadius = 4
            }
            else {
                button.backgroundColor = .lightGray
                button.layer.cornerRadius = 4
            }
        }
        
        for container in self.paletteColorContainers {
            container.backgroundColor = .white
            container.layer.cornerRadius = container.frame.size.width / 2
            container.layer.borderColor = UIColor.black.cgColor
            container.layer.borderWidth = 2.5
            if container.tag == 1 {
                // Set Main Color as "selected"
                container.backgroundColor = UIColor.dgBlueDark()
            }
        }
        
        for indicator in self.paletteColorIndicators {
            indicator.layer.cornerRadius = indicator.frame.size.width / 2
            indicator.layer.borderColor = UIColor.black.cgColor
            indicator.layer.borderWidth = 1
            if indicator.tag == 1 {
                indicator.backgroundColor = .red
            }
            if indicator.tag == 2 {
                indicator.backgroundColor = .green
            }
            if indicator.tag == 3 {
                indicator.backgroundColor = .blue
            }
            if indicator.tag == 0 {
                indicator.backgroundColor = .white
            }
        }
        
        for button in self.paletteSizeButtons {
            if button.tag == 26 { // default size
                button.setTitleColor(UIColor.dgBlueDark(), for: .normal)
            }
        }
    }
    
    func togglePalette() {
        if isShowingPalette {
            hidePalette()
        }
        else {
            showPalette()
        }
    }
    
    func showPalette() {
        isShowingPalette = true
        UIView.animate(withDuration: 0.10) {
            self.view.layoutIfNeeded()
            self.paletteContainer.alpha = 1
            self.paletteDismissButton.alpha = 1
            self.paletteBackgroundView.alpha = 1
        }
    }
    
    func hidePalette() {
        isShowingPalette = false
        UIView.animate(withDuration: 0.10) {
            self.view.layoutIfNeeded()
            self.paletteContainer.alpha = 0
            self.paletteDismissButton.alpha = 0
            self.paletteBackgroundView.alpha = 0
        }
    }
    
    func toggleEraser(sender: UIButton) {
        if isErasing {
            turnEraserOff(sender: sender)
        }
        else {
            turnEraserOn(sender: sender)
        }
    }
    
    func turnEraserOn(sender: UIButton) {
        isErasing = true
        // Set Erasing
        if let jot = self.jotVC {
            jot.drawingColor = .clear
        }
        UIView.animate(withDuration: 0.25) {
            self.paletteEraserButtonLabel.backgroundColor = UIColor.dgBlueDark()
        }
    }
    
    func turnEraserOff(sender: UIButton) {
        isErasing = false
        if let jot = self.jotVC {
            jot.drawingColor = .red
        }
        UIView.animate(withDuration: 0.25) {
            self.paletteEraserButtonLabel.backgroundColor = .clear
        }
    }
    
    func togglePaletteSection() {
        for button in paletteSectionButtons {
            let selectedColor = UIColor.dgBlueDark()
            let selectedTextColor = UIColor.white
            
            let unselectedColor = UIColor.darkGray
            let unselectedTextColor = UIColor.white
            
            if paletteMode == .color {
                if button.tag == 0 {
                    button.backgroundColor = selectedColor
                    button.setTitleColor(selectedTextColor, for: .normal)
                }
                if button.tag == 1 {
                    button.backgroundColor = unselectedColor
                    button.setTitleColor(unselectedTextColor, for: .normal)
                }
                UIView.animate(withDuration: 0.25, animations: {
                    self.paletteSizeContainer.alpha = 0
                })
            }
            else {
                if button.tag == 0 {
                    button.backgroundColor = unselectedColor
                    button.setTitleColor(unselectedTextColor, for: .normal)
                }
                if button.tag == 1 {
                    button.backgroundColor = selectedColor
                    button.setTitleColor(selectedTextColor, for: .normal)
                }
                UIView.animate(withDuration: 0.25, animations: {
                    self.paletteSizeContainer.alpha = 1
                })
            }
        }
    }
    
    @IBAction func paletteSectionColorTapped(_ sender: UIButton) {
        paletteMode = .color
        togglePaletteSection()
    }
    
    @IBAction func paletteSectionSizeTapped(_ sender: UIButton) {
        paletteMode = .size
        togglePaletteSection()
    }
    
    @IBAction func colorButtonTapped(_ sender: UIButton) {
        turnEraserOff(sender: sender)
        for container in self.paletteColorContainers {
            let color: UIColor
            if container.tag == sender.tag {
                color = UIColor.dgBlueDark()
            }
            else {
                color = .white
            }
            UIView.animate(withDuration: 0.25) {
                container.backgroundColor = color
            }
        }
        
        var color:UIColor = .gray

        // Set color
        if sender.tag == 1 {
            color = .red
        }
        else if sender.tag == 2 {
            color = .green
        }
        else if sender.tag == 3 {
            color = .blue
        }
        else {
            color = .white
        }
        
        if let jot = self.jotVC {
            jot.drawingColor = color
            jot.textColor = color
        }
        
    }
    
    @IBAction func eraseButtonTapped(_ sender: Any) {
        for container in self.paletteColorContainers {
            container.backgroundColor = .white
        }
        toggleEraser(sender: sender as! UIButton)
    }
    
    @IBAction func sizeButtonTapped(_ sender: UIButton) {
        for button in self.paletteSizeButtons {
            button.setTitleColor(.black, for: .normal)
        }
        sender.setTitleColor(UIColor.dgBlueDark(), for: .normal)
        // Set Size
        if let jot = self.jotVC {
            jot.drawingStrokeWidth = CGFloat(sender.tag)
            jot.fontSize = CGFloat(sender.tag)
        }
    }
    
    //MARK:- Orientation
    
    func shouldAutorotateToInterfaceOrientation(interfaceOrientation: UIInterfaceOrientation) -> Bool {
        
        // Native video orientation is landscape with the button on the right.
        // The video processor rotates vide as needed, so don't autorotate also
        return interfaceOrientation == UIInterfaceOrientation.landscapeRight
    }
    
    func deviceOrientationDidChange() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.20) {
            if self.callMode == .merge {
                
                if self.localVideoView != nil {
                    self.localVideoView?.removeFromSuperview()
                    self.localVideoView = nil
                }
                
                self.localVideoView = DGStreamVideoView(layer: self.cameraCapture.previewLayer, frame: self.remoteVideoViewContainer.bounds)
                self.localVideoView?.boundInside(container: self.remoteVideoViewContainer)
                
                if self.isHelper {
                    self.localVideoView?.alpha = 0.45
                    
                    if let remoteView = self.videoViewWith(userID: self.selectedUser) as? QBRTCRemoteVideoView {
                        remoteView.alpha = 1.0
                    }

                }
                else {
                    self.localVideoView?.alpha = 1.0
                    
                    if let remoteView = self.videoViewWith(userID: self.selectedUser) as? QBRTCRemoteVideoView {
                        remoteView.alpha = 0.45
                    }
                    
                    self.remoteVideoViewContainer.sendSubview(toBack: self.localVideoView!)

                }
                
                self.localVideoView?.updateOrientationIfNeeded()
                self.localVideoView?.videoLayer.videoGravity = AVLayerVideoGravityResize
            }
            else {
                self.localVideoView?.videoLayer.videoGravity = AVLayerVideoGravityResizeAspect
            }
        }
        
    }
    
}

//MARK:- White Board Mode
extension DGStreamCallViewController {
    func user(userID: NSNumber, joinedWhiteBoardSession sessionID: String) {
        print("joinedWhiteBoardSession")
        if let session = self.whiteBoardSessions.filter({ (session) -> Bool in
            return session.sessionID == sessionID
        }).first {
            session.userIDs.append(userID)
            if let currentUser = DGStreamCore.instance.currentUser, let currentUserID = currentUser.userID, session.userIDs.contains(currentUserID) {
                
            }
        }
        else {
            let session = DGStreamWhiteBoardSession()
            session.sessionID = sessionID
            session.userIDs = [userID]
            self.whiteBoardSessions.append(session)
        }
//        if userID == self.selectedUser {
//            print("updateFrameFor")
//            updateFrameFor(mode: .board)
//        }
    }
    
    func user(userID: NSNumber, exitedWhiteBoardSession sessionID: String) {
        if let session = self.whiteBoardSessions.filter({ (session) -> Bool in
            return session.sessionID == sessionID
        }).first {
            
        }
    }
    
    func startWhiteBoard() {
        
        var otherUsersIDs:[NSNumber] = []
        var isJoiningSelectedUserWhiteBoard = false
        
        // Add new session or update existing session with current user
        if let currentUser = DGStreamCore.instance.currentUser, let currentUserID = currentUser.userID {
            if let session = self.whiteBoardSessions.filter({ (session) -> Bool in
                return session.userIDs.contains(self.selectedUser)
            }).first {
                isJoiningSelectedUserWhiteBoard = true
                otherUsersIDs = session.userIDs
                session.userIDs.append(currentUserID)
                DGStreamNotification.joinWhiteBoardSession(session.sessionID, forUser: currentUserID, sendToUsers: [self.selectedUser], with: { (success, errorMessage) in
                    
                })
            }
            else {
                let session = DGStreamWhiteBoardSession()
                session.sessionID = UUID().uuidString.components(separatedBy: "-")[0]
                session.userIDs = [currentUserID]
                self.whiteBoardSessions.append(session)
                DGStreamNotification.joinWhiteBoardSession(session.sessionID, forUser: currentUserID, sendToUsers: [self.selectedUser], with: { (success, errorMessage) in
                    
                })
            }
        }
        
        // Update frame of container to be white square
        self.remoteVideoViewContainer.alpha = 0
        //updateFrameFor(mode: .board)
        self.remoteVideoViewContainer.backgroundColor = .white
        
        // Stack all included userIDs' videoView on top of container
        for userID in otherUsersIDs {
            if let videoView = self.videoViewWith(userID: userID) as? QBRTCRemoteVideoView{
                videoView.boundInside(container: self.remoteVideoViewContainer)
                videoView.setSize(self.remoteVideoViewContainer.bounds.size)
                videoView.alpha = 0.5
            }
        }

        // Add current user's draw view on top off stack
        self.jotVC = JotViewController()
        self.jotVC?.delegate = self
        self.jotVC?.view.boundInside(container: self.remoteVideoViewContainer)
        self.jotVC?.view.contentMode = .scaleAspectFill
        self.jotVC?.view.backgroundColor = .clear
        self.jotVC?.drawingContainer.backgroundColor = .clear
        self.jotVC?.view.alpha = 0.5
        self.jotVC?.didMove(toParentViewController: self)
        self.jotVC?.state = .drawing
        self.jotVC?.drawingColor = UIColor.red
        self.jotVC?.textColor = UIColor.red
        self.jotVC?.initialTextInsets = UIEdgeInsets(top: UIScreen.main.bounds.size.height / 2, left: 0, bottom: 0, right: 0)
        self.jotVC?.textEditingInsets = UIEdgeInsets(top: UIScreen.main.bounds.size.height / 2, left: 0, bottom: 0, right: 0)
        
        // Hide selected user video
        if let selectedUserVideo = self.videoViewWith(userID: self.selectedUser), isJoiningSelectedUserWhiteBoard == false {
            selectedUserVideo.alpha = 0
        }
        
        self.remoteVideoViewContainer.alpha = 1
        
        captureScreen(screenView: self.remoteVideoViewContainer)
        
    }
    
    func endWhiteBoard() {
        
        var otherUsersIDs:[NSNumber] = []
        
        // Set new mode
        self.callMode = .stream
        
        // Add new session or update existing session with current user
        if let currentUser = DGStreamCore.instance.currentUser, let currentUserID = currentUser.userID {
            if let session = self.whiteBoardSessions.filter({ (session) -> Bool in
                return session.userIDs.contains(self.selectedUser)
            }).first {
                otherUsersIDs = session.userIDs
                if let index = session.userIDs.index(of: currentUserID) {
                    session.userIDs.remove(at: index)
                }
                DGStreamNotification.exitWhiteBoardSession(session.sessionID, forUser: currentUserID, sendToUsers: [self.selectedUser], with: { (success, errorMessage) in
                    
                })
            }
        }
        
        // Remove all included userIDs' videoView on top of container
        for userID in otherUsersIDs {
            if let videoView = self.videoViewWith(userID: userID) as? QBRTCRemoteVideoView{
                videoView.removeFromSuperview()
            }
        }
        
        // Update frame of container to be full screen
        self.remoteVideoViewContainer.alpha = 0
        //updateFrameFor(mode: .stream)
        self.remoteVideoViewContainer.backgroundColor = .black
        
        // Add current user's draw view on top off stack
        if let jot = self.jotVC {
            jot.view.removeFromSuperview()
            self.jotVC = nil
        }
        
        self.remoteVideoViewContainer.alpha = 1
        
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

//MARK:- QBRTCClientDelegate
extension DGStreamCallViewController: QBRTCClientDelegate {
    public func session(_ session: QBRTCBaseSession, updatedStatsReport report: QBRTCStatsReport, forUserID userID: NSNumber) {
//        if session == self.session {
//            let result = report.statsString()
//            print(result)
//        }
    }
    
    public func session(_ session: QBRTCSession, userDidNotRespond userID: NSNumber) {
        //print("USER \(userID) DID NOT RESPOND")
        DGStreamCore.instance.audioPlayer.stopAllSounds()
        if session == self.session {
//            self.performUpdate(userID: userID) { (cell) in
//                cell.connectionState = self.session.connectionState(forUser: userID)
//            }
            let alert = UIAlertController(title: "No Response", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action: UIAlertAction) in
                alert.dismiss(animated: true, completion: nil)
                self.navigationController?.popViewController(animated: true)
            }))
            present(alert, animated: true, completion: nil)
        }
    }
    
    public func session(_ session: QBRTCSession, acceptedByUser userID: NSNumber, userInfo: [String : String]? = nil) {
        //print("ACCEPTED BY \(userID)")
//        if session == self.session {
//            self.performUpdate(userID: userID) { (cell) in
//                cell.connectionState = self.session.connectionState(forUser: userID)
//            }
//        }
    }
    
    public func session(_ session: QBRTCSession, rejectedByUser userID: NSNumber, userInfo: [String : String]? = nil) {
        print("REJECTED BY \(userID)")
        DGStreamCore.instance.audioPlayer.stopAllSounds()

        if session == self.session {
//            self.performUpdate(userID: userID) { (cell) in
//                cell.connectionState = self.session.connectionState(forUser: userID)
//            }
            let alert = UIAlertController(title: "Call Rejected", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action: UIAlertAction) in
                alert.dismiss(animated: true, completion: nil)
                self.navigationController?.popViewController(animated: true)
            }))
            present(alert, animated: true, completion: nil)
        }
    }
    
    public func session(_ session: QBRTCSession, hungUpByUser userID: NSNumber, userInfo: [String : String]? = nil) {
        //print("\(userID) HUNG UP")
//        if session == self.session {
//            self.performUpdate(userID: userID) { (cell) in
//                cell.connectionState = self.session.connectionState(forUser: userID)
//            }
//        }
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
        //print("STARTED CONNECTING TO \(userID)")
//        if session == self.session {
//            self.performUpdate(userID: userID) { (cell) in
//                cell.connectionState = self.session.connectionState(forUser: userID)
//            }
//        }
    }
    
    public func session(_ session: QBRTCBaseSession, connectedToUser userID: NSNumber) {
        print("CONNECTED TO \(userID)")
        if session == self.session {
            
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
            
//            self.performUpdate(userID: userID) { (cell) in
//                cell.connectionState = self.session.connectionState(forUser: userID)
//            }
        }
    }
    
    public func session(_ session: QBRTCBaseSession, disconnectedFromUser userID: NSNumber) {
        print("DISCONNECTED FROM \(userID)")
        if let index = self.chatVC.chatConversation.userIDs.index(of: userID) {
            self.chatVC.chatConversation.userIDs.remove(at: index)
        }
//        if session == self.session {
//            self.performUpdate(userID: userID) { (cell) in
//                cell.connectionState = self.session.connectionState(forUser: userID)
//            }
//        }
        self.hangUpButtonTapped(self)
    }
    
    public func session(_ session: QBRTCBaseSession, connectionClosedForUser userID: NSNumber) {
        //print("CONNECTIONG CLOSED FOR \(userID)")
//        if session == self.session {
//            self.performUpdate(userID: userID) { (cell) in
//                cell.connectionState = self.session.connectionState(forUser: userID)
//                self.videoViews.removeValue(forKey: userID.uintValue)
//                cell.set(videoView: nil)
//            }
//            let alert = UIAlertController(title: "Session Closed", message: nil, preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action: UIAlertAction) in
//                alert.dismiss(animated: true, completion: nil)
//            }))
//            present(alert, animated: true, completion: nil)
//        }
    }
    
    public func session(_ session: QBRTCBaseSession, connectionFailedForUser userID: NSNumber) {
        print("CONNECTION FAILED FOR \(userID)")
//        if session == self.session {
//            self.performUpdate(userID: userID) { (cell) in
//                cell.connectionState = self.session.connectionState(forUser: userID)
//            }
//        }

    }
    
    public func session(_ session: QBRTCBaseSession, didChange state: QBRTCSessionState) {
        printSession(state: state)
    }
    
    public func session(_ session: QBRTCBaseSession, didChange state: QBRTCConnectionState, forUser userID: NSNumber) {
        printConnection(state: state, for: userID)
//        if session == self.session {
//            self.performUpdate(userID: userID) { (cell) in
//                cell.connectionState = self.session.connectionState(forUser: userID)
//            }
//        }
    }
    
    public func didReceiveNewSession(_ session: QBRTCSession, userInfo: [String : String]? = nil) {
        print("DID RECEIVE NEW SESSION")
    }
    
    public func sessionDidClose(_ session: QBRTCSession) {
        print("SESSION CLOSED")
//        if !self.didHangUp {
//            if session == self.session {
//                let alert = UIAlertController(title: "Session Closed", message: nil, preferredStyle: .alert)
//                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action: UIAlertAction) in
//                    alert.dismiss(animated: true, completion: nil)
//                    self.navigationController?.popViewController(animated: true)
//                }))
//                present(alert, animated: true, completion: nil)
//            }
//        }
    }
    
    func printSession(state: QBRTCSessionState) {
//        if state == .closed {
//            print("|-CLOSED-|")
//        }
//        if state == .connected {
//            print("|-CONNECTED-|")
//        }
//        if state == .connecting {
//            print("|-CONNECTING-|")
//        }
//        if state == .new {
//            print("|-NEW-|")
//        }
//        if state == .pending {
//            print("|-PENDING-|")
//        }
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
        if isEditing {
            
        }
        else {
            
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
