//
//  DGStreamPhotoSaver.m
//  DGStream
//
//  Created by Brandon on 11/13/17.
//  Copyright © 2017 Dataglance. All rights reserved.
//

#import "DGStreamPhotoSaver.h"

@implementation DGStreamPhotoSaver

-(void)configureWith:(id)delegate and:(AVCaptureSession *)session {
    self.delegate = delegate;
    
//    for (AVCaptureOutput *output in session.outputs) {
//        for (AVCaptureConnection *connection in output.connections) {
//
//        }
//        break;
//    }
    
    self.captureSession = [[AVCaptureSession alloc] init];
    self.captureSession.sessionPreset = AVCaptureSessionPresetLow;
    
    /*
     * Create video connection
     */
    AVCaptureDeviceInput *videoIn = [[AVCaptureDeviceInput alloc]
                                     initWithDevice:[self videoDeviceWithPosition:AVCaptureDevicePositionBack]
                                     error:nil];
    
    if ([self.captureSession canAddInput:videoIn])
    {
        [self.captureSession addInput:videoIn];
    }
    
    AVCaptureVideoDataOutput *videoOut = [[AVCaptureVideoDataOutput alloc] init];
    /*
     Processing can take longer than real-time on some platforms.
     Clients whose image processing is faster than real-time should consider
     setting AVCaptureVideoDataOutput's alwaysDiscardsLateVideoFrames property
     to NO.
     */
    
    //    NSLog(@"Getting Format Types %@", output.availableVideoCVPixelFormatTypes);
    //
    //    NSMutableArray *mutablePixelFormatTypes = [NSMutableArray array];
    //    [output.availableVideoCVPixelFormatTypes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    //        NSNumber* num = (NSNumber *)obj;
    //        [mutablePixelFormatTypes addObject:[num descriptivePixelFormat]];
    //    }];
    //    NSString *pixelFormats = [mutablePixelFormatTypes componentsJoinedByString:@",\n"];
    //    NSLog(@"Available pixel formats:\n%@\n", pixelFormats);
    
    
    [videoOut setAlwaysDiscardsLateVideoFrames:YES];
    [videoOut setVideoSettings:
     @{(id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32BGRA)}];
    dispatch_queue_t videoCaptureQueue =
    dispatch_queue_create("Video Capture Queue", DISPATCH_QUEUE_SERIAL);
    [videoOut setSampleBufferDelegate:self queue:videoCaptureQueue];
    if ([self.captureSession canAddOutput:videoOut]) {
        [self.captureSession addOutputWithNoConnections:videoOut];
    }
    // dispatch_release(videoCaptureQueue);
    //    if ([captureSession canAddOutput:videoOut]) {
    //        [captureSession addOutput:videoOut];
    //    }
    //    else {
    //        NSLog(@"CAN NOT ADD OUTPUT");
    //    }
    
    self.videoConnection = [videoOut connectionWithMediaType:AVMediaTypeVideo];
    self.videoOrientation = [self.videoConnection videoOrientation];
}

-(void)save:(UIImage *)image {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImageWriteToSavedPhotosAlbum(image,
                                       self,
                                       @selector(image:didFinishSavingWithError:contextInfo:),
                                       NULL);
    });
}

- (void)image:(UIImage *)image
didFinishSavingWithError:(NSError *)error
  contextInfo:(void *)contextInfo {
    BOOL success = true;
    if (error) {
        success = false;
    }
    [self.delegate didSavePhoto:success];
}

-(void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    // Create a UIImage+Orientation from the sample buffer data
    //[self.session stopRunning];
    
    //_captureFrame = NO;
    UIImage *image = [DGStreamPhotoSaver imageFromSampleBuffer:sampleBuffer];
    //image = [image rotate:UIImageOrientationRight];
    
    //_frameCaptured = YES;
    
    if (self.delegate != nil)
    {
        [self.delegate didTakeSessionSnapshot:image];
    }
}

+ (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer
{
    // Get a CMSampleBuffer's Core Video image buffer for the media data
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    // Get the number of bytes per row for the pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // Create a bitmap graphics context with the sample buffer data
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    // Create a Quartz image from the pixel data in the bitmap graphics context
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // Unlock the pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    // Free up the context and color space
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    // Create an image object from the Quartz image
    UIImage *image = [UIImage imageWithCGImage:quartzImage];
    
    // Release the Quartz image
    CGImageRelease(quartzImage);
    
    return (image);
}

- (AVCaptureDevice *)videoDeviceWithPosition:(AVCaptureDevicePosition)position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices)
        if ([device position] == position)
            return device;
    
    return nil;
}

@end
