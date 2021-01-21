# FUTRTCDemo 快速接入文档

FUTRTCDemo 是集成了 [Faceunity](https://github.com/Faceunity/FULiveDemo/tree/dev) 面部跟踪、虚拟道具功能 和 腾讯实时音视频 SDK的 Demo。

**本文是 FaceUnity SDK  快速对接 腾讯实时音视频 的导读说明**

**关于  FaceUnity SDK 的更多详细说明，请参看 [FULiveDemo](https://github.com/Faceunity/FULiveDemo/tree/dev)**

## 快速集成方法

### 一、导入 SDK

将  FaceUnity  文件夹全部拖入工程中，NamaSDK所需依赖库为 `OpenGLES.framework`、`Accelerate.framework`、`CoreMedia.framework`、`AVFoundation.framework`、`libc++.tbd`

- 备注: 示例demo NamaSDK 使用 Pods 管理 会自动添加依赖

### FaceUnity 模块简介

```objc
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
#import "FUManager.h"
#import "FUAPIDemoBar.h"

@property (nonatomic, strong) FUAPIDemoBar *demoBar;

// 使用纹理渲染时,记录当前glcontext
@property(nonatomic, strong) EAGLContext *mContext;
```
2、在 `viewDidLoad` 中初始化 FaceUnity SDK

```objc
/**faceU */
[[FUManager shareManager] loadFilter];
[FUManager shareManager].isRender = YES;
[FUManager shareManager].flipx = YES;
[FUManager shareManager].trackFlipx = YES;
```

3、初始化美颜工具条UI，并遵循代理  FUAPIDemoBarDelegate ，实现代理方法 `bottomDidChange:` 切换美颜 和 `filterValueChange` 更新美颜参数。
可查看 `setupUI` demoBar布局

```objc
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
```

#### 切换贴纸

```C
// 切换贴纸
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

#### 更新美颜参数

```C
// 更新美颜参数    
- (void)filterValueChange:(FUBeautyParam *)param{
    [[FUManager shareManager] filterValueChange:param];
}
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

### 四、在本地视频的自定义渲染回调中,FaceUnity处理视频数据

```C
- (void)onRenderVideoFrame:(TRTCVideoFrame *)frame userId:(NSString *)userId streamType:(TRTCVideoStreamType)streamType{
    
    [[FUManager shareManager] renderItemsToPixelBuffer:frame.pixelBuffer];
    
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

