//
//  StringRoomIdViewController.m
//  TRTC-API-Example-OC
//
//  Created by adams on 2021/4/26.
//  Copyright © 2021 Tencent. All rights reserved.
//

/*
 字符串房间号功能示例
 TRTC APP 支持字符串房间号功能
 本文件展示如何集成字符串房间号功能
 1、设置字符串房间号。API: params.strRoomId = self.roomIDTextField.text;
 2、进入TRTC房间。 API:[self.trtcCloud enterRoom:params appScene:TRTCAppSceneLIVE];
 参考文档：https://cloud.tencent.com/document/product/647/32258
 */
/*
 String-type Room ID
 The TRTC app supports string-type room IDs.
 This document shows how to enable string-type room IDs in your project.
 1. Set a string-type room ID: params.strRoomId = self.roomIDTextField.text
 2. Enter a room: [self.trtcCloud enterRoom:params appScene:TRTCAppSceneLIVE]
 Documentation: https://cloud.tencent.com/document/product/647/32258
 */

#import "StringRoomIdViewController.h"
#import "UIViewController+KeyBoard.h"

@interface StringRoomIdViewController () <TRTCCloudDelegate>
@property (weak, nonatomic) IBOutlet UILabel *roomIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *userIdLabel;

@property (weak, nonatomic) IBOutlet UIButton *startPushButton;

@property (weak, nonatomic) IBOutlet UITextField *roomIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *userIDTextField;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;

@property (strong, nonatomic) TRTCCloud *trtcCloud;

@end

@implementation StringRoomIdViewController

- (TRTCCloud *)trtcCloud {
    if (!_trtcCloud) {
        _trtcCloud = [TRTCCloud sharedInstance];
    }
    return _trtcCloud;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.trtcCloud.delegate = self;
    [self setupDefaultUIConfig];
    [self addKeyboardObserver];
}

- (void)setupDefaultUIConfig {
    
    self.roomIDTextField.text = @"abc123";
    self.userIDTextField.text = [NSString generateRandomUserId];
    self.title = localizeReplace(localize(@"TRTC-API-Example.StringRoomId.Title"), self.roomIDTextField.text);
    
    self.roomIdLabel.text = localize(@"TRTC-API-Example.StringRoomId.roomId");
    self.userIdLabel.text = localize(@"TRTC-API-Example.StringRoomId.userId");
    
    [self.startPushButton setTitle:localize(@"TRTC-API-Example.StringRoomId.start") forState:UIControlStateNormal];
    [self.startPushButton setTitle:localize(localize(@"TRTC-API-Example.StringRoomId.stop")) forState:UIControlStateSelected];
    
    self.startPushButton.titleLabel.adjustsFontSizeToFitWidth = true;
  }

#pragma mark - IBActions
- (IBAction)onStartPushClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self startPushStream];
    } else {
        [self stopPushStream];
    }
}

#pragma mark - StartPushStream & StopPushStream
- (void)startPushStream {
    [self.trtcCloud startLocalPreview:true view:self.view];

    self.title = localizeReplace(localize(@"TRTC-API-Example.StringRoomId.Title"), self.roomIDTextField.text);
    TRTCParams *params = [[TRTCParams alloc] init];
    params.sdkAppId = SDKAppID;
    params.strRoomId = self.roomIDTextField.text;
    params.userId = self.userIDTextField.text;
    params.userSig = [GenerateTestUserSig genTestUserSig:self.userIDTextField.text];
    params.role = TRTCRoleAnchor;
    
    [self.trtcCloud enterRoom:params appScene:TRTCAppSceneLIVE];
    [self.trtcCloud startLocalAudio:TRTCAudioQualityMusic];
    
    TRTCVideoEncParam *videoEncParam = [[TRTCVideoEncParam alloc] init];
    videoEncParam.videoFps = 24;
    videoEncParam.resMode = TRTCVideoResolutionModePortrait;
    videoEncParam.videoResolution = TRTCVideoResolution_960_540;
    [self.trtcCloud setVideoEncoderParam:videoEncParam];
}

- (void)stopPushStream {
    [self.trtcCloud stopLocalPreview];
    [self.trtcCloud stopLocalAudio];
    [self.trtcCloud exitRoom];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self.userIDTextField resignFirstResponder];
    [self.roomIDTextField resignFirstResponder];
}

- (void)dealloc {
    [self removeKeyboardObserver];
    [self.trtcCloud stopLocalPreview];
    [self.trtcCloud stopLocalAudio];
    [self.trtcCloud exitRoom];
    [TRTCCloud destroySharedIntance];
}


@end
