//
//  AddBikeViewController.m
//  RideHousekeeper
//
//  Created by smartwallit on 16/7/12.
//  Copyright © 2016年 Duke Wu. All rights reserved.
//

#import "AddBikeViewController.h"
#import "BindBikeTableViewCell.h"
#import "SetUpViewController.h"
#import "SearchBleModel.h"
#import "AView.h"
#import "UIView+i7Rotate360.h"
#import "HelpViewController.h"
#import "BLEScanPopview.h"
#import "KVOModel.h"
@interface AddBikeViewController ()<ScanDelegate,UIActionSheetDelegate,UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate>{
    
    NSMutableDictionary *uuidarray;
    NSArray *ascendArray;
    NSString *macstring;
}
@property(nonatomic,strong) BLEScanPopview *scanView;
@property(strong, nonatomic) CAShapeLayer *shapeLayer;
@property(nonatomic,weak) UIButton *upBtn;
@property(nonatomic,weak) UILabel *search;
@property(nonatomic,weak) UIImageView *giftImage;
@property(nonatomic,weak) AView *aView;
@property(nonatomic,strong) UIView *promptView;//中间的绑定提示
@property(nonatomic,copy) NSString *deviceuuid;//默认的蓝牙设备uuid
@property(nonatomic,strong) BikeInfoModel *bikeinfomodel;
@property(nonatomic,strong) BikeBrandInfoModel *bikebrandinfomodel;
@property(nonatomic,strong) BikeModelInfoModel *bikemodelinfomodel;
@property(nonatomic,strong) BikePasswdInfoModel *bikepasswdlinfomodel;
@property(nonatomic,assign) BOOL needDelegate;
@property(nonatomic,strong) KVOModel *model;


@end

@implementation AddBikeViewController

-(void)addDeviceAccessories:(NSInteger)seq{
    
    PeripheralModel *permodel = [PeripheralModel modalWith:_bikeinfomodel.bike_id deviceid:seq + 30 type:6 seq:seq mac:@"00000000" sn:@"300000000000" firmversion:@"00000000"];
    [LVFmdbTool insertDeviceModel:permodel];
    
}

-(NSInteger)getRandomNumber:(NSInteger)from to:(NSInteger)to{
    return (NSInteger)(from + (arc4random() % (to - from + 1)));
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
}

