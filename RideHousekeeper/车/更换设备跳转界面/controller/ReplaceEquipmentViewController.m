//
//  ReplaceEquipmentViewController.m
//  RideHousekeeper
//
//  Created by Apple on 2020/4/24.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import "ReplaceEquipmentViewController.h"

@interface ReplaceEquipmentViewController ()
@property (nonatomic,assign) BindingType bindingType;
@end

@implementation ReplaceEquipmentViewController

-(void)setChangeDeviceType:(BindingType)type{
    _bindingType = type;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[APPStatusManager sharedManager] setChangeDeviceType:BindingBike];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupNavView];
    [self setupView];
}

- (void)setupNavView{
    [super setupNavView];
    self.navView.backgroundColor = [UIColor whiteColor];
    self.navView.showBottomLabel = NO;
    @weakify(self);
    [self.navView.leftButton setImage:[UIImage imageNamed:@"icon_add_back"] forState:UIControlStateNormal];
    self.navView.leftButtonBlock = ^{
        @strongify(self);
        [self.navigationController popToRootViewControllerAnimated:YES];
    };
}
-(void)setupView{
    
    UILabel *topLab = [[UILabel alloc] init];
    topLab.numberOfLines = 0;
    topLab.font = FONT_PINGFAN_BOLD(20);
    topLab.textColor = [UIColor blackColor];
    topLab.textAlignment = NSTextAlignmentCenter;
    if (_bindingType == BindingChangeECU) {
        topLab.text = @"中控更新完成";
    }else if (_bindingType == BindingChangeECUFail){
        topLab.text = @"中控更新失败";
    }else if (_bindingType == BindingChangeGPS){
        topLab.text = @"定位器更新完成";
    }else if (_bindingType == BindingChangeGPSFail){
        topLab.text = @"定位器更新失败";
    }else{
        topLab.text = @"定位器更新完成";
    }
    
    [self.view addSubview:topLab];
    [topLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.navView.mas_bottom).offset(20);
    }];
    
    UIImageView *headView = [[UIImageView alloc] init];
    if (_bindingType == BindingChangeGPS || _bindingType == BindingChangeECU) {
        headView.image = [UIImage imageNamed:@"icon_chenge_device_success"];
    }else{
        headView.image = [UIImage imageNamed:@"icon_chenge_device_fail"];
    }
    
    [self.view addSubview:headView];
    [headView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(topLab.mas_bottom).offset(30);
        make.centerX.equalTo(self.view);
    }];
    
    UILabel *midLab = [[UILabel alloc] init];
    midLab.numberOfLines = 0;
    midLab.font = FONT_PINGFAN(14);
    midLab.textAlignment = NSTextAlignmentCenter;
    midLab.textColor = [UIColor blackColor];
    
    if (_bindingType == BindingChangeGPS || _bindingType == BindingChangeECU) {
        midLab.text = @"请检查车辆\n手机连接及遥控是否正常\n定位器功能是否正常\n如有相关配件请立即重新配置\n如有车辆装有指纹请重新录入";
    }else{
        midLab.text = @"请检查中控类型是否一致\n手机是否离车辆足够近\n手机网络和蓝牙信号是否良好\n多次失败请尝试重启网络或蓝牙后重试";
    }
    [self.view addSubview:midLab];
    [midLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(headView.mas_bottom).offset(30);
    }];
    
    UIButton *completeBtn = [[UIButton alloc] init];
    [completeBtn setTitle:@"完成" forState:UIControlStateNormal];
    [completeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    completeBtn.backgroundColor = [QFTools colorWithHexString:MainColor];
    [completeBtn.layer setCornerRadius:10.0]; // 切圆角
    completeBtn.titleLabel.font = FONT_PINGFAN(18);
    [self.view addSubview:completeBtn];
    [completeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-100);
        make.size.mas_equalTo(CGSizeMake(ScreenWidth - 150, 45));
    }];
    @weakify(self);
    [[completeBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
}

@end
