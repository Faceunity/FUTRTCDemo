//
//  FUBeautySkinViewModel.h
//  FUDemo
//
//  Created by 项林平 on 2021/6/11.
//  美肤功能模块
//

#import <Foundation/Foundation.h>
#import "FUBeautySkinModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FUBeautySkinViewModel : NSObject

@property (nonatomic, copy, readonly) NSArray<FUBeautySkinModel *> *beautySkins;
/// 是否所有值都是默认
@property (nonatomic, assign, readonly) BOOL isDefaultValue;
/// 皮肤分割开关，默认为NO
@property (nonatomic, assign) BOOL skinSegmentationEnabled;
/// 当前选中索引，默认为-1
@property (nonatomic, assign) NSInteger selectedIndex;
/// 需要根据高低端机适配
@property (nonatomic, assign) FUDevicePerformanceLevel performanceLevel;

/// 设置单项美肤值
/// @param value 当前选中单项的值
- (void)setSkinValue:(double)value;

/// 恢复所有美肤值为默认
- (void)recoverAllSkinValuesToDefault;

@end

NS_ASSUME_NONNULL_END
