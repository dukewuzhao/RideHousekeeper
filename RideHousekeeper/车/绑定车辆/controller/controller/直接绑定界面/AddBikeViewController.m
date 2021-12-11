//
//  AddBikeViewController.m
//  RideHousekeeper
//
//  Created by smartwallit on 16/7/12.
//  Copyright © 2016年 Duke Wu. All rights reserved.
//

#import "AddBikeViewController.h"
#import "PersonalCenterViewController.h"
#import "MultipleBindingLogicProcessingViewController.h"
#import "BindingHelpViewController.h"
#import "BindBikeTableViewCell.h"
#import "BindingHitView.h"
#import "AView.h"
#import "UIView+i7Rotate360.h"
#import "BindingView.h"
#import "BLEScanPopview.h"
#import "SearchBleModel.h"
#import "monitorBindingModel.h"
#import "DeviceConfigurationModel.h"
#import "UpdateViewModel.h"
#import "BikeStatusModel.h"
#import "BindingDeviceViewModel.h"
#import "Manager.h"
@interface AddBikeViewController ()<UIActionSheetDelegate,UIScrollViewDelegate>
@property(nonatomic,assign) BindingType bindingType;
@property(nonatomic,strong) BindingDeviceViewModel *bindingDeviceViewModel;
@property(nonatomic,strong) BLEScanPopview *scanView;
@property(nonatomic,strong) BindingView *bindingView;
@property(nonatomic,strong) BikeInfoModel *bikeinfomodel;
@property(nonatomic,strong) UpdateViewModel *updateModel;
@property(nonatomic,strong) monitorBindingModel *model;
@property(nonatomic,assign) DeviceScanType scantype;
@property(nonatomic,strong) BikeModel *bikeModel;
@property(nonatomic,assign) BOOL faild;
@end

@implementation AddBikeViewController

-(BindingDeviceViewModel *)bindingDeviceViewModel{
    if (!_bindingDeviceViewModel) {
        _bindingDeviceViewModel = [[BindingDeviceViewModel alloc] init];
    }
    return _bindingDeviceViewModel;
}

-(UpdateViewModel *)updateModel{
    if (!_updateModel) {
        _updateModel = [[UpdateViewModel alloc] init];
    }
    return _updateModel;
}


-(BikeInfoModel *)bikeinfomodel{
    if (!_bikeinfomodel) {
        _bikeinfomodel = [BikeInfoModel new];
        _bikeinfomodel.brand_info = [BikeBrandInfoModel new];
        _bikeinfomodel.model_info = [BikeModelInfoModel new];
        _bikeinfomodel.model_info.model_id = 0;
        _bikeinfomodel.model_info.model_name = @"自定义";
        _bikeinfomodel.model_info.batt_type = 0;
        _bikeinfomodel.model_info.batt_vol = 0;
        _bikeinfomodel.model_info.wheel_size = 0;
    }
    return _bikeinfomodel;
}

-(void)setBikeInfo:(BikeModel *)model bindType:(BindingType)type{
    _bindingType = type;
    _bikeModel = model;
    NSLog(@"绑定型号%d",type);
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    if (_faild) {
        return;
    }
    [self startblescan];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //if ([self isMovingFromParentViewController])
    if (_faild) {
        return;
    }
    [CommandDistributionServices stopScan];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    self.model=[[monitorBindingModel alloc]init];
    self.model.rssiList=[NSMutableArray new];
    
    [self setupNavView];
    @weakify(self);
    
    [[[NSNOTIC_CENTER rac_addObserverForName:KNotification_BluetoothPowerOn object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id x) {
        @strongify(self);
        
        if (![[APPStatusManager sharedManager] getBikeBindingStstus]) {
            [self startblescan];
            [self.view resumeLayer:self.bindingView.aView.layer];
        }
    }];
    
    [[[NSNOTIC_CENTER rac_addObserverForName:KNotification_BluetoothPowerOff object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id x){
        @strongify(self);
        
        if (![[APPStatusManager sharedManager] getBikeBindingStstus]) {
            [CommandDistributionServices stopScan];
            [[self.model mutableArrayValueForKey:@"rssiList"] removeAllObjects];
            [self.view pauseLayer:self.bindingView.aView.layer];
        }
    }];
    
    if (_bindingType == BindingBike) {
        _bindingView = [[BindingView alloc] initWithFrame:CGRectMake(0, navHeight, ScreenWidth, ScreenHeight - navHeight) bindType:_bindingType];
        
    }else{
        
        BindingHitView *hitView = [[BindingHitView alloc] initWithFrame:CGRectZero title:@"更换中控前请确认车辆配件信息，更换后相关配件和指纹需要重新配置。" color:[UIColor colorWithRed:255/255.0 green:94/255.0 blue:0/255.0 alpha:.15]];
        [self.view addSubview:hitView];
        [hitView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.view);
            make.top.equalTo(self.navView.mas_bottom);
            make.height.mas_equalTo(50);
        }];
        [self.view layoutIfNeeded];
        
        _bindingView = [[BindingView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(hitView.frame), ScreenWidth, ScreenHeight - navHeight - hitView.height) bindType:_bindingType];
    }
    
    _bindingView.resetBindingBlock = ^{
        @strongify(self);
        [CommandDistributionServices removePeripheral:nil];
        [self registerObservers];
        [self startblescan];
        self.faild = NO;
    };
    [self.view addSubview:_bindingView];
    [self registerObservers];
    _scantype = DeviceBingDingType;
    
    [self.model addObserver:self forKeyPath:@"rssiList" options:NSKeyValueObservingOptionNew context:NULL];
    
}

