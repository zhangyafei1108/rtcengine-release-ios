//
//  ViewController.m
//  RTCEngine-ios-app
//
//  Created by yafei zhang on 2019/3/27.
//  Copyright © 2019 RTCEngine. All rights reserved.
//

#import "ViewController.h"
#import "CoreDataManager.h"
#import "VCVideoCapturer.h"



@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *mTextRoom;
@property (weak, nonatomic) IBOutlet UITextField *mTextUser;


//
//@property (nonatomic, strong) VCVideoCapturer *videoCapture;
//@property (nonatomic, strong) AVCaptureVideoPreviewLayer *recordLayer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _mTextUser.text = DataManager.user;
    _mTextRoom.text = DataManager.room;
    
    
   
}


@end
