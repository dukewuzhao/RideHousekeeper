//
//  BindingGPSViewController.m
//  RideHousekeeper
//
//  Created by Apple on 2018/3/13.
//  Copyright © 2018年 Duke Wu. All rights reserved.
//

#import "GPSActivationViewController.h"
#import "GPSHeadView.h"
#import "GPSFootView.h"
#import "GPSDetectionProcessingView.h"
#import "bindingDeviceViewModel.h"
#import "SearchBleModel.h"
#import "Manager.h"
@interface GPSActivationViewController ()

@property (nonatomic,strong) UILabel *mobileTitle;
@property (nonatomic,strong) YYLabel *promptTitle;
@property (nonatomic,strong) GPSHeadView *headView;
@property (nonatomic,strong) GPSFootView *footview;
@property (nonatomic,strong) BindingDeviceViewModel *bindingDeviceViewModel;
@property(nonatomic,strong) BikeModel *bikeModel;
@property(nonatomic,strong) PeripheralModel *peripheralModel;
@end

@implementation GPSActivationViewController

NSInteger checkTime = 0;
NSInteger scanTime = 0;
NSInteger detectionTimes = 0;//每次检测提示失败的次数
NSInteger currentDetectedStep = 0;//检测到第几步

-(BindingDeviceViewModel *)bindingDeviceViewModel{
    if (!_bindingDeviceViewModel) {
        _bindingDeviceViewModel = [[BindingDeviceViewModel alloc] init];
    }
    return _bindingDeviceViewModel;
}

-(void)setpGPSParameters:(BikeModel *)model{
    _bikeModel = model;
     _peripheralModel = [[LVFmdbTool queryPeripheraData:[NSString stringWithFormat:@"SELECT * FROM periphera_modals WHERE type = '%d' AND bikeid = '%zd'",4,_bikeModel.bikeid]] firstObject];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupNavView];
    [self setupMainView];
}

- (void)setupNavView{
    [super setupNavView];
    self.navView.showBottomLabel = NO;
    self.navView.backgroundColor = [UIColor whiteColor];
    @weakify(self);
    [self.navView.leftButton setImage:[UIImage imageNamed:@"stop_gps_binding"] forState:UIControlStateNormal];
    self.navView.leftButtonBlock = ^{
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    };
}

