//
//  FUMakeUpProducer.m
//  BeautifyExample
//
//  Created by Chen on 2021/4/25.
//  Copyright © 2021 Agora. All rights reserved.
//

#import "FUMakeupNodeModelProvider.h"
#import "FUBaseModel.h"

@implementation FUMakeupNodeModelProvider
@synthesize dataSource = _dataSource;
- (id)dataSource {
    if (!_dataSource) {
        _dataSource = [self producerDataSource];
    }
    return _dataSource;
}

- (NSArray *)producerDataSource {
    NSArray *prams = @[@"makeup_noitem",@"chaoA",@"dousha",@"naicha",@"jianling",@"nuandong",@"hongfeng",@"Rose",@"shaonv",@"ziyun",@"yanshimao",@"renyu",@"chuqiu",@"qianzhihe",@"chaomo",@"chuju",@"gangfeng",@"xinggan",@"tianmei",@"linjia",@"oumei",@"wumei"];
    NSDictionary *titelDic = @{@"chaoA" : @"超A", @"dousha": @"豆沙", @"naicha" : @"奶茶",  @"makeup_noitem":@"卸妆",@"jianling":@"减龄",@"nuandong":@"暖冬",@"hongfeng":@"红枫",@"Rose":@"玫瑰",@"shaonv":@"少女",@"ziyun":@"紫韵",@"yanshimao":@"厌世猫",@"renyu":@"人鱼",@"chuqiu":@"初秋",@"qianzhihe":@"千纸鹤",@"chaomo":@"超模",@"chuju":@"雏菊",@"gangfeng":@"港风",@"xinggan":@"性感",@"tianmei":@"甜美",@"linjia":@"邻家",@"oumei":@"欧美",@"wumei":@"妩媚"};
     
    NSMutableArray *source = [NSMutableArray arrayWithCapacity:prams.count];
    for (NSUInteger i = 0; i < prams.count; i ++) {
        NSString *str = [prams objectAtIndex:i];
        FUBaseModel *model = [[FUBaseModel alloc] init];
        model.imageName = str;
        model.mTitle = [titelDic valueForKey:str];
        model.indexPath = [NSIndexPath indexPathForRow:i inSection:FUDataTypeMakeup];
        model.mValue = @0.7;
        [source addObject:model];
    }
    return [NSArray arrayWithArray:source];
}
@end
