//
//  DGStreamRecorderMerge.h
//  DGStream
//
//  Created by Brandon on 3/28/18.
//  Copyright © 2018 Dataglance. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^MergeRecordingCompletion)(NSURL *);

@interface DGStreamRecorderMerge : NSObject
- (void) overlapVideosWithLocalURL:(NSURL *) localURL remoteURL:(NSURL *) remoteURL isMerged:(bool) isMerged fileName:(NSString *) fileName withCompletion:(MergeRecordingCompletion) completion;
//+(CVPixelBufferRef)pixelBufferFromCGImage:(CGImageRef)image;
@end
