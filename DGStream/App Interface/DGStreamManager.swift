//
//  DGStreamManager.swift
//  DGStream
//
//  Created by Brandon on 9/8/17.
//  Copyright © 2017 Dataglance. All rights reserved.
//

import UIKit
import Quickblox
import QuickbloxWebRTC

public protocol DGStreamManagerDataSource {
    func streamManager(_ manager: DGStreamManager, recentsWithUserIDs userIDs: [NSNumber]) -> [DGStreamRecentProtocol]
    func streamManager(_ manager: DGStreamManager, contactsForUserID userID: NSNumber) -> [DGStreamContactProtocol]
    
    func streamManager(_ manager: DGStreamManager, conversationsWithID conversationID: String) -> DGStreamConversationProtocol?
    func streamManager(_ manager: DGStreamManager, conversationsWithCurrentUser userID: NSNumber) -> [DGStreamConversationProtocol]
    func streamManager(_ manager: DGStreamManager, conversationWithUsers userIDs: [NSNumber]) -> DGStreamConversationProtocol?
    
    func streamManager(_ manager: DGStreamManager, messagesWithConversationID conversationID: String) -> [DGStreamMessageProtocol]
    
    func streamManager(_ manager: DGStreamManager, userWithUserID userID: NSNumber) -> DGStreamUserProtocol?
    func streamManager(_ manager: DGStreamManager, usersExceptUserID: NSNumber) -> [DGStreamUserProtocol]
    
    func streamManager(_ manager: DGStreamManager, recordingCollectionsForUserID userID: NSNumber) -> [DGStreamRecordingCollectionProtocol]
    func streamManager(_ manager: DGStreamManager, recordingsWithPredicates predicates: [NSPredicate]) -> [DGStreamRecordingProtocol]
    
    func streamManager(_ manager: DGStreamManager, documentsForUserID userID: NSNumber) -> [DGStreamDocumentProtocol]
    
    func streamManager(_ manager: DGStreamManager, imagesWithID imageID: String) -> [DGStreamImageProtocol]
}

public protocol DGStreamManagerDataStore {
    func streamManager(_ manager: DGStreamManager, store user: DGStreamUserProtocol)
    func streamManager(_ manager: DGStreamManager, store message: DGStreamMessageProtocol)
    func streamManager(_ manager: DGStreamManager, store conversation: DGStreamConversationProtocol)
    func streamManager(_ manager: DGStreamManager, store recent: DGStreamRecentProtocol)
    func streamManager(_ manager: DGStreamManager, store contact: DGStreamContactProtocol)
    func streamManager(_ manager: DGStreamManager, store recording: DGStreamRecordingProtocol, into collection: DGStreamRecordingCollectionProtocol)
    func streamManager(_ manager: DGStreamManager, store document: DGStreamDocumentProtocol)
    func streamManager(_ manager: DGStreamManager, store image: DGStreamImageProtocol)
}

public protocol DGStreamManagerDelegate {
    func screenToShare() -> UIViewController?
}

public class DGStreamManager: NSObject {
    
    public static let instance = DGStreamManager()
    public var mediaViewControllerDelegate: DGStreamMediaViewControllerProtocol?
    var parentViewController: UIViewController?
    var frameworkContainer: UIView!
    
    var waitingForResponse:CallMode = .stream
    
    var dataStore: DGStreamManagerDataStore!
    var dataSource: DGStreamManagerDataSource!
    var delegate: DGStreamManagerDelegate?
    
    var notification:DGBeaconNotification!
    
    public func initializeWith(dataSource: DGStreamManagerDataSource, and dataStore: DGStreamManagerDataStore) {
        self.dataStore = dataStore
        self.dataSource = dataSource
        initialize()
    }
    
    func initialize() {
        
        registerforDeviceLockNotification()
        
        QBSettings.applicationID = 62345
        QBSettings.authKey = "nARYSQ7S8-yuaAR"
        QBSettings.authSecret = "XWrAtJTC-KvmhBD"
        QBSettings.accountKey = "QyjirWxtvhs2sZvssAo6"
        QBSettings.apiEndpoint = "https://api.quickblox.com"
        QBSettings.chatEndpoint = "chat.quickblox.com"
        
        QBRTCClient.initializeRTC()
        DGStreamSettings.instance.initialize()
        DGStreamCore.instance.initialize()
        self.notification = DGBeaconNotification()
    }
    
    public func placeCallFrom(parent: UIViewController, with user: DGStreamUser) {
        let sdkStoryboard = UIStoryboard(name: "Users", bundle: Bundle(identifier: "com.dataglance.DGStream"))
        if let viewController = sdkStoryboard.instantiateInitialViewController() {
            viewController.modalTransitionStyle = .crossDissolve
            parent.present(viewController, animated: true, completion: nil)
        }
    }
    
