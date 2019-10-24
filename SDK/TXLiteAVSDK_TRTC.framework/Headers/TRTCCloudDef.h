/*
 * Module:   TRTC 关键类型定义
 * 
 * Function: 分辨率、质量等级等枚举和常量值的定义
 *
 */

#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE || TARGET_OS_SIMULATOR
#import <UIKit/UIKit.h>
typedef UIView TXView;
typedef UIImage TXImage;
typedef UIEdgeInsets TXEdgeInsets;
#elif TARGET_OS_MAC
#import <AppKit/AppKit.h>
typedef NSView TXView;
typedef NSImage TXImage;
typedef NSEdgeInsets TXEdgeInsets;
#endif




/////////////////////////////////////////////////////////////////////////////////
//
//                    【（一）视频相关枚举值定义】
//                   
/////////////////////////////////////////////////////////////////////////////////

/**
 * 1.1 视频分辨率
 *
 * 此处仅定义了横屏分辨率，如果要使用360 × 640这样的竖屏分辨率，需要同时指定 TRTCVideoResolutionMode 为 Portrait。
 */
typedef NS_ENUM(NSInteger, TRTCVideoResolution) {
    // 宽高比1:1
    TRTCVideoResolution_120_120     = 1,    ///< [C] 建议码率80kbps
    TRTCVideoResolution_160_160     = 3,    ///< [C] 建议码率100kbps
    TRTCVideoResolution_270_270     = 5,    ///< [C] 建议码率200kbps
    TRTCVideoResolution_480_480     = 7,    ///< [C] 建议码率350kbps
    
    // 宽高比4:3
    TRTCVideoResolution_160_120     = 50,   ///< [C] 建议码率100kbps
    TRTCVideoResolution_240_180     = 52,   ///< [C] 建议码率150kbps
    TRTCVideoResolution_280_210     = 54,   ///< [C] 建议码率200kbps
    TRTCVideoResolution_320_240     = 56,   ///< [C] 建议码率250kbps
    TRTCVideoResolution_400_300     = 58,   ///< [C] 建议码率300kbps
    TRTCVideoResolution_480_360     = 60,   ///< [C] 建议码率400kbps
    TRTCVideoResolution_640_480     = 62,   ///< [C] 建议码率600kbps
    TRTCVideoResolution_960_720     = 64,   ///< [C] 建议码率1000kbps
    
    // 宽高比16:9
    TRTCVideoResolution_160_90      = 100,  ///< [C] 建议码率100kbps
    TRTCVideoResolution_256_144     = 102,  ///< [C] 建议码率150kbps
    TRTCVideoResolution_320_180     = 104,  ///< [C] 建议码率250kbps
    TRTCVideoResolution_480_270     = 106,  ///< [C] 建议码率350kbps
    TRTCVideoResolution_640_360     = 108,  ///< [C] 建议码率550kbps
    TRTCVideoResolution_960_540     = 110,  ///< [C] 建议码率850kbps
    TRTCVideoResolution_1280_720    = 112,  ///< [C] 摄像头采集 - 建议码率1200kbps
                                            ///< [S] 屏幕分享   - 建议码率：低清：400kbps 高清：600kbps
    TRTCVideoResolution_1920_1080   = 114,  ///< [S] 屏幕分享   - 建议码率800kbps
};

/**
 * 1.2 视频宽高比模式
 *
 * - 横屏分辨率：TRTCVideoResolution_640_360 + TRTCVideoResolutionModeLandscape = 640 × 360
 * - 竖屏分辨率：TRTCVideoResolution_640_360 + TRTCVideoResolutionModePortrait  = 360 × 640
 */
typedef NS_ENUM(NSInteger, TRTCVideoResolutionMode) {
	TRTCVideoResolutionModeLandscape = 0,  ///< 横屏分辨率
    TRTCVideoResolutionModePortrait  = 1,  ///< 竖屏分辨率
};


/**
 * 1.3 视频流类型
 *
 * TRTC 内部有三种不同的音视频流，分别是：
 * - 主画面：最常用的一条线路，一般用来传输摄像头的视频数据。
 * - 小画面：跟主画面的内容相同，但是分辨率和码率更低。
 * - 辅流画面：一般用于屏幕分享，以及远程播片（比如老师放一段视频给学生）。
 *
 * @note - 如果主播的上行网络和性能比较好，则可以同时送出大小两路画面。
 * @note - SDK 不支持单独开启小画面，小画面必须依附于主画面而存在。
 */

typedef NS_ENUM(NSInteger, TRTCVideoStreamType) {
    TRTCVideoStreamTypeBig   = 0,     ///< 主画面视频流
    TRTCVideoStreamTypeSmall = 1,     ///< 小画面视频流
    TRTCVideoStreamTypeSub   = 2,     ///< 辅流（屏幕分享）

};

/**
 * 1.4 画质级别
 *
 * TRTC SDK 对画质定义了六种不同的级别，Excellent 代表最好，Down 代表不可用。
 */
