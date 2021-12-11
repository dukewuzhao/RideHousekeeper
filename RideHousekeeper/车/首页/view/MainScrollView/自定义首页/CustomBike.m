//
//  CustomBike.m
//  RideHousekeeper
//
//  Created by Apple on 2018/3/1.
//  Copyright © 2018年 Duke Wu. All rights reserved.
//

#import "CustomBike.h"
#import "VehiclePositionViewController.h"
#import "VehicleTrajectoryViewController.h"
#import "CarConditionViewController.h"
#import "FaultViewController.h"
#import "SubmitViewController.h"
#import "AccessoriesViewController.h"
#import "GPSDetailViewController.h"
#import "BikeStatusModel.h"
#import "Manager.h"
@interface CustomBike()<ManagerDelegate>{
    NSInteger touchCount;//座桶锁点击频率限制
    NSInteger muteCount;//静音键点击频率限制
}
@property (nonatomic,strong) MSWeakTimer * monitorTime;
@property (nonatomic,assign) BOOL  needTimer,isadd,isClickBtn,isExpired;
@property (nonatomic,assign) NSInteger  num,countTime;
@property (nonatomic,strong) LOTAnimationView *buttonAnimation;
@property (nonatomic,strong) DW_AlertView *alert;
@property (nonatomic,assign) NomalCommand commandType;
@end

//#import "BikeViewController.h"
@implementation CustomBike

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(BikeStatusModel *)bikeStatusModel{
    if (!_bikeStatusModel) {
        _bikeStatusModel = [[BikeStatusModel alloc] init];
    }
    return _bikeStatusModel;
}

-(LOTAnimationView *)buttonAnimation{
    if (!_buttonAnimation) {
        _buttonAnimation = [[LOTAnimationView alloc] init];
        _buttonAnimation.backgroundColor = [UIColor whiteColor];
        _buttonAnimation.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _buttonAnimation;
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [[Manager shareManager] addDelegate:self];
        _num = 5;
        [self setupUI];
    }
    return self;
}


