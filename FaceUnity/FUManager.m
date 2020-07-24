//
//  FUManager.m
//  FULiveDemo
//
//  Created by 刘洋 on 2017/8/18.
//  Copyright © 2017年 刘洋. All rights reserved.
//

#import "FUManager.h"
#import <libCNamaSDK/CNamaSDK.h>

#import <CoreMotion/CoreMotion.h>
#import "authpack.h"
#import <sys/utsname.h>

@interface FUManager ()
{
    //MARK: Faceunity
    int items[FUNamaHandleTotal];
    int frameID;
    NSString *oldMakeup;
}

@property (nonatomic, strong) CMMotionManager *motionManager;

@property (nonatomic) int deviceOrientation;

@property (nonatomic,assign)FUDataType currentType;
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
        
        [self setupDeviceMotion];
        _asyncLoadQueue = dispatch_queue_create("com.faceLoadItem", DISPATCH_QUEUE_SERIAL);

        /**这里新增了一个参数shouldCreateContext，设为YES的话，不用在外部设置context操作，我们会在内部创建并持有一个context。
         还有设置为YES,则需要调用FURenderer.h中的接口，不能再调用funama.h中的接口。*/
        [[FURenderer shareRenderer] setupWithData:nil dataSize:0 ardata:nil authPackage:&g_auth_package authSize:sizeof(g_auth_package) shouldCreateContext:YES];
        
        /* 加载AI模型 */
        [self loadAIModle];
        
        [self loadFilter];
        NSLog(@"faceunitySDK version:%@",[FURenderer getVersion]);
        
        [FURenderer setMaxFaces:4];
        
        self.isRender = YES;
        self.flipx = YES;
    }
    
    return self;
}

-(void)loadAIModle{

    NSData *ai_human_processor = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ai_human_processor.bundle" ofType:nil]];
    [FURenderer loadAIModelFromPackage:(void *)ai_human_processor.bytes size:(int)ai_human_processor.length aitype:FUAITYPE_HUMAN_PROCESSOR];
    
    NSData *ai_face_processor = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ai_face_processor.bundle" ofType:nil]];
    [FURenderer loadAIModelFromPackage:(void *)ai_face_processor.bytes size:(int)ai_face_processor.length aitype:FUAITYPE_FACEPROCESSOR];
}

- (void)loadBundleWithName:(NSString *)name aboutType:(FUNamaHandleType)type{
    dispatch_async(_asyncLoadQueue, ^{
        if (self->items[type] != 0) {
            NSLog(@"faceunity: destroy item");
            [FURenderer destroyItem:self->items[type]];
            self->items[type] = 0;
        }
        if ([name isEqualToString:@""] || !name) {
            return ;
        }
        NSString *filePath = [[NSBundle mainBundle] pathForResource:name ofType:@"bundle"];
        self->items[type] = [FURenderer itemWithContentsOfFile:filePath];
    });
}

-(void)setParamItemAboutType:(FUNamaHandleType)type name:(NSString *)paramName value:(float)value{
    dispatch_async(_asyncLoadQueue, ^{
        if(self->items[type]){
            [FURenderer itemSetParam:self->items[type] withName:paramName value:@(value)];
        NSLog(@"设置type(%lu)----参数（%@）-----值（%lf",(unsigned long)self->items[type],paramName,value);
       }
    });
}


- (void)destoryItemAboutType:(FUNamaHandleType)type;
{
    dispatch_async(_asyncLoadQueue, ^{
        /**后销毁老道具句柄*/
        if (self->items[type] != 0) {
            NSLog(@"faceunity: destroy item");
            [FURenderer destroyItem:self->items[type]];
            self->items[type] = 0;
        }
    });
}

-(int)getHandleAboutType:(FUNamaHandleType)type{
    return items[type];
}

-(void)setRenderType:(FUDataType)dateType{
    _currentType = dateType;
}

