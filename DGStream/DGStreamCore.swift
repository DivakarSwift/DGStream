//
//  DGStreamCore.swift
//  DGStream
//
//  Created by Brandon on 9/11/17.
//  Copyright © 2017 Dataglance. All rights reserved.
//

import UIKit
import Quickblox
import QuickbloxWebRTC
import SystemConfiguration
import UserNotifications

enum DGStreamNetworkStatus {
    case notReachable
    case wifi
    case wwan
}

enum DGStreamErrorDomain {
    case signUp
    case login
    case logout
    case chat
}

typealias Completion = () -> Void
typealias LoginCompletion = (_ success: Bool, _ errorMessage: String) -> Void

class DGStreamCore: NSObject {
    
    static let instance = DGStreamCore()
    
    var currentUser: DGStreamUser?
    var allUsers: [DGStreamUser] = []
    var presentedViewController: UIViewController?
    var chatViewController: DGStreamChatViewController?
    var alertView: DGStreamAlertView?
    
    typealias networkStatusBlock = (_ status: DGStreamNetworkStatus?) -> Void
    var loginCompletion:LoginCompletion?
    var multicastDelegate = QBMulticastDelegate()
    //var profile: QBProfile!
    
    var reachability = Reachability()!
    var isReachable:Bool = false
    var isAuthorized:Bool = false
    
    var userDataSource: DGStreamUserDataSource?
    
    var audioPlayer:DGStreamAudioPlayer!
    
    override init() {
        super.init()
    }
    
    func initialize() {
        startReachability()
        QBRTCClient.instance().add(self)
        QBSettings.setAutoReconnectEnabled(true)
        QBChat.instance().addDelegate(self)
        registerForAppDelegateNotifications()
        self.audioPlayer = DGStreamAudioPlayer()
        self.getAllUsers()
    }
    
    func add(delegate: Any) {
        self.multicastDelegate.addDelegate(delegate)
    }
    
