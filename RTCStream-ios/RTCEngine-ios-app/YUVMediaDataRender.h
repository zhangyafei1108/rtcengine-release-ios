//
//  NSObject+YUVMediaDataRender.h
//  RTCEngine-ios-app
//
//  Created by yafei zhang on 2019/3/28.
//  Copyright © 2019 RTCEngine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIImage.h>
#import <UIKit/UIImageView.h>
#import <RTCEngine/RTCVideoData.h>

NS_ASSUME_NONNULL_BEGIN

@interface YUVMediaDataRender :NSObject
+ (instancetype)getmediaDataRender;
- (void)screenShotWithImage:(RTCVideoData*)data callback:(void (^)(UIImage *image))completion;
@end

NS_ASSUME_NONNULL_END
