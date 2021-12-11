//
//  BikeViewController.m
//  RideHousekeeper
//
//  Created by 同时科技 on 16/6/20.
//  Copyright © 2016年 Duke Wu. All rights reserved.
//

#import "BikeViewController.h"
#import "AddBikeViewController.h"
#import "SubmitViewController.h"
#import "FaultViewController.h"
#import "SetUpViewController.h"
#import "AccessoriesViewController.h"
#import "DeviceModel.h"
#import "QuartzCore/QuartzCore.h"
#import "LrdOutputView.h"
#import "FaultModel.h"
#import "CustomBike.h"
#import "TwoDimensionalCodecanViewController.h"
#import "AnimationObjectProtocol.h"
#import "Manager.h"

@interface BikeViewController ()<ScanDelegate,SubmitDelegate,AddBikeDelegate,LrdOutputViewDelegate,ManagerDelegate>

{
    NSMutableArray *rssiList;//搜索到的车辆的model数组
    NSMutableDictionary *uuidarray;//UUID字典
    BOOL phoneInduction;//手机感应是否打开
    NSInteger Inductionvalue;//手机感应的rssi值
    NSString *querydate;//查询的车辆蓝牙返回信息
    NSString *uuidstring;//要连接车辆的UUID
    NSString *editionname;//固件版本号
    BOOL fortification;//是否设防
    BOOL powerswitch;//电源是否打开
    BOOL riding;//是否骑行中
    BOOL keyInduction;//感应钥匙是否打开
    NSInteger touchCount;//座桶锁点击频率限制
    NSInteger muteCount;//静音键点击频率限制
}
@property(nonatomic,copy) NSString            *shockState;//震动灵敏度
@property (nonatomic, copy) NSString          *latest_version;//最新的固件版本号
@property(nonatomic, assign) NSInteger          bikeid;//车辆id
@property(nonatomic, copy) NSString             *mac;//车辆mac地址
@property(nonatomic, assign) NSInteger          ownerflag;//主与子用户分别
@property(nonatomic, copy) NSString             *password;//设备写入密码
@property(nonatomic, strong) MSWeakTimer        *queraTime;//0.5秒的计时器，用于查询数据
@property(nonatomic,strong) FaultModel           *faultmodel;//故障model
@property (nonatomic, strong) LrdOutputView     *outputView;//右上角弹出按钮
@property (nonatomic, weak) LrdCellModel        *Lrdmodel;//弹出界面model
@property (nonatomic, strong) NSMutableArray    *chooseArray;//获取弹出界面model的数组
@property (nonatomic, strong) CustomBike *custombike;
@end

@implementation BikeViewController

- (FaultModel *)faultmodel {
    if (!_faultmodel) {
        _faultmodel = [[FaultModel alloc] init];
    }
    return _faultmodel;
}

- (NSMutableArray *)chooseArray {
    if (!_chooseArray) {
        _chooseArray = [NSMutableArray new];
    }
    return _chooseArray;
}


