//
//  RTCShownViewController.m
//  RTCEngine-osx-app
//
//  Created by yafei zhang on 2019/3/29.
//  Copyright © 2019 RTCEngine. All rights reserved.
//

#import "RTCShownViewController.h"
#import "CoreDataManager.h"
#import <RTCEngine_osx/RTCEngine.h>
#import <JWT/JWT.h>
#import <AFNetworking/AFNetworking.h>

#define OP_HIGHT  64

@interface RTCShownViewController  ()<RTCEngineDelegate,RTCMediaAudioProcessDelegate,RTCMediaVideoProcessDelegate>{
    BOOL audioMuted ;
    BOOL videoMuted ;
    BOOL cameraFront;
    BOOL imageViewShow;
    
    BOOL boRunning;
    NSString* mstrToken;

}

@property (nonatomic, strong) RTCEngine* rtcEngine;
@property (nonatomic, strong) NSMutableDictionary* players;
@property (nonatomic,readonly) XESView* preview;

@property (strong) IBOutlet NSView *mbtnCameraOn;
@property (weak) IBOutlet NSButton *mbtnMuteAudio;
@property (weak) IBOutlet NSButton *mbtnSwitchCamere;
@property (weak) IBOutlet NSButton *mbtnSwithMeeting;
@end

@implementation RTCShownViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    audioMuted = FALSE;
    videoMuted = FALSE;
    cameraFront = FALSE;
    imageViewShow = FALSE;
    boRunning = FALSE;
    
    
    _players = [NSMutableDictionary dictionary];
    
    // Do any additional setup after loading the view.
   // [self meetingIn];
    // 创建管理者对象
    AFHTTPSessionManager *sessionManager = [AFHTTPSessionManager manager];
    // 设置请求参数
    //NSString *urlStr = @"http://47.107.97.230/api/token";
   // NSString *urlStr = @"http://39.106.131.10/api/token";
    
   // [self testAFCmethord];

    NSString *urlStr  = @"http://rtcapi.xueersi.com/api/token";
    // 需要设置 body 体
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    [result setObject:DataManager.room forKey:@"room"];
    [result setObject:DataManager.user  forKey:@"user"];
    [result setObject:DataManager.psuser  forKey:@"psuser"];
    NSString* auth = [JWT encodePayload:@{
                                                    @"appid":DataManager.Appid,
                                                    @"timestamp":[self getTime],
                                                    } withSecret:DataManager.Appsecret];

    AFHTTPRequestSerializer *requestSerializer =  [AFJSONRequestSerializer serializer];
    
    NSDictionary *headerFieldValueDictionary = @{@"Authorization":auth};
    if (headerFieldValueDictionary != nil) {
        for (NSString *httpHeaderField in headerFieldValueDictionary.allKeys) {
            NSString *value = headerFieldValueDictionary[httpHeaderField];
            [requestSerializer setValue:value forHTTPHeaderField:httpHeaderField];
        }
    }
    
    sessionManager.requestSerializer = requestSerializer;
    
//    sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil];


    //NSDictionary *dic = @{@" " : @" ",@" " : @" "};
    [sessionManager POST:urlStr parameters:result progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"请求成功");
        
        NSLog(@"resp:%@",responseObject);
        NSDictionary *resDict = [responseObject objectForKey:@"d"];
        
        for(NSString *key in resDict){
            NSString * realTmp = [resDict objectForKey:key];
            mstrToken = realTmp;
            [self meetingIn];
        }
        
        //NSMutableDictionary *token = [NSMutableDictionary dictionary];
        //NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        
        //
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"请求失败");
    }];
    
}

