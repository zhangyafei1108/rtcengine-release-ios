//
//  CoreDataManager.h
//  RTCStream-ios
//
//  Created by yafei zhang on 2019/3/18.
//  Copyright © 2019 RTCEngine. All rights reserved.
//
//  可以下沉到RTCStream中，记录配置信息
//

#import <Foundation/Foundation.h>


#if TARGET_OS_IPHONE || TARGET_OS_SIMULATOR
#import <UIKit/UIKit.h>
typedef UIView XESView;
typedef UIImage XESImage;
typedef UIEdgeInsets XESEdgeInsets;
static NSString* PLATFORM = @"ios";

#elif TARGET_OS_MAC
#import <AppKit/AppKit.h>
typedef NSImage XESImage;
typedef NSEdgeInsets XESEdgeInsets;
static NSString* PLATFORM = @"osx";

#endif


NS_ASSUME_NONNULL_BEGIN
#define DataManager (CoreDataManager.sharedInstance)



@interface CoreDataManager : NSObject

+(CoreDataManager *)sharedInstance;

//room CharParameter
@property (nonatomic, copy) NSString *severAddrs; //服务器地址
@property (nonatomic, copy) NSString *room; //房间号
@property (nonatomic, copy) NSString *user; //用户名'
@property (nonatomic, copy) NSString *psuser; //用户名

@property (nonatomic, copy) NSString *Appid; //用户申请的appId
@property (nonatomic, copy) NSString *Appsecret; //用户申请加密密码，不会网上传输


//pusher


//player

@end

NS_ASSUME_NONNULL_END