- (void)setupNavView{
    [super setupNavView];
    self.navView.showBottomLabel = NO;
    self.navView.backgroundColor = [UIColor clearColor];
    @weakify(self);
    
    if ([[AppDelegate currentAppDelegate].mainController isKindOfClass:[self class]]) {
        [[APPStatusManager sharedManager] setActivatedJumpStstus:NO];
        [self.navView.leftButton setImage:[UIImage imageNamed:@"pattern_selection_user_center"] forState:UIControlStateNormal];
        self.navView.leftButtonBlock = ^{
            @strongify(self);
            
            PersonalCenterViewController *personVc = [PersonalCenterViewController new];
            [self.navigationController pushViewController:personVc animated:YES];
        };
        
    }else{
        
        [self.navView.leftButton setImage:[UIImage imageNamed:@"icon_add_back"] forState:UIControlStateNormal];
        self.navView.leftButtonBlock = ^{
            @strongify(self);
            
            [self.navigationController popViewControllerAnimated:YES];
        };
    }
    if (_bindingType == BindingBike) {
        
        [self.navView.rightButton setTitle:@"绑定帮助" forState:UIControlStateNormal];
        [self.navView.rightButton setTitleColor:[QFTools colorWithHexString:MainColor] forState:UIControlStateNormal];
        self.navView.rightButtonBlock = ^{
            @strongify(self);
            
            [self.navigationController pushViewController:[BindingHelpViewController new] animated:YES];
        };
    }else if (_bindingType == BindingChangeECU) {
        
        [self.navView.centerButton setTitle:@"更换中控" forState:UIControlStateNormal];
        [self.navView.centerButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.navView.centerButton.titleLabel.font = FONT_PINGFAN_BOLD(18);
    }
}

-(BLEScanPopview *)scanView{
    
    if (!_scanView) {
        _scanView = [[BLEScanPopview alloc] initWithType:_bindingType];
        @weakify(self);
        _scanView.bindingBikeClickBlock = ^(NSInteger index) {
            @strongify(self);
            [self bindBike:index];
        };
    }
    return _scanView;
}


- (void)startblescan{
    @weakify(self);
    [CommandDistributionServices stopScan];
    [CommandDistributionServices removePeripheral:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){

        [CommandDistributionServices startScan:_scantype PeripheralList:^(NSMutableArray * arry) {
            @strongify(self);
            if (self.scantype == DeviceBingDingType){
                self.model.rssiList = [arry mutableCopy];
                [self.scanView setParams:[arry copy]];
            }
        }];
    });
}

-(void)bindBike:(NSInteger)num{
    
    if (![HttpRequest sharedInstance].available) {
        [SVProgressHUD showSimpleText:@"网络未连接"];
        return;
    }else if (![[APPStatusManager sharedManager] getBLEStstus]) {
        [SVProgressHUD showSimpleText:@"蓝牙未开启"];
        return;
    }
    
    [[APPStatusManager sharedManager] setBikeBindingStstus:YES];
    if ([[self.model.rssiList objectAtIndex:num] searchCount] != 0) {
        
        for (int i=0; i<self.model.rssiList.count; i++) {
            [[self.model.rssiList objectAtIndex:num] stopSearchBle];
        }
        
        [self.view pauseLayer:_bindingView.aView.layer];
        [LoadView sharedInstance].protetitle.text = (_bindingType == BindingBike)? @"绑定车辆中":@"更换智能中控中";
        [[LoadView sharedInstance] show];
        
        @weakify(self);
        RACSignal * deallocSignal = [self rac_signalForSelector:@selector(receiveConnnectMessageBikeSuccess)];
        [[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:KNotification_UpdateDeviceStatus object:nil] takeUntil:deallocSignal] timeout:5 onScheduler:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
            @strongify(self);
            NSNotification *userInfo = x;
            BOOL disConnect = [userInfo.object boolValue];
            if (self.scantype == DeviceBingDingType){
                if (!disConnect) {
                    [self receiveConnnectMessageBikeSuccess];
                }
            }
        }error:^(NSError *error) {
            [self overtime];
        }];
        [CommandDistributionServices stopScan];
        [CommandDistributionServices connectPeripheral:[[self.model.rssiList objectAtIndex:num] peripher]];
        self.bikeinfomodel.mac = [[self.model.rssiList objectAtIndex:num] mac].uppercaseString;
        [[self.model mutableArrayValueForKey:@"rssiList"] removeAllObjects];
        [self unregisterObservers];
    }
}


