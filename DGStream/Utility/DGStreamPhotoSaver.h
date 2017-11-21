//
//  DGStreamPhotoSaver.h
//  DGStream
//
//  Created by Brandon on 11/13/17.
//  Copyright © 2017 Dataglance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol DGStreamPhotoSaverDelegate
-(void)didSavePhoto: (BOOL)success;
-(void)didTakeSessionSnapshot: (UIImage *)image;
@end

@interface DGStreamPhotoSaver : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate>

@property (weak, nonatomic) AVCaptureConnection *videoConnection;

@property (nonatomic) AVCaptureVideoOrientation videoOrientation;

@property (strong, nonatomic) AVCaptureSession* captureSession;

@property (weak, nonatomic) id<DGStreamPhotoSaverDelegate> delegate;

@property (nonatomic) dispatch_queue_t  sampleBufferQueue; 

-(void)save:(UIImage *)image;
-(void)configureWith:(id) delegate and:(AVCaptureSession *) session;

@end
