# FUTRTCDemo 快速接入文档

FUTRTCDemo 是集成了 [Faceunity](https://github.com/Faceunity/FULiveDemo/tree/dev) 面部跟踪、虚拟道具功能 和 腾讯实时音视频 SDK的 Demo。

**本文是 FaceUnity SDK  快速对接 腾讯实时音视频 的导读说明**

**关于  FaceUnity SDK 的更多详细说明，请参看 [FULiveDemo](https://github.com/Faceunity/FULiveDemo/tree/dev)**



## 快速集成方法

### 一、导入 SDK

将  FaceUnity  文件夹全部拖入工程中

### 二、加入展示 FaceUnity SDK 美颜贴纸效果的  UI

1、在  TRTCMainViewController.m  中添加头文件，并创建页面属性

```C
#import <FUAPIDemoBar/FUAPIDemoBar.h>

@property (nonatomic, strong) FUAPIDemoBar *demoBar ;
```

2、初始化 UI，并遵循代理  FUAPIDemoBarDelegate ，实现代理方法 `demoBarDidSelectedItem:` 切换贴纸 和 `demoBarBeautyParamChanged` 更新美颜参数。

```C
-(FUAPIDemoBar *)demoBar {
    if (!_demoBar) {
        _demoBar = [[FUAPIDemoBar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 231 - 50, self.view.bounds.size.width, 231)];
        
        NSLog(@"---------%@",NSStringFromCGRect(_demoBar.frame));
        _demoBar.mDelegate = self;
    }
    return _demoBar ;
}

```

#### 实现UI事件回调

```C
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
```



### 三、在 `initUI ` 中初始化 SDK  并将  demoBar 添加到页面上

```C
    [[FUManager shareManager] loadItems];
    [self.view addSubview:self.demoBar];
```

### 四、实现自采集和外部滤镜

在类TRTCMainViewController.m 方法startPreview中修改

```C
    //自定义视频文件
    if (1) {
//        if (!_customVideoRenderTester)
//            _customVideoCaptureTester = [[TestSendCustomVideoData alloc] initWithTRTCCloud:_trtc mediaAsset:self.customMediaAsset];
//        [self.customVideoCaptureTester start];
        
        [_trtc enableCustomVideoCapture:YES];
        [self.mCamera startCapture];
        
        if (!_customVideoRenderTester)
            _customVideoRenderTester = [TestRenderVideoFrame new];
//        //以下代码同时测试自定义渲染
        [_trtc setLocalVideoRenderDelegate:_customVideoRenderTester pixelFormat:TRTCVideoPixelFormat_NV12 bufferType:TRTCVideoBufferType_PixelBuffer];
        [_customVideoRenderTester addUser:nil videoView:_localView];

        //也可通过startLocalPreview让SDK渲染， 此时须设置SDK的enableCustomVideoCapture要为YES， 否则为启动摄像头采集
//        [_trtc startLocalPreview:NO view:_localView];

    }
```

### 五、将自采集到的数据，经nama处理后，交由腾讯推流

```
#pragma mark - FUCameraDelegate
-(void)didOutputVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) ;
    NSTimeInterval startTime =  [[NSDate date] timeIntervalSince1970];
    [[FUManager shareManager] renderItemsToPixelBuffer:pixelBuffer];
    TRTCVideoFrame* videoFrame = [TRTCVideoFrame new];
    videoFrame.bufferType = TRTCVideoBufferType_PixelBuffer;
    videoFrame.pixelFormat = TRTCVideoPixelFormat_32BGRA;
    videoFrame.pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    TRTCVideoRotation rotation = TRTCVideoRotation_0;
    
    [_trtc sendCustomVideoData:videoFrame];
    
}
```

### 六、推流结束时需要销毁道具

销毁道具需要调用以下代码

```C
[[FUManager shareManager] destoryItems];
```



#### 关于 FaceUnity SDK 的更多详细说明，请参看 [FULiveDemo](<https://github.com/Faceunity/FULiveDemo/blob/master/docs/iOS_Nama_SDK_%E9%9B%86%E6%88%90%E6%8C%87%E5%AF%BC%E6%96%87%E6%A1%A3.md>)

