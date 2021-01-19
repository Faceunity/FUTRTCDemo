//
//  TRTRCRoomViewController.m
//  TRTCSimpleDemo
//
//  Created by support on 2020/9/29.
//

#import "TRTRCRoomViewController.h"

#import <TXLiteAVSDK_TRTC/TXLiteAVSDK.h>
#import "GenerateTestUserSig.h"
#import "ColorMacro.h"
#import "NSString+Common.h"
#import <Masonry/Masonry.h>

/**faceU */
#import "FUManager.h"
#import "FUAPIDemoBar.h"

#import "FUTestRecorder.h"

@interface TRTRCRoomViewController ()<TRTCCloudDelegate,TRTCVideoRenderDelegate,TRTCVideoFrameDelegate,FUAPIDemoBarDelegate>

@property (nonatomic, retain) TRTCCloud *trtc;       //TRTC SDK 实例对象
@property (nonatomic, retain) UIView* localView;     //本地画面的view
@property(nonatomic, strong) UIView *remoteView;      // 远端画面view
@property(nonatomic, assign) BOOL isFrontCamera;      // 前后摄像头标志

/**faceU */
@property (nonatomic, strong) FUAPIDemoBar *demoBar;   // demoBar

// 使用纹理渲染时,记录当前glcontext
@property(nonatomic, strong) EAGLContext *mContext;

@end


@implementation TRTRCRoomViewController

- (void)dealloc{

    //纹理渲染时,资源的释放销毁 setLocalVideoProcessDelegete
    //在调用fusetup初始化时,shouldCreateContext:NO
//    if (_mContext) {
//
//        [EAGLContext setCurrentContext:_mContext];
//        [[FUManager shareManager] destoryItems];
//    }
//
    //buffer 渲染时 setLocalVideoRenderDelegate
    //在调用fusetup初始化时,shouldCreateContext:YES
     [[FUManager shareManager] destoryItems];
    
    [TRTCCloud destroySharedIntance];
    //NSLog(@"%s",__func__);
    
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
}

- (void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    
}


- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = UIColorFromRGB(0x333333);
    self.title = self.roomId;
    self.isFrontCamera = YES;
    
    UIButton *backBtn = [[UIButton alloc] init];
    [backBtn setImage:[UIImage imageNamed:@"back"] forState:(UIControlStateNormal)];
    [backBtn sizeToFit];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    [backBtn addTarget:self action:@selector(leaveRoom) forControlEvents:(UIControlEventTouchUpInside)];
    
    [self setupTRTC];
    [self setupUI];
    [self enterRoom];
    
    /**faceU */
    [[FUManager shareManager] loadFilter];
    [FUManager shareManager].isRender = YES;
    [FUManager shareManager].flipx = YES;
    [FUManager shareManager].trackFlipx = YES;

    // 测试时使用写入csv文件查看性能
    [[FUTestRecorder shareRecorder] setupRecord];
    
}

/// 初始化引擎
- (void)setupTRTC{

    self.trtc = [TRTCCloud sharedInstance];
    self.trtc.delegate = self;
    
    /// 调整仪表盘显示位置
    [self.trtc setDebugViewMargin:self.userId margin:UIEdgeInsetsMake(80, 0, 0, 0)];
    
}


/// 加入房间
- (void)enterRoom{
    
    /**
     * 设置参数，进入视频通话房间
     * 房间号param.roomId，当前用户id param.userId
     * param.role 指定以什么角色进入房间（anchor主播，audience观众）
     */
    TRTCParams *params = [[TRTCParams alloc] init];
    params.sdkAppId = SDKAppID;
    params.userId = self.userId;
    
    /**
     userSig是进入房间的用户签名，相当于密码（
     这里生成的是测试签名，正确做法需要业务服务器来生成，然后下发给客户端）
     */
    params.userSig = [GenerateTestUserSig genTestUserSig:self.userId];
    params.roomId = (UInt32)[self.roomId integerValue];
    params.role = TRTCRoleAnchor;
    
    /**视频编码参数
     * 该设置决定远端用户看到的画面质量
     */
    TRTCVideoEncParam *videoEncParam = [[TRTCVideoEncParam alloc] init];
    videoEncParam.videoResolution = TRTCVideoResolution_1280_720;
    videoEncParam.resMode = TRTCVideoResolutionModePortrait;
    videoEncParam.videoBitrate = 1200;
    videoEncParam.videoFps = 30;
    [self.trtc setVideoEncoderParam:videoEncParam];
    
    // 使用纹理渲染的话,可不调用 callExperimentalAPI
    NSDictionary *dict = @{
                            @"api" : @"setCustomRenderMode",
                            @"params" : @{@"mode" : @(1)}
                           };

    [self.trtc callExperimentalAPI:[NSString convertToJsonData:dict]];
    [self.trtc setLocalVideoRenderDelegate:self pixelFormat:(TRTCVideoPixelFormat_NV12) bufferType:(TRTCVideoBufferType_PixelBuffer)];
    
//    [self.trtc setLocalVideoProcessDelegete:self pixelFormat:(TRTCVideoPixelFormat_Texture_2D) bufferType:(TRTCVideoBufferType_Texture)];
    
    [self.trtc setGSensorMode:(TRTCGSensorMode_Disable)];
    [self.trtc startLocalAudio:(TRTCAudioQualityDefault)];
    [self.trtc startLocalPreview:self.isFrontCamera view:self.localView];

    [self.trtc enterRoom:params appScene:(TRTCAppSceneVideoCall)];
    
}