-(void)setupMainView{
    
    UILabel *titleLab = [[UILabel alloc] init];
    titleLab.font = FONT_PINGFAN_BOLD(18);
    titleLab.textColor = [QFTools colorWithHexString:@"111111"];
    titleLab.text = _isOnlyGPSActivation? @"车辆首次初始化": @"定位器检测";
    [self.view addSubview:titleLab];
    [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.navView.mas_bottom).offset(10);
        make.centerX.equalTo(self.view);
        make.height.mas_equalTo(25);
    }];
    
    _headView = [[GPSHeadView alloc] init];
    [self.view addSubview:_headView];
    [_headView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLab.mas_bottom).offset(30);
        make.left.equalTo(self.view).offset(84);
        make.right.equalTo(self.view).offset(-84);
        make.height.equalTo(_headView.mas_width).multipliedBy(1.0);
    }];
    
    _mobileTitle = [[UILabel alloc] init];
    _mobileTitle.textColor = [UIColor blackColor];
    _mobileTitle.font = FONT_PINGFAN(16);
    _mobileTitle.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_mobileTitle];
    [_mobileTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_headView.mas_bottom).offset(20);
        make.centerX.equalTo(self.view);
        make.left.equalTo(self.view).offset(10);
    }];
    
    _promptTitle = [[YYLabel alloc] init];
    _promptTitle.textColor = [QFTools colorWithHexString:@"#333333"];
    _promptTitle.font = FONT_PINGFAN(14);
    _promptTitle.textAlignment = NSTextAlignmentCenter;
    //_promptTitle.textVerticalAlignment = YYTextVerticalAlignmentCenter;
    _promptTitle.numberOfLines = 0;
    _promptTitle.preferredMaxLayoutWidth = ScreenWidth - 20; //设置最大的宽度
    [self.view addSubview:_promptTitle];
    [_promptTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_mobileTitle.mas_bottom).offset(10);
        make.centerX.equalTo(self.view);
        make.left.equalTo(self.view).offset(10);
    }];
   
    _footview = [[GPSFootView alloc] init];
    _footview.backgroundColor = [UIColor whiteColor];
    @weakify(self);
    
    _footview.GPSScanTag = ^(NSInteger tag) {
        
        @strongify(self);
        if (tag == 0) {
            currentDetectedStep = tag;
            self.mobileTitle.text = @"正在初始化设置...";
            self.promptTitle.text = @"初始化过程请尽量靠近车辆";
            [self.headView.gpsImageView stopAnimating];
            YYImage *image = [YYImage imageNamed:@"gps_network_activation.gif"];
            self.headView.gpsImageView.image = image;
            [self.headView.gpsImageView startAnimating];
            
            if ([QFTools isBlankString:self.bikeModel.sn]) {
                
                if ([CommandDistributionServices isConnect]) {
                    [self CommunicateWithGPS:PureGPSMode];
                }else{
                    [self startScanGPS:self.peripheralModel.mac];
                }
                
            }else{
                
                if ([CommandDistributionServices isConnect]) {
                    [self connectGPSByMac:self.peripheralModel.mac];
                }else{
                    RACSignal * deallocSignal = [self rac_signalForSelector:@selector(connectGPSByMac:)];
                    [[[[NSNOTIC_CENTER rac_addObserverForName:KNotification_ConnectStatus object:nil] takeUntil:deallocSignal] timeout:10 onScheduler:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
                        @strongify(self);
                        NSNotification *userInfo = x;
                        if (![userInfo.object boolValue]) {
                            [self connectGPSByMac:self.peripheralModel.mac];
                        }
                    }error:^(NSError *error) {
                        @strongify(self);
                        if(self.footview.GPSScanTag) self.footview.GPSScanTag(6);
                    }];
                }
            }
            
        }else if (tag == 1){
            
            currentDetectedStep = tag;
            self.mobileTitle.text = @"正在查询设备网络状态";
            if (detectionTimes == 0) {
                self.promptTitle.text = @"请移动车辆到良好网络状态，确保周边网络状态正常";
            }else if (detectionTimes == 1){
                self.promptTitle.text = @"请尽量确保周边网络状况良好，您也可以移动车辆到不同的位置进行查询网络";
            }else if (detectionTimes >= 2){
                self.promptTitle.text = @"如确认周边网络良好，移动到其它位置也一直查询不到网络您可以尝试重启设备";
            }
            
            if ([QFTools isBlankString:self.bikeModel.sn] && ![CommandDistributionServices isConnect]) {
                [self startScanGPS:self.peripheralModel.mac];
            }else{
                [self detectNetworkConnectionStatus];
            }
            
        }else if (tag == 2){
            
            currentDetectedStep = tag;
            self.mobileTitle.text = @"正在搜索设备定位卫星信号";
            
            if (detectionTimes == 0) {
                self.promptTitle.text = @"请移动车辆到无遮挡区域，避免车辆在室内或地下室区域";
            }else if (detectionTimes == 1){
                self.promptTitle.text = @"请确认车辆处于空旷位置，无建筑物或其它物体遮挡，也可以移动车辆到空旷位置尝试";
            }else if (detectionTimes >= 2){
                self.promptTitle.text = @"如确认无建筑物遮挡也移动车辆到了不同位置仍搜不到车辆，您可以尝试重启设备";
            }
            
            if ([QFTools isBlankString:self.bikeModel.sn] && ![CommandDistributionServices isConnect]) {
                [self startScanGPS:self.peripheralModel.mac];
            }else{
                [self detectSatelliteCommunicationStatus];
            }
            
        }else if (tag == 3){
            NSLog(@"网络故障");
            GPSDetectionProcessingView *faildView = [[GPSDetectionProcessingView alloc] init];
            faildView.headView.image = [UIImage imageNamed:@"network_calibration_failed_icon"];
            faildView.mobileTitle.text = @"查询设备SIM卡网络异常";
            @weakify(faildView);
            
            if (detectionTimes == 0) {
               faildView.promptTitle.text = @"请移动车辆到良好网络状态，确保周边网络状态正常";
            }else if (detectionTimes == 1){
                faildView.promptTitle.text = @"请尽量确保周边网络状况良好，您也可以移动车辆到不同的位置进行查询网络";
            }else if (detectionTimes >= 2){
                NSMutableAttributedString *one = [[NSMutableAttributedString alloc] initWithString:@"如确认周边网络良好，移动到其它位置也一直查询不到网络您可以尝试重启设备"];
                one.yy_font = FONT_PINGFAN(14);
                one.yy_color = [QFTools colorWithHexString:MainColor];
                [one yy_setTextHighlightRange:NSMakeRange(one.length - 4, 4) color:[QFTools colorWithHexString:MainColor] backgroundColor:[UIColor whiteColor] tapAction:^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect){
                    @strongify(self);
                    LoadView *loadview = [LoadView sharedInstance];
                    loadview.protetitle.text = @"重启设备中";
                    [loadview show];
                    
                    if ([QFTools isBlankString:self.bikeModel.sn] && ![CommandDistributionServices isConnect]) {
                        [CommandDistributionServices connectPeripheralByUUIDString:[USER_DEFAULTS objectForKey:Key_DeviceUUID]];
                        
                        [[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:KNotification_ConnectStatus object:nil] takeUntil:[self rac_signalForSelector:@selector(restOutTime:)]] timeout:10 onScheduler:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
                            @strongify(self);
                            NSNotification *userInfo = x;
                            if (![userInfo.object boolValue]) {
                                
                                [self restOutTime:nil];
                                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                    @strongify(self);
                                    @strongify(faildView);
                                    [loadview hide];
                                    detectionTimes = 0;
                                    if(self.footview.GPSScanTag) self.footview.GPSScanTag(0);
                                    [faildView removeFromSuperview];
                                });
                            }
                        }error:^(NSError *error) {
                            [loadview hide];
                            [SVProgressHUD showSimpleText:@"重启车辆定位器超时"];
                        }];
                        
                    }else{
                        [self restOutTime:nil];
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            @strongify(self);
                            @strongify(faildView);
                            [loadview hide];
                            detectionTimes = 0;
                            if(self.footview.GPSScanTag) self.footview.GPSScanTag(0);
                            [faildView removeFromSuperview];
                        });
                    }
                }];
                faildView.promptTitle.attributedText = one;
            }
            
            faildView.titleLab.text = @"定位器检测";
            [faildView.scanAgainBtn setTitle:@"重新检测" forState:UIControlStateNormal];
            [self.view addSubview:faildView];
            [faildView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.top.right.bottom.equalTo(self.view);
            }];
            @weakify(self);
            
            faildView.btnClick = ^{
                @strongify(self);
                [self.navigationController popViewControllerAnimated:YES];
            };
            
            faildView.restClick = ^{
                @strongify(self);
                @strongify(faildView);
                if(self.footview.GPSScanTag) self.footview.GPSScanTag(0);
                [faildView removeFromSuperview];
            };
            
        }else if (tag == 4){
            NSLog(@"卫星监测故障");
            GPSDetectionProcessingView *scanFaildView = [[GPSDetectionProcessingView alloc] init];
            scanFaildView.headView.image = [UIImage imageNamed:@"gps_device_not_found_icon"];
            scanFaildView.mobileTitle.text = @"搜索设备卫星信号异常";
            @weakify(self);
            @weakify(scanFaildView);
            if (detectionTimes == 0) {
               scanFaildView.promptTitle.text = @"请移动车辆到无遮挡区域，避免车辆在室内或地下室区域";
            }else if (detectionTimes == 1){
                scanFaildView.promptTitle.text = @"请确认车辆处于空旷位置，无建筑物或其它物体遮挡，也可以移动车辆到空旷位置尝试";
            }else if (detectionTimes >= 2){
                NSMutableAttributedString *one = [[NSMutableAttributedString alloc] initWithString:@"如确认无建筑物遮挡也移动车辆到了不同位置仍搜不到车辆，您可以尝试重启设备"];
                one.yy_font = FONT_PINGFAN(14);
                one.yy_color = [QFTools colorWithHexString:@"#333333"];
                
                [one yy_setTextHighlightRange:NSMakeRange(one.length - 4, 4) color:[QFTools colorWithHexString:MainColor] backgroundColor:[UIColor whiteColor] tapAction:^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect){
                    @strongify(self);
                    LoadView *loadview = [LoadView sharedInstance];
                    loadview.protetitle.text = @"重启设备中";
                    [loadview show];
                    
                    if ([QFTools isBlankString:self.bikeModel.sn] && ![CommandDistributionServices isConnect]) {
                        [CommandDistributionServices connectPeripheralByUUIDString:[USER_DEFAULTS objectForKey:Key_DeviceUUID]];
                        
                        [[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:KNotification_ConnectStatus object:nil] takeUntil:[self rac_signalForSelector:@selector(restOutTime:)]] timeout:10 onScheduler:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
                            @strongify(self);
                            NSNotification *userInfo = x;
                            if (![userInfo.object boolValue]) {
                                
                                [self restOutTime:nil];
                                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                    @strongify(self);
                                    @strongify(scanFaildView);
                                    [loadview hide];
                                    detectionTimes = 0;
                                    if(self.footview.GPSScanTag) self.footview.GPSScanTag(0);
                                    [scanFaildView removeFromSuperview];
                                });
                                        
                            }
                        }error:^(NSError *error) {
                            [loadview hide];
                            [SVProgressHUD showSimpleText:@"重启车辆定位器超时"];
                        }];
                        
                    }else{
                        [self restOutTime:nil];
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            @strongify(self);
                            @strongify(scanFaildView);
                            [loadview hide];
                            detectionTimes = 0;
                            if(self.footview.GPSScanTag) self.footview.GPSScanTag(0);
                            [scanFaildView removeFromSuperview];
                        });
                    }
                }];;
                scanFaildView.promptTitle.attributedText = one;
                
            }
            scanFaildView.titleLab.text = @"定位器检测";
            [scanFaildView.scanAgainBtn setTitle:@"重新检测" forState:UIControlStateNormal];
            [self.view addSubview:scanFaildView];
            [scanFaildView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.top.right.bottom.equalTo(self.view);
            }];
            
            scanFaildView.btnClick = ^{
                @strongify(self);
                [self.navigationController popViewControllerAnimated:YES];
            };
            
            scanFaildView.restClick = ^{
                @strongify(self);
                @strongify(scanFaildView);
                if(self.footview.GPSScanTag) self.footview.GPSScanTag(currentDetectedStep);
                [scanFaildView removeFromSuperview];
            };
            
        }else if (tag == 5){
            
            GPSDetectionProcessingView *successView = [[GPSDetectionProcessingView alloc] init];
            successView.headView.image = [UIImage imageNamed:@"network_calibration_completed_icon"];
            successView.promptTitle.text = @"请把车辆行到空旷地带，尝试骑行两圈后查看\n车辆定位和骑行轨迹是否正常";
            successView.titleLab.text = @"定位检测完成";
            [successView.scanAgainBtn setTitle:@"确定" forState:UIControlStateNormal];
            [self.view addSubview:successView];
            [successView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.top.right.bottom.equalTo(self.view);
            }];
            @weakify(self);
            successView.btnClick = ^{
                @strongify(self);
                [self.navigationController popViewControllerAnimated:YES];
            };
            successView.restClick = ^{
                @strongify(self);
                [self.navigationController popViewControllerAnimated:YES];
            };
        }else if (tag == 6){
            
            GPSDetectionProcessingView *faildView = [[GPSDetectionProcessingView alloc] init];
            faildView.headView.image = [UIImage imageNamed:@"network_calibration_failed_icon"];
            faildView.titleLab.text = self.isOnlyGPSActivation? @"车辆首次初始化": @"定位器检测";
            faildView.promptTitle.text = @"请检查手机网络和蓝牙信息是否良好，初始化过程请尽量靠近车辆";
            faildView.mobileTitle.text = @"车辆初始化超时";
            [faildView.scanAgainBtn setTitle:@"重新初始化" forState:UIControlStateNormal];
            [self.view addSubview:faildView];
            [faildView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.top.right.bottom.equalTo(self.view);
            }];
            @weakify(self);
            faildView.btnClick = ^{
                @strongify(self);
                [self.navigationController popViewControllerAnimated:YES];
            };
            @weakify(faildView);
            faildView.restClick = ^{
                @strongify(self);
                @strongify(faildView);
                if(self.footview.GPSScanTag) self.footview.GPSScanTag(0);
                [faildView removeFromSuperview];
            };
        }
        /*
        dispatch_async(dispatch_get_main_queue(), ^{
            // something
            [self.footview.checkTab reloadData];
        });
        */
    };
    /*
    [self.view addSubview:_footview];
    [_footview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_promptTitle.mas_bottom).offset(60);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    */
    self.footview.GPSScanTag(0);
}

