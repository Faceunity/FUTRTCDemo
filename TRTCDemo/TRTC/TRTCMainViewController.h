/*
 * Module:   TRTCMainViewController
 * 
 * Function: 使用TRTC SDK完成 1v1 和 1vn 的视频通话功能
 *
 *    1. 支持九宫格平铺和前后叠加两种不同的视频画面布局方式，该部分由 TRTCVideoViewLayout 来计算每个视频画面的位置排布和大小尺寸
 *
 *    2. 支持对视频通话的分辨率、帧率和流畅模式进行调整，该部分由 TRTCSettingViewController 来实现
 *
 *    3. 创建或者加入某一个通话房间，需要先指定 roomid 和 userid，这部分由 TRTCNewViewController 来实现
 */

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "TRTCCloud.h"


@interface TRTCMainViewController : UIViewController 

@property (nonatomic) TRTCParams *param;    /// TRTC SDK 视频通话房间进入所必须的参数
//@property (nonatomic) BOOL  pureAudioMode;
@property (nonatomic, assign) BOOL enableCustomVideoCapture;
@property (nonatomic, retain) AVAsset* customMediaAsset;
@property (nonatomic, assign) TRTCAppScene appScene;

@property (nonatomic, assign) BOOL enableAEC;
@property (nonatomic, assign) BOOL enableAGC;
@property (nonatomic, assign) BOOL enableANC;
@property (nonatomic, assign) TRTCSystemVolumeType volumeType;

- (void)setLocalView:(UIView*)localView remoteViewDic:(NSMutableDictionary*)remoteViewDic;

@end
