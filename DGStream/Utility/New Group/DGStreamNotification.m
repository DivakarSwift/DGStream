//
//  DGStreamNotification.m
//  DGStream
//
//  Created by Brandon on 9/29/17.
//  Copyright © 2017 Dataglance. All rights reserved.
//

#import "DGStreamNotification.h"

@implementation DGStreamNotification

+(void)sendText:(NSString *)text from:(NSNumber *)userID to:(NSNumber *)toUserID for:(NSString *)conversationID with:(void (^)(bool, NSString *))completion {
    [QBRequest sendPushWithText:[NSString stringWithFormat:@"conversationID=%@-%@:%@", conversationID, userID, text] toUsers:toUserID.stringValue successBlock:^(QBResponse * _Nonnull response, NSArray<QBMEvent *> * _Nullable events) {
        NSLog(@"SUCCESSFULLY PUSHED");
        completion(YES, @"");
    } errorBlock:^(QBError * _Nonnull error) {
        NSLog(@"FAILED TO PUSH WITH ERROR %@", error.error.localizedDescription);
        completion(NO, error.error.localizedDescription);
    }];
}

+(void)conversationRequestFor:(NSString *)conversationID from:(NSNumber *)userID to:(NSNumber *)toUserID containingUserIDs:(NSArray *)userIDs with:(void (^)(bool, NSString *))completion {
    NSString *userIDString = userID.stringValue;
    NSMutableString* mutableUserIDs = [[NSMutableString alloc] initWithString:@""];
    NSUInteger index = 0;
    NSUInteger count = userIDs.count;
    for (NSNumber* uID in userIDs) {
        NSString *string = uID.stringValue;
        [mutableUserIDs appendString:string];
        index += 1;
        if (index < count) {
            [mutableUserIDs appendString:@","];
        }
    }
    [QBRequest sendPushWithText:[NSString stringWithFormat:@"conversationRequest=%@-%@:%@", conversationID, userIDString, mutableUserIDs] toUsers:toUserID.stringValue successBlock:^(QBResponse * _Nonnull response, NSArray<QBMEvent *> * _Nullable events) {
        NSLog(@"SUCCESSFULLY PUSHED");
        completion(YES, @"");
    } errorBlock:^(QBError * _Nonnull error) {
        NSLog(@"FAILED TO PUSH WITH ERROR %@", error.error.localizedDescription);
        completion(NO, error.error.localizedDescription);
    }];
}

+(void)backgroundCallFrom:(NSNumber *)fromUserID fromUsername:(NSString *)username to:(NSArray *)toUserIDs with:(void (^)(bool, NSString *))completion {
    
    NSMutableString* mutableUserIDs = [[NSMutableString alloc] initWithString:@""];
    NSUInteger index = 0;
    NSUInteger count = toUserIDs.count;
    for (NSNumber* uID in toUserIDs) {
        NSString *string = uID.stringValue;
        [mutableUserIDs appendString:string];
        index += 1;
        if (index < count) {
            [mutableUserIDs appendString:@","];
        }
    }
    
    NSMutableDictionary *payload = [NSMutableDictionary dictionary];
    NSMutableDictionary *aps = [NSMutableDictionary dictionary];
    [aps setObject:username forKey:@"fromUsername"];
    [aps setObject:fromUserID forKey:@"fromUserID"];
    [aps setObject:mutableUserIDs forKey:@"toUserID"];
    [aps setObject:@"ReceiverRing" forKey:QBMPushMessageSoundKey];
    [aps setObject:fromUserID forKey:QBMPushMessageBadgeKey];
    //[aps setObject:mesage forKey:QBMPushMessageAlertKey];
    [payload setObject:aps forKey:QBMPushMessageApsKey];
    
    QBMPushMessage* message = [[QBMPushMessage alloc] initWithPayload:payload];
    [QBRequest sendPush:message toUsers:mutableUserIDs successBlock:^(QBResponse * _Nonnull response, QBMEvent * _Nullable event) {
        completion(true, nil);
    } errorBlock:^(QBError * _Nonnull error) {
        completion(false, error.error.localizedDescription);
    }];
    
//    [QBRequest sendPushWithText:[NSString stringWithFormat:@"&8274-%@-%@", fromUserID.stringValue, username] toUsers:mutableUserIDs successBlock:^(QBResponse * _Nonnull response, NSArray<QBMEvent *> * _Nullable events) {
//        NSLog(@"SUCCESSFULLY PUSHED");
//        completion(YES, @"");
//    } errorBlock:^(QBError * _Nonnull error) {
//        NSLog(@"FAILED TO PUSH WITH ERROR %@", error.error.localizedDescription);
//        completion(NO, error.error.localizedDescription);
//    }];
}

+(void)registerForPushNotificationsWith:(NSData *)deviceToken {
    NSString *deviceIdentifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    QBMSubscription *subscription = [QBMSubscription subscription];
    subscription.notificationChannel = QBMNotificationChannelAPNS;
    subscription.deviceUDID = deviceIdentifier;
    subscription.deviceToken = deviceToken;
    
    [QBRequest createSubscription:subscription successBlock:^(QBResponse *response, NSArray *objects) {
        
    } errorBlock:^(QBResponse *response) {
        
    }];
}

+(void)unregisterForPushNotificationsWith:(void (^)(bool, NSString *))completion {
    NSString *deviceUdid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    [QBRequest unregisterSubscriptionForUniqueDeviceIdentifier:deviceUdid successBlock:^(QBResponse *response) {
        // Unsubscribed successfully
        NSLog(@"DID UNSUBSCRIBE SUCCESSFULLY");
        completion(true, @"");
    } errorBlock:^(QBError *error) {
        // Handle error
        NSLog(@"DID NOT UNSUBSCRIBE SUCCESSFULLY");
        completion(false, @"");
    }];
}

@end