-(void)setupUI{
    
    self.bikeHeadView.carCondition.clickDelegate = self;
    [self addSubview:self.bikeHeadView];
    
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [QFTools colorWithHexString:@"#F5F5F5"];
    [self addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(self.bikeHeadView.mas_bottom);
        make.height.mas_equalTo(7.5);
    }];
    
    [self addSubview:self.vehicleConfigurationView];
    [self.vehicleConfigurationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bikeHeadView.mas_bottom).offset(7.5);
        make.left.equalTo(self.mas_left);
        make.right.equalTo(self.mas_right);
        make.width.mas_equalTo(ScreenWidth);
        make.bottom.equalTo(self.mas_bottom).offset(-QGJ_TabbarSafeBottomMargin);
    }];
    
    @weakify(self);
    self.vehicleConfigurationView.bikeTestClickBlock = ^{
        @strongify(self);
        
        if (![CommandDistributionServices isConnect]) {
            [self disConnectAlertView];
            return;
        }
        
        FaultViewController *faultVc = [FaultViewController new];
        faultVc.faultmodel = self.bikeStatusModel.faultModel;
        [[QFTools viewController:self].navigationController pushViewController:faultVc animated:YES];
    };
    
    self.vehicleConfigurationView.bikeSetUpClickBlock = ^{
        @strongify(self);
        
        if (self.viewType == 3) {
            
            GPSVehicleDetailsViewController *GPSDetailVc = [[GPSVehicleDetailsViewController alloc] init];
            GPSDetailVc.bikeid = self.bikeid;
            [[QFTools viewController:self].navigationController pushViewController:GPSDetailVc animated:YES];
        }else{
            SubmitViewController *submitVc = [SubmitViewController new];
            submitVc.delegate = (UIViewController<SubmitDelegate> *)[QFTools viewController:self];
            submitVc.deviceNum = self.bikeid;
            
            switch (self.bikeStatusModel.shockState) {
                case low:
                    submitVc.shockState = @"低";
                    break;
                case middle:
                    submitVc.shockState = @"中";
                    break;
                case high:
                    submitVc.shockState = @"高";
                    break;
                default:
                    break;
            }
            [[QFTools viewController:self].navigationController pushViewController:submitVc animated:YES];
        }
    };
    
    self.vehicleConfigurationView.bikePartsManagClickBlock = ^{
        @strongify(self);
        AccessoriesViewController *AccessoriesVc = [AccessoriesViewController new];
        AccessoriesVc.deviceNum = self.bikeid;
        [[QFTools viewController:self].navigationController pushViewController:AccessoriesVc animated:YES];
    };
    
    self.bikeHeadView.vehicleStateView.bikeControlClickBlock = ^(NSInteger tag){
        @strongify(self);
        [self controlerClick:tag];
    };
    
    self.vehicleConfigurationView.RidingTrackClick = ^{
        @strongify(self);
        /*
        NSMutableArray *viewCtrs = [NSMutableArray arrayWithArray:[QFTools viewController:self].navigationController.viewControllers];
        VehiclePositionViewController *positionVc = [[VehiclePositionViewController alloc] init];
        positionVc.bikeid = self.bikeid;
        [viewCtrs addObject:positionVc];
        VehicleTrajectoryViewController *trajectoryVc = [[VehicleTrajectoryViewController alloc] init];
        trajectoryVc.bikeid = self.bikeid;
        trajectoryVc.delegate = (UIViewController<CyclingRouteDrawingDelegate> *)positionVc;
        trajectoryVc.modalPresentationStyle = UIModalPresentationOverFullScreen;
        
        [[QFTools viewController:self] presentViewController:trajectoryVc animated:YES completion:^{
            [[QFTools viewController:self].navigationController setViewControllers:viewCtrs animated:NO];
        }];
        */
        
        VehicleTrajectoryViewController *trajectoryVc = [[VehicleTrajectoryViewController alloc] init];
        trajectoryVc.bikeid = self.bikeid;
        //[[QFTools viewController:self] presentViewController:trajectoryVc animated:YES completion:nil];
        [[QFTools viewController:self].navigationController pushViewController:trajectoryVc animated:YES];
    };
    
    self.vehicleConfigurationView.PositioningServiceClick = ^{
        @strongify(self);
        BikeModel* bikeModel = [[LVFmdbTool queryBikeData:[NSString stringWithFormat:@"SELECT * FROM bike_modals WHERE bikeid LIKE '%zd'", self.bikeid]] firstObject];
        PeripheralModel *deviceModel = [[LVFmdbTool queryPeripheraData:[NSString stringWithFormat:@"SELECT * FROM periphera_modals WHERE type LIKE '%zd' AND bikeid LIKE '%zd'", 4,self.bikeid]] firstObject];
        GPSDetailViewController *GPSDetailVc = [GPSDetailViewController new];
        [GPSDetailVc setpGPSParameters:bikeModel :deviceModel.deviceid];
        [[QFTools viewController:self].navigationController pushViewController:GPSDetailVc animated:YES];
    };
}


-(VehicleConfigurationView *)vehicleConfigurationView{

    if (!_vehicleConfigurationView) {
        
        _vehicleConfigurationView = [[VehicleConfigurationView alloc] initWithFrame: CGRectZero];
//        _vehicleConfigurationView.layer.mask = [self UiviewRoundedRect:_vehicleConfigurationView.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(10, 10)];
    }
    return _vehicleConfigurationView;
}


-(BikeHeadView *)bikeHeadView{
    
    if (!_bikeHeadView) {
        _bikeHeadView = [[BikeHeadView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, self.height * .771)];
    }
    return _bikeHeadView;
}