    //MARK:- App Events
    func registerForAppDelegateNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: Notification.Name.UIApplicationWillEnterForeground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willExit), name: Notification.Name.UIApplicationWillTerminate, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willExit), name: Notification.Name.UIApplicationDidEnterBackground, object: nil)
    }
    
    func unregisterForAppDelegateNotifications() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIApplicationWillEnterForeground, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIApplicationWillTerminate, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIApplicationDidEnterBackground, object: nil)
    }
    
    func willEnterForeground() {
        if let user = DGStreamCore.instance.currentUser?.asQuickbloxUser() {
            QBChat.instance().connect(with: user) { (user) in
                
            }
        }
    }
    
    func willExit() {
        QBChat.instance().disconnect(completionBlock: { (error) in
            
        })
    }
    
    //MARK:- Reachability
    func startReachability() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged), name: ReachabilityChangedNotification, object: nil)
        
        do {
            try reachability.startNotifier()
            
        }
        catch let error { print("Reachability Error \(error.localizedDescription)") }
        
        if reachability.currentReachabilityStatus != .notReachable {
            isReachable = true
        }
        else {
            isReachable = false
        }
    }
    
    func reachabilityChanged() {
        if reachability.currentReachabilityStatus != .notReachable {
            isReachable = true
        }
        else {
            isReachable = false
        }
    }
    
    func clearProfile() {
        
    }
    
    func set(loginStatus: String) {
        
    }
    
    func loginWith(user: DGStreamUser, completion: @escaping LoginCompletion) {
        
        if self.isAuthorized {
            self.connectToChat()
            return
        }
        
        if let username = user.username, let password = user.password {
            QBRequest.logIn(withUserLogin: username, password: password, successBlock: { (response, qbU4ser) in
                
                if let quickbloxUser = qbU4ser, let loggedInDGUser = DGStreamUser.fromQuickblox(user: quickbloxUser) {
                
                    // Store User
                    DGStreamManager.instance.dataStore.streamManager(DGStreamManager.instance, store: loggedInDGUser)
                    
                    self.isAuthorized = true
                    self.registerForRemoteNotifications()
                    self.loginCompletion = completion
                    self.currentUser = loggedInDGUser
                    self.getAllUsers()
                    self.connectToChat()
                }
                else {
                    completion(false, "No QB User.")
                }
                
            }, errorBlock: { (response) in
                var errorMessage = "Login Error"
                if let qbError = response.error, let error = qbError.error {
                    errorMessage = error.localizedDescription
                }
                completion(false, errorMessage)
            })
        }
    }
    
    func getAllUsers() {
        
        // If there is connection check against Quickblox to find possible new users
        if DGStreamCore.instance.isReachable {
            DGStreamUserOperationQueue().getUsersWith(tags: ["dev"]) { (success, errorMessage, users) in
                print("Downloaded And Saving All Users \(users)")
                self.allUsers = users
                // Check if users exists in CoreData, if not, add to CoreData
                // Also, do not include current user
                for u in users {
                    if let userID = u.userID, let _ = DGStreamManager.instance.dataSource.streamManager(DGStreamManager.instance, userWithUserID: userID) {
                        // User Exists
                    }
                    else {
                        // User Doesn't Exist
                        DGStreamManager.instance.dataStore.streamManager(DGStreamManager.instance, store: u)
                        
                        // Create Contact
                        let contact = DGStreamContact.createDGStreamContactFrom(user: u)
                        DGStreamManager.instance.dataStore.streamManager(DGStreamManager.instance, store: contact)
                    }
                    
                }
                
            }
        }
        else {
            
            // Not online, gather from CoreData
            if let currentUser = self.currentUser, let currentUserID = currentUser.userID {
                var all:[DGStreamUser] = []
                let protos = DGStreamManager.instance.dataSource.streamManager(DGStreamManager.instance, usersExceptUserID: currentUserID)
                for proto in protos {
                    let user = DGStreamUser.createDGStreamUserFrom(proto: proto)
                    all.append(user)
                }
                self.allUsers = all
            }
        }
    
    }
    
    func getOtherUserWith(userID: NSNumber) -> DGStreamUser? {
        return self.allUsers.filter { (user) -> Bool in
            return user.userID == userID
            }.first
    }
    
    func getOtherUserWith(username: String) -> DGStreamUser? {
        return self.allUsers.filter { (user) -> Bool in
            return user.username == username
            }.first
    }
    
    //MARK:- Chat
    func connectToChat() {
        if let currentUser = self.currentUser {
            currentUser.password = "dataglance"
            let user = currentUser.asQuickbloxUser()
            QBChat.instance().connect(with: user) { (error) in
                if error != nil {
                    self.isAuthorized = false
                    if let completion = self.loginCompletion {
                        completion(false, "Unable to connect to chat.")
                    }
                }
                else {
                    self.isAuthorized = true
                    if let completion = self.loginCompletion {
                        completion(true, "")
                    }
                }
            }
        }
    }
    
    func startConversationWith(users: [NSNumber]) {
        
        let dialog = QBChatDialog(dialogID: "FontVariation.conversationID", type: .private)
        QBRequest.createDialog(dialog, successBlock: { (response, dialog) in
            //
        }) { (response) in
            // Error
        }
    }
    
    func sendChat(message: DGStreamMessage) {
//        let quickbloxMessage = DGStreamMessage.createQuickbloxMessageFrom(message: message)
//        QBRequest.send(quickbloxMessage, successBlock: { (response, chatMessage) in
//            if response.isSuccess {
//                print("Successfully Send Message")
//                DGStreamManager.instance.dataStore.streamManager(DGStreamManager.instance, store: message)
//            }
//        }) { (error) in
//            print("Error Sending Chat Message")
//        }
        
        DGStreamNotification.sendText(message.message, from: message.senderID, to: message.receiverID, for: message.conversationID) { (success, errorMessage) in
            print("SEND TEXT \(success) \(errorMessage ?? "No Error")")
        }
        
    }
    
    // Remote Notifications
    func registerForRemoteNotifications() {
        let app = UIApplication.shared
        app.registerForRemoteNotifications()
    }
    
    func unregisterForRemoteNotificationsWith(deviceToken: Data) {
        if let id = UIDevice.current.identifierForVendor?.uuidString {
            let subscription = QBMSubscription()
            subscription.notificationChannel = .APNS
            subscription.deviceUDID = id
                subscription.deviceToken = deviceToken
            QBRequest.createSubscription(subscription, successBlock: { (response, subscriptions) in
                
            }) { (response) in
                
            }
        }
    }
    
    func unsubscribeFromRemoteNotifications(completion: @escaping Completion) {
        if let id = UIDevice.current.identifierForVendor?.uuidString {
            QBRequest.unregisterSubscription(forUniqueDeviceIdentifier: id, successBlock: { (response) in
                completion()
            }) { (error) in
                completion()
            }
        }
    }
    
    func handle(error: Error, domain: DGStreamErrorDomain) {
        
    }

}

