//
//  OpenCamera.m
//  AgoraCameraDemo
//
//  Created by yangmoumou on 2019/1/25.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import "OpenCamera.h"

@interface OpenCamera() 
@property (nonatomic, strong) AVCaptureSession *captureSession;
//当前使用的视频设备
@property (nonatomic, weak) AVCaptureDeviceInput *videoInputDevice;
@property (nonatomic, strong) AVCaptureDeviceInput *audioInputDevice;
//属于设备
@property (nonatomic, strong) AVCaptureDeviceInput *captureDeviceInput;
//输出设备
@property (nonatomic, strong) AVCaptureVideoDataOutput *captureVideoDataOutput;
@property (nonatomic, strong) AVCaptureAudioDataOutput *captureAudioDataOutput;
@property (nonatomic, strong) AVCaptureConnection *videoConnection;
@property (nonatomic, strong) AVCaptureConnection *audioConnection;
@end
@implementation OpenCamera
- (void)initWithView:(UIView *)renderView {

    [self openCaptureSessionView:renderView];

}

//初始化视频设备
-(void) createCaptureDevice{
    AVCaptureDevice *devices = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:(AVCaptureDevicePositionFront)];
    self.captureDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:devices error:nil];
}

- (void)openCaptureSessionView:(UIView *)renderView {
   self.captureSession = [[AVCaptureSession alloc] init];
    self.captureSession .sessionPreset = AVCaptureSessionPreset1280x720;
    [self createCaptureDevice];
    if ([self.captureSession  canAddInput:_captureDeviceInput]) {
        [self.captureSession  addInput:_captureDeviceInput];
    }
    self.captureVideoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    dispatch_queue_t captureQueue = dispatch_queue_create("aw.capture.queue", DISPATCH_QUEUE_SERIAL);
    [self.captureVideoDataOutput setSampleBufferDelegate:self queue:captureQueue];
    [self.captureVideoDataOutput setAlwaysDiscardsLateVideoFrames:YES];
    [self.captureVideoDataOutput setVideoSettings:@{
                                             (__bridge NSString *)kCVPixelBufferPixelFormatTypeKey:@(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange)
                                             }];

    if ([self.captureSession  canAddOutput:self.captureVideoDataOutput]) {
        [self.captureSession  addOutput:self.captureVideoDataOutput];
    }

//    [self audioInputAndOutput];
    [self.videoConnection setVideoOrientation:AVCaptureVideoOrientationPortrait];

    AVCaptureVideoPreviewLayer *videoLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
    videoLayer.frame = renderView.bounds;
    videoLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [renderView.layer addSublayer:videoLayer];

    [self.captureSession startRunning];
}

// 设置音频I/O 对象
- (void)audioInputAndOutput {
    NSError *error;
    // 初始音频设备对象
    AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    // 音频输入对象
    self.audioInputDevice = [[AVCaptureDeviceInput alloc] initWithDevice:audioDevice error:&error];
    if (error) {
        NSLog(@"== 录音设备出错");
    }
    // 判断session 是否可以添加 音频输入对象
    if ([self.captureSession canAddInput:self.audioInputDevice]) {
        [self.captureSession addInput:self.audioInputDevice];
    }
     _audioConnection = [self.captureAudioDataOutput connectionWithMediaType:AVMediaTypeAudio];
    // 音频输出对象
    self.captureAudioDataOutput = [[AVCaptureAudioDataOutput alloc] init];
    // 判断是否可以添加音频输出对象
    if ([self.captureSession canAddOutput:self.captureAudioDataOutput]) {
        [self.captureSession addOutput:self.captureAudioDataOutput];
    }
    // 创建设置音频输出代理所需要的线程队列
    dispatch_queue_t audioQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
    [self.captureAudioDataOutput setSampleBufferDelegate:self queue:audioQueue];
}

- (AVCaptureConnection *)videoConnection {
    _videoConnection = [self.captureVideoDataOutput connectionWithMediaType:AVMediaTypeVideo];
    _videoConnection.automaticallyAdjustsVideoMirroring =  NO;
    return _videoConnection;
}



-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    // 判断 captureOutput 多媒体输出对象的类型
//    if (captureOutput == self.captureAudioDataOutput) {    // 音频输出对象
//        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(didOutputAudioSampleBuffer:fromConnection:)]) {
//            [self.delegate didOutputAudioSampleBuffer:sampleBuffer fromConnection:connection];
//        }
//    } else {                                    // 视频输出对象
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(didOutputSampleBuffer:fromConnection:)]) {
            [self.delegate didOutputSampleBuffer:sampleBuffer fromConnection:connection];
        }
//    }

}
@end