- (void)setBikeid:(NSInteger)bikeid{
    _bikeid = bikeid;
    self.bikeHeadView.bikeid = bikeid;
    NSMutableArray *bikemodels = [LVFmdbTool queryBikeData:[NSString stringWithFormat:@"SELECT * FROM bike_modals WHERE bikeid LIKE '%zd'", bikeid]];
    BikeModel *bikeModel = bikemodels.firstObject;
    if (bikeModel.wheels == 0) {
        self.bikeHeadView.bikeBrandImg.image = [UIImage imageNamed:@"two_wheeler_icon"];
    }else if (bikeModel.wheels == 1){
        self.bikeHeadView.bikeBrandImg.image = [UIImage imageNamed:@"tricycle_icon"];
    }else if (bikeModel.wheels == 2){
        self.bikeHeadView.bikeBrandImg.image = [UIImage imageNamed:@"four_wheeled_vehicle_icon"];
    }
}

- (void)setViewType:(NSInteger)viewType{
    _viewType = viewType;
    self.bikeHeadView.viewType = viewType;
    self.vehicleConfigurationView.viewType = viewType;
    switch (viewType) {
        case 1:
            [self stopTimer];
            break;
        default:
            [self begainTimer];
            break;
    }
}

-(void)viewReset{
    
    if (_viewType == 2 || _viewType == 3) {
        
        return;
    }
    self.bikeHeadView.vehicleReportView.BikeStatusImg.image = [UIImage imageNamed:@"bike_BLE_braekconnect"];
    self.bikeHeadView.vehicleReportView.BikeStatusLab.text = @"未连接";
}

-(void)begainTimer{
    NSLog(@"时间开始");
    _needTimer = YES;
    [self startTimer];
    [self registerObservers];
}

-(void)startTimer{
    _monitorTime = [MSWeakTimer scheduledTimerWithTimeInterval:_num target:self selector:@selector(queryFired) userInfo:nil repeats:YES dispatchQueue:dispatch_get_main_queue()];
}

-(void)stopTimer{
    NSLog(@"时间停止");
    _needTimer = NO;
    [self endTimer];
    [self unregisterObservers];
}

-(void)endTimer{
    [_monitorTime invalidate];
    _monitorTime = nil;
}

-(void)queryFired{
    //NSLog(@"运行了时间");
    if (_num == 1) {
        _countTime ++;
        if (_countTime == 10) {
            _num = 5;
            _countTime = 0;
            [self restTimer];
        }
    }
    
    
    if (_viewType == 2 && ![CommandDistributionServices isConnect]) {
        [self getbikestatus:_bikeid];
    } else if (_viewType == 3){
        [self getbikestatus:_bikeid];
    }
}

-(void)restTimer{
    [self endTimer];
    [self startTimer];
}

-(void)registerObservers{
    if (!_isadd) {
        NSLog(@"添加通知");
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterForeground:) name:UIApplicationDidBecomeActiveNotification object:nil];
        _isadd = YES;
    }
}

-(void)unregisterObservers
{
    if (_isadd) {
        NSLog(@"移除通知");
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
        _isadd = NO;
        
    }
}

-(void)appDidEnterBackground:(NSNotification *)_notification
{
    // Controller is set when the DFU is in progress
    if (_needTimer){
        [self endTimer];
    }
}

-(void)appDidEnterForeground:(NSNotification *)_notification
{
    if (_needTimer){
        [self startTimer];
    }
}

#pragma -mark didClickView
-(void)didClickView{
    
    if (![CommandDistributionServices isConnect]) {
        
        [self disConnectAlertView];
        return;
    }
    
    CarConditionViewController *CarConditionVc = [[CarConditionViewController alloc] init];
    CarConditionVc.deviceNum = _bikeid;
    [[QFTools viewController:self].navigationController pushViewController:CarConditionVc animated:YES];
}