extension DGStreamCore: QBChatDelegate {
    func chatDidConnect() {
        print("Did Connect To Chat!")
    }
    func chatDidReconnect() {
        
    }
    func chatDidAccidentallyDisconnect() {
        print("Did Acceidentally Disconnect From Chat!")
    }
    func chatDidReceive(_ message: QBChatMessage) {
        
        // Received text message
        
        // Create Message
        let createdMessage = DGStreamMessage.createDGStreamMessageFrom(chatMessage: message)
        DGStreamManager.instance.dataStore.streamManager(DGStreamManager.instance, store: createdMessage)

        // Get the conversation
        if let conversationID = message.dialogID {
            
            if let foundConversation = DGStreamManager.instance.dataSource.streamManager(DGStreamManager.instance, conversationsWithID: conversationID) {
                print("Found Conversation \(conversationID)")
//                let conversation = DGStreamConversation.createDGStreamConversationFrom(proto: foundConversation)
//                DGStreamManager.instance.dataStore.streamManager(DGStreamManager.instance, store: conversation)
            }
            else {
                print("Creating New Conversation")
                let newConversation = DGStreamConversation()
                newConversation.conversationID = conversationID
                newConversation.userIDs = [createdMessage.receiverID, createdMessage.senderID]
                if newConversation.userIDs.count == 2 {
                    newConversation.type = .privateConversation
                }
                DGStreamManager.instance.dataStore.streamManager(DGStreamManager.instance, store: newConversation)
            }
            
        }
        
        if let chatVC = DGStreamCore.instance.chatViewController {
            chatVC.didReceive(message: createdMessage)
        }
        
    }
    func chatDidFail(withStreamError error: Error?) {
        
    }
    func chatDidNotConnectWithError(_ error: Error?) {
        print("Chat Did Not Connect With Error \(error?.localizedDescription ?? "")")
    }
    func chatDidReceive(_ privacyList: QBPrivacyList) {
        
    }
    func chatDidSetPrivacyList(withName name: String) {
        
    }
    func chatDidRemovedPrivacyList(withName name: String) {
        
    }
    func chatDidSetActivePrivacyList(withName name: String) {
        
    }
    func chatDidSetDefaultPrivacyList(withName name: String) {
        
    }
    func chatDidReceivePrivacyListNames(_ listNames: [String]) {
        
    }
    func chatDidReceiveSystemMessage(_ message: QBChatMessage) {
        
    }
    func chatContactListDidChange(_ contactList: QBContactList) {
        
    }
    func chatDidReceiveContactAddRequest(fromUser userID: UInt) {
        
    }
    func chatDidNotReceivePrivacyListNamesDue(toError error: Any?) {
        
    }
    func chatDidReceiveAcceptContactRequest(fromUser userID: UInt) {
        
    }
    func chatDidReceiveRejectContactRequest(fromUser userID: UInt) {
        
    }
    func chatDidNotSetPrivacyList(withName name: String, error: Any?) {
        
    }
    func chatDidNotReceivePrivacyList(withName name: String, error: Any?) {
        
    }
    func chatDidNotSetActivePrivacyList(withName name: String, error: Any?) {
        
    }
    func chatDidNotSetDefaultPrivacyList(withName name: String, error: Any?) {
        
    }
    func chatDidReceivePresence(withStatus status: String, fromUser userID: Int) {
        
    }
    func chatRoomDidReceive(_ message: QBChatMessage, fromDialogID dialogID: String) {
        print("Chatroom Did Receive Message")
    }
    func chatDidReadMessage(withID messageID: String, dialogID: String, readerID: UInt) {
        
    }
    func chatDidReceiveContactItemActivity(_ userID: UInt, isOnline: Bool, status: String?) {
        
    }
    func chatDidDeliverMessage(withID messageID: String, dialogID: String, toUserID userID: UInt) {
        
    }
}

