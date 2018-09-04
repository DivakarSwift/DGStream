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
//import GPUImage2

typealias CellUpdateBlock = (_ cell: DGStreamCollectionViewCell) -> Void

enum CallMode {
    case stream
    case merge
    case perspective
    case board
}

enum DGStreamStampMode: Int {
    case off = 0
    case arrow = 1
    case box = 2
    case star = 3
    case smiley = 4
    
}

protocol RecordingSelectionDelegate {
    func recordingSelected(url: URL)
}

public class DGStreamCallViewController: UIViewController {
    
    static let kOpponentCollectionViewCellIdentifier = "OpponentCollectionViewCellIdentifier"
    static let kSharingViewControllerIdentifier = "SharingViewController"
    
    
    @IBOutlet weak var selectColorDisabledLabel: UILabel!
    
    @IBOutlet weak var selectSizeDisabledLabel: UILabel!
    
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
    
    @IBOutlet weak var remoteVideoViewContainer: UIView!
    
    @IBOutlet weak var optionsContainerContainer: UIView!
    
    @IBOutlet weak var optionsContainerConstraint: NSLayoutConstraint!
    @IBOutlet weak var optionsContainer: UIView!
    @IBOutlet weak var optionsContainerButton: UIButton!
    @IBOutlet weak var optionsButtonContainer: UIView!
    
    @IBOutlet weak var selectColorContainer: UIView!
    @IBOutlet weak var selectColorLabel: UILabel!
    @IBOutlet weak var selectColorCollectionView: UICollectionView!
    
    @IBOutlet weak var selectSizeContainer: UIView!
    @IBOutlet weak var selectSizeLabel: UILabel!
    @IBOutlet weak var selectSizeCollectionView: UICollectionView!
    
    @IBOutlet weak var optionsButtonsContainer: UIView!
    
    @IBOutlet weak var drawButton: UIButton!
    
    @IBOutlet weak var showHideButtonsButton: UIButton!
    
    var dropDown:DGStreamDropDownMenu!
    var dropDownManager: DGStreamDropDownManager!
    var dropDownSelectedSize:CGFloat = 14
    var dropDownSelectedColor:UIColor = .black
    var dropDownSelectedStamp: String?
    
    var sizeCollectionView: UICollectionView!
    var colorCollectionView: UICollectionView!
    var stampCollectionView: UICollectionView!
    
    @IBOutlet weak var localVideoViewContainer: UIView!
    
    @IBOutlet weak var mergeButtonContainer: UIView!
    @IBOutlet weak var mergeButton: UIButton! //10
    @IBOutlet weak var mergeButtonLabel: UILabel!
    
    @IBOutlet weak var perspectiveButtonContainer: UIView!
    @IBOutlet weak var perspectiveButton: UIButton!
    @IBOutlet weak var perspectiveButtonLabel: UILabel!
    
    @IBOutlet weak var hangUpButtonContainer: UIView!
    @IBOutlet weak var hangUpButton: UIButton!
    
    @IBOutlet weak var recordButton: UIButton!
    
    @IBOutlet weak var shareButtonContainer: UIView!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var shareButtonLabel: UILabel!
    
    @IBOutlet weak var whiteBoardButtonContainer: UIView!
    @IBOutlet weak var whiteBoardButton: UIButton!
    
    @IBOutlet weak var whiteBoardButtonLabel: UILabel!
    
    @IBOutlet weak var freezeButton: UIButton!
    var freezeImageView: UIImageView?
    var isFrozen: Bool = false
    var freezeFrame: UIImage?
    var freezeRotation: QBRTCVideoRotation?
    
    @IBOutlet weak var snapshotButton: UIButton!
    
    @IBOutlet weak var stampsButton: UIButton!
    
    @IBOutlet weak var undoButton: UIButton!
    @IBOutlet weak var undoButtonLabel: UILabel!
    
    @IBOutlet weak var clearAllButton: UIButton!
    @IBOutlet weak var clearAllButtonLabel: UILabel!
    
    @IBOutlet weak var mergeColorButton: UIButton!
    @IBOutlet weak var mergeColorButtonLabel: UILabel!
    
    @IBOutlet weak var mergeIntensityButton: UIButton!
    @IBOutlet weak var mergeIntensityButtonLabel: UILabel!
    
    @IBOutlet weak var chatButtonContainer: UIView!
    @IBOutlet weak var chatButton: UIButton!
    @IBOutlet weak var chatButtonLabel: UILabel!
    @IBOutlet weak var chatContainerHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var chatPeekViewContainer: UIView!
    var chatPeekView: DGStreamChatPeekView!

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
    
    var cameraCapture: QBRTCCameraCapture?
    var videoViews: [UInt: UIView] = [:]
    var zoomedView: UIView!
    
    var dynamicEnable: UIButton!
    var videoEnabled: UIButton!
    
    var statsView: UIView!
    var isInitiator = false
    var isDrawing = false
    var stampMode:DGStreamStampMode = .off
    var drawingUsers:[NSNumber] = []
    var localDrawIncrement:Int = 1
    
    var screenCapture: DGStreamScreenCapture?
    var localVideoCapture: DGStreamLocalVideoCapture?
    var videoTextureCache: CVOpenGLESTextureCache?
    var background: GLKTextureInfo!
    
    var session:QBRTCSession?
    
    var callMode: CallMode = .stream
    var alertView: DGStreamAlertView?
    var alertRequestWaitingView: DGStreamAlertView?
    var jotVC: JotViewController?
    var jotTapGesture: UITapGestureRecognizer?
    var localDrawImageView: UIImageView?
    var localDrawUndo1ImageView: UIImageView?
    var localDrawUndo2ImageView: UIImageView?
    var remoteDrawImageView: UIImageView?
    var remoteDrawUndo1ImageView: UIImageView?
    var remoteDrawUndo2ImageView: UIImageView?
    var isSettingText: Bool = false
    var drawSize:CGFloat = 14
    var drawColor:UIColor = .black
    var drawOperationQueue: DGStreamDrawOperationQueue = DGStreamDrawOperationQueue()
    var drawingTimer:Timer?
    var controlTimer:Timer?
    var chatVC: DGStreamChatViewController!
    
    var shouldLoadData: Bool = true
    
    @IBOutlet weak var chatContainer: UIView!
    
    var whiteBoardView:UIView?
    
    var videoOrientation: AVCaptureVideoOrientation = .portrait
    var bufferQueue: DispatchQueue?
    
    var recordingManager:DGStreamRecordingManager = DGStreamRecordingManager(orientation: .portrait)
    var isWaitingForOrientation: Bool = false
    var didRecord:Bool = false
    
    //var localBroadcastView:QBRTCRemoteVideoView?
    var recordQueue:DispatchQueue?
    
    var shouldChangeRecordingStatus:Bool = true
    var isRecording:Bool = false
    var recorder = RPScreenRecorder.shared()
    var audioRecorder: AVAudioRecorder?
    var assetWriter: AVAssetWriter?
    var assetWriterVideoInput: AVAssetWriterInput?
    var assetWriterAudioInput: AVAssetWriterInput?
    var assetReader: AVAssetReader?
    var assetReaderOutput: AVAssetReaderOutput?
    var isSharing: Bool = false
    var isBeingSharedWith: Bool = false
    var isBeingSharedWithVideo:Bool = false
    var isSharingVideo: Bool = false
    var isSharingDocument: Bool = false
    
    var didSelectToHideLocalVideo:Bool = false
    var isCurrentUserPerspective = false
    var isWaitingForCallAccept = true
    
    var isDisplayingAlert = false
    
    var recordingOperationQueue: DGStreamSendRecordingOperationQueue?
    var remoteReader: DGStreamRemoteReader?
    var isMergeHelper = false
    
    var recordingView: QBRTCRemoteVideoView?
    var localBroadcastView: DGStreamLocalVideoView?
    var greenScreenVC: GSViewController!
    var lastGreenScreenOrientation: AVCaptureVideoOrientation = .portrait
    
    var topViews:[UIView] = [] // The views that must be on top (sent to the front) after each draw
    
    var didTapDropDownContainer: Bool = false
    
    var dropDownVC: UIViewController?
    
    var mergeOptionColor: UIColor = .green
    var mergeOptionIntensity: Float = 0.5
    
    var shaderName:String = "greenScreen"
    
    var documentView: DGStreamDocumentView?
    
    var undoIDs:[Int] = []
    
    var drawSession:QBRTCSession?
    var drawCapture:DGStreamScreenCapture?
    var remoteDrawView: QBRTCRemoteVideoView?
    var drawView:UIImageView?
    var drawTimer:Timer?
    
    var whiteBlendView:UIView?
    var blackBlendView:UIView?
    
    var undoImage1:UIImage?
    var undoImage2:UIImage?
    
    var latestRemoteDrawID:Int = 0
    var latestRemotePageIncrement:Int = 0
    
    var popover: UIViewController?
    
    var remoteScreenSize:CGSize?
    
    let colors:[UIColor] = [.black, .white, .gray, .red, .blue, .green, .yellow, .brown, .purple]
    let mergeOptionColors:[UIColor] = [.green, .blue, .red, .white, .black]
    let sizes:[Int] = [8, 12, 16, 20, 24, 28, 32, 36, 40]
    
    var selectedIntensity: Float = 0.525
    
    var selectedColorIndex:Int = 0
    var selectedSizeIndex:Int = 0

    override public func viewDidLoad() {
        super.viewDidLoad()
        
        if shouldLoadData {
            self.localVideoViewContainer.backgroundColor = .clear
            //        let tap = UITapGestureRecognizer(target: self, action: #selector(toggleControls))
            //        tap.delegate = self
            //        self.view.addGestureRecognizer(tap)
            
            //        let localVideoTap = UITapGestureRecognizer(target: self, action: #selector(localVideoTapped))
            //        localVideoTap.delegate = self
            //        self.localVideoViewContainer.addGestureRecognizer(localVideoTap)
            
            self.blackoutView.backgroundColor = UIColor.dgBlueDark()
            
            self.savedPhotoLabel.clipsToBounds = true
            self.savedPhotoLabel.textColor = UIColor.dgDarkGray()
            self.savedPhotoLabel.backgroundColor = UIColor.white
            self.savedPhotoLabel.layer.cornerRadius = 6
            
            self.view.backgroundColor = UIColor.dgWhite()
            
            self.statusBar.backgroundColor = UIColor.dgBlueDark()
            self.statusBarTitle.textColor = .white
            
            if self.session == nil {
                print("NO SESSION!")
            }
            else {
                initCall()
                self.loadMergeOptions()
                self.setUpButtons()
                self.setUpOptions()
                self.setUpChat()
                self.setUpDrawView()
            }
            print("VIEW DID LOAD")
        }
        
    }
    
    
    
    func loadMergeOptions() {
        if let color = UserDefaults.standard.string(forKey: "MergeColor") {
            
            if color == "green" {
                self.mergeOptionColor = .green
            }
            else if color == "blue" {
                self.mergeOptionColor = .blue
            }
            else if color == "red" {
                self.mergeOptionColor = .red
            }
            else if color == "white" {
                self.mergeOptionColor = .white
            }
            else if color == "black" {
                self.mergeOptionColor = .black
            }
            
            self.mergeOptionIntensity = UserDefaults.standard.float(forKey: "MergeIntensity")
        }
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if shouldLoadData {
            
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
            self.chatButtonContainer.alpha = 0
            
            if self.isAudioCall {

            }
            
            // Drop Down
            self.setDropDownView()
            
            self.remoteVideoViewContainer.backgroundColor = .black
            self.remoteVideoViewContainer.clipsToBounds = true
            self.view.sendSubview(toBack: self.remoteVideoViewContainer)
            
            self.localVideoViewContainer.frame = frameForLocalVideo(isCenter: true)
            self.localVideoViewContainer.clipsToBounds = true
            self.localVideoViewContainer.layer.cornerRadius = self.localVideoViewContainer.frame.size.width / 2
            self.localVideoViewContainer.backgroundColor = .clear
            self.setUpLocalVideoViewIn(container: self.localVideoViewContainer, isFront: true, isChromaKey: false)
            
            self.orderDrawViews()
            
            self.chatPeekView = DGStreamChatPeekView()
            self.chatPeekView.configureWithin(container: self.chatPeekViewContainer)
            
            UIDevice.current.beginGeneratingDeviceOrientationNotifications()
            
            NotificationCenter.default.addObserver(self, selector: #selector(deviceOrientationDidChange), name: Notification.Name.UIDeviceOrientationDidChange, object: nil)
            
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
            
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                self.session?.acceptCall(nil)
            }
            print("VIEW WILL APPEAR")
        }

    }
    
    func dismissPopover() {
        if let pop = self.popover {
            pop.dismiss(animated: true, completion: nil)
            self.popover = nil
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
        DGStreamCore.instance.presentedViewController = self
        if shouldLoadData {
            
//            if !self.isInitiator, let session = self.session {
//
//                if let _ = self.videoViewWith(userID: self.selectedUser) {
//                    self.videoViews.removeValue(forKey: self.selectedUser.uintValue)
//                }
//
//                let qbVideoView = QBRTCRemoteVideoView(frame: self.remoteVideoViewContainer.bounds)
//                qbVideoView.setVideoTrack(session.remoteVideoTrack(withUserID: self.selectedUser))
//                qbVideoView.videoGravity = AVLayerVideoGravityResizeAspect
//
//                self.videoViews[self.selectedUser.uintValue] = qbVideoView
//
//                if selectedUser.uintValue == self.selectedUser.uintValue {
//                    let exists = self.remoteVideoViewContainer.subviews.filter({ (subview) -> Bool in
//                        return subview is QBRTCRemoteVideoView
//                    }).first
//                    if exists == nil {
//                        qbVideoView.boundInside(container: self.remoteVideoViewContainer)
//                    }
//                }
//
//                qbVideoView.setSize(self.remoteVideoViewContainer.bounds.size)
//            }
            
            self.remoteVideoViewContainer.bringSubview(toFront: self.hangUpButton)
            self.remoteVideoViewContainer.bringSubview(toFront: self.mergeButton)
            self.remoteVideoViewContainer.bringSubview(toFront: self.drawButton)
            self.remoteVideoViewContainer.bringSubview(toFront: self.statusBar)
            
            
            //self.setUpLocalVideoViewIn(container: self.localVideoViewContainer, isFront: true, isChromaKey: false)
            
            print("VIEW WILL APPEAR")
            
        }
        
        self.shouldLoadData = false
        
    }
    
    override public func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "Media", let vc = segue.destination as? DGStreamMediaViewController {
            vc.isShare = true
            vc.delegate = self
        }
        
//        if segue.identifier == "Recording", let nav = segue.destination as? UINavigationController, let recordingsVC = nav.viewControllers[0] as? DGStreamRecordingCollectionsViewController {
//            recordingsVC.delegate = self
//            nav.preferredContentSize = CGSize(width: 280, height: 300)
//            nav.modalPresentationStyle = .popover
//            nav.popoverPresentationController?.delegate = self
//            nav.isModalInPopover = false
//            if sender != nil {
//                recordingsVC.isPhotos = true
//            }
//            self.popover = nav
//        }
        
        if segue.identifier == "documents", let documentsVC = segue.destination as? DGStreamDocumentsViewController {
            documentsVC.delegate = self
            documentsVC.preferredContentSize = CGSize(width: 200, height: 150)
            documentsVC.modalPresentationStyle = .popover
            documentsVC.popoverPresentationController?.delegate = self
            documentsVC.isModalInPopover = false
            self.popover = documentsVC
        }
        
        if segue.identifier == "shareSelect", let shareSelect = segue.destination as? DGStreamCallShareSelectViewController {
            shareSelect.delegate = self
            shareSelect.preferredContentSize = CGSize(width: 200, height: 150)
            shareSelect.modalPresentationStyle = .popover
            shareSelect.popoverPresentationController?.delegate = self
            shareSelect.isModalInPopover = false
            self.popover = shareSelect
        }
        
        if segue.identifier == "stamps", let stampsVC = segue.destination as? DGStreamCallStampsViewController {
            stampsVC.preferredContentSize = CGSize(width: 280, height: 244)
            stampsVC.delegate = self
            stampsVC.selectedColor = self.drawColor
            stampsVC.modalPresentationStyle = .popover
            stampsVC.popoverPresentationController?.delegate = self
            stampsVC.isModalInPopover = false
            self.popover = stampsVC
        }
        
        if segue.identifier == "mergeColor", let colorVC = segue.destination as? DGStreamCallColorViewController {
            colorVC.preferredContentSize = CGSize(width: 280, height: 44)
            colorVC.selectedColor = self.mergeOptionColor
            colorVC.selectedIntensity = self.mergeOptionIntensity
            colorVC.modalPresentationStyle = .popover
            colorVC.popoverPresentationController?.delegate = self
            colorVC.isModalInPopover = false
            colorVC.delegate = self
            self.popover = colorVC
        }
        
        if segue.identifier == "mergeIntensity", let intensityVC = segue.destination as? DGStreamMergeIntensityViewController {
            intensityVC.preferredContentSize = CGSize(width: 280, height: 44)
            intensityVC.mergeColor = self.mergeOptionColor
            intensityVC.intensity = self.mergeOptionIntensity
            intensityVC.modalPresentationStyle = .popover
            intensityVC.popoverPresentationController?.delegate = self
            intensityVC.isModalInPopover = false
            intensityVC.delegate = self
            self.popover = intensityVC
        }
        
        if segue.identifier == "image", let image = sender as? UIImage, let imageVC = segue.destination as? DGStreamCallImageViewController {
            imageVC.image = image
        }
    }
    
