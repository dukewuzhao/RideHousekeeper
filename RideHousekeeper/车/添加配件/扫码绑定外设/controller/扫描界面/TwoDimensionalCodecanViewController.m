//
//  QRViewController.m
//  SmartWallitAdv
//
//  Created by AlanWang on 15/8/4.
//  Copyright (c) 2015年 AlanWang. All rights reserved.
//

#import "TwoDimensionalCodecanViewController.h"
#import "AddBikeViewController.h"
#import "ManualInputViewController.h"
#import "MultipleBindingLogicProcessingViewController.h"
#import "ProductDetailsViewController.h"
#import "PublicWebpageViewController.h"
#import "BindingGuidePopView.h"
#import "BindingHitView.h"
#import "BottomBtn.h"
#import "BindingDeviceViewModel.h"
#import "Manager.h"

@interface TwoDimensionalCodecanViewController (){
    SGQRCodeObtain *obtain;
}
@property (nonatomic,strong) BindingGuidePopView *popview;
@property (nonatomic, strong) SGQRCodeScanView *scanView;
@property (nonatomic, strong) BottomBtn *SetupBtn;
@property (nonatomic,strong) BikeModel *bikeModel;
@property (nonatomic,strong) DeviceInfoModel *deviceInfoModel;
@property (nonatomic,strong) BindingDeviceViewModel *deviceModel;
@property (nonatomic,strong) UpdateViewModel *updateModel;
@property (nonatomic,assign) BindingType bindingType;
@end

@implementation TwoDimensionalCodecanViewController

-(BindingDeviceViewModel *)deviceModel{
    if (!_deviceModel) {
        _deviceModel = [[BindingDeviceViewModel alloc] init];
    }
    return _deviceModel;
}

-(void)setChangeDeviceType:(BindingType)type{
    _bindingType = type;
}

- (void)setBikeid:(NSInteger)bikeid{
    _bikeid = bikeid;
    _bikeModel = [LVFmdbTool queryBikeData:[NSString stringWithFormat:@"SELECT * FROM bike_modals WHERE bikeid LIKE '%zd'", bikeid]].firstObject;
}