typedef NS_ENUM(NSInteger, TRTCQuality) {
    TRTCQuality_Unknown     = 0,     ///< 未定义
    TRTCQuality_Excellent   = 1,     ///< 最好
    TRTCQuality_Good        = 2,     ///< 好
    TRTCQuality_Poor        = 3,     ///< 一般
    TRTCQuality_Bad         = 4,     ///< 差
    TRTCQuality_Vbad        = 5,     ///< 很差
    TRTCQuality_Down        = 6,     ///< 不可用
};

/**
 * 1.5 视频画面填充模式
 *
 * 如果画面的显示分辨率不等于画面的原始分辨率，就需要您设置画面的填充模式:
 * - TRTCVideoFillMode_Fill，图像铺满屏幕，超出显示视窗的视频部分将被截掉，所以画面显示可能不完整。
 * - TRTCVideoFillMode_Fit，图像长边填满屏幕，短边区域会被填充黑色，但画面的内容肯定是完整的。
 */
typedef NS_ENUM(NSInteger, TRTCVideoFillMode) {
    TRTCVideoFillMode_Fill   = 0,  ///< 图像铺满屏幕，超出显示视窗的视频部分将被截掉
    TRTCVideoFillMode_Fit    = 1,  ///< 图像长边填满屏幕，短边区域会被填充黑色
};

/**
 * 1.6 视频画面旋转方向
 *
 * TRTC SDK 提供了对本地和远程画面的旋转角度设置 API，如下的旋转角度都是指顺时针方向的。
 */
typedef NS_ENUM(NSInteger, TRTCVideoRotation) {
    TRTCVideoRotation_0      = 0,  ///< 不旋转
    TRTCVideoRotation_90     = 1,  ///< 顺时针旋转90度
    TRTCVideoRotation_180    = 2,  ///< 顺时针旋转180度
    TRTCVideoRotation_270    = 3,  ///< 顺时针旋转270度
};

/**
 * 1.7 美颜（磨皮）算法
 *
 * TRTC SDK 内置了多种不同的磨皮算法，您可以选择最适合您产品定位的方案。
 */
typedef NS_ENUM(NSInteger, TRTCBeautyStyle) {
    TRTCBeautyStyleSmooth    = 0,  ///< 光滑，适用于美女秀场，效果比较明显。
    TRTCBeautyStyleNature    = 1,  ///< 自然，磨皮算法更多地保留了面部细节，主观感受上会更加自然。
};

/**
 * 1.8 视频像素格式
 *
 * TRTC SDK 提供针对视频的自定义采集和自定义渲染功能，在自定义采集功能中，您可以用如下枚举值描述您采集的视频像素格式。
 * 在自定义渲染功能中，您可以指定您期望 SDK 回调的视频像素格式。
 */
typedef NS_ENUM(NSInteger, TRTCVideoPixelFormat) {
    TRTCVideoPixelFormat_Unknown    = 0,    ///< 未知
    TRTCVideoPixelFormat_I420       = 1,    ///< YUV420P I420
    TRTCVideoPixelFormat_NV12       = 5,    ///< YUV420SP NV12
    TRTCVideoPixelFormat_32BGRA     = 6,    ///< BGRA8888
};


/**
 * 1.9 视频数据包装格式
 *
 * 在自定义采集和自定义渲染功能，您需要用到如下枚举值来指定您希望以什么类型的容器来包装视频数据。
 * - PixelBuffer：直接使用效率最高，iOS 系统也提供了众多 API 获取或者处理 PixelBuffer。
 * - NSData：仅用于自定义渲染，SDK 帮您做了一次 PixelBuffer 到 NSData 的内存拷贝工作，当然，这意味着额外的性能损耗。
 */
typedef NS_ENUM(NSInteger, TRTCVideoBufferType) {
    TRTCVideoBufferType_Unknown         = 0,    ///< 未知
    TRTCVideoBufferType_PixelBuffer     = 1,    ///< 直接使用效率最高，iOS 系统也提供了众多 API 获取或者处理 PixelBuffer。
    TRTCVideoBufferType_NSData          = 2,    ///< 仅用于自定义渲染，SDK 帮您做了一次 PixelBuffer 到 NSData 的内存拷贝工作，当然，这意味着额外的性能损耗。
};

/**
 * 1.10 本地视频预览镜像类型
 *
 * iOS 的本地画面提供三种设置模式
 */
typedef NS_ENUM(NSUInteger, TRTCLocalVideoMirrorType) {
    TRTCLocalVideoMirrorType_Auto       = 0,       ///< 前置摄像头镜像，后置摄像头不镜像
    TRTCLocalVideoMirrorType_Enable     = 1,       ///< 前后置摄像头画面均镜像
    TRTCLocalVideoMirrorType_Disable    = 2,       ///< 前后置摄像头画面均不镜像
};

/////////////////////////////////////////////////////////////////////////////////
//
//                    【（二）网络相关枚举值定义】
//                   
/////////////////////////////////////////////////////////////////////////////////

