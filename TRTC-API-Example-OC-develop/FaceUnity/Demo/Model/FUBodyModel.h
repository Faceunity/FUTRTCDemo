//
//  FUBodyModel.h
//  FULiveDemo
//
//  Created by 项林平 on 2022/8/10.
//

#import <Foundation/Foundation.h>
#import "FUDefines.h"

NS_ASSUME_NONNULL_BEGIN

@interface FUBodyModel : NSObject

@property (nonatomic, assign) FUBeautyBodyItem type;
@property (nonatomic, copy) NSString* name;
@property (nonatomic, assign) double defaultValue;
@property (nonatomic, assign) double currentValue;
@property (nonatomic, assign) BOOL defaultValueInMiddle;

@end

NS_ASSUME_NONNULL_END