- (void)setNaVtitle:(NSString *)naVtitle{
    _naVtitle = naVtitle;
    
    if ([naVtitle isEqualToString:@"兑换卡"]) {
        
        DW_AlertView *alertView = [[DW_AlertView alloc] initTopTitle:@"请刮开兑换卡密码涂层区\n在扫码确认兑换服务后输入密码进行充值" contentImgString:@"icon_exchange_card" sureButtionTitle:@"知道了"];
        alertView.sureBolck = ^(BOOL clickStatu) {};
        
    }else if ([naVtitle isEqualToString:@"转移服务"]){
        DW_AlertView *alertView = [[DW_AlertView alloc] initTopTitle:@"请扫描需要转移服务设备的二维码\n开始转移步骤，转移成功后原设备\n服务期将延续到新设备上" contentImgString:@"icon_scan_prompt" sureButtionTitle:@"知道了"];
        alertView.sureBolck = ^(BOOL clickStatu) {};
    }else if ([naVtitle isEqualToString:@"绑定车辆"]){
        DW_AlertView *alertView = [[DW_AlertView alloc] initTopTitle:@"请扫描定位器设备或说明书上的设备二维码进行绑定" contentImgString:@"icon_scan_prompt" sureButtionTitle:@"知道了"];
        alertView.sureBolck = ^(BOOL clickStatu) {};
    }else if ([naVtitle isEqualToString:@"添加配件"] && _type == 4){
        DW_AlertView *alertView = [[DW_AlertView alloc] initTopTitle:@"请扫描定位器设备或说明书上的设备二维码进行绑定" contentImgString:@"icon_scan_prompt" sureButtionTitle:@"知道了"];
        alertView.sureBolck = ^(BOOL clickStatu) {};
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [obtain startRunningWithBefore:nil completion:nil];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.scanView addTimer];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.scanView removeTimer];
    [obtain stopRunning];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _deviceInfoModel = [DeviceInfoModel new];
    obtain = [SGQRCodeObtain QRCodeObtain];
    [self setupNavView];
    
    [APPPermissionDetectionManager openCaptureDeviceServiceWithBlock:^(BOOL isOpen) {
        if (isOpen) {
            [self setupQRCodeScan];
        }else{
            DW_AlertView *alert = [[DW_AlertView alloc] initBackroundImage:nil Title:@"提示" contentString:@"请打开相机权限" sureButtionTitle:@"确定" cancelButtionTitle:@"取消"];
            alert.sureBolck = ^(BOOL clickStatu) {
                NSURL * url= [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                if (@available(iOS 10.0, *)) {
                    NSDictionary *options = @{UIApplicationOpenURLOptionsSourceApplicationKey : @YES};
                    [[UIApplication sharedApplication] openURL:url options:options completionHandler:nil];
                } else {
                    // Fallback on earlier versions
                    [[UIApplication sharedApplication] openURL:url];
                }
            };
        }
    }];
    
    
    [self.view addSubview:self.scanView];
    [self.view addSubview:self.SetupBtn];
    
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = [QFTools colorWithHexString:MainColor];
    [self.view addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.SetupBtn);
        make.right.equalTo(self.SetupBtn);
        make.top.equalTo(self.SetupBtn.mas_bottom);
        make.height.mas_equalTo(0.5);
    }];
    
    if (_bindingType == BindingChangeGPS) {
        BindingHitView *hitView = [[BindingHitView alloc] initWithFrame:CGRectZero title:@"更换中控前请确认车辆配件信息，更换后相关配件和指纹需要重新配置。" color:[UIColor colorWithRed:255/255.0 green:94/255.0 blue:0/255.0 alpha:.15]];
        [self.view addSubview:hitView];
        [hitView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.view);
            make.top.equalTo(self.navView.mas_bottom);
            make.height.mas_equalTo(50);
        }];
    }
}

-(void)restartScan{
    [obtain stopRunning];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [obtain startRunningWithBefore:nil completion:nil];
//    });
}

