//
//  TRTCViewController.m
//  TRTCSimpleDemo
//
//  Created by support on 2020/9/29.
//


/**
 * TRTC视频通话的入口页面（可以设置房间id和用户id）
 *
 * TRTC视频通话是基于房间来实现的，通话的双方要进入一个相同的房间id才能进行视频通话
 */

#import "TRTCViewController.h"

#import <Masonry/Masonry.h>

#import "TRTRCRoomViewController.h"


@interface TRTCViewController ()

/// 房间号
@property(nonatomic, strong) UITextField *roomIdTF;

/// 用户名
@property(nonatomic, strong) UITextField *userIdTF;


@end

@implementation TRTCViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    [self setupUI];
}

/// 布局子控件
- (void)setupUI{

    
    UILabel *tipsRoomLbl = [[UILabel alloc] init];
    tipsRoomLbl.text = @"请输入房间号:";
    tipsRoomLbl.font = [UIFont systemFontOfSize:16];
    tipsRoomLbl.textColor = [UIColor greenColor];
    
    UITextField *roomIdTF = [[UITextField alloc] init];
    roomIdTF.text = @"1256732";
    roomIdTF.textColor = [UIColor blackColor];
    roomIdTF.font = [UIFont systemFontOfSize:14];
    roomIdTF.backgroundColor = [UIColor whiteColor];
    roomIdTF.borderStyle = UITextBorderStyleRoundedRect;
    roomIdTF.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, 0)];
    roomIdTF.leftViewMode = UITextFieldViewModeAlways;
    
    [self.view addSubview:tipsRoomLbl];
    [self.view addSubview:roomIdTF];
    
    UILabel *tipsUserLbl = [[UILabel alloc] init];
    tipsUserLbl.text = @"请输入用户名:";
    tipsUserLbl.font = [UIFont systemFontOfSize:16];
    tipsUserLbl.textColor = [UIColor greenColor];
    
    UITextField *userIdTF = [[UITextField alloc] init];
    userIdTF.text = [NSString stringWithFormat:@"%.0f",CACurrentMediaTime() * 1000];
    userIdTF.textColor = [UIColor blackColor];
    userIdTF.font = [UIFont systemFontOfSize:14];
    userIdTF.backgroundColor = [UIColor whiteColor];
    userIdTF.borderStyle = UITextBorderStyleRoundedRect;
    userIdTF.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, 0)];
    userIdTF.leftViewMode = UITextFieldViewModeAlways;
    
    [self.view addSubview:tipsUserLbl];
    [self.view addSubview:userIdTF];
    
    UIButton *joinRoomBtn = [[UIButton alloc] init];
    [joinRoomBtn setTitle:@"进入房间" forState:(UIControlStateNormal)];
    [joinRoomBtn setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    joinRoomBtn.titleLabel.font = [UIFont systemFontOfSize:20];
    joinRoomBtn.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:joinRoomBtn];
    
    
    [tipsRoomLbl mas_makeConstraints:^(MASConstraintMaker *make) {

        if (@available(iOS 11.0, *)) {
           
            make.top.mas_equalTo(self.view.mas_safeAreaLayoutGuideTop)
            .mas_offset(80);
            make.left.mas_equalTo(self.view.mas_safeAreaLayoutGuideLeft)
            .mas_offset(32);
            make.right.mas_equalTo(self.view.mas_safeAreaLayoutGuideRight)
            .mas_offset(-32);
            
        } else {
            
            make.top.mas_equalTo(80);
            make.left.mas_equalTo(32);
            make.right.mas_equalTo(-32);
        }
    
        make.height.mas_equalTo(34);
        
    }];
    
    [roomIdTF mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(tipsRoomLbl.mas_bottom);
        make.left.right.mas_equalTo(tipsRoomLbl);
        make.height.mas_equalTo(34);
            
    }];
    
    [tipsUserLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            
        make.top.mas_equalTo(roomIdTF.mas_bottom)
        .mas_offset(22);
        make.left.right.mas_equalTo(roomIdTF);
        make.height.mas_equalTo(34);
        
    }];

    [userIdTF mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(tipsUserLbl.mas_bottom);
        make.left.right.mas_equalTo(tipsUserLbl);
        make.height.mas_equalTo(34);
            
    }];
    
    [joinRoomBtn mas_makeConstraints:^(MASConstraintMaker *make) {
      
        if (@available(iOS 11.0, *)) {
            
            make.left.mas_equalTo(self.view.mas_safeAreaLayoutGuideLeft)
            .mas_offset(32);
            make.right.mas_equalTo(self.view.mas_safeAreaLayoutGuideRight)
            .mas_offset(-32);
            make.bottom.mas_equalTo(self.view.mas_safeAreaLayoutGuideBottom)
            .mas_offset(-62);
            
        } else {
            
            make.left.mas_equalTo(32);
            make.right.mas_equalTo(-32);
            make.bottom.mas_equalTo(-62);
        }
    
        make.height.mas_equalTo(44);
        
    }];
    
    self.roomIdTF = roomIdTF;
    self.userIdTF = userIdTF;
    
    [joinRoomBtn addTarget:self action:@selector(joinRoomBtnClick) forControlEvents:(UIControlEventTouchUpInside)];
    
}


/// 进入房间
- (void)joinRoomBtnClick{

    TRTRCRoomViewController *roomVC = [[TRTRCRoomViewController alloc] init];
    NSString *userId = [NSString stringWithFormat:@"%.0f",CACurrentMediaTime() * 1000];
    roomVC.roomId = self.roomIdTF.text.length ? self.roomIdTF.text : @"1256732";
    roomVC.userId = self.userIdTF.text.length ? self.userIdTF.text : userId;
    [self.navigationController pushViewController:roomVC animated:YES];
    
}



/// 点击屏幕其他地方,隐藏键盘
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    [self.view endEditing:YES];
    
}

@end