extension DGStreamCore: QBRTCClientDelegate {
    public func session(_ session: QBRTCBaseSession, updatedStatsReport report: QBRTCStatsReport, forUserID userID: NSNumber) {
        
//        let result = report.statsString()
//        print(result)
    }
    
    public func session(_ session: QBRTCSession, userDidNotRespond userID: NSNumber) {
        print("USER \(userID) DID NOT RESPOND")
        if let currentUser = self.currentUser, let currentUserID = currentUser.userID, currentUserID != userID {
            let recent = DGStreamRecent()
            recent.date = Date()
            recent.receiverID = userID
            recent.senderID = currentUserID
            recent.isMissed = true
            recent.duration = 0.0 // Determine from timer
            DGStreamManager.instance.dataStore.streamManager(DGStreamManager.instance, store: recent)
        }
    }
    
    public func session(_ session: QBRTCSession, acceptedByUser userID: NSNumber, userInfo: [String : String]? = nil) {
        print("ACCEPTED BY \(userID)")
       if let currentUser = self.currentUser, let currentUserID = currentUser.userID, currentUserID != userID {
            self.audioPlayer.stopAllSounds()
            let recent = DGStreamRecent()
            recent.date = Date()
            recent.receiverID = userID
            recent.senderID = currentUserID
            recent.isMissed = false
            recent.duration = 10.0 // Determine from timer
            DGStreamManager.instance.dataStore.streamManager(DGStreamManager.instance, store: recent)
        }
    }
    
    public func session(_ session: QBRTCSession, rejectedByUser userID: NSNumber, userInfo: [String : String]? = nil) {
        print("REJECTED BY \(userID)")
        self.audioPlayer.stopAllSounds()
        if let currentUser = self.currentUser, let currentUserID = currentUser.userID, currentUserID != userID {
            let recent = DGStreamRecent()
            recent.date = Date()
            recent.receiverID = userID
            recent.senderID = currentUserID
            recent.isMissed = true
            recent.duration = 0.0
            DGStreamManager.instance.dataStore.streamManager(DGStreamManager.instance, store: recent)
        }
    }
    
    public func session(_ session: QBRTCSession, hungUpByUser userID: NSNumber, userInfo: [String : String]? = nil) {
        //print("\(userID) HUNG UP")
        self.audioPlayer.stopAllSounds()
        if let currentUser = self.currentUser, let currentUserID = currentUser.userID, currentUserID != userID {
            let recent = DGStreamRecent()
            recent.date = Date()
            recent.receiverID = userID
            recent.senderID = currentUserID
            recent.isMissed = false
            recent.duration = 10.0 // Determine from timer
            DGStreamManager.instance.dataStore.streamManager(DGStreamManager.instance, store: recent)
        }
    }
    
    public func session(_ session: QBRTCBaseSession, receivedRemoteVideoTrack videoTrack: QBRTCVideoTrack, fromUser userID: NSNumber) {
        print("RECEIVED REMOTE VIDEO TRACK FROM \(userID)")
    }
    
    public func session(_ session: QBRTCBaseSession, receivedRemoteAudioTrack audioTrack: QBRTCAudioTrack, fromUser userID: NSNumber) {
        print("RECEIVED REMOTE AUDIO TRACK FROM \(userID)")
    }
    
    public func session(_ session: QBRTCBaseSession, startedConnectingToUser userID: NSNumber) {
        print("STARTED CONNECTING TO \(userID)")
    }
    
    public func session(_ session: QBRTCBaseSession, connectedToUser userID: NSNumber) {
        print("CONNECTED TO \(userID)")
        if let currentUser = self.currentUser, let currentUserID = currentUser.userID, userID != currentUserID {
            DGStreamCore.instance.audioPlayer.stopAllSounds()
        }
    }
    
    public func session(_ session: QBRTCBaseSession, disconnectedFromUser userID: NSNumber) {
        //print("DISCONNECTED FROM \(userID)")
    
    }
    
    public func session(_ session: QBRTCBaseSession, connectionClosedForUser userID: NSNumber) {
        //print("CONNECTIONG CLOSED FOR \(userID)")
    }
    
    public func session(_ session: QBRTCBaseSession, connectionFailedForUser userID: NSNumber) {
        //print("CONNECTION FAILED FOR \(userID)")
    }
    
