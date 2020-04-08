//
//  FUManager.m
//  FULiveDemo
//
//  Created by 刘洋 on 2017/8/18.
//  Copyright © 2017年 刘洋. All rights reserved.
//

#import "FUManager.h"
#import "funama.h"
#import "FURenderer.h"
#import "authpack.h"
#import <sys/utsname.h>

@interface FUManager ()
{
    //MARK: Faceunity
    int items[3];
    int frameID;
}
@end

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
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"v3.bundle" ofType:nil];
        
        /**这里新增了一个参数shouldCreateContext，设为YES的话，不用在外部设置context操作，我们会在内部创建并持有一个context。
         还有设置为YES,则需要调用FURenderer.h中的接口，不能再调用funama.h中的接口。*/
        [[FURenderer shareRenderer] setupWithDataPath:path authPackage:&g_auth_package authSize:sizeof(g_auth_package) shouldCreateContext:YES];
        
        [self setDefaultParameters];
        
        /* 加载AI模型 */
        [self loadAIModle];
        
        NSLog(@"faceunitySDK version:%@",[FURenderer getVersion]);
    }
    
    return self;
}

-(void)loadAIModle{
    /* 单独使用美颜场景，只需加载 ai_facelandmarks75,注：美颜和贴纸都用场景用 ai_face_processor*/
//    NSData *ai_facelandmarks75 = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ai_facelandmarks75.bundle" ofType:nil]];
//    [FURenderer loadAIModelFromPackage:(void *)ai_facelandmarks75.bytes size:(int)ai_facelandmarks75.length aitype:FUAITYPE_FACELANDMARKS75];
    
    NSData *ai_face_processor = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ai_face_processor.bundle" ofType:nil]];
    [FURenderer loadAIModelFromPackage:(void *)ai_face_processor.bytes size:(int)ai_face_processor.length aitype:FUAITYPE_FACEPROCESSOR];
}


/*设置默认参数*/
- (void)setDefaultParameters {
    
    self.itemsDataSource = @[ @"noitem", @"fengya_ztt_fu", @"hudie_lm_fu", @"juanhuzi_lm_fu", @"mask_hat", @"touhua_ztt_fu", @"yazui", @"yuguan"];
    self.selectedItem = @"fengya_ztt_fu" ;
    
    self.filtersDataSource = @[@"origin", @"delta", @"electric", @"slowlived", @"tokyo", @"warm"];
    self.selectedFilter         = self.filtersDataSource[0] ;
    
    self.beautyFiltersDataSource = @[@"ziran", @"danya", @"fennen", @"qingxin", @"hongrun"];
    self.filtersCHName = @{@"ziran":@"自然", @"danya":@"淡雅", @"fennen":@"粉嫩", @"qingxin":@"清新", @"hongrun":@"红润"};
    
    self.selectedFilterLevel    = 0.5 ;
    
    self.skinDetectEnable       = YES ;
    self.blurShape              = 1 ;
    self.blurLevel              = 0.7 ;
    self.whiteLevel             = 0.5 ;
    self.redLevel               = 0.5 ;
    
    self.eyelightingLevel       = 0.7 ;
    self.beautyToothLevel       = 0.7 ;
    
    self.faceShape              = 4 ;
    self.enlargingLevel         = 0.4 ;
    self.thinningLevel          = 0.4 ;
    self.enlargingLevel_new         = 0.4 ;
    self.thinningLevel_new          = 0.4 ;
    
    self.jewLevel               = 0.3 ;
    self.foreheadLevel          = 0.3 ;
    self.noseLevel              = 0.5 ;
    self.mouthLevel             = 0.4 ;
    
    self.enableGesture = NO;
    self.enableMaxFaces = NO;
}

- (void)loadItems
{
    /**加载普通道具*/
    [self loadItem:self.selectedItem];
    
    /**加载美颜道具*/
    [self loadFilter];
}

- (void)setEnableGesture:(BOOL)enableGesture
{
    _enableGesture = enableGesture;
}

/**开启多脸识别（最高可设为8，不过考虑到性能问题建议设为4以内*/
- (void)setEnableMaxFaces:(BOOL)enableMaxFaces
{
    if (_enableMaxFaces == enableMaxFaces) {
        return;
    }
    
    _enableMaxFaces = enableMaxFaces;
    
    if (_enableMaxFaces) {
        [FURenderer setMaxFaces:4];
    }else{
        [FURenderer setMaxFaces:1];
    }
    
}

