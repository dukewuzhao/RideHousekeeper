//
//  BindingHelpViewController.m
//  RideHousekeeper
//
//  Created by Apple on 2020/4/1.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import "BindingHelpViewController.h"

@interface BindingHelpViewController ()

@end

@implementation BindingHelpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupNavView];
    [self setupMainView];
}

- (void)setupNavView{
    [super setupNavView];
    self.navView.showBottomLabel = NO;
    [self.navView.centerButton setTitle:@"绑定帮助" forState:UIControlStateNormal];
    [self.navView.centerButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.navView.backgroundColor = [UIColor whiteColor];
    @weakify(self);
    [self.navView.leftButton setImage:[UIImage imageNamed:@"icon_add_back"] forState:UIControlStateNormal];
    self.navView.leftButtonBlock = ^{
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    };
}

-(void)setupMainView{
    
    UILabel *firstLab = [[UILabel alloc] init];
    firstLab.text = @"为什么搜索不到车辆？";
    firstLab.textColor = [QFTools colorWithHexString:@"#333333"];
    firstLab.font = FONT_PINGFAN(17);
    [self.view addSubview:firstLab];
    [firstLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(20);
        make.top.equalTo(self.navView.mas_bottom).offset(6);
        make.right.equalTo(self.view);
        make.height.mas_equalTo(24);
    }];
    
    UILabel *firstDetailLab = [[UILabel alloc] init];
    firstDetailLab.text = @"1.确认您的车辆是否是智能款，骑管家APP只支持智能款绑定，非智能款无法搜索到车辆；\n2.手机蓝牙异常会导致搜索不到车辆，您可以开关蓝牙或关闭APP后再重新打开APP进行搜索，必要时可以重启手机后再试。";
    firstDetailLab.numberOfLines = 0;
    firstDetailLab.textColor = [QFTools colorWithHexString:@"#666666"];
    firstDetailLab.font = FONT_PINGFAN(14);
    [self.view addSubview:firstDetailLab];
    [firstDetailLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(firstLab);
        make.top.equalTo(firstLab.mas_bottom).offset(5);
        make.right.equalTo(firstLab);
    }];
    
    UILabel *secondLab = [[UILabel alloc] init];
    secondLab.text = @"为什么搜索到车辆后绑定失败？";
    secondLab.textColor = [QFTools colorWithHexString:@"#333333"];
    secondLab.font = FONT_PINGFAN(17);
    [self.view addSubview:secondLab];
    [secondLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(firstLab);
        make.top.equalTo(firstDetailLab.mas_bottom).offset(6);
        make.right.equalTo(firstLab);
        make.height.mas_equalTo(24);
    }];
    
    UILabel *secondDetailLab = [[UILabel alloc] init];
    secondDetailLab.text = @"绑定车辆需要手机网络和蓝牙跟车辆进行通信，当网络或蓝牙信号不稳定时可能通信异常导致绑定失败。您可尝试开关蓝牙或其它手机绑定，必要时可以重启手机后再试。";
    secondDetailLab.numberOfLines = 0;
    secondDetailLab.textColor = [QFTools colorWithHexString:@"#666666"];
    secondDetailLab.font = FONT_PINGFAN(14);
    [self.view addSubview:secondDetailLab];
    [secondDetailLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(firstLab);
        make.top.equalTo(secondLab.mas_bottom).offset(5);
        make.right.equalTo(firstLab);
    }];
    /*
    UILabel *thirdLab = [[UILabel alloc] init];
    thirdLab.text = @"钥匙激活和扫码绑定有什么区别？";
    thirdLab.textColor = [QFTools colorWithHexString:@"#333333"];
    thirdLab.font = FONT_PINGFAN(17);
    [self.view addSubview:thirdLab];
    [thirdLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(firstLab);
        make.top.equalTo(secondDetailLab.mas_bottom).offset(6);
        make.right.equalTo(firstLab);
        make.height.mas_equalTo(24);
    }];
    
    UILabel *thirdDetailLab = [[UILabel alloc] init];
    thirdDetailLab.text = @"如您车是智能款，您可以钥匙激活绑定车辆，也可以扫描二维码后再要是激活绑定车辆；\n如您的车不是智能款，只有GPS设备时您无法钥匙激活搜索到车辆，您可以扫描二维码来绑定GPS设备。";
    thirdDetailLab.numberOfLines = 0;
    thirdDetailLab.textColor = [QFTools colorWithHexString:@"#666666"];
    thirdDetailLab.font = FONT_PINGFAN(14);
    [self.view addSubview:thirdDetailLab];
    [thirdDetailLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(firstLab);
        make.top.equalTo(thirdLab.mas_bottom).offset(5);
        make.right.equalTo(firstLab);
    }];
     */
}

@end