-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [AppDelegate currentAppDelegate].device.scanDelete = self;
    self.navigationController.fd_fullscreenPopGestureRecognizer.enabled = YES;
    NSString*deviceuuid=[USER_DEFAULTS stringForKey:Key_DeviceUUID];
    if ([AppDelegate currentAppDelegate].isPop && [QFTools isBlankString:deviceuuid] && [AppDelegate currentAppDelegate].device.blueToothOpen && [[QFTools currentViewController] isKindOfClass:[BikeViewController class]]) {
        
        [[AppDelegate currentAppDelegate].device startScan];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    NSString*deviceuuid=[USER_DEFAULTS stringForKey:Key_DeviceUUID];
    //if DFU peripheral is connected and user press Back button then disconnect it
    if ([AppDelegate currentAppDelegate].isPop && [QFTools isBlankString:deviceuuid]) {
        
        [[AppDelegate currentAppDelegate].device stopScan];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[Manager shareManager] addDelegate:self];
    
    rssiList=[[NSMutableArray alloc]init];
    
    uuidarray=[[NSMutableDictionary alloc]init];
    
    [NSNOTIC_CENTER addObserver:self selector:@selector(BikeViewquerySuccess:) name:KNotification_QueryData object:nil];
    
    [NSNOTIC_CENTER addObserver:self selector:@selector(updateDeviceStatusAction:) name:KNotification_UpdateDeviceStatus object:nil];
    
    [[[NSNOTIC_CENTER rac_addObserverForName:KNotification_BluetoothPowerOn object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id x) {
        NSString*deviceuuid=[USER_DEFAULTS stringForKey:Key_DeviceUUID];
        if ([[QFTools currentViewController] isKindOfClass:[BikeViewController class]] && [QFTools isBlankString:deviceuuid]) {
            
            [[AppDelegate currentAppDelegate].device startScan];
        }
    }];
    
    [[[NSNOTIC_CENTER rac_addObserverForName:KNotification_BluetoothPowerOff object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id x) {
        NSString*deviceuuid=[USER_DEFAULTS stringForKey:Key_DeviceUUID];
        if ([[QFTools currentViewController] isKindOfClass:[BikeViewController class]] && [QFTools isBlankString:deviceuuid]) {
            
            [[AppDelegate currentAppDelegate].device stopScan];
        }
    }];
    
    [self setupmenu];
    [self setupBikeMenu];
    [self setupNavView];
}

-(void)setupBikeMenu{
    
    [self setupScroview];
    [self datatimeFired];
    self.queraTime = [MSWeakTimer scheduledTimerWithTimeInterval:0.6 target:self selector:@selector(queryFired:) userInfo:nil repeats:YES dispatchQueue:dispatch_get_main_queue()];
}

-(void)setupScroview{
    
    _custombike = [self setupCustomView];
    [self.view addSubview:_custombike];
}

-(CustomBike *)setupCustomView{
    
    CustomBike *custombike = [[CustomBike alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    @weakify(self);
    custombike.vehicleConfigurationView.bikeTestClickBlock = ^{
        @strongify(self);
        if (![[AppDelegate currentAppDelegate].device isConnected]) {
            
            [SVProgressHUD showSimpleText:NSLocalizedString(@"device_disconnect", nil)];
            return;
        }
        FaultViewController *faultVc = [FaultViewController new];
        faultVc.bikeid = self.bikeid;
        faultVc.querydate = self->querydate;
        [self.navigationController pushViewController:faultVc animated:YES];
    };
    
    custombike.vehicleConfigurationView.bikeSetUpClickBlock = ^{
        @strongify(self);
        SubmitViewController *submitVc = [SubmitViewController new];
        submitVc.delegate = self;
        submitVc.deviceNum = self.bikeid;
        submitVc.shockState = self.shockState;
        [self.navigationController pushViewController:submitVc animated:YES];
    };
    
    custombike.vehicleConfigurationView.bikePartsManagClickBlock = ^{
        @strongify(self);
        AccessoriesViewController *accessVc = [AccessoriesViewController new];
        accessVc.deviceNum = self.bikeid;
        [self.navigationController pushViewController:accessVc animated:YES];
    };
    
    custombike.vehicleStateView.bikeLockBlock = ^(NSInteger tag){
        @strongify(self);
        [self controlerClick:tag];
    };
    
    custombike.vehicleStateView.bikeSwitchBlock = ^(NSInteger tag){
        @strongify(self);
        [self controlerClick:tag];
    };
    
    custombike.vehicleStateView.bikeSeatBlock = ^(NSInteger tag){
        @strongify(self);
        [self controlerClick:tag];
    };
    
    custombike.vehicleStateView.bikeMuteBlock = ^(NSInteger tag){
        @strongify(self);
        [self controlerClick:tag];
    };
    
    return custombike;
}

#pragma mark - 车辆的连接状态改变的通知
-(void)updateDeviceStatusAction:(NSNotification*)notification{
    
    if([AppDelegate currentAppDelegate].device.deviceStatus == 0){
        editionname = nil;
        [_custombike viewReset];
    }else if([AppDelegate currentAppDelegate].device.deviceStatus>=2 &&[AppDelegate currentAppDelegate].device.deviceStatus<5){
        
        _custombike.bikeHeadView.vehicleView.bikestateImge.image = [UIImage imageNamed:@"icon_bike_check_connect"];
    }else{
        editionname = nil;
        [_custombike viewReset];
    }
}

- (void)setupNavView{
    [super setupNavView];
    self.navView.backgroundColor = [UIColor clearColor];
    self.navView.showBottomLabel = NO;
    @weakify(self);
    
    [self.navView.leftButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(15);
        make.centerY.mas_equalTo(self.navView.mainView.mas_centerY).with.offset((KStatusBarHeight+20)/2);
        make.height.mas_equalTo(40);
    }];
    
    [self.navView.leftButton setImage:[UIImage imageNamed:@"icon_choose_down"] forState:UIControlStateNormal];
    [self.navView.leftButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.navView.leftButton.titleLabel.font = [UIFont boldSystemFontOfSize:20];
    self.navView.leftButtonBlock = ^{
        @strongify(self);
        [self setupmenu];
        [self showBikeList];
    };
    
    [self.navView.rightButton setImage:[UIImage imageNamed:@"icon_set"] forState:UIControlStateNormal];
    self.navView.rightButtonBlock  = ^{
        @strongify(self);
        
        [self.navigationController pushViewController:[SetUpViewController new] animated:YES];
    };
}


-(void)showBikeList{
    
    CGFloat x = 15;
    CGFloat y = navHeight +5;
    _outputView = [[LrdOutputView alloc] initWithDataArray:self.chooseArray origin:CGPointMake(x, y) width:150 height:44 direction:kLrdOutputViewDirectionLeft];
    _outputView.delegate = self;
    _outputView.dismissOperation = ^(){
        _outputView = nil;
    };
    [_outputView pop];
}

#pragma mark -  LrdOutputViewcell
- (void)setupmenu{
    [self.chooseArray removeAllObjects];
    for (BikeModel*model in [LVFmdbTool queryBikeData:nil]) {
        
        LrdCellModel *one = [[LrdCellModel alloc] initWithTitle:model.bikename imageName:nil];
        [self.chooseArray addObject:one];
    }
    LrdCellModel *two = [[LrdCellModel alloc] initWithTitle:NSLocalizedString(@"add_car", nil) imageName:@"add"];
    [self.chooseArray addObject:two];
}


#pragma mark -  LrdOutputViewDelegate的回调
- (void)didSelectedAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == self.chooseArray.count-1) {
        AddBikeViewController *addVc = [AddBikeViewController new];
        addVc.delegate = self;
        editionname = nil;
        [self pushNewViewController:addVc];
    }else{
        NSString *bikeQuerySql = [NSString stringWithFormat:@"SELECT * FROM bike_modals WHERE id LIKE '%ld'",indexPath.row + 1];
        BikeModel *bikeModal = [[LVFmdbTool queryBikeData:bikeQuerySql] firstObject];
        [self switchingVehicle:bikeModal.bikeid];
    }
}


#pragma mark -  addBikeDelegate
-(void)bidingBikeSuccess:(NSDictionary *)bikeDic :(BOOL)needUpdate{
    
    if ([bikeDic[@"bikeid"] intValue] == self.bikeid) {
        return;
    }
    
    if (needUpdate) {
        self.bikeid = [bikeDic[@"bikeid"] intValue];
        return;
    }
    
    phoneInduction = NO;
    [self.navView.leftButton setTitle:[NSString stringWithFormat:@"  %@",bikeDic[@"bikename"]] forState:UIControlStateNormal];
    self.bikeid = [bikeDic[@"bikeid"] intValue];
    _custombike.bikeid = [bikeDic[@"bikeid"] intValue];
    NSString *keyversion =bikeDic[@"keyversion"];
    [_custombike.vehicleStateView setupFootView:keyversion.intValue];
    [self setupmenu];
}


#pragma mark - 每0.6秒发送的查询码
-(void)queryFired:(MSWeakTimer *)timer{
    
    if (![[AppDelegate currentAppDelegate].device isConnected]) {
        //NSLog(@"time was invalite");
        return;
    }
    if (_custombike.haveCentralControl) {
        return;
    }
    
    if (![AppDelegate currentAppDelegate].device.binding && ![AppDelegate currentAppDelegate].device.bindingaccessories) {
        
        NSString *passwordHEX = @"A50000061001";
        [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
    }
}

#pragma mark - 进入首页后的延时，连接报警器的延时机制，给蓝牙中控启动的时间（只执行一次）
-(void)datatimeFired{
    
    NSString*deviceuuid=[USER_DEFAULTS stringForKey:Key_DeviceUUID];
    if (deviceuuid) {
        [self connectDevice];
        return;
    }
    
    NSString *fuzzyQuerySql = [NSString stringWithFormat:@"SELECT * FROM bike_modals WHERE id LIKE '%d'", 1];
    NSMutableArray *modals = [LVFmdbTool queryBikeData:fuzzyQuerySql];
    
    if (modals.count == 0) {
        return;
    }
    
    BikeModel *model = modals.firstObject;
    [self.navView.leftButton setTitle:[NSString stringWithFormat:@"  %@",model.bikename] forState:UIControlStateNormal];
    self.mac = model.mac;
    self.bikeid = model.bikeid;
    _custombike.bikeid = model.bikeid;
    [_custombike.vehicleStateView setupFootView:model.keyversion.intValue];
    [USER_DEFAULTS setObject: model.mac forKey:Key_MacSTRING];
    [USER_DEFAULTS synchronize];
    self.ownerflag = model.ownerflag;
    if (model.ownerflag == 1) {
    
        self.password = model.mainpass;
        NSString* masterpwd = [QFTools toHexString:(long)[self.password longLongValue]];
        
        if(masterpwd.length !=8){
            
            int masterpwdCount = 8 - (int)masterpwd.length;
            for (int i = 0; i<masterpwdCount; i++) {
                masterpwd = [@"0" stringByAppendingFormat:@"%@",masterpwd];
                
            }
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                NSDictionary *userDic = [NSDictionary dictionaryWithObjectsAndKeys:masterpwd,@"main",nil];
                [USER_DEFAULTS setObject:userDic forKey:passwordDIC];
                [USER_DEFAULTS synchronize];
            });
            
        }else{
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                NSDictionary *userDic = [NSDictionary dictionaryWithObjectsAndKeys:masterpwd,@"main",nil];
                [USER_DEFAULTS setObject:userDic forKey:passwordDIC];
                [USER_DEFAULTS synchronize];
            });
        }
        
    }else if (model.ownerflag == 0){
        
        self.password = model.password;
        NSString* childpwd = [QFTools toHexString:(long)[self.password longLongValue]];
        if(childpwd.length !=8){
            
            int childpwdCount = 8 - (int)childpwd.length;
            for (int i = 0; i<childpwdCount; i++) {
                
                childpwd = [@"0" stringByAppendingFormat:@"%@",childpwd];
            }
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                NSDictionary *userDic = [NSDictionary dictionaryWithObjectsAndKeys:childpwd,@"main",nil];
                [USER_DEFAULTS setObject:userDic forKey:passwordDIC];
                [USER_DEFAULTS synchronize];
            });
            
        }else{
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                NSDictionary *userDic = [NSDictionary dictionaryWithObjectsAndKeys:childpwd,@"main",nil];
                [USER_DEFAULTS setObject:userDic forKey:passwordDIC];
                [USER_DEFAULTS synchronize];
                
            });
        }
    }
    
    NSString *QueryuuidSql = [NSString stringWithFormat:@"SELECT * FROM peripherauuid_modals WHERE mac LIKE '%@'", model.mac];
    NSMutableArray *uuidmodals = [LVFmdbTool queryPeripheraUUIDData:QueryuuidSql];
    PeripheralUUIDModel *peripheraluuidmodel = uuidmodals.firstObject;
    if (uuidmodals.count == 0) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            
            [[AppDelegate currentAppDelegate].device startScan];
        });
        
    }else{
        
        uuidstring = peripheraluuidmodel.uuid;
        [self showDeviceList];
    }
}