-(void)bluetoothStatusMonitoring{
    @weakify(self);
    [[[NSNOTIC_CENTER rac_addObserverForName:KNotification_BluetoothPowerOn object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id x) {
        @strongify(self);
        NSNotification *userInfo = x;
        NSInteger devicetag=[userInfo.object integerValue];
        if(devicetag == [AppDelegate currentAppDelegate].device.tag){
            
            if (![AppDelegate currentAppDelegate].device.binding) {
                [[AppDelegate currentAppDelegate].device startInfiniteScan];
                [self.view pauseLayer:self.aView.layer];
                [self.view resumeLayer:self.aView.layer];
            }
        }
    }];
    
    [[[NSNOTIC_CENTER rac_addObserverForName:KNotification_BluetoothPowerOff object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id x){
        @strongify(self);
        NSNotification *userInfo = x;
        NSInteger devicetag=[userInfo.object integerValue];
        if(devicetag == [AppDelegate currentAppDelegate].device.tag){
            if (![AppDelegate currentAppDelegate].device.binding) {
                [[AppDelegate currentAppDelegate].device stopScan];
                [[self.model mutableArrayValueForKey:@"rssiList"] removeAllObjects];
                [self->uuidarray removeAllObjects];
                [self.view pauseLayer:self.aView.layer];
            }
        }
    }];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if ([self isMovingFromParentViewController] && [[AppDelegate currentAppDelegate].mainController isKindOfClass:NSClassFromString(@"BikeViewController")])
    {
        [AppDelegate currentAppDelegate].isPop = YES;
    }else{
        
        [AppDelegate currentAppDelegate].isPop = NO;
    }
    
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [QFTools colorWithHexString:@"#ffffff"];
    self.navigationController.fd_fullscreenPopGestureRecognizer.enabled = NO;
    [self setupNavView];
    @weakify(self);
    
    [[[NSNOTIC_CENTER rac_addObserverForName:KNotification_reloadTableViewData object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id x) {
        @strongify(self);
        NSNotification *userInfo = x;
        SearchBleModel *bleModel = userInfo.userInfo[@"searchmodel"];
        if ([[self.model mutableArrayValueForKey:@"rssiList"] containsObject: bleModel]) {
            [[self.model mutableArrayValueForKey:@"rssiList"] removeObject:bleModel];
        }
    }];
    
    _bikeinfomodel = [BikeInfoModel new];
    _bikebrandinfomodel = [BikeBrandInfoModel new];
    _bikemodelinfomodel = [BikeModelInfoModel new];
    _bikepasswdlinfomodel = [BikePasswdInfoModel new];
    uuidarray=[[NSMutableDictionary alloc]init];
    self.model=[[KVOModel alloc]init];
    self.model.rssiList=[NSMutableArray new];
    [self.model addObserver:self forKeyPath:@"rssiList" options:NSKeyValueObservingOptionNew context:NULL];
    
    [self setuptableview];
    [self registerObservers];
    
    
}

- (void)setupNavView{
    [super setupNavView];
    self.navView.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
    self.navView.showBottomLabel = NO;
    [self.navView.centerButton setTitle:NSLocalizedString(@"addvc_binding_bike", nil) forState:UIControlStateNormal];
    @weakify(self);
    
    if ([[AppDelegate currentAppDelegate].mainController isKindOfClass:[self class]]) {
        
        [self.navView.rightButton setImage:[UIImage imageNamed:@"icon_set_search"] forState:UIControlStateNormal];
        self.navView.rightButtonBlock = ^{
            @strongify(self);
            
            SetUpViewController *setupVc = [SetUpViewController new];
            [self.navigationController pushViewController:setupVc animated:YES];
        };
        
    }else{
        
        [self.navView.leftButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
        self.navView.leftButtonBlock = ^{
            @strongify(self);
            
            [self addVcnextBtnClick];
        };
    }
}

- (void)setuptableview{
    
    UILabel *search = [[UILabel alloc] initWithFrame:CGRectMake(20,navHeight+ScreenWidth * .4*.22+5, ScreenWidth - 40, 30)];
    search.textAlignment = NSTextAlignmentCenter;
    search.text = NSLocalizedString(@"searching_device", nil);
    search.textColor = [QFTools colorWithHexString:@"999999"];
    search.font = FONT_PINGFAN(15);
    [self.view addSubview:search];
    self.search = search;
    
    UIImageView *giftImage = [[UIImageView alloc] initWithFrame:CGRectMake(ScreenWidth/2 - ScreenWidth *.3, CGRectGetMaxY(search.frame) + 20, ScreenWidth * .6 , ScreenWidth*.6)];
    giftImage.image = [UIImage imageNamed:@"find_bg"];
    [self.view addSubview:giftImage];
    self.giftImage = giftImage;
    
    AView *aView = [[AView alloc] initWithImage:[UIImage imageNamed:@"turnaround"]];
    aView.frame = CGRectMake(giftImage.x - 2.5, giftImage.y - 2.5,giftImage.width+5,giftImage.height+5);
    [aView rotate360WithDuration:2.0 repeatCount:HUGE_VALF timingMode:i7Rotate360TimingModeLinear];
    if (![AppDelegate currentAppDelegate].device.blueToothOpen) {
        [self.view pauseLayer:aView.layer];
    }
    aView.userInteractionEnabled = NO;
    [self.view addSubview:aView];
    self.aView = aView;
    
    _promptView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(giftImage.frame) + ScreenHeight *.05, ScreenWidth, ScreenHeight * .3)];
    [self.view addSubview:_promptView];
    
    UILabel *prompt = [[UILabel alloc] init];
    prompt.numberOfLines = 0;
    prompt.text = NSLocalizedString(@"binding_hint", nil);
    prompt.textColor = [UIColor whiteColor];
    prompt.font = FONT_PINGFAN(16);
    prompt.textAlignment = NSTextAlignmentCenter;
    [_promptView addSubview:prompt];
    [prompt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_promptView);
        make.centerY.equalTo(_promptView);
        make.width.mas_equalTo(ScreenWidth - 10);
    }];
    [self bluetoothStatusMonitoring];
    [self startblescan];
}

-(BLEScanPopview *)scanView{
    
    if (!_scanView) {
        _scanView = [BLEScanPopview new];
        self.scanView.scandTabView.delegate = self;
        self.scanView.scandTabView.dataSource = self;
        @weakify(self);
        _scanView.bindingBikeClickBlock = ^{
            @strongify(self);
            [self bindBike:0];
        };
    }
    return _scanView;
}


- (void)startblescan{
    [[AppDelegate currentAppDelegate].device remove];
    [AppDelegate currentAppDelegate].device.scanDelete = self;
    [AppDelegate currentAppDelegate]. device.deviceStatus=0;
    [NSNOTIC_CENTER postNotification:[NSNotification notificationWithName:KNotification_UpdateDeviceStatus object:nil]];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
        [[AppDelegate currentAppDelegate].device startInfiniteScan];
    });
}


#pragma mark -- TableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
    
    return self.model.rssiList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 45.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return 1.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 5.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *headerView = [UIView new];
    return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    UIView *footerView = [UIView new];
    return footerView;
}