-(void)receiveConnnectMessageBikeSuccess{
    @weakify(self);
    [CommandDistributionServices getDeviceFirmwareRevisionString:^(NSString * _Nonnull revision) {
        @strongify(self);
        self.bikeinfomodel.firm_version = revision;
        [self monitorDiviceVersion];
    } error:^(CommandStatus status) {
        @strongify(self);
        switch (status) {
            case SendSuccess:
                NSLog(@"固件版本获取成功");
                break;
            default:
                [[LoadView sharedInstance] hide];
                [self overtime];
                break;
        }
    }];
    
}

-(void)monitorDiviceVersion{
    @weakify(self);
    [CommandDistributionServices getDeviceHardwareRevisionString:^(NSString * _Nonnull revision) {
        @strongify(self);
        self.bikeinfomodel.hw_version = revision;
        NSString *last = [self.bikeinfomodel.hw_version substringFromIndex:self.bikeinfomodel.hw_version.length-1];
        if ([last isEqualToString:@"1"]) {
            self.bikeinfomodel.fp_func = 1;
        }
        [self vehicleInformationReading];
        
    } error:^(CommandStatus status) {
        @strongify(self);
        switch (status) {
            case SendSuccess:
                NSLog(@"硬件版本号成功");
                break;
            default:
                [[LoadView sharedInstance] hide];
                [self overtime];
                break;
        }
        
    }];
}

-(void)vehicleInformationReading{
    @weakify(self);
    [CommandDistributionServices readingVehicleInformation:^(id _Nonnull data) {
        @strongify(self);
        if ([data intValue] == 2) {
            self.bikeinfomodel.wheels = 0;
        }else if ([data intValue] == 3){
            self.bikeinfomodel.wheels = 1;
        }else if ([data intValue] == 4){
            self.bikeinfomodel.wheels = 2;
        }
        [self firmwareJudgment];
        
    } error:^(CommandStatus status) {
        @strongify(self);
        switch (status) {
            case SendSuccess:
                NSLog(@"车轮数获取成功");
                break;
            default:
                [self firmwareJudgment];
                break;
        }
    }];
    
}

-(void)firmwareJudgment{
    
    if (![[self.bikeinfomodel.firm_version substringWithRange:NSMakeRange(0, 4)] isEqualToString:@"X100"]) {
        @weakify(self);
        [CommandDistributionServices getDeviceSupportdata:^(DeviceConfigurationModel *model) {
            @strongify(self);
            if(model.supportFingerprint){
                self.bikeinfomodel.fp_func = 1;
            }
            
            if(model.supportVibrationSensor){
                self.bikeinfomodel.vibr_sens_func = 1;
            }
            
            if(model.supportTirePressure){
                self.bikeinfomodel.tpm_func = 1;
            }
            
            if(model.supportGPS){
                self.bikeinfomodel.gps_func = 1;
            }
            
            if(model.fingerprintConfigurationTimes == 5){
                self.bikeinfomodel.fp_conf_count = 1;
            }
            [self getKeyType];
        }error:^(CommandStatus status) {
            @strongify(self);
            switch (status) {
                case SendSuccess:
                    NSLog(@"设备支持获取成功");
                    break;
                default:
                    [self getKeyType];
                    break;
            }
        }];
        
    }else{
        //无指纹和无震动灵敏度
        [self getKeyType];
    }
}

//发送钥匙码
-(void)getKeyType{
    @weakify(self);
    [CommandDistributionServices querykeyVersionNumber:^(NSString * _Nonnull date) {
        @strongify(self);
        self.bikeinfomodel.key_version = nil;
        self.bikeinfomodel.key_version = date;
        [self addCheckdevicenew];
        
    }error:^(CommandStatus status) {
        @strongify(self);
        switch (status) {
            case SendSuccess:
                NSLog(@"获取钥匙码成功");
                break;
            default:
                [[LoadView sharedInstance] hide];
                [self overtime];
                break;
        }
    }];
}

-(void)overtime{
    [[LoadView sharedInstance] hide];
    [CommandDistributionServices removePeripheral:nil];
    if (_bindingType == BindingBike) [SVProgressHUD showSimpleText:@"绑定超时"];
    [[APPStatusManager sharedManager] setBikeBindingStstus:NO];
    [_bindingView bndingfail];
    _faild = YES;
}