#pragma mark - 有记录的车辆，进行连接车辆
-(void)connectDevice{
    
    NSString*deviceuuid=[USER_DEFAULTS stringForKey:Key_DeviceUUID];
    NSString *uuidQuerySql = [NSString stringWithFormat:@"SELECT * FROM peripherauuid_modals WHERE uuid LIKE '%%%@%%'", deviceuuid];
    NSMutableArray *uuidmodals = [LVFmdbTool queryPeripheraUUIDData:uuidQuerySql];
    PeripheralUUIDModel *peripherauuidmodel = uuidmodals.firstObject;
    NSString *mac = peripherauuidmodel.mac;
    
    NSString *fuzzyQuerySql = [NSString stringWithFormat:@"SELECT * FROM bike_modals WHERE mac LIKE '%%%@%%'", mac];
    NSMutableArray *bikemodals = [LVFmdbTool queryBikeData:fuzzyQuerySql];
    BikeModel *bikemodel = bikemodals.firstObject;
    self.bikeid = bikemodel.bikeid;
    _custombike.bikeid = bikemodel.bikeid;
    self.mac = bikemodel.mac;
    [_custombike.vehicleStateView setupFootView:bikemodel.keyversion.intValue];

    [self.navView.leftButton setTitle:[NSString stringWithFormat:@"  %@",bikemodel.bikename] forState:UIControlStateNormal];
    
    self.ownerflag = bikemodel.ownerflag;
    if (bikemodel.ownerflag == 1) {
        
        self.password = bikemodel.mainpass;
        NSString* masterpwd = [QFTools toHexString:(long)[self.password longLongValue]];
        
        if(masterpwd.length != 8){
            
            int masterpwdCount = 8 - (int)masterpwd.length;
            for (int i = 0; i<masterpwdCount; i++) {
                masterpwd = [@"0" stringByAppendingFormat:@"%@",masterpwd];
            }
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                NSDictionary *userDic = [NSDictionary dictionaryWithObjectsAndKeys:masterpwd,@"main",nil];
                [USER_DEFAULTS setObject:userDic forKey:passwordDIC];
                [USER_DEFAULTS synchronize];
            });
            
        }else{
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                NSDictionary *userDic = [NSDictionary dictionaryWithObjectsAndKeys:masterpwd,@"main",nil];
                [USER_DEFAULTS setObject:userDic forKey:passwordDIC];
                [USER_DEFAULTS synchronize];
            });
        }
        
    }else if (bikemodel.ownerflag == 0){
        
        self.password = bikemodel.password;
        NSString* masterpwd = [QFTools toHexString:(long)[self.password longLongValue]];
        if(masterpwd.length != 8){
            
            int masterpwdCount = 8 - (int)masterpwd.length;
            for (int i = 0; i<masterpwdCount; i++) {
                masterpwd = [@"0" stringByAppendingFormat:@"%@",masterpwd];
            }
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                NSDictionary *userDic = [NSDictionary dictionaryWithObjectsAndKeys:masterpwd,@"main",nil];
                [USER_DEFAULTS setObject:userDic forKey:passwordDIC];
                [USER_DEFAULTS synchronize];
            });
            
        }else{
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                NSDictionary *userDic = [NSDictionary dictionaryWithObjectsAndKeys:masterpwd,@"main",nil];
                [USER_DEFAULTS setObject:userDic forKey:passwordDIC];
                [USER_DEFAULTS synchronize];
            });
        }
    }
    
    NSString *fuzzyinduSql = [NSString stringWithFormat:@"SELECT * FROM induction_modals WHERE bikeid LIKE '%zd'", self.bikeid];
    NSMutableArray *modals = [LVFmdbTool queryInductionData:fuzzyinduSql];
    InductionModel *indumodel = modals.firstObject;
    
    if (modals.count == 0) {
        phoneInduction = NO;
        Inductionvalue = 70;
    }else if(indumodel.induction == 0){
        phoneInduction = NO;
        Inductionvalue = indumodel.inductionValue;
    }else if (indumodel.induction == 1){
        phoneInduction = YES;
        Inductionvalue = indumodel.inductionValue;
    }
        
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
        
        [USER_DEFAULTS setObject: self.mac forKey:Key_MacSTRING];
        [USER_DEFAULTS synchronize];
    });
}


