//
//  ViewController.m
//  TRTCSimpleDemo
//
//  Created by support on 2020/9/29.
//

#import "ViewController.h"

#import "TRTCViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"TRTC视频通话";
}


/// 进入视频通话
/// @param sender 视频通话按钮
- (IBAction)onTRTCVideoClick:(UIButton *)sender {
    
    TRTCViewController *videoVC = [[TRTCViewController alloc] init];
    [self.navigationController pushViewController:videoVC animated:YES];
    
}


@end