#pragma mark - 底部控制按钮，app主页底部的控制按钮逻辑
-(void)controlerClick:(NSInteger )tag{
    
    if (_isClickBtn) {
        return;
    }
    @weakify(self);
    RACSignal * deallocSignal = [self rac_signalForSelector:@selector(restAnimationView)];
    [[[[self rac_signalForSelector:@selector(restAnimationView)] takeUntil:deallocSignal] timeout:5 onScheduler:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        NSLog(@"执行了");
    }error:^(NSError *error) {
        @strongify(self);
        NSLog(@"没有执行按钮点击复位");
        [SVProgressHUD showSimpleText:@"远程遥控超时"];
        [self restAnimationView];
    }];
    
    _isClickBtn = YES;
    if (tag == 20){
        
        if (![CommandDistributionServices isConnect]) {
            if (self.viewType == 1) {
                [self disConnectAlertView];
            }else if (self.viewType == 2){
                [self startAnimationWithName:@"btn_run" :DeviceOutSafe :tag];
                [self remotectrlbike:@[@2]];
            }else{
                [SVProgressHUD showSimpleText:NSLocalizedString(@"车辆不支持", nil)];
            }
            return;
        }
        [self startAnimationWithName:@"btn_run_ble" :DeviceOutSafe :tag];
        [CommandDistributionServices setBikeBasicStatues:DeviceOutSafe error:nil];
        
    }else if (tag == 21){
        
        if (![CommandDistributionServices isConnect]) {
            if (self.viewType == 1) {
                [self disConnectAlertView];
            }else if (self.viewType == 2){
                [self startAnimationWithName:@"btn_run" :DeviceSetSafe :tag];
                [self remotectrlbike:@[@1]];
            }else{
                [SVProgressHUD showSimpleText:NSLocalizedString(@"车辆不支持", nil)];
            }
            return;
        }
        [self startAnimationWithName:@"btn_run_ble" :DeviceSetSafe :tag];
        [CommandDistributionServices setBikeBasicStatues:DeviceSetSafe error:nil];
    }else if (tag == 22){
        
        if (![CommandDistributionServices isConnect]) {
            if (self.viewType == 1) {
                [self disConnectAlertView];
            }else if (self.viewType == 2){
                [self startAnimationWithName:@"btn_run" :DeviceOpenEleDoor :tag];
                [self remotectrlbike:@[@3]];
            }else{
                [SVProgressHUD showSimpleText:NSLocalizedString(@"车辆不支持", nil)];
            }
            return;
        }
        [self startAnimationWithName:@"btn_run_ble" :DeviceOpenEleDoor :tag];
        [CommandDistributionServices setBikeBasicStatues:DeviceOpenEleDoor error:nil];
        
    }else if (tag == 23){
    
        if (!self.bikeHeadView.vehicleStateView.chamberpot){
            [SVProgressHUD showSimpleText:@"该车辆不支持座桶"];
            return ;
        }
        if(touchCount<1){
            
            touchCount++;
            if (![CommandDistributionServices isConnect]) {
                if (self.viewType == 1) {
                    [self disConnectAlertView];
                }else if (self.viewType == 2){
                    [self startAnimationWithName:@"btn_run" :DeviceOpenSeat :tag];
                    [self remotectrlbike:@[@5]];
                }else{
                    [SVProgressHUD showSimpleText:NSLocalizedString(@"车辆不支持", nil)];
                }
            }else{
                [self startAnimationWithName:@"btn_run_ble" :DeviceOpenSeat :tag];
                [CommandDistributionServices setBikeBasicStatues:DeviceOpenSeat error:nil];
            }
            [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(timeSetting) object:nil];
            [self performSelector:@selector(timeSetting) withObject:nil afterDelay:1.0];//1秒后点击次数清零
            
        }else{
            [SVProgressHUD showSimpleText:@"点击过于频繁"];
        }
    }else if (tag == 24){
        /*
        if(muteCount<1){
            muteCount++;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self->muteCount = 0;
            });
            if (_bikeStatusModel.isMute) {
                
                if (![CommandDistributionServices isConnect]) {
                    [self startAnimationWithName:@"btn_run" :DeviceSetSafeSound :tag];
                    [self remotectrlbike:@[@8]];
                    return;
                }
                [self startAnimationWithName:@"btn_run_ble" :DeviceSetSafeSound :tag];
                [CommandDistributionServices setBikeBasicStatues:DeviceSetSafeSound error:nil];
            }else{
                
                if (![CommandDistributionServices isConnect]) {
                    [self startAnimationWithName:@"btn_run" :DeviceSetSafeNoSound :tag];
                    [self remotectrlbike:@[@7]];
                    return;
                }
                [self startAnimationWithName:@"btn_run_ble" :DeviceSetSafeNoSound :tag];
               [CommandDistributionServices setBikeBasicStatues:DeviceSetSafeNoSound error:nil];
            }
        }
        */
    }
}

