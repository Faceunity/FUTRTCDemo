/*
* Module:   TXReplayKitExt @ TXLiteAVSDK
*
* Function: 腾讯云 ReplayKit 录屏功能在Extension中的主要接口类
*
* Version: 7.7.9458
*/

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, TXReplayKitExtReason) {
    /// 主进程请求结束
    TXReplayKitExtReasonRequestedByMain,
    /// 链接断开，主进程退出
    TXReplayKitExtReasonDisconnected,
    /// 版本号与主进程SDK不符
    TXReplayKitExtReasonVersionMismatch
};

@protocol TXReplayKitExtDelegate;

/// 屏幕分享主入口类
@interface TXReplayKitExt : NSObject

/// 获取单例
+ (instancetype)sharedInstance;

/// 初始化方法
///
/// 需要在 RPBroadcastSampleHandler 的实现类中的 broadcastStartedWithSetupInfo 方法中调用
/// @param appGroup App group ID
/// @param delegate 回调对象
- (void)setupWithAppGroup:(NSString *)appGroup delegate:(id<TXReplayKitExtDelegate>)delegate;


/// 录屏完成方法
///
/// 通过系统控制中心停止录屏时，会回调 RPBroadcastSampleHandler.broadcastFinished，在 broadcastFinished 方法中调用
- (void)finishBroadcast;

/// 视频发送方法
///
/// 需要在 RPBroadcastSampleHandler 的实现类中的 processSampleBuffer: 方法中调用
/// @param sampleBuffer 系统回调的视频帧
- (void)sendVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer;
@end

@protocol TXReplayKitExtDelegate <NSObject>
/// 录屏完成回调
///
/// @param broadcast 发出回调的实例
/// @param reason 结束原因代码, 参见 TXReplayKitExtReason
- (void)broadcastFinished:(TXReplayKitExt *)broadcast reason:(TXReplayKitExtReason)reason;
@end

NS_ASSUME_NONNULL_END