-(void)startScanGPS:(NSString *)mac{
    @weakify(self);
    [self.bindingDeviceViewModel startblescan:DeviceGPSType :mac :15 scanCallBack:^(id dict) {
        @strongify(self);
        if ([dict[@"status"] intValue] == 0) {
            //扫描到设备
            
            SearchBleModel *model = dict[@"data"];
            [CommandDistributionServices connectPeripheralByUUIDString:model.peripher.identifier.UUIDString];
            [USER_DEFAULTS setObject: model.peripher.identifier.UUIDString forKey:Key_DeviceUUID];
            [USER_DEFAULTS synchronize];
            
            RACSignal * deallocSignal;
            switch (currentDetectedStep) {
                case 0:
                    deallocSignal = [self rac_signalForSelector:@selector(CommunicateWithGPS:)];
                    break;
                 case 1:
                    deallocSignal = [self rac_signalForSelector:@selector(detectNetworkConnectionStatus)];
                    break;
                case 2:
                    deallocSignal = [self rac_signalForSelector:@selector(detectSatelliteCommunicationStatus)];
                    break;
                default:
                    break;
            }
            
            [[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:KNotification_ConnectStatus object:nil] takeUntil:deallocSignal] timeout:10 onScheduler:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
                @strongify(self);
                NSNotification *userInfo = x;
                if (![userInfo.object boolValue]) {
                    //连接上设备
                    
                    switch (currentDetectedStep) {
                        case 0:
                            [self CommunicateWithGPS:PureGPSMode];
                            break;
                         case 1:
                            [self detectNetworkConnectionStatus];
                            break;
                        case 2:
                            [self detectSatelliteCommunicationStatus];
                            break;
                        default:
                            break;
                    }
                }
            }error:^(NSError *error) {
                @strongify(self);
                //未连接上设备，错误处理
                switch (currentDetectedStep) {
                    case 0:
                        if(self.footview.GPSScanTag) self.footview.GPSScanTag(6);
                        break;
                     case 1:
                        if(self.footview.GPSScanTag) self.footview.GPSScanTag(3);
                        break;
                    case 2:
                        if(self.footview.GPSScanTag) self.footview.GPSScanTag(4);
                        break;
                    default:
                        break;
                }
                
            }];
        }else{
            //未扫描到设备，错误处理
            switch (currentDetectedStep) {
                case 0:
                    if(self.footview.GPSScanTag) self.footview.GPSScanTag(6);
                    break;
                 case 1:
                    if(self.footview.GPSScanTag) self.footview.GPSScanTag(3);
                    break;
                case 2:
                    if(self.footview.GPSScanTag) self.footview.GPSScanTag(4);
                    break;
                default:
                    break;
            }
        }

    } countDown:^(NSInteger num) {
        //@strongify(self);
//        if (!self.isOnlyGPSActivation) {
//            self.mobileTitle.text = [NSString stringWithFormat:@"正在搜索连接车辆(%ds)",num];
//        }
    }];
}