/**销毁全部道具*/
- (void)destoryItems
{
    [FURenderer destroyAllItems];
    
    /**销毁道具后，为保证被销毁的句柄不再被使用，需要将int数组中的元素都设为0*/
    for (int i = 0; i < sizeof(items) / sizeof(int); i++) {
        items[i] = 0;
    }
    
    /**销毁道具后，清除context缓存*/
    [FURenderer OnDeviceLost];
    
    /**销毁道具后，重置人脸检测*/
    [FURenderer onCameraChange];
    
    /**销毁道具后，重置默认参数*/
    [self setDefaultParameters];
}

#pragma -Faceunity Load Data
/**
 加载普通道具
 - 先创建再释放可以有效缓解切换道具卡顿问题
 */
- (void)loadItem:(NSString *)itemName
{
    NSLog(@"---- load item: %@", itemName);
    /**如果取消了道具的选择，直接销毁道具*/
    if ([itemName isEqual: @"noitem"] || itemName == nil)
    {
        if (items[1] != 0) {
            
//            NSLog(@"faceunity: destroy item");
//            [FURenderer destroyItem:items[1]];
            
            fuDestroyItem(items[1]) ;
            
            /**为避免道具句柄被销毁会后仍被使用导致程序出错，这里需要将存放道具句柄的items[1]设为0*/
            items[1] = 0;
        }
        return;
    }
    
    /**先创建道具句柄*/
    NSString *path = [[NSBundle mainBundle] pathForResource:[itemName stringByAppendingString:@".bundle"] ofType:nil];
    int itemHandle = [FURenderer itemWithContentsOfFile:path];
    
    /**销毁老的道具句柄*/
    if (items[1] != 0) {
        NSLog(@"faceunity: destroy item");
//        [FURenderer destroyItem:items[1]];
        fuDestroyItem(items[1]) ;
    }
    
    /**将刚刚创建的句柄存放在items[1]中*/
    items[1] = itemHandle;
    
    NSLog(@"faceunity: load item");
}

/**加载美颜道具*/
/**加载美颜道具*/
- (void)loadFilter
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"face_beautification.bundle" ofType:nil];

    items[0] = [FURenderer itemWithContentsOfFile:path];
    
}
/**设置美颜参数*/
- (void)setBeautyParams {
    
    [FURenderer itemSetParam:items[0] withName:@"skin_detect" value:@(self.skinDetectEnable)]; //是否开启皮肤检测
    [FURenderer itemSetParam:items[0] withName:@"heavy_blur" value:@(self.blurShape)]; // 美肤类型 (0、1、) 清晰：0，朦胧：1
    [FURenderer itemSetParam:items[0] withName:@"blur_level" value:@(self.blurLevel * 6.0 )]; //磨皮 (0.0 - 6.0)
    [FURenderer itemSetParam:items[0] withName:@"color_level" value:@(self.whiteLevel)]; //美白 (0~1)
    [FURenderer itemSetParam:items[0] withName:@"red_level" value:@(self.redLevel)]; //红润 (0~1)
    [FURenderer itemSetParam:items[0] withName:@"eye_bright" value:@(self.eyelightingLevel)]; // 亮眼
    [FURenderer itemSetParam:items[0] withName:@"tooth_whiten" value:@(self.beautyToothLevel)];// 美牙
    
    [FURenderer itemSetParam:items[0] withName:@"face_shape" value:@(self.faceShape)]; //美型类型 (0、1、2、3、4)女神：0，网红：1，自然：2，默认：3，自定义：4
    
    [FURenderer itemSetParam:items[0] withName:@"eye_enlarging" value:self.faceShape == 4 ? @(self.enlargingLevel_new) : @(self.enlargingLevel)]; //大眼 (0~1)
    [FURenderer itemSetParam:items[0] withName:@"cheek_thinning" value:self.faceShape == 4 ? @(self.thinningLevel_new) : @(self.thinningLevel)]; //瘦脸 (0~1)
    [FURenderer itemSetParam:items[0] withName:@"intensity_chin" value:@(self.jewLevel)]; /**下巴 (0~1)*/
    [FURenderer itemSetParam:items[0] withName:@"intensity_nose" value:@(self.noseLevel)];/**鼻子 (0~1)*/
    [FURenderer itemSetParam:items[0] withName:@"intensity_forehead" value:@(self.foreheadLevel)];/**额头 (0~1)*/
    [FURenderer itemSetParam:items[0] withName:@"intensity_mouth" value:@(self.mouthLevel)];/**嘴型 (0~1)*/
    
    [FURenderer itemSetParam:items[0] withName:@"filter_name" value:self.selectedFilter]; //滤镜名称
    [FURenderer itemSetParam:items[0] withName:@"filter_level" value:@(self.selectedFilterLevel)]; //滤镜程度
}