- (void)setupNavView{
    [super setupNavView];
    self.navView.showBottomLabel = NO;
    [self.navView.centerButton setTitle:_naVtitle forState:UIControlStateNormal];
    @weakify(self);
    [self.navView.leftButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    self.navView.leftButtonBlock = ^{
        @strongify(self);
        
        [self.navigationController popViewControllerAnimated:YES];
    };
    
//    [self.navView.rightButton setTitle:@"相册" forState:UIControlStateNormal];
//    self.navView.rightButtonBlock = ^{
//        @strongify(self);
//        [self rightBarButtonItenAction];
//    };
}


- (void)setupQRCodeScan {
    __weak typeof(self) weakSelf = self;
    SGQRCodeObtainConfigure *configure = [SGQRCodeObtainConfigure QRCodeObtainConfigure];
    configure.openLog = YES;
    //configure.rectOfInterest = CGRectMake(0.4, 0.2, 0.7, 0.6);
    CGFloat x = 0.15*ScreenWidth;
    CGFloat y = 0.5*(ScreenHeight - 0.7*ScreenWidth);
    CGFloat w = 0.7*ScreenWidth;
    CGFloat h = 0.7*ScreenWidth;
    configure.rectOfInterest  = CGRectMake(y / ScreenHeight, (ScreenWidth-(w+x)) / ScreenWidth, h / ScreenHeight, w / ScreenWidth);
    // 这里只是提供了几种作为参考（共：13）；需什么类型添加什么类型即可
    NSArray *arr = @[AVMetadataObjectTypeQRCode,//二维码
    //以下为条形码，如果项目只需要扫描二维码，下面都不要写
    AVMetadataObjectTypeEAN13Code,
    AVMetadataObjectTypeEAN8Code,
    AVMetadataObjectTypeUPCECode,
    AVMetadataObjectTypeCode39Code,
    AVMetadataObjectTypeCode39Mod43Code,
    AVMetadataObjectTypeCode93Code,
    AVMetadataObjectTypeCode128Code,
    AVMetadataObjectTypePDF417Code];
    configure.metadataObjectTypes = arr;
    
    [obtain establishQRCodeObtainScanWithController:self configure:configure];
    [obtain startRunningWithBefore:^{
        //[MBProgressHUD SG_showMBProgressHUDWithModifyStyleMessage:@"正在加载..." toView:weakSelf.view];
    } completion:^{
        //[MBProgressHUD SG_hideHUDForView:weakSelf.view];
    }];
    [obtain setBlockWithQRCodeObtainScanResult:^(SGQRCodeObtain *obtain, NSString *result) {
        if (result) {
            [weakSelf restartScan];
            [obtain playSoundName:@"noticeMusic.wav"];
            [weakSelf accordingQcode:result];
        }
    }];
}


- (void)rightBarButtonItenAction {
    __weak typeof(self) weakSelf = self;

    [obtain establishAuthorizationQRCodeObtainAlbumWithController:nil];
    if (obtain.isPHAuthorization == YES) {
        [self.scanView removeTimer];
    }
    [obtain setBlockWithQRCodeObtainAlbumDidCancelImagePickerController:^(SGQRCodeObtain *obtain) {
        [weakSelf.view addSubview:weakSelf.scanView];
    }];
    [obtain setBlockWithQRCodeObtainAlbumResult:^(SGQRCodeObtain *obtain, NSString *result) {
        if (result == nil) {
            NSLog(@"暂未识别出二维码");
            [SVProgressHUD showSimpleText:@"暂未识别出二维码"];
        } else {
            [weakSelf accordingQcode:result];
        }
    }];
}

- (SGQRCodeScanView *)scanView {
    if (!_scanView) {
        _scanView = [[SGQRCodeScanView alloc] initWithFrame:CGRectMake(0, navHeight, ScreenWidth, ScreenHeight - navHeight)];
        // 静态库加载 bundle 里面的资源使用 SGQRCode.bundle/QRCodeScanLineGrid
        // 动态库加载直接使用 QRCodeScanLineGrid
        _scanView.scanImageName = @"scanLine";
        _scanView.scanAnimationStyle = ScanAnimationStyleDefault;
        _scanView.cornerLocation = CornerLoactionOutside;
        _scanView.cornerColor = [QFTools colorWithHexString:MainColor];
        
    }
    return _scanView;
}
- (void)removeScanningView {
    [self.scanView removeTimer];
    [self.scanView removeFromSuperview];
    self.scanView = nil;
}

- (BottomBtn *)SetupBtn {
    if (!_SetupBtn) {
        _SetupBtn = [[BottomBtn alloc] initWithFrame:CGRectMake(ScreenWidth/2 - 60, 0.8*ScreenHeight, 120, 35)];
        _SetupBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [_SetupBtn setTitle:@"手动输入" forState:UIControlStateNormal];
        [_SetupBtn setTitleColor:[QFTools colorWithHexString:MainColor] forState:UIControlStateNormal];
        [_SetupBtn setImage:[UIImage imageNamed:@"input"] forState:UIControlStateNormal];
        _SetupBtn.contentMode = UIViewContentModeCenter;
        _SetupBtn.backgroundColor = [UIColor clearColor];
        @weakify(self)
        [[_SetupBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            ManualInputViewController *manualVc = [ManualInputViewController new];
            manualVc.naVtitle = self.naVtitle;
            manualVc.bikeid = self.bikeid;
            manualVc.type = self.type;
            manualVc.seq = self.seq;
            manualVc.input = self.scanValue;
            [manualVc setChangeDeviceType:self.bindingType];
            [self.navigationController pushViewController:manualVc animated:NO];
        }];
    }
    return _SetupBtn;
}

#pragma mark - 扫描结果处理
- (void)accordingQcode:(NSString *)code{
    
    if (_type == 10) {
        //服务转移
        NSString *codeName = [QFTools getParamByName:@"qrcode" URLString:code];
        ProductDetailsViewController *productVc = [[ProductDetailsViewController alloc] init];
        [productVc setServiceTransferCode:codeName bikeid:_bikeid];
        [self.navigationController pushViewController:productVc animated:YES];
        
    }else if (_type == 11) {
        //兑换卡扫描
        NSString *codeName = [QFTools getParamByName:@"qr" URLString:code];
        if ([QFTools isBlankString:codeName]) {
            [obtain startRunningWithBefore:nil completion:nil];
            [SVProgressHUD showSimpleText:@"请扫描正确的兑换卡二维码"];
            return;
        }
        if (self.scanValue) self.scanValue(codeName);
        [obtain startRunningWithBefore:nil completion:nil];
    }else if (_type == 12) {
        //兑换卡扫描
        NSString *codeName;
        if (![code hasPrefix:@"https://m.smart-qgj.com/scan/"] || [QFTools isBlankString:[QFTools getParamByName:@"qrcode" URLString:code]]){
            [obtain startRunningWithBefore:nil completion:nil];
            [SVProgressHUD showSimpleText:@"请扫描正确的定位器二维码"];
            return;
        }
        
        if (self.scanValue) self.scanValue(codeName);
        
    }else if (_type == 6) {
        NSString *str = [QFTools completionStr:code needLength:8];
        if (str.length != 8) {
            [SVProgressHUD showSimpleText:@"该类型不是胎压"];
            return;
        }
        NSMutableArray *bikemodals = [LVFmdbTool queryBikeData:[NSString stringWithFormat:@"SELECT * FROM bike_modals WHERE bikeid LIKE '%zd'", _bikeid]];
        BikeModel *bikemodel = bikemodals.firstObject;
        if (bikemodel.tpm_func == 0) {
            
            [SVProgressHUD showSimpleText:@"该中控不支持胎压监测"];
            return;
        }
        [LoadView sharedInstance].protetitle.text = @"添加配件中";
        [[LoadView sharedInstance] show];
        _deviceInfoModel = [DeviceInfoModel new];
        _deviceInfoModel.device_id = 0;
        _deviceInfoModel.type = self.type;
        _deviceInfoModel.mac = str;
        _deviceInfoModel.sn = [NSString stringWithFormat:@"3000%@",str];
        _deviceInfoModel.seq = self.seq;
        @weakify(self);
        [CommandDistributionServices addTirePressure:_deviceInfoModel.seq - 1 mac:_deviceInfoModel.mac data:^(id data) {
            @strongify(self);
            if ([data intValue] == ConfigurationFail) {
                [[LoadView sharedInstance] hide];
                [SVProgressHUD showSimpleText:@"绑定失败"];
            }else{
                [self.deviceModel bindKey:_bikeid :_deviceInfoModel success:^(id dict) {
                    [[LoadView sharedInstance] hide];
                    if ([dict[@"status"] intValue] == 0) {
                        
                        NSDictionary *deviceDiction = dict[@"data"];
                        NSMutableArray *deviceinfo = deviceDiction[@"device_info"];
                        for (NSDictionary *devicedic in deviceinfo) {
                            DeviceInfoModel* deviceInfoModel = [DeviceInfoModel yy_modelWithDictionary:devicedic];
                            NSString *sn = deviceInfoModel.sn;
                            if ([_deviceInfoModel.sn isEqualToString:sn]) {
                                
                                PeripheralModel *pmodel = [PeripheralModel modalWith:self.bikeid deviceid:deviceInfoModel.device_id type:deviceInfoModel.type seq:deviceInfoModel.seq mac:deviceInfoModel.mac sn:deviceInfoModel.sn qr:deviceInfoModel.qr firmversion:deviceInfoModel.firm_version default_brand_id:deviceInfoModel.default_brand_id default_model_id:deviceInfoModel.default_model_id prod_date:deviceInfoModel.prod_date imei:deviceInfoModel.imei imsi:deviceInfoModel.imsi sign:deviceInfoModel.sign desc:deviceInfoModel.desc ts:deviceInfoModel.ts bind_sn:deviceInfoModel.bind_sn bind_mac:deviceInfoModel.bind_mac is_used:deviceInfoModel.is_used];
                                [LVFmdbTool insertDeviceModel:pmodel];
                                
                                for (ServiceInfoModel *servicesInfo in deviceInfoModel.service){
                                    
                                    PerpheraServicesInfoModel *service = [PerpheraServicesInfoModel modelWith:self.bikeid deviceid:deviceInfoModel.device_id ID:servicesInfo.ID type:servicesInfo.type title:servicesInfo.title brand_id:servicesInfo.brand_id begin_date:servicesInfo.begin_date end_date:servicesInfo.end_date left_days:servicesInfo.left_days];
                                    [LVFmdbTool insertPerpheraServicesInfoModel:service];
                                }
                                
                                [[Manager shareManager] bindingPeripheralSucceeded:pmodel];
                            }
                        }
                        [SVProgressHUD showSimpleText:@"添加配件成功"];
                        [self.navigationController popViewControllerAnimated:YES];
                    }else{
                        
                        [self->obtain startRunningWithBefore:nil completion:nil];
                        [SVProgressHUD showSimpleText:@"添加配件失败"];
                    }
                } failure:^(NSError * error) {
                    [self->obtain startRunningWithBefore:nil completion:nil];
                    [[LoadView sharedInstance] hide];
                }];
            }
        } error:^(CommandStatus status) {
            switch (status) {
                case SendSuccess:
                    NSLog(@"绑定胎压发送成功");
                    break;
                    
                default:
                    [[LoadView sharedInstance] hide];
                    [SVProgressHUD showSimpleText:@"添加配件失败"];
                    [self->obtain startRunningWithBefore:nil completion:nil];
                    break;
            }
        }];
        
    }else{
        
        NSString *codeName;
        if ([QFTools isUrlAddress:code]) {
            
            if ([code hasPrefix:@"https://m.smart-qgj.com/scan/"]) {
                NSString *a = [QFTools getParamByName:@"qrcode" URLString:code];//GPS二维码
                NSString *b = [QFTools getParamByName:@"qr" URLString:code];//兑换卡二维码
                codeName = a.length?  a:b;
            }else{
                
                PublicWebpageViewController *htmlVc = [[PublicWebpageViewController alloc] init];
                htmlVc.topTitle = @"网页";
                htmlVc.userPrivacyUrl = code;
                [self.navigationController pushViewController:htmlVc animated:YES];
                
                return;
            }
        }else{
            codeName = code;
        }
        
        [LoadView sharedInstance].protetitle.text = (_bindingType == BindingChangeGPS)? @"更换外设中":@"添加配件中";
        [[LoadView sharedInstance] show];
        
        [self.deviceModel checkKey:_bikeid :codeName success:^(id dict) {
            
            if ([dict[@"status"] intValue] == 0) {
                
                [[LoadView sharedInstance] hide];
                NSDictionary *deviceDiction = dict[@"data"];
                NSMutableArray *deviceinfo = deviceDiction[@"device_info"];
                for (NSDictionary *devicedic in deviceinfo) {
                    DeviceInfoModel* deviceInfoModel = [DeviceInfoModel yy_modelWithDictionary:devicedic];
                    if ([deviceInfoModel.sn isEqualToString:codeName]) {
                        
                        NSString *mac = deviceInfoModel.mac;
                        NSInteger deviceid = deviceInfoModel.device_id;
                        PeripheralModel *pmodel = [PeripheralModel modalWith:_bikeid deviceid:deviceid type:deviceInfoModel.type seq:deviceInfoModel.seq mac:mac sn:deviceInfoModel.sn qr:deviceInfoModel.qr firmversion:deviceInfoModel.firm_version default_brand_id:deviceInfoModel.default_brand_id default_model_id:deviceInfoModel.default_model_id prod_date:deviceInfoModel.prod_date imei:deviceInfoModel.imei imsi:deviceInfoModel.imsi sign:deviceInfoModel.sign desc:deviceInfoModel.desc ts:deviceInfoModel.ts bind_sn:deviceInfoModel.bind_sn bind_mac:deviceInfoModel.bind_mac is_used:deviceInfoModel.is_used];
                        [LVFmdbTool insertDeviceModel:pmodel];
                        
                        for (ServiceInfoModel *servicesInfo in deviceInfoModel.service){
                            
                            PerpheraServicesInfoModel *service = [PerpheraServicesInfoModel modelWith:self.bikeid deviceid:deviceInfoModel.device_id ID:servicesInfo.ID type:servicesInfo.type title:servicesInfo.title brand_id:servicesInfo.brand_id begin_date:servicesInfo.begin_date end_date:servicesInfo.end_date left_days:servicesInfo.left_days];
                            [LVFmdbTool insertPerpheraServicesInfoModel:service];
                        }
                        
                        [[Manager shareManager] bindingPeripheralSucceeded:pmodel];
                    }
                }
                        
                [SVProgressHUD showSimpleText:@"添加配件成功"];
                [self.navigationController popViewControllerAnimated:YES];
            }else if([dict[@"status"] intValue] == 2000){
                //GPS被使用
                [[LoadView sharedInstance] hide];
                
                if (self.bikeModel.gps_func == 0 && self.bikeid != 0 && self.bindingType == BindingBike) {
                    [self->obtain startRunningWithBefore:nil completion:nil];
                    [SVProgressHUD showSimpleText:@"无效的设备"];
                    return;
                }
                
                NSDictionary *data = dict[@"data"];
                DeviceInfoModel *deviceInfo = [DeviceInfoModel yy_modelWithDictionary:data[@"device_info"]];
                MultipleBindingLogicProcessingViewController* vc = [[MultipleBindingLogicProcessingViewController alloc] init];
                
                if (self.bindingType == BindingChangeGPS) {
                    [vc showView:ChangeGPS :deviceInfo :self.bikeid];
                }else{
                    [vc showView:GPSKitWithECU :deviceInfo :self.bikeid];
                }
                [self.navigationController pushViewController:vc animated:YES];
            }else if([dict[@"status"] intValue] == 2100){
                //GPS被试用
                [[LoadView sharedInstance] hide];
                if (self.bikeModel.gps_func == 0 && self.bikeid != 0 && self.bindingType == BindingBike) {
                    [self->obtain startRunningWithBefore:nil completion:nil];
                    [SVProgressHUD showSimpleText:@"无效的设备"];
                    return;
                }
                NSDictionary *data = dict[@"data"];
                DeviceInfoModel *deviceInfo = [DeviceInfoModel yy_modelWithDictionary:data[@"device_info"]];
                MultipleBindingLogicProcessingViewController* vc = [[MultipleBindingLogicProcessingViewController alloc] init];
                
                if (self.bindingType == BindingChangeGPS) {
                    [vc showView:DuplicateChangeGPS :deviceInfo :self.bikeid];
                }else{
                    [vc showView:DuplicateGPSKitWithECU :deviceInfo :self.bikeid];
                }
                [self.navigationController pushViewController:vc animated:YES];
            }else if([dict[@"status"] intValue] == 3000){
                [[LoadView sharedInstance] hide];
                if (self.bikeModel.gps_func == 0 && self.bikeid != 0 && self.bindingType == BindingBike) {
                    [self->obtain startRunningWithBefore:nil completion:nil];
                    [SVProgressHUD showSimpleText:@"无效的设备"];
                    return;
                }
                
                NSDictionary *data = dict[@"data"];
                DeviceInfoModel *deviceInfo = [DeviceInfoModel yy_modelWithDictionary:data[@"device_info"]];
                MultipleBindingLogicProcessingViewController* vc = [[MultipleBindingLogicProcessingViewController alloc] init];
                if (_bikeid == 0) {
                    [self matchingScanLogic:SingleGPSBinding :deviceInfo :vc];
                }else{
                    if (self.bindingType == BindingChangeGPS) {
                        [vc showView:ChangeGPS :deviceInfo :self.bikeid];
                    }else{
                        [vc showView:AccessoriesGPSBinding :deviceInfo :self.bikeid];
                    }
                    [self.navigationController pushViewController:vc animated:YES];
                }
                
            }else if([dict[@"status"] intValue] == 3100){
                [[LoadView sharedInstance] hide];
                if (self.bikeModel.gps_func == 0 && self.bikeid != 0 && self.bindingType == BindingBike) {
                    [self->obtain startRunningWithBefore:nil completion:nil];
                    [SVProgressHUD showSimpleText:@"无效的设备"];
                    return;
                }
                NSDictionary *data = dict[@"data"];
                DeviceInfoModel *deviceInfo = [DeviceInfoModel yy_modelWithDictionary:data[@"device_info"]];
                MultipleBindingLogicProcessingViewController* vc = [[MultipleBindingLogicProcessingViewController alloc] init];
                if (_bikeid == 0) {
                    [self matchingScanLogic:DuplicateSingleGPSBinding :deviceInfo :vc];
                }else{
                    
                    if (self.bindingType == BindingChangeGPS) {
                        [vc showView:DuplicateChangeGPS :deviceInfo :self.bikeid];
                    }else{
                        [vc showView:DuplicateAccessoriesGPSBinding :deviceInfo :self.bikeid];
                    }
                    [self.navigationController pushViewController:vc animated:YES];
                }
                
            }else if([dict[@"status"] intValue] == 4000){
                //GPSKitWithOutECU
                [[LoadView sharedInstance] hide];
                if (self.bikeModel.gps_func == 0 && self.bikeid != 0 && self.bindingType == BindingBike) {
                    [self->obtain startRunningWithBefore:nil completion:nil];
                    [SVProgressHUD showSimpleText:@"无效的设备"];
                    return;
                }
                
                NSDictionary *data = dict[@"data"];
                DeviceInfoModel *deviceInfo = [DeviceInfoModel yy_modelWithDictionary:data[@"device_info"]];
                MultipleBindingLogicProcessingViewController* vc = [[MultipleBindingLogicProcessingViewController alloc] init];
                
                if (self.bindingType == BindingChangeGPS) {
                    [vc showView:ChangeGPS :deviceInfo :self.bikeid];
                }else{
                    [vc showView:GPSKitWithOutECU :deviceInfo :self.bikeid];//需要检测是否要配成套件
                }
                [self.navigationController pushViewController:vc animated:YES];
                
            }else if([dict[@"status"] intValue] == 4100){
                //GPSKitWithOutECU
                [[LoadView sharedInstance] hide];
                if (self.bikeModel.gps_func == 0 && self.bikeid != 0 && self.bindingType == BindingBike) {
                    [self->obtain startRunningWithBefore:nil completion:nil];
                    [SVProgressHUD showSimpleText:@"无效的设备"];
                    return;
                }
                NSDictionary *data = dict[@"data"];
                DeviceInfoModel *deviceInfo = [DeviceInfoModel yy_modelWithDictionary:data[@"device_info"]];
                MultipleBindingLogicProcessingViewController* vc = [[MultipleBindingLogicProcessingViewController alloc] init];
                
                if (self.bindingType == BindingChangeGPS) {
                    [vc showView:DuplicateChangeGPS :deviceInfo :self.bikeid];
                }else{
                    [vc showView:DuplicateGPSKitWithOutECU :deviceInfo :self.bikeid];//需要检测是否要配成套件
                }
                [self.navigationController pushViewController:vc animated:YES];
                
            }else if([dict[@"status"] intValue] == 6000){
                //GPSKitWithOutECU
                [[LoadView sharedInstance] hide];
                if (self.bikeModel.gps_func == 0 && self.bikeid != 0 && self.bindingType == BindingBike) {
                    [self->obtain startRunningWithBefore:nil completion:nil];
                    [SVProgressHUD showSimpleText:@"无效的设备"];
                    return;
                }
                
                [obtain startRunningWithBefore:nil completion:nil];
                [SVProgressHUD showSimpleText:@"该配件已被绑定"];
            }else if([dict[@"status"] intValue] == 1042){
                
                [[LoadView sharedInstance] hide];
                NSMutableArray *peripheraModals = [LVFmdbTool queryPeripheraData:[NSString stringWithFormat:@"SELECT * FROM periphera_modals WHERE type LIKE '%zd' AND bikeid LIKE '%zd'", 4,self.bikeModel.bikeid]];
                if (peripheraModals.count == 0) {
                    [self->obtain startRunningWithBefore:nil completion:nil];
                    [SVProgressHUD showSimpleText:@"无效的设备"];
                    return;
                }
                
                ProductDetailsViewController *productVc = [[ProductDetailsViewController alloc] init];
                [productVc setRechargeCardNo:codeName bikeid:_bikeid];
                [self.navigationController pushViewController:productVc animated:YES];
                
            }else{
                [[LoadView sharedInstance] hide];
                [SVProgressHUD showSimpleText:dict[@"status_info"]];
                [self->obtain startRunningWithBefore:nil completion:nil];
            }
            
        } failure:^(NSError * error) {
            [[LoadView sharedInstance] hide];
            [self->obtain startRunningWithBefore:nil completion:nil];
        }];
    }
}


-(void)matchingScanLogic:(ProcessingtType)type :(DeviceInfoModel *)deviceInfo :(MultipleBindingLogicProcessingViewController*)vc{
     
    NSMutableArray *bikeAry = [LVFmdbTool queryBikeData:nil];
    NSMutableArray *copyBikeAry = [bikeAry mutableCopy];
    [bikeAry enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        BikeModel *model = (BikeModel *)obj;
        if (![QFTools isBlankString:model.sn]) {
            if (model.builtin_gps == 1) {
                [copyBikeAry removeObject:obj];
            }else{
                NSMutableArray *peripheraModals = [LVFmdbTool queryPeripheraData:[NSString stringWithFormat:@"SELECT * FROM periphera_modals WHERE type LIKE '%zd' AND bikeid LIKE '%zd'", 4,model.bikeid]];
                if (peripheraModals.count != 0 || model.gps_func == 0) {
                    [copyBikeAry removeObject:obj];
                }
            }
        }else{
            [copyBikeAry removeObject:obj];
        }
    }];
    if (copyBikeAry.count > 0) {
        _popview = [[BindingGuidePopView alloc] init];
        [_popview showInView:self.view withParams:copyBikeAry];
        @weakify(self);
        _popview.bindingBikeClickBlock = ^(NSInteger index) {
            @strongify(self);
            switch (index) {
                case -1:{
                    
                    [vc showView:type :deviceInfo :self.bikeid];//需要检测是否要配成套件
                    [self.navigationController pushViewController:vc animated:YES];
                    break;
                }
                    
                case -2:
                    
                    [self->obtain startRunningWithBefore:nil completion:nil];
                    break;
                default:
                    
                    [vc showView:AccessoriesGPSBinding :deviceInfo :[(BikeModel *)copyBikeAry[index] bikeid]];
                    [self.navigationController pushViewController:vc animated:YES];
                    break;
            }
        };
    }else{
        [vc showView:type :deviceInfo :_bikeid];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - 点击屏幕取消键盘
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

-(void)dealloc{
    
    [self removeScanningView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
    
}

@end
