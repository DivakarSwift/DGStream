//
//  DGStreamChatBubble.swift
//  DGStream
//
//  Created by Brandon on 1/8/18.
//  Copyright © 2018 Dataglance. All rights reserved.
//

import UIKit
import NMessenger

class DGStreamChatBubble: Bubble, BubbleConfigurationProtocol {
    
    open var isMasked = false
    
    public override init() {}
    
    func getIncomingColor() -> UIColor {
        return UIColor.dgGreen()
    }
    
    func getOutgoingColor() -> UIColor {
        return UIColor.dgBlueDark()
    }
    
    func getBubble() -> Bubble {
        let newBubble = DefaultBubble()
        newBubble.hasLayerMask = self.isMasked
        return newBubble
    }
    
    func getSecondaryBubble() -> Bubble {
        let newBubble = StackedBubble()
        newBubble.hasLayerMask = self.isMasked
        return newBubble
    }
}

class DGStreamChatImageBubble: Bubble, BubbleConfigurationProtocol {
    
    open var isMasked = false
    
    public override init() {}
    
    func getIncomingColor() -> UIColor {
        return .clear
    }
    
    func getOutgoingColor() -> UIColor {
        return .clear
    }
    
    func getBubble() -> Bubble {
        let newBubble = DefaultBubble()
        newBubble.hasLayerMask = self.isMasked
        return newBubble
    }
    
    func getSecondaryBubble() -> Bubble {
        let newBubble = StackedBubble()
        newBubble.hasLayerMask = self.isMasked
        return newBubble
    }
}