    func deviceOrientationDidChange() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.20) {
            
            var isCenter = false
            if self.blackoutView.alpha == 1 {
                isCenter = true
            }
            let frame = self.frameForLocalVideo(isCenter: isCenter)
            UIView.animate(withDuration: 0.10, animations: {
                self.localVideoViewContainer.frame = frame
                self.localVideoViewContainer.layer.cornerRadius = frame.size.width / 2
            })
            
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
                var height:CGFloat = 450
                if Display.pad {
                    height = 700
                }
                self.chatContainerHeightConstraint.constant = height
                self.chatContainer.layoutIfNeeded()
            }
            
            let orientation: AVCaptureVideoOrientation = self.getCaptureOrientationDeviceOrientation()
            
            self.videoOrientation = orientation
            self.recordingManager.recorder?.recordOrientation = UIApplication.shared.statusBarOrientation
            
            if let lv = self.localBroadcastView {
                lv.adjust(orientation: UIDevice.current.orientation, newSize: self.remoteVideoViewContainer.bounds.size)
            }
        }
        
    }
    
    func setUpDrawView() {
        if self.jotVC == nil {
            
            self.drawView = UIImageView(frame: self.view.bounds)
            self.drawView?.boundInside(container: self.view)
            self.drawView?.backgroundColor = .clear
            
            self.jotVC = JotViewController()
            self.jotVC?.undoManager?.enableUndoRegistration()
            self.jotVC?.undoManager?.levelsOfUndo = 0
            self.jotVC?.delegate = self
            self.jotVC?.view.boundInside(container: self.view)
            self.jotVC?.view.backgroundColor = .clear
            self.jotVC?.drawingContainer.backgroundColor = .clear
            let gestures = self.jotVC?.drawingContainer.gestureRecognizers
            let tapGest = gestures?.first as? UITapGestureRecognizer
            self.jotTapGesture = tapGest
            self.jotVC?.view.alpha = 1.0
            self.jotVC?.didMove(toParentViewController: self)
            self.jotVC?.state = .drawing
            self.jotVC?.drawingColor = self.drawColor
            self.jotVC?.drawingStrokeWidth = self.drawSize
            self.jotVC?.textColor = self.drawColor
            self.jotVC?.initialTextInsets = UIEdgeInsets(top: UIScreen.main.bounds.size.height / 2, left: 0, bottom: 0, right: 0)
            self.jotVC?.textEditingInsets = UIEdgeInsets(top: UIScreen.main.bounds.size.height / 2, left: 0, bottom: 0, right: 0)
            self.orderDrawViews()
            self.jotVC?.view.isUserInteractionEnabled = false
        
        }
    }
    
    func setUpLocalVideoViewIn(container: UIView, isFront: Bool, isChromaKey: Bool) {
        if let lv = self.localBroadcastView {
            lv.deconfigure()
            lv.removeFromSuperview()
            self.localBroadcastView = nil
        }
        self.localBroadcastView = DGStreamLocalVideoView(frame: self.remoteVideoViewContainer.frame)
        self.localBroadcastView!.configureWith(orientation: UIDevice.current.orientation, isFront: isFront, isChromaKey: isChromaKey, removeColor: self.mergeOptionColor, removeIntensity: self.getTrue(intensity: self.mergeOptionIntensity, for: self.mergeOptionColor), delegate: self)
        self.localBroadcastView?.boundInside(container: container)
        self.localBroadcastView?.alpha = 1.0
        if isChromaKey {
            self.localVideoCapture = nil
            self.screenCapture = DGStreamScreenCapture(view: self.remoteVideoViewContainer, remoteScreenSize: self.remoteScreenSize!)
            self.screenCapture?.delegate = self
            self.session?.localMediaStream.videoTrack.videoCapture = self.screenCapture
            if self.mergeOptionColor == .black {
                self.localBroadcastView?.alpha = 0.5
            }
            else {
                self.localBroadcastView?.beginChromaKey()
            }
        }
        else {
            self.screenCapture = nil
            self.localVideoCapture = DGStreamLocalVideoCapture(view: container)
            self.session?.localMediaStream.videoTrack.videoCapture = self.localVideoCapture
            self.localBroadcastView?.stopChromaKey()
        }
    }
    
    func getCaptureOrientationDeviceOrientation() -> AVCaptureVideoOrientation {
        var orientation: AVCaptureVideoOrientation = .portrait
        let deviceOrientation = UIDevice.current.orientation
        if deviceOrientation == .portrait {
            orientation = .portrait
        }
        else if deviceOrientation == .landscapeLeft {
            orientation = .landscapeLeft
        }
        else if deviceOrientation == .landscapeRight {
            orientation = .landscapeRight
        }
        else {
            orientation = .portraitUpsideDown
        }
        return orientation
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
        QBRTCAudioSession.instance().isAudioEnabled = true
        QBRTCAudioSession.instance().useManualAudio = true
        QBRTCAudioSession.instance().initialize { (config) in
            config.mode = AVAudioSessionModeVoiceChat
            config.categoryOptions = .duckOthers
            config.category = AVAudioSessionCategoryPlayAndRecord
        }
//
        if isAudioCall {
            self.mergeButtonContainer.isHidden = true
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
            //self.session?.localMediaStream.audioTrack.isEnabled = true
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
            //self.session?.localMediaStream.audioTrack.isEnabled = true
            self.session?.localMediaStream.videoTrack.isEnabled = true
            
            self.localBroadcastView?.frame = self.localVideoViewContainer.bounds
            localBroadcastView?.boundInside(container: self.localVideoViewContainer)
            self.localBroadcastView?.isHidden = false
        }
    }
    
    func setUpButtons() {
        
        let callPhoneImage = UIImage(named: "video", in: Bundle.init(identifier: "com.dataglance.DGStream"), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        
        let mergeImage = UIImage(named: "merge", in: Bundle(identifier: "com.dataglance.DGStream"), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        
        let perspectiveImage = UIImage(named: "eye", in: Bundle(identifier: "com.dataglance.DGStream"), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        
        //let drawImage = UIImage(named: "EditPencil", in: Bundle(identifier: "com.dataglance.DGStream"), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        
        let hangUpImage = UIImage(named: "hangup", in: Bundle.init(identifier: "com.dataglance.DGStream"), compatibleWith: nil)
        
        let whiteBoardImage = UIImage(named: "scratchpad", in: Bundle.init(identifier: "com.dataglance.DGStream"), compatibleWith: nil)
        
        let recordImage = UIImage.init(named: "record", in: Bundle.init(identifier: "com.dataglance.DGStream"), compatibleWith: nil)
        
        let shareImage = UIImage.init(named: "share", in: Bundle.init(identifier: "com.dataglance.DGStream"), compatibleWith: nil)
        
        self.statusBarBackButton.setTitleColor(.white, for: .normal)
        self.statusBarDoneButton.setTitleColor(.white, for: .normal)
        self.statusBarDoneButton.alpha = 0
        
        self.showHideButtonsButton.setImage(UIImage.init(named: "hide", in: Bundle(identifier: "com.dataglance.DGStream"), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.showHideButtonsButton.tintColor = .white
        self.showHideButtonsButton.backgroundColor = .clear
        self.showHideButtonsButton.layer.cornerRadius = self.showHideButtonsButton.frame.size.width / 2
        self.showHideButtonsButton.clipsToBounds = true
        self.showHideButtonsButton.alpha = 0
        
        self.topViews.append(self.statusBar)
        
        var radius:CGFloat = 6.0
        if Display.phone {
            radius = 22
        }
        else {
            radius = 30
        }
        
        // Hang up
        self.hangUpButtonContainer.layer.borderColor = UIColor.red.cgColor
        self.hangUpButtonContainer.layer.borderWidth = 1
        self.hangUpButtonContainer.backgroundColor = .clear
        self.hangUpButton.setImage(hangUpImage?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.hangUpButton.tintColor = .red
        self.hangUpButton.backgroundColor = .clear
        var hangUpButtonInsets: UIEdgeInsets
        if Display.pad {
            self.hangUpButton.contentHorizontalAlignment = .fill
            self.hangUpButton.contentVerticalAlignment = .fill
            self.hangUpButton.contentMode = .scaleAspectFill
            hangUpButtonInsets = UIEdgeInsetsMake(8, 8, 8, 8)
        }
        else {
            hangUpButtonInsets = UIEdgeInsetsMake(8, 8, 8, 8)
        }
        self.hangUpButton.imageEdgeInsets = hangUpButtonInsets
        self.hangUpButtonContainer.layer.cornerRadius = self.hangUpButtonContainer.frame.size.width / 2
        
        self.topViews.append(self.hangUpButtonContainer)
        
        // Merge
        self.mergeButtonContainer.alpha = 0
        self.mergeButtonContainer.layer.borderColor = UIColor.dgBlueDark().cgColor
        self.mergeButtonContainer.layer.borderWidth = 1
        self.mergeButtonContainer.clipsToBounds = true
        self.mergeButtonContainer.layer.cornerRadius = radius
        self.mergeButtonContainer.backgroundColor = .clear
        self.mergeButton.backgroundColor = .clear
        self.mergeButton.setImage(mergeImage?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.mergeButton.tintColor = UIColor.dgBlueDark()
        var mergeButtonInsets: UIEdgeInsets
        if Display.pad {
            self.mergeButton.contentVerticalAlignment = .fill
            self.mergeButton.contentHorizontalAlignment = .fill
            self.mergeButton.contentMode = .scaleAspectFill
            mergeButtonInsets = UIEdgeInsetsMake(12, 12, 12, 12)
        }
        else {
            mergeButtonInsets = UIEdgeInsetsMake(10, 10, 24, 24)
        }
        self.mergeButton.imageEdgeInsets = mergeButtonInsets
        self.mergeButtonLabel.text = "Merge"
        self.mergeButtonLabel.textColor = UIColor.dgBlueDark()
        self.mergeButtonLabel.alpha = 0
        
        self.topViews.append(self.mergeButtonContainer)
        self.topViews.append(self.mergeButtonLabel)
        
        self.perspectiveButtonContainer.alpha = 0
        self.perspectiveButtonContainer.layer.borderColor = UIColor.dgBlueDark().cgColor
        self.perspectiveButtonContainer.layer.borderWidth = 1
        self.perspectiveButtonContainer.clipsToBounds = true
        self.perspectiveButton.backgroundColor = .clear
        self.perspectiveButtonContainer.layer.cornerRadius = radius
        self.perspectiveButtonContainer.backgroundColor = .clear
        self.perspectiveButton.setImage(perspectiveImage?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.perspectiveButton.tintColor = UIColor.dgBlueDark()
        var perspectiveButtonInsets: UIEdgeInsets
        if Display.pad {
            self.perspectiveButton.contentVerticalAlignment = .fill
            self.perspectiveButton.contentHorizontalAlignment = .fill
            self.perspectiveButton.contentMode = .scaleAspectFill
            perspectiveButtonInsets = UIEdgeInsetsMake(12, 12, 12, 12)
        }
        else {
            perspectiveButtonInsets = UIEdgeInsetsMake(0, 0, 14, 14)
        }
        self.perspectiveButton.imageEdgeInsets = perspectiveButtonInsets
        self.perspectiveButtonLabel.text = "Perspective"
        self.perspectiveButtonLabel.textColor = UIColor.dgBlueDark()
        self.perspectiveButtonLabel.alpha = 0
        
        self.topViews.append(self.perspectiveButtonContainer)
        self.topViews.append(self.perspectiveButtonLabel)
        
        // Share
        self.shareButtonContainer.alpha = 0
        self.shareButtonContainer.layer.borderColor = UIColor.dgBlueDark().cgColor
        self.shareButtonContainer.layer.borderWidth = 1
        self.shareButtonContainer.clipsToBounds = true
        self.shareButton.backgroundColor = .clear
        self.shareButtonContainer.layer.cornerRadius = radius
        self.shareButtonContainer.backgroundColor = .clear
        self.shareButton.setImage(shareImage?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.shareButton.tintColor = UIColor.dgBlueDark()
        self.shareButton.contentVerticalAlignment = .fill
        self.shareButton.contentHorizontalAlignment = .fill
        self.shareButton.contentMode = .scaleAspectFill
        var shareButtonInsets: UIEdgeInsets
        if Display.pad {
            shareButtonInsets = UIEdgeInsetsMake(12, 12, 12, 12)
        }
        else {
            shareButtonInsets = UIEdgeInsetsMake(10, 10, 24, 24)
        }
        self.shareButton.imageEdgeInsets = shareButtonInsets
        self.shareButtonLabel.text = "Share..."
        self.shareButtonLabel.textColor = UIColor.dgBlueDark()
        self.shareButtonLabel.alpha = 0
        
        self.topViews.append(self.shareButtonContainer)
        self.topViews.append(self.shareButtonLabel)
        
        // White Board
        self.whiteBoardButtonContainer.alpha = 0
        self.whiteBoardButtonContainer.layer.borderColor = UIColor.dgBlueDark().cgColor
        self.whiteBoardButtonContainer.layer.borderWidth = 1
        self.whiteBoardButtonContainer.clipsToBounds = true
        self.whiteBoardButtonContainer.backgroundColor = .clear
        self.whiteBoardButtonContainer.layer.cornerRadius = radius
        self.whiteBoardButton.backgroundColor = .clear
        self.whiteBoardButton.setImage(whiteBoardImage?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.whiteBoardButton.tintColor = UIColor.dgBlueDark()
        self.whiteBoardButton.contentHorizontalAlignment = .fill
        self.whiteBoardButton.contentVerticalAlignment = .fill
        self.whiteBoardButton.contentMode = .scaleAspectFill
        var whiteBoardInsets: UIEdgeInsets
        if Display.pad {
            whiteBoardInsets = UIEdgeInsetsMake(12, 12, 12, 12)
        }
        else {
            whiteBoardInsets = UIEdgeInsetsMake(8, 8, 24, 24)
        }
        self.whiteBoardButton.imageEdgeInsets = whiteBoardInsets
        self.whiteBoardButtonLabel.text = "Whiteboard"
        self.whiteBoardButtonLabel.textColor = UIColor.dgBlueDark()
        self.whiteBoardButtonLabel.alpha = 0
        
        self.topViews.append(self.whiteBoardButtonContainer)
        self.topViews.append(self.whiteBoardButtonLabel)
        
        // Record
        self.recordButton.backgroundColor = .clear
        self.recordButton.setImage(recordImage?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.recordButton.tintColor = .white
        self.recordButton.contentHorizontalAlignment = .center
        self.recordButton.contentVerticalAlignment = .center
        self.recordButton.contentMode = .scaleAspectFill
        self.recordButton.alpha = 0
        
        // Freeze
        self.freezeButton.backgroundColor = .clear
        self.freezeButton.setImage(UIImage.init(named: "freeze", in: Bundle.init(identifier: "com.dataglance.DGStream"), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.freezeButton.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8)
        self.freezeButton.tintColor = .white
        self.freezeButton.contentHorizontalAlignment = .center
        self.freezeButton.contentVerticalAlignment = .center
        self.freezeButton.contentMode = .scaleAspectFill
        self.freezeButton.alpha = 0
        self.freezeButton.layer.cornerRadius = self.freezeButton.frame.size.width / 2
        self.freezeButton.clipsToBounds = true
        self.freezeButton.isEnabled = false
        
        // Snapshot
        self.snapshotButton.backgroundColor = .clear
        self.snapshotButton.setImage(UIImage.init(named: "capture", in: Bundle.init(identifier: "com.dataglance.DGStream"), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.snapshotButton.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 12)
        self.snapshotButton.tintColor = .white
        self.snapshotButton.contentHorizontalAlignment = .center
        self.snapshotButton.contentVerticalAlignment = .center
        self.snapshotButton.contentMode = .scaleAspectFill
        self.snapshotButton.alpha = 0
        
        // Draw
        self.drawButton.backgroundColor = .clear
//        self.drawButton.setTitle("Draw", for: .normal)
        self.drawButton.titleLabel?.textAlignment = .center
        self.drawButton.setImage(UIImage.init(named: "EditPencil", in: Bundle.init(identifier: "com.dataglance.DGStream"), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.drawButton.imageEdgeInsets = UIEdgeInsetsMake(12, 12, 12, 12)
        self.drawButton.tintColor = .white
        self.drawButton.contentHorizontalAlignment = .center
        self.drawButton.contentVerticalAlignment = .center
        self.drawButton.contentMode = .scaleAspectFill
        self.drawButton.alpha = 0
        self.drawButton.layer.cornerRadius = self.drawButton.frame.size.width / 2
        self.drawButton.clipsToBounds = true
        self.drawButton.isEnabled = false
        
        // Chat
        self.chatButtonContainer.alpha = 0
        self.chatButtonContainer.layer.borderColor = UIColor.dgBlueDark().cgColor
        self.chatButtonContainer.clipsToBounds = true
        self.chatButtonContainer.layer.borderWidth = 1
        self.chatButtonContainer.layer.cornerRadius = radius
        self.chatButtonContainer.backgroundColor = .clear
        self.chatButton.backgroundColor = .clear
        self.chatButton.setImage(UIImage.init(named: "message", in: Bundle.init(identifier: "com.dataglance.DGStream"), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.chatButton.tintColor = UIColor.dgBlueDark()
        var chatButtonInsets: UIEdgeInsets
        if Display.pad {
            chatButtonInsets = UIEdgeInsetsMake(8, 8, 8, 8)
        }
        else {
            chatButtonInsets = UIEdgeInsetsMake(10, 10, 26, 26)
        }
        self.chatButton.imageEdgeInsets = chatButtonInsets
        self.chatButtonLabel.textColor = UIColor.dgBlueDark()
        self.chatButtonLabel.alpha = 0
        
        self.topViews.append(self.chatButtonContainer)
        
        var hangUpButtonWH:CGFloat = 0
        var otherButtonsWH:CGFloat = 0
        var padding: CGFloat = 0
        let insets:UIEdgeInsets
        
        if Display.pad {
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
        
        self.statusBarDoneButton.alpha = 0
        
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
        self.disableDrawButtons()
        self.view.layoutIfNeeded()
    }
    
    func setUpOptions() {
        
        self.optionsContainerContainer.alpha = 0
        
        self.optionsContainer.backgroundColor = UIColor.dgBG()
        self.optionsContainer.layer.borderColor = UIColor.dgBlack().cgColor
        self.optionsContainer.layer.borderWidth = 0.5
        
        self.optionsButtonContainer.backgroundColor = .clear
        self.optionsButtonContainer.layer.borderColor = UIColor.dgBlueDark().cgColor
        self.optionsButtonContainer.layer.borderWidth = 0.5
        self.optionsButtonContainer.layer.cornerRadius = 6
        
        self.selectColorContainer.layer.borderColor = UIColor.dgBlack().cgColor
        self.selectColorContainer.layer.borderWidth = 0.5
        self.selectColorLabel.backgroundColor = UIColor.dgBlueDark()
        self.selectColorCollectionView.dataSource = self
        self.selectColorCollectionView.delegate = self
        self.selectColorCollectionView.tag = 100
        self.selectColorCollectionView.reloadData()
        
        self.selectSizeContainer.layer.borderColor = UIColor.dgBlack().cgColor
        self.selectSizeContainer.layer.borderWidth = 0.5
        self.selectSizeLabel.backgroundColor = UIColor.dgBlueDark()
        self.selectSizeCollectionView.dataSource = self
        self.selectSizeCollectionView.delegate = self
        self.selectSizeCollectionView.tag = 99
        self.selectSizeCollectionView.reloadData()
        
        self.optionsButtonsContainer.layer.borderColor = UIColor.dgBlack().cgColor
        self.optionsButtonsContainer.layer.borderWidth = 0.5
        
        self.optionsContainerButton.setImage(UIImage.init(named: "back", in: Bundle.init(identifier: "com.dataglance.DGStream"), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.optionsContainerButton.backgroundColor = .clear
        self.optionsContainerButton.tintColor = UIColor.dgBlueDark()
        
        // Stamps
        self.stampsButton.backgroundColor = UIColor.dgBlueDark()
        self.stampsButton.setTitle("Stamps", for: .normal)
        self.stampsButton.setTitleColor(.white, for: .normal)
        self.stampsButton.titleLabel?.textColor = .white
        self.stampsButton.imageEdgeInsets = UIEdgeInsetsMake(12, 12, 12, 12)
        self.stampsButton.layer.cornerRadius = 6
        self.stampsButton.layer.borderWidth = 0.5
        self.stampsButton.layer.borderColor = UIColor.dgBlack().cgColor
        
        self.undoButton.backgroundColor = UIColor.dgBlueDark()
        self.undoButton.setImage(UIImage.init(named: "undo", in: Bundle.init(identifier: "com.dataglance.DGStream"), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.undoButton.imageEdgeInsets = UIEdgeInsetsMake(12, 12, 12, 12)
        self.undoButton.tintColor = .white
        self.undoButton.contentHorizontalAlignment = .center
        self.undoButton.contentVerticalAlignment = .center
        self.undoButton.contentMode = .scaleAspectFill
        self.undoButton.isEnabled = false
//        self.undoButton.tintColor = .lightGray
        self.undoButton.layer.cornerRadius = self.undoButton.frame.size.width / 2
        self.undoButton.layer.borderWidth = 0.5
        self.undoButton.layer.borderColor = UIColor.dgBlack().cgColor
        
        self.clearAllButton.backgroundColor = UIColor.dgBlueDark()
        self.clearAllButton.setImage(UIImage.init(named: "trash", in: Bundle.init(identifier: "com.dataglance.DGStream"), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.clearAllButton.imageEdgeInsets = UIEdgeInsetsMake(12, 12, 12, 12)
        self.clearAllButton.tintColor = .white
        self.clearAllButton.contentHorizontalAlignment = .center
        self.clearAllButton.contentVerticalAlignment = .center
        self.clearAllButton.contentMode = .scaleAspectFit
        self.clearAllButton.isEnabled = false
//        self.clearAllButton.tintColor = .lightGray
        self.clearAllButton.layer.cornerRadius = self.clearAllButton.frame.size.width / 2
        self.clearAllButton.layer.borderWidth = 0.5
        self.clearAllButton.layer.borderColor = UIColor.dgBlack().cgColor
        self.clearAllButton.isEnabled = false
        self.clearAllButton.setTitleColor(.lightGray, for: .normal)
        self.clearAllButton.titleLabel?.textColor = .lightGray
        
        self.mergeColorButton.backgroundColor = UIColor.dgBlueDark()
        self.mergeColorButton.setImage(UIImage.init(named: "colorDot", in: Bundle.init(identifier: "com.dataglance.DGStream"), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.mergeColorButton.imageEdgeInsets = UIEdgeInsetsMake(12, 12, 12, 12)
        self.mergeColorButton.tintColor = .lightGray
        self.mergeColorButton.contentHorizontalAlignment = .center
        self.mergeColorButton.contentVerticalAlignment = .center
        self.mergeColorButton.contentMode = .scaleAspectFill
//        self.mergeColorButton.isEnabled = false
        self.mergeColorButton.layer.cornerRadius = self.mergeColorButton.frame.size.width / 2
        self.mergeColorButton.layer.borderWidth = 0.5
        self.mergeColorButton.layer.borderColor = UIColor.dgBlack().cgColor
        
        self.mergeIntensityButton.backgroundColor = UIColor.dgBlueDark()
        self.mergeIntensityButton.setTitle("\(stringFor(float: self.mergeOptionIntensity))", for: .normal)
        self.mergeIntensityButton.setTitleColor(.white, for: .normal)
        self.mergeIntensityButton.titleLabel?.textColor = .white
        self.mergeIntensityButton.imageEdgeInsets = UIEdgeInsetsMake(12, 12, 12, 12)
        self.mergeIntensityButton.contentHorizontalAlignment = .center
        self.mergeIntensityButton.contentVerticalAlignment = .center
        self.mergeIntensityButton.contentMode = .scaleAspectFill
//        self.mergeIntensityButton.isEnabled = false
        self.mergeIntensityButton.layer.cornerRadius = self.mergeColorButton.frame.size.width / 2
        self.mergeIntensityButton.layer.borderWidth = 0.5
        self.mergeIntensityButton.layer.borderColor = UIColor.dgBlack().cgColor
        self.hideOptions(animated: false)
        self.disableDrawButtons()
        self.disableMergeButtons()
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
        self.topViews.append(self.chatContainer)
    }
    
    func setDropDownView() {
        if self.dropDown != nil {
            self.dropDown.removeFromSuperview()
            self.dropDown = nil
        }
        if self.dropDownManager != nil {
            self.dropDownManager = nil
        }
    }
    
    func animateButtons() {
        UIView.animate(withDuration: 0.25) {
            self.mergeButton.alpha = 1
            self.hangUpButton.alpha = 1
            self.whiteBoardButton.alpha = 1
            self.recordButton.alpha = 1
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
//            if Display.pad {
//                wh = 160
//                y = 70
//            }
//            else {
//                wh = 100
//                y = UIScreen.main.bounds.height - (wh + 40)
//            }
            wh = 100
            y = UIScreen.main.bounds.height - (wh + 40)
            x = 10
        }
        return CGRect(x: x, y: y, width: wh, height: wh)
    }
    
    func videoViewWith(userID: NSNumber) -> UIView? {
        if self.session?.conferenceType == .audio {
            return nil
        }
        var result = self.videoViews[userID.uintValue]
        if let currentUser = DGStreamCore.instance.currentUser, let currentUserID = currentUser.userID, currentUserID.int16Value == userID.int16Value {
            if result == nil {
                let videoView = DGStreamVideoView(layer: self.cameraCapture!.previewLayer, frame: self.localVideoViewContainer.bounds)
                self.videoViews[userID.uintValue] = videoView
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
        let currentUser = DGStreamCore.instance.currentUser
        var username = ""
        if let currentUsername = currentUser?.username {
            username = currentUsername
        }
        let userInfo:[String: String] = ["username": username, "url": "http.quickblox.com", "param": "dev"]
        self.session?.startCall(userInfo)
    }
    
    func playCallingSound(sender: Any) {
        
    }
    
    func acceptCall() {
        self.session?.acceptCall(nil)
    }
    
    func showCallEndedWith(isHungUp: Bool) {
        
        self.dismissPopover()
        
        if isHungUp {
            let suffix = NSLocalizedString("hung up", comment: "(user_name) was disconnected")
            if let user = DGStreamCore.instance.getOtherUserWith(userID: self.selectedUser), let username = user.username {
                self.blackoutLabel.text = "\(username) \(suffix)"
            }
            else {
                let otherUserString = NSLocalizedString("The other user", comment: "Default name for the other user in the call other than the current user")
                self.blackoutLabel.text = "\(otherUserString) \(suffix)"
            }
        }
        else {
            self.blackoutLabel.text = "Connection Lost"
        }
        
        if let blackout = self.blackoutView {
            self.view.bringSubview(toFront: blackout)
        }

        self.statusBar.backgroundColor = UIColor.dgBlueDark()
        self.statusBarBackButton.alpha = 0
        self.statusBarDoneButton.alpha = 0
        self.statusBarTitle.alpha = 0
        self.hangUpButtonContainer.alpha = 0
        self.chatContainer.alpha = 0
        self.chatVC.view.alpha = 0
        self.chatButtonContainer.alpha = 0
        self.perspectiveButtonLabel.alpha = 0
        self.perspectiveButtonContainer.alpha = 0
        self.shareButtonLabel.alpha = 0
        self.shareButtonContainer.alpha = 0
        self.mergeButtonLabel.alpha = 0
        self.mergeButtonContainer.alpha = 0
        self.whiteBoardButtonLabel.alpha = 0
        self.whiteBoardButtonContainer.alpha = 0
        //self.hideDropDown(animated: false)
        let newFrame = self.frameForLocalVideo(isCenter: true)
        self.localBroadcastView?.frame = CGRect(x: 0, y: 0, width: newFrame.size.width, height: newFrame.size.height)
        self.localBroadcastView?.layoutIfNeeded()
        self.localBroadcastView?.stopChromaKey()
        self.localVideoViewContainer.frame = newFrame
        self.localVideoViewContainer.layoutIfNeeded()
        self.localVideoViewContainer.alpha = 1
        self.localVideoViewContainer.layer.cornerRadius = newFrame.size.width / 2
        self.jotVC?.clearDrawing()
        self.jotVC?.view.removeFromSuperview()
        self.jotVC = nil
        self.clearDrawings()
        self.clearRemoteDrawings()
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
//        self.screenCapture = DGStreamScreenCapture(view: screenView)
//        self.screenCapture?.view.contentMode = .scaleAspectFill
//        self.session?.localMediaStream.videoTrack.videoCapture = self.screenCapture
    }
    
    func endScreenCapture() {
        self.screenCapture = nil
        self.session?.localMediaStream.videoTrack.videoCapture = self.cameraCapture
    }
    
    func removeBlackout() {
        self.blackoutView.alpha = 0.99
        let newFrame = frameForLocalVideo(isCenter: false)
        print("New Frame \(newFrame)")
        self.isWaitingForCallAccept = false
        if self.isAudioCall {
            UIView.animate(withDuration: 0.35, animations: {
                self.statusBar.backgroundColor = UIColor.dgBlueDark()
                self.audioIndicatorContainer.alpha = 1
                self.audioCallLabel.alpha = 1
                self.blackoutView.alpha = 0
            }, completion: { (f) in
            })
        }
        else {
            UIView.animate(withDuration: 0.35, delay: 0.01, options: .curveEaseIn, animations: {
                self.statusBar.backgroundColor = UIColor.dgBlueDark()
                self.blackoutView.alpha = 0
                self.shareButtonContainer.alpha = 1
                self.shareButtonLabel.alpha = 1
                self.mergeButtonContainer.alpha = 1
                self.mergeButtonLabel.alpha = 1
                self.whiteBoardButtonContainer.alpha = 1
                self.whiteBoardButtonLabel.alpha = 1
                self.chatButtonContainer.alpha = 1
                self.chatButtonLabel.alpha = 1
                self.perspectiveButtonContainer.alpha = 1
                self.perspectiveButtonLabel.alpha = 1
                self.recordButton.alpha = 1
                self.freezeButton.alpha = 1
                self.snapshotButton.alpha = 1
                self.drawButton.alpha = 1
                self.showHideButtonsButton.alpha = 1
                self.optionsContainerButton.alpha = 1
                self.localBroadcastView?.frame = CGRect(x: 0, y: 0, width: newFrame.size.width, height: newFrame.size.height)
                self.localBroadcastView?.layoutIfNeeded()
                self.localVideoViewContainer?.frame = newFrame
                self.localVideoViewContainer?.layer.cornerRadius = newFrame.size.width / 2
                self.localVideoViewContainer?.layoutIfNeeded()
            }) { (f) in

            }
            self.freezeImageView = UIImageView.init(frame: self.remoteVideoViewContainer.bounds)
            self.freezeImageView?.image = nil
            self.freezeImageView?.boundInside(container: self.remoteVideoViewContainer)
            self.freezeImageView?.alpha = 0
        }
    
    }
    
    func showDropDown(animated: Bool) {
        self.view.layoutIfNeeded()
        let newRect = CGRect(x: 10, y: 84, width: self.localVideoViewContainer.frame.width, height: self.localVideoViewContainer.frame.height)
        if animated {
            UIView.animate(withDuration: 0.25) {
                self.localVideoViewContainer.frame = newRect
            }
        }
        else {
            self.localVideoViewContainer.frame = newRect
        }
    }
    
    func hideDropDown(animated: Bool) {
        self.view.layoutIfNeeded()
        let newRect = CGRect(x: 10, y: 40, width: self.localVideoViewContainer.frame.width, height: self.localVideoViewContainer.frame.height)
        if animated {
            UIView.animate(withDuration: 0.25, animations: {
                self.localVideoViewContainer.frame = newRect
            }, completion: { (f) in
            })
        }
        else {
            self.localVideoViewContainer.frame = newRect
        }
    }
    
    func localVideoTapped() {
        self.didSelectToHideLocalVideo = true
        self.hideLocalVideo()
    }
    
    func showLocalVideo() {
        UIView.animate(withDuration: 0.25) {
            self.localVideoViewContainer.alpha = 1
        }
    }
    
    func hideLocalVideo() {
        UIView.animate(withDuration: 0.25) {
            self.localVideoViewContainer.alpha = 0
        }
    }
    
    func toggleControls() {
        if self.isAudioCall == false {
            if self.isShowingControls {
                self.hideControls()
            }
            else {
                self.showControls()
            }
        }
    }
    
    func showControls() {
        self.isShowingControls = true
        self.didSelectToHideLocalVideo = false
        UIView.animate(withDuration: 0.25) {
            self.hangUpButtonContainer.alpha = 1
            if self.callMode != .stream || (self.isSharing || self.isBeingSharedWith) {
               
            }
            if self.callMode != .board {
                self.localVideoViewContainer.alpha = 1
            }
            self.perspectiveButtonLabel.alpha = 1
            self.perspectiveButtonContainer.alpha = 1
            self.shareButtonLabel.alpha = 1
            self.shareButtonContainer.alpha = 1
            self.mergeButtonLabel.alpha = 1
            self.mergeButtonContainer.alpha = 1
            self.whiteBoardButtonLabel.alpha = 1
            self.whiteBoardButtonContainer.alpha = 1
            self.chatButtonContainer.alpha = 1
            self.chatButtonLabel.alpha = 1
            self.showHideButtonsButton.backgroundColor = .clear
            self.showHideButtonsButton.tintColor = .white
        }
    }
    
    func hideControls() {
        self.isShowingControls = false
        UIView.animate(withDuration: 0.25) {
            self.hangUpButtonContainer.alpha = 0
            self.localVideoViewContainer.alpha = 0
            self.perspectiveButtonLabel.alpha = 0
            self.perspectiveButtonContainer.alpha = 0
            self.shareButtonLabel.alpha = 0
            self.shareButtonContainer.alpha = 0
            self.mergeButtonLabel.alpha = 0
            self.mergeButtonContainer.alpha = 0
            self.whiteBoardButtonLabel.alpha = 0
            self.whiteBoardButtonContainer.alpha = 0
            self.chatButtonContainer.alpha = 0
            self.chatButtonLabel.alpha = 0
            self.showHideButtonsButton.backgroundColor = .white
            self.showHideButtonsButton.tintColor = self.statusBar.backgroundColor
        }
    }
    
    func startRecording() {
        let message = QBChatMessage()
        message.text = "recordingStart"
        message.senderID = UInt(DGStreamCore.instance.currentUser?.userID ?? 0)
        message.recipientID = self.selectedUser.uintValue
        QBChat.instance.sendSystemMessage(message, completion: { (error) in })
        
        
        let documentsDirectory = DGStreamFileManager.getDocumentsDirectory()!
        let audioFileName = UUID().uuidString.components(separatedBy: "-").first!
        let remoteAudioName = "\(audioFileName)_R"
        var audioURL = documentsDirectory.appendingPathComponent(audioFileName)
        var remoteAudioURL = documentsDirectory.appendingPathComponent(remoteAudioName)
        audioURL.appendPathExtension("mp4")
        remoteAudioURL.appendPathExtension("mp4")
        let audioCompressionSettings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.low.rawValue]
        do {
            self.audioRecorder = try AVAudioRecorder(url: audioURL, settings: audioCompressionSettings)
            self.audioRecorder?.record()
            self.session?.recorder?.startRecord(withFileURL: remoteAudioURL)
            self.isRecording = true
            self.recordButton.tintColor = .red
        }
        catch let error {
            print("Error recording Audio \(error.localizedDescription)")
            return
        }
        let videoFileName = UUID().uuidString.components(separatedBy: "-").first!
        var videoURL = documentsDirectory.appendingPathComponent(videoFileName)
        videoURL.appendPathExtension("mp4")
        let videoURLString = NSString(string: videoURL.absoluteString).substring(from: 7)
        if FileManager.default.fileExists(atPath: videoURLString) {
            do {
                try FileManager.default.removeItem(at: videoURL)
                print("Deleted Previous File")
            }
            catch let error {
                print("ERROR Removing File \(videoURLString) | \(error.localizedDescription)")
            }
        }
        else {
            print("File Does Not Exist")
        }
        
        do {
            self.assetWriter = try AVAssetWriter(url: videoURL, fileType: AVFileTypeMPEG4)
            
            self.assetWriter?.shouldOptimizeForNetworkUse = true
        }
        catch let error {
            print("ERROR ASSETWRITER \(error.localizedDescription)")
        }
        let videoWidth = self.view.bounds.size.width
        let videoHeight = self.view.bounds.size.height
        let videoCompressionSettings = [AVVideoCodecKey: AVVideoCodecH264, AVVideoWidthKey: videoWidth, AVVideoHeightKey: videoHeight, AVVideoCompressionPropertiesKey: [AVVideoAverageBitRateKey: 636528, AVVideoMaxKeyFrameIntervalKey: 30]] as [String : Any]
        
        if let writer = assetWriter, writer.canApply(outputSettings: videoCompressionSettings, forMediaType: AVMediaTypeVideo) {
            self.assetWriterVideoInput = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: videoCompressionSettings, sourceFormatHint: nil)
            self.assetWriterVideoInput?.expectsMediaDataInRealTime = true
            print("Get transform for \(self.videoOrientation == .portrait)")
            self.assetWriterVideoInput?.transform = transformFor(orientation: videoOrientation)
            if let movieIn = self.assetWriterVideoInput, writer.canAdd(movieIn) {
                writer.add(movieIn)
            }
            else {
                print("Couldn't add asset writer video input.")
                return
            }
            
        }
        else {
            print("Couldn't apply video output settings.")
            return
        }
        self.recordButton.tintColor = .red
        self.recordButton.setTitleColor(.red, for: .normal)
        self.hideControls()
        if #available(iOS 11.0, *) {
            self.recorder.startCapture(handler: { (sample, sampleBufferType, error) in
                
                if CMSampleBufferDataIsReady(sample) {
                    if self.assetWriter?.status == AVAssetWriterStatus.unknown {
                        self.assetWriter?.startWriting()
                        self.assetWriter?.startSession(atSourceTime: CMSampleBufferGetPresentationTimeStamp(sample))
                        self.isRecording = true
                    }
                    if self.assetWriter?.status == AVAssetWriterStatus.failed {
                        print("Error occured, failed = \(self.assetWriter!.error!.localizedDescription)")
                        return
                    }
                    if self.isRecording, sampleBufferType == .video, let input = self.assetWriterVideoInput {
                        if input.isReadyForMoreMediaData {
                            input.append(sample)
                        }
                    }
                }
                
            }) { (error) in
                print("Error Starting Capture \(error?.localizedDescription ?? "No Error")")
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    func stopRecording(isEndOfCall: Bool, completion:@escaping () -> Void) {
        if self.isRecording == false {
            completion()
        }
        
        self.statusBarBackButton.setTitle("Cancel", for: .normal)
        
        if self.callMode != .stream {
            self.statusBar.backgroundColor = UIColor.dgMergeMode()
        }
        else {
            self.statusBar.backgroundColor = UIColor.dgBlueDark()
        }

        if #available(iOS 11.0, *) {
            
            self.recordButton.tintColor = .white
            self.recordButton.setTitleColor(.white, for: .normal)
        
            self.isRecording = false
            
            // Stop Audio Recording
            let audioURL = self.audioRecorder?.url
            self.audioRecorder?.stop()
            self.audioRecorder = nil
            if isEndOfCall == false {
                self.showControls()
            }
            // Stop Video Recording
            self.recorder.stopCapture { (error) in
                if let error = error {
                }
                else {
                    let message = QBChatMessage()
                    message.text = "orientationRequest"
                    message.senderID = UInt(DGStreamCore.instance.currentUser?.userID ?? 0)
                    message.recipientID = self.selectedUser.uintValue
                    QBChat.instance.sendSystemMessage(message, completion: { (error) in })
                    self.assetWriterVideoInput?.markAsFinished()
                    self.assetWriter?.finishWriting {
                        let videoURL = self.assetWriter?.outputURL
                        self.assetWriterVideoInput = nil
                        self.assetWriter = nil
                        let avAsset = AVAsset(url: videoURL!)
                        let assetGenerator = AVAssetImageGenerator(asset: avAsset)
                        assetGenerator.generateCGImagesAsynchronously(forTimes: [kCMTimeZero as NSValue], completionHandler: { (time, image, time2, result, error) in
                            
                            if error == nil, let image = image {
                                
                                let originalThumbnail = UIImage(cgImage: image)
//                                var newThumbnail: UIImage!
//
//                                if self.videoOrientation == .portrait {
//                                    newThumbnail = originalThumbnail.rotated(by:  Measurement(value: 90.0, unit: .degrees))
//                                }
//                                else if self.videoOrientation == .landscapeRight {
//                                    newThumbnail = originalThumbnail.rotated(by:  Measurement(value: 180.0, unit: .degrees))
//                                }
//                                else if self.videoOrientation == .portraitUpsideDown {
//                                    newThumbnail = originalThumbnail.rotated(by:  Measurement(value: 270.0, unit: .degrees))
//                                }
//                                else {
//                                    newThumbnail = originalThumbnail
//                                }
                                let mergeTitle = UUID().uuidString.components(separatedBy: "-").first!
                                DGStreamAudioVideoMerger().mergeVideoAndAudio(videoUrl: videoURL!, audioUrl: audioURL!, fileName: mergeTitle, completion: { (error, errorMessage, url) in
                                    if let error = error {
                                        print("Failed To Merge Audio and Video \(error.localizedDescription)")
                                        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                                        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action: UIAlertAction) in
                                            alert.dismiss(animated: true, completion: nil)
                                        }))
                                        self.present(alert, animated: true) {
                                            
                                        }
                                    }
                                    if let errorMessage = errorMessage {
                                        let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
                                        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action: UIAlertAction) in
                                            alert.dismiss(animated: true, completion: nil)
                                        }))
                                        self.present(alert, animated: true) {
                                            
                                        }
                                    }
                                    else if let url = url {
                                        let fileName = UUID().uuidString.components(separatedBy: "-").first!
                                        let newURL = DGStreamFileManager.createPathFor(mediaType: .video, fileName: fileName)!
                                        
                                        do {
                                            try FileManager.default.moveItem(at: url, to: newURL)
                                            let thumbnailData = UIImageJPEGRepresentation(originalThumbnail, 0.5)
                                            DispatchQueue.main.async {
                                                saveRecordingsWith(fileName: fileName, thumbnail: thumbnailData)
                                            }
                                        }
                                        catch {
                                            print("UNBLE TO MOVE VIDEO TO NEW FOLDER")
                                        }
                                    }
                                })
                            }
                            else {
                                let mergeTitle = UUID().uuidString.components(separatedBy: "-").first!
                                DGStreamAudioVideoMerger().mergeVideoAndAudio(videoUrl: videoURL!, audioUrl: audioURL!,fileName: mergeTitle, completion: { (error, errorMessage, url) in
                                    if let error = error {
                                        print("Failed To Merge Audio and Video \(error.localizedDescription)")
                                        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                                        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action: UIAlertAction) in
                                            alert.dismiss(animated: true, completion: nil)
                                        }))
                                        self.present(alert, animated: true) {
                                            
                                        }
                                    }
                                    else if let errorMessage = errorMessage {
                                        let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
                                        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action: UIAlertAction) in
                                            alert.dismiss(animated: true, completion: nil)
                                        }))
                                        self.present(alert, animated: true) {
                                            
                                        }
                                    }
                                    else if let url = url {
                                        print("MERGED AUDIO AND VIDEO")
                                        let fileName = UUID().uuidString.components(separatedBy: "-").first!
                                        let newURL = DGStreamFileManager.createPathFor(mediaType: .video, fileName: fileName)!
                                        
                                        do {
                                            try FileManager.default.moveItem(at: url, to: newURL)
                                            DispatchQueue.main.async {
                                                saveRecordingsWith(fileName: fileName, thumbnail: nil)
                                            }
                                        }
                                        catch {
                                            print("UNBLE TO MOVE VIDEO TO NEW FOLDER")
                                        }
                                    }
                                })
                            }
                        })
                        func saveRecordingsWith(fileName: String, thumbnail: Data?) {
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
                            self.finishedTakingSnapshot(forVideoCover: true)
                            completion()
                        }
                        
                    }
                }
            }
        }
    }
    
    
    @IBAction func dropDownCancelButtonTapped(_ sender: Any) {
        self.hideDropDown()
    }
    
    @IBAction func optionsButtonTapped(_ sender: Any) {
        if self.optionsContainerConstraint.constant == 0 {
            self.optionsContainerConstraint.constant = -170
            UIView.animate(withDuration: 0.18) {
                self.view.layoutIfNeeded()
            }
        }
        else {
            self.optionsContainerConstraint.constant = 0
            UIView.animate(withDuration: 0.18) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @IBAction func colorBlackButtonTapped(_ sender: Any) {
    }
    
    @IBAction func colorWhiteButtonTapped(_ sender: Any) {
    }
    
    @IBAction func colorRedButtonTapped(_ sender: Any) {
    }
    
    @IBAction func sizeSmallButtonTapped(_ sender: Any) {
    }
    
    @IBAction func sizeMediumButtonTapped(_ sender: Any) {
    }
    
    @IBAction func sizeLargeButtonTapped(_ sender: Any) {
    }
    
    @IBAction func stampsButtonTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "stamps", sender: nil)
    }
    
    @IBAction func undoButtonTapped(_ sender: Any) {
        self.getLastUndo()
//        let undoMessage = QBChatMessage()
//        undoMessage.text = "undo"
//        undoMessage.senderID = DGStreamCore.instance.currentUser?.userID?.uintValue ?? 0
//        undoMessage.recipientID = self.selectedUser.uintValue
//        undoMessage.customParameters = ["undoID":"\(undoID)"]
//        QBChat.instance.sendSystemMessage(undoMessage, completion: { (error) in
//            print("Sent Undo Message With \(error?.localizedDescription ?? "No Error")")
//        })
    }
    
    @IBAction func clearAllButtonTapped(_ sender: Any) {
        self.clearDrawings()
        self.clearRemoteDrawings()
        
        self.drawOperationQueue.increment += 1
        let clearID = self.drawOperationQueue.increment
        let customParams = NSMutableDictionary()
        customParams["increment"] = clearID
        
        let clearAllMessage = QBChatMessage()
        clearAllMessage.senderID = DGStreamCore.instance.currentUser?.userID?.uintValue ?? 0
        clearAllMessage.recipientID = self.selectedUser.uintValue
        clearAllMessage.text = "clearAllDrawings"
        clearAllMessage.customParameters = customParams
        QBChat.instance.sendSystemMessage(clearAllMessage) { (error) in
            
        }
    }
    
    @IBAction func mergeColorButtonTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "mergeColor", sender: nil)
    }
    
    
    @IBAction func mergeIntensityButtonTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "mergeIntensity", sender: nil)
    }
    
    @IBAction func shareButtonTapped(_ sender: Any) {
        
        if self.isSharingDocument {
            let shareMessage = QBChatMessage()
            shareMessage.text = "stopSharing"
            shareMessage.senderID = DGStreamCore.instance.currentUser?.userID?.uintValue ?? 0
            shareMessage.recipientID = self.selectedUser.uintValue
            QBChat.instance.sendSystemMessage(shareMessage, completion: { (error) in
                print("Sent stopSharing System Message With \(error?.localizedDescription ?? "No Error")")
                //self.hideFreezeActivityIndicator()
            })
            self.removePDF()
            self.stopSharing()
        }
        else if self.isSharing {
            if !self.isSharingVideo {
                let shareMessage = QBChatMessage()
                shareMessage.text = "stopSharing"
                shareMessage.senderID = DGStreamCore.instance.currentUser?.userID?.uintValue ?? 0
                shareMessage.recipientID = self.selectedUser.uintValue
                QBChat.instance.sendSystemMessage(shareMessage, completion: { (error) in
                    print("Sent stopSharing System Message With \(error?.localizedDescription ?? "No Error")")
                    //self.hideFreezeActivityIndicator()
                })
            }
            self.stopSharing()
        }
        else if self.isBeingSharedWith {
            let shareMessage = QBChatMessage()
            shareMessage.text = "stopSharing"
            shareMessage.senderID = DGStreamCore.instance.currentUser?.userID?.uintValue ?? 0
            shareMessage.recipientID = self.selectedUser.uintValue
            QBChat.instance.sendSystemMessage(shareMessage, completion: { (error) in
                print("Sent stopSharing System Message With \(error?.localizedDescription ?? "No Error")")
                //self.hideFreezeActivityIndicator()
            })
            self.stopSharing()
        }
        else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.20) {
                
                self.performSegue(withIdentifier: "Media", sender: nil)
                
//                let alert = UIAlertController(title: "Choose Option", message: nil, preferredStyle: .actionSheet)
//                alert.addAction(UIAlertAction(title: "Recordings", style: .default, handler: { (action: UIAlertAction) in
//                    alert.dismiss(animated: false, completion: nil)
//                    self.performSegue(withIdentifier: "Recording", sender: nil)
//                }))
//                alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action: UIAlertAction) in
//                    alert.dismiss(animated: false, completion: nil)
//                    let imagePicker = UIImagePickerController()
//                    imagePicker.delegate = self
//                    imagePicker.sourceType = .photoLibrary
//                    imagePicker.allowsEditing = false
//                    imagePicker.modalPresentationStyle = .popover
//                    imagePicker.popoverPresentationController?.sourceView = self.view
//                    imagePicker.popoverPresentationController?.sourceRect = CGRect(x: self.shareButtonLabel.frame.origin.x + self.shareButtonLabel.frame.size.width / 2, y: self.shareButtonLabel.frame.y, width: self.shareButtonLabel.frame.width, height: 20)
//                    self.present(imagePicker, animated: true) {
//
//
//                    }
//                }))
//                alert.addAction(UIAlertAction(title: "Documents", style: .default, handler: { (action: UIAlertAction) in
//                    alert.dismiss(animated: false, completion: nil)
//                    self.performSegue(withIdentifier: "documents", sender: nil)
//                }))
//                alert.popoverPresentationController?.sourceView = self.view
//                alert.popoverPresentationController?.sourceRect = CGRect(x: self.shareButtonLabel.frame.origin.x + self.shareButtonLabel.frame.size.width / 2, y: self.shareButtonLabel.frame.y, width: self.shareButtonLabel.frame.width, height: 20)
//                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func recordButtonTapped(_ sender: Any) {
        
        if #available(iOS 11.0, *) {
            if self.isRecording {
                self.stopRecording(isEndOfCall: false) {
                    print("STOPPED RECORDING")
                    let message = QBChatMessage()
                    message.text = "recordingStop"
                    message.senderID = UInt(DGStreamCore.instance.currentUser?.userID ?? 0)
                    message.recipientID = self.selectedUser.uintValue
                    QBChat.instance.sendSystemMessage(message, completion: { (error) in
                        
                    })
                }
            }
            else {
                let message = QBChatMessage()
                message.text = "recordingRequest"
                message.senderID = UInt(DGStreamCore.instance.currentUser?.userID ?? 0)
                message.recipientID = self.selectedUser.uintValue
                QBChat.instance.sendSystemMessage(message, completion: { (error) in
                    
                })
            }
        }
        else {
            let alert = UIAlertController(title: "iOS 11 and above only", message: "The recording feature is for iOS 11 and above only. Please install iOS 11 and restart the application.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action: UIAlertAction) in
                alert.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true) {
                
            }
        }
        
    }
    
    func startRecordingTimer() {
        self.showControls()
        if let timer = self.controlTimer {
            timer.invalidate()
            self.controlTimer = nil
        }
        self.controlTimer = Timer.scheduledTimer(withTimeInterval: 2.5, repeats: false) { (timer) in
            if self.isRecording && (self.isDrawing == false || self.callMode == .board) {
                self.hideControls()
            }
        }
    }
    
    @IBAction func drawButtonTapped(_ sender: Any) {
        if self.callMode != .board {
            if self.isDrawing {
                drawEndWith(userID: DGStreamCore.instance.currentUser?.userID ?? 0)
                if self.callMode != .merge {
                    self.hideOptions(animated: false)
                }
            }
            else {
                let currentUserID = DGStreamCore.instance.currentUser?.userID ?? NSNumber.init(value: 0)
                self.startDrawingWith(userID: currentUserID)
            }
        }
        else {
            let clearDrawingsMessage = QBChatMessage()
            clearDrawingsMessage.text = "clearDrawings"
            clearDrawingsMessage.senderID = DGStreamCore.instance.currentUser?.userID?.uintValue ?? 0
            clearDrawingsMessage.recipientID = self.selectedUser.uintValue
            self.clearDrawings()
            QBChat.instance.sendSystemMessage(clearDrawingsMessage, completion: { (error) in
                print("Sent clearDrawingsMessage System Message With \(error?.localizedDescription ?? "No Error")")
            })
        }
    }
    
    @IBAction func whiteBoardButtonTapped(_ sender: Any) {
        
        if self.alertView != nil {
            return
        }
        
        // Hide video
        if self.callMode != .board, let currentUser = DGStreamCore.instance.currentUser, let currentUserID = currentUser.userID, let whiteboardRequestView = UINib(nibName: "DGStreamAlertView", bundle: Bundle(identifier: "com.dataglance.DGStream")).instantiate(withOwner: self, options: nil).first as? DGStreamAlertView {
            
            whiteboardRequestView.configureFor(mode: .whiteboardRequest, fromUsername: nil, message: NSLocalizedString("Waiting for response...", comment: ""),isWaiting: true)
            self.alertView = whiteboardRequestView
            DGStreamManager.instance.waitingForResponse = .board
            whiteboardRequestView.presentWithin(viewController: self, block: { (accepted) in })
            
            let mergeRequestMessage = QBChatMessage()
            mergeRequestMessage.text = "whiteboardRequest"
            mergeRequestMessage.senderID = currentUserID.uintValue
            mergeRequestMessage.recipientID = self.selectedUser.uintValue
            
            QBChat.instance.sendSystemMessage(mergeRequestMessage, completion: { (error) in
                print("Sent Merge System Message With \(error?.localizedDescription ?? "No Error")")
                if error != nil {
                    whiteboardRequestView.dismiss()
                    
                    let message = DGStreamMessage()
                    message.message = "Whiteboard failed."
                    message.isSystem = true
                    self.chatPeekView.addCellWith(message: message)
                }
            })
        }
        else {
            //hideDropDown(animated: true)
            endWhiteBoard(sendNotification: true)
        }
    }
    
    @IBAction func mergeButtonTapped(_ sender: Any) {
        if self.alertView != nil {
            return
        }
        var toEnd:Bool = false
        if callMode == .merge {
            toEnd = true
        }
        tapped(forMerge: true, toEnd: toEnd)
    }
    
    @IBAction func perspectiveButtonTapped(_ sender: UIButton) {
        
        if self.alertView != nil {
            return
        }
        
        var toEnd:Bool = false
        if callMode == .perspective {
            toEnd = true
        }
        tapped(forMerge: false, toEnd: toEnd)
    }
    
    func perspectiveAccepted() {
        // As accepted by other user
        //self.returnToStreamMode(hideModeButtons: false)
        self.isCurrentUserPerspective = true
        self.start(mode: .perspective)
    }
    
    func acceptedPerspective() {
        // Current User accepted, Update UI
        if let alert = self.alertView {
            alert.dismiss()
            self.alertView = nil
        }
        if let alert = self.alertRequestWaitingView {
            alert.dismiss()
            self.alertRequestWaitingView = nil
        }
        self.isCurrentUserPerspective = false
        self.start(mode: .perspective)
        
        var userName = "Unknown"
        if let user = DGStreamCore.instance.getOtherUserWith(userID: self.selectedUser), let username = user.username {
            userName = username
        }
        
        if userName.hasSuffix("s") {
            userName.append("'")
        }
        else {
            userName.append("'s")
        }
        
        let systemMessage = DGStreamMessage()
        systemMessage.isSystem = true
        systemMessage.message = "Viewing \(userName) Perspective."
        self.chatPeekView.addCellWith(message: systemMessage)
        
        UIView.animate(withDuration: 0.18) {
            self.perspectiveButton.tintColor = UIColor.dgMergeMode()
            self.perspectiveButton.layer.borderColor = UIColor.dgMergeMode().cgColor
            self.perspectiveButtonLabel.textColor = UIColor.dgMergeMode()
            self.statusBar.backgroundColor = UIColor.dgMergeMode()
        }
    }
    
    func requestDeclined() {
        if let alert = self.alertView {
            alert.dismiss()
            self.alertView = nil
        }
        if let alert = self.alertRequestWaitingView {
            alert.dismiss()
            self.alertRequestWaitingView = nil
        }
        let perspectiveDeclinedMessage = DGStreamMessage()
        perspectiveDeclinedMessage.isSystem = true
        perspectiveDeclinedMessage.message = "Request Declined."
    }
    
    func perspectiveEnded() {
        if self.callMode == .perspective {
            let systemMessage = DGStreamMessage()
            systemMessage.isSystem = true
            systemMessage.message = "Perspective ended."
            self.chatPeekView.addCellWith(message: systemMessage)
            self.isCurrentUserPerspective = false
            self.returnToStreamMode(hideModeButtons: true)
        }
        
    }
    
    func tapped(forMerge: Bool, toEnd: Bool) {
        
        var modeString = "perspective"
        var alertMode:AlertMode = .perspectiveRequest
        if forMerge {
            modeString = "merge"
            alertMode = .mergeRequest
        }
        
        if toEnd {
            if let currentUser = DGStreamCore.instance.currentUser, let currentUserID = currentUser.userID {
                
                let unmergeMessage = QBChatMessage()
                unmergeMessage.text = "\(modeString)End"
                unmergeMessage.senderID = currentUserID.uintValue
                unmergeMessage.recipientID = self.selectedUser.uintValue
                
                QBChat.instance.sendSystemMessage(unmergeMessage, completion: { (error) in
                    print("Sent \(modeString)End System Message With \(error?.localizedDescription ?? "No Error")")
                })
            }
            returnToStreamMode(hideModeButtons: true)
        }
        else {
            
            // Send push notification that asks the helper to merge with their reality
            if let currentUser = DGStreamCore.instance.currentUser, let currentUserID = currentUser.userID, let mergeRequestView = UINib(nibName: "DGStreamAlertView", bundle: Bundle(identifier: "com.dataglance.DGStream")).instantiate(withOwner: self, options: nil).first as? DGStreamAlertView {
                self.alertView = mergeRequestView
                mergeRequestView.configureFor(mode: alertMode, fromUsername: nil, message: NSLocalizedString("Waiting for response...", comment: ""),isWaiting: true)
//                if forMerge {
//                    self.alertRequestWaitingView = mergeRequestView
//                }
//                else {
//                    self.alertView = mergeRequestView
//                }
                DGStreamManager.instance.waitingForResponse = .merge
                mergeRequestView.presentWithin(viewController: self, block: { (accepted) in })
                
                let customParams = NSMutableDictionary()
                customParams["ScreenWidth"] = "\(UIScreen.main.bounds.size.width)"
                customParams["ScreenHeight"] = "\(UIScreen.main.bounds.size.height)"
                
                let mergeRequestMessage = QBChatMessage()
                mergeRequestMessage.text = "\(modeString)Request"
                mergeRequestMessage.senderID = currentUserID.uintValue
                mergeRequestMessage.recipientID = self.selectedUser.uintValue
                mergeRequestMessage.customParameters = customParams
                
                if forMerge {
                    self.isMergeHelper = false
                }
                else {
                    self.isCurrentUserPerspective = true
                }
                
                QBChat.instance.sendSystemMessage(mergeRequestMessage, completion: { (error) in
                    print("Sent Merge System Message With \(error?.localizedDescription ?? "No Error")")
                    if error != nil {
                        mergeRequestView.dismiss()
                        
                        let message = DGStreamMessage()
                        message.message = "\(modeString) failed."
                        message.isSystem = true
                        self.chatPeekView.addCellWith(message: message)
                    }
                })
            }
        }
    }
    
    @IBAction func hangUpButtonTapped(_ sender: Any) {
        self.session?.hangUp(["hangup" : "hang up"])
        self.session = nil
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.20) {
            self.closeOut()
        }
    }
    
    func closeOut() {
        
        QBRTCClient.instance().remove(self)
        QBRTCAudioSession.instance().removeDelegate(self)
        if QBRTCAudioSession.instance().isInitialized {
            QBRTCAudioSession.instance().deinitialize()
        }
        
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
        if self.isAudioCall == false {
            if let lv = self.localBroadcastView {
                lv.deconfigure()
                self.localBroadcastView = nil
            }
            self.cameraCapture = nil
            self.assetWriterVideoInput = nil
            self.assetWriter = nil
            self.isRecording = false
        }
        if self.session?.state == .closed {
//            self.session?.hangUp(["hangup" : "hang up"])
//            self.session = nil
        }
        if let tab = self.navigationController?.viewControllers.first {
            DGStreamCore.instance.presentedViewController = nil
            DGStreamCore.instance.presentedViewController = tab
        }
        if let nav = self.navigationController {
            nav.popViewController(animated: false)
        }
        else {
            self.dismiss(animated: false, completion: nil)
        }
        UIDevice.current.endGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIDeviceOrientationDidChange, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillShow, object: nil)
    }
    
    func freeze() {
        
        // Other device has frozen the screen. This would be your screen.
        
        if let image = DGStreamScreenCapture.snapshot(view: self.remoteVideoViewContainer) {
            self.freezeFrame = image
            
            self.freezeImageView = UIImageView(frame: self.remoteVideoViewContainer.bounds)
            self.freezeImageView?.boundInside(container: self.remoteVideoViewContainer)
            self.freezeImageView?.image = self.freezeFrame
            
            self.orderDrawViews()
            
            self.isFrozen = true
            
            self.freezeButton.tintColor = UIColor.dgMergeMode()
            self.freezeButton.setTitleColor(UIColor.dgMergeMode(), for: .normal)
            self.freezeButton.backgroundColor = .white
            
            if let user = DGStreamCore.instance.getOtherUserWith(userID: self.selectedUser), let username = user.username {
                let message = DGStreamMessage()
                message.message = "\(username) has frozen the screen."
                message.isSystem = true
                self.chatPeekView.addCellWith(message: message)
            }
        
        }
        
    }
    
    func unfreeze() {
        DispatchQueue.main.async {
            
            if self.isDrawing {
                self.drawEndWith(userID: DGStreamCore.instance.currentUser?.userID ?? 0)
            }
            
            if self.callMode == .merge {
                //self.localBroadcastView?.alpha = 0.5
            }
            else if self.callMode == .perspective {
                if self.isCurrentUserPerspective {
                    self.localBroadcastView?.alpha = 1.0
                }
                else {
                    self.localBroadcastView?.alpha = 0
                }
            }
            else {
                
                self.localBroadcastView?.alpha = 1.0
            }
            self.freezeFrame = nil
            self.isFrozen = false
//            self.changedFreeze()
            self.freezeButton.setTitleColor(.white, for: .normal)
            self.freezeButton.tintColor = .white
            self.freezeButton.backgroundColor = .clear
            self.freezeImageView?.alpha = 0
            self.freezeImageView?.removeFromSuperview()
            self.freezeImageView?.image = nil
        }
    }
    
    @IBAction func freezeButtonTapped(_ sender: Any) {
        if self.isFrozen {
            if self.callMode == .merge {
                //self.localBroadcastView?.alpha = 0.5
            }
            else if self.callMode == .perspective {
                if self.isCurrentUserPerspective {
                    self.localBroadcastView?.alpha = 1.0
                }
                else {
                    self.localBroadcastView?.alpha = 0.0
                }
            }
            else {
                self.localBroadcastView?.alpha = 1.0
            }
    
            self.freezeButton.setTitleColor(.white, for: .normal)
            self.freezeButton.tintColor = .white
            self.freezeButton.backgroundColor = .clear
            self.freezeFrame = nil
            self.freezeImageView?.alpha = 0
            self.freezeImageView?.removeFromSuperview()
            self.freezeImageView = nil
            self.isFrozen = false
            let unfreezeMessage = QBChatMessage()
            unfreezeMessage.text = "unfreeze"
            unfreezeMessage.senderID = DGStreamCore.instance.currentUser?.userID?.uintValue ?? 0
            unfreezeMessage.recipientID = self.selectedUser.uintValue
            QBChat.instance.sendSystemMessage(unfreezeMessage, completion: { (error) in
                print("Sent Unfreeze System Message With \(error?.localizedDescription ?? "No Error")")
                //self.hideFreezeActivityIndicator()
            })
        }
        else {
            
            DispatchQueue.main.async {
                
                if let image = DGStreamScreenCapture.snapshot(view: self.remoteVideoViewContainer) {
                    self.freezeFrame = image
                    
                    self.freezeImageView = UIImageView(frame: self.remoteVideoViewContainer.bounds)
                    self.freezeImageView?.boundInside(container: self.remoteVideoViewContainer)
                    self.freezeImageView?.image = self.freezeFrame
                    
                    self.orderDrawViews()
                    
                    self.isFrozen = true
                    
                    self.freezeButton.tintColor = UIColor.dgMergeMode()
                    self.freezeButton.setTitleColor(UIColor.dgMergeMode(), for: .normal)
                    self.freezeButton.backgroundColor = .white
                    
                    let freezeMessage = QBChatMessage()
                    freezeMessage.text = "freeze"
                    freezeMessage.senderID = DGStreamCore.instance.currentUser?.userID?.uintValue ?? 0
                    freezeMessage.recipientID = self.selectedUser.uintValue
                    //freezeMessage.customParameters = ["instruction": instruction]
                    QBChat.instance.sendSystemMessage(freezeMessage, completion: { (error) in
                        print("Sent Unfreeze System Message With \(error?.localizedDescription ?? "No Error")")
                        //self.hideFreezeActivityIndicator()
                    })
                }
            }
        }
    }
    
    @IBAction func snapshotButtonTapped(_ sender: Any) {
        if let snap = DGStreamScreenCapture.snapshot(view: self.view) {
//            let photoSaver = DGStreamPhotoSaver()
//            photoSaver.delegate = self
//            photoSaver.save(snap)
            
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
            
            if let data = UIImageJPEGRepresentation(snap, 1.0),
                !FileManager.default.fileExists(atPath: path.path) {
                do {
                    // writes the image data to disk
                    try data.write(to: path)
                    print("file saved")
                } catch {
                    print("error saving file:", error)
                }
            }
            
            saveRecordingsWith(fileName: recordingTitle, thumbnail: UIImageJPEGRepresentation(snap, 0.5))
            self.finishedTakingSnapshot(forVideoCover: false)
        }
    }
    
    func finishedTakingSnapshot(forVideoCover: Bool) {
        // If not for video cover then we are just taking a snapshot
        var text = ""
        if forVideoCover {
            text = "Saved Video To Media"
        }
        else {
            text = "Saved Photo To Media"
        }
        self.savedPhotoLabel.text = text
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
        self.chatButton.tintColor = UIColor.dgBlueDark()
        self.chatButtonContainer.layer.borderColor = UIColor.dgBlueDark().cgColor
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
    
    @IBAction func showHideButtonsButtonTapped(_ sender: Any) {
        self.toggleControls()
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        if isSettingText {
            endSettingText(cancelled: false)
        }
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        
        if self.isRecording {
            self.stopRecording(isEndOfCall: false) {
                print("STOPPED RECORDING")
                let message = QBChatMessage()
                message.text = "recordingStop"
                message.senderID = UInt(DGStreamCore.instance.currentUser?.userID ?? 0)
                message.recipientID = self.selectedUser.uintValue
                QBChat.instance.sendSystemMessage(message, completion: { (error) in
                    
                })
            }
        }
        else if self.isSharingDocument {
            let shareMessage = QBChatMessage()
            shareMessage.text = "stopSharing"
            shareMessage.senderID = DGStreamCore.instance.currentUser?.userID?.uintValue ?? 0
            shareMessage.recipientID = self.selectedUser.uintValue
            QBChat.instance.sendSystemMessage(shareMessage, completion: { (error) in
                print("Sent stopSharing System Message With \(error?.localizedDescription ?? "No Error")")
                //self.hideFreezeActivityIndicator()
            })
            self.stopSharing()
        }
        else if self.isSettingText {
            self.endSettingText(cancelled: true)
        }
        else if self.callMode == .board {
            endWhiteBoard(sendNotification: true)
        }
        else if self.callMode == .merge  {
            if let currentUser = DGStreamCore.instance.currentUser, let currentUserID = currentUser.userID {
                
                let unmergeMessage = QBChatMessage()
                unmergeMessage.text = "mergeEnd"
                unmergeMessage.senderID = currentUserID.uintValue
                unmergeMessage.recipientID = self.selectedUser.uintValue
                
                QBChat.instance.sendSystemMessage(unmergeMessage, completion: { (error) in
                    print("Sent mergeEnd System Message With \(error?.localizedDescription ?? "No Error")")
                })
                
            }
            returnToStreamMode(hideModeButtons: true)
        }
        else if self.callMode == .perspective {
            if let currentUser = DGStreamCore.instance.currentUser, let currentUserID = currentUser.userID {
                
                let unmergeMessage = QBChatMessage()
                unmergeMessage.text = "perspectiveEnd"
                unmergeMessage.senderID = currentUserID.uintValue
                unmergeMessage.recipientID = self.selectedUser.uintValue
                
                QBChat.instance.sendSystemMessage(unmergeMessage, completion: { (error) in
                    print("Sent mergeEnd System Message With \(error?.localizedDescription ?? "No Error")")
                })
                
            }
            returnToStreamMode(hideModeButtons: true)
        }
        else if self.isDrawing {
            self.drawEndWith(userID: DGStreamCore.instance.currentUser?.userID ?? 0)
        }
    
    }
    
    @IBAction func blackoutCancelButtonTapped(_ sender: Any) {
        self.closeOut()
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
    }
    
    func start(mode: CallMode) {
        
        DispatchQueue.main.async {
            
            self.dismissPopover()
            
            if self.drawingUsers.contains(DGStreamCore.instance.currentUser?.userID ?? 0) {
                self.drawEndWith(userID: DGStreamCore.instance.currentUser?.userID ?? 0)
            }
            
            if self.drawingUsers.contains(self.selectedUser) {
                self.drawEndWith(userID: self.selectedUser)
            }
            
            self.endWhiteBoard(sendNotification: false)
            
            if mode == .merge {
                if self.isMergeHelper {
                    self.stopSharing()
                    self.disableDrawButtons()
                    self.enableMergeButtons()
                    self.showOptions()
                }
            }
            else if let recordingView = self.recordingView {
                recordingView.alpha = 0
            }
            
            if self.isFrozen {
                self.freezeButtonTapped(self)
            }
            
            if let alertView = self.alertView {
                alertView.dismiss()
                self.alertView = nil
            }
            
            if let alertVew = self.alertRequestWaitingView {
                alertVew.dismiss()
                self.alertRequestWaitingView = nil
            }
            
            print("\n\nStart Merge For Helper\n\n")
                        
            self.statusBarBackButton.setTitle(NSLocalizedString("Cancel", comment: "Stop action"), for: .normal)
            
            var button:UIButton
            var otherButtons:[UIButton] = []
            let container: UIView!
            var otherContainers:[UIView] = []
            var label:UILabel
            var otherLabels:[UILabel] = []
            if mode == .merge {
                button = self.mergeButton
                otherButtons = [self.perspectiveButton, self.whiteBoardButton]
                container = self.mergeButtonContainer
                otherContainers = [self.perspectiveButtonContainer, self.whiteBoardButtonContainer]
                label = self.mergeButtonLabel
                otherLabels = [self.perspectiveButtonLabel, self.whiteBoardButtonLabel]
            }
            else {
                button = self.perspectiveButton
                otherButtons = [self.mergeButton, self.whiteBoardButton]
                container = self.perspectiveButtonContainer
                otherContainers = [self.mergeButtonContainer, self.whiteBoardButtonContainer]
                label = self.perspectiveButtonLabel
                otherLabels = [self.mergeButtonLabel, self.whiteBoardButtonLabel]
            }
            
            UIView.animate(withDuration: 0.18) {
                label.textColor = UIColor.dgMergeMode()
                button.tintColor = UIColor.dgMergeMode()
                container.layer.borderColor = UIColor.dgMergeMode().cgColor
                for button in otherButtons {
                    button.tintColor = UIColor.dgBlueDark()
                }
                for container in otherContainers {
                    container.layer.borderColor = UIColor.dgBlueDark().cgColor
                }
                for label in otherLabels {
                    label.textColor = UIColor.dgBlueDark()
                }
                self.statusBar.backgroundColor = UIColor.dgMergeMode()
            }
            
            // End previous merge
            if self.callMode == .merge {
                let isPerspective = mode == .perspective
                self.endMerge(forPerspective: isPerspective)
            }
            
            if mode == .merge {
                if self.isMergeHelper {
                    self.shareButton.isEnabled = false
                    self.shareButton.tintColor = UIColor.lightGray
                    self.shareButtonContainer.layer.borderColor = UIColor.lightGray.cgColor
                    self.shareButton.setTitleColor(UIColor.lightGray, for: .normal)
                    self.shareButtonLabel.textColor = .lightGray
                    self.setUpLocalVideoViewIn(container: self.remoteVideoViewContainer, isFront: false, isChromaKey: true)
                }
                else {
                    self.setUpLocalVideoViewIn(container: self.remoteVideoViewContainer, isFront: false, isChromaKey: false)
                    self.localBroadcastView?.isHidden = true
                }
            }
            else {
                self.localBroadcastView?.stopChromaKey()
                if self.isCurrentUserPerspective {
                    // Place Local Video On Top of Remote
                    self.setUpLocalVideoViewIn(container: self.remoteVideoViewContainer, isFront: false, isChromaKey: false)
                    self.localBroadcastView?.alpha = 1.0
                }
                else {
                    self.localBroadcastView?.alpha = 0.0
                }
            }
            
            if let freezeImageView = self.freezeImageView {
                self.remoteVideoViewContainer.insertSubview(freezeImageView, aboveSubview: self.remoteVideoViewContainer)
            }
            
            if let remoteVideo = self.videoViewWith(userID: self.selectedUser) as? QBRTCRemoteVideoView {
                remoteVideo.alpha = 1
                remoteVideo.videoGravity = AVLayerVideoGravityResizeAspect
            }
            
            self.drawButton.isEnabled = true
            self.freezeButton.isEnabled = true
            
            self.orderDrawViews()
            
            self.callMode = mode
        }
        
    }
    
    func endMerge(forPerspective: Bool) {
        self.localBroadcastView?.stopChromaKey()
        self.screenCapture = nil
        if self.isMergeHelper {
            self.localBroadcastView?.boundInside(container: self.localVideoViewContainer)
        }
        else if self.isBeingSharedWithVideo {
            self.recordingView?.alpha = 1
        }
        
        if forPerspective {
            if self.isCurrentUserPerspective {
                self.setUpLocalVideoViewIn(container: self.remoteVideoViewContainer, isFront: false, isChromaKey: false)
                self.localBroadcastView?.isHidden = false
            }
            else {
                self.setUpLocalVideoViewIn(container: self.localVideoViewContainer, isFront: true, isChromaKey: false)
                self.localBroadcastView?.isHidden = true
            }
        }
        else {
            self.setUpLocalVideoViewIn(container: self.localVideoViewContainer, isFront: true, isChromaKey: false)
        }
        
        if !self.isSharing || !self.isSharingVideo || !self.isBeingSharedWith || !self.isBeingSharedWithVideo {
            self.shareButton.isEnabled = true
            self.shareButton.tintColor = UIColor.dgBlueDark()
            self.shareButtonContainer.layer.borderColor = UIColor.dgBlueDark().cgColor
            self.shareButton.setTitleColor(UIColor.dgBlueDark(), for: .normal)
            self.shareButtonLabel.textColor = UIColor.dgBlueDark()
        }
        self.freezeImageView?.removeFromSuperview()
        self.freezeImageView = nil
    }
    
    func returnToStreamMode(hideModeButtons: Bool) {
        
        if self.screenCapture != nil {
            self.screenCapture = nil
            self.session?.localMediaStream.videoTrack.videoCapture = self.localVideoCapture
        }
        
        DGStreamCore.instance.audioPlayer.stopAllSounds()
        
        self.latestRemotePageIncrement = 0
        
        if self.isFrozen {
            self.freezeButtonTapped(self)
        }
        
        if self.drawingUsers.contains(DGStreamCore.instance.currentUser?.userID ?? 0) {
            self.drawEndWith(userID: DGStreamCore.instance.currentUser?.userID ?? 0)
        }
        if self.drawingUsers.contains(self.selectedUser) {
            self.drawEndWith(userID: self.selectedUser)
        }
        
        self.hideOptions(animated: false)
        
        UIView.animate(withDuration: 0.18) {
            self.mergeButtonLabel.textColor = UIColor.dgBlueDark()
            self.mergeButton.tintColor = UIColor.dgBlueDark()
            self.mergeButtonContainer.layer.borderColor = UIColor.dgBlueDark().cgColor
            self.mergeButton.isEnabled = true
            self.perspectiveButtonLabel.textColor = UIColor.dgBlueDark()
            self.perspectiveButton.tintColor = UIColor.dgBlueDark()
            self.perspectiveButtonContainer.layer.borderColor = UIColor.dgBlueDark().cgColor
            self.perspectiveButton.isEnabled = true
            self.drawButton.tintColor = .white
            self.drawButton.backgroundColor = .clear
            self.drawButton.isEnabled = false
            self.freezeButton.isEnabled = false
            self.whiteBoardButtonLabel.textColor = UIColor.dgBlueDark()
            self.whiteBoardButton.tintColor = UIColor.dgBlueDark()
            self.whiteBoardButtonContainer.layer.borderColor = UIColor.dgBlueDark().cgColor
            
            if !self.isSharing || !self.isSharingVideo || !self.isBeingSharedWith || !self.isBeingSharedWithVideo {
                self.shareButtonLabel.textColor = UIColor.dgBlueDark()
                self.shareButton.tintColor = UIColor.dgBlueDark()
                self.shareButtonContainer.layer.borderColor = UIColor.dgBlueDark().cgColor
                self.shareButton.isEnabled = true
            }
            
            self.statusBar.backgroundColor = UIColor.dgBlueDark()
            self.statusBarBackButton.alpha = 0
            self.statusBarDoneButton.alpha = 0
            if self.isSharingVideo || self.isBeingSharedWithVideo {
                self.recordingView?.alpha = 1
            }
        }
        
        if let alert = self.alertView {
            alert.dismiss()
            self.alertView = nil
        }
        
        if let alert = self.alertRequestWaitingView {
            alert.dismiss()
            self.alertRequestWaitingView = nil
        }
        
        self.dismissPopover()
        
        if self.callMode == .merge {
            self.endMerge(forPerspective: false)
        }
        
        if self.isRecording {
            self.stopRecording(isEndOfCall: false) {
                
            }
        }
        
        // Switch current device to merge mode
        self.setUpLocalVideoViewIn(container: self.localVideoViewContainer, isFront: true, isChromaKey: false)
        
        if let remoteVideo = self.videoViewWith(userID: self.selectedUser) as? QBRTCRemoteVideoView {
            remoteVideo.alpha = 1
            remoteVideo.videoGravity = AVLayerVideoGravityResizeAspect//AVLayerVideoGravityResizeAspect
        }
        
        if let localDrawView = self.localDrawImageView {
            self.view.bringSubview(toFront: localDrawView)
        }
        
        if let remoteDrawView = self.remoteDrawImageView {
            self.view.bringSubview(toFront: remoteDrawView)
        }
        
        if let jotVC = self.jotVC {
            self.view.bringSubview(toFront: jotVC.view)
        }
        
        self.localVideoViewContainer.isHidden = false
        self.localVideoViewContainer.alpha = 1
        
        DGStreamCore.instance.flipCamera(toFront: true)
        
        self.isCurrentUserPerspective = false
        
        self.callMode = .stream
        
    }
    
    //MARK:- Orientation
    
    func shouldAutorotateToInterfaceOrientation(interfaceOrientation: UIInterfaceOrientation) -> Bool {
        
        // Native video orientation is landscape with the button on the right.
        // The video processor rotates vide as needed, so don't autorotate also
        return interfaceOrientation == UIInterfaceOrientation.landscapeRight
    }
    
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        if let touch = touches.first {
//            let touchPoint = touch.location(in: self.view)
//            if self.statusBar.frame.contains(touchPoint), let jot = self.jotVC {
//                jot.view.gestureRecognizers
//            }
//        }
    }
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if !self.isSettingText, self.isDrawing || self.callMode == .board && self.didTapDropDownContainer == false {
            sendDrawing(image: nil, isUndo: false)
        }
        self.didTapDropDownContainer = false
    }
    
    //MARK:- Draw Mode
    
//    func startDrawMode(session: QBRTCSession?) {
//
//        if let session = session {
//            // INCOMING
//            self.drawSession = session
//            self.drawSession?.acceptCall(nil)
//        }
//        else {
//            // NEW
//            self.drawSession = QBRTCClient.instance().createNewSession(withOpponents: [self.selectedUser], with: .video)
//            let userInfo:[String: String] = ["username": DGStreamCore.instance.currentUser?.username ?? "Unknown", "url": "http.quickblox.com", "param": "dev"]
//            self.drawSession?.startCall(userInfo)
//        }
//
//        if self.drawCapture == nil, let jot = self.jotVC {
//            self.drawCapture = DGStreamScreenCapture(view: jot.view)
//            self.drawSession?.localMediaStream.videoTrack.videoCapture = self.drawCapture
//
//            self.drawTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { (timer) in
//                self.processDrawImage()
//            })
//        }
//
//    }
    
//    func processDrawImage() {
//
//        if let remote = self.remoteDrawView {
//            let background = CIImage(image: UIImage(named: "gsBackground")!)
//            let forground = CIImage(image: DGStreamScreenCapture(view: remote).screenshot()!)
//
//            let chromaCIFilter = self.chromaKeyFilter(fromHue: 0.2, toHue: 0.5)
//            chromaCIFilter?.setValue(forground, forKey: kCIInputImageKey)
//            let sourceCIImageWithoutBackground = chromaCIFilter?.outputImage
//
//            let compositor = CIFilter(name:"CISourceOverCompositing")
//            compositor?.setValue(sourceCIImageWithoutBackground, forKey: kCIInputImageKey)
//            compositor?.setValue(background, forKey: kCIInputBackgroundImageKey)
//            let compositedCIImage = compositor?.outputImage
//
//            self.drawView?.image = UIImage(ciImage: compositedCIImage!)
//            self.view.bringSubview(toFront: self.drawView!)
//        }
//
//    }
    
    func chromaKeyFilter(fromHue: CGFloat, toHue: CGFloat) -> CIFilter?
    {
        // 1
        let size = 64
        var cubeRGB = [Float]()
        
        // 2
        for z in 0 ..< size {
            let blue = CGFloat(z) / CGFloat(size-1)
            for y in 0 ..< size {
                let green = CGFloat(y) / CGFloat(size-1)
                for x in 0 ..< size {
                    let red = CGFloat(x) / CGFloat(size-1)
                    
                    // 3
                    let hue = getHue(red: red, green: green, blue: blue)
                    let alpha: CGFloat = (hue >= fromHue && hue <= toHue) ? 0: 1
                    
                    // 4
                    cubeRGB.append(Float(red * alpha))
                    cubeRGB.append(Float(green * alpha))
                    cubeRGB.append(Float(blue * alpha))
                    cubeRGB.append(Float(alpha))
                }
            }
        }
        
        let data = Data(buffer: UnsafeBufferPointer(start: &cubeRGB, count: cubeRGB.count))
        
        // 5
        let colorCubeFilter = CIFilter(name: "CIColorCube", withInputParameters: ["inputCubeDimension": size, "inputCubeData": data])
        return colorCubeFilter
    }
    
    func getHue(red: CGFloat, green: CGFloat, blue: CGFloat) -> CGFloat
    {
        let color = UIColor(red: red, green: green, blue: blue, alpha: 1)
        var hue: CGFloat = 0
        color.getHue(&hue, saturation: nil, brightness: nil, alpha: nil)
        return hue
    }
    
    func enableMergeButtons() {
        let enabledColor = UIColor.dgBlueDark()
        let enabledTintColor = UIColor.white
        let enableButtons = [self.mergeColorButton, self.mergeIntensityButton]
        for button in enableButtons {
            guard let b = button else { continue }
            b.backgroundColor = enabledColor
            b.isEnabled = true
            if b == self.mergeColorButton {
                b.tintColor = self.mergeOptionColor
            }
            else {
                b.tintColor = enabledTintColor
                b.setTitleColor(enabledTintColor, for: .normal)
                b.titleLabel?.textColor = enabledTintColor
            }
        }
    }
    
    func disableMergeButtons() {
        let disabledColor = UIColor.gray
        let disabledTintColor = UIColor.lightGray
        let disableButtons = [self.mergeColorButton, self.mergeIntensityButton]
        for button in disableButtons {
            guard let b = button else { continue }
            b.setTitleColor(disabledTintColor, for: .normal)
            b.tintColor = disabledTintColor
            b.backgroundColor = disabledColor
            b.isEnabled = false
        }
    }
    
    func enableDrawButtons() {
        self.selectColorCollectionView.alpha = 1
        self.selectColorDisabledLabel.alpha = 0
        self.selectSizeCollectionView.alpha = 1
        self.selectSizeDisabledLabel.alpha = 0
        let enabledColor = UIColor.dgBlueDark()
        let enabledTintColor = UIColor.white
        let enableButtons = [self.stampsButton, self.undoButton, self.clearAllButton]
        for button in enableButtons {
            guard let b = button else { continue }
            b.tintColor = enabledTintColor
            b.backgroundColor = enabledColor
            b.isEnabled = true
            if b == self.stampsButton {
                b.setTitleColor(.white, for: .normal)
                b.titleLabel?.textColor = .white
            }
        }
    }
    
    func disableDrawButtons() {
        self.selectColorCollectionView.alpha = 0
        self.selectColorDisabledLabel.alpha = 1
        self.selectSizeCollectionView.alpha = 0
        self.selectSizeDisabledLabel.alpha = 1
        let disabledColor = UIColor.gray
        let disabledTintColor = UIColor.lightGray
        let disableButtons = [self.stampsButton, self.undoButton, self.clearAllButton]
        for button in disableButtons {
            guard let b = button else { continue }
            b.tintColor = disabledTintColor
            b.backgroundColor = disabledColor
            b.isEnabled = false
            if b == self.stampsButton {
                b.setTitleColor(.lightGray, for: .normal)
                b.titleLabel?.textColor = .lightGray
            }
        }
    }
    
    func hasDrawings() -> Bool {
        if let remote = self.remoteDrawImageView, remote.tag > 0 {
            return true
        }
        else if let local = self.localDrawImageView, local.tag > 0 {
            return true
        }
        else {
            return false
        }
    }
    
    func startDrawingWith(userID: NSNumber) {
        
        // Flag user as a drawing user
        if !self.drawingUsers.contains(userID) {
            self.drawingUsers.append(userID)
        }

        // If they are the selected user, change the UI
        if userID == self.selectedUser {
            if let user = DGStreamCore.instance.getOtherUserWith(userID: userID), let username = user.username {
                let message = DGStreamMessage()
                message.message = "\(username) has started drawing."
                message.isSystem = true
                self.chatPeekView.addCellWith(message: message)
            }
        }
        // If they are current user, enter draw mode
        else if let currentUser = DGStreamCore.instance.currentUser, let currentUserID = currentUser.userID, userID == currentUserID {
            self.isDrawing = true
                        
            let drawStartMessage = QBChatMessage()
            drawStartMessage.text = "drawStart"
            drawStartMessage.senderID = currentUserID.uintValue
            drawStartMessage.recipientID = self.selectedUser.uintValue
            
            QBChat.instance.sendSystemMessage(drawStartMessage) { (error) in
                print("Sent Draw Start System Message With \(error?.localizedDescription ?? "No Error")")
                if error != nil {
                    //self.drawFailedWith(errorMessage: error?.localizedDescription ?? "Error")
                }
            }
            
            UIView.animate(withDuration: 0.25, animations: {
                self.drawButton.layer.borderColor = UIColor.dgMergeMode().cgColor
                self.drawButton.tintColor = UIColor.dgMergeMode()
                self.drawButton.backgroundColor = .white
                self.statusBar.backgroundColor = UIColor.dgMergeMode()
                self.statusBarBackButton.setTitle(NSLocalizedString("Cancel", comment: "Stop action"), for: .normal)
                self.enableDrawButtons()
                self.showOptions()
            })
            
            if let jot = self.jotVC {
                jot.view.isUserInteractionEnabled = true
            }
            
        }
        
        if let jot = self.jotVC {
            self.remoteVideoViewContainer.bringSubview(toFront: jot.view)
        }
        
    }
    
    func drawEndWith(userID: NSNumber) {
        if let currentUser = DGStreamCore.instance.currentUser, let currentUserID = currentUser.userID, userID == currentUserID {
            
            let drawEndMessage = QBChatMessage()
            drawEndMessage.text = "drawEnd"
            drawEndMessage.senderID = DGStreamCore.instance.currentUser?.userID?.uintValue ?? 0
            drawEndMessage.recipientID = self.selectedUser.uintValue
            
            QBChat.instance.sendSystemMessage(drawEndMessage) { (error) in
                print("Sent Draw End System Message With \(error?.localizedDescription ?? "No Error")")
            }
            
            if self.callMode == .board {
                self.callMode = .stream
            }
            
            if self.isRecording {
                self.startRecordingTimer()
            }
            
            UIView.animate(withDuration: 0.18) {
                self.drawButton.tintColor = .white
                self.drawButton.backgroundColor = .clear
                self.disableDrawButtons()
                if self.callMode == .stream {
                    self.hideOptions(animated: false)
                }
            }
            
            self.isDrawing = false
            
            if let jot = self.jotVC {
                jot.clearAll()
                jot.view.isUserInteractionEnabled = false
            }
            
            self.removeDrawViewsFor(userID: DGStreamCore.instance.currentUser?.userID ?? 0)
            
            if !self.drawingUsers.contains(self.selectedUser) && self.callMode == .board {
                self.removeDrawViewsFor(userID: self.selectedUser)
            }
            
        }
        else {
            self.whiteBlendView?.alpha = 0.20
            self.blackBlendView?.alpha = 0.20
            self.removeDrawViewsFor(userID: self.selectedUser)
        }
        
        if let index = self.drawingUsers.index(of: userID) {
            self.drawingUsers.remove(at: index)
        }
        
    }
    
    func sendDrawing(image: UIImage?, isUndo: Bool) {
        if let currentUser = DGStreamCore.instance.currentUser, let currentUserID = currentUser.userID, let fileID = UUID().uuidString.components(separatedBy: "-").first {
            
            var snapshot:UIImage?
            if let image = image {
                snapshot = image
            }
            else if let jot = self.jotVC, let image = jot.renderImage() {
                snapshot = image
            }
            
            guard let sendImage = snapshot else {return}
            
            guard let theImage = self.drawLocal(image: sendImage, isFromUndo: isUndo) else {return}
            self.localDrawIncrement += 1
            self.drawOperationQueue.addDrawing(snapshot: theImage, fromCurrentUser: currentUserID, toUsers: [self.selectedUser], isUndo: isUndo, withFileID: fileID)
            if let jot = jotVC {
                jot.clearDrawing()
                jot.clearText()
                jot.clearAll()
            }
        }
    }
    
    func drawWithImage(id: Int, data: Data) {
        
        self.latestRemoteDrawID = id
        
        guard let image = UIImage(data: data) else { return }
        
        DispatchQueue.main.async {
            if let remoteDraw = self.remoteDrawImageView {
                remoteDraw.image = image
                remoteDraw.tag = remoteDraw.tag + 1
            }
            else {
                self.remoteDrawImageView = UIImageView(frame: self.view.bounds)
                self.remoteDrawImageView?.boundInside(container: self.view)
                self.remoteDrawImageView?.image = image
                self.remoteDrawImageView?.contentMode = .scaleAspectFill
                self.remoteDrawImageView?.tag = 1
            }
            self.updateClearAllButton()
            self.orderDrawViews()
        }
        
        return
        
//        let message = DGStreamMessage()
//        message.isSystem = true
//        message.message = "REMOTE DRAW \(id)"
        
//        if self.undoIDs.contains(id) {
//            return
//        }
//
//        if let image = UIImage(data: data) {
//
//            var secondImage: UIImage?
//            var secondID:Int = 0
//            if let first = self.remoteDrawUndo1ImageView {
//                secondID = first.tag
//                secondImage = first.image
//                first.image = image
//                first.tag = id
//            }
//            else {
//                self.remoteDrawUndo1ImageView = UIImageView(frame: self.view.bounds)
//                self.remoteDrawUndo1ImageView?.boundInside(container: self.view)
//                self.remoteDrawUndo1ImageView?.image = image
//                self.remoteDrawUndo1ImageView?.tag = id
//                self.remoteVideoViewContainer.bringSubview(toFront: self.remoteDrawUndo1ImageView!)
//                if let jot = self.jotVC {
//                    self.remoteVideoViewContainer.bringSubview(toFront: jot.view)
//                }
//            }
//
//            var mergeImage: UIImage?
//            if let second = self.remoteDrawUndo2ImageView {
//                mergeImage = second.image
//                second.image = secondImage
//                second.tag = secondID
//            }
//            else if let secondImage = secondImage {
//                self.remoteDrawUndo2ImageView = UIImageView(frame: self.view.bounds)
//                self.remoteDrawUndo2ImageView?.boundInside(container: self.view)
//                self.remoteDrawUndo2ImageView?.image = secondImage
//                self.remoteDrawUndo2ImageView?.tag = secondID
//                self.remoteVideoViewContainer.bringSubview(toFront: self.remoteDrawUndo2ImageView!)
//                if let jot = self.jotVC {
//                    self.remoteVideoViewContainer.bringSubview(toFront: jot.view)
//                }
//            }
//
//            if let mergeImage = mergeImage {
//                if let remoteDraw = self.remoteDrawImageView {
//                    remoteDraw.mergeImagesWith(newImage: mergeImage)
//                }
//                else {
//                    self.remoteDrawImageView = UIImageView(frame: self.view.bounds)
//                    self.remoteDrawImageView?.boundInside(container: self.view)
//                    self.remoteDrawImageView?.image = mergeImage
//                    self.remoteDrawImageView?.contentMode = .scaleAspectFill
//                }
//            }
//        }
//        self.orderDrawViews()
    }
    
    func drawLocal(image: UIImage, isFromUndo: Bool) -> UIImage? {
        self.undoButton.isEnabled = true
        self.undoButton.tintColor = .white
        var sendImage:UIImage?
        if let localDraw = self.localDrawImageView {
            localDraw.tag = localDraw.tag + 1
            if let beforeImage = localDraw.image, isFromUndo == false {
                self.addLocalDraw(image: beforeImage)
            }
            if isFromUndo {
                localDraw.image = image
            }
            else {
                localDraw.mergeImagesWith(newImage: image)
            }
            if let afterImage = localDraw.image {
                sendImage = afterImage
            }
            else {
                sendImage = image
            }
        }
        else {
            self.localDrawImageView = UIImageView(frame: self.view.bounds)
            self.localDrawImageView?.boundInside(container: self.view)
            self.localDrawImageView?.image = image
            sendImage = image
            self.localDrawImageView?.contentMode = .scaleAspectFill
            self.localDrawImageView?.tag = 1
        }
        self.updateClearAllButton()
        self.orderDrawViews()
        return sendImage
//        var secondImage: UIImage?
//        var secondID:Int = 0
//
//        let message = DGStreamMessage()
//        message.isSystem = true
//        message.message = "LOCAL DRAW \(self.localDrawIncrement)"
//
//        if let first = self.localDrawUndo1ImageView {
//            secondImage = first.image
//            secondID = first.tag
//            first.image = image
//            first.tag = self.localDrawIncrement
//        }
//        else {
//            self.localDrawUndo1ImageView = UIImageView(frame: self.view.bounds)
//            self.localDrawUndo1ImageView?.boundInside(container: self.view)
//            self.localDrawUndo1ImageView?.image = image
//            self.localDrawUndo1ImageView?.contentMode = .scaleAspectFill
//            self.localDrawUndo1ImageView?.tag = self.localDrawIncrement
//            self.remoteVideoViewContainer.bringSubview(toFront: self.localDrawUndo1ImageView!)
//            if let jot = self.jotVC {
//                self.remoteVideoViewContainer.bringSubview(toFront: jot.view)
//            }
//        }
//
//        var mergeImage: UIImage?
//        if let secondImage = secondImage {
//
//            if let second = self.localDrawUndo2ImageView {
//                mergeImage = second.image
//                second.image = secondImage
//                second.tag = secondID
//            }
//            else {
//                self.localDrawUndo2ImageView = UIImageView(frame: self.view.bounds)
//                self.localDrawUndo2ImageView?.boundInside(container: self.view)
//                self.localDrawUndo2ImageView?.image = secondImage
//                self.localDrawUndo2ImageView?.contentMode = .scaleAspectFill
//                self.localDrawUndo2ImageView?.tag = secondID
//                self.remoteVideoViewContainer.bringSubview(toFront: self.localDrawUndo2ImageView!)
//                if let jot = self.jotVC {
//                    self.remoteVideoViewContainer.bringSubview(toFront: jot.view)
//                }
//            }
//
//        }
//
//        if let mergeImage = mergeImage {
//            if let localDraw = self.localDrawImageView {
//                localDraw.mergeImagesWith(newImage: mergeImage)
//            }
//            else {
//                self.localDrawImageView = UIImageView(frame: self.view.bounds)
//                self.localDrawImageView?.boundInside(container: self.view)
//                self.localDrawImageView?.image = mergeImage
//                self.localDrawImageView?.contentMode = .scaleAspectFill
//            }
//        }
//        self.orderDrawViews()
    }
    
    func addLocalDraw(image: UIImage) {
        self.undoImage2 = self.undoImage1
        self.undoImage1 = image
        return
    }
    
    func orderDrawViews() {
        if let view = self.remoteDrawImageView {
            self.view.bringSubview(toFront: view)
        }

        if let view = self.remoteDrawUndo2ImageView {
            self.view.bringSubview(toFront: view)
        }

        if let view = self.remoteDrawUndo1ImageView {
            self.view.bringSubview(toFront: view)
        }

        if let view = self.localDrawImageView {
            self.view.bringSubview(toFront: view)
        }

        if let view = self.localDrawUndo2ImageView {
            self.view.bringSubview(toFront: view)
        }

        if let view = self.localDrawUndo1ImageView {
            self.view.bringSubview(toFront: view)
        }
        
        // Keep in the back
        if let view = self.remoteDrawView {
            self.view.bringSubview(toFront: view)
        }
        
        if let view = self.drawView {
            self.view.bringSubview(toFront: view)
        }
        
        if let view = self.whiteBlendView {
            self.view.bringSubview(toFront: view)
        }
        
        if let view = self.blackBlendView {
            self.view.bringSubview(toFront: view)
        }
        
        if let jot = self.jotVC {
            self.view.bringSubview(toFront: jot.view)
        }
        
        self.view.bringSubview(toFront: self.optionsContainerContainer)
        
        for v in self.topViews {
            self.view.bringSubview(toFront: v)
        }
        
        if let alert = self.alertView {
            self.view.bringSubview(toFront: alert)
        }
        
        if let alert = self.alertRequestWaitingView {
            self.view.bringSubview(toFront: alert)
        }
        
        self.view.bringSubview(toFront: self.statusBar)
    }
    
    func removeDrawViewsFor(userID: NSNumber) {
        if userID == DGStreamCore.instance.currentUser?.userID ?? 0 {
            if let localDrawView = self.localDrawImageView {
                localDrawView.removeFromSuperview()
                self.localDrawImageView = nil
            }
            
            if let localDrawView = self.localDrawUndo1ImageView {
                localDrawView.removeFromSuperview()
                self.localDrawUndo1ImageView = nil
            }
            
            if let localDrawView = self.localDrawUndo2ImageView {
                localDrawView.removeFromSuperview()
                self.localDrawUndo2ImageView = nil
            }
        }
        else {
            if let remoteDrawView = self.remoteDrawImageView {
                remoteDrawView.removeFromSuperview()
                self.remoteDrawImageView = nil
            }
            
            if let remoteDrawView = self.remoteDrawUndo1ImageView {
                remoteDrawView.removeFromSuperview()
                self.remoteDrawUndo1ImageView = nil
            }
            
            if let remoteDrawView = self.remoteDrawUndo2ImageView {
                remoteDrawView.removeFromSuperview()
                self.remoteDrawUndo2ImageView = nil
            }
        }
    }
    
    func undo(id: Int) {
        
        self.undoIDs.append(id)
        print("UNDO ID = \(id)")
//        let message = DGStreamMessage()
//        message.isSystem = true
//        message.message = "REMOTE UNDO \(id)"
//        self.chatPeekView.addCellWith(message: message)
        if self.remoteDrawUndo1ImageView?.tag == id, let first = self.remoteDrawUndo1ImageView {
            first.image = nil
            if let second = self.remoteDrawUndo2ImageView, let newImage = second.image {
                first.image = newImage
                first.tag = second.tag
                second.image = nil
                second.tag = 0
            }
        }
        else if self.remoteDrawUndo2ImageView?.tag == id, let second = self.remoteDrawUndo2ImageView {
            second.image = nil
            second.tag = 0
        }
//        else if let first = self.remoteDrawUndo1ImageView {
//            first.image = nil
//            if let second = self.remoteDrawUndo2ImageView, let newImage = second.image {
//                first.image = newImage
//                second.image = nil
//            }
//        }
    }
    
    func undoLocal() {
        
        
        
//        return
//        //print("UNDO LOCAL \(self.localDrawUndo1ImageView?.tag ?? 0) \(self.localDrawUndo2ImageView?.tag ?? 0)")
//        var undoID: Int = 0
//        if let first = self.localDrawUndo1ImageView {
//            undoID = first.tag
//            first.image = nil
//            first.tag = 0
//            if let second = self.localDrawUndo2ImageView, second.tag != 0, let newImage = second.image {
//                first.tag = second.tag
//                first.image = newImage
//                second.image = nil
//                second.tag = 0
//                self.undoButton.isEnabled = true
//                self.undoButton.tintColor = UIColor.dgBlueDark()
//            }
//            else {
//                self.undoButton.isEnabled = false
//                self.undoButton.tintColor = .lightGray
//            }
//        }
//        else {
//            self.undoButton.isEnabled = false
//            self.undoButton.tintColor = .lightGray
//        }
////        let message = DGStreamMessage()
////        message.isSystem = true
////        message.message = "LOCAL UNDO \(undoID)"
////        self.chatPeekView.addCellWith(message: message)
//        return undoID
    }
    
    func getLastUndo() {
        if let image = self.undoImage1 {
            self.sendDrawing(image: image, isUndo: true)
            self.undoImage1 = nil
            if let local = localDrawImageView, local.tag > 0 {
                local.tag = local.tag - 1
            }
        }
        if let image = self.undoImage2 {
            self.undoImage1 = image
            self.undoImage2 = nil
        }
        if self.undoImage1 == nil && self.undoImage2 == nil {
            self.undoButton.isEnabled = false
            updateClearAllButton()
        }
    }
    
    func clearDrawings() {
        DispatchQueue.main.async {
            self.undoButton.isEnabled = false
            self.localDrawImageView?.image = UIImage(color: .clear, size: self.view.bounds.size)
            self.localDrawImageView?.tag = 0
            self.updateClearAllButton()
        }
    }
    
    func clearRemoteDrawings() {
        DispatchQueue.main.async {
            self.remoteDrawImageView?.image = UIImage(color: .clear, size: self.view.bounds.size)
            self.remoteDrawImageView?.tag = 0
            self.updateClearAllButton()
        }
    }
    
    func updateClearAllButton() {
        if hasDrawings() {
            self.clearAllButton.isEnabled = true
        }
        else {
            self.clearAllButton.isEnabled = false
        }
    }
    
}

//MARK:- White Board Mode
extension DGStreamCallViewController {
    
    func startWhiteBoard() {
        
        DispatchQueue.main.async {
            
            if self.callMode == .merge || self.callMode == .perspective {
                self.returnToStreamMode(hideModeButtons: false)
            }
            else if self.isShowingControls {

            }
            
            self.hideLocalVideo()
            self.localBroadcastView?.alpha = 0
            
            // Add Whiteboard
            if self.whiteBoardView == nil {
                self.whiteBoardView = UIView(frame: self.remoteVideoViewContainer.bounds)
                self.whiteBoardView?.tag = 1999
                self.whiteBoardView?.backgroundColor = .white
                self.whiteBoardView?.boundInside(container: self.remoteVideoViewContainer)
            }
            
            if self.drawingUsers.contains(self.selectedUser) == false {
                self.drawingUsers.append(self.selectedUser)
            }
            
            if let currentUser = DGStreamCore.instance.currentUser, let currentUserID = currentUser.userID, self.drawingUsers.contains(currentUserID) == false {
                self.drawingUsers.append(currentUserID)
            }
            
            self.orderDrawViews()
            
            // Update Buttons
            self.freezeButton.isEnabled = false
            UIView.animate(withDuration: 0.18) {
                self.whiteBoardButton.tintColor = UIColor.dgMergeMode()
                self.whiteBoardButtonContainer.layer.borderColor = UIColor.dgMergeMode().cgColor
                self.whiteBoardButtonLabel.textColor = UIColor.dgMergeMode()
                self.statusBar.backgroundColor = UIColor.dgMergeMode()
                self.drawButton.tintColor = UIColor.dgMergeMode()
                self.drawButton.backgroundColor = .white
                
                self.shareButton.isEnabled = false
                self.shareButton.tintColor = UIColor.lightGray
                self.shareButtonContainer.layer.borderColor = UIColor.lightGray.cgColor
                self.shareButton.setTitleColor(UIColor.lightGray, for: .normal)
                self.shareButtonLabel.textColor = .lightGray
                
                self.drawButton.isEnabled = true
                self.freezeButton.isEnabled = false
                
                self.enableDrawButtons()
                self.showOptions()
            }
            
            if let jot = self.jotVC {
                jot.view.isUserInteractionEnabled = true
            }
            
            self.callMode = .board
        }
        
    }
    
    func endWhiteBoard(sendNotification: Bool) {
        if self.callMode == .board {
            
            if didSelectToHideLocalVideo == false {
                self.showLocalVideo()
            }
            
            self.hideOptions(animated: false)
            
            // To end on other users device
            if sendNotification {
                let whiteboardEndMessage = QBChatMessage()
                whiteboardEndMessage.text = "whiteboardEnd"
                whiteboardEndMessage.senderID = DGStreamCore.instance.currentUser?.userID?.uintValue ?? 0
                whiteboardEndMessage.recipientID = self.selectedUser.uintValue
                whiteboardEndMessage.customParameters = ["isDrawing":"\(self.isDrawing)"]
                QBChat.instance.sendSystemMessage(whiteboardEndMessage, completion: { (error) in
                    print("Sent Whiteboard End System Message With \(error?.localizedDescription ?? "No Error")")
                })
            }
            
            if !self.drawingUsers.contains(self.selectedUser), let remote = self.remoteDrawImageView {
                remote.image = UIImage(color: .clear, size: remote.bounds.size)
            }
            
            // Remove Whiteboard
            if let white = self.whiteBoardView {
//                var shouldRemoveWhiteBoard = true
//                if userID == self.selectedUser && self.callMode == .board {
//                    shouldRemoveWhiteBoard = false
//                }
//                else if self.whiteBoardUsers.contains(selectedUser) {
//                    shouldRemoveWhiteBoard = false
//                }
//                if shouldRemoveWhiteBoard {
//                    white.removeFromSuperview()
//                    self.whiteBoardView = nil
//                    //self.layoutRemoteViewHeirarchy()
//                }
                white.removeFromSuperview()
                self.whiteBoardView = nil
            }
            
            // Update Buttons
            self.freezeButton.isEnabled = true
            UIView.animate(withDuration: 0.18) {
                self.whiteBoardButton.tintColor = UIColor.dgBlueDark()
                self.whiteBoardButtonLabel.textColor = UIColor.dgBlueDark()
                self.whiteBoardButtonContainer.layer.borderColor = UIColor.dgBlueDark().cgColor
                self.statusBar.backgroundColor = UIColor.dgBlueDark()
                self.statusBarBackButton.alpha = 0
                self.statusBarDoneButton.alpha = 0
                self.freezeButton.tintColor = .white
                self.freezeButton.setTitleColor(.white, for: .normal)
                if self.isDrawing == false {
                    self.drawButton.layer.borderColor = UIColor.dgBlueDark().cgColor
                    self.drawEndWith(userID: DGStreamCore.instance.currentUser?.userID ?? 0)
                }
                self.shareButton.isEnabled = true
                self.shareButton.tintColor = UIColor.dgBlueDark()
                self.shareButtonContainer.layer.borderColor = UIColor.dgBlueDark().cgColor
                self.shareButton.setTitleColor(UIColor.dgBlueDark(), for: .normal)
                self.shareButtonLabel.textColor = UIColor.dgBlueDark()
                
                self.disableDrawButtons()
            }
            
            self.localBroadcastView?.alpha = 1
            
            self.clearRemoteDrawings()
            self.clearDrawings()
            
            if let jot = self.jotVC {
                jot.clearAll()
                jot.view.isUserInteractionEnabled = false
            }
            
            self.mergeButton.isEnabled = true
        }
        else if let whiteboardView = self.whiteBoardView {
            whiteboardView.removeFromSuperview()
            self.whiteBoardView = nil
        }
        
    }
    
}

//MARK:- UICollectionView Users
//extension DGStreamCallViewController: UICollectionViewDataSource, UICollectionViewDelegate {
//    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return self.users.count
//    }
//
//    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! DGStreamCollectionViewCell
//        let user = self.users[indexPath.item]
//        if let userID = user.userID, let videoView = self.videoViewWith(userID: userID) {
//            cell.set(videoView: videoView)
//        }
//        return cell
//    }
//}

//MARK:- Transition To Size
extension DGStreamCallViewController {
    override public func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil) { (context) in
            //self.refreshVideoViews()
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
//    func performUpdate(userID: NSNumber, block: CellUpdateBlock) {
//        let indexPath = self.indexPathAt(userID: userID)
//        if let cell = self.collectionView.cellForItem(at: indexPath) as? DGStreamCollectionViewCell {
//            block(cell)
//        }
//    }
}

//MARK:- QBRTCClientDelegate
extension DGStreamCallViewController: QBRTCClientDelegate {
    
    public func session(_ session: QBRTCSession, userDidNotRespond userID: NSNumber) {
        //DGStreamCore.instance.audioPlayer.stopAllSounds()
        if session == self.session {
            let alert = UIAlertController(title: "No Response", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action: UIAlertAction) in
                alert.dismiss(animated: true, completion: nil)
                self.navigationController?.popViewController(animated: true)
            }))
            present(alert, animated: true, completion: nil)
        }
    }
    
    public func session(_ session: QBRTCSession, rejectedByUser userID: NSNumber, userInfo: [String : String]? = nil) {
        //DGStreamCore.instance.audioPlayer.stopAllSounds()
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
            self.session?.hangUp(["hangup" : "hang up"])
            self.didOtherUserHangUp = true
            self.showCallEndedWith(isHungUp: true)
        }
        //DGStreamCore.instance.audioPlayer.stopAllSounds()
    }
    
    public func session(_ session: QBRTCBaseSession, receivedRemoteVideoTrack videoTrack: QBRTCVideoTrack, fromUser userID: NSNumber) {
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
//        else {
//            // DRAW SESSION
//            self.remoteDrawView = QBRTCRemoteVideoView(frame: self.view.bounds)
//            self.remoteDrawView?.setVideoTrack(videoTrack)
//            self.remoteDrawView?.videoGravity = AVLayerVideoGravityResizeAspect
//            self.remoteDrawView?.boundInside(container: self.view)
//            self.remoteDrawView?.backgroundColor = .clear
//            self.remoteDrawView?.alpha = 1.0
//            if let black = self.blackBlendView {
//                black.alpha = 0
//            }
//            self.orderDrawViews()
//        }
    }
    
    public func session(_ session: QBRTCBaseSession, connectedToUser userID: NSNumber) {
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
            }
            if self.callTimer == nil {
                self.callTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(refreshCallTime(sender:)), userInfo: nil, repeats: true)
            }
        }
    }
    
    public func session(_ session: QBRTCBaseSession, disconnectedFromUser userID: NSNumber) {
        self.stopRecording(isEndOfCall: true) {
            if self.didOtherUserHangUp == false && userID == self.selectedUser {
                self.showCallEndedWith(isHungUp: false)
                self.session?.hangUp(["hangup" : "hang up"])
            }
            if let index = self.chatVC.chatConversation.userIDs.index(of: userID) {
                self.chatVC.chatConversation.userIDs.remove(at: index)
            }
            if let recent = DGStreamCore.instance.lastRecent {
                recent.duration = self.timeDuration
                DGStreamManager.instance.dataStore.streamManager(DGStreamManager.instance, store: recent)
            }
        }
    }
}

