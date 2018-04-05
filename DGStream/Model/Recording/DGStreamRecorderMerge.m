//
//  DGStreamRecorderMerge.m
//  DGStream
//
//  Created by Brandon on 3/28/18.
//  Copyright © 2018 Dataglance. All rights reserved.
//

#import "DGStreamRecorderMerge.h"
#import <AVFoundation/AVFoundation.h>

@implementation DGStreamRecorderMerge

- (void) overlapVideosWithLocalURL:(NSURL *) localURL remoteURL:(NSURL *) remoteURL isMerged:(bool) isMerged fileName:(NSString *) fileName withCompletion:(MergeRecordingCompletion) completion {
        
    AVURLAsset* firstAsset = [AVURLAsset URLAssetWithURL:localURL options:nil];
    AVURLAsset * secondAsset = [AVURLAsset URLAssetWithURL:remoteURL options:nil];
    
    AVMutableComposition* mixComposition = [[AVMutableComposition alloc] init];
    
    AVMutableCompositionTrack *firstTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    
    [firstTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, firstAsset.duration) ofTrack:[[firstAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:kCMTimeZero error:nil];
    
    AVMutableCompositionTrack *secondTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [secondTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, secondAsset.duration) ofTrack:[[secondAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:kCMTimeZero error:nil];
    
    AVMutableVideoCompositionInstruction * MainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    MainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, firstAsset.duration);
    
    AVMutableVideoCompositionLayerInstruction *FirstlayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:firstTrack];
    
    //Here we are creating AVMutableVideoCompositionLayerInstruction for our second track.see how we make use of Affinetransform to move and scale our second Track.
    AVMutableVideoCompositionLayerInstruction *SecondlayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:secondTrack];
    
    if (isMerged) {
        CGAffineTransform Scale = CGAffineTransformMakeScale(1.0f,1.0f);
        CGAffineTransform Move = CGAffineTransformMakeTranslation(0,0);
        [FirstlayerInstruction setTransform:CGAffineTransformConcat(Scale,Move) atTime:kCMTimeZero];
        [FirstlayerInstruction setOpacity: 0.7 atTime: kCMTimeZero];
        
        CGAffineTransform SecondScale = CGAffineTransformMakeScale(1.0f,1.0f);
        CGAffineTransform SecondMove = CGAffineTransformMakeTranslation(0,0);
        [SecondlayerInstruction setTransform:CGAffineTransformConcat(SecondScale,SecondMove) atTime:kCMTimeZero];
    }
    else {
        CGAffineTransform Scale = CGAffineTransformMakeScale(0.6f,0.6f);
        CGAffineTransform Move = CGAffineTransformMakeTranslation(320,320);
        [FirstlayerInstruction setTransform:CGAffineTransformConcat(Scale,Move) atTime:kCMTimeZero];
        
        CGAffineTransform SecondScale = CGAffineTransformMakeScale(1.0f,1.0f);
        CGAffineTransform SecondMove = CGAffineTransformMakeTranslation(0,0);
        [SecondlayerInstruction setTransform:CGAffineTransformConcat(SecondScale,SecondMove) atTime:kCMTimeZero];
    }
    
    //Now we add our 2 created AVMutableVideoCompositionLayerInstruction objects to our AVMutableVideoCompositionInstruction in form of an array.
    MainInstruction.layerInstructions = [NSArray arrayWithObjects:FirstlayerInstruction,SecondlayerInstruction,nil];;
    
    AVMutableVideoComposition *MainCompositionInst = [AVMutableVideoComposition videoComposition];
    MainCompositionInst.instructions = [NSArray arrayWithObject:MainInstruction];
    MainCompositionInst.frameDuration = CMTimeMake(1, 30);
    MainCompositionInst.renderSize = CGSizeMake(640, 480);
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *myPathDocs = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4", fileName]];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:myPathDocs])
    {
        [[NSFileManager defaultManager] removeItemAtPath:myPathDocs error:nil];
    }
    
    NSURL *url = [NSURL fileURLWithPath:myPathDocs];
    
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
    exporter.outputURL=url;
    [exporter setVideoComposition:MainCompositionInst];
    exporter.outputFileType = AVFileTypeMPEG4;
    NSLog(@"EXPORTING");
    [exporter exportAsynchronouslyWithCompletionHandler:^
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"FINISHED EXPORTING %@", exporter.error.localizedDescription);
            completion(exporter.outputURL);
        });
    }];
}