- ( void )tableView:( UITableView  *)tableView  willDisplayCell :( UITableViewCell  *)cell  forRowAtIndexPath :( NSIndexPath  *)indexPath{
    
    cell.backgroundColor = [UIColor whiteColor];
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section{
    
    view.tintColor = [QFTools colorWithHexString:@"#cccccc"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellName = @"ADDBindingCell";
    BindBikeTableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:cellName];
    if (!cell) {
        cell = [[BindBikeTableViewCell alloc] initWithStyle:0 reuseIdentifier:cellName];
    }
    //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    ascendArray = [self.model.rssiList sortedArrayUsingComparator:^NSComparisonResult(SearchBleModel* obj1, SearchBleModel* obj2){
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
        UIImageView *image = cell.Icon;
        
        SearchBleModel *model = [ascendArray objectAtIndex:indexPath.section];
        
        if (model.rssi.intValue <= -95) {
            
            image.image = [UIImage imageNamed:@"icon_signal1"];
        }else if (model.rssi.intValue > -90 && model.rssi.intValue <= -85){
        
            image.image = [UIImage imageNamed:@"icon_signal2"];
        }else if (model.rssi.intValue > -85 && model.rssi.intValue <= -80){
            
            image.image = [UIImage imageNamed:@"icon_signal3"];
        }else{
        
            image.image = [UIImage imageNamed:@"icon_signal4"];
        }
    
    if (indexPath.section == 0) {
        cell.IntelligenceBike.textColor = [QFTools colorWithHexString:NSLocalizedString(@"VCControlColor", nil)];
        cell.IntelligenceBike.text = NSLocalizedString(@"bike_name", nil);
    }else{
        cell.IntelligenceBike.textColor = [UIColor blackColor];
        cell.IntelligenceBike.text = [NSString stringWithFormat:@"%@  %ld",NSLocalizedString(@"bike_name", nil),(long)indexPath.section];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self bindBike:indexPath.section];
}

-(void)bindBike:(NSInteger)num{
    
    if (![AppDelegate currentAppDelegate].device.blueToothOpen) {
        [SVProgressHUD showSimpleText:NSLocalizedString(@"device_disconnect", nil)];
        return;
    }
    
    NSString *title = [[ascendArray objectAtIndex:num] titlename];
    if ([title hasPrefix: @"0000A501"]) {
        
        if ([[ascendArray objectAtIndex:num] searchCount] == 0) {
            //[SVProgressHUD showSimpleText:@"设备已断电"];
            return;
        }
        
        for (int i=0; i<ascendArray.count; i++) {
            [[ascendArray objectAtIndex:num] stopSearchBle];
        }
        
        [AppDelegate currentAppDelegate].device.binding = YES;//进入绑定模式
        [self.view pauseLayer:self.aView.layer];
        [self unregisterObservers];
        
        [[AppDelegate currentAppDelegate].device stopScan];
        LoadView* loadview = [LoadView sharedInstance];
        loadview.protetitle.text = NSLocalizedString(@"bike_binding", nil);
        [loadview show];
        [AppDelegate currentAppDelegate]. device.peripheral=[[ascendArray objectAtIndex:num] peripher];
        [[AppDelegate currentAppDelegate].device connect];
        macstring = [title substringWithRange:NSMakeRange(8, 12)];
        [[self.model mutableArrayValueForKey:@"rssiList"] removeAllObjects];
        @weakify(self);
        RACSignal * deallocSignal = [self rac_signalForSelector:@selector(updateNewDeviceStatusAction)];
        [[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:KNotification_ConnectStatus object:nil] takeUntil:deallocSignal] timeout:10 onScheduler:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
            @strongify(self);
            [self updateNewDeviceStatusAction];
        }error:^(NSError *error) {
            [[LoadView sharedInstance] hide];
            [self overtime];
        }];
    }
}

-(void)overtime{
    [[LoadView sharedInstance] hide];
    macstring = nil;
    [[AppDelegate currentAppDelegate].device remove];
    [SVProgressHUD showSimpleText:NSLocalizedString(@"bind_fail", nil)];
    [AppDelegate currentAppDelegate].device.binding = NO;
    self.search.hidden = YES;
    self.aView.hidden = YES;
    self.giftImage.image = [UIImage imageNamed:@"binding_fail"];
    self.upBtn.hidden = YES;
    macstring = nil;//mac地址置空，避免下次扫描直接连接
    [uuidarray removeAllObjects];
    
    UIButton *scanAgainBtn = [[UIButton alloc] initWithFrame:CGRectMake(75, ScreenHeight - 120, ScreenWidth - 150, 45)];
    [scanAgainBtn setTitle:NSLocalizedString(@"bind_start_retry", nil) forState:UIControlStateNormal];
    [scanAgainBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    scanAgainBtn.backgroundColor = [UIColor clearColor];
    scanAgainBtn.contentMode = UIViewContentModeCenter;
    [scanAgainBtn.layer setCornerRadius:10.0];
    [scanAgainBtn.layer setBorderColor:[QFTools colorWithHexString:MainColor].CGColor];
    [scanAgainBtn.layer setBorderWidth:1];
    [scanAgainBtn.layer setMasksToBounds:YES];
    [scanAgainBtn addTarget:self action:@selector(scanAgain:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:scanAgainBtn];
}

-(void)updateNewDeviceStatusAction{
    
    if([AppDelegate currentAppDelegate].device.deviceStatus == 2){
        [[AppDelegate currentAppDelegate].device stopScan];
        //数据通知
        @weakify(self);
        RACSignal * deallocSignal = [self rac_signalForSelector:@selector(queryFirmEditionData:)];
        [[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:KNotification_UpdateeditionValue object:nil] takeUntil:deallocSignal] timeout:6 onScheduler:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
            @strongify(self);
            NSNotification *userInfo = x;
            NSString *date = userInfo.userInfo[@"data"];
            [self queryFirmEditionData:date];
        }error:^(NSError *error) {
            [[LoadView sharedInstance] hide];
            [self overtime];
        }];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            [[AppDelegate currentAppDelegate].device readDiviceInformation];
        });
    }
}