/**
 * 2.1 应用场景
 *
 * TRTC 可用于视频会议和在线直播等多种应用场景，针对不同的应用场景，TRTC SDK 的内部会进行不同的优化配置：
 * - VideoCall：视频通话场景，即绝大多数时间都是两人或两人以上视频通话的场景，比如1v1的在线课程辅导，1vN (N < 8) 的视频会议或者小班课堂。
 * - LIVE：在线直播场景，即绝大多数时间都是一人直播，偶尔有多人视频互动的场景，比如美女秀场连麦等场景。
 */
typedef NS_ENUM(NSInteger, TRTCAppScene) {
	TRTCAppSceneVideoCall     = 0,  ///< 视频通话场景，内部编码器和网络协议优化侧重流畅性，降低通话延迟和卡顿率。
    TRTCAppSceneLIVE          = 1,  ///< 在线直播场景，内部编码器和网络协议优化侧重性能和兼容性，性能和清晰度表现更佳。
};

/**
 * 2.2 角色，仅适用于直播场景（TRTCAppSceneLIVE）
 *
 * 在直播场景中，多数用户只是观众，只有个别用户是主播，这种角色区分可以有利于 TRTC 进行更好的定向优化。
 *
 * - Anchor：主播，可以上行视频和音频，一个房间里的主播人数不能超过 50 人。
 * - Audience：观众，只能观看，不能上行视频和音频，一个房间里的观众人数没有上限。
 */
typedef NS_ENUM(NSInteger, TRTCRoleType) {
    TRTCRoleAnchor            =  20,   ///< 主播
    TRTCRoleAudience          =  21,   ///< 观众
};

/**
 * 2.3 流控模式
 *
 * TRTC SDK 内部需要时刻根据网络情况调整内部的编解码器和网络模块，以便能够对网络的变化做出反应。
 * 为了支持快速算法升级，SDK 内部设置了两种不同的流控模式：
 * - ModeClient： 本地控制，用于 SDK 开发内部调试，客户请勿使用。
 * - ModeServer： 云端控制，推荐模式，也是默认模式，推荐选择。
 *
 * @note 推荐您使用云端控制，这样每当我们升级 Qos 算法时，您无需升级 SDK 即可体验更好的效果。
 */
typedef NS_ENUM(NSInteger, TRTCQosControlMode)
{
    TRTCQosControlModeClient,        ///< 客户端控制（用于 SDK 开发内部调试，客户请勿使用）
    TRTCQosControlModeServer,        ///< 云端控制 （默认）
};

/**
 * 2.4 画质偏好
 *
 * 指当 TRTC SDK 在遇到弱网络环境时，您是希望“保清晰”还是“保流畅”：
 *
 * - Smooth：弱网下保流畅，在遭遇弱网环境时首先确保声音的流畅和优先发送，画面会变得模糊且会有较多马赛克，但可以保持流畅不卡顿。
 * - Clear：弱网下保清晰，在遭遇弱网环境时，画面会尽可能保持清晰，但可能会更容易出现卡顿。
 */
typedef NS_ENUM(NSInteger, TRTCVideoQosPreference)
{
    TRTCVideoQosPreferenceSmooth = 1,      ///< 弱网下保流畅
    TRTCVideoQosPreferenceClear  = 2,      ///< 弱网下保清晰
};

/////////////////////////////////////////////////////////////////////////////////
//
//                    【（三）声音相关枚举值定义】
//
/////////////////////////////////////////////////////////////////////////////////

/**
 * 3.1 音频采样率
 *
 * 音频采样率用来衡量声音的保真程度，采样率越高保真程度越好，如果您的应用场景有音乐的存在，推荐使用 TRTCAudioSampleRate48000。
 */
typedef NS_ENUM(NSInteger, TRTCAudioSampleRate) {
    TRTCAudioSampleRate16000   = 16000,      ///< 16k采样率
    TRTCAudioSampleRate32000   = 32000,      ///< 32采样率
    TRTCAudioSampleRate44100   = 44100,      ///< 44.1k采样率
    TRTCAudioSampleRate48000   = 48000,      ///< 48k采样率
};

/**
 * 3.2 声音播放模式（音频路由）
 *
 * 微信和手机 QQ 里的视频通话功能，都有一个免提模式，开启后就不用把手机贴在耳朵上，这个功能就是基于音频路由实现的。
 * 一般手机都有两个扬声器，设置音频路由的作用就是要决定声音从哪个扬声器播放出来：
 * - Speakerphone：扬声器，位于手机底部，声音偏大，适合外放音乐。
 * - Earpiece：听筒，位于手机顶部，声音偏小，适合通话。
 */
typedef NS_ENUM(NSInteger, TRTCAudioRoute) {
    TRTCAudioModeSpeakerphone  =   0,   ///< 扬声器
    TRTCAudioModeEarpiece      =   1,   ///< 听筒
};