static int oldHandle = 0;
-(void)filterValueChange:(FUBeautyParam *)param{
    dispatch_async(_asyncLoadQueue, ^{
        [[FURenderer shareRenderer] setUpCurrentContext];
           if (param.type == FUDataTypeBeautify) {
               if(self->items[FUNamaHandleTypeBeauty] == 0){
                   [self loadFilter];
               }
               if ([param.mParam isEqualToString:@"cheek_narrow"] || [param.mParam isEqualToString:@"cheek_small"]){//程度值 只去一半
                   [FURenderer itemSetParam:self->items[FUNamaHandleTypeBeauty] withName:param.mParam value:@(param.mValue * 0.5)];

               }else if([param.mParam isEqualToString:@"blur_level"]) {//磨皮 0~6
                   [FURenderer itemSetParam:self->items[FUNamaHandleTypeBeauty] withName:param.mParam value:@(param.mValue * 6)];
               }else{
                   [FURenderer itemSetParam:self->items[FUNamaHandleTypeBeauty] withName:param.mParam value:@(param.mValue)];
               }
           }else if (param.type == FUDataTypeFilter){
               if(self->items[FUNamaHandleTypeBeauty] == 0){
                   [self loadFilter];
               }
               
               int handle = [[FUManager shareManager] getHandleAboutType:FUNamaHandleTypeBeauty];
               [FURenderer itemSetParam:handle withName:@"filter_name" value:[param.mParam lowercaseString]];
               [FURenderer itemSetParam:handle withName:@"filter_level" value:@(param.mValue)]; //滤镜程度

           }else if (param.type == FUDataTypeMakeup){
               self->_currentType = FUDataTypeMakeup;
               if (self->items[FUNamaHandleTypeMakeup] == 0) {
                   NSString *path = [[NSBundle mainBundle] pathForResource:@"face_makeup.bundle" ofType:nil];
                   self->items[FUNamaHandleTypeMakeup] = [FURenderer itemWithContentsOfFile:path];
                   [FURenderer itemSetParam:self->items[FUNamaHandleTypeMakeup] withName:@"is_makeup_on" value:@(1)];

               }
               
               if ([param.mParam isEqualToString:self->oldMakeup]) {
                   [FURenderer itemSetParam:self->items[FUNamaHandleTypeMakeup] withName:@"makeup_intensity" value:@(param.mValue)];
                   return ;
               }
               
               /* 切换bundle,清空当前bind道具 */
               [FURenderer itemSetParam:self->items[FUNamaHandleTypeMakeup] withName:@"is_clear_makeup" value:@(1)];
               NSString *path = [[NSBundle mainBundle] pathForResource:param.mParam ofType:@"bundle"];
               int subHandle = [FURenderer itemWithContentsOfFile:path];
               
               if (oldHandle) {//存在旧美妆道具，先销毁
                   [FURenderer unBindItems:self->items[FUNamaHandleTypeMakeup] items:&oldHandle itemsCount:1];
                    [FURenderer destroyItem:oldHandle];
                    oldHandle = 0;
               }
               self->oldMakeup = param.mParam;
               /* 设置妆容程度值 */
               int aaa = [FURenderer itemSetParam:self->items[FUNamaHandleTypeMakeup] withName:@"makeup_intensity" value:@(param.mValue)];
               
               NSLog(@"------aaa = %d",aaa);
               [FURenderer bindItems:self->items[FUNamaHandleTypeMakeup] items:&subHandle itemsCount:1];
                oldHandle = subHandle;
               
           }else if (param.type == FUDataTypebody){
               self->_currentType = FUDataTypebody;
               if (self->items[FUNamaHandleTypeBodySlim] == 0) {
                   NSString *path = [[NSBundle mainBundle] pathForResource:@"body_slim.bundle" ofType:nil];
                   self->items[FUNamaHandleTypeBodySlim] = [FURenderer itemWithContentsOfFile:path];
                   [FURenderer itemSetParam:self->items[FUNamaHandleTypeBodySlim] withName:@"Debug" value:@(0)];
               }
               [FURenderer itemSetParam:self->items[FUNamaHandleTypeBodySlim] withName:@"filter_name" value:[param.mParam lowercaseString]];
               [FURenderer itemSetParam:self->items[FUNamaHandleTypeBodySlim] withName:param.mParam value:@(param.mValue)]; //滤镜程度
               
               NSLog(@"设置type(%lu)----参数（%@）-----值（%lf",(unsigned long)FUNamaHandleTypeBodySlim,param.mParam ,param.mValue);
           }else if (param.type == FUDataTypeStrick){
               self->_currentType = FUDataTypeStrick;
               int destoryItem = self->items[FUNamaHandleTypeItem];
               
               NSString *path = [[NSBundle mainBundle] pathForResource:param.mParam ofType:@"bundle"];
               int newHandle = [FURenderer itemWithContentsOfFile:path];
               
               self->items[FUNamaHandleTypeItem] = newHandle;
               
              /**后销毁老道具句柄*/
              if (destoryItem != 0){
                  NSLog(@"faceunity: destroy item");
                  [FURenderer destroyItem:destoryItem];
              }

           }
        
        [[FURenderer shareRenderer] setBackCurrentContext];
    });

}