-(void)startAnimationWithName:(NSString *)name :(NSInteger)type :(NSInteger)tag{
    _commandType = type;
    [_buttonAnimation removeFromSuperview];
    UIButton *btn = (UIButton *)[self viewWithTag:tag];
    [self.buttonAnimation setAnimation:name];
    self.buttonAnimation.loopAnimation = YES;
    [self.buttonAnimation playWithCompletion:nil];
    [self.bikeHeadView.vehicleStateView addSubview:self.buttonAnimation];
    [self.buttonAnimation mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(btn);
    }];
}

#pragma mark - 避免重复开启电子锁，等待几秒后的操作
-(void)timeSetting{
    
    touchCount=0;
    [self restAnimationView];
}

-(void)remotectrlbike:(NSArray *)command{
    _num = 1;
    _countTime = 0;
    [self restTimer];
    NSString *token = [QFTools getdata:@"token"];
    NSNumber *bikeNum = [NSNumber numberWithInteger:_bikeid];
    NSString *URLString = [NSString stringWithFormat:@"%@%@",QGJURL,@"app/remotectrlbike"];
    NSDictionary *parameters = @{@"token":token, @"bike_id": bikeNum,@"command": command,};
    [[HttpRequest sharedInstance] postWithURLString:URLString parameters:parameters success:^(id _Nullable dict) {
        
        if ([dict[@"status"] intValue] == 0) {
            //NSDictionary *data = dict[@"data"];
            //[SVProgressHUD showSimpleText:@"远程遥控成功"];
        }else{
            [SVProgressHUD showSimpleText:dict[@"status_info"]];
        }
        
    }failure:^(NSError *error) {
        NSLog(@"error :%@",error);
        [SVProgressHUD showSimpleText:TIP_OF_NO_NETWORK];
    }];
}

