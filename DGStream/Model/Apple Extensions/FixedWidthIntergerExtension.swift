//
//  FixedWidthIntergerExtension.swift
//  DGStream
//
//  Created by Brandon on 4/12/18.
//  Copyright © 2018 Dataglance. All rights reserved.
//

import Foundation

extension FixedWidthInteger {
    var byteWidth:Int {
        return self.bitWidth/UInt8.bitWidth
    }
    static var byteWidth:Int {
        return Self.bitWidth/UInt8.bitWidth
    }
    
    static func sizeof<T:FixedWidthInteger>(_ int:T) -> Int {
        return int.bitWidth/UInt8.bitWidth
    }
    
    static func sizeof<T:FixedWidthInteger>(_ intType:T.Type) -> Int {
        return intType.bitWidth/UInt8.bitWidth
    }
}