    public func session(_ session: QBRTCBaseSession, didChange state: QBRTCSessionState) {
        //print("SESSION STATE CHANGED \(state) FOR CURRENT USER")
    }
    
    public func session(_ session: QBRTCBaseSession, didChange state: QBRTCConnectionState, forUser userID: NSNumber) {
        //print("SESSION STATE CHANGED \(state) FOR \(userID)")
    }
    
    public func didReceiveNewSession(_ session: QBRTCSession, userInfo: [String : String]? = nil) {
        print("DID RECEIVE NEW SESSION")
        
        if let currentUser = self.currentUser, let currentUserID = currentUser.userID {
            var fromUsername = "Unknown"
            var fromUserID: NSNumber = NSNumber(value: 0)
            if let info = userInfo, let username = info["username"] {
                fromUsername = username
            }
            
            if let otherUser = self.getOtherUserWith(username: fromUsername), let otherUserID = otherUser.userID {
                fromUserID = otherUserID
            }
            
            if let vc = self.presentedViewController, vc is DGStreamCallViewController == false, self.alertView == nil, let incomingCallView = UINib(nibName: "DGStreamAlertView", bundle: Bundle(identifier: "com.dataglance.DGStream")).instantiate(withOwner: self, options: nil).first as? DGStreamAlertView {
                
                var mode:AlertMode = .incomingVideoCall
                if session.conferenceType == .audio {
                    mode = .incomingAudioCall
                }
                self.audioPlayer.ringFor(receiver: true)
                incomingCallView.configureFor(mode: mode, fromUsername: fromUsername, message: "", isWaiting: false)
                self.alertView = incomingCallView
                incomingCallView.presentWithin(viewController: vc, fromUsername: fromUsername, block: { (didAccept) in
                    
                    self.alertView = nil
                    
                    if didAccept {
                        
                        self.audioPlayer.stopAllSounds()
                        
                        session.acceptCall(nil)
                        
                        let recent = DGStreamRecent()
                        recent.date = Date()
                        recent.duration = 0.0
                        recent.isMissed = false
                        recent.receiver = DGStreamCore.instance.currentUser
                        recent.receiverID = currentUserID
                        recent.recentID = UUID().uuidString
                        recent.sender = DGStreamCore.instance.getOtherUserWith(userID: fromUserID)
                        recent.senderID = fromUserID
                        DGStreamManager.instance.dataStore.streamManager(DGStreamManager.instance, store: recent)
                        
                        
                        if let callVC = UIStoryboard(name: "Call", bundle: Bundle(identifier: "com.dataglance.DGStream")).instantiateInitialViewController() as? DGStreamCallViewController, let chatVC = UIStoryboard.init(name: "Chat", bundle: Bundle(identifier: "com.dataglance.DGStream")).instantiateInitialViewController() as? DGStreamChatViewController {
                            
                            let conversation = DGStreamConversation()
                            conversation.conversationID = "0"
                            conversation.userIDs = [fromUserID]
                            conversation.type = .callConversation
                            
                            chatVC.chatConversation = conversation
                            chatVC.delegate = callVC
                            
                            callVC.chatVC = chatVC
                            callVC.session = session
                            callVC.selectedUser = fromUserID
                            
                            if mode == .incomingAudioCall {
                                callVC.isAudioCall = true
                            }
                            
                            if let navigationController = vc.navigationController {
                                navigationController.pushViewController(callVC, animated: true)
                            }
                            else {
                                vc.present(callVC, animated: true, completion: nil)
                            }
                                                        
                        }
                        
                    }
                    else {
                        session.rejectCall(nil)
                        
                        let recent = DGStreamRecent()
                        recent.date = Date()
                        recent.duration = 0.0
                        recent.isMissed = true
                        recent.receiver = DGStreamCore.instance.currentUser
                        recent.receiverID = currentUserID
                        recent.recentID = UUID().uuidString
                        recent.sender = DGStreamCore.instance.getOtherUserWith(userID: fromUserID)
                        recent.senderID = fromUserID
                        DGStreamManager.instance.dataStore.streamManager(DGStreamManager.instance, store: recent)
                    }
                })
            }
        }

    }
    
    public func sessionDidClose(_ session: QBRTCSession) {
//        print("SESSION CLOSED")
    }
    
}
