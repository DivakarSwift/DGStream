//
//  DGStreamBroadcast.swift
//  DGStream
//
//  Created by Brandon on 8/31/17.
//  Copyright © 2017 Dataglance. All rights reserved.
//

import UIKit
import Quickblox

class DGStreamBroadcast: NSObject {
    
    var session:QBSession!
    var canCall = false
    
    override init() {
        super.init()
        initializeSession()
    }
    
    func initializeSession() {
        session = QBSession()
        let details = QBASession()
        session.start(withDetails: details) { 
            self.canCall = true
        }
    }
    
    func resetSession() {
        self.canCall = false
    }
    
    func beginBroadcast() {
        
        let user = DGStreamUser.instance.asQuickbloxUser()
        print(user.login)
        
        
    }
    
}