-(void)connectGPSByMac:(NSString *)mac{
    @weakify(self);
    [CommandDistributionServices connectGPSByMac:mac data:^(id _Nonnull data) {
        @strongify(self);
        switch ([data intValue]) {
            case DeviceConnect:
                NSLog(@"GPS连接成功");
                [self CommunicateWithGPS:ECUMode];
                break;
                
            default:
                NSLog(@"GPS连接失败");
                if(self.footview.GPSScanTag) self.footview.GPSScanTag(6);
                break;
        }
        
        
    } error:^(CommandStatus status) {
        @strongify(self);
        switch (status) {
            case ConfigurationSuccess:
                NSLog(@"GPS连接发送成功");
                break;
                
            default:
                NSLog(@"GPS连接发送失败");
                if(self.footview.GPSScanTag) self.footview.GPSScanTag(6);
                break;
        }
    }];
}



-(void)CommunicateWithGPS:(GPSWorkingMode)mode{
    @weakify(self);
    [CommandDistributionServices GPSAuthentication:[NSString stringWithFormat:@"0%d01%@%@%@",mode,[QFTools completionStr:[ConverUtil ToHex:[QFTools getdata:@"userid"].intValue] needLength:8],[QFTools completionStr:[ConverUtil ToHex:_peripheralModel.ts] needLength:8],_peripheralModel.sign] data:^(id _Nonnull data) {
            @strongify(self);
            if ([data intValue] == 0) {
                NSLog(@"GPS鉴权成功");
                [self QueryGPSWorkMode:mode];
            }else{
                NSLog(@"GPS鉴权失败");
                if (self.footview.GPSScanTag) {
                    self.footview.GPSScanTag(6);
                }
            }
            
        } error:^(CommandStatus status) {
            @strongify(self);
            switch (status) {
                case SendSuccess:
                    NSLog(@"鉴权GPS发送成功");
                    break;
    
                default:
                    if (self.footview.GPSScanTag) {
                        self.footview.GPSScanTag(6);
                    }
                    break;
            }
        }];
}