-(void)addCheckdevicenew{

    [self.bindingDeviceViewModel checkECUDevices:self.bikeinfomodel.mac success:^(id dict) {
        
        if ([dict[@"status"] intValue] == 0) {
            
            NSDictionary *data = dict[@"data"];
            DeviceInfoModel *deviceInfo = [DeviceInfoModel yy_modelWithDictionary:data[@"device_info"]];
            self.bikeinfomodel.brand_info.brand_id = deviceInfo.default_brand_id;
            self.bikeinfomodel.sn = deviceInfo.sn;
            [self getDefaultBikeBrand];
            
        }else if([dict[@"status"] intValue] == 2000){
            
            [[LoadView sharedInstance] hide];
            //[_bindingView bndingfail];
            [self.view resumeLayer:_bindingView.aView.layer];
            NSDictionary *data = dict[@"data"];
            DeviceInfoModel *deviceInfo = [DeviceInfoModel yy_modelWithDictionary:data[@"device_info"]];
            self.bikeinfomodel.brand_info.brand_id = deviceInfo.default_brand_id;
            self.bikeinfomodel.sn = deviceInfo.sn;
            MultipleBindingLogicProcessingViewController* MultipleBindVC = [[MultipleBindingLogicProcessingViewController alloc] init];
            MultipleBindVC.bikeinfomodel  = self.bikeinfomodel;
            
            if (self.bindingType == BindingBike) {
                [MultipleBindVC showView:DuplicateBindingKitWithGPS :deviceInfo :0];
            }else{
                [MultipleBindVC showView:DuplicateChangeECU :deviceInfo :self.bikeModel.bikeid];
            }
            [self.navigationController pushViewController:MultipleBindVC animated:YES];
        }else if([dict[@"status"] intValue] == 3000){
            
            [[LoadView sharedInstance] hide];
            //[_bindingView bndingfail];
            [self.view resumeLayer:_bindingView.aView.layer];
            NSDictionary *data = dict[@"data"];
            DeviceInfoModel *deviceInfo = [DeviceInfoModel yy_modelWithDictionary:data[@"device_info"]];
            self.bikeinfomodel.brand_info.brand_id = deviceInfo.default_brand_id;
            self.bikeinfomodel.sn = deviceInfo.sn;
            MultipleBindingLogicProcessingViewController* MultipleBindVC = [[MultipleBindingLogicProcessingViewController alloc] init];
            MultipleBindVC.bikeinfomodel  = self.bikeinfomodel;
            
            if (self.bindingType == BindingBike) {
                [MultipleBindVC showView:DuplicateBindingWithOutGPS :deviceInfo :0];
            }else{
                [MultipleBindVC showView:DuplicateChangeECU :deviceInfo :self.bikeModel.bikeid];
            }
            [self.navigationController pushViewController:MultipleBindVC animated:YES];
            
        }else if([dict[@"status"] intValue] == 4000){
            
            
            NSDictionary *data = dict[@"data"];
            DeviceInfoModel *deviceInfo = [DeviceInfoModel yy_modelWithDictionary:data[@"device_info"]];
            self.bikeinfomodel.brand_info.brand_id = deviceInfo.default_brand_id;
            self.bikeinfomodel.sn = deviceInfo.sn;
            MultipleBindingLogicProcessingViewController* MultipleBindVC = [[MultipleBindingLogicProcessingViewController alloc] init];
            MultipleBindVC.bikeinfomodel  = self.bikeinfomodel;
            if (self.bindingType == BindingBike) {
                [[LoadView sharedInstance] hide];
                [self.view resumeLayer:_bindingView.aView.layer];
                [MultipleBindVC showView:ECUKitWithGPS :deviceInfo:0];
                [self.navigationController pushViewController:MultipleBindVC animated:YES];
            }else{
                [self getDefaultBikeBrand];
            }
            
        }else if([dict[@"status"] intValue] == 5000){
            
            NSDictionary *data = dict[@"data"];
            DeviceInfoModel *deviceInfo = [DeviceInfoModel yy_modelWithDictionary:data[@"device_info"]];
            self.bikeinfomodel.brand_info.brand_id = deviceInfo.default_brand_id;
            self.bikeinfomodel.sn = deviceInfo.sn;
            MultipleBindingLogicProcessingViewController* MultipleBindVC = [[MultipleBindingLogicProcessingViewController alloc] init];
            MultipleBindVC.bikeinfomodel  = self.bikeinfomodel;
            
            if (self.bindingType == BindingBike) {
                [[LoadView sharedInstance] hide];
                [self.view resumeLayer:_bindingView.aView.layer];
                [MultipleBindVC showView:ECUKitWithOutGPS :deviceInfo:0];
                [self.navigationController pushViewController:MultipleBindVC animated:YES];
            }else{
                [self getDefaultBikeBrand];
            }
        }else if([dict[@"status"] intValue] == 6000){
            
            [[LoadView sharedInstance] hide];
            //[_bindingView bndingfail];
            [self.view resumeLayer:_bindingView.aView.layer];
            NSDictionary *data = dict[@"data"];
            DeviceInfoModel *deviceInfo = [DeviceInfoModel yy_modelWithDictionary:data[@"device_info"]];
            self.bikeinfomodel.brand_info.brand_id = deviceInfo.default_brand_id;
            self.bikeinfomodel.sn = deviceInfo.sn;
            MultipleBindingLogicProcessingViewController* MultipleBindVC = [[MultipleBindingLogicProcessingViewController alloc] init];
            MultipleBindVC.bikeinfomodel  = self.bikeinfomodel;
            
            if (self.bindingType == BindingBike) {
                [MultipleBindVC showView:DuplicateBinding :deviceInfo :0];
            }else{
                [MultipleBindVC showView:DuplicateChangeECU :deviceInfo :self.bikeModel.bikeid];
            }
            [self.navigationController pushViewController:MultipleBindVC animated:YES];
        }else if([dict[@"status"] intValue] == 1017){
            
            self.bikeinfomodel.brand_info.logo = [QFTools getdata:@"defaultlogo"];
            self.bikeinfomodel.brand_info.brand_id = 0;
            self.bikeinfomodel.brand_info.brand_name = @"骑管家";
            [self addVcbikebinding:0];
        }else{
            
            [self overtime];
        }
        
    } failure:^(NSError *error) {
        NSLog(@"error :%@",error);
        [SVProgressHUD showSimpleText:TIP_OF_NO_NETWORK];
        [self overtime];
    }];
    
}

