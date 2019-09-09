//
//  RTCMediaDelegate.h
//  RTCEngine
//
//  Created by xiang on 2019/3/27.
//  Copyright © 2019 RTCEngine. All rights reserved.
//


#import "RTCVideoData.h"
#import "RTCAudioData.h"



#ifndef RTCMediaDelegate_h
#define RTCMediaDelegate_h



@protocol RTCMediaVideoProcessDelegate <NSObject>

@optional
- (void)didCapturedVideoData:(RTCVideoData *)data;
@end



@protocol RTCMediaAudioProcessDelegate <NSObject>

@optional
- (void)didCapturedAuidoData:(RTCAudioData *)data;

@end


#endif /* RTCMediaDelegate_h */