-(void)QueryGPSWorkMode:(GPSWorkingMode)mode{
    @weakify(self);
    [CommandDistributionServices QueryGPSActivationStatus:QueryGPSWorkMode data:^(id  _Nonnull data) {
        @strongify(self);
        if ([data[@"status"] intValue] == 0){
            
            if ([data[@"data"] intValue] != mode) {
                NSLog(@"模式查询不符");
                [self SetGPSWorkMode:mode];
            }else{
                //模式正确不用设置
                NSLog(@"模式查询相符");
                [self StartGPSActivation];
            }
            
        }else{
            //失败处理
            NSLog(@"");
            if (self.footview.GPSScanTag) {
                self.footview.GPSScanTag(6);
            }
        }
        
    } error:^(CommandStatus status) {
        //失败处理
        @strongify(self);
        switch (status) {
            case SendSuccess:
                NSLog(@"查询GPS模式发送成功");
                break;

            default:
                if (self.footview.GPSScanTag) {
                    self.footview.GPSScanTag(6);
                }
                break;
        }
    }];
}

-(void)SetGPSWorkMode:(GPSWorkingMode)mode{
    @weakify(self);
    [CommandDistributionServices SetGPSWorkingMode:mode data:^(NSString * _Nonnull data) {
        @strongify(self);
        if ([data intValue] == 0) {
            NSLog(@"GPS设置工作模式成功");
            [self StartGPSActivation];
        }else{
            NSLog(@"GPS设置工作模式失败");
            if (self.footview.GPSScanTag) {
                self.footview.GPSScanTag(6);
            }
        }
        
    } error:^(CommandStatus status) {
        @strongify(self);
        switch (status) {
            case SendSuccess:
                NSLog(@"查询GPS发送成功");
                break;

            default:
                if (self.footview.GPSScanTag) {
                    self.footview.GPSScanTag(6);
                }
                break;
        }
    }];
    
}

