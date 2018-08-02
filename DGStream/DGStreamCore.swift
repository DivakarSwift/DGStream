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

enum DGStreamOnlineStatus {
    case online
    case recent
    case away
    case busy
    case offline
}

typealias Completion = () -> Void
typealias LocalVideoCompletion = (_ success: Bool) -> Void
typealias LoginCompletion = (_ success: Bool, _ errorMessage: String) -> Void

let incomingCallID = "&8274"

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
    
    var didRegister: Bool = false
    var didStartReachability = false
    
    var cameraCapture: QBRTCCameraCapture!
    var localVideoCompletion: LocalVideoCompletion?
    
    var refreshTimer: Timer?
    
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
    
//    func initializeLocalVideoWith(completion: @escaping LocalVideoCompletion) {
////        completion(true)
////        return
//        self.localVideoCompletion = completion
//        if self.cameraCapture == nil {
//            let format = QBRTCVideoFormat(width: 640, height: 480, frameRate: 30, pixelFormat: QBRTCPixelFormat.format420f)
//            self.cameraCapture = QBRTCCameraCapture(videoFormat: format, position: .front)
//        }
//        self.cameraCapture?.startSession {
//            print("START LOCAL SESSION")
////            self.session?.localMediaStream.videoTrack.videoCapture = self.cameraCapture
////            self.bufferQueue = self.cameraCapture?.videoQueue
////            self.recordingManager.startRecordingWith(localCaptureSession: self.cameraCapture!.captureSession, remoteRecorder: self.session!.recorder!, bufferQueue: self.bufferQueue!, documentNumber: "01234-56789", isMerged: false, delegate: self)
//            for output in self.cameraCapture.captureSession.outputs {
//                if let dataOutput = output as? AVCaptureVideoDataOutput {
//                    print("setSampleBufferDelegate")
//                    dataOutput.setSampleBufferDelegate(self, queue: self.cameraCapture.videoQueue)
//                }
//            }
//            
//        }
//    }
    
    func stopLocalVideo(completion: @escaping LocalVideoCompletion) {
        self.cameraCapture?.stopSession {
            self.cameraCapture = nil
            completion(true)
        }
    }
    
    func flipCamera(toFront: Bool) {
        if toFront == true && self.cameraCapture?.position == .back || toFront == false && self.cameraCapture?.position == .front {
            self.cameraCapture?.configureSession {
                if toFront {
                    self.cameraCapture?.position = .front
                }
                else {
                    self.cameraCapture?.position = .back
                }
            }
        }
    }
    
    func add(delegate: Any) {
        self.multicastDelegate.addDelegate(delegate)
    }
    
    //MARK:- App Events
    func registerForAppDelegateNotifications() {
        if self.didRegister == false {
            self.didRegister = true
            NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: Notification.Name.UIApplicationWillEnterForeground, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(willExit), name: Notification.Name.UIApplicationWillTerminate, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(willExit), name: Notification.Name.UIApplicationDidEnterBackground, object: nil)
        }
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
        if didStartReachability == false {
            self.didStartReachability = true
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
            self.connectToChatWith(user: user.asQuickbloxUser())
            return
        }

        if let username = user.username {
            QBRequest.logIn(withUserLogin: username, password: "dataglance", successBlock: { (response, qbU4ser) in
                
                if let loggedInDGUser = DGStreamUser.fromQuickblox(user: qbU4ser) {
                    
                    loggedInDGUser.password = user.password
                
                    // Store User
                    DGStreamManager.instance.dataStore.streamManager(DGStreamManager.instance, store: loggedInDGUser)
                    
                    self.isAuthorized = true
                    self.registerForRemoteNotifications()
                    self.loginCompletion = completion
                    self.currentUser = loggedInDGUser
                    self.getAllUsers {
                        self.connectToChatWith(user: qbU4ser)
                        self.startRefreshTimer()
                        
                        // TODO: REMOVE FOR PRODUCTION
                        QBRequest.downloadFile(withID: 8998848, successBlock: { (response, data) in
                            
                            let fileID = "8998848"
                            let documentsPath = DGStreamFileManager.applicationDocumentsDirectory()
                            let newPDFPath = documentsPath.appendingPathComponent(fileID).appendingPathExtension("pdf")
                            do {
                                try data.write(to: newPDFPath)
                                print("Write Move Item")
                            }
                            catch let error {
                                print("Could Not Write Item \(error.localizedDescription)")
                            }
                            
                        }, statusBlock: { (request, status) in
                            
                        }, errorBlock: { (response) in
                            print(response.error?.error?.localizedDescription ?? "No Error")
                        })
    
                    }
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
    
    func getAllUsers(completion: @escaping () -> Void) {

        // If there is connection check against Quickblox to find possible new users
        if DGStreamCore.instance.isReachable,
            let currentUser = self.currentUser,
            let currentUserID = currentUser.userID {
            DGStreamUserOperationQueue().getUsersWith(tags: ["dev"]) { (success, errorMessage, users) in
                print("Downloaded And Saving All Users \(users)")
                self.allUsers = users
                // Check if users exists in CoreData, if not, add to CoreData
                // Also, do not include current user
                for u in users {
                    var otherUserID: NSNumber = NSNumber(value: 0)
                    if let userID = u.userID, let _ = DGStreamManager.instance.dataSource.streamManager(DGStreamManager.instance, userWithUserID: userID) {
                        // User Exists
                        otherUserID = userID
                    }
                    else if let userID = u.userID {
                        
                        otherUserID = userID
                        
                        // User Doesn't Exist
                        DGStreamManager.instance.dataStore.streamManager(DGStreamManager.instance, store: u)
                        
                        // Create Contact
                        let contact = DGStreamContact.createDGStreamContactFrom(user: u)
                        DGStreamManager.instance.dataStore.streamManager(DGStreamManager.instance, store: contact)
                    }
                    
                    let dialog = QBChatDialog(dialogID: nil, type: .private)
                    dialog.occupantIDs = [otherUserID]
                    
                    QBRequest.createDialog(dialog, successBlock: { (response, chatDialogs) in
                        print("CREATE DIALOG WITH USER \(otherUserID) \(response.isSuccess)")
                    }, errorBlock: { (errorResponse) in
                        print("ERROR CREATING DIALOG WITH USER \(otherUserID) \(errorResponse.error?.error?.localizedDescription ?? "No Error")")
                    })
                    
                }
                
                completion()
                
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
            completion()
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
    
    //MARK:- Refresh
    func startRefreshTimer() {
        if let timer = self.refreshTimer {
            timer.invalidate()
            self.refreshTimer = nil
        }
        let threeMinutes:Double = 189.0
        self.refreshTimer = Timer.scheduledTimer(withTimeInterval: threeMinutes, repeats: true, block: { (timer) in
            self.getAllUsers {
                if let tab = self.presentedViewController as? DGStreamTabBarViewController {
                    tab.loadRecents(searchText: tab.searchBar.text)
                    tab.loadContactsWith(option: tab.selectedContactsOption, searchText: tab.searchBar.text)
                    tab.tableView.reloadData()
                    print("\n\nRELOADED USERS\n\n")
                }
            }
        })
    }
    
    func onlineStatusFor(user: DGStreamUser) -> DGStreamOnlineStatus {
        if let lastSeen = user.lastSeen {
            let since = lastSeen.timeIntervalSinceNow.magnitude
            let twoMinutes = 120.0
            let tenMinutes = 600.0
            let thirtyMinutes = 1800.0
            if since < twoMinutes {
                return .online
            }
            else if since < tenMinutes {
                return .recent
            }
            else if since < thirtyMinutes {
                return .away
            }
            else {
                return .offline
            }
        }
        return .offline
    }
    
    //MARK:- Chat
    func connectToChatWith(user: QBUUser) {
        print("connectToChatWith \(user.login ?? "No Login") \(user.password ?? "No Password")")
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
    
    func startConversationWith(users: [NSNumber]) {
        
        let dialog = QBChatDialog(dialogID: "FontVariation.conversationID", type: .private)
        QBRequest.createDialog(dialog, successBlock: { (response, dialog) in
            //
        }) { (response) in
            // Error
        }
    }
    
    func sendChat(message: DGStreamMessage) {
        DGStreamMessage.createQuickbloxMessageFrom(message: message) { (chatMessage) in
            if let chatMessage = chatMessage {
                QBRequest.createMessage( chatMessage, successBlock: { (response, chatMessage) in
                    print("Successfully created chat message \(response.isSuccess)")
                }) { (errorResponse) in
                    print("Error sending chat message \(errorResponse.error?.error?.localizedDescription ?? "No Error")")
                }
            }
            else {
                // Error
            }
        }
    }
    
    func sendUser(image: UIImage) {
        if let currentUser = self.currentUser, let currentUserID = currentUser.userID, let imageData = UIImagePNGRepresentation(image), let fileID = NSString.init(string: UUID().uuidString).components(separatedBy: "-").first {
            
            QBRequest.tUploadFile(imageData, fileName: fileID, contentType: "image/png", isPublic: true, successBlock: { (response, blob) in
                
                _ = self.allUsers.filter({ (user) -> Bool in
                    return user.isOnline == true
                })
                
                let userImageMessage = QBChatMessage()
                userImageMessage.text = "updateUserImage"
                userImageMessage.senderID = currentUserID.uintValue
                userImageMessage.recipientID = 0
                
                let uploadedFileID: UInt = blob.id
                let attachment: QBChatAttachment = QBChatAttachment()
                attachment.type = "image"
                attachment.id = String(uploadedFileID)
                userImageMessage.attachments = [attachment]
                
                QBChat.instance.sendSystemMessage(userImageMessage, completion: { (error) in
                    print("Sent Freeze System Message With \(error?.localizedDescription ?? "No Error")")
                })
                
            }, statusBlock: { (request, status) in
                
            }, errorBlock: { (response) in
                
            })
            
        }
    }
    
    //MARK:- Screen Share
    func share(screen: UIViewController) {
        if let callVC = self.presentedViewController as? DGStreamCallViewController {
            callVC.captureScreen(screenView: screen.view)
        }
    }
    
    //MARK:- Remote Notifications
    func registerForRemoteNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: []) { (granted, error) in
            
            guard error == nil else {
                //Display Error.. Handle Error.. etc..
                return
            }
            
            if granted {
                //Do stuff here..
                
                //Register for RemoteNotifications. Your Remote Notifications can display alerts now :)
                DispatchQueue.main.async {
                    let app = UIApplication.shared
                    app.registerForRemoteNotifications()
                }
            }
            else {
                //Handle user denying permissions..
            }
        }
    }
    
    func registerForRemoteNotificationsWith(deviceToken: Data) {
        self.removePreviousSubscribedDevice {
            if let id = UIDevice.current.identifierForVendor?.uuidString {
                let subscription = QBMSubscription()
                subscription.notificationChannel = .APNS
                subscription.deviceUDID = id
                subscription.deviceToken = deviceToken
                QBRequest.createSubscription(subscription, successBlock: { (response, subscriptions) in
                    print("\n\nDID REGISTER SUBSCRIPTION")
                }) { (response) in
                    print("\n\nDID NOT REGISTER SUBSCRIPTION")
                }
            }
        }
    }
    
    func unregisterFromRemoteNotifications(completion: @escaping Completion) {
        //if let id = UIDevice.current.identifierForVendor?.uuidString {
//            QBRequest.unregisterSubscription(forUniqueDeviceIdentifier: id, successBlock: { (response) in
//                print("\n\nDID UNREGISTER SUBSCRIPTION")
//                completion()
//            }) { (error) in
//                completion()
//                print("\n\nDID NOT UNREGISTER SUBSCRIPTION")
//            }
            
        //}
        self.removePreviousSubscribedDevice {
            completion()
        }
    }
    
    func removePreviousSubscribedDevice(_ completion: @escaping () -> Void) {
        // This will return the subscriptions for the new logged in user
        QBRequest.subscriptions(successBlock: { (success, subscriptions) in
            
            guard let subscriptions = subscriptions else {
                print("NO SUBSCRIPTIONS")
                completion()
                return
            }
            
            for sub in subscriptions {
                // Delete subscription
                let id = sub.id
                QBRequest.deleteSubscription(withID: id, successBlock: { (reponse) in
                    print("Deleted Subscription")
                    completion()
                }, errorBlock: { (errorResponse) in
                    print("ERROR DELETING SUBSCRIPTION \(errorResponse.error?.error?.localizedDescription ?? "NO ERROR")")
                    completion()
                })
            }
            
        }) { (errorResponse) in
            completion()
        }
    }
    
    func handle(error: Error, domain: DGStreamErrorDomain) {
        
    }
    
    func getFavorites() -> [NSNumber]? {
        if let currentUser = self.currentUser, let currentUserID = currentUser.userID, let favorites = UserDefaults.standard.dictionary(forKey: "Favorites"), let userFavorites = favorites[currentUserID.stringValue] as? [NSNumber] {
            return userFavorites
        }
        else {
            return nil
        }
    }
    
    func isFavorite(userID: NSNumber) -> Bool {
        if let currentUser = self.currentUser, let currentUserID = currentUser.userID, let favorites = UserDefaults.standard.dictionary(forKey: "Favorites"), let userFavorites = favorites[currentUserID.stringValue] as? [NSNumber], userFavorites.contains(userID) {
            return true
        }
        else {
            return false
        }
    }
    
    func addFavorite(userID: NSNumber) {
        if let currentUser = self.currentUser, let currentUserID = currentUser.userID {
            var favorites:[String: Any] = [:]
            var userFavorites:[NSNumber] = []
            if let savedFavorites = UserDefaults.standard.dictionary(forKey: "Favorites") {
                favorites = savedFavorites
            }
            if let savedUserFavorites = favorites[currentUserID.stringValue] as? [NSNumber] {
                userFavorites = savedUserFavorites
            }
            userFavorites.append(userID)
            favorites[currentUserID.stringValue] = userFavorites
            UserDefaults.standard.removeObject(forKey: "Favorites")
            UserDefaults.standard.set(favorites, forKey: "Favorites")
            UserDefaults.standard.synchronize()
        }
    }
    
    func removeFavorite(userID: NSNumber) {
        if let currentUser = self.currentUser, let currentUserID = currentUser.userID, let favorites = UserDefaults.standard.dictionary(forKey: "Favorites"), let userFavorites = favorites[currentUserID.stringValue] as? [NSNumber] {
            var newFavorites = favorites
            var newUserFavorites = userFavorites
            if let index = newUserFavorites.index(of: userID) {
                _ = newUserFavorites.remove(at: index)
                newFavorites.removeValue(forKey: currentUserID.stringValue)
                newFavorites[currentUserID.stringValue] = newUserFavorites
                UserDefaults.standard.removeObject(forKey: "Favorites")
                UserDefaults.standard.set(newFavorites, forKey: "Favorites")
                UserDefaults.standard.synchronize()
            }
        }
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
        if let chatVC = DGStreamCore.instance.chatViewController {
            chatVC.didReceive(message: message)
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
    
    func chatDidReceiveSystemMessage(_ message: QBChatMessage) {
        
        if let text = message.text {
            
            let senderID = NSNumber(value: message.senderID)
            
            print("\n\nDID RECEIVE SYSTEM MESSAGE\n\(text)\nFrom \(senderID)\n\n")
            
            // RECORD
            if text.hasPrefix("sharing"), let callVC = self.presentedViewController as? DGStreamCallViewController {
                callVC.beingSharedWith(imageData: nil)
            }
            else if text.hasPrefix("shareImage"), let callVC = self.presentedViewController as? DGStreamCallViewController {
                
                message.attachments?.forEach({ (attachment) in
                    
                    if let id = attachment.id, let attachmentID = UInt(id) {
                        
                        QBRequest.downloadFile(withID: attachmentID, successBlock: { (response, data) in
                            
                            callVC.beingSharedWith(imageData: data)
                            
                            if let user = DGStreamCore.instance.getOtherUserWith(userID: callVC.selectedUser), let username = user.username {
                                let message = DGStreamMessage()
                                message.message = "\(username) shared an image."
                                message.isSystem = true
                                callVC.chatPeekView.addCellWith(message: message)
                            }
                            
                        }, statusBlock: { (request, status) in
                            
                        }, errorBlock: { (response) in
                            print(response.error?.error?.localizedDescription ?? "No Error")
                        })
                        
                    }
                    
                })
            }
            else if text.hasPrefix("documentShare"), let callVC = self.presentedViewController as? DGStreamCallViewController {
                
                message.attachments?.forEach({ (attachment) in
                    
                    if let id = attachment.id, let attachmentID = UInt(id) {
                        
                        let message = DGStreamMessage()
                        message.message = "Downloading document..."
                        message.isSystem = true
                        callVC.chatPeekView.addCellWith(message: message)
                        
                        QBRequest.downloadFile(withID: attachmentID, successBlock: { (response, data) in
                            var path = DGStreamFileManager.applicationDocumentsDirectory()
                            path.appendPathComponent(id)
                            path.appendPathExtension("pdf")
                            do {
                                try data.write(to: path)
                            }
                            catch let error {
                                print("Could not write with error \(error.localizedDescription)")
                            }
                            
                            let document = DGStreamDocument()
                            document.createdBy = self.currentUser?.userID
                            document.createdDate = Date()
                            document.id = id
                            document.title = "ChromaKey.pdf"
                            document.url = "\(id).pdf"
                            
                            callVC.isBeingSharedWith = true
                            callVC.placePDF(document: document)

                        }, statusBlock: { (request, status) in
                            
                        }, errorBlock: { (response) in
                            print(response.error?.error?.localizedDescription ?? "No Error")
                        })
                        
                    }
                    
                })
                
            }
            else if text.hasPrefix("stopSharing"), let callVC = self.presentedViewController as? DGStreamCallViewController {
                if let user = self.getOtherUserWith(userID: senderID), let username = user.username {
                    var text = "\(username) "
                    if callVC.isSharing {
                        text.append("stopped your share.")
                    }
                    else {
                        text.append("stopped sharing.")
                    }
                    let systemMessage = DGStreamMessage()
                    systemMessage.isSystem = true
                    systemMessage.message = text
                    callVC.chatPeekView.addCellWith(message: systemMessage)
                }
                callVC.stopSharing()
            }
            else if text.hasPrefix("busy"), let callVC = self.presentedViewController as? DGStreamCallViewController {
                callVC.hangUpButtonTapped(self)
                if let user = self.getOtherUserWith(userID: senderID), let username = user.username {
                    let alert = UIAlertController(title: "Busy", message: "\(username) is busy. Try again.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action: UIAlertAction) in
                        alert.dismiss(animated: true, completion: nil)
                    }))
                    if let alert = self.alertView {
                        alert.dismiss()
                        self.alertView = nil
                    }
                    if let callAlert = callVC.alertView {
                        callAlert.dismiss()
                    }
                    self.presentedViewController?.present(alert, animated: true, completion: nil)
                }
            }
            else if text.hasPrefix("recordingRequest"), let recordingRequestView = UINib(nibName: "DGStreamAlertView", bundle: Bundle(identifier: "com.dataglance.DGStream")).instantiate(withOwner: self, options: nil).first as? DGStreamAlertView, let callVC = self.presentedViewController as? DGStreamCallViewController, let currentUser = self.currentUser, let currentUserID = currentUser.userID {
                
                if !self.shouldShowAlert() {
                    return
                }
                
                var fromUsername = ""
                if let fromUser = self.getOtherUserWith(userID: senderID), let username = fromUser.username {
                    fromUsername = username
                }
                callVC.playMergeSound()
                recordingRequestView.configureFor(mode: .recordingRequest, fromUsername: fromUsername, message: "", isWaiting: false)
                
                DispatchQueue.main.async {
                    
                    if let alertView = callVC.alertView {
                        alertView.dismiss()
                        callVC.alertView = nil
                    }
                    
                    callVC.alertView = recordingRequestView
                    
                    recordingRequestView.presentWithin(viewController: callVC, block: { (accepted) in
                        if accepted {
                            
                            // Send Merge Accepted System Message
                            let acceptedMessage = QBChatMessage()
                            acceptedMessage.text = "recordingAccepted"
                            acceptedMessage.senderID = currentUserID.uintValue
                            acceptedMessage.recipientID = senderID.uintValue
                            
                            QBChat.instance.sendSystemMessage(acceptedMessage, completion: { (error) in
                                print("Sent Accepted Message With \(error?.localizedDescription ?? "NO ERROR")")
                            })
                            
                        }
                        else {
                            
                            // Send Merge Declined System Message
                            let declinedMessage = QBChatMessage()
                            declinedMessage.text = "recordingDeclined"
                            declinedMessage.senderID = currentUserID.uintValue
                            declinedMessage.recipientID = senderID.uintValue
                            
                            QBChat.instance.sendSystemMessage(declinedMessage, completion: { (error) in
                                print("Sent Declined Message With \(error?.localizedDescription ?? "NO ERROR")")
                                
                                let message = DGStreamMessage()
                                message.message = "\(fromUsername) declined perspective."
                                message.isSystem = true
                                callVC.chatPeekView.addCellWith(message: message)
                            })
                            
                        }
                    })
                }
            }
            else if text.hasPrefix("clearDrawings"), let callVC = self.presentedViewController as? DGStreamCallViewController {
                if let user = self.getOtherUserWith(userID: senderID), let username = user.username {
                    let message = DGStreamMessage()
                    message.message = "\(username) cleared drawings."
                    message.isSystem = true
                    callVC.chatPeekView.addCellWith(message: message)
                }
                callVC.clearRemoteDrawings()
            }
            else if text.hasPrefix("clearAllDrawings"), let callVC = self.presentedViewController as? DGStreamCallViewController {
                if let user = self.getOtherUserWith(userID: senderID), let username = user.username {
                    
                    var drawID:Int = 0 // Increments from other devices draws
                    
                    if let params = message.customParameters, let drawIDValue = params["increment"] {
                        let drawIDString:String = String(describing: drawIDValue)
                        if let drawIDInt = Int(drawIDString) {
                            drawID = drawIDInt
                        }
                        else if drawIDString.contains("(") {
                            let string = drawIDString.components(separatedBy: "(")[1].components(separatedBy: ")")[0]
                            if let drawIDInt:Int = Int(string) {
                                drawID = drawIDInt
                            }
                        }
                    }
                    
                    if callVC.latestRemoteDrawID > drawID {
                        return
                    }
                    
                    callVC.latestRemoteDrawID = drawID
                    
                    let message = DGStreamMessage()
                    message.message = "\(username) cleared all drawings."
                    message.isSystem = true
                    callVC.chatPeekView.addCellWith(message: message)
                }
                callVC.clearDrawings()
                callVC.clearRemoteDrawings()
            }
            else if text.hasPrefix("recordingAccepted"), let callVC = self.presentedViewController as? DGStreamCallViewController {
                callVC.alertView?.dismiss()
                callVC.alertView = nil
                let message = DGStreamMessage()
                message.message = "Recording in progress."
                message.isSystem = true
                callVC.chatPeekView.addCellWith(message: message)
                callVC.startRecording()
            }
            else if text.hasPrefix("recordingDeclined"), let callVC = self.presentedViewController as? DGStreamCallViewController, let user = DGStreamCore.instance.getOtherUserWith(userID: senderID), let username = user.username {
                callVC.alertView?.dismiss()
                callVC.alertView = nil
                let message = DGStreamMessage()
                message.message = "\(username) declined record."
                message.isSystem = true
                callVC.chatPeekView.addCellWith(message: message)
            }
            else if text.hasPrefix("recordingStart") {
                if let callVC = self.presentedViewController as? DGStreamCallViewController {
                    callVC.drawEndWith(userID: senderID)
                    if let user = self.getOtherUserWith(userID: senderID), let username = user.username {
                        let message = DGStreamMessage()
                        message.message = "\(username) is recording."
                        message.isSystem = true
                        callVC.chatPeekView.addCellWith(message: message)
                    }
                }
            }
            else if text.hasPrefix("recordingStop") {
                if let callVC = self.presentedViewController as? DGStreamCallViewController {
                    callVC.drawEndWith(userID: senderID)
                    if let user = self.getOtherUserWith(userID: senderID), let username = user.username {
                        let message = DGStreamMessage()
                        message.message = "\(username) stopped recording."
                        message.isSystem = true
                        callVC.chatPeekView.addCellWith(message: message)
                    }
                }
            }
            else if text.hasPrefix("orientationUpdate"),
                let callVC = self.presentedViewController as? DGStreamCallViewController {
                let splice = text.components(separatedBy: "-")
                let orientationString = splice[1]
                print(orientationString)
                var orientation:UIInterfaceOrientation = .portrait
                if orientationString == "portrait" {
                    orientation = .portrait
                }
                else if orientationString == "landscapeLeft" {
                    orientation = .landscapeLeft
                }
                else if orientationString == "landscapeRight" {
                    orientation = .landscapeRight
                }
                else if orientationString == "upsideDown" {
                    orientation = .portraitUpsideDown
                }
                callVC.updateRecordingWith(orientation: orientation)
            }
            else if text.hasPrefix("orientationRequest"), let callVC = self.presentedViewController as? DGStreamCallViewController {
                callVC.sendOrientationUpdateTo(userID: senderID)
            }
                // DRAW START
            else if text.hasPrefix("drawStart") {
                if let callVC = self.presentedViewController as? DGStreamCallViewController {
                    callVC.startDrawingWith(userID: senderID)
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
                    
                    var drawID:Int = 0 // Increments from other devices draws

                    if let params = message.customParameters, let drawIDValue = params["increment"] {
                        let drawIDString:String = String(describing: drawIDValue)
                        if let drawIDInt = Int(drawIDString) {
                            drawID = drawIDInt
                        }
                        else if drawIDString.contains("(") {
                            let string = drawIDString.components(separatedBy: "(")[1].components(separatedBy: ")")[0]
                            if let drawIDInt:Int = Int(string) {
                                drawID = drawIDInt
                            }
                        }
                    }
                    
                    if callVC.latestRemoteDrawID > drawID {
                        return
                    }
                    
                    message.attachments?.forEach({ (attachment) in
                        
                        if let id = attachment.id, let attachmentID = UInt(id) {
                            
                            QBRequest.downloadFile(withID: attachmentID, successBlock: { (response, data) in
                                if callVC.latestRemoteDrawID > drawID {
                                    return
                                }
                                callVC.drawWithImage(id: drawID, data: data)
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
                //callVC.showFreezeActivityIndicator()
            }
            else if text.hasPrefix("freeze") {
                if let callVC = self.presentedViewController as? DGStreamCallViewController {
                    callVC.freeze()
                }
            }
            else if text.hasPrefix("didFreeze"), let callVC = self.presentedViewController as? DGStreamCallViewController {
                //callVC.hideFreezeActivityIndicator()
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
                        //callVC.hideFreezeActivityIndicator()
                    }
                }
            }
            else if text.hasPrefix("didUnfreeze"), let callVC = self.presentedViewController as? DGStreamCallViewController {
                //callVC.hideFreezeActivityIndicator()
            }
                // MERGE REQUEST
            else if text.hasPrefix("cancelRequest"), let callVC = self.presentedViewController as? DGStreamCallViewController {
                if let alert = callVC.alertView, alert.alertMode == .mergeRequest, alert.isWaiting {
                    alert.dismiss()
                    callVC.alertView = nil
                }
                if let alert = callVC.alertRequestWaitingView {
                    alert.dismiss()
                    callVC.alertRequestWaitingView = nil
                }
            }
            else if text.hasPrefix("mergeRequest"), let mergeRequestView = UINib(nibName: "DGStreamAlertView", bundle: Bundle(identifier: "com.dataglance.DGStream")).instantiate(withOwner: self, options: nil).first as? DGStreamAlertView, let callVC = self.presentedViewController as? DGStreamCallViewController, let currentUser = self.currentUser, let currentUserID = currentUser.userID, let customParams = message.customParameters, let screenWidthString = customParams["ScreenWidth"] as? String, let screenHeightString = customParams["ScreenHeight"] as? String {
                
                print("\n\nMERGE REQUEST\n\n")
                
                if !self.shouldShowAlert() {
                    return
                }
                
                var fromUsername = ""
                if let fromUser = self.getOtherUserWith(userID: senderID), let username = fromUser.username {
                    fromUsername = username
                }
                callVC.playMergeSound()
                
                var widthString = ""
                var heightString = ""
                if screenWidthString.contains("."), let w = screenWidthString.components(separatedBy: ".").first {
                    widthString = w
                }
                else {
                    widthString = screenWidthString
                }
                
                if screenHeightString.contains("."), let h = screenHeightString.components(separatedBy: ".").first {
                    heightString = h
                }
                else {
                    heightString = screenHeightString
                }
                
                var width = UIScreen.main.bounds.width
                var height = UIScreen.main.bounds.height
                if let wInt = Int(widthString), let hInt = Int(heightString) {
                    width = CGFloat(wInt)
                    height = CGFloat(hInt)
                }
                
                callVC.remoteScreenSize = CGSize(width: width, height: height)
                
                mergeRequestView.configureFor(mode: .mergeRequest, fromUsername: fromUsername, message: "", isWaiting: false)
                
                DispatchQueue.main.async {
                    
                    if let alertView = callVC.alertView {
                        alertView.dismiss()
                        callVC.alertView = nil
                    }
                    
                    callVC.alertView = mergeRequestView
                    
                    mergeRequestView.presentWithin(viewController: callVC, block: { (accepted) in
                        if accepted {
                            
                            if callVC.isSharingVideo == false {
                                callVC.isMergeHelper = true
                            }
                            callVC.start(mode: .merge)
                            callVC.alertView = nil
                            
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
                            
                            callVC.isMergeHelper = false
                            
                            // Send Merge Declined System Message
                            
                            let declinedMessage = QBChatMessage()
                            declinedMessage.text = "mergeDeclined"
                            declinedMessage.senderID = currentUserID.uintValue
                            declinedMessage.recipientID = senderID.uintValue
                            
                            mergeRequestView.dismiss()
                            callVC.alertView = nil
                        
                            QBChat.instance.sendSystemMessage(declinedMessage, completion: { (error) in
                                print("Sent Declined Message With \(error?.localizedDescription ?? "NO ERROR")")
                                
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
                if callVC.isBeingSharedWithVideo {
                    callVC.isMergeHelper = true
                }
                callVC.start(mode: .merge)
            }
                // MERGE DECLINED
            else if text.hasPrefix("mergeDeclined"), let callVC = self.presentedViewController as? DGStreamCallViewController {
                if let alertView = callVC.alertView {
                    var fromUsername = ""
                    if let fromUser = self.getOtherUserWith(userID: senderID), let username = fromUser.username {
                        fromUsername = username
                    }
                    alertView.dismiss()
                    callVC.alertView = nil
                    let message = DGStreamMessage()
                    message.message = "\(fromUsername) declined merge."
                    message.isSystem = true
                    callVC.chatPeekView.addCellWith(message: message)
                }
            }
                // MERGE END
            else if text.hasPrefix("mergeEnd"), let callVC = self.presentedViewController as? DGStreamCallViewController {
                callVC.returnToStreamMode(hideModeButtons: true)
            }
                // PDF PAGE CHANGE
            else if text.hasPrefix("pageChange"), let callVC = self.presentedViewController as? DGStreamCallViewController, let customParams = message.customParameters, let pageIndexString = customParams["index"] as? String, let pageIndex = Int(pageIndexString), let incrementString = customParams["increment"] as? String, let increment = Int(incrementString) {
                callVC.changeToPage(index: pageIndex, increment: increment)
            }
                // PDF PAGE SELECTION
            else if text.hasPrefix("pageSelection"), let callVC = self.presentedViewController as? DGStreamCallViewController, let customParams = message.customParameters, let pageSelection = customParams["string"] as? String, let incrementString = customParams["increment"] as? String, let increment = Int(incrementString) {
                callVC.changeToPage(selection: pageSelection, increment: increment)
            }
                // PERSPECTIVE REQUEST
            else if text.hasPrefix("perspectiveRequest"), let perspectiveRequestView = UINib(nibName: "DGStreamAlertView", bundle: Bundle(identifier: "com.dataglance.DGStream")).instantiate(withOwner: self, options: nil).first as? DGStreamAlertView, let callVC = self.presentedViewController as? DGStreamCallViewController, let currentUser = self.currentUser, let currentUserID = currentUser.userID {
                
                if !self.shouldShowAlert() {
                    return
                }
                
                var fromUsername = ""
                if let fromUser = self.getOtherUserWith(userID: senderID), let username = fromUser.username {
                    fromUsername = username
                }
                callVC.playMergeSound()
                perspectiveRequestView.configureFor(mode: .perspectiveRequest, fromUsername: fromUsername, message: "", isWaiting: false)
                
                DispatchQueue.main.async {
                    
                    if let alertView = callVC.alertView {
                        alertView.dismiss()
                        callVC.alertView = nil
                    }
                    
                    callVC.alertView = perspectiveRequestView
                    
                    perspectiveRequestView.presentWithin(viewController: callVC, block: { (accepted) in
                        if accepted {
                            
                            callVC.acceptedPerspective()
                            
                            // Send Merge Accepted System Message
                            let acceptedMessage = QBChatMessage()
                            acceptedMessage.text = "perspectiveAccepted"
                            acceptedMessage.senderID = currentUserID.uintValue
                            acceptedMessage.recipientID = senderID.uintValue
                            
                            QBChat.instance.sendSystemMessage(acceptedMessage, completion: { (error) in
                                print("Sent Accepted Message With \(error?.localizedDescription ?? "NO ERROR")")
                            })
                            
                        }
                        else {
                            
                            // Send Merge Declined System Message
                            let declinedMessage = QBChatMessage()
                            declinedMessage.text = "perspectiveDeclined"
                            declinedMessage.senderID = currentUserID.uintValue
                            declinedMessage.recipientID = senderID.uintValue
                            
                            QBChat.instance.sendSystemMessage(declinedMessage, completion: { (error) in
                                print("Sent Declined Message With \(error?.localizedDescription ?? "NO ERROR")")
                                
                                let message = DGStreamMessage()
                                message.message = "\(fromUsername) declined perspective."
                                message.isSystem = true
                                callVC.chatPeekView.addCellWith(message: message)
                            })
                            
                        }
                    })
                }
            }
                // PERSPECTIVE ACCEPT
            else if text.hasPrefix("perspectiveAccept"), let callVC = self.presentedViewController as? DGStreamCallViewController {
                callVC.perspectiveAccepted()
            }
                // PERSPECTIVE DECLINED
            else if text.hasPrefix("perspectiveDeclined"), let callVC = self.presentedViewController as? DGStreamCallViewController {
                callVC.requestDeclined()
            }
                // PERSPECTIVE END
            else if text.hasPrefix("perspectiveEnd"), let callVC = self.presentedViewController as? DGStreamCallViewController {
                callVC.perspectiveEnded()
            }
                // WHITEBOARD REQUEST
            else if text.hasPrefix("whiteboardRequest"), let whiteboardRequestView = UINib(nibName: "DGStreamAlertView", bundle: Bundle(identifier: "com.dataglance.DGStream")).instantiate(withOwner: self, options: nil).first as? DGStreamAlertView, let callVC = self.presentedViewController as? DGStreamCallViewController, let currentUser = self.currentUser, let currentUserID = currentUser.userID {
                
                print("\n\nWHITEBOARD REQUEST\n\n")
                if !self.shouldShowAlert() {
                    return
                }
                
                var fromUsername = ""
                if let fromUser = self.getOtherUserWith(userID: senderID), let username = fromUser.username {
                    fromUsername = username
                }
                callVC.playMergeSound()
                whiteboardRequestView.configureFor(mode: .whiteboardRequest, fromUsername: fromUsername, message: "", isWaiting: false)
                
                DispatchQueue.main.async {
                    
                    if let alertView = callVC.alertView {
                        alertView.dismiss()
                        callVC.alertView = nil
                    }
                    
                    callVC.alertView = whiteboardRequestView
                    
                    whiteboardRequestView.presentWithin(viewController: callVC, block: { (accepted) in
                        if accepted {
                            
                            callVC.startWhiteBoard()
                            
                            // Send Merge Accepted System Message
                            
                            let acceptedMessage = QBChatMessage()
                            acceptedMessage.text = "whiteboardStart"
                            acceptedMessage.senderID = currentUserID.uintValue
                            acceptedMessage.recipientID = senderID.uintValue
                            
                            QBChat.instance.sendSystemMessage(acceptedMessage, completion: { (error) in
                                print("Sent Accepted Message With \(error?.localizedDescription ?? "NO ERROR")")
                            })
                            
                        }
                        else {
                            
                            // Send Merge Declined System Message
                            
                            let declinedMessage = QBChatMessage()
                            declinedMessage.text = "whiteboardDeclined"
                            declinedMessage.senderID = currentUserID.uintValue
                            declinedMessage.recipientID = senderID.uintValue
                            
                            QBChat.instance.sendSystemMessage(declinedMessage, completion: { (error) in
                                print("Sent Declined Message With \(error?.localizedDescription ?? "NO ERROR")")
                                
                                whiteboardRequestView.dismiss()
                                
                            })
                            
                        }
                    })
                }
            }
                // WHITE BOARD START
            else if text.hasPrefix("whiteboardStart"), let callVC = self.presentedViewController as? DGStreamCallViewController {
                
                callVC.alertView?.dismiss()
                callVC.alertView = nil
                callVC.startWhiteBoard()
                
                if let user = self.getOtherUserWith(userID: senderID), let username = user.username {
                    let message = DGStreamMessage()
                    message.message = "You and \(username) are in Whiteboard."
                    message.isSystem = true
                    callVC.chatPeekView.addCellWith(message: message)
                }
            }
                // WHITE BOARD DECLINDED
            else if text.hasPrefix("whiteboardDeclined"), let callVC = self.presentedViewController as? DGStreamCallViewController {
                callVC.requestDeclined()
            }
                // WHITE BOARD END
            else if text.hasPrefix("whiteboardEnd"), let callVC = self.presentedViewController as? DGStreamCallViewController {
                
                let isDrawingOptionalString = String(describing: message.customParameters["isDrawing"])
                
                if isDrawingOptionalString == "Optional(false)" || isDrawingOptionalString == "false" {
                    callVC.drawEndWith(userID: senderID)
                }
                
                callVC.endWhiteBoard(sendNotification: false)
                
                if let user = DGStreamCore.instance.getOtherUserWith(userID: senderID), let username = user.username {
                    let message = DGStreamMessage()
                    message.message = "\(username) ended Whiteboard."
                    message.isSystem = true
                    callVC.chatPeekView.addCellWith(message: message)
                }
            }
            else if text.hasPrefix("undo"), let callVC = self.presentedViewController as? DGStreamCallViewController {
                
                var undoID:Int = 0
                
                if let params = message.customParameters, let undoIDValue = params["undoID"] {
                    let undoIDString:String = String(describing: undoIDValue)
                    if let undoIDInt = Int(undoIDString) {
                        undoID = undoIDInt
                    }
                    else if undoIDString.contains("(") {
                        let string = undoIDString.components(separatedBy: "(")[1].components(separatedBy: ")")[0]
                        if let undoIDInt:Int = Int(string) {
                            undoID = undoIDInt
                        }
                    }
                }
                
                callVC.undo(id: undoID)
                if let user = DGStreamCore.instance.getOtherUserWith(userID: senderID), let username = user.username {
                    let message = DGStreamMessage()
                    message.message = "\(username) undid their last draw."
                    message.isSystem = true
                    callVC.chatPeekView.addCellWith(message: message)
                }
            }
            else if text.hasPrefix("takingPicture"), let callVC = self.presentedViewController as? DGStreamCallViewController {
                var fromUsername = ""
                if let fromUser = self.getOtherUserWith(userID: senderID), let username = fromUser.username {
                    fromUsername = username
                }
                let message = DGStreamMessage()
                message.isSystem = true
                message.message = "\(fromUsername) is taking a photo."
                callVC.chatPeekView.addCellWith(message: message)
            }
        }
        
    }
    
    func shouldShowAlert() -> Bool {
        
        // 1)
        // If we:
        //     a) are the initiator
        //     b) are waiting for a request outselves
        // Then don't show request
        // and tell them to
        
        // 2)
        // If we:
        //     a) are not the initiator
        //     b) and are showing an alert
        // Remove the existing alert
        // and show this alert
        // all other cases show
        
        if let callVC = self.presentedViewController as? DGStreamCallViewController {
            // 1)
            if self.currentUser?.userID ?? 0 == callVC.session?.initiatorID, let alert = callVC.alertView, (alert.alertMode == .mergeRequest || alert.alertMode == .perspectiveRequest || alert.alertMode == .whiteboardRequest), alert.isWaiting {
                
                let message = QBChatMessage()
                message.senderID = UInt(self.currentUser?.userID ?? 0)
                message.recipientID = callVC.selectedUser.uintValue
                message.text = "cancelRequest"
                QBChat.instance.sendSystemMessage(message) { (error) in
                    
                }
                
                return false
                
            }
            // 2)
            else if let alert = callVC.alertView, alert.isWaiting {
                alert.dismiss()
            }
        }
        return true
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
        var stateString = "UNKNOWN"
        if state == .disconnected {
            stateString = "DISCONNECTED"
        }
        else if state == .disconnectTimeout {
            stateString = "DISCONNECTED TIMEOUT"
        }
        else if state == .hangUp {
            stateString = "HANGUP"
            
        }
        print("SESSION STATE CHANGED \(stateString) FOR \(userID)")
    }
    
    public func didReceiveNewSession(_ session: QBRTCSession, userInfo: [String : String]? = nil) {
        print("DID RECEIVE NEW SESSION")
        
        var fromUsername = "Unknown"
        var fromUserID: NSNumber = NSNumber(value: 0)
        if let info = userInfo, let username = info["username"] {
            fromUsername = username
        }
        
        if let otherUser = self.getOtherUserWith(username: fromUsername), let otherUserID = otherUser.userID {
            fromUserID = otherUserID
        }
        
        if let callVC = self.presentedViewController as? DGStreamCallViewController, callVC.isWaitingForCallAccept, let currentUser = self.currentUser, let currentUserID = currentUser.userID {
            
            let busyMessage = QBChatMessage()
            busyMessage.text = "busy"
            busyMessage.senderID = currentUserID.uintValue
            busyMessage.recipientID = fromUserID.uintValue
            
            QBChat.instance.sendSystemMessage(busyMessage, completion: { (error) in
                print("Sent Busy Message With \(error?.localizedDescription ?? "NO ERROR")")
            })
            
            return
        }

        if let currentUser = self.currentUser, let currentUserID = currentUser.userID {
            
            if let vc = self.presentedViewController, self.alertView == nil, let incomingCallView = UINib(nibName: "DGStreamAlertView", bundle: Bundle(identifier: "com.dataglance.DGStream")).instantiate(withOwner: self, options: nil).first as? DGStreamAlertView {
                
                var mode:AlertMode = .incomingVideoCall
                if session.conferenceType == .audio {
                    mode = .incomingAudioCall
                }
                self.audioPlayer.ringFor(receiver: true)
                incomingCallView.configureFor(mode: mode, fromUsername: fromUsername, message: "", isWaiting: false)
                self.alertView = incomingCallView
                incomingCallView.presentWithin(viewController: vc, block: { (didAccept) in
                    
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
                        
                        // CALL VC
                        if vc is DGStreamCallViewController {
                            //callVC.hangUpButtonTapped(self)
//                            if let alertView = self.alertView {
//                                
//                            }
                            NotificationCenter.default.post(name: Notification.Name("AcceptIncomingCall"), object: session)
                        }
                        // TAB BAR
                        else if let tabBarVC = vc as? DGStreamTabBarViewController, let callVC = UIStoryboard(name: "Call", bundle: Bundle(identifier: "com.dataglance.DGStream")).instantiateInitialViewController() as? DGStreamCallViewController, let chatVC = UIStoryboard.init(name: "Chat", bundle: Bundle(identifier: "com.dataglance.DGStream")).instantiateInitialViewController() as? DGStreamChatViewController {
                            
                            print("GETTING CONVERSATION WITH \(fromUserID)")
                            
                            print("Total conversations \(tabBarVC.conversations.count)")
                            
                            for c in tabBarVC.conversations {
                                print("\(c.conversationID) | \(c.userIDs)")
                                if c.userIDs.contains(fromUserID) {
                                    let proto = DGStreamConversation.createDGStreamConversationFrom(proto: c)
                                    let newConversation = DGStreamConversation.createDGStreamConversationFrom(proto: proto)
                                    newConversation.type = .callConversation
                                    chatVC.chatConversation = newConversation
                                    print("SET NEW CONVERSATION")
                                    break
                                }
                            }
                            
                            chatVC.delegate = callVC
                            callVC.chatVC = chatVC
                            callVC.session = session
                            callVC.selectedUser = fromUserID
                            
                            if mode == .incomingAudioCall {
                                callVC.isAudioCall = true
                                DispatchQueue.main.async {
                                    if let navigationController = vc.navigationController {
                                        navigationController.pushViewController(callVC, animated: true)
                                    }
                                    else {
                                        vc.present(callVC, animated: true, completion: nil)
                                    }
                                }
                            }
                            else {
                                DispatchQueue.main.async {
                                    if let navigationController = vc.navigationController {
                                        navigationController.pushViewController(callVC, animated: true)
                                    }
                                    else {
                                        vc.present(callVC, animated: true, completion: nil)
                                    }
                                }
                            }
                            
                        }
                        else if let recordingsCollectionsVC = vc as? DGStreamRecordingCollectionsViewController, let callVC = UIStoryboard(name: "Call", bundle: Bundle(identifier: "com.dataglance.DGStream")).instantiateInitialViewController() as? DGStreamCallViewController, let chatVC = UIStoryboard.init(name: "Chat", bundle: Bundle(identifier: "com.dataglance.DGStream")).instantiateInitialViewController() as? DGStreamChatViewController{
                            if let nav = recordingsCollectionsVC.navigationController, let tabBarVC = nav.viewControllers.first as? DGStreamTabBarViewController {
                                nav.popViewController(animated: false)
                                print("GETTING CONVERSATION WITH \(fromUserID)")
                                
                                print("Total conversations \(tabBarVC.conversations.count)")
                                
                                for c in tabBarVC.conversations {
                                    print("\(c.conversationID) | \(c.userIDs)")
                                    if c.userIDs.contains(fromUserID) {
                                        let proto = DGStreamConversation.createDGStreamConversationFrom(proto: c)
                                        let newConversation = DGStreamConversation.createDGStreamConversationFrom(proto: proto)
                                        newConversation.type = .callConversation
                                        chatVC.chatConversation = newConversation
                                        print("SET NEW CONVERSATION")
                                        break
                                    }
                                }
                                
                                chatVC.delegate = callVC
                                callVC.chatVC = chatVC
                                callVC.session = session
                                callVC.selectedUser = fromUserID
                                
                                if mode == .incomingAudioCall {
                                    callVC.isAudioCall = true
                                    DispatchQueue.main.async {
                                        if let navigationController = tabBarVC.navigationController {
                                            navigationController.pushViewController(callVC, animated: true)
                                        }
                                        else {
                                            tabBarVC.present(callVC, animated: true, completion: nil)
                                        }
                                    }
                                }
                                else {
                                    DispatchQueue.main.async {
                                        if let navigationController = tabBarVC.navigationController {
                                            navigationController.pushViewController(callVC, animated: true)
                                        }
                                        else {
                                            tabBarVC.present(callVC, animated: true, completion: nil)
                                        }
                                    }
                                }
                            }
                        }
                        else if let recordingsVC = vc as? DGStreamRecordingsViewController, let callVC = UIStoryboard(name: "Call", bundle: Bundle(identifier: "com.dataglance.DGStream")).instantiateInitialViewController() as? DGStreamCallViewController, let chatVC = UIStoryboard.init(name: "Chat", bundle: Bundle(identifier: "com.dataglance.DGStream")).instantiateInitialViewController() as? DGStreamChatViewController{
                            if let nav = recordingsVC.navigationController, let tabBarVC = nav.viewControllers.first as? DGStreamTabBarViewController {
                                //nav.popViewController(animated: false)
                                nav.popToRootViewController(animated: false)
                                print("GETTING CONVERSATION WITH \(fromUserID)")
                                
                                print("Total conversations \(tabBarVC.conversations.count)")
                                
                                for c in tabBarVC.conversations {
                                    print("\(c.conversationID) | \(c.userIDs)")
                                    if c.userIDs.contains(fromUserID) {
                                        let proto = DGStreamConversation.createDGStreamConversationFrom(proto: c)
                                        let newConversation = DGStreamConversation.createDGStreamConversationFrom(proto: proto)
                                        newConversation.type = .callConversation
                                        chatVC.chatConversation = newConversation
                                        print("SET NEW CONVERSATION")
                                        break
                                    }
                                }
                                
                                chatVC.delegate = callVC
                                callVC.chatVC = chatVC
                                callVC.session = session
                                callVC.selectedUser = fromUserID
                                
                                if mode == .incomingAudioCall {
                                    callVC.isAudioCall = true
                                    DispatchQueue.main.async {
                                        if let navigationController = tabBarVC.navigationController {
                                            navigationController.pushViewController(callVC, animated: true)
                                        }
                                        else {
                                            tabBarVC.present(callVC, animated: true, completion: nil)
                                        }
                                    }
                                }
                                else {
                                    DispatchQueue.main.async {
                                        if let navigationController = tabBarVC.navigationController {
                                            navigationController.pushViewController(callVC, animated: true)
                                        }
                                        else {
                                            tabBarVC.present(callVC, animated: true, completion: nil)
                                        }
                                    }
                                }
                            }
                        }
                        
                    }
                    else {
                        session.rejectCall(nil)
                        
//                        let recent = DGStreamRecent()
//                        recent.date = Date()
//                        recent.duration = 0.0
//                        recent.isMissed = true
//                        recent.receiver = DGStreamCore.instance.currentUser
//                        recent.receiverID = currentUserID
//                        recent.recentID = UUID().uuidString
//                        recent.sender = DGStreamCore.instance.getOtherUserWith(userID: fromUserID)
//                        recent.senderID = fromUserID
//                        recent.isAudio = session.conferenceType == .audio
//
//                        DGStreamManager.instance.dataStore.streamManager(DGStreamManager.instance, store: recent)
                    }
                })
            }
        }

    }
    
    public func sessionDidClose(_ session: QBRTCSession) {

    }
    
}

extension DGStreamCore: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {

        if let completion = self.localVideoCompletion {
            completion(true)
            self.localVideoCompletion = nil
        }

        guard let callVC = self.presentedViewController as? DGStreamCallViewController else {
            return
        }

        if callVC.isSharing {
            //callVC.sendFreezeFrame()
            return
        }

        var bufferCopy: CMSampleBuffer?
        if CMSampleBufferCreateCopy(kCFAllocatorDefault, sampleBuffer, &bufferCopy) == noErr, let copy = bufferCopy {

            // SEND AUDIO SAMPLE
//            if connection.output is AVCaptureAudioDataOutput {
//                self.delegate.recorder(self, audioSample: copy)
//                print("AVCaptureAudioDataOutput!")
//                return
//            }
            // SEND VIDEO FRAME
            if let pixelBuffer : CVPixelBuffer = CMSampleBufferGetImageBuffer(copy), let videoFrame = QBRTCVideoFrame(pixelBuffer: pixelBuffer, videoRotation: ._0) {
                if callVC.callMode == .merge && callVC.isMergeHelper {
                    //callVC.greenScreenVC.pixelBufferReady(forDisplay: pixelBuffer)
                }
                callVC.send(frameToBroadcast: videoFrame)
            }
            else {
                print("No Pixel Buffer")
            }
        }
        else {
            print("Failed To Copy")
        }
    }
}
