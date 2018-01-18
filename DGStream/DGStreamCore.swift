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
    var lastRecent: DGStreamRecent?
    var presentedViewController: UIViewController?
    var chatViewController: DGStreamChatViewController?
    var alertView: DGStreamAlertView?
    
    typealias networkStatusBlock = (_ status: DGStreamNetworkStatus?) -> Void
    var loginCompletion:LoginCompletion?
    var multicastDelegate = QBMulticastDelegate()
    
    var reachability = Reachability()!
    var isReachable:Bool = false
    var isAuthorized:Bool = false
    
    var userDataSource: DGStreamUserDataSource?
    var audioPlayer:DGStreamAudioPlayer!
    
    var onlineDialog: QBChatDialog!
    
    override init() {
        super.init()
    }
    
    func initialize() {
        startReachability()
        QBRTCClient.instance().add(self)
        QBSettings.autoReconnectEnabled = true
        QBChat.instance.addDelegate(self)
        registerForAppDelegateNotifications()
        self.audioPlayer = DGStreamAudioPlayer()
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
            QBChat.instance.connect(with: user) { (user) in
                
            }
        }
    }
    
    func willExit() {
        QBChat.instance.disconnect(completionBlock: { (error) in
            
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
                
                if let loggedInDGUser = DGStreamUser.fromQuickblox(user: qbU4ser) {
                
                    // Store User
                    DGStreamManager.instance.dataStore.streamManager(DGStreamManager.instance, store: loggedInDGUser)
                    
                    self.isAuthorized = true
                    self.registerForRemoteNotifications()
                    self.loginCompletion = completion
                    self.currentUser = loggedInDGUser
                    self.getAllUsers()
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
                
                self.connectToChat()
                
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
    
    func getOnlineUsers() {
        
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
            QBChat.instance.connect(with: user) { (error) in
                if error != nil {
                    self.isAuthorized = false
                    if let completion = self.loginCompletion {
                        completion(false, "Unable to connect to chat.")
                    }
                }
                else {
                    
                    self.onlineDialog = QBChatDialog(dialogID: "5a55347ba28f9a7ed1f1fd45", type: .publicGroup)
                    self.onlineDialog.name = "online"
                    self.onlineDialog.userID = self.currentUser?.userID?.uintValue ?? 0
                    
                    QBRequest.createDialog(self.onlineDialog, successBlock: { (response, dialog) in
                        
                        self.onlineDialog.join(completionBlock: { (error) in
                            
                            print("DID JOIN WITH \(error?.localizedDescription ?? "No Error")")
                            
                            // User Came Online
                            self.onlineDialog.onJoinOccupant = {(userID: UInt) in
                                if let user = self.getOtherUserWith(userID: NSNumber(value: userID)) {
                                    user.isOnline = true
                                    if let tabVC = self.presentedViewController as? DGStreamTabBarViewController {
                                        tabVC.update(user: user, forOnline: true)
                                    }
                                }
                            }
                            
                            // User Went Offline
                            self.onlineDialog.onLeaveOccupant = {(userID: UInt) in
                                if let user = self.getOtherUserWith(userID: NSNumber(value: userID)) {
                                    user.isOnline = false
                                    if let tabVC = self.presentedViewController as? DGStreamTabBarViewController {
                                        tabVC.update(user: user, forOnline: false)
                                    }
                                }
                            }
                            
                            // Get Currently Online Users
                            self.onlineDialog.requestOnlineUsers(completionBlock: { (userIDs, error) in
                                
                                if let userIDs = userIDs as? [NSNumber] {
                                    print("REQUESTED USER IDS \(userIDs)")
                                    for userID in userIDs {
                                        if let user = self.getOtherUserWith(userID: userID) {
                                            user.isOnline = true
                                            if let tabVC = self.presentedViewController as? DGStreamTabBarViewController {
                                                tabVC.update(user: user, forOnline: true)
                                            }
                                        }
                                    }
                                }
                                else {
                                    print("REQUESTED USER IDS WITH NO IDS")
                                }
                                
                                self.isAuthorized = true
                                if let completion = self.loginCompletion {
                                    completion(true, "")
                                }
                                
                            })
                            
                        })
                        
                    }, errorBlock: { (errorResponse) in
                        self.isAuthorized = false
                        if let completion = self.loginCompletion {
                            completion(false, "Unable To Connect To Online Server")
                        }
                    })
                
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
        QBRequest.createMessage(DGStreamMessage.createQuickbloxMessageFrom(message: message), successBlock: { (response, chatMessage) in
            print("Successfully created chat message \(response.isSuccess)")
        }) { (errorResponse) in
            print("Error sending chat message \(errorResponse.error?.error?.localizedDescription ?? "No Error")")
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
                
        // Create Message
        let createdMessage = DGStreamMessage.createDGStreamMessageFrom(chatMessage: message)
        
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
        
        if let text = message.text {
            
            let senderID = NSNumber(value: message.senderID)
            
            print("\n\nDID RECEIVE SYSTEM MESSAGE\n\(text)\nFrom \(senderID)\n\n")
            
            // DRAW START
            if text.hasPrefix("drawStart") {
                if let callVC = self.presentedViewController as? DGStreamCallViewController {
                    callVC.setDrawUserWith(userID: senderID)
                    if let user = self.getOtherUserWith(userID: senderID), let username = user.username {
                        let message = DGStreamMessage()
                        message.message = "\(username) has started drawing."
                        message.isSystem = true
                        callVC.chatPeekView.addCellWith(message: message)
                    }
                }
            }
            // DRAW END
            else if text.hasPrefix("drawEnd") {
                if let callVC = self.presentedViewController as? DGStreamCallViewController {
                    callVC.drawEndWith(userID: senderID)
                    if let user = self.getOtherUserWith(userID: senderID), let username = user.username {
                        let message = DGStreamMessage()
                        message.message = "\(username) has stopped drawing."
                        message.isSystem = true
                        callVC.chatPeekView.addCellWith(message: message)
                    }
                }
            }
            // DRAW IMAGE
            else if text.hasPrefix("drawImage") {
                if let callVC = self.presentedViewController as? DGStreamCallViewController {
                    
                    message.attachments?.forEach({ (attachment) in
                        
                        if let id = attachment.id, let attachmentID = UInt(id) {
                            
                            QBRequest.downloadFile(withID: attachmentID, successBlock: { (response, data) in
                                callVC.drawWithImage(data: data)
                            }, statusBlock: { (request, status) in
                                
                            }, errorBlock: { (response) in
                                print(response.error?.error?.localizedDescription ?? "No Error")
                            })
                            
                        }
                        
                    })
                    
                }
            }
            // FREEZE
            else if text.hasPrefix("prepFreeze"), let callVC = self.presentedViewController as? DGStreamCallViewController {
                callVC.showFreezeActivityIndicator()
            }
            else if text.hasPrefix("freeze") {
                if let callVC = self.presentedViewController as? DGStreamCallViewController {
                    
                    message.attachments?.forEach({ (attachment) in

                        if let id = attachment.id, let attachmentID = UInt(id) {

                            QBRequest.downloadFile(withID: attachmentID, successBlock: { (response, data) in

                                callVC.freeze(imageData: data)

                                if let user = DGStreamCore.instance.getOtherUserWith(userID: callVC.selectedUser), let username = user.username {
                                    let message = DGStreamMessage()
                                    message.message = "\(username) has frozen the screen."
                                    message.isSystem = true
                                    callVC.chatPeekView.addCellWith(message: message)
                                    callVC.hideFreezeActivityIndicator()
                                }

                            }, statusBlock: { (request, status) in

                            }, errorBlock: { (response) in
                                print(response.error?.error?.localizedDescription ?? "No Error")
                            })

                        }

                    })
                }
            }
            else if text.hasPrefix("didFreeze"), let callVC = self.presentedViewController as? DGStreamCallViewController {
                callVC.hideFreezeActivityIndicator()
            }
            // UNFREEZE
            else if text.hasPrefix("unfreeze") {
                if let callVC = self.presentedViewController as? DGStreamCallViewController {
                    
                    callVC.unfreeze()
                    
                    if let user = DGStreamCore.instance.getOtherUserWith(userID: senderID), let username = user.username {
                        let message = DGStreamMessage()
                        message.message = "\(username) has unfrozen the screen."
                        message.isSystem = true
                        callVC.chatPeekView.addCellWith(message: message)
                        callVC.hideFreezeActivityIndicator()
                    }
                }
            }
            else if text.hasPrefix("didUnfreeze"), let callVC = self.presentedViewController as? DGStreamCallViewController {
                callVC.hideFreezeActivityIndicator()
            }
            // MERGE REQUEST
            else if text.hasPrefix("mergeRequest"), let mergeRequestView = UINib(nibName: "DGStreamAlertView", bundle: Bundle(identifier: "com.dataglance.DGStream")).instantiate(withOwner: self, options: nil).first as? DGStreamAlertView, let callVC = self.presentedViewController as? DGStreamCallViewController, let currentUser = self.currentUser, let currentUserID = currentUser.userID {
                
                print("\n\nMERGE REQUEST\n\n")
                
                var fromUsername = ""
                if let fromUser = self.getOtherUserWith(userID: senderID), let username = fromUser.username {
                    fromUsername = username
                }
                callVC.playMergeSound()
                mergeRequestView.configureFor(mode: .mergeRequest, fromUsername: fromUsername, message: "", isWaiting: false)
                
                DispatchQueue.main.async {
                    mergeRequestView.presentWithin(viewController: callVC, fromUsername: fromUsername, block: { (accepted) in
                        if accepted {
                            
                            callVC.startMergeMode()
                            
                            // Send Merge Accepted System Message
                            
                            let acceptedMessage = QBChatMessage()
                            acceptedMessage.text = "mergeAccepted"
                            acceptedMessage.senderID = currentUserID.uintValue
                            acceptedMessage.recipientID = senderID.uintValue
                            
                            QBChat.instance.sendSystemMessage(acceptedMessage, completion: { (error) in
                                print("Sent Accepted Message With \(error?.localizedDescription ?? "NO ERROR")")
                            })
                            
                        }
                        else {
                            
                            // Send Merge Declined System Message
                            
                            let declinedMessage = QBChatMessage()
                            declinedMessage.text = "mergeDeclined"
                            declinedMessage.senderID = currentUserID.uintValue
                            declinedMessage.recipientID = senderID.uintValue
                            
                            QBChat.instance.sendSystemMessage(declinedMessage, completion: { (error) in
                                print("Sent Declined Message With \(error?.localizedDescription ?? "NO ERROR")")
                                
                                mergeRequestView.dismiss()
                                
                                let message = DGStreamMessage()
                                message.message = "\(fromUsername) declined to merge."
                                message.isSystem = true
                                callVC.chatPeekView.addCellWith(message: message)
                            })
                            
                        }
                    })
                }
                
            }
            // MERGE ACCEPTED
            else if text.hasPrefix("mergeAccepted"), let callVC = self.presentedViewController as? DGStreamCallViewController {
                callVC.startMergeMode()
            }
            // MERGE DECLINED
            else if text.hasPrefix("mergeDeclined"), let callVC = self.presentedViewController as? DGStreamCallViewController {
//                callVC.view.subviews
            }
            // MERGE END
            else if text.hasPrefix("mergeEnd"), let callVC = self.presentedViewController as? DGStreamCallViewController {
                callVC.returnToStreamMode()
            }
            // WHITE BOARD START
            else if text.hasPrefix("whiteboardStart"), let callVC = self.presentedViewController as? DGStreamCallViewController {

                callVC.startWhiteBoardFor(userID: senderID)
                
                if let user = self.getOtherUserWith(userID: senderID), let username = user.username {
                    let message = DGStreamMessage()
                    var action = "entered"
                    if callVC.callMode == .board {
                        action = "joined your"
                    }
                    message.message = "\(username) has \(action) White Board."
                    message.isSystem = true
                    callVC.chatPeekView.addCellWith(message: message)
                }
            }
            // WHITE BOARD END
            else if text.hasPrefix("whiteboardEnd"), let callVC = self.presentedViewController as? DGStreamCallViewController {
                
                callVC.endWhiteBoardFor(userID: senderID)
                
                if let user = DGStreamCore.instance.getOtherUserWith(userID: senderID), let username = user.username {
                    let message = DGStreamMessage()
                    message.message = "\(username) has left White Board."
                    message.isSystem = true
                    callVC.chatPeekView.addCellWith(message: message)
                }
            }
        }
        
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
            recent.duration = 0.0
            recent.isAudio = session.conferenceType == .audio
            self.lastRecent = recent
            DGStreamManager.instance.dataStore.streamManager(DGStreamManager.instance, store: recent)
        }
    }
    
    public func session(_ session: QBRTCSession, acceptedByUser userID: NSNumber, userInfo: [String : String]? = nil) {
        print("ACCEPTED BY \(userID)")
        self.audioPlayer.stopAllSounds()
       if let currentUser = self.currentUser, let currentUserID = currentUser.userID, currentUserID != userID {
            let recent = DGStreamRecent()
            recent.date = Date()
            recent.receiverID = userID
            recent.senderID = currentUserID
            recent.isMissed = false
            recent.duration = 1.0
            recent.isAudio = session.conferenceType == .audio
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
            recent.isAudio = session.conferenceType == .audio
            DGStreamManager.instance.dataStore.streamManager(DGStreamManager.instance, store: recent)
        }
    }
    
    public func session(_ session: QBRTCSession, hungUpByUser userID: NSNumber, userInfo: [String : String]? = nil) {
        //print("\(userID) HUNG UP")
        self.audioPlayer.stopAllSounds()
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
        self.audioPlayer.stopAllSounds()
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
                    
                    self.audioPlayer.stopAllSounds()
                    
                    if didAccept {
                        
                        session.acceptCall(nil)
                        
                        let recent = DGStreamRecent()
                        recent.date = Date()
                        recent.duration = 1.0
                        recent.isMissed = false
                        recent.receiver = DGStreamCore.instance.currentUser
                        recent.receiverID = currentUserID
                        recent.recentID = UUID().uuidString
                        recent.sender = DGStreamCore.instance.getOtherUserWith(userID: fromUserID)
                        recent.senderID = fromUserID
                        recent.isAudio = session.conferenceType == .audio
                        self.lastRecent = recent
                        DGStreamManager.instance.dataStore.streamManager(DGStreamManager.instance, store: recent)
                        
                        
                        if let callVC = UIStoryboard(name: "Call", bundle: Bundle(identifier: "com.dataglance.DGStream")).instantiateInitialViewController() as? DGStreamCallViewController, let chatVC = UIStoryboard.init(name: "Chat", bundle: Bundle(identifier: "com.dataglance.DGStream")).instantiateInitialViewController() as? DGStreamChatViewController {
                            
                            if let proto = DGStreamManager.instance.dataSource.streamManager(DGStreamManager.instance, conversationWithUsers: [DGStreamCore.instance.currentUser?.userID ?? 0, fromUserID]), let conversation = DGStreamConversation.createDGStreamConversationsFrom(protocols: [proto]).first {
                                conversation.type = .callConversation
                                chatVC.chatConversation = conversation
                            }
                            
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
                        recent.isAudio = session.conferenceType == .audio
                        
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
