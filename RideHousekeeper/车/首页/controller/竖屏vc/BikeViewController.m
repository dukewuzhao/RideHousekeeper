//
//  BikeViewController.m
//  RideHousekeeper
//
//  Created by 同时科技 on 16/6/20.
//  Copyright © 2016年 Duke Wu. All rights reserved.
//

#import "BikeViewController.h"
#import "BindingUserViewController.h"
#import "SubmitViewController.h"
#import "SideMenuViewController.h"
#import "TwoDimensionalCodecanViewController.h"
#import "AddBikeViewController.h"
#import "GPSActivationViewController.h"
#import "BikeViewController+UpdateCustomBikeView.h"
#import "Constants.h"
#import "Utility.h"
#import "QuartzCore/QuartzCore.h"
#import "LrdOutputView.h"
#import "CustomProgress.h"
#import "DfuDownloadFile.h"
#import "DroppyScrollView.h"
#import "MainScrollerView.h"
#import "CustomBike.h"
#import "MJDIYHeader.h"
#import "NameAlertView.h"
#import "Manager.h"
#import "BikeStatusModel.h"
#import "DeviceModel.h"
#import "SearchBleModel.h"
#import "UpdateViewModel.h"
#import "AnimationObjectProtocol.h"
#import <objc/message.h>

@import iOSDFULibrary;

@interface BikeViewController ()<LoggerDelegate, DFUServiceDelegate, DFUProgressDelegate,UIAlertViewDelegate,SubmitDelegate,AnimationObjectProtocol,ManagerDelegate>{
    NSMutableArray *rssiList;//搜索到的车辆的model数组
    NSMutableDictionary *uuidarray;//UUID字典
    NSInteger Inductionvalue;//手机感应的rssi值
    NSString *downloadhttp;//固件升级包地址
    NSString *editionname;//固件版本号
    CustomProgress *custompro;//自定义固件升级界面
    BOOL checkUpgrate;//点击固件版本检测
    BOOL phoneInduction;//手机感应是否打开
    NomalCommand commandType;
}
@property (nonatomic,copy)   NSString               *shockState;//震动灵敏度
@property (nonatomic,copy)   NSString               *latest_version;//最新的固件版本号
@property (nonatomic,weak)   UIWindow               *backView;//固件升级的背景窗口
@property (nonatomic,assign) NSInteger              bikeid;//车辆id
@property (nonatomic,copy)   NSString               *mac;//车辆mac地址
@property (nonatomic, strong)LrdOutputView          *outputView;//右上角弹出按钮
@property (nonatomic,weak)   LrdCellModel           *Lrdmodel;//弹出界面model
@property (nonatomic,copy)   NSArray                *chooseArray;//获取弹出界面model的数组
@property (strong,nonatomic) CBPeripheral           *selectedPeripheral;
@property (strong,nonatomic) DFUServiceController   *controller;
@property (nonatomic,strong) UIAlertView            *BluetoothUpgrateAlertView;
@property (nonatomic,strong) NSMutableArray         *customViewAry;// 主界面数组
@property (nonatomic,strong) DroppyScrollView       *droppy;
@property (nonatomic,assign) NSInteger              index;
@end

@implementation BikeViewController

@synthesize selectedPeripheral;
@synthesize controller;

- (NSMutableArray *)customViewAry {
    if (!_customViewAry) {
        _customViewAry = [NSMutableArray new];
    }
    return _customViewAry;
}

- (void)startblescan:(DeviceScanType)scanType{
    
    @weakify(self);
    [CommandDistributionServices startScan:scanType PeripheralList:^(NSMutableArray * arry) {
        @strongify(self);
        if (scanType == DeviceNomalType) {
            
            for (SearchBleModel *model in arry) {
                if ([self.mac isEqualToString:[model.mac uppercaseString]]){
                    [self storagePeripheraUUID:model.peripher.identifier.UUIDString];
                }
            }
        }else if (scanType == DeviceDFUType){
            
            self->rssiList = [arry mutableCopy];
            [self connectDfuModel];
        }else if (scanType == DeviceGPSType){
            for (SearchBleModel *model in arry) {
                NSLog(@"搜索到Mac%@--匹配Mac%@",model.mac,self.mac);
                if ([model.mac.uppercaseString isEqualToString:self.mac.uppercaseString]){
                    [self storagePeripheraUUID:model.peripher.identifier.UUIDString];
                }
            }
        }
    }];
}


-(void)monitorConnectStatus:(BOOL)status{
    
    CustomBike *custombike = [self getCustomBikeAtIndex:self.index];
    [self BLEConnectlogicalAllocation:custombike :self.BluetoothUpgrateAlertView :status];
    if (status) {
        editionname = nil;
        commandType = 0;
    }
}

