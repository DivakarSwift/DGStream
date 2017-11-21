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

+(void)mergeFrom:(NSNumber *) userID with:(void(^)(bool success, NSString* errorMessage))completion {
    NSString *userIDString = userID.stringValue;
    [QBRequest sendPushWithText:[NSString stringWithFormat:@"merge-%@", userIDString] toUsersWithAnyOfTheseTags:@"dev" successBlock:^(QBResponse * _Nonnull response, NSArray<QBMEvent *> * _Nullable events) {
        NSLog(@"SUCCESSFULLY PUSHED");
        completion(YES, @"");
    } errorBlock:^(QBError * _Nonnull error) {
        NSLog(@"FAILED TO PUSH WITH ERROR %@", error.error.localizedDescription);
        completion(NO, error.error.localizedDescription);
    }];
}

+(void)unmergeFrom:(NSNumber *) userID with:(void(^)(bool success, NSString* errorMessage))completion {
    NSString *userIDString = userID.stringValue;
    [QBRequest sendPushWithText:[NSString stringWithFormat:@"unmerge-%@", userIDString] toUsersWithAnyOfTheseTags:@"dev" successBlock:^(QBResponse * _Nonnull response, NSArray<QBMEvent *> * _Nullable events) {
        NSLog(@"SUCCESSFULLY PUSHED");
        completion(YES, @"");
    } errorBlock:^(QBError * _Nonnull error) {
        NSLog(@"FAILED TO PUSH WITH ERROR %@", error.error.localizedDescription);
        completion(NO, error.error.localizedDescription);
    }];
}

+(void)acceptedFrom:(NSNumber *)userID with:(void (^)(bool, NSString *))completion {
    NSString *userIDString = userID.stringValue;
    [QBRequest sendPushWithText:[NSString stringWithFormat:@"accepted-%@", userIDString] toUsersWithAnyOfTheseTags:@"dev" successBlock:^(QBResponse * _Nonnull response, NSArray<QBMEvent *> * _Nullable events) {
        NSLog(@"SUCCESSFULLY PUSHED");
        completion(YES, @"");
    } errorBlock:^(QBError * _Nonnull error) {
        NSLog(@"FAILED TO PUSH WITH ERROR %@", error.error.localizedDescription);
        completion(NO, error.error.localizedDescription);
    }];
}

+(void)declinedFrom:(NSNumber *)userID with:(void (^)(bool, NSString *))completion {
    NSString *userIDString = userID.stringValue;
    [QBRequest sendPushWithText:[NSString stringWithFormat:@"declined-%@", userIDString] toUsersWithAnyOfTheseTags:@"dev" successBlock:^(QBResponse * _Nonnull response, NSArray<QBMEvent *> * _Nullable events) {
        NSLog(@"SUCCESSFULLY PUSHED");
        completion(YES, @"");
    } errorBlock:^(QBError * _Nonnull error) {
        NSLog(@"FAILED TO PUSH WITH ERROR %@", error.error.localizedDescription);
        completion(NO, error.error.localizedDescription);
    }];
}

+(void)freezeWith:(NSString *)frozenImageID for:(NSArray *)userIDs with:(void (^)(bool, NSString *))completion {
    
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
    
    NSLog(@"Freeze With %@", mutableUserIDs);
    
    [QBRequest sendPushWithText:[NSString stringWithFormat:@"freeze-%@", frozenImageID] toUsers:mutableUserIDs successBlock:^(QBResponse * _Nonnull response, NSArray<QBMEvent *> * _Nullable events) {
        NSLog(@"SUCCESSFULLY PUSHED");
        completion(YES, @"");
    } errorBlock:^(QBError * _Nonnull error) {
        NSLog(@"FAILED TO PUSH WITH ERROR %@", error.error.localizedDescription);
        completion(NO, error.error.localizedDescription);
    }];
}

+(void)unfreezeFor:(NSArray *)userIDs with:(void (^)(bool, NSString *))completion {
    
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
    
    [QBRequest sendPushWithText:@"unfreeze-true" toUsers:mutableUserIDs successBlock:^(QBResponse * _Nonnull response, NSArray<QBMEvent *> * _Nullable events) {
        NSLog(@"SUCCESSFULLY PUSHED");
        completion(YES, @"");
    } errorBlock:^(QBError * _Nonnull error) {
        NSLog(@"FAILED TO PUSH WITH ERROR %@", error.error.localizedDescription);
        completion(NO, error.error.localizedDescription);
    }];
}

+(void)joinWhiteBoardSession:(NSString *)sessionID forUser:(NSNumber *)userID sendToUsers:(NSArray *)toUsers with:(void (^)(bool, NSString *))completion {
    
    NSMutableString* mutableUserIDs = [[NSMutableString alloc] initWithString:@""];
    NSUInteger index = 0;
    NSUInteger count = toUsers.count;
    for (NSNumber* uID in toUsers) {
        NSString *string = uID.stringValue;
        [mutableUserIDs appendString:string];
        index += 1;
        if (index < count) {
            [mutableUserIDs appendString:@","];
        }
    }
    
    NSString * message = [NSString stringWithFormat:@"joinedWhiteBoardSession-%@:%@", sessionID, userID.stringValue];
    
    [QBRequest sendPushWithText:message toUsers:mutableUserIDs successBlock:^(QBResponse * _Nonnull response, NSArray<QBMEvent *> * _Nullable events) {
        NSLog(@"SUCCESSFULLY PUSHED");
        completion(YES, @"");
    } errorBlock:^(QBError * _Nonnull error) {
        NSLog(@"FAILED TO PUSH WITH ERROR %@", error.error.localizedDescription);
        completion(NO, error.error.localizedDescription);
    }];
}

+(void)exitWhiteBoardSession:(NSString *)sessionID forUser:(NSNumber *)userID sendToUsers:(NSArray *)toUsers with:(void (^)(bool, NSString *))completion {
    
    NSMutableString* mutableUserIDs = [[NSMutableString alloc] initWithString:@""];
    NSUInteger index = 0;
    NSUInteger count = toUsers.count;
    for (NSNumber* uID in toUsers) {
        NSString *string = uID.stringValue;
        [mutableUserIDs appendString:string];
        index += 1;
        if (index < count) {
            [mutableUserIDs appendString:@","];
        }
    }
    
    NSString * message = [NSString stringWithFormat:@"exitedWhiteBoardSession-%@:%@", sessionID, userID.stringValue];
    
    [QBRequest sendPushWithText:message toUsers:mutableUserIDs successBlock:^(QBResponse * _Nonnull response, NSArray<QBMEvent *> * _Nullable events) {
        NSLog(@"SUCCESSFULLY PUSHED");
        completion(YES, @"");
    } errorBlock:^(QBError * _Nonnull error) {
        NSLog(@"FAILED TO PUSH WITH ERROR %@", error.error.localizedDescription);
        completion(NO, error.error.localizedDescription);
    }];
}

@end