-(void)getDefaultBikeBrand{
    
    NSString *URLString = [NSString stringWithFormat:@"%@%@",QGJURL,@"app/getbrandlist"];
    NSString *token = [QFTools getdata:@"token"];
    NSDictionary *parameters = @{@"token": token,@"firm_version":self.bikeinfomodel.firm_version,@"mac":self.bikeinfomodel.mac};
    
    [[HttpRequest sharedInstance] postWithURLString:URLString parameters:parameters success:^(id _Nullable dict) {
        
        if ([dict[@"status"] intValue] == 0) {
            
            NSDictionary *data = dict[@"data"];
            NSMutableArray *userinfo = data[@"brands"];
            for (NSDictionary *dataDict in userinfo) {
                NSNumber *brand = dataDict[@"brand_id"];
                if (brand.intValue == self.bikeinfomodel.brand_info.brand_id) {
                    self.bikeinfomodel.brand_info.bike_pic = dataDict[@"bike_pic"];
                    self.bikeinfomodel.brand_info.brand_name = dataDict[@"brand_name"];
                    self.bikeinfomodel.brand_info.logo = dataDict[@"logo"];
                }else if (_bikeinfomodel.brand_info.brand_id == 0){
                    
                    self.bikeinfomodel.brand_info.brand_name = @"骑管家";
                    self.bikeinfomodel.brand_info.logo = [QFTools getdata:@"defaultlogo"];
                }
            }
            
            [self addVcbikebinding:0];
        }else if([dict[@"status"] intValue] == 1001){
            
            [self overtime];
        }else{
            [self overtime];
        }
        
    }failure:^(NSError *error) {
        [SVProgressHUD showSimpleText:TIP_OF_NO_NETWORK];
        NSLog(@"error :%@",error);
        [self overtime];
    }];
}