extension DGStreamCallViewController: JotViewControllerDelegate {
    public func jotViewController(_ jotViewController: JotViewController!, isEditingText isEditing: Bool) {
//        if let jot = self.jotVC, self.isSettingText {
////            jot.state = .drawing
////            jot.clearText()
////            if let stamp = self.dropDownSelectedStamp {
////                self.place(stamp: stamp)
////            }
//            //jot.drawingContainer.gest
//        }
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
            finishedTakingSnapshot(forVideoCover: false)
        }
    }
}

extension DGStreamCallViewController: DGStreamChatViewControllerDelegate {
    func chat(viewController: DGStreamChatViewController, backButtonTapped sender: Any?) {
        hideChatVC()
    }
    func chat(viewController: DGStreamChatViewController, didReceiveMessage message: DGStreamMessage) {
        self.chatButton.tintColor = UIColor.dgMergeMode()
        self.chatButtonContainer.layer.borderColor = UIColor.dgMergeMode().cgColor
        self.chatPeekView.addCellWith(message: message)
    }
    func chat(viewController: DGStreamChatViewController, tapped image: UIImage) {
        self.performSegue(withIdentifier: "image", sender: image)
    }
    func chatViewControllerDidFinishTakingPicture() {
        // The Image Picker was using the camera
        // Restart users camera
        
        if self.callMode == .board {
            return
        }
        
        var isFront: Bool = false
        var isChromaKey: Bool = false
        var container: UIView!
        
        if self.callMode == .stream {
            isFront = true
            isChromaKey = false
            container = self.localVideoViewContainer
        }
        
        if self.callMode == .merge {
            isFront = false
            isChromaKey = true
            container = self.remoteVideoViewContainer
        }
        if self.callMode == .perspective {
            isFront = false
            isChromaKey = false
            container = self.remoteVideoViewContainer
        }
        self.setUpLocalVideoViewIn(container: container, isFront: isFront, isChromaKey: isChromaKey)
        
        if self.callMode == .perspective && !self.isCurrentUserPerspective {
            self.localBroadcastView?.alpha = 0
        }
    }
}

