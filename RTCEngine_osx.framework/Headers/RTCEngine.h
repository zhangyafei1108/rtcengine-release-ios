//
//  RTCEngine.h
//  RTCEngine
//
//  Created by xiang on 2019/3/25.
//  Copyright © 2019 RTCEngine. All rights reserved.
//

#import <CoreMedia/CoreMedia.h>
#import "RTCMediaDelegate.h"

#if TARGET_OS_IPHONE || TARGET_OS_SIMULATOR
#import <UIKit/UIKit.h>
typedef UIView XESView;
#elif TARGET_OS_MAC
#import <AppKit/NSView.h>
typedef NSView XESView;
#endif

//! Project version number for RTCEngine.
FOUNDATION_EXPORT double RTCEngineVersionNumber;

//! Project version string for RTCEngine.
FOUNDATION_EXPORT const unsigned char RTCEngineVersionString[];


typedef NS_ENUM(NSInteger, RTCEngineErrorCode) {
    
    RTCEngineErrorCodeInvalidToken = 1,
    RTCEngineErrorCodeTokenExpired = 2,
    RTCEngineErrorCodesAudioError = 4,
    RTCEngineErrorCodePublishFailed = 5,
    RTCEngineErrorCodeStartCamera = 6,
    RTCEngineErrorCodeStartVideoRender = 7,
};



@protocol  RTCEngineDelegate;


typedef NS_ENUM(NSInteger, RTCEngineState) {
    RTCEngineStateNew,
    RTCEngineStateConnected,
    RTCEngineStateDisConnected,
    RTCEngineStateFailed,
};


typedef NS_ENUM(NSInteger, RTC_ENGINE_VIDEO_RESOLUTION) {
    RTC_VIDEO_RESOLUTION_120P = 0,
    RTC_VIDEO_RESOLUTION_180P = 1,
    RTC_VIDEO_RESOLUTION_240P = 2,
    RTC_VIDEO_RESOLUTION_360P = 3,
    RTC_VIDEO_RESOLUTION_480P = 4,
    RTC_VIDEO_RESOLUTION_640P = 5,
};



typedef NS_ENUM(NSInteger, RTC_ENGINE_VIDEO_BITRATE) {
    RTC_VIDEO_BITRATE_100 = 100, // MAX 100
    RTC_VIDEO_BITRATE_200 = 200, // MAX 200
    RTC_VIDEO_BITRATE_350 = 350, // MAX 350
    RTC_VIDEO_BITRATE_400 = 400, // MAX 400
    RTC_VIDEO_BITRATE_600 = 600, // MAX 600
    RTC_VIDEO_BITRATE_1000 = 1000,// MAX 1000
};


typedef NS_ENUM(NSUInteger, RTCVideoRenderMode) {
    
    RTCVideoRenderModeHidden = 1,
    RTCVideoRenderModeFit = 2,
};


@interface RTCEngine : NSObject


@property (nonatomic,weak) id<RTCEngineDelegate> delegate;

@property (nonatomic,weak) id<RTCMediaVideoProcessDelegate> videoProcessDelegate;

@property (nonatomic,weak) id<RTCMediaAudioProcessDelegate> audioProcessDelegate;



/**
 Call this method to initialize the service before using RTCEngine.
 @param token : User get encrypted token which contained roomId,appId,rtcType,...ltd  from signaling-server an a param token
 @param delegate option events triggered by RTCEngine
 @return return
 */
- (instancetype) initWithToken:(NSString*) token delegate:(id<RTCEngineDelegate>) delegate;

/**
 Called  when release core RTCEngine resource
 */
- (void) destroy;

/**
 Join the Room Specified by parameter in token which used in function initWithToken
 @return   <0  error;   0 normal  but real joinRoom  success status can  be get in Event "didJoinWithUid"
 */
- (int) joinRoom;

/**
 After joining a channel, the user must call the leaveChannel method to end the call before joining again
 This method call is asynchronous. Once the user leaves the channel, the SDK triggers the function:didOfflineOfUid
 */
- (void) leaveRoom;

/**
 Control local video (audio) send or not
 @param enable :send ; YES stop send;
 */
- (void) enableLocalVideo:(BOOL) enable;
- (void) enableLocalAudio:(BOOL) enable;

/**
 mute local audio or video
 @param enable YES or NOT
 */
- (void) muteLocalVideo:(BOOL) enable;
- (void) muteLocalAudio:(BOOL) enable;

/** If you called [enableRemoteVideo](enableRemoteAuido: enableAllRemoteVideo) and set to `YES`(NO) to stop(open) receiving  remote video streams (video stream).
 @param uid remote id NSUInteger
 @param enable YES or NO
 */
- (void) muteRemoteVideo:(NSUInteger)uid enable:(BOOL)enable;
- (void) muteRemoteAuido:(NSUInteger)uid enable:(BOOL)enable;
- (void) muteAllRemoteVideo:(BOOL)enable;
- (void) muteAllRemoteAuido:(BOOL)enable;

/** set XESView  to show local video
 @param view  set by caller
 */
- (void) setupLocalVideo:(XESView*)view;

/**Sets the local video display mode.
 This method may be invoked multiple times during a call to change the display mode.
 @param mode Sets the local video display mode. See RTCVideoRenderMode.
 */