- (void)addVcbikebinding:(NSInteger)isForce{
    
    if ([LVFmdbTool queryBikeData:nil].count >= 5) {
        
        [SVProgressHUD showSimpleText:@"最多同时只能绑定5辆车"];
        [[LoadView sharedInstance] hide];
        return;
    }
    
    if(self.bikeinfomodel.hw_version == nil){
        self.bikeinfomodel.hw_version = @"000000";//硬件版本号
    }
    
    if(self.bikeinfomodel.key_version == nil){
        self.bikeinfomodel.key_version = @"1";//钥匙版本号
    }
    
    NSDictionary *bike_info = [self.bikeinfomodel yy_modelToJSONObject];
    NSString *token = [QFTools getdata:@"token"];
    NSString *URLString;
    NSDictionary *parameters;
    if (_bindingType == BindingBike) {
        URLString = [NSString stringWithFormat:@"%@%@",QGJURL,@"app/bindbike"];
        parameters = @{@"token": token,@"bike_info":bike_info};
    }else{
        NSNumber* is_force;
        if (_bikeModel.gps_func == 1 && self.bikeinfomodel.gps_func != _bikeModel.gps_func) {
            is_force = @(1);
        }else{
            is_force = @(0);
        }
        
        URLString = [NSString stringWithFormat:@"%@%@",QGJURL,@"app/changedevice"];
        parameters = @{@"token": token,@"bike_id":@(_bikeModel.bikeid),@"device_type": @(1),@"old_device_id":@(_bikeModel.ecu_id),@"new_bike_info":bike_info,@"is_force":@(isForce)};
    }
    
    [[HttpRequest sharedInstance] postWithURLString:URLString parameters:parameters success:^(id _Nullable dict) {
        
        if ([dict[@"status"] intValue] == 0) {
            @weakify(self);
            NSDictionary *data = dict[@"data"];
            NSDictionary *bike_info = data[@"bike_info"];
            /*
            NSArray *ecu_missing_func = data[@"ecu_missing_func"];
            NSNumber *can_not_force = data[@"can_not_force"];
            NSNumber *device_type = data[@"device_type"];
            if (ecu_missing_func.count != 0) {
                
            }
            */
            BikeInfoModel *bikeInfo = [BikeInfoModel yy_modelWithDictionary:bike_info];
            [USER_DEFAULTS setInteger:bikeInfo.bike_id forKey:Key_BikeId];
            [USER_DEFAULTS synchronize];
            NSString *child = @"0";
            NSString *main = bikeInfo.passwd_info.main;
            
            NSMutableArray *bikeAry = [LVFmdbTool queryBikeData:nil];
            for (BikeModel *bik in bikeAry) {
                if ([bik.mac isEqualToString: (self.bindingType == BindingBike)? bikeInfo.mac:_bikeModel.mac]) {
                    if ([LVFmdbTool deleteSpecifiedData:bik.bikeid]) {
                        [[Manager shareManager] bikeViewUpdateForNewConnect:NO];
                    }
                }
            }
                
            BikeModel *pmodel = [BikeModel modalWith:bikeInfo.bike_id bikename:bikeInfo.bike_name ownerflag:bikeInfo.owner_flag ecu_id:bikeInfo.ecu_id hwversion:bikeInfo.hw_version firmversion:bikeInfo.firm_version keyversion:bikeInfo.key_version mac:bikeInfo.mac sn:bikeInfo.sn mainpass:main password:child bindedcount:bikeInfo.binded_count ownerphone:[QFTools getdata:@"phone_num"] fp_func:bikeInfo.fp_func fp_conf_count:bikeInfo.fp_conf_count tpm_func:bikeInfo.tpm_func gps_func:bikeInfo.gps_func vibr_sens_func:bikeInfo.vibr_sens_func wheels:bikeInfo.wheels builtin_gps:bikeInfo.builtin_gps];
            [LVFmdbTool insertBikeModel:pmodel];
            
            BrandModel *bmodel = [BrandModel modalWith:bikeInfo.bike_id brandid:bikeInfo.brand_info.brand_id brandname:bikeInfo.brand_info.brand_name logo:self.bikeinfomodel.brand_info.logo bike_pic:bikeInfo.brand_info.bike_pic];
            [LVFmdbTool insertBrandModel:bmodel];
            
            if (bikeInfo.model_info.model_id == 0) {
                
                bikeInfo.model_info.picture_b = [QFTools getdata:@"defaultimage"];
            }
            
            ModelInfo *Infomodel = [ModelInfo modalWith:bikeInfo.bike_id modelid:bikeInfo.model_info.model_id modelname:bikeInfo.model_info.model_name batttype:bikeInfo.model_info.batt_type battvol:bikeInfo.model_info.batt_vol wheelsize:bikeInfo.model_info.wheel_size brandid:bikeInfo.model_info.brand_id pictures:bikeInfo.model_info.picture_s pictureb:bikeInfo.model_info.picture_b];
            [LVFmdbTool insertModelInfo:Infomodel];
            
            for (DeviceInfoModel *device in bikeInfo.device_info){
                
                PeripheralModel *permodel = [PeripheralModel modalWith:bikeInfo.bike_id deviceid:device.device_id type:device.type seq:device.seq mac:device.mac sn:device.sn qr:device.qr firmversion:device.firm_version default_brand_id:device.default_brand_id default_model_id:device.default_model_id prod_date:device.prod_date imei:device.imei imsi:device.imsi sign:device.sign desc:device.desc ts:device.ts bind_sn:device.bind_sn bind_mac:device.bind_mac is_used:device.is_used];
                [LVFmdbTool insertDeviceModel:permodel];
                
                for (ServiceInfoModel *servicesInfo in device.service){
                    
                    PerpheraServicesInfoModel *service = [PerpheraServicesInfoModel modelWith:bikeInfo.bike_id deviceid:device.device_id ID:servicesInfo.ID type:servicesInfo.type title:servicesInfo.title brand_id:servicesInfo.brand_id begin_date:servicesInfo.begin_date end_date:servicesInfo.end_date left_days:servicesInfo.left_days];
                    [LVFmdbTool insertPerpheraServicesInfoModel:service];
                }
                
            }
            
            for (FingerModel *fpsInfo in bikeInfo.fps){
                
                FingerprintModel *fingermodel = [FingerprintModel modalWith:bikeInfo.bike_id fp_id:fpsInfo.fp_id pos:fpsInfo.pos name:fpsInfo.name added_time:fpsInfo.added_time];
                [LVFmdbTool insertFingerprintModel:fingermodel];
            }
            self.bikeinfomodel.bike_name = bikeInfo.bike_name;
            self.bikeinfomodel.bike_id = bikeInfo.bike_id;
            
            [CommandDistributionServices bikePasswordConfiguration:bike_info[@"passwd_info"] data:^(id data) {
                @strongify(self);
                [self monitorConnectAgain:[data intValue] :bikeInfo];
            } error:^(CommandStatus status) {
                @strongify(self);
                switch (status) {
                    case SendSuccess:
                        NSLog(@"密码配置发送成功");
                        break;
                    default:
                        [self monitorConnectAgain:ConfigurationFail :bikeInfo];
                        break;
                }
            }];
        }else if([dict[@"status"] intValue] == 1047){
            
            if (self.bindingType == BindingChangeECU) {
                
                NSMutableArray* peripheraAry = [LVFmdbTool queryPeripheraData:[NSString stringWithFormat:@"SELECT * FROM periphera_modals WHERE type = '%zd' AND bikeid = '%zd'", 4,_bikeModel.bikeid]];
                            NSDictionary *data = dict[@"data"];
                            ChangeDeviceModel *model = [ChangeDeviceModel yy_modelWithDictionary:data];
                            //NSArray *ecu_missing_func = model.ecu_missing_func;
                            //NSInteger can_not_force = model.can_not_force;
                            //NSInteger device_type = model.device_type;
                //            __block NSString *title = @"" ;
                //            if (ecu_missing_func.count != 0) {
                //                [ecu_missing_func enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                //                    title = [title stringByAppendingFormat:@"%@,",(NSString *)obj];
                //                    //title = [NSString stringWithFormat:@"%@,",obj];
                //                    NSLog(@"title---%@",title);
                //                }];
                //            }
                
                if (model.can_not_force == 1) {
                    //跳转更换失败界面
                    [self overtime];
                    [self pushChangeDeviceFail:BindingChangeECUFail];
                    
                    return ;
                }else if (peripheraAry.count > 0 && self.bikeinfomodel.gps_func == 0){
                    
                    [self overtime];
                    [self pushChangeDeviceFail:BindingChangeECUFail];
                    return;
                }
                
                @weakify(self);
                DW_AlertView *alertView = [[DW_AlertView alloc] initBackroundImage:nil Title:@"中控类型不一致" contentString:@"更换的设备类型不一致，更换后可 能影响部分功能使用"  sureButtionTitle:@"确认" cancelButtionTitle:@"取消"];
                [alertView setSureBolck:^(BOOL clickStatu) {
                    @strongify(self);
                    [LoadView sharedInstance].protetitle.text = @"强制更换中...";
                    [[LoadView sharedInstance] show];
                    [self addVcbikebinding:1];
                }];
                [alertView setCancleBolck:^(BOOL clickStatu) {
                    @strongify(self);
                    [self.navigationController popViewControllerAnimated:YES];
                }];
            }else{
                [self overtime];
            }
        }else{
            
            if (_bindingType == BindingChangeECU) {
                [self overtime];
                [self pushChangeDeviceFail:BindingChangeECUFail];
            } else {
                [self overtime];
            }
        }
        
    }failure:^(NSError *error) {
        NSLog(@"error :%@",error);
        if (_bindingType == BindingChangeECU) {
            [self overtime];
            [self pushChangeDeviceFail:BindingChangeECUFail];
        } else {
            [self overtime];
        }
    }];
}