- (NSArray *) getInstructionsForLocalTrack:(AVMutableCompositionTrack *)localTrack andRemoteTrack:(AVMutableCompositionTrack *)remoteTrack withEvents:(NSArray *) events {
    
    NSMutableArray * instructions = [NSMutableArray new];
    
    for (NSDictionary * event in events) {
        
        CMTime time = kCMTimeZero;
        
        NSNumber * timeStamp = event[@"timeStamp"];
        NSNumber * isBeginningMerge = event[@"isBeginningMerge"];
        //NSNumber * isEndingMerge = event[@"isEndingMerge"];
        
        if (timeStamp.doubleValue != 0.0) {
            time = CMTimeMake(timeStamp.doubleValue, 1);
        }
        
        if (isBeginningMerge.boolValue) {
            // Merged
            AVMutableVideoCompositionLayerInstruction *FirstlayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:localTrack];
            CGAffineTransform Scale = CGAffineTransformMakeScale(1.0f,1.0f);
            CGAffineTransform Move = CGAffineTransformMakeTranslation(0,0);
            [FirstlayerInstruction setTransform:CGAffineTransformConcat(Scale,Move) atTime:time];
            [FirstlayerInstruction setOpacity: 0.7 atTime:kCMTimeZero];
            [instructions addObject: FirstlayerInstruction];
            
            AVMutableVideoCompositionLayerInstruction *secondlayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:remoteTrack];
            CGAffineTransform secondScale = CGAffineTransformMakeScale(1.0f,1.0f);
            CGAffineTransform secondMove = CGAffineTransformMakeTranslation(0,0);
            [secondlayerInstruction setTransform:CGAffineTransformConcat(secondScale,secondMove) atTime:time];
            [instructions addObject: secondlayerInstruction];
        }
        else {
            // Unmerged
            AVMutableVideoCompositionLayerInstruction *FirstlayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:localTrack];
            CGAffineTransform Scale = CGAffineTransformMakeScale(1.0f,1.0f);
            CGAffineTransform Move = CGAffineTransformMakeTranslation(0,0);
            [FirstlayerInstruction setTransform:CGAffineTransformConcat(Scale,Move) atTime:time];
            [FirstlayerInstruction setOpacity: 1.0 atTime:kCMTimeZero];
            [instructions addObject: FirstlayerInstruction];
            
            AVMutableVideoCompositionLayerInstruction *secondlayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:remoteTrack];
            CGAffineTransform secondScale = CGAffineTransformMakeScale(0.25f,0.25f);
            CGAffineTransform secondMove = CGAffineTransformMakeTranslation(0,0);
            [secondlayerInstruction setTransform:CGAffineTransformConcat(secondScale,secondMove) atTime:time];
            [instructions addObject: secondlayerInstruction];
        }
    
    }
    
    return instructions;
}

//+(CVPixelBufferRef)pixelBufferFromCGImage:(CGImageRef)image
//{
//    CGSize frameSize = CGSizeMake(CGImageGetWidth(image), CGImageGetHeight(image));
//    
//    // set pixel buffer attributes so we get an iosurface
//    NSDictionary *pixelBufferAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
//                                           [NSDictionary dictionary], kCVPixelBufferIOSurfacePropertiesKey,
//                                           
//                                           CVPixelBufferRef pixelBuffer = NULL;
//                                           
//                                           
//                                           
//                                           CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, frameSize.width, frameSize.height, kCVPixelFormatType_420YpCbCr8BiPlanarFullRange,
//                                                                                 (__bridge CFDictionaryRef)pixelBufferAttributes, &pixelBuffer);
//                                           
//                                           if (status != kCVReturnSuccess) {
//                                               return NULL;
//                                           }
//                                           NSLog(@"[INFO IMAGE] Width %f, Height %f, Byte per row %zi",frameSize.width,frameSize.height,CVPixelBufferGetBytesPerRow(pixelBuffer));
//                                           
//                                           
//                                           CVPixelBufferLockBaseAddress(pixelBuffer, 0);
//                                           void *data = CVPixelBufferGetBaseAddress(pixelBuffer);
//                                           // get y plane
//                                           const uint8_t* yDestPlane = reinterpret_cast<uint8_t*> (CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0));
//                                           
//                                           // get cbCr plane
//                                           const uint8_t* uvDestPlane = reinterpret_cast<uint8_t*> (CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 1));
//                                           
//                                           
//                                           CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
//                                           CGContextRef context = CGBitmapContextCreate(data, frameSize.width, frameSize.height,
//                                                                                        8, CVPixelBufferGetBytesPerRow(pixelBuffer), rgbColorSpace,
//                                                                                        kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Little);
//                                           
//                                           CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image),
//                                                                                  CGImageGetHeight(image)), image);
//                                           CGColorSpaceRelease(rgbColorSpace);
//                                           CGContextRelease(context);
//                                           CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
//                                           
//                                           NSLog(@"[INFO IMAGE] return pixel buffer done");
//                                           return pixelBuffer;
//                                           }
//                                           }

@end