-(void)StartGPSActivation{
    @weakify(self);
    [CommandDistributionServices QueryGPSActivationStatus:QueryGPSActivateMode data:^(id _Nonnull data) {
        @strongify(self);
        if ([data[@"status"] intValue] == 0 && [data[@"data"] intValue] == 1) {
            NSLog(@"GPS已经激活");
            
            NSMutableArray *ary = [LVFmdbTool queryPeripheralActivationStatusData:[NSString stringWithFormat:@"SELECT * FROM peripheralActivationStatus_models WHERE bikeid = '%zd'",self.bikeModel.bikeid]];
            
            if (ary.count > 0) {
                
                PeripheralActivationStatusModel *model = ary.firstObject;
                if (model.activationStatus == 0) {
                    [LVFmdbTool modifyData:[NSString stringWithFormat:@"UPDATE peripheralActivationStatus_models SET activationStatus = '%zd' WHERE bikeid = '%zd'",1,self.bikeModel.bikeid]];
                    [[Manager shareManager] updateGPSMapActivationStatus:self.bikeModel.bikeid];
                }
                
            }else{
                PeripheralActivationStatusModel *model = [PeripheralActivationStatusModel modelWith:self.peripheralModel.bikeid deviceid:self.peripheralModel.deviceid type:self.peripheralModel.type activationStatus:1];
                [LVFmdbTool insertPeripheralActivationStatusModel:model];
                [[Manager shareManager] updateGPSMapActivationStatus:self.bikeModel.bikeid];
            }
            
            if (self.isOnlyGPSActivation) {
                
                if ([[APPStatusManager sharedManager] getChangeDeviceType] != BindingBike) {
                    NSMutableArray *viewCtrs = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
                    [viewCtrs removeObjectsInRange: NSMakeRange(1, viewCtrs.count - 1)];
                    id vc = [[NSClassFromString(@"ReplaceEquipmentViewController") alloc] init];
                    #pragma clang diagnostic push
                    #pragma clang diagnostic ignored "-Wundeclared-selector"
                    [QFTools performSelector:@selector(setChangeDeviceType:) withTheObjects:@[@([[APPStatusManager sharedManager] getChangeDeviceType])] withTarget:vc];
                    #pragma clang diagnostic pop
                    [viewCtrs addObject:vc];
                    [self.navigationController setViewControllers:viewCtrs animated:YES];
                }else{
                    [SVProgressHUD showSimpleText:@"初始化完成"];
                    [self.navigationController popViewControllerAnimated:YES];
                }
                
            }else{
                if (self.footview.GPSScanTag) {
                    self.footview.GPSScanTag(1);
                }
            }
        }else{

            [CommandDistributionServices sendSingleGPSActivationCommend:Open data:^(id _Nonnull queryData) {
            @strongify(self);
                if ([queryData intValue] == 0) {
                    NSLog(@"GPS激活成功");
                    
                    NSMutableArray *ary = [LVFmdbTool queryPeripheralActivationStatusData:[NSString stringWithFormat:@"SELECT * FROM peripheralActivationStatus_models WHERE bikeid = '%zd'",self.bikeModel.bikeid]];
                    
                    if (ary.count > 0) {
                        
                        PeripheralActivationStatusModel *model = ary.firstObject;
                        if (model.activationStatus == 0) {
                            [LVFmdbTool modifyData:[NSString stringWithFormat:@"UPDATE peripheralActivationStatus_models SET activationStatus = '%zd' WHERE bikeid = '%zd'",1,self.bikeModel.bikeid]];
                            [[Manager shareManager] updateGPSMapActivationStatus:self.bikeModel.bikeid];
                        }
                        
                    }else{
                        PeripheralActivationStatusModel *model = [PeripheralActivationStatusModel modelWith:self.peripheralModel.bikeid deviceid:self.peripheralModel.deviceid type:self.peripheralModel.type activationStatus:1];
                        [LVFmdbTool insertPeripheralActivationStatusModel:model];
                        [[Manager shareManager] updateGPSMapActivationStatus:self.bikeModel.bikeid];
                    }
                    
                    if (self.isOnlyGPSActivation) {
                        if ([[APPStatusManager sharedManager] getChangeDeviceType] != BindingBike) {
                            NSMutableArray *viewCtrs = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
                            [viewCtrs removeObjectsInRange: NSMakeRange(1, viewCtrs.count - 1)];
                            id vc = [[NSClassFromString(@"ReplaceEquipmentViewController") alloc] init];
                            #pragma clang diagnostic push
                            #pragma clang diagnostic ignored "-Wundeclared-selector"
                            [QFTools performSelector:@selector(setChangeDeviceType:) withTheObjects:@[@([[APPStatusManager sharedManager] getChangeDeviceType])] withTarget:vc];
                            #pragma clang diagnostic pop
                            [viewCtrs addObject:vc];
                            [self.navigationController setViewControllers:viewCtrs animated:YES];
                        }else{
                            [SVProgressHUD showSimpleText:@"初始化完成"];
                            [self.navigationController popViewControllerAnimated:YES];
                        }
                        
                    }else{
                        if (self.footview.GPSScanTag) {
                            self.footview.GPSScanTag(1);
                        }
                    }
                    
                }else{
                    NSLog(@"GPS激活失败");
                    if (self.footview.GPSScanTag) {
                        self.footview.GPSScanTag(6);
                    }
                }

            } error:^(CommandStatus status) {
                @strongify(self);
                switch (status) {
                    case SendSuccess:
                        NSLog(@"激活GPS发送成功");
                        break;

                    default:
                        if (self.footview.GPSScanTag) {
                            self.footview.GPSScanTag(6);
                        }
                        break;
                }
            }];
        }
    } error:^(CommandStatus status) {
        @strongify(self);
        switch (status) {
            case SendSuccess:
                NSLog(@"查询GPS发送成功");
                break;

            default:
                if (self.footview.GPSScanTag) {
                    self.footview.GPSScanTag(6);
                }
                break;
        }
    }];
}

