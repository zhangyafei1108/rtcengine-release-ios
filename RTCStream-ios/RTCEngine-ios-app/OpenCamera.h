//
//  OpenCamera.h
//  AgoraCameraDemo
//
//  Created by yangmoumou on 2019/1/25.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol OpenCameraDelegate <NSObject>

- (void)didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection;

- (void)didOutputAudioSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection;
@end
NS_ASSUME_NONNULL_BEGIN

@interface OpenCamera : NSObject<AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureAudioDataOutputSampleBufferDelegate>
- (void)initWithView:(UIView *)renderView;
@property (nonatomic, weak)id<OpenCameraDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