extension DGStreamCallViewController: DGStreamCallColorViewControllerDelegate, DGStreamCallStampsViewControllerDelegate {
    
    func stampSelected(stamp: String) {
        if let jot = self.jotVC {
            if let image = jot.renderImage() {
                jot.draw(on: image)
            }
            jot.textColor = self.drawColor
            jot.fontSize = 250
            jot.textString = stamp
            jot.state = .text
            self.dropDownSelectedStamp = stamp
            startSettingText()
            
            self.optionsContainerContainer.alpha = 0
            self.hideControls()
                        
            self.recordButton.alpha = 0
            self.snapshotButton.alpha = 0
            self.freezeButton.alpha = 0
            self.showHideButtonsButton.alpha = 0
            self.drawButton.alpha = 0
            self.statusBarBackButton.alpha = 1
            self.statusBarDoneButton.alpha = 1
        }
    }
    
    func mergeColorSelected(color: UIColor) {
        self.mergeOptionColor = color
        self.mergeColorButton.tintColor = color
        self.setUpLocalVideoViewIn(container: self.remoteVideoViewContainer, isFront: false, isChromaKey: true)
    }
    
    func colorSelected(color: UIColor) {
        if let jot = self.jotVC {
            self.dropDownSelectedColor = color
            self.drawColor = color
            jot.drawingColor = self.drawColor
        }
    }
    