-(void)testAFCmethord{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil];
    
    [manager GET:@"http://rtcapi.xueersi.com/test" parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

-(NSString *)getTime{
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a=[date timeIntervalSince1970]*1000; // *1000 是精确到毫秒，不乘就是精确到秒
    NSString *timeString = [NSString stringWithFormat:@"%.0f", a]; //转为字符型
    return timeString;
}
- (NSString *)getTimeNow
{
    NSString* date;
    
    NSDateFormatter * formatter = [[NSDateFormatter alloc ] init];
    //[formatter setDateFormat:@"YYYY.MM.dd.hh.mm.ss"];
    [formatter setDateFormat:@"YYYY-MM-dd hh:mm:ss:SSS"];
    date = [formatter stringFromDate:[NSDate date]];
    NSString* timeNow = [[NSString alloc] initWithFormat:@"%@", date];
    NSLog(@"%@", timeNow);
    return timeNow;
}

- (void)meetingIn{
    
    
    // Do any additional setup after loading the view.
//    NSString* test_token = [JWT encodePayload:@{
//                                                @"room":DataManager.room,
//                                                @"user":DataManager.user,
//                                                @"wsUrl":DataManager.severAddrs,
//                                                @"appid":@"407efd6acdeb4683b52e0bd9bb92a188",
//                                                @"type":@"1",
//                                                } withSecret:@"thisissecret"];
    _rtcEngine = [[RTCEngine alloc] initWithToken:mstrToken delegate:self];
    
    
    
   
    
    //-[_rtcEngine setChannelProfile:RTCChannelProfileLiveBroadcasting];
    [_rtcEngine setVideoBitrate:200];
    
    
    _preview = [[XESView alloc] initWithFrame:CGRectMake(0, 0, 120, 160)];
    _preview.frame = CGRectMake(0,self.view.bounds.size.height, self.view.bounds.size.width/2, self.view.bounds.size.height/2);
    [self.view addSubview:_preview];
    
    
    [_players setObject:_preview forKey:DataManager.user];
    
    
    [_rtcEngine setupLocalVideo:_preview];
    
    [_rtcEngine startPreview];
    
    
    [_rtcEngine joinRoom];
    
    _rtcEngine.videoProcessDelegate = self;
    _rtcEngine.audioProcessDelegate = self;
    
    [self layoutVideoViews];
}

-(void)meetingOut{
    [_rtcEngine stopPreview];
    [_rtcEngine leaveRoom];
    //view
    [_players removeAllObjects];
    
    [_rtcEngine destroy];
    _rtcEngine = nil;
}

- (void)layoutVideoViews
{
    int i =0 ;
    
    NSUInteger allCount =[_players count];
    
    for(NSString *key in _players){
        XESView * viewTmp = [_players objectForKey:key];
        if(viewTmp){
            viewTmp.frame = [self frameAtPosition:i++ all:allCount];
        }
    }
    
}
-(CGRect)frameAtPosition:(int)postion all:(NSUInteger)allSum
{
    
    float lineNum = ceilf(sqrtf(allSum));
    
    
    CGRect bounds = self.view.bounds;
    
    CGFloat width = bounds.size.width / lineNum;
    CGFloat height = (bounds.size.height- OP_HIGHT) / lineNum;
    
    CGFloat x = ((postion) % (NSUInteger)lineNum) * width;
    CGFloat y =OP_HIGHT + (lineNum - (NSUInteger)((postion)/lineNum) -1) * height;
    
    CGRect frame = CGRectMake(x, y, width, height);
    
    return frame;
}
- (IBAction)noMeetingStop:(id)sender {
    if(boRunning){
        boRunning = FALSE;
        [self meetingOut];
    }else {
        audioMuted = FALSE;
        videoMuted = FALSE;
        cameraFront = FALSE;
        boRunning = FALSE;
        [self meetingIn];
    }

}
- (IBAction)onMuteAudio:(id)sender {
    if (_rtcEngine) {
        [_rtcEngine enableLocalAudio:audioMuted];
        audioMuted = !audioMuted;
    }
}
- (IBAction)onPushStop:(id)sender {
    
    if (_rtcEngine) {
        [_rtcEngine enableLocalVideo:videoMuted];
        videoMuted = !videoMuted;
    }
//    [self.mbtnCameraOn setImage:[UIImage imageNamed:(videoMuted ? @"btn_join" : @"btn_join_cancel")] forState:UIControlStateNormal];
}

- (void)viewWillDisappear
{
    if(boRunning){
        boRunning = FALSE;
        [self meetingOut];
    }
}
- (void)dismissViewController:(NSViewController *)viewController NS_AVAILABLE_MAC(10_10);
{
    
    
}
#pragma call back RTCIN

- (void)rtcEngine:(RTCEngine*)engine didOccurError:(NSInteger)code
{
    
    
}


- (void)rtcEngine:(RTCEngine*)engine localUserJoindWithUid:(NSUInteger)uid
{
    boRunning = TRUE;
    [self layoutVideoViews];

}

- (XESView *)fetchSessionOfUid:(NSUInteger)uid {
    
    NSArray * allkeys = [_players allKeys];
    XESView * viewTmp= nil;
    
    for (int i = 0; i < allkeys.count; i++)
    {
        NSString * key = [allkeys objectAtIndex:i];
        if([key intValue] == uid){
            viewTmp = [_players objectForKey:key];
        }
    }
    return viewTmp;
}
- (XESView *)videoSessionOfUid:(NSUInteger)uid {
    XESView *fetchedSession = [self fetchSessionOfUid:uid ];
    
    if (fetchedSession) {
        return fetchedSession;
    } else {
        XESView * romteView = [[XESView alloc] initWithFrame:CGRectMake(0, 0, 120, 160)];
        romteView.frame = CGRectMake(0, 0, self.view.bounds.size.width/2, self.view.bounds.size.height/2);
        [self.view addSubview:romteView];
        [_players setObject:romteView forKey:[NSString stringWithFormat: @"%ld", uid]];
        return romteView;
    }
}
// remote,  when got the first audio frame
- (void)rtcEngine:(RTCEngine*)engine remoteUserJoinWitnUid:(NSUInteger)uid 
{
    boRunning = TRUE;
    
    NSLog(@"join the meeting sucessful  %d",uid);
    
    XESView *xerView  =  [self videoSessionOfUid:uid];
    
    [_rtcEngine setRemoteRenderMode:uid mode:RTCVideoRenderModeHidden];
    
    [_rtcEngine setupRemoteVideo:uid view:xerView];
    
    
    //    [self.view bringSubviewToFront:self.mbtnQuit];
    //    [self.view bringSubviewToFront:self.mbtnCamera];
    //    [self.view bringSubviewToFront:self.mbtnAudio];
    //    [self.view bringSubviewToFront:self.mbtnVideo];
    //
    [self layoutVideoViews];
    
}

- (void)rtcEngine:(RTCEngine *_Nonnull )engine remotefirstAudioRecvWithUid:(NSUInteger)uid
{
    
}
/** notice Video data received
 @param uid remote id NSUInteger
 */
- (void)rtcEngine:(RTCEngine *_Nonnull )engine remotefirstVideoRecvWithUid:(NSUInteger)uid
{
    
}

// remote
- (void)rtcEngine:(RTCEngine*)engine didOfflineOfUid:(NSUInteger)uid
{
    [_players removeObjectForKey:[NSString stringWithFormat: @"%ld", uid]];
    [self layoutVideoViews];
}


// connection lost
- (void)rtcEngineConnectionDidLost:(RTCEngine*)engine
{
    
}


- (void)rtcEngine:(RTCEngine*)engine didAudioMuted:(BOOL)muted byUid:(NSUInteger)uid
{
    
}

- (void)rtcEngine:(RTCEngine *)engine didVideoMuted:(BOOL)muted byUid:(NSUInteger)uid
{
    
}
- (void)rtcEngine:(RTCEngine * _Nonnull)engine reportAudioVolumeOfSpeaker:(NSUInteger)uid  totalVolume:(NSInteger)totalVolume
{
    
    
}

#pragma audio/video data
- (void)didCapturedVideoData:(RTCVideoData *)data
{
    
}
- (void)didCapturedAuidoData:(RTCAudioData *)data
{
    
}

@end