/*
* 检测网络连接状态
*/
-(void)detectNetworkConnectionStatus{
    
    checkTime++;
    @weakify(self);
    [CommandDistributionServices getGPSGSMSignalValue:^(id  _Nonnull data) {
        @strongify(self);
        if ([data[@"status"] intValue] == 0 && [data[@"data"] intValue] >= 40) {
            
            [CommandDistributionServices QueryGPSActivationStatus:QueryGPSNetworkStatusMode data:^(id _Nonnull data) {
                @strongify(self);
                if ([data[@"status"] intValue] == 0 && [data[@"data"] intValue] == 3) {
                    checkTime = 0;
                    detectionTimes = 0;
                    if (self.footview.GPSScanTag) {
                        self.footview.GPSScanTag(2);
                    }
                }else{
                    if (checkTime >= 40) {
                        checkTime = 0;
                        detectionTimes ++;
                        if (self.footview.GPSScanTag) {
                            self.footview.GPSScanTag(3);
                        }
                    }else{
                        [self performSelector:@selector(detectNetworkConnectionStatus) withObject:nil afterDelay:0.5];
                    }
                }
            } error:^(CommandStatus status) {
                @strongify(self);
                switch (status) {
                    case SendSuccess:
                        NSLog(@"查询GSM信号发送成功");
                        break;

                    default:
                        checkTime = 0;
                        if (self.footview.GPSScanTag) {
                            self.footview.GPSScanTag(3);
                        }
                        detectionTimes++;
                        break;
                }
            }];
            
        }else{
            
            if (checkTime >= 40) {
                checkTime = 0;
                if (self.footview.GPSScanTag) {
                    self.footview.GPSScanTag(3);
                }
                detectionTimes ++;
            }else{
                [self performSelector:@selector(detectNetworkConnectionStatus) withObject:nil afterDelay:0.5];
            }
        }
        
    } error:^(CommandStatus status) {
            @strongify(self);
            switch (status) {
                case SendSuccess:
                    NSLog(@"获取GPS卫星数量发送成功");
                    break;
    
                default:
                    checkTime = 0;
                    
                    if (self.footview.GPSScanTag) {
                        self.footview.GPSScanTag(3);
                    }
                    detectionTimes++;
                    break;
            }
    }];
    
}


