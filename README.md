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
+Lib              //FURenderKit动态库、鉴权文件和文件资源
+Demo             //集成实例demo
      
```


### 二、加入展示 FaceUnity SDK 美颜贴纸效果的  UI

1、在  TRTRCRoomViewController.m  中添加头文件，并创建页面属性

```objc
/**faceU */
#import "FUDemoManager.h"

#import <FURenderKit/FUGLContext.h>

// 使用纹理渲染时,记录当前glcontext
@property(nonatomic, strong) EAGLContext *mContext;
```
2、在 `viewDidLoad` 中初始化 FaceUnity的界面和 SDK

```objc
    [FUDemoManager setupFaceUnityDemoInController:self originY:CGRectGetHeight(self.view.frame) - FUBottomBarHeight - safeAreaBottom - 60];
```

### 三、在 `enterRoom ` 方法中,进入房间之前设置本地视频的自定义渲染回调

```C
NSDictionary *dict = @{
                            @"api" : @"setCustomRenderMode",
                            @"params" : @{@"mode" : @(1)}
                        };

[self.trtc callExperimentalAPI:[NSString convertToJsonData:dict]];
[self.trtc setLocalVideoRenderDelegate:self pixelFormat:(TRTCVideoPixelFormat_NV12) bufferType:(TRTCVideoBufferType_PixelBuffer)];

```

### 四、在本地视频的自定义渲染回调中，FaceUnity处理视频数据（FURenderInput输入和FURenderOutput输出）

```C
- (uint32_t)onProcessVideoFrame:(TRTCVideoFrame *)srcFrame dstFrame:(TRTCVideoFrame *)dstFrame{
    _mContext = [EAGLContext currentContext];
    if ([FUGLContext shareGLContext].currentGLContext != _mContext) {
        [[FUGLContext shareGLContext] setCustomGLContext: _mContext];
    }
    
    if ([FUManager shareManager].isRender) {
        [[FUTestRecorder shareRecorder] processFrameWithLog];
        [[FUManager shareManager] updateBeautyBlurEffect];
        FURenderInput *input = [[FURenderInput alloc] init];
        
        // 根据输入纹理调整参数设置
        input.renderConfig.imageOrientation = FUImageOrientationDown;
        input.renderConfig.isFromFrontCamera = self.isFrontCamera;
        input.renderConfig.isFromMirroredCamera = YES;
        // stickerFlipH和stickerFlipV尽量不要使用，后续将不再维护，这里使用是为了适配老道具
        input.renderConfig.stickerFlipH = !self.isFrontCamera;
        input.renderConfig.stickerFlipV = NO;
        
        FUTexture tex = {srcFrame.textureId, CGSizeMake(srcFrame.width, srcFrame.height)};
        input.texture = tex;
        // 开启重力感应，内部会自动计算正确方向，设置fuSetDefaultRotationMode，无须外面设置
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