-(void)getbikestatus:(NSInteger)bikeid{
    NSString *token = [QFTools getdata:@"token"];
    NSNumber *bikeNum = [NSNumber numberWithInteger:bikeid];
    NSString *URLString = [NSString stringWithFormat:@"%@%@",QGJURL,@"app/getbikestatus"];
    NSDictionary *parameters = @{@"token":token,@"user_id": [QFTools getdata:@"userid"], @"bike_id": bikeNum};
    [[HttpRequest sharedInstance] postWithURLString:URLString parameters:parameters success:^(id _Nullable dict) {
        
        if ([dict[@"status"] intValue] == 0) {
            NSDictionary *data = dict[@"data"];
            BikeStatusInfoModel *model = [BikeStatusInfoModel yy_modelWithDictionary:data[@"status"]];
            [self.bikeHeadView.vehiclePositioningMapView setBikeStatusInfo:model];
            
            if (_viewType == 3) {
                
                if (model.bike.acc) {
                    
                    self.bikeHeadView.vehicleReportView.BikeStatusImg.image = [UIImage imageNamed:@"icon_gps_door_close"];
                    self.bikeHeadView.vehicleReportView.BikeStatusLab.text = @"电门关闭";
                } else {
                    
                    self.bikeHeadView.vehicleReportView.BikeStatusImg.image = [UIImage imageNamed:@"icon_gps_door_open"];
                    self.bikeHeadView.vehicleReportView.BikeStatusLab.text = @"电门开启";
                    if (model.bike.lock == 0) {
                        self.bikeStatusModel.isLock = NO;
                    }else if (model.bike.lock == 1){
                        self.bikeStatusModel.isLock = YES;
                    }
                }
                
            } else {
                
                if (model.bike.acc) {
                    self.bikeHeadView.vehicleReportView.BikeStatusImg.image = [UIImage imageNamed:@"bike_riding"];
                    self.bikeHeadView.vehicleReportView.BikeStatusLab.text = @"骑行中";
                }else{
                    
                    if (model.bike.lock == 0) {
                        self.bikeHeadView.vehicleReportView.BikeStatusImg.image = [UIImage imageNamed:@"bike_unlock"];
                        self.bikeHeadView.vehicleReportView.BikeStatusLab.text = @"已撤防";
                        self.bikeStatusModel.isLock = NO;
                    }else if (model.bike.lock == 1){
                        self.bikeHeadView.vehicleReportView.BikeStatusImg.image = [UIImage imageNamed:@"bike_lock"];
                        self.bikeHeadView.vehicleReportView.BikeStatusLab.text = @"已上锁";
                        self.bikeStatusModel.isLock = YES;
                    }
                }
            }
            
            if (model.bike.mute == 0) {
                self.bikeStatusModel.isMute = NO;
            }else if (model.bike.mute == 1){
                self.bikeStatusModel.isMute = YES;
            }
            
            switch (self.commandType) {
                case DeviceOutSafe:
                        
                        if (model.bike.lock == 0) {
                            [self restAnimationView];
                        }
                    break;
                case DeviceSetSafe:
                        if (model.bike.lock == 1) {
                            [self restAnimationView];
                        }
                    break;
                case DeviceOpenEleDoor:
                        if (model.bike.acc == 1) {
                            [self restAnimationView];
                        }
                    break;
                default:
                    break;
            }
            
        }else if ([dict[@"status"] intValue] == 1038){//没数据
            NSDictionary *data = dict[@"data"];
            BikeStatusInfoModel *model = [BikeStatusInfoModel yy_modelWithDictionary:data[@"status"]];
            [self.bikeHeadView.vehiclePositioningMapView setBikeStatusInfo:model];
        }else if ([dict[@"status"] intValue] == 3003){
            
            [self stopTimer];
            if (!_isExpired) {
                _isExpired = YES;
                DW_AlertView *alertView = [[DW_AlertView alloc] initBackroundImage:nil Title:@"服务到期提醒" contentString:@"定位器服务试用到期已停用，为保证车辆安全及设备正常使用，请进行续费充值。" sureButtionTitle:@"去充值" cancelButtionTitle:@"取消"];
                @weakify(self);
                [alertView setSureBolck:^(BOOL clickStatu) {
                    @strongify(self);
                    //跳转到GPS服务续费界面
                    
                }];
            }
            
        }else{
            [SVProgressHUD showSimpleText:dict[@"status_info"]];
        }
        
    }failure:^(NSError *error) {
        NSLog(@"error :%@",error);
    }];
}

-(void)manager:(Manager *)manager updateGPSServiceInfo:(NSInteger)bikeid{
    
    if (_bikeid != bikeid) {
        return;
    }
    [self stopTimer];
    [self startTimer];
    if (_isExpired) {
        _isExpired = NO;
    }
}

-(void)disConnectAlertView{
     _alert = [[DW_AlertView alloc] initHeadLottiAnimation:@"MainViewBLEConnectAnimation"
                                                                 Title:@"正在连接车辆蓝牙（15S）..."
                                                         contentString:@"请尽量靠近车辆后尝试连接"
                                                    cancelButtionTitle:@"取消"];
    @weakify(self);
    _alert.cancleBolck = ^(BOOL clickStatu) {
        @strongify(self);
        [self restAnimationView];
        self.alert = nil;
    };
}

-(void)restAnimationView{
    _isClickBtn = NO;
    [_buttonAnimation removeFromSuperview];
}

-(void)dealloc{
    NSLog(@"%s dealloc",object_getClassName(self));
    [self stopTimer];
    [[Manager shareManager] deleteDelegate:self];
}

@end