- (void)loadFilter{
    dispatch_async(_asyncLoadQueue, ^{
        if (self->items[FUNamaHandleTypeBeauty] == 0) {
                NSString *path = [[NSBundle mainBundle] pathForResource:@"face_beautification.bundle" ofType:nil];
            self->items[FUNamaHandleTypeBeauty] = [FURenderer itemWithContentsOfFile:path];

                /* 默认精细磨皮 */
            [FURenderer itemSetParam:self->items[FUNamaHandleTypeBeauty] withName:@"heavy_blur" value:@(0)];
            [FURenderer itemSetParam:self->items[FUNamaHandleTypeBeauty] withName:@"blur_type" value:@(2)];
                /* 默认自定义脸型 */
            [FURenderer itemSetParam:self->items[FUNamaHandleTypeBeauty] withName:@"face_shape" value:@(4)];
            [FURenderer itemSetParam:self->items[FUNamaHandleTypeBeauty] withName:@"eye_bright" value:@(0.5)];
                [self setBeautyParameters];

        }
    });
}


- (void)setBeautyParameters{
    
    NSArray *skinParams = [FUDateHandle setupSkinData];
    NSArray *shapeParams = [FUDateHandle setupShapData];
  
    
    for (FUBeautyParam *modle in skinParams){
        if ([modle.mParam isEqualToString:@"blur_level"]) {
            [FURenderer itemSetParam:items[FUNamaHandleTypeBeauty] withName:modle.mParam value:@(modle.mValue * 6)];
        }else{
            [FURenderer itemSetParam:items[FUNamaHandleTypeBeauty] withName:modle.mParam value:@(modle.mValue)];
        }
    }
    
    for (FUBeautyParam *modle in shapeParams){
         [FURenderer itemSetParam:items[FUNamaHandleTypeBeauty] withName:modle.mParam value:@(modle.mValue)];
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
    
}

//-(void)getNeedRenderItems:()


#pragma mark -  render
/**将道具绘制到pixelBuffer*/
- (CVPixelBufferRef)renderItemsToPixelBuffer:(CVPixelBufferRef)pixelBuffer{
    if ([self isDeviceMotionChange]) {
        fuSetDefaultRotationMode(self.deviceOrientation);
            /* 解决旋转屏幕效果异常 onCameraChange*/
        [FURenderer onCameraChange];
    }
    
    if (_isRender) {
        /* 由于 rose 妆可能会镜像，下面代码对妆容做镜像翻转 */
         int temp = self.flipx? 1:0;
        [FURenderer itemSetParam:items[FUNamaHandleTypeMakeup] withName:@"is_flip_points" value:@(temp)];
        
        /* 美妆，美体，贴纸 性能问题不共用 */
        static int readerItems[2] = {0};
        readerItems[0] = items[FUNamaHandleTypeBeauty];
        if (_currentType == FUDataTypeMakeup) {
            readerItems[1] = items[FUNamaHandleTypeMakeup];
        }
        if (_currentType == FUDataTypeStrick) {
            readerItems[1] = items[FUNamaHandleTypeItem];
        }
        if (_currentType == FUDataTypebody) {
            readerItems[1] = items[FUNamaHandleTypeBodySlim];
        }

        CVPixelBufferRef buffer = [[FURenderer shareRenderer] renderPixelBuffer:pixelBuffer withFrameId:frameID items:readerItems itemCount:2 flipx:_flipx];//flipx 参数设为YES可以使道具做水平方向的镜像翻转
        frameID += 1;
    }

    
    return pixelBuffer;
}

/**处理YUV*/
- (void)processFrameWithY:(void*)y U:(void*)u V:(void*)v yStride:(int)ystride uStride:(int)ustride vStride:(int)vstride FrameWidth:(int)width FrameHeight:(int)height {
    if ([self isDeviceMotionChange]) {
        fuSetDefaultRotationMode(self.deviceOrientation);
        /* 解决旋转屏幕效果异常 onCameraChange*/
        [FURenderer onCameraChange];
    }
    
    /* 由于 rose 妆可能会镜像，下面代码对妆容做镜像翻转 */
     int temp = self.flipx? 0:1;
    [FURenderer itemSetParam:items[FUNamaHandleTypeMakeup] withName:@"is_flip_points" value:@(temp)];
    
    /* 美妆，美体，贴纸 性能问题不共用 */
    static int readerItems[2] = {0};
    readerItems[0] = items[FUNamaHandleTypeBeauty];
    if (_currentType == FUDataTypeMakeup) {
        readerItems[1] = items[FUNamaHandleTypeMakeup];
    }
    if (_currentType == FUDataTypeStrick) {
        readerItems[1] = items[FUNamaHandleTypeItem];
    }
    if (_currentType == FUDataTypebody) {
        readerItems[1] = items[FUNamaHandleTypeBodySlim];
    }
    
    [[FURenderer shareRenderer] renderFrame:y u:u  v:v  ystride:ystride ustride:ustride vstride:vstride width:width height:height frameId:frameID items:readerItems itemCount:2];
    frameID ++ ;
}

/**将道具绘制到pixelBuffer*/

- (int)renderItemWithTexture:(int)texture Width:(int)width Height:(int)height {
    if ([self isDeviceMotionChange]) {
        // 设置识别方向
        fuSetDefaultRotationMode(self.deviceOrientation);
        /* 解决旋转屏幕效果异常 onCameraChange*/
        [FURenderer onCameraChange];
    }
    [self prepareToRender];
    
    /* 由于 rose 妆可能会镜像，下面代码对妆容做镜像翻转 */
     int temp = self.flipx? 1:0;
    [FURenderer itemSetParam:items[FUNamaHandleTypeMakeup] withName:@"is_flip_points" value:@(temp)];
    
    /* 美妆，美体，贴纸 性能问题不共用 */
    static int readerItems[2] = {0};
    readerItems[0] = items[FUNamaHandleTypeBeauty];
    if (_currentType == FUDataTypeMakeup) {
        readerItems[1] = items[FUNamaHandleTypeMakeup];
    }
    if (_currentType == FUDataTypeStrick) {
        readerItems[1] = items[FUNamaHandleTypeItem];
    }
    if (_currentType == FUDataTypebody) {
        readerItems[1] = items[FUNamaHandleTypeBodySlim];
    }
    
    if(self.flipx){
       fuRenderItemsEx2(FU_FORMAT_RGBA_TEXTURE,&texture, FU_FORMAT_RGBA_TEXTURE, &texture, width, height, frameID, readerItems, 2, NAMA_RENDER_OPTION_FLIP_X | NAMA_RENDER_FEATURE_FULL, NULL);
    }else{
       fuRenderItemsEx(FU_FORMAT_RGBA_TEXTURE, &texture, FU_FORMAT_RGBA_TEXTURE, &texture, width, height, frameID, readerItems, 2) ;
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


#pragma mark -  重力感应
-(void)setupDeviceMotion{
    // 初始化陀螺仪
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.accelerometerUpdateInterval = 0.5;// 1s刷新一次
    
    if ([self.motionManager isDeviceMotionAvailable]) {
       [self.motionManager startAccelerometerUpdates];
         [self.motionManager startDeviceMotionUpdates];
    }
}

-(BOOL)isDeviceMotionChange{
//    if (![FURenderer isTracking]) {
        CMAcceleration acceleration = self.motionManager.accelerometerData.acceleration ;
        int orientation = 0;
        if (acceleration.x >= 0.75) {
            orientation = 3;
        } else if (acceleration.x <= -0.75) {
            orientation = 1;
        } else if (acceleration.y <= -0.75) {
            orientation = 0;
        } else if (acceleration.y >= 0.75) {
            orientation = 2;
        }
    
        if (self.deviceOrientation != orientation) {
            self.deviceOrientation = orientation ;
            NSLog(@"屏幕方向-----%d",self.deviceOrientation);

            return YES;
        }
//    }
    return NO;
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