-(void)queryFirmEditionData:(NSString *)data{
    
    _bikeinfomodel.firm_version = data;
    _bikeinfomodel.bike_name = NSLocalizedString(@"bike_name", nil);
    _bikebrandinfomodel.logo = @"";
    _bikebrandinfomodel.brand_id = 1;
    _bikebrandinfomodel.brand_name = NSLocalizedString(@"bike_name", nil);
    
    @weakify(self);
    RACSignal * deallocSignal = [self rac_signalForSelector:@selector(queryKeyVersionData:)];
    [[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:KNotification_VersionValue object:nil] takeUntil:deallocSignal] timeout:6 onScheduler:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        @strongify(self);
        NSNotification *userInfo = x;
        NSString *date = userInfo.userInfo[@"data"];
        [self queryKeyVersionData:date];
    }error:^(NSError *error) {
        [[LoadView sharedInstance] hide];
        [self overtime];
    }];
    [[AppDelegate currentAppDelegate].device readDiviceVersion];
}


//获取硬件版本号信息
-(void)queryKeyVersionData:(NSString *)data{
    
    _bikeinfomodel.hw_version = data;
    
    NSString *last = [_bikeinfomodel.hw_version substringFromIndex:_bikeinfomodel.hw_version.length-1];
    if ([last isEqualToString:@"0"]) {
        
        if (![[_bikeinfomodel.firm_version substringWithRange:NSMakeRange(0, 4)] isEqualToString:@"X100"]) {
            //无指纹和查询震动灵敏度
            [self accessorySupport];
        }else{
            //无指纹和无震动灵敏度
            [self getKeyType];
        }
        
    }else{
        _bikeinfomodel.fp_func = 1;
        //有指纹，查询震动灵敏度
        if (![[_bikeinfomodel.firm_version substringWithRange:NSMakeRange(0, 4)] isEqualToString:@"X100"]) {
            
            [self accessorySupport];
        }else{
            //有指纹和无震动灵敏度
            [self getKeyType];
        }
    }
}

-(void)accessorySupport{
    @weakify(self);
    RACSignal * deallocSignal = [self rac_signalForSelector:@selector(queryKeyType:)];
    [[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:KNotification_SupportableAccessories object:nil] takeUntil:deallocSignal] timeout:6 onScheduler:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        @strongify(self);
        NSNotification *userInfo = x;
        NSString *date = userInfo.userInfo[@"data"];
        [self queryKeyType:date];
    }error:^(NSError *error) {
        [[LoadView sharedInstance] hide];
        [self overtime];
    }];
    [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:@"A50000065002"]];
}

-(void)queryKeyType:(NSString*)notificationData{
    
    if ([[notificationData substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"5002"]) {
        NSString *bikefunction = [QFTools getBinaryByhex:[notificationData substringWithRange:NSMakeRange(18, 2)]];
        
        if([[bikefunction substringWithRange:NSMakeRange(7, 1)] isEqualToString:@"1"]){
            _bikeinfomodel.fp_func = 1;
        }
        
        if([[bikefunction substringWithRange:NSMakeRange(6, 1)] isEqualToString:@"1"]){
            _bikeinfomodel.vibr_sens_func = 1;
        }
        if([[bikefunction substringWithRange:NSMakeRange(5, 1)] isEqualToString:@"1"]){
            self.bikeinfomodel.tpm_func = 1;
        }
        if([[bikefunction substringWithRange:NSMakeRange(2, 1)] isEqualToString:@"1"]){
            self.bikeinfomodel.fp_conf_count = 1;
        }
        [self getKeyType];
    }
}

//发送钥匙码
-(void)getKeyType{
    @weakify(self);
    RACSignal * deallocSignal = [self rac_signalForSelector:@selector(addVcbikebinding)];
    [[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:KNotification_QueryKeyType object:nil] takeUntil:deallocSignal] timeout:6 onScheduler:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        @strongify(self);
        NSNotification *userInfo = x;
        NSString *date = userInfo.userInfo[@"data"];
        if ([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"1005"]) {
            self.bikeinfomodel.key_version = nil;
            self.bikeinfomodel.key_version = [date substringWithRange:NSMakeRange(13, 1)];
            [self addVcbikebinding];
        }
        
    }error:^(NSError *error) {
        [[LoadView sharedInstance] hide];
        [self overtime];
    }];
    
    [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:@"A50000061005"]];
}