#pragma mark - 获取到车辆的UUID后的连接
-(void)showDeviceList{
    [[AppDelegate currentAppDelegate].device stopScan];
    NSString *fuzzyinduSql = [NSString stringWithFormat:@"SELECT * FROM induction_modals WHERE bikeid LIKE '%zd'", self.bikeid];
    NSMutableArray *modals = [LVFmdbTool queryInductionData:fuzzyinduSql];
    InductionModel *indumodel = modals.firstObject;
    if (modals.count == 0) {
        
        phoneInduction = NO;
        Inductionvalue = indumodel.inductionValue;
    }else if(indumodel.induction == 0){
        
        phoneInduction = NO;
        Inductionvalue = indumodel.inductionValue;
    }else if (indumodel.induction == 1){
        
        phoneInduction = YES;
        Inductionvalue = indumodel.inductionValue;
    }
    
    if (uuidstring) {
        [[AppDelegate currentAppDelegate].device retrievePeripheralWithUUID:uuidstring];//导入外设 根据UUID
        [[AppDelegate currentAppDelegate].device connect];
        [USER_DEFAULTS setObject: uuidstring forKey:Key_DeviceUUID];
        [USER_DEFAULTS synchronize];
        
        NSString *fuzzyQuerySql = [NSString stringWithFormat:@"SELECT * FROM peripherauuid_modals WHERE uuid LIKE '%@'",uuidstring];
        NSMutableArray *modals = [LVFmdbTool queryPeripheraUUIDData:fuzzyQuerySql];
        NSString *phonenum = [QFTools getdata:@"phone_num"];
        
        if (modals.count == 0) {
            PeripheralUUIDModel *peripheramodel = [PeripheralUUIDModel modalWith:phonenum bikeid:self.bikeid mac:self.mac uuid:uuidstring];
            [LVFmdbTool insertPeripheralUUIDModel:peripheramodel];
        }
    }
}

