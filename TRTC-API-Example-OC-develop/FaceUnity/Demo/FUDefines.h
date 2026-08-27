//
//  FUDefines.h
//  FUDemo
//
//  Created by 项林平 on 2021/6/15.
//

#import <CoreGraphics/CoreGraphics.h>
#import <FURenderKit/FURenderKit.h>

#pragma mark - 宏

#define FULocalizedString(key) NSLocalizedStringFromTable(key, @"FaceUnity", nil)


#pragma mark - 枚举

/// 功能模块
typedef NS_ENUM(NSInteger, FUModuleType) {
    FUModuleTypeBeautySkin,             // 美肤
    FUModuleTypeBeautyShape,            // 美型
    FUModuleTypeBeautyFilter,           // 滤镜
    FUModuleTypeSticker,                // 贴纸
    FUModuleTypeMakeup,                 // 美妆
    FUModuleTypeBody                    // 美体
};

typedef NS_ENUM(NSUInteger, FUBeautySkin) {
    FUBeautySkinBlurLevel = 0,
    FUBeautySkinColorLevel,
    FUBeautySkinRedLevel,
    FUBeautySkinSharpen,
    FUBeautySkinFaceThreed,
    FUBeautySkinEyeBright,
    FUBeautySkinToothWhiten,
    FUBeautySkinRemovePouchStrength,
    FUBeautySkinRemoveNasolabialFoldsStrength,
    FUBeautySkinAntiAcneSpot,
    FUBeautySkinClarity,
    FUBeautySkinBodyBlurLevel,      // 全身磨皮，SDK key: body_blur_level，范围 0.0-6.0，仅 4 级机型
    FUBeautySkinFacialPlump         // 面部丰盈，SDK key: facial_plump，范围 0.0-1.0，高端机
};

typedef NS_ENUM(NSUInteger, FUBeautyShape) {
    FUBeautyShapeCheekThinning = 0,
    FUBeautyShapeCheekV,
    FUBeautyShapeCheekNarrow,
    FUBeautyShapeCheekShort,
    FUBeautyShapeCheekSmall,
    FUBeautyShapeCheekbones,
    FUBeautyShapeLowerJaw,
    FUBeautyShapeEyeEnlarging,
    FUBeautyShapeEyeCircle,
    FUBeautyShapeChin,
    FUBeautyShapeForehead,
    FUBeautyShapeNose,
    FUBeautyShapeMouth,
    FUBeautyShapeLipThick,
    FUBeautyShapeEyeHeight,
    FUBeautyShapeCanthus,
    FUBeautyShapeEyeLid,
    FUBeautyShapeEyeSpace,
    FUBeautyShapeEyeRotate,
    FUBeautyShapeLongNose,
    FUBeautyShapePhiltrum,
    FUBeautyShapeSmile,
    FUBeautyShapeBrowHeight,
    FUBeautyShapeBrowSpace,
    FUBeautyShapeBrowThick,
    FUBeautyShapeEyePupil,        // 瞳孔大小，SDK key: intensity_eye_pupil，范围 0.0-1.0，双向滑杆，全机型
    FUBeautyShapeCustomWarpFaceLift,   // 面部提拉，custom_warp_face_lift，0.0-1.0，默认 0.0
    FUBeautyShapeCustomWarpSmallHead,  // 小头，custom_warp_small_head，0.0-1.0，默认 0.0
    FUBeautyShapeCustomWarpEyeOutter,  // 外眼角，custom_warp_eye_outter，0.0-1.0，默认 0.5
    FUBeautyShapeCustomWarpMouthWidth, // 嘴巴宽度，custom_warp_mouth_width，0.0-1.0，默认 0.5
    FUBeautyShapeCustomWarpNoseAlar    // 鼻翼，custom_warp_nose_alar，0.0-1.0，默认 0.5
};

/// 美体模块子功能
typedef NS_ENUM(NSUInteger, FUBeautyBodyItem) {
    FUBeautyBodyItemSlim,  // 瘦身,
    FUBeautyBodyItemLongLeg, // 长腿,
    FUBeautyBodyItemThinWaist, // 细腰,
    FUBeautyBodyItemBeautyShoulder, // 美肩,
    FUBeautyBodyItemBeautyButtock, // 美臀,
    FUBeautyBodyItemSmallHead, // 小头,
    FUBeautyBodyItemThinLeg, // 瘦腿,
    FUBeautyBodyItemBreast, // 丰胸,
    FUBeautyBodyItemSwanNeck, // 天鹅颈
};


#pragma mark - 持久化 Key

static NSString * const FUPersistentBeautySkinKey = @"FUPersistentBeautySkin_v9.1.0";
static NSString * const FUPersistentBeautySkinSegmentationKey = @"FUPersistentBeautySkinSegmentation_v9.1.0";
static NSString * const FUPersistentBeautyShapeKey = @"FUPersistentBeautyShape_v9.1.0";

#pragma mark - 常量

static CGFloat const FUBottomBarHeight = 49.f;

static CGFloat const FUFunctionViewHeight = 118.f;

static CGFloat const FUFunctionSliderHeight = 30.f;

#pragma mark - 内联函数

static inline CGFloat FUSafaAreaBottomInsets(void) {
    if (@available(iOS 11.0, *)) {
        if (@available(iOS 11.0, *)) {
            if ([UIApplication sharedApplication].delegate.window) {
                return [UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom;
            }
            return [UIApplication sharedApplication].windows.firstObject.safeAreaInsets.bottom;
        }
    }
    return 0;
}