- (void)addVcbikebinding{
    
    if ([LVFmdbTool queryBikeData:nil].count == 5) {
        
        [SVProgressHUD showSimpleText:NSLocalizedString(@"big_max_add_bike", nil)];
        return;
    }
    
    if(_bikeinfomodel.hw_version == nil){
        _bikeinfomodel.hw_version = @"000000";//硬件版本号
    }
    
    if(_bikeinfomodel.key_version == nil){
        _bikeinfomodel.key_version = @"1";//钥匙版本号
    }
    
    _bikemodelinfomodel.model_id = 0;
    _bikemodelinfomodel.model_name = @"自定义";
    _bikemodelinfomodel.batt_type = 0;
    _bikemodelinfomodel.batt_vol = 0;
    _bikemodelinfomodel.wheel_size = 0;
   
    _bikeinfomodel.brand_info = _bikebrandinfomodel;
    _bikeinfomodel.model_info = _bikemodelinfomodel;
    _bikeinfomodel.mac = macstring.uppercaseString;
    
    NSMutableArray *arr = [NSMutableArray array];
    for (int i = 0; i<5; i++) {
        NSInteger num = [self getRandomNumber:16777216 to:1099511627775];
        [arr addObject:[NSNumber numberWithInteger:num]];
    }
    NSDictionary *passwd_info = @{@"children":arr, @"main":[NSNumber numberWithInteger:[self getRandomNumber:16777216 to:1099511627775]]};
    
    [USER_DEFAULTS setValue:macstring.uppercaseString forKey:SETRSSI];
    [USER_DEFAULTS setObject: macstring.uppercaseString forKey:Key_MacSTRING];
    [USER_DEFAULTS synchronize];
    
    NSMutableArray *bikeidAry = [NSMutableArray new];
    NSMutableArray *bikeAry = [LVFmdbTool queryBikeData:nil];
    for (BikeModel *bikemodel in bikeAry) {
        [bikeidAry addObject:bikemodel.mac];
    }
    
    if ([bikeidAry containsObject: _bikeinfomodel.mac]) {
        
        self.needDelegate = YES;
        _bikepasswdlinfomodel.main = [passwd_info[@"main"] stringValue];
        NSString *updateSql = [NSString stringWithFormat:@"UPDATE bike_modals SET bikename = '%@',ownerflag = '%d' , mainpass = '%@' , password = '%@' , bindedcount = '%d' , ownerphone = '%@' WHERE mac = '%@'",_bikeinfomodel.bike_name,1,_bikepasswdlinfomodel.main,@"0",1,@"123456",_bikeinfomodel.mac];
        
        if ([LVFmdbTool modifyData:updateSql]) {
            NSString *bikeQuerySql = [NSString stringWithFormat:@"SELECT * FROM bike_modals WHERE mac LIKE '%@'",_bikeinfomodel.mac];
            BikeModel *bikeModal = [[LVFmdbTool queryBikeData:bikeQuerySql] firstObject];
            _bikeinfomodel.bike_id = bikeModal.bikeid;
        }
        
    }else{
        
        _bikeinfomodel.bike_id = bikeAry.count+1;
        BikeModel *pmodel = [BikeModel modalWith:_bikeinfomodel.bike_id bikename:_bikeinfomodel.bike_name ownerflag:1 hwversion:_bikeinfomodel.hw_version firmversion:_bikeinfomodel.firm_version keyversion:_bikeinfomodel.key_version mac:_bikeinfomodel.mac mainpass:[passwd_info[@"main"] stringValue] password:@"0" bindedcount:1 ownerphone:@"123456" fp_func:_bikeinfomodel.fp_func fp_conf_count:_bikeinfomodel.fp_conf_count tpm_func:_bikeinfomodel.tpm_func vibr_sens_func:_bikeinfomodel.vibr_sens_func];
        [LVFmdbTool insertBikeModel:pmodel];
        
        BrandModel *bmodel = [BrandModel modalWith:_bikeinfomodel.bike_id brandid:1 brandname:_bikebrandinfomodel.brand_name logo:_bikebrandinfomodel.logo];
        [LVFmdbTool insertBrandModel:bmodel];
        
        ModelInfo *Infomodel = [ModelInfo modalWith:_bikeinfomodel.bike_id modelid:1 modelname:_bikemodelinfomodel.model_name batttype:_bikemodelinfomodel.batt_type battvol:_bikemodelinfomodel.batt_vol wheelsize:_bikemodelinfomodel.wheel_size brandid:_bikemodelinfomodel.brand_id pictures:_bikemodelinfomodel.picture_s pictureb:_bikemodelinfomodel.picture_b];
        [LVFmdbTool insertModelInfo:Infomodel];
    }
        NSArray *child = passwd_info[@"children"];
        _bikepasswdlinfomodel.main = [ConverUtil ToHex:(long)[passwd_info[@"main"] longLongValue]];
        NSString* childpwdone = [ConverUtil ToHex:(long)[child[0] longLongValue]];
        NSString* childpwdtwo = [ConverUtil ToHex:(long)[child[1] longLongValue]];
        NSString* childpwdthree = [ConverUtil ToHex:(long)[child[2] longLongValue]];
        NSString* childpwdfour = [ConverUtil ToHex:(long)[child[3] longLongValue]];
        NSString* childpwdfive = [ConverUtil ToHex:(long)[child[4] longLongValue]];
        
        if (_bikepasswdlinfomodel.main.length !=8) {
            int masterpwdCount = 8 - (int)_bikepasswdlinfomodel.main.length;
            for (int i = 0; i<masterpwdCount; i++) {
                _bikepasswdlinfomodel.main = [@"0" stringByAppendingFormat:@"%@",_bikepasswdlinfomodel.main];
            }
        }
        
        if (childpwdone.length !=8) {
            int childpwdoneCount = 8 - (int)childpwdone.length;
            for (int i = 0; i<childpwdoneCount; i++) {
                childpwdone = [@"0" stringByAppendingFormat:@"%@", childpwdone];
            }
        }
        
        if (childpwdtwo.length !=8) {
            int childpwdtwoCount = 8 - (int)childpwdtwo.length;
            for (int i = 0; i<childpwdtwoCount; i++) {
                childpwdtwo = [@"0" stringByAppendingFormat:@"%@", childpwdtwo];
            }
        }
        
        if (childpwdthree.length !=8) {
            int childpwdthreeCount = 8 - (int)childpwdthree.length;
            for (int i = 0; i<childpwdthreeCount; i++) {
                childpwdthree = [@"0" stringByAppendingFormat:@"%@",childpwdthree];
            }
        }
        
        if (childpwdfour.length !=8) {
            int childpwdfourCount = 8 - (int)childpwdfour.length;
            for (int i = 0; i<childpwdfourCount; i++) {
                childpwdfour = [@"0" stringByAppendingFormat:@"%@",childpwdfour];
            }
        }
        
        if (childpwdfive.length !=8) {
            int childpwdfiveCount = 8 - (int)childpwdfive.length;
            for (int i = 0; i<childpwdfiveCount; i++) {
                childpwdfive = [@"0" stringByAppendingFormat:@"%@",childpwdfive];
            }
        }
    
    @weakify(self);
    RACSignal * deallocSignal = [self rac_signalForSelector:@selector(addVcboundSuccess:)];
    [[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:KNotification_BindingQGJSuccess object:nil] takeUntil:deallocSignal] timeout:6 onScheduler:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        @strongify(self);
        NSNotification *userInfo = x;
        NSString *date = userInfo.userInfo[@"data"];
        if ([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"5001"]) {
            
            [self addVcboundSuccess:date];
        }
    }error:^(NSError *error) {
        [self addVcboundSuccess:@"A5000007500100"];
    }];
    
    NSString *passwordHEX = [@"A500001E5001" stringByAppendingFormat:@"%@%@%@%@%@%@", _bikepasswdlinfomodel.main, childpwdone,childpwdtwo,childpwdthree, childpwdfour,childpwdfive];
    [[AppDelegate currentAppDelegate].device sendHexstring:passwordHEX];
    [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:[passwordHEX substringWithRange:NSMakeRange(0, 40)]]];
}