    func sizeSelected(size: CGFloat) {
        if let jot = self.jotVC {
            self.dropDownSelectedSize = size
            jot.drawingStrokeWidth = size
        }
    }
    
    func showDropDownFor(type: DGStreamDropDownType) {
        self.dropDownManager.loadFor(type: type)
    }
    
    func hideDropDown() {

    }
    
    func startSettingText() {
        self.isSettingText = true
        self.jotTapGesture?.isEnabled = false
        self.localVideoViewContainer.alpha = 0
        self.orderDrawViews()
        UIView.animate(withDuration: 0.18) {
            self.statusBarBackButton.alpha = 1
            self.statusBarBackButton.setTitle(NSLocalizedString("Cancel", comment: "Stop action"), for: .normal)
            self.statusBarDoneButton.alpha = 1
            self.statusBarDoneButton.setTitle(NSLocalizedString("Send", comment: "Complete action"), for: .normal)
        }
    }
    
    func endSettingText(cancelled: Bool) {
        
        self.optionsContainerContainer.alpha = 1
        self.showControls()
        
        self.recordButton.alpha = 1
        self.snapshotButton.alpha = 1
        self.freezeButton.alpha = 1
        self.showHideButtonsButton.alpha = 1
        self.drawButton.alpha = 1
        self.statusBarBackButton.alpha = 0
        self.statusBarDoneButton.alpha = 0
        
        self.isSettingText = false
        self.jotTapGesture?.isEnabled = true
        if let jot = self.jotVC, self.localDrawImageView == nil {
            self.localDrawImageView = UIImageView(frame: self.remoteVideoViewContainer.bounds)
            self.localDrawImageView?.image = UIImage()
            self.localDrawImageView?.boundInside(container: self.remoteVideoViewContainer)
            self.remoteVideoViewContainer.bringSubview(toFront: jot.view)
        }
        if let jot = self.jotVC {
            if cancelled {
                jot.clearText()
//                jot.clearDrawing()
//                jot.clearAll()
            }
            else {
                self.sendDrawing(image: nil, isUndo: false)
            }
            
            jot.state = .drawing
//            jot.clearText()
//            jot.clearDrawing()
//            jot.clearAll()
        }
        UIView.animate(withDuration: 0.18) {
            self.statusBarBackButton.setTitle(NSLocalizedString("Cancel", comment: "Stop action"), for: .normal)
        }
    }
    
