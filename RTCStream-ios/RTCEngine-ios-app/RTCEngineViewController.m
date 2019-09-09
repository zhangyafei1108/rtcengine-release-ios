//
//  RTCEngineViewController.m
//  RTCEngine-ios-app
//
//  Created by yafei zhang on 2019/3/27.
//  Copyright © 2019 RTCEngine. All rights reserved.
//

#import "RTCEngineViewController.h"
#import "CoreDataManager.h"
#import <RTCEngine/RTCEngine.h>
#import <JWT/JWT.h>
#import "YUVMediaDataRender.h"

#import <AFNetworking/AFNetworking.h>
//#import "VCVideoCapturer.h"
#import "OpenCamera.h"

#define  NativeCapture 0

@interface RTCEngineViewController ()<RTCEngineDelegate,RTCMediaAudioProcessDelegate,RTCMediaVideoProcessDelegate,OpenCameraDelegate>{
    BOOL audioMuted ;
    BOOL videoMuted ;
    BOOL cameraFront;
    BOOL imageViewShow;
    BOOL boRunning;
    
    NSString* mstrToken;
}

@property (nonatomic, strong) RTCEngine* rtcEngine;
@property (nonatomic, strong) NSMutableDictionary* players;

@property (strong, nonatomic) NSMutableArray<XESView *> *viewSessions;


@property (nonatomic,readonly) XESView* preview;
@property (nonatomic,readonly) UIImageView  *imageView;
@property(nonatomic, strong)UIImage *imagedata;

@property (nonatomic, readonly)YUVMediaDataRender* RenderHander;

@property (weak, nonatomic) IBOutlet UIButton *mbtnQuit;
@property (weak, nonatomic) IBOutlet UIButton *mbtn;
@property (weak, nonatomic) IBOutlet UIButton *mbtnVideo;
@property (weak, nonatomic) IBOutlet UIButton *mbtnAudio;
@property (weak, nonatomic) IBOutlet UIButton *mbtnCamera;
@property (strong, nonatomic) IBOutlet UIView *mbtnShowMedia;


//@property (nonatomic, strong) VCVideoCapturer *videoCapture;
//@property (nonatomic, strong) VCVideoCapturer *videoCapture;
@property  (nonatomic, strong) OpenCamera *openCamera;

@property (nonatomic, strong) AVCaptureVideoPreviewLayer *recordLayer;

@end

@implementation RTCEngineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    audioMuted = FALSE;
    videoMuted = FALSE;
    cameraFront = FALSE;
    imageViewShow = FALSE;
    _RenderHander = nil;
    boRunning = FALSE;
    self.imagedata = nil;

    
    _players = [NSMutableDictionary dictionary];
    self.viewSessions = [[NSMutableArray alloc] init];

    
    // 创建管理者对象
    AFHTTPSessionManager *sessionManager = [AFHTTPSessionManager manager];
    // 设置请求参数
    //NSString *urlStr = @"http://47.107.97.230/api/token";
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
            [self meetIn];
        }

        //NSMutableDictionary *token = [NSMutableDictionary dictionary];
        //NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];

        //
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"请求失败");
    }];
    
    self.view.backgroundColor = [UIColor grayColor];
    
    // 初始化视频采集
    //VCVideoCapturerParam *param = [[VCVideoCapturerParam alloc] init];
    //param.sessionPreset = AVCaptureSessionPreset1280x720;
    
   
    // Do any additional setup after loading the view, typically from a nib.
    
    if(NativeCapture){
        
        _preview = [[XESView alloc] initWithFrame:CGRectMake(0, 0, 120, 160)];
        _preview.frame = CGRectMake(0, 0, self.view.bounds.size.width/2, self.view.bounds.size.height/2);
        [self.view addSubview:_preview];
        
        [_players setObject:_preview forKey:DataManager.user];
        self.openCamera = [[OpenCamera alloc] init];
        [self.openCamera initWithView:_preview];
        self.openCamera.delegate = self;
        
        

        //-    self.videoCapture = [[VCVideoCapturer alloc] initWithCaptureParam:param error:nil];
     //-   self.videoCapture.delegate = self;
//
//        CGFloat layerMargin = 15;
//        CGFloat layerW = (self.view.frame.size.width - 3 * layerMargin) * 0.5;
//        CGFloat layerH = layerW * 16 / 9.00;
//        CGFloat layerY = 120;
        // 初始化视频采集的预览画面
        //-self.recordLayer = self.videoCapture.videoPreviewLayer;
        //self.recordLayer.frame = CGRectMake(layerMargin, layerY, layerW, layerH);
        //-[_players setObject:self.recordLayer forKey:DataManager.user];
        //[self.videoCapture startCapture];
        //-[self.view.layer addSublayer:self.recordLayer];
    }
    

}
-(NSString *)getTime{
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a=[date timeIntervalSince1970]*1000; // *1000 是精确到毫秒，不乘就是精确到秒
    NSString *timeString = [NSString stringWithFormat:@"%.0f", a]; //转为字符型
    return timeString;
}
- (void)cameraButtonAction:(UIButton *)button
{
    button.selected = !button.selected;
    if (button.selected)
    {
        //[self.videoCapture startCapture];
        //[self.view.layer addSublayer:self.recordLayer];
    }
    else
    {
       // [self.videoCapture stopCapture];
       // [self.videoCapture.videoPreviewLayer removeFromSuperlayer];
    }
}