/// 退出房间
- (void)leaveRoom{
    
    [self.trtc stopLocalAudio];
    [self.trtc stopLocalPreview];
    [self.trtc exitRoom];
    
}


/// 初始化UI
- (void)setupUI{
    
    // 本地画面
    UIView *localView = [[UIView alloc] init];
    localView.backgroundColor = UIColorFromRGB(0x262626);
    [self.view addSubview:localView];
    [localView mas_makeConstraints:^(MASConstraintMaker *make) {
    
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    
    self.localView = localView;

    // 远端画面
    UIView *remoteView = [[UIView alloc] init];
    remoteView.backgroundColor = UIColorFromRGB(0x333333);
    [self.view addSubview:remoteView];
    
    [remoteView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        if (@available(iOS 11.0, *)) {
            make.top.mas_equalTo(self.view.mas_safeAreaLayoutGuideTop)
            .mas_offset(80);
            make.right.mas_equalTo(self.view.mas_safeAreaLayoutGuideRight)
            .mas_offset(-20);
        } else {
            
            make.top.mas_equalTo(80);
            make.right.mas_equalTo(-20);
        }
       
        make.size.mas_equalTo(CGSizeMake(90, 160));
        
    }];

    self.remoteView = remoteView;
    self.remoteView.hidden = YES;
    
    // 切换摄像头
    UIButton *switchCameraBtn = [[UIButton alloc] init];
    [switchCameraBtn setImage:[UIImage imageNamed:@"rtc_switch_camera"] forState:(UIControlStateNormal)];
    [switchCameraBtn setImage:[UIImage imageNamed:@"rtc_switch_camera"] forState:(UIControlStateSelected)];
    
    // 麦克风
    UIButton *audioBtn = [[UIButton alloc] init];
    [audioBtn setImage:[UIImage imageNamed:@"rtc_mic_on"] forState:(UIControlStateNormal)];
    [audioBtn setImage:[UIImage imageNamed:@"rtc_mic_off"] forState:(UIControlStateSelected)];
    
    // 本地预览的开始与停止
    UIButton *openCloseCameraBtn = [[UIButton alloc] init];
    [openCloseCameraBtn setImage:[UIImage imageNamed:@"rtc_camera_on"] forState:(UIControlStateNormal)];
    [openCloseCameraBtn setImage:[UIImage imageNamed:@"rtc_camera_off"] forState:(UIControlStateSelected)];

    UIButton *debugBtn = [[UIButton alloc] init];
    [debugBtn setImage:[UIImage imageNamed:@"button_bg"] forState:(UIControlStateNormal)];
    [debugBtn setImage:[UIImage imageNamed:@"button_bg"] forState:(UIControlStateSelected)];
    
    [self.view addSubview:switchCameraBtn];
    [self.view addSubview:audioBtn];
    [self.view addSubview:openCloseCameraBtn];
    [self.view addSubview:debugBtn];
    
    [switchCameraBtn mas_makeConstraints:^(MASConstraintMaker *make) {

        make.right.mas_equalTo(audioBtn.mas_left)
        .mas_offset(-30);
        if (@available(iOS 11.0, *)) {
            make.bottom.mas_equalTo(self.view.mas_safeAreaLayoutGuideBottom)
            .mas_offset(-10);
        } else {
            make.bottom.mas_equalTo(-10);
        }
        make.size.mas_equalTo(CGSizeMake(40, 40));
        
    }];
    
    [audioBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerX.mas_equalTo(self.view.mas_centerX)
        .mas_offset(-35);
        make.bottom.mas_equalTo(switchCameraBtn);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
    
    [openCloseCameraBtn mas_makeConstraints:^(MASConstraintMaker *make) {
          
        make.centerX.mas_equalTo(self.view.mas_centerX)
        .mas_offset(35);
        make.bottom.mas_equalTo(audioBtn);
        make.size.mas_equalTo(CGSizeMake(40, 40));
        
    }];
    
    [debugBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(openCloseCameraBtn.mas_right)
        .mas_offset(30);
        make.bottom.mas_equalTo(audioBtn);
        make.size.mas_equalTo(CGSizeMake(40, 40));
        make.bottom.mas_equalTo(openCloseCameraBtn);
        make.size.mas_equalTo(CGSizeMake(40, 40));
        
    }];

    /**faceU */
    FUAPIDemoBar *demoBar = [[FUAPIDemoBar alloc] init];
    demoBar.mDelegate = self;
    [self.view addSubview:demoBar];
    [demoBar mas_makeConstraints:^(MASConstraintMaker *make) {
        
        if (@available(iOS 11.0, *)) {
            make.bottom.mas_equalTo(self.view.mas_safeAreaLayoutGuideBottom)
            .mas_offset(-60);
            make.left.mas_equalTo(self.view.mas_safeAreaLayoutGuideLeft);
            make.right.mas_equalTo(self.view.mas_safeAreaLayoutGuideRight);
        } else {
            make.left.right.mas_equalTo(0);
            make.bottom.mas_equalTo(-60);
        }
        
        make.height.mas_equalTo(194);
    }];
    
    // 按钮事件
    [switchCameraBtn addTarget:self action:@selector(onSwitchCameraClicked:) forControlEvents:(UIControlEventTouchUpInside)];
    
    [audioBtn addTarget:self action:@selector(onMicCaptureClicked:) forControlEvents:(UIControlEventTouchUpInside)];
    
    [openCloseCameraBtn addTarget:self action:@selector(onVideoCaptureClicked:) forControlEvents:(UIControlEventTouchUpInside)];
    
    [debugBtn addTarget:self action:@selector(onDashboardClicked:) forControlEvents:(UIControlEventTouchUpInside)];
    
}


#pragma mark ----------底部视图按钮事件--------

/// 切换摄像头
- (void)onSwitchCameraClicked:(UIButton *)sender{
    
    self.isFrontCamera = sender.selected;
    sender.selected = !sender.selected;
    [[self.trtc getDeviceManager] switchCamera:self.isFrontCamera];
    [[FUManager shareManager] onCameraChange];
    
}

/// 麦克风
- (void)onMicCaptureClicked:(UIButton *)sender{

    sender.selected = !sender.selected;
    
    [self.trtc muteLocalAudio:sender.selected];
    
}

/// 摄像头采集
- (void)onVideoCaptureClicked:(UIButton *)sender{

    if (sender.selected) {
    
        [self.trtc startLocalPreview:self.isFrontCamera view:self.localView]; //开启摄像头采集
        
    }else{
        
        [self.trtc stopLocalPreview]; //关闭摄像头采集
    }
    
    sender.selected = !sender.selected;
    
}

/// 显示调试信息
- (void)onDashboardClicked:(UIButton *)sender{

    sender.tag += 1;
    
    if (sender.tag > 2) {
        
        sender.tag = 0;
    }
    
    [self.trtc showDebugView:sender.tag];
    
}

#pragma mark -----------TRTCCloudDelegate---------

/// 远端用户是否存在可播放的主路画面（一般用于摄像头）
- (void)onUserVideoAvailable:(NSString *)userId available:(BOOL)available{

    if ([userId isEqualToString:self.userId]){return;}

    if (available) {

        [self.trtc startRemoteView:userId streamType:(TRTCVideoStreamTypeBig) view:self.remoteView];
        self.remoteView.hidden = NO;
        
    }else{
    
        [self.trtc stopRemoteView:userId streamType:(TRTCVideoStreamTypeBig)];
        self.remoteView.hidden = YES;
    }
    
}



/// 错误回调，表示 SDK 不可恢复的错误，一定要监听并分情况给用户适当的界面提示。
- (void)onError:(TXLiteAVError)errCode errMsg:(NSString *)errMsg extInfo:(NSDictionary *)extInfo{
    
    NSLog(@"errCode = %d,errMsg = %@",errCode,errMsg);
    [self leaveRoom];
    
}

- (void)onExitRoom:(NSInteger)reason{

    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark ---------FUAPIDemoBarDelegate------

-(void)filterValueChange:(FUBeautyParam *)param{

    [[FUManager shareManager] filterValueChange:param];
}

-(void)switchRenderState:(BOOL)state{

    [FUManager shareManager].isRender = state;
    
}

-(void)bottomDidChange:(int)index{
   
    if (index < 3) {
        [[FUManager shareManager] setRenderType:FUDataTypeBeautify];
    }
    if (index == 3) {
        [[FUManager shareManager] setRenderType:FUDataTypeStrick];
    }
    
    if (index == 4) {
        [[FUManager shareManager] setRenderType:FUDataTypeMakeup];
    }
    if (index == 5) {
        [[FUManager shareManager] setRenderType:FUDataTypebody];
    }
}


//#pragma mark - TRTCVideoRenderDelegate
//
- (void)onRenderVideoFrame:(TRTCVideoFrame *)frame userId:(NSString *)userId streamType:(TRTCVideoStreamType)streamType{

    [[FUTestRecorder shareRecorder] processFrameWithLog];
    CVPixelBufferRef pixelBuffer = frame.pixelBuffer;
    [[FUManager shareManager] renderItemsToPixelBuffer:pixelBuffer];

}


#pragma mark ------ TRTCVideoFrameDelegate

- (uint32_t)onProcessVideoFrame:(TRTCVideoFrame *)srcFrame dstFrame:(TRTCVideoFrame *)dstFrame{
    _mContext = [EAGLContext currentContext];
    
    [[FUTestRecorder shareRecorder] processFrameWithLog];
    dstFrame.textureId = [[FUManager shareManager] renderItemWithTexture:srcFrame.textureId Width:srcFrame.width Height:srcFrame.height];
    return 0;
}


@end