/**
 * 3.3 声音混响模式
 *
 * 该枚举值应用于直播场景中的混响模式，主要用于秀场直播中。
 */
typedef NS_ENUM(NSInteger, TRTCReverbType) {
    TRTCReverbType_0         = 0,    ///< 关闭混响
    TRTCReverbType_1         = 1,    ///< KTV
    TRTCReverbType_2         = 2,    ///< 小房间
    TRTCReverbType_3         = 3,    ///< 大会堂
    TRTCReverbType_4         = 4,    ///< 低沉
    TRTCReverbType_5         = 5,    ///< 洪亮
    TRTCReverbType_6         = 6,    ///< 金属声
    TRTCReverbType_7         = 7,    ///< 磁性
};

/**
 * 3.4 变声模式
 *
 * 该枚举值应用于直播场景中的变声模式，主要用于秀场直播中。
 */
typedef NS_ENUM(NSInteger, TRTCVoiceChangerType) {
    TRTCVoiceChangerType_0   = 0,    ///< 关闭变声
    TRTCVoiceChangerType_1   = 1,    ///< 熊孩子
    TRTCVoiceChangerType_2   = 2,    ///< 萝莉
    TRTCVoiceChangerType_3   = 3,    ///< 大叔
    TRTCVoiceChangerType_4   = 4,    ///< 重金属
    TRTCVoiceChangerType_5   = 5,    ///< 感冒
    TRTCVoiceChangerType_6   = 6,    ///< 外国人
    TRTCVoiceChangerType_7   = 7,    ///< 困兽
    TRTCVoiceChangerType_8   = 8,    ///< 死肥仔
    TRTCVoiceChangerType_9   = 9,    ///< 强电流
    TRTCVoiceChangerType_10  = 10,   ///< 重机械
    TRTCVoiceChangerType_11  = 11,   ///< 空灵
};

/**
 * 3.5 系统音量类型
 *
 * 该枚举值用于控制通话过程中使用何种系统音量类型
 */
typedef NS_ENUM(NSInteger, TRTCSystemVolumeType) {
    TRTCSystemVolumeTypeAuto             = 0,    ///< 默认类型，SDK会自动选择合适的音量类型
    TRTCSystemVolumeTypeMedia            = 1,    ///< 仅使用媒体音量，SDK不再使用通话音量
};

#pragma mark -

/////////////////////////////////////////////////////////////////////////////////
//
//                    【（四）更多枚举值定义】
//                   
/////////////////////////////////////////////////////////////////////////////////

/**
 * 4.1 Log 级别
 *
 * 不同的日志等级定义了不同的详实程度和日志数量，推荐一般情况下将日志等级设置为：TRTCLogLevelInfo。
 */
typedef NS_ENUM(NSInteger, TRTCLogLevel) {
    TRTCLogLevelNone            = 0,      ///< 不输出任何 SDK Log
    TRTCLogLevelVerbose = 1,   ///< 输出所有级别的 Log
    TRTCLogLevelDebug = 2,     ///< 输出 DEBUG，INFO，WARNING，ERROR 和 FATAL 级别的 Log
    TRTCLogLevelInfo = 3,      ///< 输出 INFO，WARNNING，ERROR 和 FATAL 级别的 Log
    TRTCLogLevelWarn = 4,      ///< 只输出WARNNING，ERROR 和 FATAL 级别的 Log
    TRTCLogLevelError = 5,     ///< 只输出ERROR 和 FATAL 级别的 Log
    TRTCLogLevelFatal = 6,     ///< 只输出 FATAL 级别的 Log
};

/**
 * 4.2 重力感应开关
 *
 * 此配置仅适用于 iOS 和 iPad 等移动设备，并且需要配合您当前 UI 的布局模式一起使用：
 * - Disable，如果您不希望视频画面跟随重力感应方向而调整。
 * - UIAutoLayout，SDK 不会自动调整 LocalVideoView 的旋转方向，而是交给系统进行处理，这需要您的 App 界面已经针对重力感应做了适配工作。
 * - UIFixLayout，SDK 自动调整 LocalVideoView 的旋转方向，适用于您的 App 界面没有做重力感应适配的情况下。
 */
typedef NS_ENUM(NSInteger, TRTCGSensorMode) {
    TRTCGSensorMode_Disable         = 0,  ///< 关闭重力感应
    TRTCGSensorMode_UIAutoLayout    = 1,  ///< 开启重力感应，需要您的 App 界面已经针对重力感应做了适配工作。
	TRTCGSensorMode_UIFixLayout     = 2   ///< 开启重力感应，适用于您的 App 界面没有做重力感应适配的情况下。
};

#if TARGET_OS_MAC && !TARGET_OS_IPHONE
#pragma mark -
/**
 * 4.3 设备类型（仅 Mac）
 *
 * 在 Mac 上，每一种类型的设备都可能有多个，因此 TRTC SDK 的 Mac 版本提供了一系列函数用来操作这些设备。
 */