-(void)monitorConnectAgain:(CallbackStatus)status :(BikeInfoModel*)bikeInfoModel{
    
    if (status == ConfigurationSuccess){
        
        [CommandDistributionServices removePeripheral:nil];
        if ([[AppDelegate currentAppDelegate].mainController isKindOfClass:NSClassFromString(@"AddBikeViewController")]) {
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
                [self bikeBindSuccess];
            });
            
        }else{
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
                [self addVcconnectdevice:bikeInfoModel];
            });
        }
    }else{
        [self addVcbindingfail];
    }
}


-(void)bikeBindSuccess{
    [[LoadView sharedInstance] hide];
    if (_bindingType == BindingBike) [SVProgressHUD showSimpleText:@"车辆绑定成功"];
    [NSNOTIC_CENTER postNotificationName:KNOTIFICATION_LOGINCHANGE object:@YES];
}

-(void) removebikeDB{
    
    NSString *deleteBikeSql = [NSString stringWithFormat:@"DELETE FROM bike_modals WHERE bikeid LIKE '%zd'", self.bikeinfomodel.bike_id];
    [LVFmdbTool deleteBikeData:deleteBikeSql];
    
    NSString *deleteBrandSql = [NSString stringWithFormat:@"DELETE FROM brand_modals WHERE bikeid LIKE '%zd'", self.bikeinfomodel.bike_id];
    [LVFmdbTool deleteBrandData:deleteBrandSql];
    
    NSString *deleteInfoSql = [NSString stringWithFormat:@"DELETE FROM info_modals WHERE bikeid LIKE '%zd'", self.bikeinfomodel.bike_id];
    [LVFmdbTool deleteModelData:deleteInfoSql];
    
    NSString *deletePeripherSql = [NSString stringWithFormat:@"DELETE FROM periphera_modals WHERE bikeid LIKE '%zd'", self.bikeinfomodel.bike_id];
    [LVFmdbTool deletePeripheraData:deletePeripherSql];
    
    [LVFmdbTool deletePerpheraServicesInfoData:[NSString stringWithFormat:@"DELETE FROM peripheraServicesInfo_modals WHERE bikeid LIKE '%zd'", self.bikeinfomodel.bike_id]];
}

