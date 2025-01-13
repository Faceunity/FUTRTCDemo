//
//  FUBeautySkinViewModel.m
//  FUDemo
//
//  Created by 项林平 on 2021/6/11.
//

#import "FUBeautySkinViewModel.h"
#import "FUBeautySkinModel.h"

@interface FUBeautySkinViewModel ()

@property (nonatomic, copy) NSArray<FUBeautySkinModel *> *beautySkins;

@end

@implementation FUBeautySkinViewModel

- (instancetype)init {
    self = [super init];
    if (self) {
        self.performanceLevel = [FURenderKit devicePerformanceLevel];
        self.beautySkins = [self defaultSkins];
        // 默认不开启皮肤分割
        _skinSegmentationEnabled = NO;
        _selectedIndex = -1;
        
        [self setAllSkinValues];
    }
    return self;
}

#pragma mark - Instance methods

- (void)setSkinValue:(double)value {
    if (self.selectedIndex < 0 || self.selectedIndex >= self.beautySkins.count) {
        return;
    }
    FUBeautySkinModel *model = self.beautySkins[self.selectedIndex];
    model.currentValue = value * model.ratio;
    [self setValue:model.currentValue forType:model.type];
}

- (void)setAllSkinValues {
    for (FUBeautySkinModel *skin in self.beautySkins) {
        [self setValue:skin.currentValue forType:skin.type];
    }
    self.skinSegmentationEnabled = _skinSegmentationEnabled;
}

- (void)recoverAllSkinValuesToDefault {
    for (FUBeautySkinModel *skin in self.beautySkins) {
        skin.currentValue = skin.defaultValue;
        [self setValue:skin.currentValue forType:skin.type];
    }
    self.skinSegmentationEnabled = NO;
}

- (void)setSkinSegmentationEnabled:(BOOL)skinSegmentationEnabled {
    _skinSegmentationEnabled = skinSegmentationEnabled;
    [FURenderKit shareRenderKit].beauty.enableSkinSegmentation = skinSegmentationEnabled;
}

#pragma mark - Private methods

- (void)setValue:(double)value forType:(FUBeautySkin)type {
    switch (type) {
        case FUBeautySkinBlurLevel:
            [FURenderKit shareRenderKit].beauty.blurLevel = value;
            break;
        case FUBeautySkinColorLevel:
            [FURenderKit shareRenderKit].beauty.colorLevel = value;
            break;
        case FUBeautySkinRedLevel:
            [FURenderKit shareRenderKit].beauty.redLevel = value;
            break;
        case FUBeautySkinSharpen:
            [FURenderKit shareRenderKit].beauty.sharpen = value;
            break;
        case FUBeautySkinFaceThreed:
            [FURenderKit shareRenderKit].beauty.faceThreed = value;
            break;
        case FUBeautySkinEyeBright:
            [FURenderKit shareRenderKit].beauty.eyeBright = value;
            break;
        case FUBeautySkinToothWhiten:
            [FURenderKit shareRenderKit].beauty.toothWhiten = value;
            break;
        case FUBeautySkinRemovePouchStrength:
            [FURenderKit shareRenderKit].beauty.removePouchStrength = value;
            break;
        case FUBeautySkinRemoveNasolabialFoldsStrength:
            [FURenderKit shareRenderKit].beauty.removeNasolabialFoldsStrength = value;
            break;
        case FUBeautySkinAntiAcneSpot:
            [FURenderKit shareRenderKit].beauty.antiAcneSpot = value;
            break;
        case FUBeautySkinClarity:
            [FURenderKit shareRenderKit].beauty.clarity = value;
            break;
    }
}

#pragma mark - Getters

- (BOOL)isDefaultValue {
    if (self.skinSegmentationEnabled) {
        // 开启了皮肤美白
        return NO;
    }
    for (FUBeautySkinModel *skin in self.beautySkins) {
        int currentIntValue = skin.defaultValueInMiddle ? (int)(skin.currentValue / skin.ratio * 100 - 50) : (int)(skin.currentValue / skin.ratio * 100);
        int defaultIntValue = skin.defaultValueInMiddle ? (int)(skin.defaultValue / skin.ratio * 100 - 50) : (int)(skin.defaultValue / skin.ratio * 100);
        if (currentIntValue != defaultIntValue) {
            return NO;
        }
    }
    return YES;
}

- (NSArray<FUBeautySkinModel *> *)defaultSkins {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *skinPath = self.performanceLevel == FUDevicePerformanceLevelLow_1 ? [bundle pathForResource:@"beauty_skin_low" ofType:@"json"] : self.performanceLevel < FUDevicePerformanceLevelHigh ? [bundle pathForResource:@"beauty_skin_lessThan2" ofType:@"json"] : [bundle pathForResource:@"beauty_skin" ofType:@"json"];
    NSArray<NSDictionary *> *skinData = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:skinPath] options:NSJSONReadingMutableContainers error:nil];
    NSMutableArray *skins = [[NSMutableArray alloc] init];
    for (NSDictionary *dictionary in skinData) {
        FUBeautySkinModel *model = [[FUBeautySkinModel alloc] init];
        [model setValuesForKeysWithDictionary:dictionary];
        [skins addObject:model];
    }
    return [skins copy];
}

@end