typedef NS_ENUM(NSInteger, TRTCMediaDeviceType) {
    TRTCMediaDeviceTypeUnknown      =   -1,  ///< 未定义
	
    TRTCMediaDeviceTypeAudioInput   =    0,  ///< 麦克风
    TRTCMediaDeviceTypeAudioOutput  =    1,  ///< 扬声器或听筒
    TRTCMediaDeviceTypeVideoCamera  =    2,  ///< 摄像头

    TRTCMediaDeviceTypeVideoWindow  =    3,  ///< 某个窗口（用于屏幕分享）
    TRTCMediaDeviceTypeVideoScreen  =    4,  ///< 整个屏幕（用于屏幕分享）
};
#endif

#if TARGET_OS_MAC && !TARGET_OS_IPHONE
#pragma mark -

/**
 * 4.4 屏幕分享目标类型（仅 Mac）
 *
 * 该枚举值主要用于 SDK 区分屏幕分享的目标，是屏幕上的某一个窗口，还是要分享整个屏幕。
 */
typedef NS_ENUM(NSInteger, TRTCScreenCaptureSourceType) {
    TRTCScreenCaptureSourceTypeUnknown      =   -1,    ///< 未定义
    TRTCScreenCaptureSourceTypeWindow       =    0,    ///< 该分享目标是某一个Mac窗口
    TRTCScreenCaptureSourceTypeScreen       =    1,    ///< 该分享目标是整个Mac桌面
};
#endif

#pragma mark -

/**
 * 4.5 混流参数配置模式
 *
 * 目前暂仅支持手动配置这一种模式，即需要指定 TRTCTranscodingConfig 的全部参数。
 */
typedef NS_ENUM(NSInteger, TRTCTranscodingConfigMode) {
    TRTCTranscodingConfigMode_Unknown = 0,   ///< 未定义
    TRTCTranscodingConfigMode_Manual  = 1,   ///< 手动配置混流参数
};


/////////////////////////////////////////////////////////////////////////////////
//
//                      【（五）TRTC 核心类型定义】
//                   
/////////////////////////////////////////////////////////////////////////////////
#pragma mark -

/** 
 * 5.1 进房相关参数
 *
 * 只有该参数填写正确，才能顺利调用 enterRoom 进入 roomId 所指定的音视频房间。
 */
@interface TRTCParams : NSObject

///【字段含义】应用标识（必填），腾讯视频云基于 sdkAppId 完成计费统计。
///【推荐取值】在腾讯云 [TRTC 控制台](https://console.cloud.tencent.com/rav/) 中创建应用，之后可以在账号信息页面中得到该 ID
@property (nonatomic, assign) UInt32   sdkAppId;

///【字段含义】用户标识（必填），当前用户的 userId，相当于登录用户名。
///【推荐取值】如果一个用户在您的账号系统中的 ID 为“abc”，则 userId 即可设置为“abc”。
@property (nonatomic, strong, nonnull) NSString* userId;

///【字段含义】用户签名（必填），当前 userId 对应的验证签名，相当于登录密码。
///【推荐取值】请参考 [如何计算UserSig](https://cloud.tencent.com/document/product/647/17275)。
@property (nonatomic, strong, nonnull) NSString* userSig;

///【字段含义】房间号码（必填），指定房间号，在同一个房间里的用户（userId）可以彼此看到对方并进行视频通话。
///【推荐取值】您可以随意指定，但请不要重复，如果您的用户账号 ID 是数字类型的，可以直接用创建者的用户 ID 来作为 roomId。
@property (nonatomic, assign) UInt32 roomId;

///【字段含义】直播场景下的角色，仅适用于直播场景（TRTCAppSceneLIVE），视频通话场景下指定无效。
///【推荐取值】默认值：主播（TRTCRoleAnchor）
@property (nonatomic, assign) TRTCRoleType role;

///【字段含义】房间签名（非必填），如果您希望某个房间只能让特定的某些 userId 进入，就需要使用 privateMapKey 进行权限保护。
///【推荐取值】仅建议有高级别安全需求的客户使用，参考文档：[进房权限保护](https://cloud.tencent.com/document/product/647/32240)
@property (nonatomic, strong, nullable) NSString* privateMapKey;

///【字段含义】业务数据（非必填），某些非常用的高级特性才需要用到此字段。
///【推荐取值】不建议使用
@property (nonatomic, strong, nullable) NSString* bussInfo;
@end

#pragma mark -

/** 
 * 5.2 视频编码参数
 *
 * 该设置决定了远端用户看到的画面质量（同时也是云端录制出的视频文件的画面质量）。
 */
@interface TRTCVideoEncParam : NSObject