#pragma mark - 底部控制按钮，app主页底部的控制按钮逻辑
-(void)controlerClick:(NSInteger )tag{

    if (![[AppDelegate currentAppDelegate].device isConnected]) {
        
        [SVProgressHUD showSimpleText:NSLocalizedString(@"device_disconnect", nil)];
        return;
        
    }else if (querydate == nil){
    
        return;
    }
    
    NSString *binary = [QFTools getBinaryByhex:[querydate substringWithRange:NSMakeRange(12, 2)]];
    if (tag == 20) {
        if ([[binary substringWithRange:NSMakeRange(7, 1)] isEqualToString:@"0"]) {
            if (riding) {
                [SVProgressHUD showSimpleText:NSLocalizedString(@"now_riding_content", nil)];
                return;
            }
            if (keyInduction) {
                [SVProgressHUD showSimpleText:NSLocalizedString(@"blu_key_have", nil)];
                return;
            }
            NSString *passwordHEX = @"A5000007200102";
            [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
        }else if ([[binary substringWithRange:NSMakeRange(7, 1)] isEqualToString:@"1"]){
            NSString *passwordHEX = @"A5000007200101";
            [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
        }
    }else if (tag == 21){
        if ([[binary substringWithRange:NSMakeRange(6, 1)] isEqualToString:@"0"]) {
            
            if ([[binary substringWithRange:NSMakeRange(7, 1)] isEqualToString:@"1"]){
                [SVProgressHUD showSimpleText:NSLocalizedString(@"unlock_can_opendoor", nil)];
                return;
            }
            NSString *passwordHEX = @"A5000007200103";
            [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
        }else if ([[binary substringWithRange:NSMakeRange(6, 1)] isEqualToString:@"1"]){
            NSString *passwordHEX = @"A5000007200104";
            [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
        }
    }else if (tag == 22){
    
        if (_custombike.vehicleStateView.chamberpot) {
            
            if (self->fortification) {
                [SVProgressHUD showSimpleText:NSLocalizedString(@"unlock_can_chamberpot", nil)];
                return;
            }
            
            if(touchCount<1){
                touchCount++;
                NSString *passwordHEX = @"A5000007200107";
                [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];;//不是频繁操作执行对应点击事件
                [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(timeSetting) object:nil];
                [self performSelector:@selector(timeSetting) withObject:nil afterDelay:1.0];//1秒后点击次数清零
                [_custombike.vehicleStateView.bikeSeatBtn setImage:[UIImage imageNamed:@"icon_bike_seat_open"] forState:UIControlStateNormal];
            }else{
                
                [SVProgressHUD showSimpleText:NSLocalizedString(@"closet_time_out", nil)];
            }
            
        }else if (!_custombike.vehicleStateView.chamberpot){
            //非静音
            
            if(muteCount<1){
                muteCount++;
                
                if ([[binary substringWithRange:NSMakeRange(5, 1)] isEqualToString:@"0"]) {
                    
                    NSString *passwordHEX = @"A5000007200105";//静音
                    [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
                    
                }else if ([[binary substringWithRange:NSMakeRange(5, 1)] isEqualToString:@"1"]) {
                    //静音
                    NSString *passwordHEX = @"A5000007200106";//非静音
                    [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
                }
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    
                    self->muteCount = 0;
                });
            }
        }
    }else if (tag == 23){
    
        if(muteCount<1){
            muteCount++;
            
            if ([[binary substringWithRange:NSMakeRange(5, 1)] isEqualToString:@"0"]) {
                
                NSString *passwordHEX = @"A5000007200105";
                
                [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
                
            }else if ([[binary substringWithRange:NSMakeRange(5, 1)] isEqualToString:@"1"]){
                
                NSString *passwordHEX = @"A5000007200106";
                
                [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
            }
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                self->muteCount = 0;
            });
        }
    }
}

#pragma mark - 避免重复开启电子锁，等待几秒后的操作
-(void)timeSetting{
    
    touchCount=0;
    [_custombike.vehicleStateView.bikeSeatBtn setImage:[UIImage imageNamed:@"icon_bike_seat"] forState:UIControlStateNormal];
}


#pragma mark - 0.6循环秒查询蓝牙数据返回
-(void)BikeViewquerySuccess:(NSNotification *)data{
    
    NSString *date = data.userInfo[@"data"];
    NSData *datevalue = [ConverUtil parseHexStringToByteArray:date];
    
    Byte *byte=(Byte *)[datevalue bytes];
    
    if ([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"1001"]) {
        
        UIButton*btn1= _custombike.vehicleStateView.bikeLockBtn;
        UIButton*btn2= _custombike.vehicleStateView.bikeSwitchBtn;
        UIButton*btn3= _custombike.vehicleStateView.bikeSeatBtn;
        UIButton*btn4= _custombike.vehicleStateView.bikeMuteBtn;
        //A5000014100101000001DD016ACF000000000000
        querydate = date;
        NSString *binary = [QFTools getBinaryByhex:[date substringWithRange:NSMakeRange(12, 2)]];
        NSString *bikestate = [QFTools getBinaryByhex:[date substringWithRange:NSMakeRange(28, 2)]];
        NSString *keystatenumber = [QFTools getBinaryByhex:[date substringWithRange:NSMakeRange(16, 2)]];
        
        if (byte[14] == 0) {
            
            _custombike.vehicleConfigurationView.bikeTestImge.image = [UIImage imageNamed:@"vehicle_physical_examination"];
            self.faultmodel.motorfault = 0;
            self.faultmodel.rotationfault = 0;
            self.faultmodel.controllerfault = 0;
            self.faultmodel.brakefault = 0;
            self.faultmodel.lackvoltage = 0;
            self.faultmodel.motordefectNum = 0;
            
        }else{
            
            _custombike.vehicleConfigurationView.bikeTestImge.image = [UIImage imageNamed:@"bike_fault"];
            if([[bikestate substringWithRange:NSMakeRange(7, 1)] isEqualToString:@"1"]){
                //电机故障
                self.faultmodel.motorfault = 1;
                
            }else if([[bikestate substringWithRange:NSMakeRange(7, 1)] isEqualToString:@"0"]){
            
                self.faultmodel.motorfault = 0;
            }
            
            if([[bikestate substringWithRange:NSMakeRange(6, 1)] isEqualToString:@"1"]){
                //转把故障
                self.faultmodel.rotationfault = 1;
                
            }else if([[bikestate substringWithRange:NSMakeRange(6, 1)] isEqualToString:@"0"]){
                
                self.faultmodel.rotationfault = 0;
            }
            
            if([[bikestate substringWithRange:NSMakeRange(5, 1)] isEqualToString:@"1"]){
                //控制器故障
                
                self.faultmodel.controllerfault = 1;
            }else if([[bikestate substringWithRange:NSMakeRange(5, 1)] isEqualToString:@"0"]){
                
                self.faultmodel.controllerfault = 0;
            }
            
            if([[bikestate substringWithRange:NSMakeRange(4, 1)] isEqualToString:@"1"]){
                //控制器故障
                
                self.faultmodel.motordefectNum = 1;
            }else if([[bikestate substringWithRange:NSMakeRange(4, 1)] isEqualToString:@"0"]){
                
                self.faultmodel.motordefectNum = 0;
            }
            
            if([[bikestate substringWithRange:NSMakeRange(3, 1)] isEqualToString:@"1"]){
                //刹车故障
                self.faultmodel.brakefault = 1;
                
            }else if([[bikestate substringWithRange:NSMakeRange(3, 1)] isEqualToString:@"0"]){
                
                self.faultmodel.brakefault = 0;
            }
            
            if([[bikestate substringWithRange:NSMakeRange(2, 1)] isEqualToString:@"1"]){
                //电池欠压故障
                self.faultmodel.lackvoltage = 1;
                
            }else if([[bikestate substringWithRange:NSMakeRange(2, 1)] isEqualToString:@"0"]){
                
                self.faultmodel.lackvoltage = 0;
            }
        }
        
        if ([[keystatenumber substringWithRange:NSMakeRange(7, 1)] isEqualToString:@"1"]) {
            keyInduction = YES;
        }else if ([[keystatenumber substringWithRange:NSMakeRange(7, 1)] isEqualToString:@"0"]){
            keyInduction = NO;
        }
        
        if ([[binary substringWithRange:NSMakeRange(7, 1)] isEqualToString:@"0"]) {
            
            [btn1 setImage:[UIImage imageNamed:@"icon_bike_lock_blue"] forState:UIControlStateNormal];
            fortification = NO;
        }else if ([[binary substringWithRange:NSMakeRange(7, 1)] isEqualToString:@"1"]){
            
            [btn1 setImage:[UIImage imageNamed:@"icon_bike_unlock_blue"] forState:UIControlStateNormal];
            fortification = YES;
        }
        
        if (!fortification && powerswitch) {
            riding = YES;
        }
        _custombike.bikeHeadView.vehicleView.bikestateImge.image = [UIImage imageNamed:@"icon_bike_check_connect"];
        _custombike.bikeHeadView.vehicleView.bikestateLabel.text = NSLocalizedString(@"has_connect", nil);
        _custombike.bikeHeadView.vehicleView.bikestateLabel.textColor = [UIColor whiteColor];
        
        if ([[binary substringWithRange:NSMakeRange(6, 1)] isEqualToString:@"0"]) {
            
            [btn2 setImage:[UIImage imageNamed:@"close_the_switch"] forState:UIControlStateNormal];
            powerswitch = NO;
            riding = NO;
            
        }else{
            
            [btn2 setImage:[UIImage imageNamed:@"open_the_switch"] forState:UIControlStateNormal];
            powerswitch = YES;
        }
        
        if ([[binary substringWithRange:NSMakeRange(5, 1)] isEqualToString:@"0"]) {
            
            if (_custombike.vehicleStateView.chamberpot) {
                
                [btn4 setImage:[UIImage imageNamed:@"bike_close_mute_icon"] forState:UIControlStateNormal];
                
            }else{
            
                [btn3 setImage:[UIImage imageNamed:@"bike_close_mute_icon"] forState:UIControlStateNormal];
            }
            
        }else{
            
            if (_custombike.vehicleStateView.chamberpot) {
                
                [btn4 setImage:[UIImage imageNamed:@"bike_open_mute_icon"] forState:UIControlStateNormal];
                
            }else{
            
                [btn3 setImage:[UIImage imageNamed:@"bike_open_mute_icon"] forState:UIControlStateNormal];
            }
        }
        
        if ([[binary substringWithRange:NSMakeRange(3, 2)] isEqualToString:@"00"]) {
            
            self.shockState = NSLocalizedString(@"low", nil);
        }else if([[binary substringWithRange:NSMakeRange(3, 2)] isEqualToString:@"01"]){
            
            self.shockState = NSLocalizedString(@"middle", nil);
        }else if([[binary substringWithRange:NSMakeRange(3, 2)] isEqualToString:@"10"]){
            
            self.shockState = NSLocalizedString(@"high", nil);
        }
        
        NSInteger rssi = byte[13] - 255;
        if (phoneInduction) {
            
            NSInteger rssivalue = -Inductionvalue;
            
            if (rssi >= rssivalue && fortification) {

                if (riding) {
                    return;
                }
                NSString *passwordHEX = @"A5000007200101";
                [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];

            }else if (rssi < rssivalue - 8 && !fortification){

                if (riding) {
                    return;
                }
                NSString *passwordHEX = @"A5000007200102";
                [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
            }
        }
        
    }else if([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"6002"]){
    
       // self.bikestatedetail.text = @"车辆状态:异常";
    }else if([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"1002"]){
        
        if ([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"00"]) {
            [SVProgressHUD showSimpleText:NSLocalizedString(@"bike_passwd_wrong_content", nil)];
            [[AppDelegate currentAppDelegate].device remove];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
                
                if (_custombike.haveGPS) {
                    
                    _custombike.bikeHeadView.bikeStateImg.image = [UIImage imageNamed:@"bike_BLE_braekconnect"];
                    _custombike.bikeHeadView.bikeBleLab.text = NSLocalizedString(@"no_connect_state", nil);
                    _custombike.bikeHeadView.bikeBleLab.textColor = [UIColor whiteColor];
                    
                }else if(!_custombike.haveCentralControl){
                    
                    _custombike.bikeHeadView.vehicleView.bikestateLabel.text = NSLocalizedString(@"no_connect_state", nil);
                    _custombike.bikeHeadView.vehicleView.bikestateLabel.textColor = [UIColor whiteColor];
                }
            });
            
        }else if ([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"01"]){
            
            [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:@"A5000007200300"]];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:@"A5000007300302"]];
            });
        }
    }
}