- (void)revertCameraButtonAction:(UIButton *)button
{
   //- [self.videoCapture reverseCamera];
}


- (void)meetIn
{
    // Do any additional setup after loading the view.
//    NSString* test_token = [JWT encodePayload:@{
//                                                @"room":DataManager.room,
//                                                @"user":DataManager.user,
//                                                @"token":mstrToken,
//                                                @"appid":@"407efd6acdeb4683b52e0bd9bb92a188",
//                                                @"type":@"1",
//                                                } withSecret:@"thisissecret"];
    _rtcEngine = [[RTCEngine alloc] initWithToken:mstrToken delegate:self];
    
    
    
    //-[_rtcEngine setChannelProfile:RTCChannelProfileCommunication];
    
    [_rtcEngine setVideoBitrate:400];

    if(NativeCapture){
        [_rtcEngine enableExternalVideo:YES];
        //[_rtcEngine enableLocalAudio:NO];
        //[_rtcEngine enableLocalVideo:NO];
        
        //-[_rtcEngine setupLocalVideo:_preview];
        //-[_rtcEngine startPreview];

    }else{
        _preview = [[XESView alloc] initWithFrame:CGRectMake(0, 0, 120, 160)];
        _preview.frame = CGRectMake(0, 0, self.view.bounds.size.width/2, self.view.bounds.size.height/2);
        [self.view addSubview:_preview];
        
        [_players setObject:_preview forKey:DataManager.user];
        
        [_rtcEngine setupLocalVideo:_preview];
        
        [_rtcEngine startPreview];
    }
    //[self.viewSessions addObject:_preview];

    
    int result = [_rtcEngine joinRoom];
    NSLog(@"join the result   %d",result);

    //_rtcEngine.videoProcessDelegate = self;
    //_rtcEngine.audioProcessDelegate = self;
    
    
}
- (void)meetOut
{
    boRunning = FALSE;
    [_rtcEngine stopPreview];
    [_rtcEngine leaveRoom];
    
    //view
    [_players removeAllObjects];
    [_rtcEngine destroy];
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

- (void)layoutVideoViews
{
    
    //NSMutableArray *videoViews = [NSMutableArray array];
    //[videoViews addObject:_preview];
    
//    NSArray * allkeys = [_players allKeys];
//    XESView * viewTmp= nil;
//
//    for (int i = 0; i < allkeys.count; i++)
//    {
//        NSString * key = [allkeys objectAtIndex:i];
//        viewTmp = [_players objectForKey:key];
//        if(viewTmp){
//            viewTmp.frame =[self frameAtPosition:i];
//        }
//    }
    int i =0 ;
    for(NSString *key in _players){
        XESView * viewTmp = [_players objectForKey:key];
        if(viewTmp){
            viewTmp.frame =[self frameAtPosition:i++];
        }
    }

}

-(CGRect)frameAtPosition:(int)postion
{
    CGRect bounds = self.view.bounds;
    
    CGFloat width = bounds.size.width / 2;
    CGFloat height = bounds.size.height / 2;
    
    CGFloat x = ((postion)%2) * width;
    CGFloat y = ((postion)/2) * height;
    
    CGRect frame = CGRectMake(x, y, width, height);
    
    return frame;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)onVideoPause:(id)sender {
    if (_rtcEngine) {
        [_rtcEngine muteLocalVideo:!videoMuted];
        videoMuted = !videoMuted;
    }
    [self.mbtnVideo setImage:[UIImage imageNamed:(videoMuted ? @"btn_join" : @"btn_join_cancel")] forState:UIControlStateNormal];
}

- (IBAction)onAudioMute:(id)sender {
    if (_rtcEngine) {
        [_rtcEngine muteLocalAudio:!audioMuted];
        audioMuted = !audioMuted;
    }
    [self.mbtnAudio setImage:[UIImage imageNamed:( audioMuted? @"btn_mute" : @"btn_mute_cancel")] forState:UIControlStateNormal];
}
- (IBAction)onCameraChange:(id)sender {
    if(_rtcEngine){
        cameraFront = !cameraFront;
        [_rtcEngine switchCamera];
    }
    [self.mbtnCamera setImage:[UIImage imageNamed:(cameraFront ? @"btn_overturn" : @"camera_trun")] forState:UIControlStateNormal];
}
- (IBAction)onStop:(id)sender {
    
    [self.mbtnQuit setImage:[UIImage imageNamed:(cameraFront ? @"btn_join" : @"btn_join_cancel")] forState:UIControlStateNormal];
    
    [self meetOut];
}
- (IBAction)onShownMedia:(id)sender {
    
    if(imageViewShow ){
        //delete from players
        for(NSString *key in _players){
            XESView * viewTmp = [_players objectForKey:key];
            if([key compare:@"1"]){
                [viewTmp removeFromSuperview];
            }
        }
    }else{
        _imageView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 120, 160)];
        [self.view addSubview:_imageView];
        [_players setObject:_imageView forKey:[NSString stringWithFormat: @"1"]];
    

        if(boRunning && _rtcEngine){
            if(_RenderHander == nil){
                _RenderHander = [YUVMediaDataRender getmediaDataRender];
            }
        }
    }
    imageViewShow= !imageViewShow;
    [self layoutVideoViews];
}