    func place(stamp: String) {
        if let jot = self.jotVC {
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

extension DGStreamCallViewController {
    
    func recorder(_ recorder: DGStreamRecorder, audioSample: CMSampleBuffer) {
        if self.isRecording, let audio = self.assetWriterAudioInput {
            audio.append(audioSample)
        }
    }
    
    func send(frameToBroadcast: QBRTCVideoFrame) {
        self.freezeRotation = frameToBroadcast.videoRotation
        if self.session != nil {
            if let local = self.localVideoCapture {
                local.send(videoFrame: frameToBroadcast)
            }
            if let vb = self.recordingView {
                var rotation = frameToBroadcast.videoRotation
                if self.isSharing {
                    rotation = ._0
                }
                let vidfra = RTCVideoFrame(pixelBuffer: frameToBroadcast.pixelBuffer, rotation: rotation, timeStampNs: 0)
                vb.renderFrame(vidfra)
            }
        }
    }
    
    func setupAssetWriterVideoInput() -> Bool {
        let videoCompressionSettings = [AVVideoCodecKey: AVVideoCodecH264, AVVideoWidthKey: 640, AVVideoHeightKey: 480, AVVideoCompressionPropertiesKey: [AVVideoAverageBitRateKey: 636528, AVVideoMaxKeyFrameIntervalKey: 30]] as [String : Any]
        if let writer = assetWriter, writer.canApply(outputSettings: videoCompressionSettings, forMediaType: AVMediaTypeVideo) {
            self.assetWriterVideoInput = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: videoCompressionSettings, sourceFormatHint: nil)
            self.assetWriterVideoInput?.expectsMediaDataInRealTime = true
            print("Get transform for \(self.videoOrientation == .portrait)")
            self.assetWriterVideoInput?.transform = transformFor(orientation: videoOrientation)
            if let movieIn = self.assetWriterVideoInput, writer.canAdd(movieIn) {
                writer.add(movieIn)
            }
            else {
                return false
            }
        }
        else {
            return false
        }
        return true
    }
    func transformFor(orientation: AVCaptureVideoOrientation) -> CGAffineTransform {
        var transform: CGAffineTransform = .identity
        let orientationOffset:CGFloat = angleOffsetFromPortraitFor(orientation: orientation)
        let videoOrientationAngleOffset:CGFloat = angleOffsetFromPortraitFor(orientation: self.videoOrientation)
        transform = CGAffineTransform(rotationAngle: orientationOffset - videoOrientationAngleOffset)
        print("transformFor \(transform)")
        return transform
    }
    func angleOffsetFromPortraitFor(orientation: AVCaptureVideoOrientation) -> CGFloat {
        var angle:CGFloat = 0.0
        switch orientation {
        case .portrait:
            angle = 0.0;
            break
        case .portraitUpsideDown:
            angle = CGFloat(Double.pi)
            break
        case .landscapeRight:
            angle = CGFloat(-Double.pi / 2)
            break
        case .landscapeLeft:
            angle = CGFloat(Double.pi / 2)
            break
        }
        return angle
    }
    
}

extension DGStreamCallViewController: DGStreamCallShareSelectViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func callShareSelectViewControllerDidTapRecordings() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.20) {
            self.performSegue(withIdentifier: "Recording", sender: nil)
        }
    }
    
    func callShareSelectViewControllerDidTapPhotos() {
        
    }
    
    func callShareSelectViewControllerDidTapDocuments() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.20) {
            self.performSegue(withIdentifier: "documents", sender: nil)
        }
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        DGStreamCore.instance.presentedViewController = self
    }
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        defer {
            picker.dismiss(animated: false, completion: nil)
        }
        
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            return
        }
        
        let resized = UIImage.resizeImage(image: image, targetSize: CGSize(width: image.size.width / 2, height: image.size.height / 2))
        
        self.uploadShareImage(data: UIImageJPEGRepresentation(resized, 0.75))
    }
    
    func uploadShareImage(data: Data?) {
        if let imageData = data, let fileID = UUID().uuidString.components(separatedBy: "-").first, let image = UIImage(data: imageData) {
            QBRequest.tUploadFile(imageData, fileName: fileID, contentType: "image/png", isPublic: true, successBlock: { (response, blob) in
                
                let shareImageMessage = QBChatMessage()
                shareImageMessage.text = "shareImage"
                shareImageMessage.senderID = DGStreamCore.instance.currentUser?.userID?.uintValue ?? 0
                shareImageMessage.recipientID = self.selectedUser.uintValue
                
                let uploadedFileID: UInt = blob.id
                let attachment: QBChatAttachment = QBChatAttachment()
                attachment.type = "image"
                attachment.id = String(uploadedFileID)
                shareImageMessage.attachments = [attachment]
                
                self.isSharing = true
                self.updateUIForShareStart()
                if self.callMode != .merge {
                    self.setShare(image: image)
                }
                
                QBChat.instance.sendSystemMessage(shareImageMessage, completion: { (error) in
                    print("Sent shareImageMessage System Message With \(error?.localizedDescription ?? "No Error")")
                    //self.delegate.drawOperationDidFinish(operation: self)
                })
                
            }, statusBlock: { (request, status) in
                
            }, errorBlock: { (response) in
                //self.delegate.drawOperationFailedWith(errorMessage: "No Image")
            })
        }
    }
    
    func stopSharing() {
        
        self.latestRemotePageIncrement = 0
        
        if let rv = self.recordingView {
            rv.removeFromSuperview()
            self.recordingView = nil
        }
        
        if self.callMode != .merge && self.callMode != .perspective {
            self.localBroadcastView?.boundInside(container: self.localVideoViewContainer)
        }
        else {
            self.localBroadcastView?.boundInside(container: self.remoteVideoViewContainer)
        }
        
        if self.callMode == .merge {
            //self.localBroadcastView?.alpha = 0.5
        }
        else if self.callMode == .perspective {
            if self.isCurrentUserPerspective {
                self.localBroadcastView?.alpha = 1.0
            }
            else {
                self.localBroadcastView?.alpha = 0.0
            }
        }
        
        self.freezeFrame = nil
        if let queue = self.recordingOperationQueue {
            queue.stop()
        }
        self.recordingOperationQueue = nil
        
        self.isBeingSharedWith = false
        self.isBeingSharedWithVideo = false
        self.isSharing = false
        self.isSharingVideo = false
        self.isSharingDocument = false
        
        self.removePDF() // if there is one
        
        self.updateUIForShareEnd()
    }
    
    func beingSharedWith(imageData: Data?) {
        self.isBeingSharedWith = true
        if self.callMode == .merge {
            //self.localBroadcastView?.alpha = 0.5
        }
        else {
            self.localBroadcastView?.alpha = 0
        }
        
        if let data = imageData, let image = UIImage(data: data) {
            self.setShare(image: image)
            self.updateUIForShareStart()
            if self.isMergeHelper {
                self.remoteVideoViewContainer.sendSubview(toBack: self.freezeImageView!)
                for subview in self.remoteVideoViewContainer.subviews {
                    if subview is QBRTCRemoteVideoView {
                        self.remoteVideoViewContainer.sendSubview(toBack: subview)
                    }
                }
            }
        }
        else {
            self.isBeingSharedWithVideo = true
        }
        
        guard let user = DGStreamCore.instance.getOtherUserWith(userID: self.selectedUser), let username = user.username else {
            return
        }
        
        var text = "\(username) is sharing "
        
        if self.isBeingSharedWithVideo {
            text.append("a video.")
        }
        else {
            text.append("an image.")
        }
        
        let message = DGStreamMessage()
        message.isSystem = true
        message.message = text
        self.chatPeekView.addCellWith(message: message)
    }
    
    func setShare(image: UIImage) {
        if let freeze = self.freezeImageView {
            freeze.removeFromSuperview()
            self.freezeImageView = nil
        }
        self.freezeImageView = UIImageView(frame: self.remoteVideoViewContainer.bounds)
        self.freezeImageView?.boundInside(container: self.remoteVideoViewContainer)
        self.freezeImageView?.image = image
        self.freezeImageView?.contentMode = .scaleAspectFill
        self.freezeImageView?.backgroundColor = .white
        
        self.orderDrawViews()
        
    }
    
    func updateUIForShareStart() {
        if self.isFrozen {
            self.unfreeze()
        }
        
        self.shareButtonContainer.layer.borderColor = UIColor.dgMergeMode().cgColor
        self.shareButton.tintColor = UIColor.dgMergeMode()
        self.shareButton.setTitleColor(UIColor.dgMergeMode(), for: .normal)
        self.shareButtonLabel.textColor = UIColor.dgMergeMode()
        self.statusBar.backgroundColor = UIColor.dgMergeMode()

        self.orderDrawViews()
        
    }
    
    func updateUIForShareEnd() {
        self.unfreeze()
        
        if self.callMode == .merge {
            //self.localBroadcastView?.alpha = 0.5
        }
        else {
            self.localBroadcastView?.alpha = 1.0
        }
        
        if self.callMode == .stream {

        }
        
        self.shareButtonContainer.layer.borderColor = UIColor.dgBlueDark().cgColor
        self.shareButton.tintColor = UIColor.dgBlueDark()
        self.shareButton.setTitleColor(UIColor.dgBlueDark(), for: .normal)
        self.shareButtonLabel.textColor = UIColor.dgBlueDark()
        if self.callMode == .stream {
            self.statusBar.backgroundColor = UIColor.dgBlueDark()
        }
    }
}