///【字段含义】 视频分辨率
///【推荐取值】 - 视频通话建议选择360 × 640及以下分辨率，resMode 选择 Portrait。
///           - 手机直播建议选择 540 × 960，resMode 选择 Portrait。
///           - Window 和 iMac 建议选择 640 × 360 及以上分辨率，resMode 选择 Landscape。
///【特别说明】 您在 TRTCVideoResolution 只能找到横屏模式的分辨率，比如：640 × 360 这样的分辨率。
///             如果想要使用竖屏分辨率，请指定 resMode 为 Portrait，比如：640 × 360 + Portrait = 360 × 640。
@property (nonatomic, assign) TRTCVideoResolution videoResolution;

///【字段含义】分辨率模式（横屏分辨率 - 竖屏分辨率）
///【推荐取值】手机直播建议选择 Portrait，Window 和 Mac 建议选择 Landscape。
///【特别说明】如果 videoResolution 指定分辨率 640 × 360，resMode 指定模式为 Portrait，则最终编码出的分辨率为360 × 640。
@property (nonatomic, assign) TRTCVideoResolutionMode resMode;

///【字段含义】视频采集帧率
///【推荐取值】15fps 或 20fps，10fps 以下会有轻微卡顿感，5fps 以下卡顿感明显，20fps 以上的帧率则过于浪费（电影的帧率也只有 24fps）。
///【特别说明】很多 Android 手机的前置摄像头并不支持15fps以上的采集帧率，部分过于突出美颜功能的 Android 手机前置摄像头的采集帧率可能低于10fps。
@property (nonatomic, assign) int videoFps;

///【字段含义】视频上行码率
///【推荐取值】推荐设置请参考本文件前半部分 TRTCVideoResolution 定义处的注释说明
///【特别说明】码率太低会导致视频中有很多的马赛克
@property (nonatomic, assign) int videoBitrate;

@end

#pragma mark -

/** 
 * 5.3 网络流控相关参数
 *
 * 网络流控相关参数，该设置决定了 SDK 在各种网络环境下的调控方向（比如弱网下是“保清晰”还是“保流畅”）
 */
@interface TRTCNetworkQosParam : NSObject

///【字段含义】弱网下是“保清晰”还是“保流畅”
///【特别说明】
///   - 弱网下保流畅：在遭遇弱网环境时，画面会变得模糊，且会有较多马赛克，但可以保持流畅不卡顿
///   - 弱网下保清晰：在遭遇弱网环境时，画面会尽可能保持清晰，但可能会更容易出现卡顿
@property (nonatomic, assign) TRTCVideoQosPreference preference;

///【字段含义】视频分辨率（云端控制 - 客户端控制）
///【推荐取值】云端控制
///【特别说明】
///   - Client 模式：客户端控制模式，用于 SDK 开发内部调试，客户请勿使用
///   - Server 模式（默认）：云端控制模式，若没有特殊原因，请直接使用该模式
@property (nonatomic, assign) TRTCQosControlMode controlMode;
@end

#pragma mark -

/** 
 * 5.4 视频质量
 *
 * 表示视频质量的好坏，通过这个数值，您可以在 UI 界面上用图标表征 userId 的通话线路质量
 */
@interface TRTCQualityInfo : NSObject
/// 用户 ID
@property (nonatomic, copy, nullable)  NSString* userId;
/// 视频质量
@property (nonatomic, assign)   TRTCQuality quality;
@end

#pragma mark -

/** 
 * 5.5 音量大小
 *
 * 表示语音音量的评估大小，通过这个数值，您可以在 UI 界面上用图标表征 userId 是否有在说话 
 */
@interface TRTCVolumeInfo : NSObject <NSCopying>
/// 说话者的 userId, nil 为自己
@property (strong, nonatomic, nullable) NSString *userId;
/// 说话者的音量, 取值范围0 - 100
@property (assign, nonatomic) NSUInteger volume;
@end

#if TARGET_OS_MAC && !TARGET_OS_IPHONE
#pragma mark -

/**
 * 5.6 媒体设备描述
 *
 * 在 Mac 上，每一种类型的设备都可能有多个，因此 TRTC SDK 的 Mac 版本提供了一系列函数用来操作这些设备。
 */
@interface TRTCMediaDeviceInfo : NSObject
/// 设备类型
@property (assign, nonatomic) TRTCMediaDeviceType type;
/// 设备ID
@property (copy, nonatomic, nullable) NSString * deviceId;
/// 设备名称
@property (copy, nonatomic, nullable) NSString * deviceName;
@end
#endif

#if TARGET_OS_MAC && !TARGET_OS_IPHONE
#pragma mark -

/**
 * 5.7 屏幕分享目标信息（仅 Mac）
 *
 * 如果您要给您的 App 增加屏幕分享功能，一般需要先显示一个窗口选择界面，这样用户可以选择希望分享的窗口。
 * TRTCScreenCaptureSourceInfo 主要用于定义分享窗口的 ID、类型、窗口名称以及缩略图。
 */