-(CustomBike *)getCustomBikeAtIndex:(NSInteger)tag{
    if (self.index >= self.customViewAry.count) return nil;
    CustomBike *custombike = [self.customViewAry objectAtIndex:self.index];
    return custombike;
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:YES];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([QFTools isBlankString:[USER_DEFAULTS stringForKey:Key_DeviceUUID]] && [[APPStatusManager sharedManager] getBLEStstus]) {
        
        CustomBike *custombike = [self getCustomBikeAtIndex:self.index];
        if (custombike.viewType == 3) {
            [self startblescan:DeviceGPSType];
        }else{
            [self startblescan:DeviceNomalType];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if ([QFTools isBlankString:[USER_DEFAULTS stringForKey:Key_DeviceUUID]]) {
        
        [CommandDistributionServices stopScan];
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //self.view.layer.contents = (id)[UIImage imageNamed:@"icon_main_bg"].CGImage;
    [[Manager shareManager] addDelegate:self];
    rssiList=[[NSMutableArray alloc]init];
    uuidarray=[[NSMutableDictionary alloc]init];
    [self setupNavView];
    
    @weakify(self);
    [[[NSNOTIC_CENTER rac_addObserverForName:KNotification_QueryData object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id x) {
        @strongify(self);
        NSNotification *userInfo = x;
        BikeStatusModel *model = userInfo.object;
        [self BikeViewquerySuccess:model];
    }];
    
    
    [[[NSNOTIC_CENTER rac_addObserverForName:KNotification_ConnectStatus object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id x) {
        @strongify(self);
        NSNotification *userInfo = x;
        [self monitorConnectStatus:[userInfo.object boolValue]];
    }];
    
    [[[NSNOTIC_CENTER rac_addObserverForName:KNotification_BluetoothPowerOn object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id x) {
        @strongify(self);

        if (![[QFTools currentViewController] isKindOfClass:[AddBikeViewController class]]) {
            [self switchingVehicle:[USER_DEFAULTS integerForKey:Key_BikeId]];
        }
    }];
    
    [[[NSNOTIC_CENTER rac_addObserverForName:KNotification_BluetoothPowerOff object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id x) {
        @strongify(self);
        CustomBike *custombike = [self getCustomBikeAtIndex:self.index];
        [custombike viewReset];
        [CommandDistributionServices removePeripheral:nil];
        if ([[QFTools currentViewController] isKindOfClass:[BikeViewController class]] && [QFTools isBlankString:[USER_DEFAULTS stringForKey:Key_DeviceUUID]]) {
            
            [CommandDistributionServices stopScan];
        }
    }];
    
    [self setupmenu];
    [self setupBikeMenu];
    
    UIWindow *backView = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    backView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.7];
    backView.windowLevel = UIWindowLevelAlert;
    [[UIApplication sharedApplication].keyWindow addSubview:backView];
    self.backView = backView;
    backView.hidden = YES;
    
    custompro = [[CustomProgress alloc] initWithFrame:CGRectMake(50, self.view.centerY - 10, self.view.frame.size.width-100, 20)];
    custompro.maxValue = 100;
    custompro.leftimg.image = [UIImage imageNamed:@"leftimg"];
    custompro.bgimg.image = [UIImage imageNamed:@"bgimg"];
    custompro.instruc.image = [UIImage imageNamed:@"bike"];
    [backView addSubview:custompro];
}

-(void)setupBikeMenu{
    
    self.droppy = [[DroppyScrollView alloc] initWithFrame:CGRectMake(0, navHeight, ScreenWidth, ScreenHeight - navHeight)];
    [self.droppy setDefaultDropLocation:DroppyScrollViewDefaultDropLocationBottom];
    self.droppy.scrollEnabled = NO;
    [self.view addSubview:self.droppy];
    @weakify(self);
    self.droppy.scrollViewIndex = ^(NSInteger index,NSInteger bikeid){
        @strongify(self);
        self.index = index;
        [self switchingVehicle:bikeid];
    };
    [self setupScroview];
    
    [self switchingVehicle:[USER_DEFAULTS integerForKey:Key_BikeId]];
    
    if ([[APPStatusManager sharedManager] getActivatedJumpStstus]) {
        [[APPStatusManager sharedManager] setActivatedJumpStstus:NO];
        BikeModel* bikeModel = [[LVFmdbTool queryBikeData:[NSString stringWithFormat:@"SELECT * FROM bike_modals WHERE bikeid LIKE '%zd'", _bikeid]] firstObject];
        NSMutableArray *viewCtrs = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
        GPSActivationViewController *bindingVc = [[GPSActivationViewController alloc] init];
        [bindingVc setpGPSParameters:bikeModel];
        bindingVc.isOnlyGPSActivation = YES;
        [viewCtrs addObject:bindingVc];
        [self.navigationController setViewControllers:viewCtrs animated:YES];
    }
}

-(void)setupScroview{
    [self.customViewAry removeAllObjects];
    self.index = 0;
    NSMutableArray *bikeAry =[LVFmdbTool queryBikeData:nil];
    for (int i = 0; i < [LVFmdbTool queryBikeData:nil].count; i++) {
        
        MainScrollerView *scrollView = [[MainScrollerView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - navHeight)];
        scrollView.contentSize = CGSizeMake(ScreenWidth, ScreenHeight - navHeight + 1);
        scrollView.showsVerticalScrollIndicator = FALSE;
        scrollView.showsHorizontalScrollIndicator = FALSE;
        @weakify(scrollView);
        scrollView.mj_header = [MJDIYHeader headerWithRefreshingBlock:^{
            @strongify(scrollView);
            #pragma clang diagnostic push
            #pragma clang diagnostic ignored "-Wundeclared-selector"
            void(^success)(void) = ^(void){
                [[Manager shareManager] bikeViewUpdateForNewConnect:NO];
                [scrollView.mj_header endRefreshing];
            };
            [QFTools performSelector:@selector(logindata:) withTheObjects:@[success] withTarget:[AppDelegate currentAppDelegate]];
            #pragma clang diagnostic pop
        }];
        
        CustomBike *custombike = [[CustomBike alloc] initWithFrame:scrollView.bounds];
        [scrollView addSubview:custombike];
        
        [self.droppy dropSubview:scrollView atIndex:[self.droppy randomIndex]];
        [[self mutableArrayValueForKey:@"customViewAry"] addObject:custombike];
        BikeModel *bikemodel = bikeAry[i];
        [custombike.bikeHeadView.vehicleStateView setupFootView:bikemodel.keyversion.intValue];
        custombike.bikeid = bikemodel.bikeid;
        custombike.tpm_func = bikemodel.tpm_func;
        custombike.wheels = bikemodel.wheels;
        NSMutableArray *peripheraModals = [LVFmdbTool queryPeripheraData:[NSString stringWithFormat:@"SELECT * FROM periphera_modals WHERE type LIKE '%zd' AND bikeid LIKE '%zd'", 6,bikemodel.bikeid]];
        if (peripheraModals.count >0) {
            custombike.havePressureMonitoring = YES;
        }
        
        if (![QFTools isBlankString:bikemodel.sn]) {
            if (bikemodel.builtin_gps == 1) {
                custombike.viewType = 2;
            }else{
                NSMutableArray *peripheraModals = [LVFmdbTool queryPeripheraData:[NSString stringWithFormat:@"SELECT * FROM periphera_modals WHERE type LIKE '%zd' AND bikeid LIKE '%zd'", 4,bikemodel.bikeid]];
                if (peripheraModals.count == 0) {
                    custombike.viewType = 1;
                }else{
                    custombike.viewType = 2;
                }
            }
        }else{
            custombike.viewType = 3;
        }
    }
    [self setupPagecontrolNumber];
}


#pragma mark - 切换车辆处理
- (void)switchingVehicle:(NSInteger)bikeid{
    
    [CommandDistributionServices stopScan];
    BikeModel *model;
    NSMutableArray *bikeArry = [LVFmdbTool queryBikeData:[NSString stringWithFormat:@"SELECT * FROM bike_modals WHERE bikeid LIKE '%zd'", bikeid]];
    if (bikeArry.count > 0) {
        model = bikeArry.firstObject;
    }else{
        NSMutableArray *newBikeArry = [LVFmdbTool queryBikeData:[NSString stringWithFormat:@"SELECT * FROM bike_modals WHERE bikeid LIKE '%d'", [[self.customViewAry firstObject] bikeid]]];
        if (newBikeArry.count <= 0) {
            return;
        }
        model = newBikeArry.firstObject;
    }
    CustomBike *custombike = [self getCustomBikeAtIndex:self.index];
    [self.navView.centerButton setTitle:model.bikename forState:UIControlStateNormal];
    if (self.bikeid == model.bikeid && [CommandDistributionServices isConnect]) {
        
        return;
    }else{
    
        [CommandDistributionServices removePeripheral:nil];
        [custombike viewReset];
    }
    self.bikeid = bikeid;
    [USER_DEFAULTS setInteger:bikeid forKey:Key_BikeId];
    [USER_DEFAULTS synchronize];
    
    [[self.customViewAry copy] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([(CustomBike *)obj viewType] != 1) {
            [(CustomBike *)obj stopTimer];
        }
    }];
    
    NSMutableArray *modals = [LVFmdbTool queryInductionData:[NSString stringWithFormat:@"SELECT * FROM induction_modals WHERE bikeid LIKE '%zd'", bikeid]];
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
    
    editionname = nil;
    NSMutableArray *brandmodals = [LVFmdbTool queryBrandData:[NSString stringWithFormat:@"SELECT * FROM brand_modals WHERE bikeid LIKE '%zd'", model.bikeid]];
    BrandModel *brandmodel = brandmodals.firstObject;

    if (brandmodals.count != 0) {
        //[custombike.bikeHeadView.bikeLogo sd_setImageWithURL:[NSURL URLWithString:brandmodel.logo]];
        [custombike.bikeHeadView.bikeLogo sd_setImageWithURL:[NSURL URLWithString:brandmodel.logo] placeholderImage:[UIImage imageNamed:@"brand_logo"]];
    }
    DeviceScanType type;
     if (custombike.viewType == 3){
         type = DeviceGPSType;
         PeripheralModel *deviceModel = [[LVFmdbTool queryPeripheraData:[NSString stringWithFormat:@"SELECT * FROM periphera_modals WHERE type LIKE '%zd' AND bikeid LIKE '%zd'", 4,bikeid]] firstObject];
         self.mac = deviceModel.mac;
         [custombike begainTimer];
    }else{
        type = DeviceNomalType;
        self.mac = model.mac;
        if (custombike.viewType == 2) {
            [custombike begainTimer];
        }
    }
    if ([[APPStatusManager sharedManager] getBLEStstus]) {
        NSMutableArray *uuidmodals = [LVFmdbTool queryPeripheraUUIDData:[NSString stringWithFormat:@"SELECT * FROM peripherauuid_modals WHERE bikeid LIKE '%zd'", bikeid]];
        PeripheralUUIDModel *peripheraluuidmodel = uuidmodals.firstObject;
        if (uuidmodals.count == 0) {
            [USER_DEFAULTS removeObjectForKey:Key_DeviceUUID];
            [self startblescan:type];
        }else{
            [self connectPeripheraByUUID:peripheraluuidmodel.uuid];
        }
    }
}

#pragma mark - 获取到车辆的UUID后的连接
-(void)connectPeripheraByUUID:(NSString *)uuid{
    
    [CommandDistributionServices stopScan];
    [CommandDistributionServices connectPeripheralByUUIDString:uuid];
    [USER_DEFAULTS setObject: uuid forKey:Key_DeviceUUID];
    [USER_DEFAULTS synchronize];
}
#pragma mark - 获取到后存储车辆的UUID
-(void)storagePeripheraUUID:(NSString *)uuid{
    
    [LVFmdbTool deletePeripheraUUIDData:[NSString stringWithFormat:@"DELETE FROM peripherauuid_modals WHERE uuid LIKE '%%%@%%'", uuid]];
    PeripheralUUIDModel *peripheramodel = [PeripheralUUIDModel modalWith:[QFTools getdata:@"phone_num"] bikeid:self.bikeid mac:self.mac uuid:uuid];
    [LVFmdbTool insertPeripheralUUIDModel:peripheramodel];
    [self connectPeripheraByUUID:uuid];
}

-(void)setupPagecontrolNumber{
    
    NSMutableArray *bikeAry =[LVFmdbTool queryBikeData:nil];
    for (int i = 0; i< bikeAry.count; i++) {
        BikeModel *bikemodel = bikeAry[i];
        if (bikemodel.bikeid == [USER_DEFAULTS integerForKey:Key_BikeId]) {
            //通过匹配mac地址确定currentPage
            self.index = i;
            self.droppy.selectIndex = i;
            [self.droppy setContentOffset:CGPointMake(ScreenWidth * i, 0) animated:NO];
        }
    }
}

- (void)setupNavView{
    [super setupNavView];
    self.navView.backgroundColor = [QFTools colorWithHexString:MainColor];
    self.navView.showBottomLabel = NO;
    [self.navView.centerButton setTitle:@"智能电动车" forState:UIControlStateNormal];
    @weakify(self);
    [self.navView.leftButton setImage:[UIImage imageNamed:@"open_slide_menu"] forState:UIControlStateNormal];
    self.navView.leftButtonBlock = ^{
        @strongify(self);
        [self XYSideOpenVC];
    };
    
    [self.navView.rightButton setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
    self.navView.rightButtonBlock  = ^{
        @strongify(self);
        
        [self showaddView];
    };
    
    [RACObserve(self, customViewAry) subscribeNext:^(id x) {
        @strongify(self);
        if ([[x copy] count] >1) {
            if (!self.navView.switchingOptions) {
                self.navView.switchingOptions = YES;
            }
        }else{
            if (self.navView.switchingOptions) {
                self.navView.switchingOptions = NO;
            }
        }
    }];
}

#pragma mark -  LrdOutputView
-(void)showaddView{
    
    CGFloat x = ScreenWidth - 15;
    CGFloat y = navHeight +5;
    _outputView = [[LrdOutputView alloc] initWithDataArray:self.chooseArray origin:CGPointMake(x, y) width:100 height:44 direction:kLrdOutputViewDirectionRight];
    _outputView.dismissOperation = ^(){
        _outputView = nil;
    };
    @weakify(self);
    _outputView.selectedIndexPath = ^(NSIndexPath *indexPath) {
        @strongify(self);
        if (indexPath.row == 0) {
            
            [self.navigationController pushViewController:[AddBikeViewController new] animated:YES];
        }else if (indexPath.row == 1){

            if (![CommandDistributionServices isConnect]) {

                [SVProgressHUD showSimpleText:@"车辆未连接"];
                return;
            }
            
            NSString *bikeQuerySql = [NSString stringWithFormat:@"SELECT * FROM bike_modals WHERE bikeid LIKE '%zd'", self.bikeid];
            NSMutableArray *bikemodals = [LVFmdbTool queryBikeData:bikeQuerySql];
            BikeModel *bikemodel = bikemodals.firstObject;
            if (bikemodel.ownerflag == 0) {
                
                [SVProgressHUD showSimpleText:@"子用户无此权限"];
                return;
            }

            TwoDimensionalCodecanViewController *scanVc = [TwoDimensionalCodecanViewController new];
            scanVc.naVtitle = @"添加配件";
            scanVc.bikeid = self.bikeid;
            [self.navigationController pushViewController:scanVc animated:YES];
        }else {
            
            BindingUserViewController *bindingUserVc = [BindingUserViewController new];
            bindingUserVc.bikeid = self.bikeid;
            [self.navigationController pushViewController:bindingUserVc animated:YES];
            
        }
    };
    [_outputView pop];
}


#pragma mark -  获取报警器固件版本号的逻辑处理
-(void)editionData:(NSString *)data{
    
    if ([[APPStatusManager sharedManager] getBikeFirmwareUpdateStstus] || [[APPStatusManager sharedManager] getBikeBindingStstus] ) {
        
        return;
    }else if (data.length < 6){
        return;
    }
    
    NSString *editiontitle = data;
    if ([editiontitle isEqualToString:editionname] && self.bikeid == 0) {
        NSLog(@"退出更新");
        return;
    }
    editionname = data;
    NSString *token = [QFTools getdata:@"token"];
    NSNumber *bikeid = [NSNumber numberWithInteger:self.bikeid];
    NSString *URLString = [NSString stringWithFormat:@"%@%@",QGJURL,@"app/checkfirmupdate"];
    NSDictionary *parameters = @{@"token":token, @"bike_id": bikeid};
    [[HttpRequest sharedInstance] postWithURLString:URLString parameters:parameters success:^(id _Nullable dict) {
        
        if ([dict[@"status"] intValue] == 0) {
            
            NSDictionary *data = dict[@"data"];
            NSString *latest_version = data[@"latest_version"];
            NSNumber *upgrade = data[@"upgrade_flag"];
            downloadhttp = data[@"download"];
            _latest_version = latest_version;
            if (latest_version.length == 0) {
                if (checkUpgrate) {
                    [SVProgressHUD showSimpleText:@"已是最新固件"];
                    checkUpgrate = NO;
                }
                [USER_DEFAULTS setBool:NO forKey:[NSString stringWithFormat:@"%zd",self.bikeid]];
                [USER_DEFAULTS synchronize];
                return ;
            }
            
            if ([[latest_version substringWithRange:NSMakeRange(0, latest_version.length - 6)] isEqualToString:[editiontitle substringWithRange:NSMakeRange(0, editiontitle.length - 6)]]) {
                NSString *NetworktVersion = [latest_version substringFromIndex:latest_version.length- 5];
                NSString *CurrentVersion = [editiontitle substringFromIndex:editiontitle.length- 5];
                CurrentVersion = [CurrentVersion stringByReplacingOccurrencesOfString:@"." withString:@""];
                if (CurrentVersion.length==2) {
                    CurrentVersion  = [CurrentVersion stringByAppendingString:@"0"];
                }else if (CurrentVersion.length==1){
                    CurrentVersion  = [CurrentVersion stringByAppendingString:@"00"];
                }
                NetworktVersion = [NetworktVersion stringByReplacingOccurrencesOfString:@"." withString:@""];
                if (NetworktVersion.length==2) {
                    NetworktVersion  = [NetworktVersion stringByAppendingString:@"0"];
                }else if (NetworktVersion.length==1){
                    NetworktVersion  = [NetworktVersion stringByAppendingString:@"00"];
                }
                //当前版本号大于网络版本
                if([CurrentVersion intValue] >= [NetworktVersion intValue]){
                    if (checkUpgrate) {
                        [SVProgressHUD showSimpleText:@"已是最新固件"];
                        checkUpgrate = NO;
                    }

                    [USER_DEFAULTS setBool:NO forKey:[NSString stringWithFormat:@"%zd",self.bikeid]];
                    [USER_DEFAULTS synchronize];
                    return;
                }
                
                if (![latest_version isEqualToString:editiontitle]){
                    [USER_DEFAULTS setBool:YES forKey:[NSString stringWithFormat:@"%zd",self.bikeid]];
                    [USER_DEFAULTS synchronize];
                    
                    if (upgrade.intValue == 0) {
                        
                        if (checkUpgrate) {
                            
                            self.BluetoothUpgrateAlertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"检测到固件新版本,立即更新吗" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"立即更新", nil];
                            self.BluetoothUpgrateAlertView.tag = 54;
                            [self.BluetoothUpgrateAlertView show];
                            checkUpgrate = NO;
                        }
                        
                    }else if (upgrade.intValue == 1){
                        
                        self.BluetoothUpgrateAlertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"检测到固件新版本,立即更新吗" delegate:self cancelButtonTitle:nil otherButtonTitles:@"立即更新", nil];
                        self.BluetoothUpgrateAlertView.tag = 55;
                        [self.BluetoothUpgrateAlertView show];
                        checkUpgrate = NO;
                    }
                }else{
                    checkUpgrate = NO;
                }
            }
        }else{
            
            [SVProgressHUD showSimpleText:dict[@"status_info"]];
        }
        
    }failure:^(NSError *error) {
        NSLog(@"error :%@",error);
        [SVProgressHUD showSimpleText:TIP_OF_NO_NETWORK];
    }];
}

-(NSInteger)getBikeId{
    return _bikeid;
}

#pragma mark -  主页面alertview的回调
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (![CommandDistributionServices isConnect]) {

        [SVProgressHUD showSimpleText:@"车辆未连接"];
        return;
    }
    if (alertView.tag == 54) {
        if (buttonIndex != [alertView cancelButtonIndex]) {
            self.backView.hidden = NO;
            [self->custompro startAnimation];
            self->custompro.presentlab.text = @"车辆正在连接中...";
            [self DownloadDFUFile:downloadhttp];
        }
    }else if (alertView.tag == 55){
    
        if (buttonIndex != [alertView cancelButtonIndex]) {
            self.backView.hidden = NO;
            [self->custompro startAnimation];
            self->custompro.presentlab.text = @"车辆正在连接中...";
            [self DownloadDFUFile:downloadhttp];
        }
    }
}

-(void)DownloadDFUFile:(NSString *)url{
    @weakify(self);
    [DfuDownloadFile downloadURL:url progress:^(NSProgress *downloadProgress) {
        
        //下载进度
        NSString *progress = [NSString stringWithFormat:@"下载:%f%%",100.0 * downloadProgress.completedUnitCount/downloadProgress.totalUnitCount];
        NSLog(@"%@",progress);
    } destination:^void(NSURL *targetPath) {//下载完毕
        //targetPath下载完成的本地存储路径
        //下载完成后的处理
        [[APPStatusManager sharedManager] setBikeFirmwareUpdateStstus:YES];
        [CommandDistributionServices enterFirmwareUpgrade:^(id data) {
            @strongify(self);
            if ([data intValue] == ConfigurationFail) {
                
                [SVProgressHUD showSimpleText:@"进入固件升级失败"];
            }else{
                
                [self->rssiList removeAllObjects];
                [CommandDistributionServices removePeripheral:nil];
                [self breakconnect];
            }
            
            [self performSelector:@selector(connectDefaultModel) withObject:nil afterDelay:20];
            
        } error:^(CommandStatus status) {
            switch (status) {
                case SendSuccess:
                    NSLog(@"进入固件模式");
                    break;
                default:
                    NSLog(@"进入固件模式失败");
                    break;
            }
        }];
        
    } failure:^(NSError *error) {
        //下载过程中遇到的错误
        [SVProgressHUD showSimpleText:@"下载中断"];
        [custompro stopAnimation];
        self.backView.hidden = YES;
    }];
}

//******************????升级文件下载代码??*******************//

#pragma mark -  LrdOutputViewcell
- (void)setupmenu{
    
    LrdCellModel *one = [[LrdCellModel alloc] initWithTitle:@"添加车辆"];
    LrdCellModel *two = [[LrdCellModel alloc] initWithTitle:@"添加配件"];
    LrdCellModel *three = [[LrdCellModel alloc] initWithTitle:@"分享车辆"];
    
    self.chooseArray = @[one,two,three];
}

#pragma mark - 0.5循环秒查询蓝牙数据返回
-(void)BikeViewquerySuccess:(BikeStatusModel *)model{
    
    CustomBike *custombike = [self getCustomBikeAtIndex:self.index];
    custombike.bikeStatusModel = model;
    [self updateCustomView:custombike :model];
    if (self->phoneInduction) {
        
        NSInteger rssivalue = -self->Inductionvalue;
        
        if (model.rssiValue >= rssivalue && model.isLock) {
            
            if (model.isElectricDoorOpen || commandType == DeviceInductionOutSafe) {
                return;
            }
            commandType = DeviceInductionOutSafe;
            [CommandDistributionServices setBikeBasicStatues:DeviceInductionOutSafe error:nil];
            
        }else if (model.rssiValue < rssivalue - 10 && !model.isLock){
            
            if (model.isElectricDoorOpen || commandType == DeviceInductionSetSafe) {
                return;
            }
            commandType = DeviceInductionSetSafe;
            [CommandDistributionServices setBikeBasicStatues:DeviceInductionSetSafe error:nil];
        }
    }
        
}

#pragma mark - 进入固件升级先主动断开再连接
- (void)breakconnect{

    [self startblescan:DeviceDFUType];
}

-(void)connectDefaultModel{

    [SVProgressHUD showSimpleText:@"固件升级失败"];
    [CommandDistributionServices stopScan];
    [custompro stopAnimation];
    BOOL result = [controller abort];
    [self clearUI];
    [self connectBle];

}

#pragma mark - 进入升级模式后连接车辆
- (void)connectDfuModel{
    
    [CommandDistributionServices stopScan];
    [custompro stopAnimation];
    if(rssiList.count>0){
        custompro.presentlab.text = @"正在固件升级中...";
        [self uploadPressed];
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

#pragma mark - 固件升级处理
-(void)submitBegainUpgrate{
    
    
}

//*******************???固件升级????*******************//

-(void)uploadPressed
{
    if (controller){
        // Pause the upload process. Pausing is possible only during upload, so if the device was still connecting or sending some metadata it will continue to do so,
        // but it will pause just before seding the data.
        [controller pause];
        
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"中止固件升级?" message:@"你想中止固件升级?" preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction* abort = [UIAlertAction
                                actionWithTitle:@"中止"
                                style:UIAlertActionStyleDestructive
                                handler:^(UIAlertAction * action){
                                    // Abort upload process
                                    BOOL result = [self->controller abort];
                                    [alert dismissViewControllerAnimated:YES completion:nil];
                                    
                                }];
        UIAlertAction* cancel = [UIAlertAction
                                 actionWithTitle:@"取消"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     // Resume upload
                                     [self->controller resume];
                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                 }];
        [alert addAction:abort];
        [alert addAction:cancel];
        [self presentViewController:alert animated:YES completion:nil];
    }else{
        [self performSelector:@selector(performDFU) withObject:nil afterDelay:2];
    }
}


-(void)performDFU{
    
    [self registerObservers];
    NSString *pathDocuments = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [pathDocuments stringByAppendingPathComponent:Downloadfile];
    NSURL *URL = [NSURL fileURLWithPath:filePath];
    DFUFirmware *selectedFirmware = nil;
    NSString *fileNameComponent = URL.lastPathComponent;
    NSString *extension = [[fileNameComponent pathExtension] lowercaseString];
    
    if ([extension isEqualToString:@"zip"]){
        selectedFirmware = [[DFUFirmware alloc] initWithUrlToZipFile:URL];
        
        if (selectedFirmware && selectedFirmware.fileName){
            
        }else{
            selectedFirmware = nil;
            [Utility showAlert:@"该文件不支持升级"];
        }
    }
    
    if(rssiList.count>0){
        custompro.presentlab.text = @"正在固件升级中...";
        //self.backView.hidden = NO;
        NSArray *dfuArray = [rssiList sortedArrayUsingComparator:^NSComparisonResult(DeviceModel* obj1, DeviceModel* obj2)
                             {
                                 float f1 = fabsf([obj1.rssi floatValue]);
                                 float f2 = fabsf([obj2.rssi floatValue]);
                                 if (f1 > f2)
                                 {
                                     return (NSComparisonResult)NSOrderedDescending;
                                 }
                                 if (f1 < f2)
                                 {
                                     return (NSComparisonResult)NSOrderedAscending;
                                 }
                                 return (NSComparisonResult)NSOrderedSame;
                             }];
        selectedPeripheral = [[dfuArray objectAtIndex:0] peripher];
        
        DFUServiceInitiator *initiator = [[DFUServiceInitiator alloc] initWithCentralManager:[CommandDistributionServices getCentralManager] target:selectedPeripheral];
        /** 旧方法 */
        //[initiator withFirmwareFile:selectedFirmware];
        /** 新方法 */
        initiator = [initiator withFirmware:selectedFirmware];
        initiator.forceDfu = NO;
        initiator.packetReceiptNotificationParameter = 12;//调整升级速度 ---每次写入多少个包
        initiator.logger = self;
        initiator.delegate = self;
        initiator.progressDelegate = self;
        initiator.enableUnsafeExperimentalButtonlessServiceInSecureDfu = YES;
        // initiator.peripheralSelector = ... // the default selector is used
        
        controller = [initiator start];
    }
}


- (void)clearUI{
    
    controller = nil;
    selectedPeripheral = nil;
    [self unregisterObservers];
    [CommandDistributionServices restCentralManagerStatus];
}

#pragma mark - Supoprt for background mode

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
    if (controller)
    {
        [Utility showBackgroundNotification:@"固件升级中..."];
    }
}

-(void)appDidEnterForeground:(NSNotification *)_notification
{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}



#pragma mark - DFU Service delegate methods

-(void)logWith:(enum LogLevel)level message:(NSString *)message
{
    NSLog(@"%ld: %@", (long) level, message);
}

-(void)dfuStateDidChangeTo:(enum DFUState)state
{
    switch (state) {
        case DFUStateConnecting:
            NSLog(@"Connecting...");
            break;
        case DFUStateStarting:
            NSLog(@"Starting DFU...");
            [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(connectDefaultModel) object:nil];
            break;
        case DFUStateEnablingDfuMode:
            NSLog(@"Enabling DFU Bootloader...");
            break;
        case DFUStateUploading:
            NSLog(@"Uploading...");
            break;
        case DFUStateValidating:
            NSLog(@"Validating...");
            
            break;
        case DFUStateDisconnecting:
            NSLog(@"Disconnecting...");
            
            break;
        case DFUStateCompleted:
            NSLog(@"Upload complete......");
        {
            if ([Utility isApplicationStateInactiveORBackground])
            {
                [Utility showBackgroundNotification:@"固件升级完成"];
            }
            [SVProgressHUD showSimpleText:@"升级完成"];
            
            if ([USER_DEFAULTS boolForKey:[NSString stringWithFormat:@"%zd",self.bikeid]]) {
                [USER_DEFAULTS setBool:NO forKey:[NSString stringWithFormat:@"%zd",self.bikeid]];
                [USER_DEFAULTS synchronize];
            }
            
            [self clearUI];
            [self connectBle];
            [LVFmdbTool modifyData:[NSString stringWithFormat:@"UPDATE bike_modals SET firmversion = '%@' WHERE bikeid = '%zd'", _latest_version,self.bikeid]];
            [self updateDeviceInfo:_latest_version];
            
            break;
        }
        case DFUStateAborted:
            [Utility showAlert:@"Upload aborted"];
            [self clearUI];
            
            break;
            
        default:
            break;
    }
}

- (void)dfuProgressDidChangeFor:(NSInteger)part outOf:(NSInteger)totalParts to:(NSInteger)progress currentSpeedBytesPerSecond:(double)currentSpeedBytesPerSecond avgSpeedBytesPerSecond:(double)avgSpeedBytesPerSecond{
    
    //NSLog(@"part:%ld, totalParts:%ld, progress:%ld, currentSpeedBytesPerSecond:%f, avgSpeedBytesPerSecond:%f", (long)part, (long)totalParts, (long)progress, currentSpeedBytesPerSecond, avgSpeedBytesPerSecond);
    //打印更新进度
    [custompro setPresent:(int)progress];
    //NSLog(@"%@", [NSString stringWithFormat:@"%ld%% (%ld/%ld)",(long)progress,(long)part,(long)totalParts]);
}

#pragma mark - 固件升级出现错误的回调
- (void)dfuError:(enum DFUError)error didOccurWithMessage:(NSString * _Nonnull)message{
    
    NSLog(@"Error %ld: %@", (long) error, message);
    
    if ([Utility isApplicationStateInactiveORBackground]){
        [Utility showBackgroundNotification:@"车辆固件升级失败"];
    }
    
    [SVProgressHUD showSimpleText:@"车辆固件升级失败"];
    [self clearUI];
    [self connectBle];
}

#pragma mark - 升级完成后更新车辆版本号
- (void)updateDeviceInfo:(NSString *)firmversion{
    
    BikeInfoModel *bikeinfomodel = [BikeInfoModel new];
    bikeinfomodel.bike_id = _bikeid;
    
    NSMutableArray *bikemodals = [LVFmdbTool queryBikeData:[NSString stringWithFormat:@"SELECT * FROM bike_modals WHERE bikeid = '%zd'", _bikeid]];
    BikeModel *bikemodel = bikemodals.firstObject;
    bikeinfomodel.bike_name = bikemodel.bikename;
    
    if (firmversion == nil) {
        bikeinfomodel.firm_version = [[[LVFmdbTool queryBikeData:[NSString stringWithFormat:@"SELECT * FROM bike_modals WHERE bikeid = '%zd'", _bikeid]] firstObject] bikename];
    }else{
        bikeinfomodel.firm_version = bikemodel.firmversion;
    }
    
    NSDictionary *bike_info = [bikeinfomodel yy_modelToJSONObject];

    NSString *token = [QFTools getdata:@"token"];
    NSString *URLString = [NSString stringWithFormat:@"%@%@",QGJURL,@"app/updatebikeinfo"];
    NSDictionary *parameters = @{@"token": token, @"bike_info": bike_info};
    
    [[HttpRequest sharedInstance] postWithURLString:URLString parameters:parameters success:^(id _Nullable dict) {
        
        if ([dict[@"status"] intValue] == 0) {
            
            [SVProgressHUD showSimpleText:@"升级完成"];
            NSDictionary *dict =[[NSDictionary alloc] initWithObjectsAndKeys:bikeinfomodel,@"data", nil];
            [NSNOTIC_CENTER postNotification:[NSNotification notificationWithName:KNotification_FirmwareUpgradeCompleted object:nil userInfo:dict]];
            
        }else {
            
            [SVProgressHUD showSimpleText:dict[@"status_info"]];
        }
        
    }failure:^(NSError *error) {
        
        NSLog(@"error :%@",error);
        [SVProgressHUD showSimpleText:TIP_OF_NO_NETWORK];
    }];
}
#pragma mark - 升级完成后连接车辆
-(void)connectBle{
    
    self.backView.hidden = YES;
    int present = 0;
    [custompro setPresent:present];
    [[APPStatusManager sharedManager] setBikeFirmwareUpdateStstus:NO];
    [CommandDistributionServices connectPeripheralByUUIDString:[USER_DEFAULTS stringForKey:Key_DeviceUUID]];
}


#pragma mark ————— 转场动画起始View —————
-(UIView *)targetTransitionView{
    
    CustomBike *custombike = [self getCustomBikeAtIndex:self.index];
    return custombike.bikeHeadView.vehiclePositioningMapView.mapView;
}

-(BOOL)isNeedTransition{
    CustomBike *custombike = [self getCustomBikeAtIndex:self.index];
    if (custombike.viewType != 1) {
        return YES;
    }else{
        return NO;
    }
}

#pragma mark - 控制器释放
- (void)dealloc {
    
    [CommandDistributionServices stopScan];
    [self unObserveAllNotifications];
    if (self.BluetoothUpgrateAlertView) {
        [self.BluetoothUpgrateAlertView dismissWithClickedButtonIndex:0 animated:YES];
        self.BluetoothUpgrateAlertView = nil;
    }
    //此处移除所有代理监听方法 相等于[[Manager shareManager] deleteDelegate:self];
    [[Manager shareManager] clearAllDelegates];
    [[APPStatusManager sharedManager] setActivatedJumpStstus:NO];
}

- (void)unObserveAllNotifications {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - ManagerDelegate
-(void)manager:(Manager *)manager bindingBikeSucceeded:(BikeInfoModel *)model :(UpdateViewModel *)updateModel{
    
    [self.navView.centerButton setTitle:model.bike_name forState:UIControlStateNormal];
    phoneInduction = NO;
    
    MainScrollerView *scrollView = [[MainScrollerView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - navHeight)];
    scrollView.contentSize = CGSizeMake(ScreenWidth, ScreenHeight - navHeight + 1);
    scrollView.showsVerticalScrollIndicator = FALSE;
    scrollView.showsHorizontalScrollIndicator = FALSE;
    @weakify(scrollView);
    scrollView.mj_header = [MJDIYHeader headerWithRefreshingBlock:^{
        @strongify(scrollView);
        
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wundeclared-selector"
        void(^success)(void) = ^(void){
            [[Manager shareManager] bikeViewUpdateForNewConnect:NO];
            [scrollView.mj_header endRefreshing];
        };
        [QFTools performSelector:@selector(logindata:) withTheObjects:@[success] withTarget:[AppDelegate currentAppDelegate]];
        #pragma clang diagnostic pop
    }];
    
    CustomBike *custombike = [[CustomBike alloc] initWithFrame:scrollView.bounds];
    [scrollView addSubview:custombike];
    [custombike.bikeHeadView.bikeLogo sd_setImageWithURL:[NSURL URLWithString:updateModel.logo]];
    custombike.bikeid = model.bike_id;
    custombike.tpm_func = model.tpm_func;
    custombike.wheels = model.wheels;
    self.bikeid = model.bike_id;
    [self.droppy dropSubview:scrollView atIndex:[self.droppy randomIndex]];
    [[self mutableArrayValueForKey:@"customViewAry"] addObject:custombike];
    NSMutableArray *peripheraModals = [LVFmdbTool queryPeripheraData:[NSString stringWithFormat:@"SELECT * FROM periphera_modals WHERE type LIKE '%zd' AND bikeid LIKE '%zd'", 6,model.bike_id]];
    if (peripheraModals.count >0) {
        custombike.havePressureMonitoring = YES;
    }
    if (![QFTools isBlankString:model.sn]) {
        self.mac = model.mac;
        if (model.builtin_gps == 1) {
            custombike.viewType = 2;
            [self pushDetectionViewController:model.bike_id needPush:YES];
        }else{
            NSMutableArray *peripheraModals = [LVFmdbTool queryPeripheraData:[NSString stringWithFormat:@"SELECT * FROM periphera_modals WHERE type LIKE '%zd' AND bikeid LIKE '%zd'", 4,model.bike_id]];
            if (peripheraModals.count == 0) {
                custombike.viewType = 1;
                [self pushDetectionViewController:model.bike_id needPush:NO];
            }else{
                custombike.viewType = 2;
                [self pushDetectionViewController:model.bike_id needPush:YES];
            }
        }
    }else{
        custombike.viewType = 3;
        PeripheralModel *deviceModel = [[LVFmdbTool queryPeripheraData:[NSString stringWithFormat:@"SELECT * FROM periphera_modals WHERE type LIKE '%zd' AND bikeid LIKE '%zd'", 4,model.bike_id]] firstObject];
        self.mac = deviceModel.mac;
        //[custombike begainTimer];
        [self pushDetectionViewController:model.bike_id needPush:YES];
    }
    [custombike.bikeHeadView.vehicleStateView setupFootView:model.key_version.intValue];
    [self setupPagecontrolNumber];
    [self switchingVehicle:model.bike_id];
}

-(void)manager:(Manager *)manager unbundBike:(NSInteger)bikeid{
    
    [[self mutableArrayValueForKey:@"customViewAry"] removeObjectAtIndex:self.index];
    [self.droppy removeSubviewAtIndex:self.index];
    self.index = 0;
    self.droppy.selectIndex = 0;
    [self.droppy setContentOffset:CGPointMake(0, 0) animated:NO];
    [self switchingVehicle:[[self getCustomBikeAtIndex:0] bikeid] ];//默认连接第一辆车
}

/* 修改车名，主界面导航栏刷新回调 */
-(void)manager:(Manager *)manager updatebikeName:(NSString *)name :(NSInteger)bikeId{
    
    if (self.bikeid == bikeId) {
        
        [self.navView.centerButton setTitle:name forState:UIControlStateNormal];
    }
}
/* 绑定配件，页面刷新回调 */
-(void)manager:(Manager *)manager bindingPeripheralSucceeded:(PeripheralModel *)model{
    
    CustomBike *custombike = [self getCustomBikeAtIndex:self.index];
    if (model.type == 4){
        
        if (model.bikeid != custombike.bikeid) {
            
            [USER_DEFAULTS setInteger:model.bikeid forKey:Key_BikeId];
            [USER_DEFAULTS synchronize];
            [[Manager shareManager] bikeViewUpdateForNewConnect:YES];
        }else{
            
            custombike.viewType = 2;
        }
        [self pushDetectionViewController:model.bikeid needPush:YES];
    }else if (model.type == 6){
        custombike.havePressureMonitoring = YES;
    }
}

/* 删除配件，页面刷新回调 */
-(void)manager:(Manager *)manager deletePeripheralSucceeded:(PeripheralModel *)model{
    
    CustomBike *custombike = [self getCustomBikeAtIndex:self.index];
    if (model.type == 4){
        NSMutableArray *pressuremodals = [LVFmdbTool queryPeripheraData:[NSString stringWithFormat:@"SELECT * FROM periphera_modals WHERE type = '%d' AND bikeid = '%zd'",model.type,model.bikeid]];
        if (pressuremodals.count == 0) {
            custombike.viewType = 1;
        }
        
    }else if (model.type == 6) {
        NSMutableArray *pressuremodals = [LVFmdbTool queryPeripheraData:[NSString stringWithFormat:@"SELECT * FROM periphera_modals WHERE type = '%d' AND bikeid = '%zd'",model.type,model.bikeid]];
        if (pressuremodals.count == 0) {
            custombike.havePressureMonitoring = NO;
        }
    }
}

/* 远程分享推送回调(所持车辆发生变化) */
-(void)manager:(Manager *)manager postRemoteJPush:(NSDictionary *)dict{
    
    NSNumber *bikeid = dict[@"bikeid"];
    NSNumber *type = dict[@"type"];
    
    if (type.intValue == 1 || type.intValue == 3) {
        
        [self.customViewAry removeAllObjects];
        [self.droppy removeAllSubview];
        [self setupScroview];
        NSMutableArray *bikeidAry = [NSMutableArray new];
        NSMutableArray *bikeAry = [LVFmdbTool queryBikeData:nil];
        for (BikeModel *bikemodel in bikeAry) {
            [bikeidAry addObject:[NSNumber numberWithInteger:bikemodel.bikeid]];
        }
        
        if (![bikeidAry containsObject: bikeid]) {
            
            NSMutableArray *inducmodals = [LVFmdbTool queryInductionData:nil];
            if (inducmodals.count != 0) {
                [LVFmdbTool deleteInductionData:[NSString stringWithFormat:@"DELETE FROM induction_modals WHERE bikeid LIKE '%zd'", bikeid.intValue]];
            }
            
            if (bikeid.intValue == self.bikeid) {
                [CommandDistributionServices removePeripheral:nil];
                [USER_DEFAULTS removeObjectForKey:Key_DeviceUUID];
                [USER_DEFAULTS removeObjectForKey:Key_BikeId];
                [USER_DEFAULTS synchronize];
                self.index = 0;
                self.droppy.selectIndex = 0;
                [self.droppy setContentOffset:CGPointMake(0, 0) animated:NO];
                [self switchingVehicle:[[self getCustomBikeAtIndex:0] bikeid] ];//默认连接第一辆车
            }else{
                
                CustomBike *custombike = [self getCustomBikeAtIndex:self.index];
                NSMutableArray *brandmodals = [LVFmdbTool queryBrandData:[NSString stringWithFormat:@"SELECT * FROM brand_modals WHERE bikeid LIKE '%zd'", custombike.bikeid]];
                BrandModel *brandmodel = brandmodals.firstObject;
                if (brandmodals.count != 0) {
                    NSURL *logurl=[NSURL URLWithString:brandmodel.logo];
                    //图片缓存的基本代码，就是这么简单
                    [custombike.bikeHeadView.bikeLogo sd_setImageWithURL:logurl];
                }
                [self setupPagecontrolNumber];
            }
        }else{
            CustomBike *custombike = [self getCustomBikeAtIndex:self.index];
            NSString *brandQuerySql = [NSString stringWithFormat:@"SELECT * FROM brand_modals WHERE bikeid LIKE '%zd'", custombike.bikeid];
            NSMutableArray *brandmodals = [LVFmdbTool queryBrandData:brandQuerySql];
            BrandModel *brandmodel = brandmodals.firstObject;
            if (brandmodals.count != 0) {
                NSURL *logurl=[NSURL URLWithString:brandmodel.logo];
                [custombike.bikeHeadView.bikeLogo sd_setImageWithURL:logurl];
            }
        }
        
    }else if (type.intValue == 2){
        
        [self.customViewAry removeAllObjects];
        [self.droppy removeAllSubview];
        [self setupScroview];
        CustomBike *custombike = [self getCustomBikeAtIndex:self.index];
        NSString *brandQuerySql = [NSString stringWithFormat:@"SELECT * FROM brand_modals WHERE bikeid LIKE '%zd'", custombike.bikeid];
        NSMutableArray *brandmodals = [LVFmdbTool queryBrandData:brandQuerySql];
        BrandModel *brandmodel = brandmodals.firstObject;
        if (brandmodals.count != 0) {
            NSURL *logurl=[NSURL URLWithString:brandmodel.logo];
            [custombike.bikeHeadView.bikeLogo sd_setImageWithURL:logurl];
        }
        
    }else if (type.intValue == 4){
        
        if (bikeid.intValue == self.bikeid) {
            
            NSString *bikeQuerySql = [NSString stringWithFormat:@"SELECT * FROM bike_modals WHERE bikeid LIKE '%zd'", self.bikeid];
            NSMutableArray *bikemodals = [LVFmdbTool queryBikeData:bikeQuerySql];
            BikeModel *bikemodel = bikemodals.firstObject;
            [self.navView.centerButton setTitle:bikemodel.bikename forState:UIControlStateNormal];
        }
    }
}
/* 点击车库的cell 切换车辆回调 */
-(void)manager:(Manager *)manager switchingVehicle:(NSDictionary *)dict{
    NSInteger biketag = [dict[@"biketag"] integerValue];
    if (self.bikeid != biketag) {
        [self setupPagecontrolNumber];
    }
    [self switchingVehicle:biketag];
}

/* 界面刷新 */
-(void)managerBikeViewUpdatet:(Manager *)manager needNewConnect:(BOOL)isNeed{
    
    [self.droppy removeAllSubview];
    [self setupScroview];
    if (isNeed) [self switchingVehicle:[USER_DEFAULTS integerForKey:Key_BikeId]];
}

-(void)pushDetectionViewController:(NSInteger)bikeid needPush:(BOOL)need{
    
    NSMutableArray *viewCtrs = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    if (need) {
        [viewCtrs removeObjectsInRange: NSMakeRange(1, viewCtrs.count - 1)];
        BikeModel* bikeModel = [[LVFmdbTool queryBikeData:[NSString stringWithFormat:@"SELECT * FROM bike_modals WHERE bikeid LIKE '%zd'", bikeid]] firstObject];
        GPSActivationViewController *bindingVc = [[GPSActivationViewController alloc] init];
        [bindingVc setpGPSParameters:bikeModel];
        bindingVc.isOnlyGPSActivation = YES;
        [viewCtrs addObject:bindingVc];
        [self.navigationController setViewControllers:viewCtrs animated:YES];
    }else{
        
        if ([[APPStatusManager sharedManager] getChangeDeviceType] != BindingBike) {
            [viewCtrs removeObjectsInRange: NSMakeRange(1, viewCtrs.count - 1)];
            id vc = [[NSClassFromString(@"ReplaceEquipmentViewController") alloc] init];
            #pragma clang diagnostic push
            #pragma clang diagnostic ignored "-Wundeclared-selector"
            [QFTools performSelector:@selector(setChangeDeviceType:) withTheObjects:@[@([[APPStatusManager sharedManager] getChangeDeviceType])] withTarget:vc];
            #pragma clang diagnostic pop
            [viewCtrs addObject:vc];
            [self.navigationController setViewControllers:viewCtrs animated:YES];
            
        }else{
            UIViewController *vc = viewCtrs.lastObject;
            [vc.navigationController popToRootViewControllerAnimated:YES];
        }
    }
}

-(void)manager:(Manager *)manager BikeFirmwareUpgrade:(NSInteger)bikeid{
    
    if (![CommandDistributionServices isConnect] || _bikeid !=bikeid) {
        
        [SVProgressHUD showSimpleText:@"车辆未连接"];
        return;
    }
    checkUpgrate = YES;
    @weakify(self);
    [CommandDistributionServices getDeviceFirmwareRevisionString:^(NSString * _Nonnull revision) {
        @strongify(self);
        
        if ([revision isKindOfClass:[NSString class]]) {
            
        }
        
        [self editionData:revision];
    } error:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end
