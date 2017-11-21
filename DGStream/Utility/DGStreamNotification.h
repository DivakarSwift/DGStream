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
+(void)conversationRequestFor:(NSString *)conversationID from:(NSNumber *)userID to:(NSNumber *)toUserID containingUserIDs:(NSArray *)userIDs with:(void (^)(bool, NSString *))completion;
+(void)sendText:(NSString *)text from:(NSNumber *) userID to:(NSNumber *) toUserID for:(NSString *) conversationID with:(void(^)(bool success, NSString* errorMessage))completion;
+(void)mergeFrom:(NSNumber *) userID with:(void(^)(bool success, NSString* errorMessage))completion;
+(void)unmergeFrom:(NSNumber *) userID with:(void(^)(bool success, NSString* errorMessage))completion;
+(void)acceptedFrom:(NSNumber *) userID with:(void(^)(bool success, NSString* errorMessage))completion;
+(void)declinedFrom:(NSNumber *) userID with:(void(^)(bool success, NSString* errorMessage))completion;
+(void)freezeWith:(NSString *)frozenImageID for:(NSArray *)userIDs with:(void (^)(bool, NSString *))completion;
+(void)unfreezeFor:(NSArray *)userIDs with:(void (^)(bool, NSString *))completion;
+(void)joinWhiteBoardSession:(NSString *)sessionID forUser:(NSNumber *)userID sendToUsers:(NSArray *)toUsers with:(void (^)(bool, NSString *))completion;
+(void)exitWhiteBoardSession:(NSString *)sessionID forUser:(NSNumber *)userID sendToUsers:(NSArray *)toUsers with:(void (^)(bool, NSString *))completion;
@end