@interface TRTCScreenCaptureSourceInfo : NSObject
/// 分享类型：要分享的是某个窗口还是整个屏幕
@property (assign, nonatomic) TRTCScreenCaptureSourceType type;
/// 窗口ID
@property (copy, nonatomic, nullable) NSString * sourceId;
/// 窗口名称
@property (copy, nonatomic, nullable) NSString * sourceName;
/// 窗口属性
@property (nonatomic, strong, nullable) NSDictionary * extInfo;
/// 窗口缩略图
@property (nonatomic, readonly, nullable) NSImage *thumbnail;
/// 窗口小图标
@property (nonatomic, readonly, nullable) NSImage *icon;
@end
#endif

#pragma mark -

/**
 * 5.8 网络测速结果
 *
 * 您可以在用户进入房间前通过 TRTCCloud 的 startSpeedTest 接口进行测速 （注意：请不要在通话中调用），
 * 测速结果会每2 - 3秒钟返回一次，每次返回一个 IP 地址的测试结果。
 *
 * @note - quality 是内部通过评估算法测算出的网络质量，loss 越低，rtt 越小，得分也就越高。
 * @note - upLostRate 是指上行丢包率，例如0.3代表每向服务器发送10个数据包，可能有3个会在中途丢失。
 * @note - downLostRate 是指下行丢包率，例如0.2代表从服务器每收取10个数据包，可能有2个会在中途丢失。
 * @note - rtt 是指当前设备到腾讯云服务器的一次网络往返时间，正常数值在10ms - 100ms之间。
 */
@interface TRTCSpeedTestResult : NSObject

/// 服务器 IP 地址
@property (strong, nonatomic, nonnull) NSString *ip;

/// 网络质量，内部通过评估算法测算出的网络质量，loss 越低，rtt 越小，得分也就越高。
@property (nonatomic) TRTCQuality quality;

/// 上行丢包率，范围是[0 - 1.0]，例如0.3代表每向服务器发送10个数据包，可能有3个会在中途丢失。
@property (nonatomic) float upLostRate;

/// 下行丢包率，范围是[0 - 1.0]，例如0.2代表从服务器每收取10个数据包，可能有2个会在中途丢失。
@property (nonatomic) float downLostRate;

/// 延迟（毫秒），代表 SDK 跟服务器一来一回之间所消耗的时间，这个值越小越好，正常数值在10ms - 100ms之间。
@property (nonatomic) uint32_t rtt;
@end

#pragma mark -

/** 
 *  5.9 视频帧信息
 *
 *  TRTCVideoFrame 用来描述一帧视频画面的裸数据，它或者是一帧编码前的画面，或者是一帧解码后的画面。
 */
@interface TRTCVideoFrame : NSObject

///【字段含义】视频像素格式
///【推荐取值】TRTCVideoPixelFormat_NV12 
@property (nonatomic, assign) TRTCVideoPixelFormat pixelFormat;

///【字段含义】视频数据结构类型
///【推荐取值】TRTCVideoBufferType_PixelBuffer
@property (nonatomic, assign) TRTCVideoBufferType bufferType;

///【字段含义】bufferType 为 TRTCVideoBufferType_PixelBuffer 时的视频数据。
@property (nonatomic, assign, nullable) CVPixelBufferRef pixelBuffer;

///【字段含义】bufferType 为 TRTCVideoBufferType_NSData 时的视频数据。
@property (nonatomic, retain, nullable) NSData* data;

///【字段含义】视频帧的时间戳，单位毫秒
///【推荐取值】自定义视频采集时可以填0，这样 SDK 会自定填充 timestamp 字段，但请“均匀”地控制 sendCustomVideoData 的调用间隔。
@property (nonatomic, assign) uint64_t timestamp;

///【字段含义】视频宽度
///【推荐取值】自定义视频采集时不需要填写。
@property (nonatomic, assign) uint32_t width;

///【字段含义】视频高度
///【推荐取值】自定义视频采集时不需要填写。
@property (nonatomic, assign) uint32_t height;

///【字段含义】视频像素的顺时针旋转角度
@property (nonatomic, assign) TRTCVideoRotation rotation;
@end


/** 
 * 5.10 音频帧数据
 */
#pragma mark -
/// 音频帧数据
@interface TRTCAudioFrame : NSObject
/// 音频数据
@property (nonatomic, retain, nonnull) NSData * data;
/// 采样率
@property (nonatomic, assign) TRTCAudioSampleRate sampleRate;
/// 声道数
@property (nonatomic, assign) int channels;
/// 时间戳，单位ms
@property (nonatomic, assign) uint64_t timestamp;
@end


/** 
* 5.11 云端混流中每一路子画面的位置信息
*
* TRTCMixUser 用于指定每一路（即每一个 userId）视频画面的具体摆放位置
*/
@interface TRTCMixUser : NSObject
/// 参与混流的 userId
@property(nonatomic, copy, nonnull) NSString * userId;
/// 混流的房间， 可填 nil 表示是自己所在的房间
@property (nonatomic, copy, nullable) NSString * roomID;
/// 图层位置坐标以及大小，左上角为坐标原点(0,0) （绝对像素值）
@property(nonatomic, assign) CGRect rect;
/// 图层层次（1 - 15）不可重复
@property(nonatomic, assign) int zOrder;
/// 参与混合的是主路画面（TRTCVideoStreamTypeBig）或屏幕分享（TRTCVideoStreamTypeSub）画面
@property (nonatomic) TRTCVideoStreamType streamType;
/// 是否是纯音频模式
@property (nonatomic, assign) BOOL pureAudio;

