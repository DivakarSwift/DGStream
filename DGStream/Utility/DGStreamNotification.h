//
//  DGStreamNotification.h
//  DGStream
//
//  Created by Brandon on 9/29/17.
//  Copyright © 2017 Dataglance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quickblox/Quickblox.h>
#import <QuickbloxWebRTC/QuickbloxWebRTC.h>

@interface DGStreamNotification : NSObject
+(void)mergeFrom:(NSNumber *) userID;
@end
