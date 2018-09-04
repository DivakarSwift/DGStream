//
//  DGStreamMediaMonth.swift
//  DGStream
//
//  Created by Brandon on 8/21/18.
//  Copyright © 2018 Dataglance. All rights reserved.
//

import UIKit

class DGStreamMediaMonth: NSObject {
    
    var month: String!
    var year: String!
    var createdDate: NSDate!
    
    class func createDGStreamMediaMonthsFrom(protocols: [DGStreamMediaMonthProtocol]) -> [DGStreamMediaMonth] {
        var months:[DGStreamMediaMonth] = []
        for proto in protocols {
            let month = DGStreamMediaMonth()
            let date = proto.dgCreatedDate
            month.createdDate = date as NSDate
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "LLLL"
            month.month = dateFormatter.string(from: date)
            month.year = "2018"
            months.append(month)
        }
        return months
    }

}

extension DGStreamMediaMonth: DGStreamMediaMonthProtocol {
    var dgMonth: String {
        get {
            return self.month
        }
        set {
            self.month = self.dgMonth
        }
    }
    
    var dgYear: String {
        get {
            return self.year
        }
        set {
            self.year = self.dgYear
        }
    }
    
    var dgCreatedDate: Date {
        get {
            return self.createdDate as Date
        }
        set {
            self.createdDate = self.dgCreatedDate as NSDate
        }
    }
    
}