@end

 
/** 
* 5.12 云端混流（转码）配置
*
* 包括最终编码质量和各路画面的摆放位置
*/
@interface TRTCTranscodingConfig : NSObject

///【字段含义】转码config模式
@property(nonatomic, assign) TRTCTranscodingConfigMode mode; 

///【字段含义】腾讯云直播 AppID
///【推荐取值】请在 [实时音视频控制台](https://console.cloud.tencent.com/rav) 选择已经创建的应用，单击【帐号信息】后，在“直播信息”中获取
@property (nonatomic) int appId; 

///【字段含义】腾讯云直播 bizid
///【推荐取值】请在 [实时音视频控制台](https://console.cloud.tencent.com/rav) 选择已经创建的应用，单击【帐号信息】后，在“直播信息”中获取
@property (nonatomic) int bizId;                  

///【字段含义】最终转码后的视频分辨率的宽度（px）
@property(nonatomic, assign) int videoWidth;       

///【字段含义】最终转码后的视频分辨率的高度（px）
@property(nonatomic, assign) int videoHeight;      

///【字段含义】最终转码后的视频分辨率的码率（kbps）
@property(nonatomic, assign) int videoBitrate;     

///【字段含义】最终转码后的视频分辨率的帧率（FPS）
///【推荐取值】15
@property(nonatomic, assign) int videoFramerate;   

///【字段含义】最终转码后的视频分辨率的关键帧间隔（也被称为 GOP），单位秒
///【推荐取值】3
@property(nonatomic, assign) int videoGOP; 

///【字段含义】最终转码后的音频采样率
///【推荐取值】48000
@property(nonatomic, assign) int audioSampleRate;  

///【字段含义】最终转码后的音频码率，单位：K
///【推荐取值】64
@property(nonatomic, assign) int audioBitrate;  

///【字段含义】最终转码后的音频声道数
///【推荐取值】2
@property(nonatomic, assign) int audioChannels;    

///【字段含义】每一路子画面的位置信息
@property(nonatomic, copy, nonnull) NSArray<TRTCMixUser *> * mixUsers; 
@end

#pragma mark -

/** 
 * 5.13 CDN 旁路推流参数
 */
@interface TRTCPublishCDNParam : NSObject
/// 腾讯云 AppID，请在 [实时音视频控制台](https://console.cloud.tencent.com/rav) 选择已经创建的应用，单击【帐号信息】后，在“直播信息”中获取
@property (nonatomic) int appId;

/// 腾讯云直播 bizid，请在 [实时音视频控制台](https://console.cloud.tencent.com/rav) 选择已经创建的应用，单击【帐号信息】后，在“直播信息”中获取
@property (nonatomic) int bizId;

/// 旁路转推的 URL
@property (nonatomic, strong, nonnull) NSString * url;
@end

/**
 * 5.14 录音参数
 *
 * 请正确填写参数，确保录音文件顺利生成。
 */
@interface TRTCAudioRecordingParams : NSObject

///【字段含义】文件路径（必填），录音文件的保存路径。该路径需要用户自行指定，请确保路径存在且可写。
///【特别说明】该路径需精确到文件名及格式后缀，格式后缀决定录制文件的格式，例如：指定路径为 path/to/audio.aac，则会生成一个 AAC 格式的文件。目前支持的格式有 PCM, WAV, AAC
@property (nonatomic, strong, nonnull) NSString* filePath;
@end

/**
 * 5.15 音效
 *
 */
@interface TRTCAudioEffectParam : NSObject

+ (_Nonnull instancetype)new  __attribute__((unavailable("Use -initWith:(int)effectId path:(NSString * )path instead")));
- (_Nonnull instancetype)init __attribute__((unavailable("Use -initWith:(int)effectId path:(NSString *)path instead")));

/// 【字段含义】音效 ID
/// 【特别说明】SDK 允许播放多路音效，因此需要音效 ID 进行标记，用于控制音效的开始、停止、音量等
@property(nonatomic, assign) int effectId;

/// 【字段含义】音效文件路径
@property(nonatomic, copy, nonnull) NSString * path;

/// 【字段含义】循环播放次数
@property(nonatomic, assign) int loopCount;

/// 【字段含义】音效是否上行
@property(nonatomic, assign) BOOL publish;

/// 【字段含义】音效音量
/// 【推荐取值】默认值 100，取值范围 [0 , 100]
@property(nonatomic, assign) int volume;

- (_Nonnull instancetype)initWith:(int)effectId path:(NSString * _Nonnull)path;
@end