- (void) setLocalRenderMode:(RTCVideoRenderMode)mode;


/** set XESView  to show remote video
 @uid remote id NSUInteger
 @param view  set by caller
 */
- (void) setupRemoteVideo:(NSUInteger)uid view:(XESView*)view;



/**Sets the remote video display mode.
 This method may be invoked multiple times during a call to change the display mode.
 @uid remote id NSUInteger
 @param mode Sets the local video display mode. See RTCVideoRenderMode.
 */
- (void) setRemoteRenderMode:(NSUInteger)uid mode:(RTCVideoRenderMode)mode;

/** Begin to show local view
 */
- (void) startPreview;

/**Stop local view
 */
- (void) stopPreview;

/**Sets the local video display bitrate.
 @param videoBitrate Sets video parameter. See RTC_ENGINE_VIDEO_BITRATE.
 */
- (void) setVideoBitrate:(RTC_ENGINE_VIDEO_BITRATE)videoBitrate;

/**Sets the local video param .
 @param videoResolution Sets the local video parameter . See RTC_ENGINE_VIDEO_RESOLUTION.
 */
- (void) setVideoResolution:(RTC_ENGINE_VIDEO_RESOLUTION)videoResolution;

/** change the camera only for ios ,macos is invalid
 */
- (void)switchCamera;

/** Sets the local video mirror mode.
*/
- (void)setMirror:(BOOL)isMirror;

/** If you use an external video source, call this API before calling "setupLocalVideo" or "startPreview".
    together with ”pushExternalVideoFrame“
 @param enable switch to use external video source data, enable:TRUE mean open ;FALSE mean closed
    default is closed;
 */
- (void)enableExternalVideo:(BOOL)enable;
- (void)pushExternalVideoFrame:(CMSampleBufferRef)sampleBuffer;


/** If you use an external audio source,"enableExternalAudio" switch to open or close.
 together with ”pushExternalAudioFrameRawData“ or pushExternalAudioFrameSampleBuffer
 @param enable switch to use external audio or not  enable:TRUE mean open ;FALSE mean closed
 @param sampleRate  audio parameter to init
 @param channelsPerFrame audio parameter  to init;
 */
- (void)enableExternalAudio:(BOOL)enable SampleRate:(NSUInteger)sampleRate channelsPerFrame:(NSUInteger)channelsPerFrame;
- (void)pushExternalAudioFrameRawData:(void *_Nonnull)data samples:(NSUInteger)samples timestamp:(NSTimeInterval)timestamp;
- (void)pushExternalAudioFrameSampleBuffer:(CMSampleBufferRef _Nonnull)sampleBuffer;

@end




@protocol RTCEngineDelegate <NSObject>

/** notice the Error
 @param code see RTCEngineErrorCode
 */
- (void)rtcEngine:(RTCEngine*_Nonnull)engine didOccurError:(RTCEngineErrorCode)code;

/** local user  joined the room notice
 @param uid remote id NSUInteger
 */
- (void)rtcEngine:(RTCEngine*_Nonnull)engine localUserJoindWithUid:(NSUInteger)uid;

/** remote user joined the room with video or audio
 【notice】:The same user may calls back twice ,one for video and one for audio.
 @param uid remote id NSUInteger
 */
- (void)rtcEngine:(RTCEngine*_Nonnull)engine remoteUserJoinWitnUid:(NSUInteger)uid;
/** notice Audio data received
 @param uid remote id NSUInteger
 */
- (void)rtcEngine:(RTCEngine *_Nonnull )engine remotefirstAudioRecvWithUid:(NSUInteger)uid;
/** notice Video data received
 @param uid remote id NSUInteger
 */
- (void)rtcEngine:(RTCEngine *_Nonnull )engine remotefirstVideoRecvWithUid:(NSUInteger)uid;

/** remote or local user leave the room
 @param uid remote id NSUInteger
 */
- (void)rtcEngine:(RTCEngine*_Nonnull)engine didOfflineOfUid:(NSUInteger)uid;

/**Occurs when the SDK cannot reconnect to Agora's edge server 10 seconds after its connection to the server is interrupted.
 */
- (void)rtcEngineConnectionDidLost:(RTCEngine*_Nonnull)engine;

/** Occurs when a remote user's video(audio) stream is muted/unmuted.
 @param muted  Whether the remote user's audio stream is muted/unmuted:
 * YES: Muted.
 * NO: Unmuted.
 @param uid  ID of the remote user.
 */
- (void)rtcEngine:(RTCEngine*_Nonnull)engine didAudioMuted:(BOOL)muted byUid:(NSUInteger)uid;
- (void)rtcEngine:(RTCEngine *_Nonnull)engine didVideoMuted:(BOOL)muted byUid:(NSUInteger)uid;

/** Reports which users are speaking and the speakers' volume
    Event calls 500ms once a time
    if want change time or cancel  the event  callback  connect author please!!
 @param uid   remote uid is real uid but local uid is 0
 @param volume  value ranges between 0 (lowest volume) and 255 (highest volume).
 */
- (void)rtcEngine:(RTCEngine * _Nonnull)engine reportAudioVolumeOfSpeaker:(NSUInteger)uid  volume:(NSInteger)volume;


- (void)rtcEngine:(RTCEngine * _Nonnull)engine test_didCapturedAuidoData:(RTCVideoData *)data;

@end







