//
//  FUBodyViewModel.m
//  FULiveDemo
//
//  Created by 项林平 on 2022/8/10.
//

#import "FUBodyViewModel.h"
#import "FUBodyModel.h"
#import <FURenderKit/FURenderKit.h>

@interface FUBodyViewModel ()

@property (nonatomic, copy) NSArray<FUBodyModel *> *bodies;

@end

@implementation FUBodyViewModel

- (instancetype)init {
    self = [super init];
    if (self) {
        self.bodies = [self defaultBodies];
        _selectedIndex = -1;
        [self setAllBodyValues];
    }
    return self;
}


#pragma mark - Instance methods

- (void)setAllBodyValues {
    for (FUBodyModel *body in self.bodies) {
        [self setValue:body.currentValue forType:body.type];
    }
}


- (void)setBodyValue:(double)value {
    if (self.selectedIndex < 0 || self.selectedIndex >= self.bodies.count) {
        return;
    }
    FUBodyModel *model = self.bodies[self.selectedIndex];
    model.currentValue = value;
    [self setValue:model.currentValue forType:model.type];
}

- (void)recoverAllBodyValuesToDefault {
    for (FUBodyModel *bodyBeauty in self.bodies) {
        bodyBeauty.currentValue = bodyBeauty.defaultValue;
        [self setValue:bodyBeauty.currentValue forType:bodyBeauty.type];
    }
}

#pragma mark - Private methods

- (void)setValue:(double)value forType:(FUBeautyBodyItem)type {
    switch (type) {
        case FUBeautyBodyItemSlim:
            [FURenderKit shareRenderKit].bodyBeauty.bodySlimStrength = value;
        
            break;
        case FUBeautyBodyItemLongLeg:
            [FURenderKit shareRenderKit].bodyBeauty.legSlimStrength = value;
        
            break;
        case FUBeautyBodyItemThinWaist:
            [FURenderKit shareRenderKit].bodyBeauty.waistSlimStrength = value;
        
            break;
        case FUBeautyBodyItemBeautyShoulder:
            [FURenderKit shareRenderKit].bodyBeauty.shoulderSlimStrength = value;
        
            break;
        case FUBeautyBodyItemBeautyButtock:
            [FURenderKit shareRenderKit].bodyBeauty.hipSlimStrength = value;
        
            break;
        case FUBeautyBodyItemSmallHead:
            [FURenderKit shareRenderKit].bodyBeauty.headSlim = value;
        
            break;
        case FUBeautyBodyItemThinLeg:
            [FURenderKit shareRenderKit].bodyBeauty.legSlim = value;
        
            break;
        case FUBeautyBodyItemBreast:
            [[FURenderKit shareRenderKit].bodyBeauty setParam:@(value) forName:@"BreastStrength" paramType:FUParamTypeDouble];
        
            break;
    }
}

#pragma mark - Getters

- (NSArray<FUBodyModel *> *)defaultBodies {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:@"body" ofType:@"json"];
    NSArray<NSDictionary *> *bodyData = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path] options:NSJSONReadingMutableContainers error:nil];
    NSMutableArray *bodies = [[NSMutableArray alloc] init];
    for (NSDictionary *dictionary in bodyData) {
        FUBodyModel *model = [[FUBodyModel alloc] init];
        [model setValuesForKeysWithDictionary:dictionary];
        [bodies addObject:model];
    }
    return [bodies copy];
}


- (BOOL)isDefaultValue {
    for (FUBodyModel *bodyBeauty in self.bodies) {
        int currentIntValue = bodyBeauty.defaultValueInMiddle ? (int)(bodyBeauty.currentValue * 100 - 50) : (int)(bodyBeauty.currentValue * 100);
        int defaultIntValue = bodyBeauty.defaultValueInMiddle ? (int)(bodyBeauty.defaultValue * 100 - 50) : (int)(bodyBeauty.defaultValue * 100);
        if (currentIntValue != defaultIntValue) {
            return NO;
        }
    }
    return YES;
}

@end