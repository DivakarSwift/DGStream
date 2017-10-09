//
//  DGStreamNotification.m
//  DGStream
//
//  Created by Brandon on 9/29/17.
//  Copyright © 2017 Dataglance. All rights reserved.
//

#import "DGStreamNotification.h"

@implementation DGStreamNotification

+(void)mergeFrom:(NSNumber *) userID {
    NSString *userIDString = userID.stringValue;
    [QBRequest sendPushWithText:[NSString stringWithFormat:@"merge-%@", userIDString] toUsersWithAnyOfTheseTags:@"dev" successBlock:^(QBResponse * _Nonnull response, NSArray<QBMEvent *> * _Nullable events) {
        NSLog(@"SUCCESSFULLY PUSHED");
    } errorBlock:^(QBError * _Nonnull error) {
        NSLog(@"ERROR %@", error.error.localizedDescription);
    }];
}

@end
