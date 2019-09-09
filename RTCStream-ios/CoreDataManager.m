//
//  CoreDataManager.m
//  RTCStream-ios
//
//  Created by yafei zhang on 2019/3/18.
//  Copyright © 2019 RTCEngine. All rights reserved.
//

#import "CoreDataManager.h"



static NSString* ROOM = @"111111111";
static NSString* ADDRESS =@"http://47.107.97.230/";
static NSString* USER = @"zhangyf";


static CoreDataManager *_sharedInstance = nil;

@implementation CoreDataManager


- (id)init {
    self = [super init];
    if (self != nil) {
        _severAddrs = ADDRESS;
        _room = ROOM;
        
        uint32_t randomNum = arc4random_uniform(10000);
        NSString* userId = [NSString stringWithFormat:@"%d",randomNum];
        _user= userId;
        
        _psuser =  [NSString stringWithFormat:@"%d",arc4random_uniform(10000000)];
        
        _Appsecret = @"";
        _Appid = @"";
    }
    return self;
}
+ (CoreDataManager*)sharedInstance {
    if (_sharedInstance != nil) {
        return _sharedInstance;
    }
    @synchronized(self) {
        if (_sharedInstance == nil) {
            _sharedInstance = [[self alloc] init];
        }
    }
    return _sharedInstance;
}
@end



