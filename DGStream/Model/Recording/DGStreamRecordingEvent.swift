//
//  DGStreamRecordingEvent.swift
//  DGStream
//
//  Created by Brandon on 3/29/18.
//  Copyright © 2018 Dataglance. All rights reserved.
//

import UIKit

class DGStreamRecordingEvent: NSObject {
    var timeStamp:Double!
    var isBeginningMerge:Bool!
    var isEndingMerge:Bool!
    
    init(timeStamp: Double, isBeginningMerge: Bool, isEndingMerge: Bool) {
        self.timeStamp = timeStamp
        self.isBeginningMerge = isBeginningMerge
        self.isEndingMerge = isEndingMerge
    }
    
    func asDictionary() -> NSMutableDictionary {
        let dictionary = NSMutableDictionary()
        dictionary.setObject(NSNumber(value: self.timeStamp), forKey: "timeStamp" as NSCopying)
        dictionary.setObject(NSNumber(value: self.isBeginningMerge), forKey: "isBeginningMerge" as NSCopying)
        dictionary.setObject(NSNumber(value: self.isEndingMerge), forKey: "isEndingMerge" as NSCopying)
        return dictionary
    }
}