-(void)addVcconnectdevice:(BikeInfoModel*)bikeInfoModel{
    [USER_DEFAULTS removeObjectForKey:Key_DeviceUUID];
    [USER_DEFAULTS synchronize];
    [[APPStatusManager sharedManager] setBikeBindingStstus:NO];
    self.updateModel.logo = bikeInfoModel.brand_info.logo;
    [[LoadView sharedInstance] hide];
    if (_bindingType == BindingBike) [SVProgressHUD showSimpleText:@"车辆绑定成功"];
    [[APPStatusManager sharedManager] setChangeDeviceType:_bindingType];
    [[Manager shareManager] bindingBikeSucceeded:bikeInfoModel :self.updateModel];
}

- (void)addVcbindingfail{
    
    [[LoadView sharedInstance] hide];
    [SVProgressHUD showSimpleText:@"绑定失败"];
    [[APPStatusManager sharedManager] setBikeBindingStstus:NO];
    [self removebikeDB];
    [CommandDistributionServices stopScan];
    [_bindingView bndingfail];
    _faild = YES;
}

-(void)registerObservers
{
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)])
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:
         [UIUserNotificationSettings
          settingsForTypes: UIUserNotificationTypeAlert|UIUserNotificationTypeSound
          categories:nil]];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterForeground:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

-(void)unregisterObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}

-(void)appDidEnterBackground:(NSNotification *)_notification
{
    // Controller is set when the DFU is in progress
    [CommandDistributionServices stopScan];
}

-(void)appDidEnterForeground:(NSNotification *)_notification
{
    [self startblescan];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"rssiList"]) {
        
        if (self.model.rssiList.count > 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.bindingView.promptView.hidden = YES;
                [self.scanView showInView:self.view];
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                self.bindingView.promptView.hidden = NO;
                [self.scanView disMissView];
                self.scanView = nil;
            });
        }
    }
}

-(void)pushChangeDeviceFail:(BindingType)type{
    
    NSMutableArray *viewCtrs = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    id vc = [[NSClassFromString(@"ReplaceEquipmentViewController") alloc] init];
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wundeclared-selector"
    [QFTools performSelector:@selector(setChangeDeviceType:) withTheObjects:@[@(type)] withTarget:vc];
    #pragma clang diagnostic pop
    [viewCtrs addObject:vc];
    [self.navigationController setViewControllers:viewCtrs animated:YES];
}

-(void)dealloc{
    if (_model != nil) {
        [_model removeObserver:self forKeyPath:@"rssiList"];
    }
    [[APPStatusManager sharedManager] setBikeBindingStstus:NO];
    [CommandDistributionServices stopScan];
    if ([[AppDelegate currentAppDelegate].mainController isKindOfClass:NSClassFromString(@"BikeViewController")]) {
        if (![QFTools isBlankString:[USER_DEFAULTS stringForKey:Key_DeviceUUID]]) {
            [CommandDistributionServices removePeripheral:nil];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [CommandDistributionServices connectPeripheralByUUIDString:[USER_DEFAULTS stringForKey:Key_DeviceUUID]];
            });
        }
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