#pragma mark -  render
/**将道具绘制到pixelBuffer*/
- (CVPixelBufferRef)renderItemsToPixelBuffer:(CVPixelBufferRef)pixelBuffer{
    
    [self setBeautyParams];
   
    CVPixelBufferRef buffer = [[FURenderer shareRenderer] renderPixelBuffer:pixelBuffer withFrameId:frameID items:items itemCount:sizeof(items)/sizeof(int) flipx:YES];//flipx 参数设为YES可以使道具做水平方向的镜像翻转
    frameID += 1;
    
    return buffer;
}

/**处理YUV*/
- (void)processFrameWithY:(void*)y U:(void*)u V:(void*)v yStride:(int)ystride uStride:(int)ustride vStride:(int)vstride FrameWidth:(int)width FrameHeight:(int)height {
    
    /**设置美颜参数*/
    [self setBeautyParams];
    
    [[FURenderer shareRenderer] renderFrame:y u:u  v:v  ystride:ystride ustride:ustride vstride:vstride width:width height:height frameId:frameID items:items itemCount:sizeof(items)/sizeof(int)];
    frameID ++ ;
}

/**将道具绘制到pixelBuffer*/

- (int)renderItemWithTexture:(int)texture Width:(int)width Height:(int)height {
    
    [self setBeautyParams];
    [self prepareToRender];
    
    GLint aa =  glGetError();
    
    if(self.flipx){
       fuRenderItemsEx2(FU_FORMAT_RGBA_TEXTURE,&texture, FU_FORMAT_RGBA_TEXTURE, &texture, width, height, frameID, items, sizeof(items)/sizeof(int), NAMA_RENDER_OPTION_FLIP_X | NAMA_RENDER_FEATURE_FULL, NULL);
    }else{
       fuRenderItemsEx(FU_FORMAT_RGBA_TEXTURE, &texture, FU_FORMAT_RGBA_TEXTURE, &texture, width, height, frameID, items, sizeof(items)/sizeof(int)) ;
    }

    [self renderFlush];
    
    frameID ++ ;
    
    return texture;
}

// 此方法用于提高 FaceUnity SDK 和 腾讯 SDK 的兼容性
 static int enabled[10];
- (void)prepareToRender {
    for (int i = 0; i<10; i++) {
        glGetVertexAttribiv(i,GL_VERTEX_ATTRIB_ARRAY_ENABLED,&enabled[i]);
    }
}

// 此方法用于提高 FaceUnity SDK 和 腾讯 SDK 的兼容性
- (void)renderFlush {
    glFlush();
    
    for (int i = 0; i<10; i++) {
        
        if(enabled[i]){
            glEnableVertexAttribArray(i);
        }
        else{
            glDisableVertexAttribArray(i);
        }
    }
}


/**获取图像中人脸中心点*/
- (CGPoint)getFaceCenterInFrameSize:(CGSize)frameSize{
    
    static CGPoint preCenter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        preCenter = CGPointMake(0.5, 0.5);
    });
    
    // 获取人脸矩形框，坐标系原点为图像右下角，float数组为矩形框右下角及左上角两个点的x,y坐标（前两位为右下角的x,y信息，后两位为左上角的x,y信息）
    float faceRect[4];
    int ret = [FURenderer getFaceInfo:0 name:@"face_rect" pret:faceRect number:4];
    
    if (ret == 0) {
        return preCenter;
    }
    
    // 计算出中心点的坐标值
    CGFloat centerX = (faceRect[0] + faceRect[2]) * 0.5;
    CGFloat centerY = (faceRect[1] + faceRect[3]) * 0.5;
    
    // 将坐标系转换成以左上角为原点的坐标系
    centerX = frameSize.width - centerX;
    centerX = centerX / frameSize.width;
    
    centerY = frameSize.height - centerY;
    centerY = centerY / frameSize.height;
    
    CGPoint center = CGPointMake(centerX, centerY);
    
    preCenter = center;
    
    return center;
}

/**获取75个人脸特征点*/
- (void)getLandmarks:(float *)landmarks
{
    int ret = [FURenderer getFaceInfo:0 name:@"landmarks" pret:landmarks number:150];
    
    if (ret == 0) {
        memset(landmarks, 0, sizeof(float)*150);
    }
}

/**判断是否检测到人脸*/
- (BOOL)isTracking
{
    return [FURenderer isTracking] > 0;
}

/**切换摄像头要调用此函数*/
- (void)onCameraChange
{
    [FURenderer onCameraChange];
}

/**获取错误信息*/
- (NSString *)getError
{
    // 获取错误码
    int errorCode = fuGetSystemError();
    
    if (errorCode != 0) {
        
        // 通过错误码获取错误描述
        NSString *errorStr = [NSString stringWithUTF8String:fuGetSystemErrorString(errorCode)];
        
        return errorStr;
    }
    
    return nil;
}
@end