-(void)addVcboundSuccess:(NSString *)date{
    
    if ([[date substringWithRange:NSMakeRange(8, 6)] isEqualToString:@"500101"]){
        [self inquireDate];
        
    }else if([[date substringWithRange:NSMakeRange(8, 6)] isEqualToString:@"500100"]){
        [self removebikeDB];
        if ([[AppDelegate currentAppDelegate].mainController isKindOfClass:[self class]]) {
            
            [self addVcbindingfail];
        }else{
            
            [self addVcnextBtnClick];
        }
    }
}

-(void)inquireDate{
    @weakify(self);
    RACSignal * deallocSignal = [self rac_signalForSelector:@selector(deleteFinger)];
    [[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:KNotification_QueryData object:nil] takeUntil:deallocSignal] timeout:6 onScheduler:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        
        @strongify(self);
        NSNotification *userInfo = x;
        NSString *date = userInfo.userInfo[@"data"];
        if ([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"1001"]) {
            //A5 00 00 14 1001 01 00 00 01 DD 01 6A CF 00 00 00 00 00 00
            
            if (![[date substringWithRange:NSMakeRange(32, 2)] isEqualToString:@"FF"]) {
                [self addDeviceAccessories:1];
            }
            
            if (![[date substringWithRange:NSMakeRange(34, 2)] isEqualToString:@"FF"]) {
                [self addDeviceAccessories:2];
            }
            
            if (![[date substringWithRange:NSMakeRange(36, 2)] isEqualToString:@"FF"]) {
                [self addDeviceAccessories:3];
            }
            
            if (![[date substringWithRange:NSMakeRange(38, 2)] isEqualToString:@"FF"]) {
                [self addDeviceAccessories:4];
            }
            [self deleteFinger];
        }
    }error:^(NSError *error) {
        
        [[LoadView sharedInstance] hide];
        [self addVcbindingfail];
    }];
    
    [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:@"A50000061001"]];
}

-(void)deleteFinger{
    
    NSString *deleteFingerSql = [NSString stringWithFormat:@"DELETE FROM fingerprint_modals WHERE bikeid LIKE '%zd'", _bikeinfomodel.bike_id];
    [LVFmdbTool deleteFingerprintData:deleteFingerSql];
    
    @weakify(self);
    RACSignal * deallocSignal = [self rac_signalForSelector:@selector(bikeBindingOver)];
    [[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:KNotification_DeleteFinger object:nil] takeUntil:deallocSignal] timeout:6 onScheduler:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        @strongify(self);
        NSNotification *userInfo = x;
        NSString *date = userInfo.userInfo[@"data"];
        if ([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"3005"]) {
            
            if ([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"00"]) {
                NSLog(@"删除指纹失败");
                [self bikeBindingOver];
            }else if ([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"01"]){
                [self bikeBindingOver];
            }
        }
    }error:^(NSError *error) {
        NSLog(@"删除指纹失败");
        [self bikeBindingOver];
    }];
    
    [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:@"A5000007300500"]];
    
}




-(void)bikeBindingOver{
    [[AppDelegate currentAppDelegate].device remove];

    if ([[AppDelegate currentAppDelegate].mainController isKindOfClass:[self class]]) {

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            [self bikeBindSuccess];
        });

    }else{

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

            NSDictionary *userDic = [NSDictionary dictionaryWithObjectsAndKeys:_bikepasswdlinfomodel.main,@"main",nil];
            [USER_DEFAULTS setObject:userDic forKey:passwordDIC];
            [USER_DEFAULTS synchronize];
        });

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            [[AppDelegate currentAppDelegate].device startScan];
        });
        @weakify(self);
        RACSignal * deallocSignal = [self rac_signalForSelector:@selector(addVcconnectdevice)];
        [[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:KNotification_ConnectStatus object:nil] takeUntil:deallocSignal] timeout:50 onScheduler:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
            @strongify(self);

            [self addVcconnectdevice];
        }error:^(NSError *error) {
            [[LoadView sharedInstance] hide];
            [self addVcbindingfail];
        }];
    }
}

