//
//  DGBeaconNotification.swift
//  DGStream
//
//  Created by Brandon on 1/2/18.
//  Copyright © 2018 Dataglance. All rights reserved.
//

import UIKit
import UserNotifications

class DGBeaconNotification: NSObject {
    
    var isAuthorized:Bool = false
    var shouldPushNotification = true
    
    override init() {
        super.init()
        checkForAuthorization()
    }
    
    func checkForAuthorization() {
        requestAuthorization()
    }
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (success, error) in
            if error == nil {
                self.isAuthorized = true
            }
        }
    }
    
    func pushNotification(title: String, body: String) {
        if shouldPushNotification {
            
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.sound = UNNotificationSound(named: "ReceiverRing.wav")
            content.categoryIdentifier = UNNotificationDefaultActionIdentifier
            
            UNUserNotificationCenter.current().delegate = self
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.10, repeats: false)
            
            let notification = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(notification) { (error) in
                if error == nil {
                    
                }
                else {
                    
                }
            }
        }
    }
}

extension DGBeaconNotification: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        shouldPushNotification = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.shouldPushNotification = true
        }
        completionHandler(.alert)
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
    }
}

