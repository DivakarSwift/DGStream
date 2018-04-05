//
//  DGStreamRecordingWriter.m
//  DGStream
//
//  Created by Brandon on 4/2/18.
//  Copyright © 2018 Dataglance. All rights reserved.
//

#import "DGStreamRecordingWriter.h"
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreImage/CoreImage.h>

@implementation DGStreamRecordingWriter

- (void)saveMovieToLibraryWithScreenshots:(NSArray *)screenshots
{
    // You just need the height and width of the video here
    // For us, our input and output video was 640 height x 480 width
    // which is what we get from the iOS front camera
    int height = 640;
    int width = 480;
    
    // You can save a .mov or a .mp4 file
    //NSString *fileNameOut = @"temp.mp4";
    NSString *fileNameOut = @"temp.mov";
    
    // We chose to save in the tmp/ directory on the device initially
    NSString *directoryOut = @"tmp/";
    NSString *outFile = [NSString stringWithFormat:@"%@%@",directoryOut,fileNameOut];
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:outFile]];
    NSURL *videoTempURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), fileNameOut]];
    
    // WARNING: AVAssetWriter does not overwrite files for us, so remove the destination file if it already exists
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:[videoTempURL path]  error:NULL];
    
    
    // Create your own array of UIImages
//    NSMutableArray *images = [NSMutableArray array];
//    for (int i=0; i<screenshots.count; i++)
//    {
//        // This was our routine that returned a UIImage. Just use your own.
//        UIImage *image = screenshots[i];
//        // We used a routine to write text onto every image
//        // so we could validate the images were actually being written when testing. This was it below.
//        image = [self writeToImage:image Text:[NSString stringWithFormat:@"%i",i ]];
//        [images addObject:image];
//    }
    
    // If you just want to manually add a few images - here is code you can uncomment
    // NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/movie.mp4"]];
    //    NSArray *images = [[NSArray alloc] initWithObjects:
    //                      [UIImage imageNamed:@"add_ar.png"],
    //                      [UIImage imageNamed:@"add_ja.png"],
    //                      [UIImage imageNamed:@"add_ru.png"],
    //                      [UIImage imageNamed:@"add_ru.png"],
    //                      [UIImage imageNamed:@"add_ar.png"],
    //                      [UIImage imageNamed:@"add_ja.png"],
    //                      [UIImage imageNamed:@"add_ru.png"],
    //                      [UIImage imageNamed:@"add_ar.png"],
    //                      [UIImage imageNamed:@"add_en.png"], nil];
    
    
    NSLog(@"writeImageAsMovie %lu, %@", (unsigned long)screenshots.count, path);
    [self writeImageAsMovie:screenshots toPath:path size:CGSizeMake(height, width)];
}

-(void)writeImageAsMovie:(NSArray *)array toPath:(NSString*)path size:(CGSize)size
{
    
    NSError *error = nil;
    
    // FIRST, start up an AVAssetWriter instance to write your video
    // Give it a destination path (for us: tmp/temp.mov)
    AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL:[NSURL fileURLWithPath:path]
                                                           fileType:AVFileTypeQuickTimeMovie
                                                              error:&error];
    
    
    NSParameterAssert(videoWriter);
    
    NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                   AVVideoCodecH264, AVVideoCodecKey,
                                   [NSNumber numberWithInt:size.width], AVVideoWidthKey,
                                   [NSNumber numberWithInt:size.height], AVVideoHeightKey,
                                   nil];
    
    AVAssetWriterInput* writerInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo
                                                                         outputSettings:videoSettings];
    
    AVAssetWriterInputPixelBufferAdaptor *adaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:writerInput
                                                                                                                     sourcePixelBufferAttributes:nil];
    NSParameterAssert(writerInput);
    NSParameterAssert([videoWriter canAddInput:writerInput]);
    [videoWriter addInput:writerInput];
    
    //Start a SESSION of writing.
    // After you start a session, you will keep adding image frames
    // until you are complete - then you will tell it you are done.
    [videoWriter startWriting];
    // This starts your video at time = 0
    [videoWriter startSessionAtSourceTime:kCMTimeZero];
    
    CVPixelBufferRef buffer = NULL;
    
    // This was just our utility class to get screen sizes etc.
    
    int i = 0;
    while (1)
    {
        // Check if the writer is ready for more data, if not, just wait
        NSLog(@"while %ul", i);
        if(writerInput.readyForMoreMediaData){
            
            CMTime frameTime = CMTimeMake(150, 600);
            // CMTime = Value and Timescale.
            // Timescale = the number of tics per second you want
            // Value is the number of tics
            // For us - each frame we add will be 1/4th of a second
            // Apple recommend 600 tics per second for video because it is a
            // multiple of the standard video rates 24, 30, 60 fps etc.
            CMTime lastTime=CMTimeMake(i*150, 600);
            CMTime presentTime=CMTimeAdd(lastTime, frameTime);
            
            if (i == 0) {presentTime = CMTimeMake(0, 600);}
            // This ensures the first frame starts at 0.
            
            
            if (i >= [array count])
            {
                buffer = NULL;
            }
            else
            {
                // This command grabs the next UIImage and converts it to a CGImage
                UIImage *iImage = (UIImage *)[array objectAtIndex:i];
                buffer = [self pixelBufferFromCGImage:iImage.CGImage];
            }
            
            
            if (buffer)
            {
                // Give the CGImage to the AVAssetWriter to add to your video
                [adaptor appendPixelBuffer:buffer withPresentationTime:presentTime];
                i++;
            }
            else
            {
                
                //Finish the session:
                // This is important to be done exactly in this order
                [writerInput markAsFinished];
                // WARNING: finishWriting in the solution above is deprecated.
                // You now need to give a completion handler.
                [videoWriter finishWritingWithCompletionHandler:^{
                    NSLog(@"Finished writing...checking completion status...");
                    if (videoWriter.status != AVAssetWriterStatusFailed && videoWriter.status == AVAssetWriterStatusCompleted)
                    {
                        NSLog(@"Video writing succeeded.");
                        
                        // Move video to camera roll
                        // NOTE: You cannot write directly to the camera roll.
                        // You must first write to an iOS directory then move it!
                        NSURL *videoTempURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@", path]];
                        //[self saveToCameraRoll:videoTempURL];
                        NSLog(@"Video URL %@", videoTempURL);
                        
                    } else
                    {
                        NSLog(@"Video writing failed: %@", videoWriter.error);
                    }
                    
                }]; // end videoWriter finishWriting Block
                
                CVPixelBufferPoolRelease(adaptor.pixelBufferPool);
                
                NSLog (@"Done");
                break;
            }
        }
    }
}

- (CVPixelBufferRef) pixelBufferFromCGImage: (CGImageRef) image
{
    // This again was just our utility class for the height & width of the
    // incoming video (640 height x 480 width)
    int height = 640;
    int width = 480;
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             nil];
    CVPixelBufferRef pxbuffer = NULL;
    
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, width,
                                          height, kCVPixelFormatType_32ARGB, (__bridge CFDictionaryRef) options,
                                          &pxbuffer);
    
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata != NULL);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(pxdata, width,
                                                 height, 8, 4*width, rgbColorSpace,
                                                 kCGImageAlphaNoneSkipFirst);
    NSParameterAssert(context);
    CGContextConcatCTM(context, CGAffineTransformMakeRotation(0));
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image),
                                           CGImageGetHeight(image)), image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
}

@end
