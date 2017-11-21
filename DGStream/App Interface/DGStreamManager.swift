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
    func streamManager(_ manager: DGStreamManager, recentsWithUserID userID: NSNumber) -> [DGStreamRecentProtocol]
    
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
    
    public func initializeWith(dataSource: DGStreamManagerDataSource, and dataStore: DGStreamManagerDataStore) {
        self.dataStore = dataStore
        self.dataSource = dataSource
        initialize()
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
    
    public func receivedPushNotification(_ notification: String) {
        if let currentUser = DGStreamCore.instance.currentUser, let currentUserID = currentUser.userID {
            if notification.contains("-") {
                if notification.hasPrefix("unfreeze") {
                    if let callVC = DGStreamCore.instance.presentedViewController as? DGStreamCallViewController {
                        callVC.unfreeze()
                    }
                }
                else if notification.hasPrefix("freeze") {
                    let splice = notification.components(separatedBy: "-")
                    let id = splice[1]
                    
                    QBRequest.object(withClassName: "FrozenImage", id: id, successBlock: { (response, object) in
                        if response.isSuccess, let object = object, let fields = object.fields, let imageID = fields["image"] as? String {
                            print("Did Download File With ImageID \(imageID)")
                            
                            QBRequest.downloadFile(fromClassName: "FrozenImage", objectID: id, fileFieldName: "image", successBlock: { (response, data) in
                                if response.isSuccess, let imageData = data, let callVC = DGStreamCore.instance.presentedViewController as? DGStreamCallViewController {
                                    callVC.freezeWith(imageData: imageData)
                                }
                                else if let responseError = response.error, let error = responseError.error {
                                    print("Failed To Download with \(error.localizedDescription)")
                                }
                            }, statusBlock: { (response, status) in
                                
                            }, errorBlock: { (response) in
                                if let responseError = response.error, let error = responseError.error {
                                    print("Failed To Download with \(error.localizedDescription)")
                                }
                            })
                            
                        }
                        else if let responseError = response.error, let error = responseError.error {
                            print("Failed To Download with \(error.localizedDescription)")
                        }
                    }, errorBlock: { (response) in
                        if let responseError = response.error, let error = responseError.error {
                            print("Failed To Download with \(error.localizedDescription)")
                        }
                    })
        
                }
                else if notification.contains("conversationRequest") {
                    
                    let splice1 = notification.components(separatedBy: "=")
                    let rest = splice1[1]
                    let splice2 = rest.components(separatedBy: "-")
                    let conversationID = splice2[0]
                    let rest2 = splice2[1]
                    let splice3 = rest2.components(separatedBy: ":")
                    let fromUserID = splice3[0]
                    let toUserIDs = splice3[1]
                    
                    if let _ = self.dataSource.streamManager(self, conversationsWithID: conversationID) {
                        
                    }
                    else {
                        let newConversation = DGStreamConversation()
                        newConversation.conversationID = conversationID
                        
                        var userIDsNumbers:[NSNumber] = []
                        // Multiple Users
                        if toUserIDs.contains(",") {
                            let userIDsStrings = toUserIDs.components(separatedBy: ",")
                            for userIDString in userIDsStrings {
                                if let int = UInt(userIDString) {
                                    userIDsNumbers.append(NSNumber(value: int))
                                }
                            }
                        }
                        else {
                            if let int = UInt(toUserIDs) {
                                userIDsNumbers.append(NSNumber(value: int))
                            }
                        }
                        
                        if let int = UInt(fromUserID) {
                            userIDsNumbers.append(NSNumber(value: int))
                        }
                        
                        newConversation.userIDs = userIDsNumbers
                        
                        DGStreamManager.instance.dataStore.streamManager(DGStreamManager.instance, store: newConversation)
                        
                        if let tabVC = DGStreamCore.instance.presentedViewController as? DGStreamTabBarViewController {
                            tabVC.add(conversation: newConversation)
                        }
                        
                        print("Storing New Conversation \(conversationID)")
                    }
                    
                }
                else if notification.contains("conversationID") {
                    let splice = notification.components(separatedBy: "-")
                    let command = splice[0]
                    let conversationSplice = command.components(separatedBy: "=")
                    let textSplice = splice[1].components(separatedBy: ":")
                    
                    let conversationID = conversationSplice[1]
                    let fromUserID = textSplice[0]
                    if textSplice.count > 1, let fromUserInt = UInt(fromUserID), let currentUser = DGStreamCore.instance.currentUser, let currentUserID = currentUser.userID {
                        
                        let text = textSplice[1]
                        
                        let message = DGStreamMessage()
                        message.conversationID = conversationID
                        message.delivered = Date()
                        message.id = UUID().uuidString
                        message.message = text
                        message.receiverID = currentUserID
                        message.senderID = NSNumber(value: fromUserInt)
                        
                        self.dataStore.streamManager(self, store: message)
                        
                        if let chatVC = DGStreamCore.instance.chatViewController, chatVC.chatConversation.conversationID == conversationID {
                            chatVC.didReceive(message: message)
                        }
                    }
                    
                }
                else if notification.hasPrefix("joinedWhiteBoardSession") {
                    // enteredWhiteboard-fromUserID:whiteBoardSessionID
                    let splice = notification.components(separatedBy: "-")
                    let splice2 = splice[1].components(separatedBy: ":")
                    if let int = UInt(splice2[1]),
                        let callVC = DGStreamCore.instance.presentedViewController as? DGStreamCallViewController {
                        let fromUserID = NSNumber(value: int)
                        let whiteBoardSessionID = splice2[0]
                        callVC.user(userID: fromUserID, joinedWhiteBoardSession: whiteBoardSessionID)
                    }
                }
                else if notification.hasPrefix("exitedWhiteBoardSession") {
                    // enteredWhiteboard-fromUserID:whiteBoardSessionID
                    let splice = notification.components(separatedBy: "-")
                    let splice2 = splice[1].components(separatedBy: ":")
                    if let int = UInt(splice2[0]),
                        let callVC = DGStreamCore.instance.presentedViewController as? DGStreamCallViewController {
                        let fromUserID = NSNumber(value: int)
                        let whiteBoardSessionID = splice2[1]
                        callVC.user(userID: fromUserID, exitedWhiteBoardSession: whiteBoardSessionID)
                    }
                }
                else {
                    let splice = notification.components(separatedBy: "-")
                    let command = splice[0]
                    let userID = splice[1]
                    let userIDNumber = NSNumber(value: Int(userID)!)
                    if let callVC = DGStreamCore.instance.presentedViewController as? DGStreamCallViewController {
                        if userIDNumber != currentUserID {
                            if command == "merge" {
                                print("MERGE WITH \(userID)")
                                if let mergeRequestView = UINib(nibName: "DGStreamAlertView", bundle: Bundle(identifier: "com.dataglance.DGStream")).instantiate(withOwner: self, options: nil).first as? DGStreamAlertView {
                                    
                                    var fromUsername = ""
                                    if let proto = DGStreamManager.instance.dataSource.streamManager(DGStreamManager.instance, userWithUserID: userIDNumber) {
                                        let user = DGStreamUser.createDGStreamUserFrom(proto: proto)
                                        fromUsername = user.username ?? ""
                                    }
                                    callVC.playMergeSound()
                                    mergeRequestView.configureFor(mode: .mergeRequest, fromUsername: fromUsername, message: "", isWaiting: false)
                                    mergeRequestView.presentWithin(viewController: callVC, fromUsername: fromUsername, block: { (accepted) in
                                        if accepted {
                                            DGStreamNotification.accepted(from: currentUserID, with: { (success, errorMessage) in
                                                if success {
                                                    callVC.startMergeModeForHelper()
                                                }
                                                else {
                                                    print("Could Not Merge With User")
                                                }
                                            })
                                        }
                                        else {
                                            DGStreamNotification.declined(from: currentUserID, with: { (success, errorMessage) in
                                                if success {
                                                    print("Declined to merge with user")
                                                    callVC.returnToStreamMode()
                                                }
                                                else {
                                                    print("Failed to decline merge with user")
                                                }
                                            })
                                        }
                                    })
                                }
                            }
                            else if command == "unmerge" {
                                callVC.returnToStreamMode()
                            }
                            else if command == "accepted" {
                                print("REQUEST ACCEPTED")
                                // Determine which response the curret user was waiting for
                                switch waitingForResponse {
                                case .board:
                                    break
                                case .draw:
                                    break
                                    
                                case .merge:
                                    callVC.startMergeModeForHelp()
                                    break
                                    
                                case .share:
                                    break
                                    
                                case .stream:
                                    break
                                }
                                
                            }
                            else if command == "declined" {
                                
                            }
                        }
                    }
                }
            }
        }
    }
    
    func initialize() {
        QBSettings.setApplicationID(62345)
        QBSettings.setAuthKey("nARYSQ7S8-yuaAR")
        QBSettings.setAuthSecret("XWrAtJTC-KvmhBD")
        QBSettings.setAccountKey("QyjirWxtvhs2sZvssAo6")
        QBSettings.setApiEndpoint("https://api.quickblox.com", chatEndpoint: "chat.quickblox.com", forServiceZone: .development)
        
        QBRTCClient.initializeRTC()
        DGStreamSettings.instance.initialize()
        DGStreamCore.instance.initialize()
    }
}
