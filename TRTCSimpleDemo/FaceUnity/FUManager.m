//
//  FUManager.m
//  FULiveDemo
//
//  Created by 刘洋 on 2017/8/18.
//  Copyright © 2017年 刘洋. All rights reserved.
//

#import "FUManager.h"

#import <CoreMotion/CoreMotion.h>
#import "authpack.h"
#import <sys/utsname.h>

static FUManager *shareManager = NULL;

@implementation FUManager

+ (FUManager *)shareManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareManager = [[FUManager alloc] init];
    });

    return shareManager;
}

- (instancetype)init
{
    if (self = [super init]) {
        CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();

        NSString *controllerPath = [[NSBundle mainBundle] pathForResource:@"controller_cpp" ofType:@"bundle"];
        NSString *controllerConfigPath = [[NSBundle mainBundle] pathForResource:@"controller_config" ofType:@"bundle"];
        FUSetupConfig *setupConfig = [[FUSetupConfig alloc] init];
        setupConfig.authPack = FUAuthPackMake(g_auth_package, sizeof(g_auth_package));
        setupConfig.controllerPath = controllerPath;
        setupConfig.controllerConfigPath = controllerConfigPath;
        
        // 初始化 FURenderKit
        [FURenderKit setupWithSetupConfig:setupConfig];
        
        [FURenderKit setLogLevel:FU_LOG_LEVEL_INFO];
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            // 加载人脸 AI 模型
            NSString *faceAIPath = [[NSBundle mainBundle] pathForResource:@"ai_face_processor" ofType:@"bundle"];
            [FUAIKit loadAIModeWithAIType:FUAITYPE_FACEPROCESSOR dataPath:faceAIPath];
            
            // 加载身体 AI 模型
            NSString *bodyAIPath = [[NSBundle mainBundle] pathForResource:@"ai_human_processor" ofType:@"bundle"];
            [FUAIKit loadAIModeWithAIType:FUAITYPE_HUMAN_PROCESSOR dataPath:bodyAIPath];
            
            CFAbsoluteTime endTime = (CFAbsoluteTimeGetCurrent() - startTime);
            
            NSString *path = [[NSBundle mainBundle] pathForResource:@"tongue" ofType:@"bundle"];
            [FUAIKit loadTongueMode:path];
            
            //TODO: todo 是否需要用？？？？？
            /* 设置嘴巴灵活度 默认= 0*/ //
            float flexible = 0.5;
            [FUAIKit setFaceTrackParam:@"mouth_expression_more_flexible" value:flexible];
            NSLog(@"---%lf",endTime);
        });
        
        NSLog(@"faceunitySDK version:%@",[FURenderKit getVersion]);
        
        self.viewModelManager = [FUViewModelManager new];
        
        [FUAIKit shareKit].maxTrackFaces = 4;
    }
    
    return self;
}

- (void)destoryItems {
    [self.viewModelManager removeAllViewModel];
}

- (void)onCameraChange {
    [FUAIKit resetTrackedResult];
}

- (NSString *)getError {
    return [FURenderKit getSystemErrorString];
}

@end