-(void)bikeBindSuccess{
    
    [[LoadView sharedInstance] hide];
    [AppDelegate currentAppDelegate].device.binding = NO;
    [NSNOTIC_CENTER postNotificationName:KNOTIFICATION_LOGINCHANGE object:@YES];
    [SVProgressHUD showSimpleText:NSLocalizedString(@"bind_success", nil)];
    
}

#pragma mark---扫描的回调
-(void)didDiscoverPeripheral:(NSInteger)tag :(CBPeripheral *)peripheral scanData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    //NSLog(@"扫描到的那些:%@",peripheral.name);
    if (peripheral.name.length < 13) {
        return;
    }
    
    if([peripheral.name isEqualToString: @"Qgj-SmartBike"]){
    NSString *title = [ConverUtil data2HexString:[advertisementData objectForKey:@"kCBAdvDataManufacturerData"]];
    if (title == NULL) {
        return;
    }else if (title.length < 9) {
        return;
    }
        
        if ([title hasPrefix: @"0000A501"] && [QFTools isBlankString:macstring]) {
            
            if(![uuidarray objectForKey:[title substringWithRange:NSMakeRange(8, 12)]]){
                
                SearchBleModel *model=[[SearchBleModel alloc]init];
                model.peripher=peripheral;
                model.rssi = RSSI;
                model.titlename = title;
                model.searchCount = 1;
                [[self.model mutableArrayValueForKey:@"rssiList"] addObject:model];
                [uuidarray setObject:model forKey:[title substringWithRange:NSMakeRange(8, 12)]];
            }else if([uuidarray objectForKey:[title substringWithRange:NSMakeRange(8, 12)]]){
                
                SearchBleModel *model = [uuidarray objectForKey:[title substringWithRange:NSMakeRange(8, 12)]];
                if (RSSI.intValue >0 ) {
                    model.rssi = [NSNumber numberWithInt:-64];;
                }else{
                    model.rssi = RSSI;
                }
                
                model.searchCount = 1;
            }
        }else if (![title hasPrefix: @"0000A501"] && [QFTools isBlankString:macstring]) {
            
            if([uuidarray objectForKey:[title substringWithRange:NSMakeRange(4, 12)]]){
                
                SearchBleModel *model = [uuidarray objectForKey:[title substringWithRange:NSMakeRange(4, 12)]];
                [[self.model mutableArrayValueForKey:@"rssiList"] removeObject:model];
                [uuidarray removeObjectForKey:[title substringWithRange:NSMakeRange(4, 12)]];
            }
        }else if ([macstring isEqualToString: [title substringWithRange:NSMakeRange(4, 12)]]  && ![QFTools isBlankString:macstring]){
            
            if (peripheral.identifier.UUIDString != nil) {
                self.deviceuuid = peripheral.identifier.UUIDString;
                [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(addVcconnectdevicename) object:nil];
                [self performSelector:@selector(addVcconnectdevicename) withObject:nil afterDelay:2];
            }
        }
    }
}

-(void)addVcconnectdevicename{
    
    [[AppDelegate currentAppDelegate].device stopScan];
    if (!self.deviceuuid) {
        [self addVcnextBtnClick];
    }
    [USER_DEFAULTS setObject: self.deviceuuid forKey:Key_DeviceUUID];
    [USER_DEFAULTS synchronize];
    [[AppDelegate currentAppDelegate].device retrievePeripheralWithUUID:self.deviceuuid];//导入外设 根据UUID
    [[AppDelegate currentAppDelegate].device connect];
    
}

