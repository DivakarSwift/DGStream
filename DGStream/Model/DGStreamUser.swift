//
//  DGStreamUser.swift
//  DGStream
//
//  Created by Brandon on 9/8/17.
//  Copyright © 2017 Dataglance. All rights reserved.
//

import UIKit
import Quickblox
import QuickbloxWebRTC

public class DGStreamUser: NSObject {
    
    static let instance = DGStreamUser()
    
    public var username: String?
    public var password: String?
    public var id: String?
    public var userID: NSNumber?
    var lastSeen: Date?
    
    class func fromQuickblox(user: QBUUser) -> DGStreamUser? {
        if user.id != 0, let username = user.login {
            let dgUser = DGStreamUser()
            dgUser.username = username
            dgUser.userID = NSNumber(value: user.id)
            return dgUser
        }
        return nil
    }
    
    func asQuickbloxUser() -> QBUUser {
        let user = QBUUser()
        user.login = username
        user.password = password
        if let id = self.userID {
            user.id = id.uintValue
        }
        return user
    }
    
    func deepCopy() -> DGStreamUser {
        let copy = DGStreamUser()
        copy.username = self.username
        copy.password = self.password
        copy.id = self.id
        copy.userID = self.userID
        return copy
    }
    
    class func usersFrom(users: [QBUUser]) -> [DGStreamUser] {
        var dgUsers:[DGStreamUser] = []
        for user in users {
            if let newUser = DGStreamUser.fromQuickblox(user: user) {
                let found = dgUsers.filter({ (u) -> Bool in
                    return u.userID?.uintValue == user.id
                }).first
                if found == nil {
                    dgUsers.append(newUser)
                }
            }
        }
        return dgUsers
    }
}