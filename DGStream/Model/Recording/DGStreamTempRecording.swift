//
//  DGStreamTempRecording.swift
//  DGStream
//
//  Created by Brandon on 4/2/18.
//  Copyright © 2018 Dataglance. All rights reserved.
//

import UIKit

class DGStreamTempRecording: NSObject {
    var id: String!
    var localURL: URL!
    var startTime: CMTime!
    var endTime: CMTime!
    var isMerge: Bool = false
}
