//
//  DGStreamContact.swift
//  DGStream
//
//  Created by Brandon on 10/20/17.
//  Copyright © 2017 Dataglance. All rights reserved.
//

import UIKit

class DGStreamContact: NSObject {
    var userID: NSNumber?
    var user: DGStreamUser?
    
    class func createDGStreamContactFrom(user: DGStreamUser) -> DGStreamContact {
        let contact = DGStreamContact()
        contact.user = user
        contact.userID = user.userID
        return contact
    }
    
    class func createDGStreamContactsFrom(protocols: [DGStreamContactProtocol]) -> [DGStreamContact] {
        var contacts:[DGStreamContact] = []
        for proto in protocols {
            let contact = DGStreamContact()
            if let protoUser = DGStreamManager.instance.dataSource.streamManager(DGStreamManager.instance, userWithUserID: proto.dgUserID) {
                contact.user = DGStreamUser.createDGStreamUserFrom(proto: protoUser)
            }
            contact.userID = proto.dgUserID
            contacts.append(contact)
        }
        return contacts
    }
}

extension DGStreamContact: DGStreamContactProtocol {
    var dgUserID: NSNumber {
        get {
            return self.userID ?? NSNumber(value: 0)
        }
        set {
            self.userID = self.dgUserID
        }
    }
}