-(void)addVcconnectdevice{
    [AppDelegate currentAppDelegate].device.binding = NO;
    NSString *phonenum = @"13751287467";
    NSString *bikeMacString = macstring.uppercaseString;
    NSString *fuzzyQuerySql = [NSString stringWithFormat:@"SELECT * FROM peripherauuid_modals WHERE mac LIKE '%%%@%%'", macstring];
    NSMutableArray *modals = [LVFmdbTool queryPeripheraUUIDData:fuzzyQuerySql];
    if (modals.count == 0) {
        PeripheralUUIDModel *peripheramodel = [PeripheralUUIDModel modalWith:phonenum bikeid:_bikeinfomodel.bike_id mac:bikeMacString uuid:self.deviceuuid];
        [LVFmdbTool insertPeripheralUUIDModel:peripheramodel];
    }else{
        
        NSString *fuzzyQuerySql = [NSString stringWithFormat:@"DELETE FROM peripherauuid_modals WHERE mac LIKE '%%%@%%'", macstring];
        [LVFmdbTool deletePeripheraUUIDData:fuzzyQuerySql];
        PeripheralUUIDModel *peripheramodel = [PeripheralUUIDModel modalWith:phonenum bikeid:_bikeinfomodel.bike_id mac:macstring uuid:self.deviceuuid];
        [LVFmdbTool insertPeripheralUUIDModel:peripheramodel];
    }
    NSNumber *bikeid = [NSNumber numberWithInteger:_bikeinfomodel.bike_id];
    
    NSDictionary *dict =[[NSDictionary alloc] initWithObjectsAndKeys:bikeid,@"bikeid",_bikebrandinfomodel.logo,@"logo",_bikeinfomodel.bike_name,@"bikename",_bikeinfomodel.key_version,@"keyversion", [NSNumber numberWithInteger:_bikeinfomodel.tpm_func],@"tpm_func", nil];
    
    if([self.delegate respondsToSelector:@selector(bidingBikeSuccess::)]){
        [self.delegate bidingBikeSuccess:dict :self.needDelegate];
    }
    
    [[LoadView sharedInstance] hide];
    [SVProgressHUD showSimpleText:NSLocalizedString(@"bind_success", nil)];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)addVcbindingfail{
    
    [self removebikeDB];
    macstring = nil;
    [SVProgressHUD showSimpleText:NSLocalizedString(@"bind_fail", nil)];
    [[AppDelegate currentAppDelegate].device stopScan];
    [[LoadView sharedInstance] hide];
    self.search.hidden = YES;
    self.aView.hidden = YES;
    self.giftImage.image = [UIImage imageNamed:@"binding_fail"];
    self.upBtn.hidden = YES;
    
    [AppDelegate currentAppDelegate].device.binding = NO;
    [uuidarray removeAllObjects];
    UIButton *scanAgainBtn = [[UIButton alloc] initWithFrame:CGRectMake(75, ScreenHeight - 120, ScreenWidth - 150, 45)];
    [scanAgainBtn setTitle:NSLocalizedString(@"bind_start_retry", nil) forState:UIControlStateNormal];
    [scanAgainBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    scanAgainBtn.backgroundColor = [UIColor clearColor];
    scanAgainBtn.contentMode = UIViewContentModeCenter;
    [scanAgainBtn.layer setCornerRadius:10.0]; // 切圆角
    [scanAgainBtn.layer setBorderColor:[QFTools colorWithHexString:MainColor].CGColor];
    [scanAgainBtn.layer setBorderWidth:1];
    [scanAgainBtn.layer setMasksToBounds:YES];
    [scanAgainBtn addTarget:self action:@selector(scanAgain:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:scanAgainBtn];
}

-(void) removebikeDB{
    
    NSString *deleteBikeSql = [NSString stringWithFormat:@"DELETE FROM bike_modals WHERE bikeid LIKE '%zd'", _bikeinfomodel.bike_id];
    [LVFmdbTool deleteBikeData:deleteBikeSql];
    
    NSString *deleteBrandSql = [NSString stringWithFormat:@"DELETE FROM brand_modals WHERE bikeid LIKE '%zd'", _bikeinfomodel.bike_id];
    [LVFmdbTool deleteBrandData:deleteBrandSql];
    
    NSString *deleteInfoSql = [NSString stringWithFormat:@"DELETE FROM info_modals WHERE bikeid LIKE '%zd'", _bikeinfomodel.bike_id];
    [LVFmdbTool deleteModelData:deleteInfoSql];
    
    NSString *deletePeripherSql = [NSString stringWithFormat:@"DELETE FROM periphera_modals WHERE bikeid LIKE '%zd'", _bikeinfomodel.bike_id];
    [LVFmdbTool deletePeripheraData:deletePeripherSql];
}

-(void)scanAgain:(UIButton *)btn{
    
    [self registerObservers];
    [btn removeFromSuperview];
    [self.view resumeLayer:self.aView.layer];
    [[AppDelegate currentAppDelegate].device startInfiniteScan];
    self.search.hidden = NO;
    self.aView.hidden = NO;
    self.giftImage.image = [UIImage imageNamed:@"find_bg"];
    self.upBtn.hidden = NO;
}

-(void)addVcnextBtnClick{
    [[AppDelegate currentAppDelegate].device stopScan];
    [[LoadView sharedInstance] hide];
    [[AppDelegate currentAppDelegate].device remove];
    [AppDelegate currentAppDelegate].device.binding = NO;
    [AppDelegate currentAppDelegate]. device.deviceStatus=0;
    [NSNOTIC_CENTER postNotification:[NSNotification notificationWithName:KNotification_UpdateDeviceStatus object:nil]];
    
    NSString*deviceuuid=[USER_DEFAULTS stringForKey:Key_DeviceUUID];
    if (![QFTools isBlankString:deviceuuid]) {
        [[AppDelegate currentAppDelegate].device retrievePeripheralWithUUID:deviceuuid];//导入外设 根据UUID
        [[AppDelegate currentAppDelegate].device connect];
    }
    [self.navigationController popViewControllerAnimated:YES];
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
    [[AppDelegate currentAppDelegate].device stopScan];
}

-(void)appDidEnterForeground:(NSNotification *)_notification
{
    [[AppDelegate currentAppDelegate].device startBackstageScan];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"rssiList"]) {
        
        dispatch_async(dispatch_get_main_queue(), ^{

            [self.scanView.scandTabView reloadData];
        });
        
        if (self.model.rssiList.count > 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                _promptView.hidden = YES;
                [self.scanView showInView:self.view];
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                _promptView.hidden = NO;
                [self.scanView disMissView];
                self.scanView = nil;
            });
        }
    }
}

-(void)dealloc{
    if (_model != nil) {
        [_model removeObserver:self forKeyPath:@"rssiList"];
    }
    [AppDelegate currentAppDelegate].device.binding = NO;
    [[AppDelegate currentAppDelegate].device stopScan];
    NSLog(@"%s dealloc",object_getClassName(self));
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