/*
 * 检测卫星通讯状态
 */
-(void)detectSatelliteCommunicationStatus{
    @weakify(self);
    scanTime++;
    NSLog(@"scanTime%d",scanTime);
    
    [CommandDistributionServices QueryGPSActivationStatus:QueryGPSPositionMode data:^(id _Nonnull data) {
        @strongify(self);
        if ([data[@"status"] intValue] == 0 && [data[@"data"] intValue] == 1) {
            scanTime = 0;
            detectionTimes = 0;
            if (self.footview.GPSScanTag) {
                self.footview.GPSScanTag(5);
            }
        }else{
            
            if (scanTime >= 40) {
                scanTime = 0;
                if (self.footview.GPSScanTag) {
                    self.footview.GPSScanTag(4);
                }
                detectionTimes++;
            }else{
                [self performSelector:@selector(detectSatelliteCommunicationStatus) withObject:nil afterDelay:0.5];
            }
        }
    } error:^(CommandStatus status) {
        @strongify(self);
        switch (status) {
            case SendSuccess:
                NSLog(@"查询GPS发送成功");
                break;

            default:
                scanTime = 0;
                if (self.footview.GPSScanTag) {
                    self.footview.GPSScanTag(4);
                }
                detectionTimes++;
                break;
        }
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)restOutTime:(void (^_Nullable)(CommandStatus status))error{
    
    [CommandDistributionServices setGPSReset:error];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
