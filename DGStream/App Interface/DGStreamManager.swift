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
    
    // Conversation
    func streamManager(_ manager: DGStreamManager, conversationsWithID conversationID: String) -> DGStreamConversationProtocol?
    func streamManager(_ manager: DGStreamManager, conversationsWithCurrentUser userID: NSNumber) -> [DGStreamConversationProtocol]
    func streamManager(_ manager: DGStreamManager, conversationWithUsers userIDs: [NSNumber]) -> DGStreamConversationProtocol?
    
    func streamManager(_ manager: DGStreamManager, messagesWithConversationID conversationID: String) -> [DGStreamMessageProtocol]
    
    func streamManager(_ manager: DGStreamManager, userWithUserID userID: NSNumber) -> DGStreamUserProtocol?
    func streamManager(_ manager: DGStreamManager, usersExceptUserID: NSNumber) -> [DGStreamUserProtocol]
    
    func streamManager(_ manager: DGStreamManager, recordingCollectionsForUserID userID: NSNumber) -> [DGStreamRecordingCollectionProtocol]
    func streamManager(_ manager: DGStreamManager, recordingsForUserID userID:NSNumber, documentNumber: String, title: String?) -> [DGStreamRecordingProtocol]
}

public protocol DGStreamManagerDataStore {
    func streamManager(_ manager: DGStreamManager, store user: DGStreamUserProtocol)
    func streamManager(_ manager: DGStreamManager, store message: DGStreamMessageProtocol)
    func streamManager(_ manager: DGStreamManager, store conversation: DGStreamConversationProtocol)
    func streamManager(_ manager: DGStreamManager, store recent: DGStreamRecentProtocol)
    func streamManager(_ manager: DGStreamManager, store contact: DGStreamContactProtocol)
    func streamManager(_ manager: DGStreamManager, store recording: DGStreamRecordingProtocol, into collection: DGStreamRecordingCollectionProtocol)
}

public protocol DGStreamManagerDelegate {
    func screenToShare() -> UIViewController?
}

public class DGStreamManager: NSObject {
    
    public static let instance = DGStreamManager()
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
