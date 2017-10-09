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
    
    var currentUser: DGStreamUser!
    var presentedViewController: UIViewController?
    var incomingCallView: DGStreamIncomingCallView?
    
    typealias networkStatusBlock = (_ status: DGStreamNetworkStatus?) -> Void
    var loginCompletion:LoginCompletion?
    var multicastDelegate = QBMulticastDelegate()
    //var profile: QBProfile!
    
    var reachability = Reachability()!
    var isReachable:Bool = false
    var isAuthorized:Bool = false
    
    var userDataSource: DGStreamUserDataSource?
    
    override init() {
        super.init()
    }
    
    func initialize() {
        startReachability()
        QBRTCClient.instance().add(self)
        QBSettings.setAutoReconnectEnabled(true)
        QBChat.instance().addDelegate(self)
    }
    
    func add(delegate: Any) {
        self.multicastDelegate.addDelegate(delegate)
    }
    
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
            QBRequest.logIn(withUserLogin: username, password: password, successBlock: { (response, user) in
                self.isAuthorized = true
                self.registerForRemoteNotifications()
                self.loginCompletion = completion
                self.connectToChat()
            }, errorBlock: { (response) in
                var errorMessage = "Login Error"
                if let qbError = response.error, let error = qbError.error {
                    errorMessage = error.localizedDescription
                }
                completion(false, errorMessage)
            })
        }
    }
    
    func connectToChat() {
        self.currentUser.password = "Data1Glance"
        let user = self.currentUser.asQuickbloxUser()
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
        
    }
    func chatDidReconnect() {
        
    }
    func chatDidAccidentallyDisconnect() {
        
    }
    func chatDidReceive(_ message: QBChatMessage) {
        
    }
    func chatDidFail(withStreamError error: Error?) {
        
    }
    func chatDidNotConnectWithError(_ error: Error?) {
        
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
        
        let result = report.statsString()
        print(result)
    }
    
    public func session(_ session: QBRTCSession, userDidNotRespond userID: NSNumber) {
        print("USER \(userID) DID NOT RESPOND")
        
    }
    
    public func session(_ session: QBRTCSession, acceptedByUser userID: NSNumber, userInfo: [String : String]? = nil) {
        print("ACCEPTED BY \(userID)")
    }
    
    public func session(_ session: QBRTCSession, rejectedByUser userID: NSNumber, userInfo: [String : String]? = nil) {
        print("REJECTED BY \(userID)")
    }
    
    public func session(_ session: QBRTCSession, hungUpByUser userID: NSNumber, userInfo: [String : String]? = nil) {
        print("\(userID) HUNG UP")
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
    }
    
    public func session(_ session: QBRTCBaseSession, disconnectedFromUser userID: NSNumber) {
        print("DISCONNECTED FROM \(userID)")
    }
    
    public func session(_ session: QBRTCBaseSession, connectionClosedForUser userID: NSNumber) {
        print("CONNECTIONG CLOSED FOR \(userID)")
    }
    
    public func session(_ session: QBRTCBaseSession, connectionFailedForUser userID: NSNumber) {
        print("CONNECTION FAILED FOR \(userID)")
    }
    
    public func session(_ session: QBRTCBaseSession, didChange state: QBRTCSessionState) {
        print("SESSION STATE CHANGED \(state) FOR CURRENT USER")
    }
    
    public func session(_ session: QBRTCBaseSession, didChange state: QBRTCConnectionState, forUser userID: NSNumber) {
        print("SESSION STATE CHANGED \(state) FOR \(userID)")
    }
    
    public func didReceiveNewSession(_ session: QBRTCSession, userInfo: [String : String]? = nil) {
        print("DID RECEIVE NEW SESSION")
        
        var fromUsername = "Unknown"
        
        if let info = userInfo, let username = info["username"] {
            fromUsername = username
        }
        
        if let vc = self.presentedViewController, let incomingCallView = UINib(nibName: "DGStreamIncomingCallView", bundle: Bundle(identifier: "com.dataglance.DGStream")).instantiate(withOwner: self, options: nil).first as? DGStreamIncomingCallView {
            self.incomingCallView = incomingCallView
            incomingCallView.presentWithin(viewController: vc, fromUsername: fromUsername, block: { (didAccept) in
                if didAccept {
                    session.acceptCall(nil)
                    
                    let storyboard = UIStoryboard(name: "Call", bundle: Bundle(identifier: "com.dataglance.DGStream"))
                    if let callVC = storyboard.instantiateInitialViewController() as? DGStreamCallViewController {
                        callVC.session = session
                        vc.present(callVC, animated: true, completion: nil)
                    }
                    
                }
                else {
                    session.rejectCall(nil)
                }
            })
        }
    }
    
    public func sessionDidClose(_ session: QBRTCSession) {
        print("SESSION CLOSED")
    }
    
}