extension DGStreamCallViewController: GLKViewControllerDelegate, DGStreamLocalVideoViewDelegate {
    func localVideo(errorMessage: String) {
        let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action: UIAlertAction) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true) {
            
        }
    }
    
    func localVideo(frameToBroadcast: QBRTCVideoFrame) {
        if !self.isSharingVideo {
            self.send(frameToBroadcast: frameToBroadcast)
        }
    }
    
    public func glkViewControllerUpdate(_ controller: GLKViewController) {
        
    }
}

// MARK:- MERGE OPTIONS
extension DGStreamCallViewController: UICollectionViewDataSource, UICollectionViewDelegate, DGStreamCallMergeIntensityDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        var oldSelectedIndex:Int = 0
        
        if collectionView.tag == 99 {
            
            oldSelectedIndex = self.selectedSizeIndex
            
            if indexPath.item == oldSelectedIndex {
                return
            }
            
            self.selectedSizeIndex = indexPath.item
            
            let size = CGFloat(self.sizes[indexPath.item])
            self.drawSize = size
            self.sizeSelected(size: size)
        }
        else {
            
            oldSelectedIndex = self.selectedColorIndex
            
            if indexPath.item == oldSelectedIndex {
                return
            }
            
            self.selectedColorIndex = indexPath.item
            
            self.colorSelected(color: self.colors[indexPath.item])
        }
        
        // Remove The Old
        if oldSelectedIndex != 100, let cell = collectionView.cellForItem(at: IndexPath(item: oldSelectedIndex, section: 0)) {
            cell.contentView.layer.borderColor = UIColor.dgBlack().cgColor
            cell.contentView.layer.borderWidth = 0.5
        }
        
        // Add the New
        if let cell = collectionView.cellForItem(at: IndexPath(item: indexPath.item, section: 0)) {
            cell.contentView.layer.borderColor = UIColor.orange.cgColor
            cell.contentView.layer.borderWidth = 4
        }
        
    }
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 99 {
            return self.sizes.count
        }
        else {
            return self.colors.count
        }
    }
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        if collectionView.tag == 99 {
            
            for subview in cell.contentView.subviews {
                if subview is UILabel {
                    subview.removeFromSuperview()
                }
            }
            
            let size = self.sizes[indexPath.item]
            cell.contentView.backgroundColor = UIColor.dgBlueDark()
            let label = UILabel(frame: cell.contentView.bounds)
            label.boundInside(container: cell.contentView)
            label.font = UIFont(name: "HelveticaNeue-Bold", size: 14)
            label.textAlignment = .center
            label.text = "\(size)"
            label.textColor = .white
            
            if indexPath.item == self.selectedSizeIndex {
                cell.contentView.layer.borderWidth = 5.0
                cell.contentView.layer.borderColor = UIColor.orange.cgColor
            }
            else {
                cell.contentView.layer.borderWidth = 0.5
                cell.contentView.layer.borderColor = UIColor.dgBlack().cgColor
            }
            
        }
        else {
            let color = self.colors[indexPath.item]
            cell.contentView.backgroundColor = color
            if indexPath.item == self.selectedColorIndex {
                cell.contentView.layer.borderColor = UIColor.orange.cgColor
                cell.contentView.layer.borderWidth = 5.0
            }
            else {
                cell.contentView.layer.borderColor = UIColor.dgBlack().cgColor
                cell.contentView.layer.borderWidth = 0.5
            }
        }
        
        cell.contentView.clipsToBounds = true
        cell.clipsToBounds = true
        cell.contentView.layer.cornerRadius = cell.contentView.frame.size.width / 2
        return cell
    }
    
    func selected(intensity: Float) {
        let i = self.getTrue(intensity: intensity, for: self.mergeOptionColor)
        self.mergeOptionIntensity = intensity
        self.localBroadcastView?.adjust(intensity: i)
        self.mergeIntensityButton.setTitle(self.stringFor(float: intensity), for: .normal)
    }
    func getTrue(intensity: Float, for color: UIColor) -> Float {
        var i = intensity
        if color == .white {
            i = intensity / 12
        }
        else if color == .red {
            i = intensity * 0.5
        }
        else if color == .blue {
            i = intensity - 0.1
        }
        return i
    }
    
    func stringFor(float: Float) -> String {
        let stringValue = String(float)
        let splice = stringValue.components(separatedBy: ".")[1]
        let spliceString = NSString(string: splice)
        var string = ""
        if spliceString.length > 1 {
            string = NSString(string: spliceString).substring(to: 2)
        }
        else {
            string = NSString(string: spliceString).substring(to: 1)
            string.append("0")
        }
        return "\(string)%"
    }
    
    func storeValues() {
        
        var color = ""
        if self.mergeOptionColor == .green {
            color = "green"
        }
        else if self.mergeOptionColor == .blue {
            color = "blue"
        }
        else if self.mergeOptionColor == .red {
            color = "red"
        }
        else if self.mergeOptionColor == .white {
            color = "white"
        }
        else {
            color = "black"
        }
        
        UserDefaults.standard.set(color, forKey: "MergeColor")
        UserDefaults.standard.set(self.selectedIntensity, forKey: "MergeIntensity")
        UserDefaults.standard.synchronize()
    }
    
    func showOptions() {
        if self.optionsContainerContainer.alpha == 1 {
            return
        }
        self.optionsContainerConstraint.constant = -170
        self.view.layoutIfNeeded()
        self.optionsContainerContainer.alpha = 1
    }
    
    func hideOptions(animated: Bool) {
        self.optionsContainerConstraint.constant = -170
        self.view.layoutIfNeeded()
        self.optionsContainerContainer.alpha = 0
    }

}