- (void)updateMyImage
{
         self.imageView.image = self.imagedata;
    return;
}

#pragma call back RTCIN

- (void)rtcEngine:(RTCEngine*)engine didOccurError:(NSInteger)code
{
   
    
}


// local
- (void)rtcEngine:(RTCEngine*_Nonnull)engine localUserJoindWithUid:(NSUInteger)uid
{
    boRunning = TRUE;
}


// remote,  when got the first audio frame

- (void)rtcEngine:(RTCEngine*_Nonnull)engine remoteUserJoinWitnUid:(NSUInteger)uid;
{
    boRunning = TRUE;

    NSLog(@"join the meeting sucessful  %d",uid);
    
    XESView *xerView  =  [self videoSessionOfUid:uid];
    
    [_rtcEngine setRemoteRenderMode:uid mode:RTCVideoRenderModeHidden];
    
    [_rtcEngine setupRemoteVideo:uid view:xerView];
    
    
    [self.view bringSubviewToFront:self.mbtnQuit];
    [self.view bringSubviewToFront:self.mbtnCamera];
    [self.view bringSubviewToFront:self.mbtnAudio];
    [self.view bringSubviewToFront:self.mbtnVideo];

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
    XESView *xerView = [self fetchSessionOfUid:uid];
    [xerView removeFromSuperview];
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
- (void)rtcEngine:(RTCEngine * )engine reportAudioVolumeOfSpeaker:(NSUInteger)uid  volume:(NSInteger)totalVolume
{
    NSLog(@"reportAudioVolumeOfSpeaker  %lu, %lu",uid,totalVolume);
}

- (void)test_didCapturedVideoData:(RTCVideoData *)data
{
    
}


#pragma audio/video data
- (void)didCapturedVideoData:(RTCVideoData *)data
{
    return;
    if(_RenderHander){
        [_RenderHander screenShotWithImage:data callback:^(UIImage *  image) {
            self.imagedata = image;
            //self.imageView.image = nil;
        [self performSelectorOnMainThread:@selector(updateMyImage) withObject:nil  waitUntilDone:NO];

        }];
    }
}
- (void)didCapturedAuidoData:(RTCAudioData *)data
{
    if(_RenderHander){
        [_RenderHander screenShotWithImage:data callback:^(UIImage *  image) {
            self.imagedata = image;
            //self.imageView.image = nil;
            [self performSelectorOnMainThread:@selector(updateMyImage) withObject:nil  waitUntilDone:NO];
            
        }];
    }
}



#pragma mark - 视频采集回调
- (void)videoCaptureOutputDataCallback:(CMSampleBufferRef)sampleBuffer
{
    //-[self.videoEncoder videoEncodeInputData:sampleBuffer forceKeyFrame:NO];
    if(_rtcEngine){
        [_rtcEngine pushExternalVideoFrame:sampleBuffer];
    }
}

- (void)didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    if(_rtcEngine){
        [_rtcEngine pushExternalVideoFrame:sampleBuffer];
    }
}

- (void)didOutputAudioSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    
}
@end
