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
    
    // Recent
    func streamManager(_ manager: DGStreamManager, recentsWithUserIDs userIDs: [NSNumber]) -> [DGStreamRecentProtocol]
    
    // Contacts
    func streamManager(_ manager: DGStreamManager, contactsForUserID userID: NSNumber) -> [DGStreamContactProtocol]
    
    // Conversation
    func streamManager(_ manager: DGStreamManager, conversationsWithID conversationID: String) -> DGStreamConversationProtocol?
    func streamManager(_ manager: DGStreamManager, conversationsWithCurrentUser userID: NSNumber) -> [DGStreamConversationProtocol]
    func streamManager(_ manager: DGStreamManager, conversationWithUsers userIDs: [NSNumber]) -> DGStreamConversationProtocol?
    
    // Message
    func streamManager(_ manager: DGStreamManager, messagesWithConversationID conversationID: String) -> [DGStreamMessageProtocol]
    
    // User
    func streamManager(_ manager: DGStreamManager, userWithUserID userID: NSNumber) -> DGStreamUserProtocol?
    func streamManager(_ manager: DGStreamManager, usersExceptUserID: NSNumber) -> [DGStreamUserProtocol]
}

public protocol DGStreamManagerDataStore {
    func streamManager(_ manager: DGStreamManager, store user: DGStreamUserProtocol)
    func streamManager(_ manager: DGStreamManager, store message: DGStreamMessageProtocol)
    func streamManager(_ manager: DGStreamManager, store conversation: DGStreamConversationProtocol)
    func streamManager(_ manager: DGStreamManager, store recent: DGStreamRecentProtocol)
    func streamManager(_ manager: DGStreamManager, store contact: DGStreamContactProtocol)
}

public class DGStreamManager: NSObject {
    
    public static let instance = DGStreamManager()
    var parentViewController: UIViewController?
    var presentedViewController: UIViewController?
    
    var waitingForResponse:CallMode = .stream
    
    var dataStore: DGStreamManagerDataStore!
    var dataSource: DGStreamManagerDataSource!
    
    var notification:DGBeaconNotification!
    
    public func initializeWith(dataSource: DGStreamManagerDataSource, and dataStore: DGStreamManagerDataStore) {
        self.dataStore = dataStore
        self.dataSource = dataSource
        initialize()
    }
    
    func initialize() {
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
            parentViewController = parent
        }
    }
    
    public func loginWith(user: DGStreamUser, completion: @escaping (_ success: Bool, _ serrorMessage: String) -> Void) {
        DGStreamCore.instance.loginWith(user: user) { (success, errorMessage) in
            completion(success, errorMessage)
        }
    }
    
    //MARK:- PUSH NOTIFICATIONS
    public func receivedPushNotification(_ notification: String) {
//        if let currentUser = DGStreamCore.instance.currentUser, let currentUserID = currentUser.userID {
//            
//        }
    }
}
