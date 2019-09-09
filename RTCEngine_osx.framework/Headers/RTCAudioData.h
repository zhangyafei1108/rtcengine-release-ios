//
//  RTCAudioData.h
//  RTCEngine
//
//  Created by xiang on 2019/3/27.
//  Copyright © 2019 RTCEngine. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RTCAudioData : NSObject

@property (nonatomic, assign) int samples;  //number of samples in this frame
@property (nonatomic, assign) int bytesPerSample;  //number of bytes per sample: 2 for PCM16
@property (nonatomic, assign) int channels;  //number of channels (data are interleaved if stereo)
@property (nonatomic, assign) int samplesPerSec;  //sampling rate
@property (nonatomic, assign) int bufferLength;
@property (nonatomic, assign) int64_t renderTimeMs;
@property (nonatomic, assign) char* buffer;  //data buffer



@end

NS_ASSUME_NONNULL_END