    public func loginWith(user: DGStreamUser, completion: @escaping (_ success: Bool, _ serrorMessage: String) -> Void) {
        DGStreamCore.instance.loginWith(user: user) { (success, errorMessage) in
            if success, let currentUser = DGStreamCore.instance.currentUser, let currentUserID = currentUser.userID {
                UserDefaults.standard.set(currentUserID.stringValue, forKey: "LastUser")
                UserDefaults.standard.synchronize()
            }
            completion(success, errorMessage)
        }
    }
    
    public func loginIfNeeded() {
        if let currentUser = DGStreamCore.instance.currentUser {
            DGStreamCore.instance.loginWith(user: currentUser, completion: { (success, errorMessage) in
                print("LOGGED BACK IN!!!")
                DGStreamCore.instance.initialize()
            })
        }
    }
    
    //MARK:- Notifications
    public func registerForPushNotifications(deviceToken: Data) {
        DGStreamCore.instance.registerForRemoteNotificationsWith(deviceToken: deviceToken)
    }
    
    public func unregisterForPushNotifications() {
        DGStreamCore.instance.unregisterFromRemoteNotifications {
            UIApplication.shared.unregisterForRemoteNotifications()
        }
    }
    
    public func receivedPush(notification: [AnyHashable: Any]) {
        
        if let aps = notification["aps"] as? [AnyHashable: Any], let alert = aps["alert"] {
            // Text Message
        }
        else {
            // Incoming Call
            
            guard let toUserID = notification["toUserID"] as? String else {
                print("NO TO USER ID")
                return
            }
            
            guard let fromUsername = notification["fromUsername"] as? String else {
                print("NO FROM USERNAME")
                return
            }
            
            guard let lastUser = UserDefaults.standard.string(forKey: "LastUser") else {
                print("NO LAST USER ID")
                return
            }
            
            if toUserID != lastUser {
                print("MEANT FOR A DIFFERENT USER, DONT SHOW")
                return
            }
            
            //self.notification.pushNotification(title: "Incoming Call", body: fromUsername)
        }

    }
    
    //MARK:- LOCK NOTIFICATIONS
    private func registerforDeviceLockNotification() {
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
            Unmanaged.passUnretained(self).toOpaque(),
            displayStatusChangedCallback,
            "com.apple.springboard.lockcomplete" as CFString,
            nil,
            .deliverImmediately)
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
            Unmanaged.passUnretained(self).toOpaque(),
            displayStatusChangedCallback,
            "com.apple.springboard.lockstate" as CFString,
            nil,     // object
            .deliverImmediately)
    }
    
    private let displayStatusChangedCallback: CFNotificationCallback = { _, cfObserver, cfName, _, _ in
        guard let lockState = cfName?.rawValue as String? else {
            return
        }
        
        let catcher = Unmanaged<DGStreamManager>.fromOpaque(UnsafeRawPointer(OpaquePointer(cfObserver)!)).takeUnretainedValue()
        catcher.displayStatusChanged(lockState)
    }
    
    private func displayStatusChanged(_ lockState: String) {
        // the "com.apple.springboard.lockcomplete" notification will always come after the "com.apple.springboard.lockstate" notification
        print("Darwin notification NAME = \(lockState)")
        if (lockState == "com.apple.springboard.lockcomplete") {
            print("DEVICE LOCKED")
            if let callVC = DGStreamCore.instance.presentedViewController as? DGStreamCallViewController {
                callVC.hangUpButtonTapped(self)
            }
        } else {
            print("LOCK STATUS CHANGED")
        }
    }

}

// MARK:- Screen Sharing
extension DGStreamManager {
    func beginScreenShare() {
        if let delegate = self.delegate,
            let screen = delegate.screenToShare() {
            
            // Fade out framework to display the application
            UIView.animate(withDuration: 0.25, animations: {
                self.frameworkContainer.alpha = 0
            })
            
            // Share this screen's view
            DGStreamCore.instance.share(screen: screen)
        }
    }
    func returnToFramework() {
        // When the button is tapped within the application to return to call
    }
}

extension DGStreamManager: DGStreamMediaCollectionViewControllerDelegate {
    public func didLoadAnd(hasNoData: Bool) {
        if let mediaViewController = DGStreamCore.instance.mediaViewController as? DGStreamMediaViewController{
            if hasNoData {
                mediaViewController.collectionViewContainer.isHidden = true
                mediaViewController.selectButton.isEnabled = false
            }
            else {
                mediaViewController.collectionViewContainer.isHidden = false
                mediaViewController.selectButton.isEnabled = true
            }
        }
    }
    
    public func didSelect(recording: DGStreamRecordingProtocol) {
        if let mediaViewController = DGStreamCore.instance.mediaViewController as? DGStreamMediaViewController{
            //mediaViewController.
            if let rec = DGStreamRecording.createDGStreamRecordingsFor(protocols: [recording]).first {
                mediaViewController.didSelect(recording: rec)
            }
        }
    }
    public func didMakeSelection() {
        if let mediaViewController = DGStreamCore.instance.mediaViewController as? DGStreamMediaViewController{
            mediaViewController.deleteButtonItem.isEnabled = true
        }
    }
}
