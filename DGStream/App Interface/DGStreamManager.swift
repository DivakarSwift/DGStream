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

protocol DGStreamManagerDelegate {
    func userForStream() -> DGStreamUserProtocol
}

public class DGStreamManager: NSObject {
    
    public static let instance = DGStreamManager()
    var parentViewController: UIViewController?
    var presentedViewController: UIViewController?
    
    public func initializeSDK() {
        initializeQuickblox()
    }
    
    public func placeCallFrom(parent: UIViewController, with user: DGStreamUser) {
        DGStreamCore.instance.currentUser = user
        let sdkStoryboard = UIStoryboard(name: "Users", bundle: Bundle(identifier: "com.dataglance.DGStream"))
        if let viewController = sdkStoryboard.instantiateInitialViewController() {
            parent.present(viewController, animated: true, completion: nil)
            parentViewController = parent
        }
    }
    
    public func receivedPushNotification(_ notification: String) {
        if let currentUserID = DGStreamCore.instance.currentUser.userID {
            if notification.contains("-") {
                let splice = notification.components(separatedBy: "-")
                let command = splice[0]
                let userID = splice[1]
                if command == "merge" {
                    print("MERGE WITH \(userID)")
                    if let callVC = DGStreamCore.instance.presentedViewController as? DGStreamCallViewController {
                        callVC.startMergeModeForHelp()
                    }
                }
            }
        }
    }
    
    func initializeQuickblox() {
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