// MARK:- DOCUMENTS
extension DGStreamCallViewController: DGStreamDocumentsViewControllerDelegate {
    func didSelect(document: DGStreamDocument) {
//        let documentOperation = DGStreamDocumentOperation(fileID: document.id!, pdfData: document.pdfData()!, currentUserID: DGStreamCore.instance.currentUser?.userID ?? 0, sendToUserID: self.selectedUser)
//
//        let message = DGStreamMessage()
//        message.isSystem = true
//        message.message = "Sending document..."
//        self.chatPeekView.addCellWith(message: message)
//
//        documentOperation.sendPDFWith { (success, errorMessage) in
//            print("SENT PDF \(success)")
//            let message = DGStreamMessage()
//            message.isSystem = true
//            message.message = "Document being downloaded..."
//            self.chatPeekView.addCellWith(message: message)
//            self.placePDF(data: document)
//        }
    }
    
    func placePDF(data: Data) {
        self.removePDF()
        self.isSharingDocument = true
        self.updateUIForShareStart()
        self.documentView = DGStreamDocumentView(frame: self.remoteVideoViewContainer.bounds)
        self.documentView?.configureIn(container: self.remoteVideoViewContainer, pdfData: data, recipientID: self.selectedUser)
        if self.isBeingSharedWith {
            self.documentView?.isUserInteractionEnabled = false
        }
    }
    
    func removePDF() {
        if let docView = self.documentView {
            docView.removeFromSuperview()
            self.documentView = nil
        }
    }
    
    func changeToPage(index: Int, increment: Int) {
        if increment > self.latestRemotePageIncrement, let docView = self.documentView {
            docView.goToPage(index: index)
            self.latestRemotePageIncrement = increment
        }
    }
    
    func changeToPage(selection: String, increment: Int) {
        if increment > self.latestRemotePageIncrement, let docView = self.documentView {
            docView.goToPage(selection: selection)
            self.latestRemotePageIncrement = increment
        }
    }
    
}

// MARK:- DOCUMENTS
extension DGStreamCallViewController: UIPopoverPresentationControllerDelegate {
    public func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    public func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        return true
    }
}

extension DGStreamCallViewController: WhateverProtocol {
    func error(message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "ERROR", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action: UIAlertAction) in
                alert.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true) {
                
            }
        }
    }
}

// MARK:- Media
extension DGStreamCallViewController: DGStreamMediaViewControllerDelegate {
    func didSelect(photo: UIImage) {
        let resized = UIImage.resizeImage(image: photo, targetSize: CGSize(width: photo.size.width / 2, height: photo.size.height / 2))
        
        self.uploadShareImage(data: UIImageJPEGRepresentation(resized, 0.75))
    }
    
    func didSelect(pdf: URL) {
        
        do {
            let data = try Data.init(contentsOf: pdf)
            
            let documentOperation = DGStreamDocumentOperation(fileID: UUID().uuidString.components(separatedBy: "-").first!, pdfData: data, currentUserID: DGStreamCore.instance.currentUser?.userID ?? 0, sendToUserID: self.selectedUser)
            
            let message = DGStreamMessage()
            message.isSystem = true
            message.message = "Sending document..."
            self.chatPeekView.addCellWith(message: message)
            
            documentOperation.sendPDFWith { (success, errorMessage) in
                print("SENT PDF \(success)")
                let message = DGStreamMessage()
                message.isSystem = true
                message.message = "Document being downloaded..."
                self.chatPeekView.addCellWith(message: message)
                self.placePDF(data: data)
            }
        }
        catch let error {
            let alert = UIAlertController(title: "Error", message: "Could not read data.\n\(error.localizedDescription)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action: UIAlertAction) in
                alert.dismiss(animated: true, completion: {
                    
                })
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func didSelect(video: URL) {
        self.shareVideo(url: video)
    }
    
    func shareVideo(url: URL) {
        
        self.dismissPopover()
        
        if url.pathExtension == "mp4" {
            self.isSharing = true
            self.isSharingVideo = true
            //let audioPlayer = try? AVAudioPlayer(contentsOf: url)
            self.startedPlayingRecording()
            self.recordingView = QBRTCRemoteVideoView(frame: self.remoteVideoViewContainer.bounds)
            self.recordingView?.boundInside(container: self.remoteVideoViewContainer)
            if self.callMode == .merge {
                self.recordingView?.alpha = 0
            }
            let shareMessage = QBChatMessage()
            shareMessage.text = "sharing"
            shareMessage.senderID = DGStreamCore.instance.currentUser?.userID?.uintValue ?? 0
            shareMessage.recipientID = self.selectedUser.uintValue
            QBChat.instance.sendSystemMessage(shareMessage, completion: { (error) in
                print("Sent shareMessage System Message With \(error?.localizedDescription ?? "No Error")")
                //self.hideFreezeActivityIndicator()
            })
            self.recordingOperationQueue = DGStreamSendRecordingOperationQueue(recordingURL: url, sendBlock: { (frame) in
                self.send(frameToBroadcast: frame)
            }, errorBlock: { (errorMessage) in
                let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action: UIAlertAction) in
                    alert.dismiss(animated: false, completion: nil)
                }))
                self.present(alert, animated: true, completion: {
                    
                })
            }, completion: { (success, errorMessage) in
                let shareMessage = QBChatMessage()
                shareMessage.text = "stopSharing"
                shareMessage.senderID = DGStreamCore.instance.currentUser?.userID?.uintValue ?? 0
                shareMessage.recipientID = self.selectedUser.uintValue
                QBChat.instance.sendSystemMessage(shareMessage, completion: { (error) in
                    print("Sent stopSharing System Message With \(error?.localizedDescription ?? "No Error")")
                    //self.hideFreezeActivityIndicator()
                })
                self.recordingStopped()
            })
            
        }
        else {
            let alert = UIAlertController(title: "Error", message: "Item selected is not an MP4.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action: UIAlertAction) in
                alert.dismiss(animated: false, completion: nil)
            }))
            self.present(alert, animated: true, completion: {
                
            })
        }
    }
    
    func startedPlayingRecording() {
        self.shareButtonContainer.layer.borderColor = UIColor.dgMergeMode().cgColor
        self.shareButton.setTitleColor(UIColor.dgMergeMode(), for: .normal)
        self.shareButton.tintColor = UIColor.dgMergeMode()
        self.shareButtonLabel.textColor = UIColor.dgMergeMode()
        
        if let broadcast = self.localBroadcastView, !self.remoteVideoViewContainer.subviews.contains(broadcast) {
            self.localBroadcastView?.boundInside(container: self.remoteVideoViewContainer)
        }
        
        self.localBroadcastView?.alpha = 0
        
    }
    
    func recordingStopped() {
        if let alert = UINib(nibName: "DGStreamAlertView", bundle: Bundle(identifier: "com.dataglance.DGStream")).instantiate(withOwner: self, options: nil).first as? DGStreamAlertView {
            self.alertView = alert
            alert.configureFor(mode: .videoEnded, fromUsername: nil, message: "Press OK to dismiss.", isWaiting: true)
            alert.presentWithin(viewController: self) { (bool) in
                if self.callMode == .merge {
                    self.tapped(forMerge: true, toEnd: true)
                }
                self.alertView = nil
            }
            self.orderDrawViews()
        }
        self.stopSharing()
    }
}
