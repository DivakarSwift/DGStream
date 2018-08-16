//
//  DGStreamUserDetail.swift
//  DGStream
//
//  Created by Brandon on 8/14/18.
//  Copyright © 2018 Dataglance. All rights reserved.
//

import UIKit
import CoreData

public class DGStreamUserDetail: NSObject {
    var title: String!
    var value: String!
    var priority: Int!
    
    init(title: String, value: String, priority: Int) {
        self.title = title
        self.value = value
        self.priority = priority
    }
    
    class func createDGStreamUserDetailsFrom(protocols: [DGStreamUserDetailProtocol]) -> [DGStreamUserDetail] {
        var details:[DGStreamUserDetail] = []
        for proto in protocols {
            details.append(DGStreamUserDetail.createDGStreamUserDetailFrom(proto: proto))
        }
        return details
    }
    
    class func createDGStreamUserDetailFrom(proto: DGStreamUserDetailProtocol) -> DGStreamUserDetail {
        return DGStreamUserDetail(title: proto.dgTitle, value: proto.dgValue, priority: proto.dgPriority)
    }
}

extension DGStreamUserDetail: DGStreamUserDetailProtocol {
    public var dgPriority: Int {
        get {
            return self.priority
        }
        set {
            self.dgPriority = self.priority
        }
    }
    
    public var dgTitle: String {
        get {
            return self.title
        }
        set {
            self.dgTitle = self.title
        }
    }
    
    public var dgValue: String {
        get {
            return self.value
        }
        set {
            self.dgValue = self.value
        }
    }
}
