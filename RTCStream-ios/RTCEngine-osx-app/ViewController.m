//
//  ViewController.m
//  RTCEngine-osx-app
//
//  Created by yafei zhang on 2019/3/29.
//  Copyright © 2019 RTCEngine. All rights reserved.
//
#import "CoreDataManager.h"
#import "ViewController.h"


@interface ViewController ()
@property (weak) IBOutlet NSTextField *mTextRoom;
@property (weak) IBOutlet NSTextField *mTextuser;

@end
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];


    self.mTextRoom.stringValue = DataManager.room;
    self.mTextuser.stringValue = DataManager.user;

}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
