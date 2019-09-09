//
//  NSObject+YUVMediaDataRender.m
//  RTCEngine-ios-app
//
//  Created by yafei zhang on 2019/3/28.
//  Copyright © 2019 RTCEngine. All rights reserved.
//

#import "YUVMediaDataRender.h"


typedef void (^imageBlock)(UIImage *image);

@interface YUVMediaDataRender()
@property (nonatomic, weak) imageBlock imageBlock;
@property (nonatomic, weak) UIImageView* imageView;

- (void)yuvToUIImageWithVideoRawData:(RTCVideoData *)data ;

@end

@implementation YUVMediaDataRender

+ (instancetype)getmediaDataRender
{
    YUVMediaDataRender *source = [[YUVMediaDataRender alloc] init];
    return source;
}

- (void)screenShotWithImage:(RTCVideoData*)data callback:(void (^)(UIImage *image))completion;
{
    self.imageBlock = completion;
    [self yuvToUIImageWithVideoRawData:data];
}

// Agora SDK Raw Data format is YUV420P
- (void)yuv420p_to_nv12:(unsigned char*)yuv420p nv12:(unsigned char*)nv12 width:(int)width  height:(int)height{
    int i, j;
    int y_size = width * height;
    
    unsigned char* y = yuv420p;
    unsigned char* u = yuv420p + y_size;
    unsigned char* v = yuv420p + y_size * 5 / 4;
    
    unsigned char* y_tmp = nv12;
    unsigned char* uv_tmp = nv12 + y_size;
    
    // y
    memcpy(y_tmp, y, y_size);
    
    // u
    for (j = 0, i = 0; j < y_size * 0.5; j += 2, i++) {
        // swtich the location of U、V，to NV12 or NV21
#if 1
        uv_tmp[j] = u[i];
        uv_tmp[j+1] = v[i];
#else
        uv_tmp[j] = v[i];
        uv_tmp[j+1] = u[i];
#endif
    }
}

- (void)UIImageToJpg:(unsigned char *)buffer width:(int)width height:(int)height {
    UIImage *image = [self YUVtoUIImage:width h:height buffer:buffer];
    if (self.imageBlock) {
        self.imageBlock( image);
    }
}

//This is API work well for NV12 data format only.
- (UIImage *)YUVtoUIImage:(int)w h:(int)h buffer:(unsigned char *)buffer{
    //YUV(NV12)-->CIImage--->UIImage Conversion
    NSDictionary *pixelAttributes = @{(NSString*)kCVPixelBufferIOSurfacePropertiesKey:@{}};
    CVPixelBufferRef pixelBuffer = NULL;
    CVReturn result = CVPixelBufferCreate(kCFAllocatorDefault,
                                          w,
                                          h,
                                          kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange,
                                          (__bridge CFDictionaryRef)(pixelAttributes),
                                          &pixelBuffer);
    CVPixelBufferLockBaseAddress(pixelBuffer,0);
    void *yDestPlane = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
    
    // Here y_ch0 is Y-Plane of YUV(NV12) data.
    unsigned char *y_ch0 = buffer;
    unsigned char *y_ch1 = buffer + w * h;
    memcpy(yDestPlane, y_ch0, w * h);
    void *uvDestPlane = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 1);
    
    // Here y_ch1 is UV-Plane of YUV(NV12) data.
    memcpy(uvDestPlane, y_ch1, w * h * 0.5);
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    
    if (result != kCVReturnSuccess) {
        NSLog(@"Unable to create cvpixelbuffer %d", result);
    }
    
    // CIImage Conversion
    CIImage *coreImage = [CIImage imageWithCVPixelBuffer:pixelBuffer];
    CIContext *temporaryContext = [CIContext contextWithOptions:nil];
    CGImageRef videoImage = [temporaryContext createCGImage:coreImage
                                                   fromRect:CGRectMake(0, 0, w, h)];
    
    // UIImage Conversion
    UIImage *finalImage = [[UIImage alloc] initWithCGImage:videoImage
                                                     scale:1.0
                                               orientation:UIImageOrientationRight];
    CVPixelBufferRelease(pixelBuffer);
    CGImageRelease(videoImage);
    return finalImage;
}


- (void)yuvToUIImageWithVideoRawData:(RTCVideoData *)data {
    
    int height = data.height;
    int yStride = data.yStride;
    
    char* yBuffer = data.yBuffer;
    char* uBuffer = data.uBuffer;
    char* vBuffer = data.vBuffer;
    
    int Len = yStride * data.height * 3/2;
    int yLength = yStride * data.height;
    int uLength = yLength / 4;
    
    unsigned char * buf = (unsigned char *)malloc(Len);
    memcpy(buf, yBuffer, yLength);
    memcpy(buf + yLength, uBuffer, uLength);
    memcpy(buf + yLength + uLength, vBuffer, uLength);
    
    unsigned char * NV12buf = (unsigned char *)malloc(Len);
    [self yuv420p_to_nv12:buf nv12:NV12buf width:yStride height:height];
    @autoreleasepool {
        [self UIImageToJpg:NV12buf width:yStride height:height];
    }
    if(buf != NULL) {
        free(buf);
        buf = NULL;
    }
    
    if(NV12buf != NULL) {
        free(NV12buf);
        NV12buf = NULL;
    }
    
}

@end
