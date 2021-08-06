# FUTRTCDemo 快速接入文档

FUTRTCDemo 是集成了 [Faceunity](https://github.com/Faceunity/FULiveDemo/tree/dev) 面部跟踪、虚拟道具功能 和 腾讯实时音视频 SDK的 Demo。

**本文是 FaceUnity SDK  快速对接 腾讯实时音视频 的导读说明**

**关于  FaceUnity SDK 的更多详细说明，请参看 [FULiveDemo](https://github.com/Faceunity/FULiveDemo/tree/dev)**



## 快速集成方法

### 一、导入 SDK

将  FaceUnity  文件夹全部拖入工程中，NamaSDK所需依赖库为 `OpenGLES.framework`、`Accelerate.framework`、`CoreMedia.framework`、`AVFoundation.framework`、`libc++.tbd`、`CoreML.framework`

- 备注: 示例demo NamaSDK 使用 Pods 管理 会自动添加依赖,运行在iOS11以下系统时,需要手动添加`CoreML.framework`,并在**TARGETS -> Build Phases-> Link Binary With Libraries**将`CoreML.framework`手动修改为可选**Optional**

### FaceUnity 模块简介
```C
-FUManager              //nama 业务类
-FUCamera               //视频采集类(示例程序未用到)    
-authpack.h             //权限文件
+FUAPIDemoBar     //美颜工具条,可自定义
+items       //贴纸和美妆资源 xx.bundel文件
      
```


### 二、加入展示 FaceUnity SDK 美颜贴纸效果的  UI

1、在  TRTRCRoomViewController.m  中添加头文件，并创建页面属性

```objc
/**faceU */
#import "UIViewController+FaceUnityUIExtension.h"
#import <FURenderKit/FUGLContext.h>

// 使用纹理渲染时,记录当前glcontext
@property(nonatomic, strong) EAGLContext *mContext;
```
2、在 `viewDidLoad` 中初始化 FaceUnity的界面和 SDK，FaceUnity界面工具和SDK都放在UIViewController+FaceUnityUIExtension中初始化了，也可以自行调用FUAPIDemoBar和FUManager初始化

```objc
[self setupFaceUnity];
```

### 三、部分代码介绍

#### 底部栏切换功能：使用不同的ViewModel控制

```C
-(void)bottomDidChangeViewModel:(FUBaseViewModel *)viewModel {
    if (viewModel.type == FUDataTypeBeauty || viewModel.type == FUDataTypebody) {
        self.renderSwitch.hidden = NO;
    } else {
        self.renderSwitch.hidden = YES;
    }

    [[FUManager shareManager].viewModelManager addToRenderLoop:viewModel];
    
    // 设置人脸数
    [[FUManager shareManager].viewModelManager resetMaxFacesNumber:viewModel.type];
}

```

#### 更新美颜参数

```C
- (IBAction)filterSliderValueChange:(FUSlider *)sender {
    _seletedParam.mValue = @(sender.value * _seletedParam.ratio);
    /**
     * 这里使用抽象接口，有具体子类决定去哪个业务员模块处理数据
     */
    [self.selectedView.viewModel consumerWithData:_seletedParam viewModelBlock:nil];
}
```



### 四、在 `enterRoom ` 方法中,进入房间之前设置本地视频的自定义渲染回调

```C
NSDictionary *dict = @{
                            @"api" : @"setCustomRenderMode",
                            @"params" : @{@"mode" : @(1)}
                        };

[self.trtc callExperimentalAPI:[NSString convertToJsonData:dict]];
[self.trtc setLocalVideoRenderDelegate:self pixelFormat:(TRTCVideoPixelFormat_NV12) bufferType:(TRTCVideoBufferType_PixelBuffer)];

```

### 五、在本地视频的自定义渲染回调中，FaceUnity处理视频数据（FURenderInput输入和FURenderOutput输出）

```C
- (uint32_t)onProcessVideoFrame:(TRTCVideoFrame *)srcFrame dstFrame:(TRTCVideoFrame *)dstFrame{
    _mContext = [EAGLContext currentContext];
    if ([FUGLContext shareGLContext].currentGLContext != _mContext) {
        [[FUGLContext shareGLContext] setCustomGLContext: _mContext];
    }
    
    if ([FUManager shareManager].isRender) {
        FURenderInput *input = [[FURenderInput alloc] init];
        input.renderConfig.imageOrientation = FUImageOrientationUP;
        input.renderConfig.isFromFrontCamera = self.isFrontCamera;
        input.renderConfig.stickerFlipH = !self.isFrontCamera;
        FUTexture tex = {srcFrame.textureId, CGSizeMake(srcFrame.width, srcFrame.height)};
        input.texture = tex;
        //开启重力感应，内部会自动计算正确方向，设置fuSetDefaultRotationMode，无须外面设置
        input.renderConfig.gravityEnable = YES;
        input.renderConfig.textureTransform = CCROT0_FLIPVERTICAL;
        FURenderOutput *output = [[FURenderKit shareRenderKit] renderWithInput:input];
        dstFrame.textureId = output.texture.ID;
        if (output.texture.ID != 0) {
            return output.texture.ID;;
        }
    }
    return 0;
}

```

### 五、销毁道具

1 视图控制器生命周期结束时,销毁道具
```C
[[FUManager shareManager] destoryItems];
```

2 切换摄像头需要调用,切换摄像头
```C
[[FUManager shareManager] onCameraChange];
```

### 关于 FaceUnity SDK 的更多详细说明，请参看 [FULiveDemo](https://github.com/Faceunity/FULiveDemo/tree/dev)