#pragma mark - 开关手机感应
-(void) regulatePhoneInduction:(BOOL)isOpen{
    
    if (isOpen) {
        
        phoneInduction = YES;
    }else{
        
        phoneInduction = NO;
    }
    
    NSString *phInductionQuerySql = [NSString stringWithFormat:@"SELECT * FROM induction_modals WHERE bikeid LIKE '%zd'", self.bikeid];
    NSMutableArray *inducmodals = [LVFmdbTool queryInductionData:phInductionQuerySql];
    InductionModel *induction = inducmodals.firstObject;
    if (inducmodals.count == 0) {
        Inductionvalue = 70;
    }else{
        Inductionvalue = induction.inductionValue;
    }
}

#pragma mark - 修改手机感应值
-(void) regulatePhoneInductionValue:(NSInteger)phInductionValue{
    
    Inductionvalue = phInductionValue;
}


#pragma mark - 车辆解绑
-(void)submitUnbundDevice:(NSInteger)bikeid{
    
    NSMutableArray *bikeAry = [LVFmdbTool queryBikeData:nil];
    BikeModel *bikemodel = bikeAry.firstObject;
    [self switchingVehicle:bikemodel.bikeid];//默认连接第一辆车
    [self setupmenu];
}

#pragma mark - 切换车辆处理
- (void)switchingVehicle:(NSInteger)bikeid{
    [[AppDelegate currentAppDelegate].device stopScan];
    NSString *QueryBikeSql = [NSString stringWithFormat:@"SELECT * FROM bike_modals WHERE bikeid LIKE '%zd'", bikeid];
    NSMutableArray *bikemodals = [LVFmdbTool queryBikeData:QueryBikeSql];
    BikeModel *model = bikemodals.firstObject;
    if (self.bikeid == model.bikeid && [[AppDelegate currentAppDelegate].device isConnected]) {
        
        return;
    }else{
    
        [[AppDelegate currentAppDelegate].device remove];
        [_custombike viewReset];
    }
    
    [self.navView.leftButton setTitle:[NSString stringWithFormat:@"  %@",model.bikename] forState:UIControlStateNormal];
    self.mac = model.mac;
    self.bikeid = model.bikeid;
    _custombike.bikeid = model.bikeid;
    [_custombike.vehicleStateView setupFootView:model.keyversion.intValue];
    [USER_DEFAULTS setValue:model.mac forKey:SETRSSI];
    [USER_DEFAULTS setObject: model.mac forKey:Key_MacSTRING];
    [USER_DEFAULTS synchronize];
    
    uuidstring = nil;
    editionname = nil;
    self.ownerflag = model.ownerflag;
    if (model.ownerflag == 1) {
        
        self.password = model.mainpass;
        NSString* masterpwd = [QFTools toHexString:(long)[self.password longLongValue]];
        
        if(masterpwd.length !=8){
            int masterpwdCount = 8 - (int)masterpwd.length;
            for (int i = 0; i<masterpwdCount; i++) {
                masterpwd = [@"0" stringByAppendingFormat:@"%@",masterpwd];
            }
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                NSDictionary *userDic = [NSDictionary dictionaryWithObjectsAndKeys:masterpwd,@"main",nil];
                [USER_DEFAULTS setObject:userDic forKey:passwordDIC];
                [USER_DEFAULTS synchronize];
            });
            
        }else{
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                NSDictionary *userDic = [NSDictionary dictionaryWithObjectsAndKeys:masterpwd,@"main",nil];
                [USER_DEFAULTS setObject:userDic forKey:passwordDIC];
                [USER_DEFAULTS synchronize];
            });
        }
        
    }else if (model.ownerflag == 0){
        
        self.password = model.password;
        NSString* masterpwd = [QFTools toHexString:(long)[self.password longLongValue]];
        
        if(masterpwd.length !=8){
            
            int masterpwdCount = 8 - (int)masterpwd.length;
            for (int i = 0; i<masterpwdCount; i++) {
                masterpwd = [@"0" stringByAppendingFormat:@"%@",masterpwd];
            }
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                NSDictionary *userDic = [NSDictionary dictionaryWithObjectsAndKeys:masterpwd,@"main",nil];
                [USER_DEFAULTS setObject:userDic forKey:passwordDIC];
                [USER_DEFAULTS synchronize];
            });
            
        }else{
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                NSDictionary *userDic = [NSDictionary dictionaryWithObjectsAndKeys:masterpwd,@"main",nil];
                [USER_DEFAULTS setObject:userDic forKey:passwordDIC];
                [USER_DEFAULTS synchronize];
            });
        }
    }
    
    NSString *QueryuuidSql = [NSString stringWithFormat:@"SELECT * FROM peripherauuid_modals WHERE mac LIKE '%@'", model.mac];
    NSMutableArray *uuidmodals = [LVFmdbTool queryPeripheraUUIDData:QueryuuidSql];
    PeripheralUUIDModel *peripheraluuidmodel = uuidmodals.firstObject;
    if (uuidmodals.count == 0) {
        [USER_DEFAULTS removeObjectForKey:Key_DeviceUUID];
        [[AppDelegate currentAppDelegate].device startScan];
    }else{
    
        uuidstring = peripheraluuidmodel.uuid;
        [self showDeviceList];
    }
}


#pragma mark---主页车辆扫描的回调
-(void)didDiscoverPeripheral:(NSInteger)tag :(CBPeripheral *)peripheral scanData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    
    if (peripheral.name.length < 13) {
        
        return;
    }
    
    if([[peripheral.name substringWithRange:NSMakeRange(0, 13)]isEqualToString: @"Qgj-SmartBike"]){
        NSString *title = [ConverUtil data2HexString:[advertisementData objectForKey:@"kCBAdvDataManufacturerData"]];
        if (title == NULL) {
            return;
        }
        
        if ([self.mac isEqualToString:[title substringWithRange:NSMakeRange(4, 12)].uppercaseString]){
            uuidstring = peripheral.identifier.UUIDString;
            [self showDeviceList];
        }
    }
}

#pragma mark - ManagerDelegate
/* 修改车名，主界面导航栏刷新回调 */
-(void)manager:(Manager *)manager updatebikeName:(NSString *)name :(NSInteger)bikeId{
    
    if (self.bikeid == bikeId) {
        
        [self.navView.leftButton setTitle:[NSString stringWithFormat:@"  %@",name] forState:UIControlStateNormal];
        [self setupmenu];
    }
}

/* 绑定配件，页面刷新回调 */
-(void)manager:(Manager *)manager bindingPeripheralSucceeded:(PeripheralModel *)model{
    
    if (model.type == 4){
        _custombike.haveGPS = YES;
    }else if (model.type == 8){
        _custombike.haveCentralControl = YES;
    }
}

/* 删除配件，页面刷新回调 */
-(void)manager:(Manager *)manager deletePeripheralSucceeded:(PeripheralModel *)model{
    
    if (model.type == 4){
        _custombike.haveGPS = NO;
    }else if (model.type == 8){
        _custombike.haveCentralControl = NO;
    }
}


/* 点击车库的cell 切换车辆回调 */
-(void)manager:(Manager *)manager switchingVehicle:(NSDictionary *)dict{
    NSInteger biketag = [dict[@"biketag"] integerValue];
    [self switchingVehicle:biketag];
}

#pragma mark - 控制器释放
- (void)dealloc {
    
    [[AppDelegate currentAppDelegate].device stopScan];
    [self unObserveAllNotifications];
    [self.queraTime invalidate];
    self.queraTime = nil;
    [[Manager shareManager] deleteDelegate:self];
}

- (void)unObserveAllNotifications {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


@end
