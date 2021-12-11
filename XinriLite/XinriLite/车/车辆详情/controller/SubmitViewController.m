//
//  SubmitViewController.m
//  RideHousekeeper
//
//  Created by smartwallit on 16/7/14.
//  Copyright © 2016年 Duke Wu. All rights reserved.
//

#import "SubmitViewController.h"
#import "nameTextFiledController.h"
#import "AccessoriesViewController.h"
#import "VehicleFingerprintViewController.h"
#import "bikeFunctionTableViewCell.h"
#import "BikeInductionDistanceTableViewCell.h"
#import "AutomaticLockTableViewCell.h"
#import "TirePressureMonitoringTableViewCell.h"
#import "TailTableViewCell.h"
#import "LianUISlider.h"
#import "PickerChoiceView.h"
#import "Manager.h"
@interface SubmitViewController ()<UITableViewDelegate,UITableViewDataSource,TFPickerDelegate,ManagerDelegate>
@property (nonatomic, weak) UITableView *bikeSubmitView;
@property (nonatomic, copy)NSArray *cellIdentifiers;
@property (nonatomic, copy)NSArray *cellClasses;
@property (nonatomic, strong)NSMutableArray *cellAry;
@end

@implementation SubmitViewController

- (NSMutableArray *)cellAry {
    if (!_cellAry) {
        _cellAry = [NSMutableArray array] ;
    }
    return _cellAry;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [[Manager shareManager] addDelegate:self];
    self.view.backgroundColor = [QFTools colorWithHexString:@"#ebecf2"];
    [self setupNavView];
    
    [NSNOTIC_CENTER addObserver:self selector:@selector(SubmitquerySuccess:) name:KNotification_QueryBleKeyData object:nil];
    
    [NSNOTIC_CENTER addObserver:self selector:@selector(updateDeviceStatusAction2:) name:KNotification_UpdateDeviceStatus object:nil];
    
    [self setupMainView];
    
    if ([[AppDelegate currentAppDelegate].device isConnected]) {
        NSString *AutomaticLockHEX = @"A5000007300302";
        [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:AutomaticLockHEX]];
    }
    
}

- (void)setupNavView{
    [super setupNavView];
    self.navView.backgroundColor = [QFTools colorWithHexString:MainColor];
    self.navView.showBottomLabel = NO;
    NSString *bikeQuerySql = [NSString stringWithFormat:@"SELECT * FROM bike_modals WHERE bikeid LIKE '%zd'", self.deviceNum];
    NSMutableArray *bikemodals = [LVFmdbTool queryBikeData:bikeQuerySql];
    BikeModel *bikemodel = bikemodals.firstObject;
    [self.navView.centerButton setTitle:bikemodel.bikename forState:UIControlStateNormal];
    @weakify(self);
    [self.navView.leftButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    self.navView.leftButtonBlock = ^{
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    };
}

-(void)setDeviceNum:(NSInteger) deviceNum{
    
    _deviceNum = deviceNum;
    NSString *bikeQuerySql = [NSString stringWithFormat:@"SELECT * FROM bike_modals WHERE bikeid LIKE '%zd'", _deviceNum];
    NSMutableArray *bikemodals = [LVFmdbTool queryBikeData:bikeQuerySql];
    BikeModel *bikemodel = bikemodals.firstObject;
    
    if (bikemodel.vibr_sens_func == 1) {
        [self.cellAry addObject:@"bikeFunctionTableViewCell"];
    }
    
    [self.cellAry addObject:@"AutomaticLockTableViewCell"];
    [self.cellAry addObject:@"FirmwareUpgradeTableViewCell"];
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.bikeSubmitView reloadData];
    });
}


-(void)setupMainView{
    
    UITableView *bikeSubmitView = [[UITableView alloc] initWithFrame:CGRectMake(0, navHeight, ScreenWidth, ScreenHeight - navHeight)];
    bikeSubmitView.delegate = self;
    bikeSubmitView.dataSource = self;
    bikeSubmitView.bounces = NO;
    for (NSInteger index = 0; index < self.cellIdentifiers.count; index++) {
        
        [bikeSubmitView registerClass:self.cellClasses[index] forCellReuseIdentifier:self.cellIdentifiers[index]];
    }
    bikeSubmitView.backgroundColor = [UIColor clearColor];
    [bikeSubmitView setSeparatorColor:[UIColor colorWithWhite:1 alpha:0.06]];
    bikeSubmitView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [bikeSubmitView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    [self.view addSubview:bikeSubmitView];
    self.bikeSubmitView = bikeSubmitView;
    
    UIView *footview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 75)];
    [self.view addSubview:footview];
    
    UIButton *UnbundBtn = [[UIButton alloc] initWithFrame:CGRectMake(80, 15, ScreenWidth - 160, 45)];
    UnbundBtn.backgroundColor = [QFTools colorWithHexString:@"#cb0016"];
    [UnbundBtn addTarget:self action:@selector(UnbundDevice:) forControlEvents:UIControlEventTouchUpInside];
    [UnbundBtn setTitle:NSLocalizedString(@"un_bind_device", nil) forState:UIControlStateNormal];
    [UnbundBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    UnbundBtn.backgroundColor = [QFTools colorWithHexString:NSLocalizedString(@"VCControlColor", nil)];
    [UnbundBtn.layer setCornerRadius:22.5]; // 切圆角
    [footview addSubview:UnbundBtn];
    bikeSubmitView.tableFooterView = footview;
}

#pragma mark -- TableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
    
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        
        return 4;
    }else if (section == 1){
        return 1;
    }else if (section == 2){
        return 1;
    }else {
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0){
        
        return 50.0f;
    }else if (indexPath.section == 1){
        
        return ScreenHeight *.13 + 5;
    }else if (indexPath.section == 2){
        
        return ScreenHeight *.13 + 5;
    }else {
    
        return self.cellAry.count*50;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *header = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 0.1)];
    return header;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    UIView *header = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 10.0)];
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 4) {
        return 0.1;
    }
    return 10.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.1;
}
- ( void )tableView:( UITableView  *)tableView  willDisplayCell :( UITableViewCell  *)cell  forRowAtIndexPath :( NSIndexPath  *)indexPath{
    
    cell.backgroundColor = [UIColor colorWithWhite:1 alpha:0.05];
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section{
    
    view.tintColor = [QFTools colorWithHexString:@"#cccccc"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *bikeQuerySql = [NSString stringWithFormat:@"SELECT * FROM bike_modals WHERE bikeid LIKE '%zd'", self.deviceNum];
    NSMutableArray *bikemodals = [LVFmdbTool queryBikeData:bikeQuerySql];
    BikeModel *bikemodel = bikemodals.firstObject;
    
    if (indexPath.section == 0) {
        
        bikeFunctionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"bikeFunctionTableViewCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UIImageView *icon = cell.Icon;
        UILabel *name = cell.nameLab;
        UILabel *detailLab = cell.detailLab;
        
        if (indexPath.row == 0) {
            icon.image = [UIImage imageNamed:@"icon_bike_name"];
            name.text = NSLocalizedString(@"search_car_name", nil);
            detailLab.text = [NSString stringWithFormat:@"%@",bikemodel.bikename];
            
        }else if (indexPath.row == 1) {
            icon.image = [UIImage imageNamed:@"icon_p1"];
            name.text = NSLocalizedString(@"car_brand", nil);
            detailLab.text = NSLocalizedString(@"default_brand", nil);;
            cell.arrow.hidden = YES;
        }else if (indexPath.row == 2){
            
            icon.image = [UIImage imageNamed:@"icon_p3"];
            name.text = NSLocalizedString(@"accessories_manager", nil);
            [detailLab removeFromSuperview];
        }else if (indexPath.row == 3){
            
            icon.image = [UIImage imageNamed:@"fingerprint_icon"];
            name.text = NSLocalizedString(@"bike_fingerpring", nil);
            [detailLab removeFromSuperview];
        }
        
        return cell;
    }else if (indexPath.section == 1){
        
        BikeInductionDistanceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BikeInductionDistanceTableViewCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UISwitch *swi1 = cell.swit;
        LianUISlider *slider = cell.slider;
        
        swi1.hidden = NO;
        cell.Icon.image = [UIImage imageNamed:@"icon_p4"];
        cell.nameLab.text = NSLocalizedString(@"induction", nil);
        swi1.tag = 7000;
        NSString *fuzzyinduSql = [NSString stringWithFormat:@"SELECT * FROM induction_modals WHERE bikeid LIKE '%zd'", self.deviceNum];
        NSMutableArray *inductionmodals = [LVFmdbTool queryInductionData:fuzzyinduSql];
        InductionModel *indumodel = inductionmodals.firstObject;
        
        if (inductionmodals.count == 0) {
            [swi1 setOn:NO animated:NO];
        }else if(indumodel.induction == 0){
            [swi1 setOn:NO animated:NO];
        }else if (indumodel.induction == 1){
            [swi1 setOn:YES animated:NO];
        }
        
        [swi1 addTarget:self action:@selector(getValue1:) forControlEvents:UIControlEventValueChanged];
        slider.tag = 180;
        slider.minimumValue = 60;
        slider.maximumValue = 80;
        if (inductionmodals.count == 0 || indumodel.inductionValue == 0) {
            slider.value = 70;
        }else{
            slider.value = indumodel.inductionValue;
        }
        [slider addTarget:self action:@selector(updateValue:) forControlEvents:UIControlEventTouchUpInside];
        
        if (swi1.on) {
            slider.userInteractionEnabled = YES;
            [slider setThumbImage:[UIImage imageNamed:@"slideimage"] forState:UIControlStateNormal];
        }else{
            slider.userInteractionEnabled = NO;
            [slider setThumbImage:[UIImage imageNamed:@"graypoint"] forState:UIControlStateNormal];
        }
            
        return cell;
    }else if (indexPath.section == 2){
        BikeInductionDistanceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BikeDeviceInductionDistanceTableViewCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UISwitch *swi1 = cell.swit;
        LianUISlider *slider = cell.slider;
        swi1.hidden = YES;
        cell.Icon.image = [UIImage imageNamed:@"icon_p5"];
        cell.nameLab.text = NSLocalizedString(@"induction_distance_key", nil);
        
        slider.tag = 201;
        slider.minimumValue = 76;
        slider.maximumValue = 92;
        
        if (![[AppDelegate currentAppDelegate].device isConnected]) {
            
            [slider setThumbImage:[UIImage imageNamed:@"graypoint"] forState:UIControlStateHighlighted];
            [slider setThumbImage:[UIImage imageNamed:@"graypoint"] forState:UIControlStateNormal];
        }else{
            
            [slider setThumbImage:[UIImage imageNamed:@"slideimage"] forState:UIControlStateHighlighted];
            [slider setThumbImage:[UIImage imageNamed:@"slideimage"] forState:UIControlStateNormal];
        }
        
        [slider addTarget:self action:@selector(updateValue:) forControlEvents:UIControlEventTouchUpInside];
        
        NSString *qureeySql = [NSString stringWithFormat:@"SELECT * FROM induckey_modals WHERE bikeid LIKE '%zd'", self.deviceNum];
        NSMutableArray *indukeymodals = [LVFmdbTool queryInduckeyData:qureeySql];
        InduckeyModel *indukeymodel = indukeymodals.firstObject;
        
        if (indukeymodals.count == 0) {
            
            if([[AppDelegate currentAppDelegate].device isConnected]){
                NSString *passwordHEX = [NSString stringWithFormat:@"A5000007200300"];
                [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
                
            }else{
                slider.value = 82;
            }
            
        }else{
            slider.value = indukeymodel.induckeyValue;
        }
        
    return cell;
        
    }else{
        TailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TailTableViewCell"];
        cell.deviceNum = _deviceNum;
        cell.shockState = _shockState;
        [cell reloadModel:self.cellAry :indexPath];
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        
        if (indexPath.row == 0) {
            
            NSString *bikeQuerySql = [NSString stringWithFormat:@"SELECT * FROM bike_modals WHERE bikeid LIKE '%zd'", self.deviceNum];
            NSMutableArray *bikemodals = [LVFmdbTool queryBikeData:bikeQuerySql];
            BikeModel *bikemodel = bikemodals.firstObject;
            if (bikemodel.ownerflag == 0) {
                [SVProgressHUD showSimpleText:NSLocalizedString(@"fingerpring_child_no", nil)];
                return;
            }
            
            nameTextFiledController * nameText = [nameTextFiledController new];
            nameText.deviceNum = self.deviceNum;
            [self.navigationController pushViewController:nameText animated:YES];
            
        }else if (indexPath.row == 2){
            
            AccessoriesViewController *accessVc = [AccessoriesViewController new];
            accessVc.deviceNum = self.deviceNum;
            [self.navigationController pushViewController:accessVc animated:YES];

        }else if (indexPath.row == 3){
            
            if (![[AppDelegate currentAppDelegate].device isConnected]) {
                
                [SVProgressHUD showSimpleText:NSLocalizedString(@"device_disconnect", nil)];
                return;
            }
            
            VehicleFingerprintViewController *vehicleVc = [VehicleFingerprintViewController new];
            vehicleVc.deviceNum = self.deviceNum;
            [self.navigationController pushViewController:vehicleVc animated:YES];
        }
        
    }
}

#pragma mark - BindingUserViewControllerDelegate
-(void)UpdateUsernumberSuccess{
    
//    NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:1];
//    [self.bikeSubmitView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.bikeSubmitView reloadData];
    });
}

#pragma mark - Getter
- (NSArray *)cellIdentifiers {
    
    if (!_cellIdentifiers) {
        
        _cellIdentifiers = @[@"bikeFunctionTableViewCell",@"BikeInductionDistanceTableViewCell",@"BikeDeviceInductionDistanceTableViewCell",@"TailTableViewCell"];
    }
    return _cellIdentifiers;
}

- (NSArray *)cellClasses {
    
    if (!_cellClasses) {
        
        _cellClasses = @[[bikeFunctionTableViewCell class],
                         [BikeInductionDistanceTableViewCell class],[BikeInductionDistanceTableViewCell class],[TailTableViewCell class]];
    }
    return _cellClasses;
}




-(void)UnbundDevice:(UIButton *)btn{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"reminders", nil) message:NSLocalizedString(@"remove_device_true", nil) preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:NSLocalizedString(@"sure", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        dispatch_group_t group = dispatch_group_create();
        dispatch_group_enter(group);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [self UnbundBtnClick];
            
            dispatch_group_leave(group);
        });
    }];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alert addAction:action1];
    [alert addAction:action2];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}


-(void)SubmitquerySuccess:(NSNotification *)data{
    
    NSString *date = data.userInfo[@"data"];
    if ([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"2003"]) {
        
        NSString *date = data.userInfo[@"data"];
        NSData *datevalue = [ConverUtil parseHexStringToByteArray:date];
        Byte *byte=(Byte *)[datevalue bytes];
        if (byte[6] > 92) {
            return;
        }
        
        NSInteger inducKeyValue = byte[6];
        NSString *qureeySql = [NSString stringWithFormat:@"SELECT * FROM induckey_modals WHERE bikeid LIKE '%zd'", self.deviceNum];
        NSMutableArray *indukeymodals = [LVFmdbTool queryInduckeyData:qureeySql];
        
        if (indukeymodals.count == 0) {
            InduckeyModel *inducmodel = [InduckeyModel modalWith:self.deviceNum induckeyValue:inducKeyValue];
            [LVFmdbTool insertInduckeyModel:inducmodel];
        }else{
            NSString *updateSql = [NSString stringWithFormat:@"UPDATE induckey_modals SET induckeyValue = '%zd' WHERE bikeid = '%zd'", inducKeyValue,self.deviceNum];
            [LVFmdbTool modifyData:updateSql];
        }
        
        InduckeyModel *inducmodel = [InduckeyModel modalWith:self.deviceNum induckeyValue:inducKeyValue];
        [LVFmdbTool insertInduckeyModel:inducmodel];
        
        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:0 inSection:2];
        [self.bikeSubmitView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
        
    }else if ([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"3003"]) {
        
        NSString *queraAutomaticLockSql = [NSString stringWithFormat:@"SELECT * FROM automaticlock_models WHERE bikeid LIKE '%zd'", self.deviceNum];
        NSMutableArray *AutomaticLockmodels = [LVFmdbTool queryAutomaticLockData:queraAutomaticLockSql];
        
        if (AutomaticLockmodels.count == 0) {
            
            if ([[date substringWithRange:NSMakeRange(8, 6)] isEqualToString:@"300300"]){
                
                AutomaticLockModel *automaticlockmodel = [AutomaticLockModel modalWith:self.deviceNum automaticlock:0];
                [LVFmdbTool insertAutomaticLockModel:automaticlockmodel];
                
            }else if ([[date substringWithRange:NSMakeRange(8, 6)] isEqualToString:@"300301"]){
                
                AutomaticLockModel *automaticlockmodel = [AutomaticLockModel modalWith:self.deviceNum automaticlock:1];
                [LVFmdbTool insertAutomaticLockModel:automaticlockmodel];
            }
            
        }else{
            
            if ([[date substringWithRange:NSMakeRange(8, 6)] isEqualToString:@"300300"]){
                
                NSString *updateSql = [NSString stringWithFormat:@"UPDATE automaticlock_models SET automaticlock = '%d' WHERE bikeid = '%zd'", 0,self.deviceNum];
                [LVFmdbTool modifyData:updateSql];
            }else if ([[date substringWithRange:NSMakeRange(8, 6)] isEqualToString:@"300301"]){
                
                NSString *updateSql = [NSString stringWithFormat:@"UPDATE automaticlock_models SET automaticlock = '%d' WHERE bikeid = '%zd'", 1,self.deviceNum];
                [LVFmdbTool modifyData:updateSql];
            }
        }
    }
}


-(void)breakBLEconnect{

    [[AppDelegate currentAppDelegate].device startScan];
    
}


- (void)updateValue:(UISlider *)sender{
    
    if (sender.tag == 180) {
        
        NSInteger phInductionValue = sender.value;
        
        if (phInductionValue <= 65) {
            UIAlertController * alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"reminders", nil) message:NSLocalizedString(@"induction_function_phone_open_content", nil) preferredStyle:UIAlertControllerStyleAlert];//UIAlertControllerStyleAlert视图在中央
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"sure", nil) style:UIAlertActionStyleDefault handler:nil];//https在iTunes中找，这里的事件是前往手机端App store下载微信
            [alertController addAction:okAction];
            [self presentViewController:alertController animated:YES completion:nil];
        }
        
        //NSString *value = [NSString stringWithFormat:@"%zd",phInductionValue];
        NSString *phInductionQuerySql = [NSString stringWithFormat:@"SELECT * FROM induction_modals WHERE bikeid LIKE '%zd'", self.deviceNum];
        NSMutableArray *inducmodals = [LVFmdbTool queryInductionData:phInductionQuerySql];
        if (inducmodals.count == 0) {
            
            InductionModel *inducmodel = [InductionModel modalWith:self.deviceNum inductionValue:phInductionValue induction:1];
            [LVFmdbTool insertInductionModel:inducmodel];
        }else{
            
            NSString *updateSql = [NSString stringWithFormat:@"UPDATE induction_modals SET inductionValue = '%zd' WHERE bikeid = '%zd'",phInductionValue,self.deviceNum];
            [LVFmdbTool modifyData:updateSql];
        }
        
        if([self.delegate respondsToSelector:@selector(regulatePhoneInductionValue:)])
        {
            [self.delegate regulatePhoneInductionValue:phInductionValue];
        }
        
        
        }else if (sender.tag == 201){
        
        if (![[AppDelegate currentAppDelegate].device isConnected]) {
            
            [SVProgressHUD showSimpleText:NSLocalizedString(@"device_disconnect", nil)];
            return;
        }
            
        int f = sender.value;
        if (f <= 81) {
            UIAlertController * alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"reminders", nil) message:NSLocalizedString(@"induction_function_phone_open_content", nil) preferredStyle:UIAlertControllerStyleAlert];//UIAlertControllerStyleAlert视图在中央
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"sure", nil) style:UIAlertActionStyleDefault handler:nil];//https在iTunes中找，这里的事件是前往手机端App store下载微信
            [alertController addAction:okAction];
            [self presentViewController:alertController animated:YES completion:nil];
        }
            
        NSString *passwordHEX = [NSString stringWithFormat:@"A50000072003%@",[ConverUtil ToHex:f]];
        [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
    }
}


- (void)getValue1:(id)sender{
    
    UISwitch *swi=(UISwitch *)sender;
    
    if (swi.tag == 7000) {
        NSString *phInductionQuerySql = [NSString stringWithFormat:@"SELECT * FROM induction_modals WHERE bikeid LIKE '%zd'", self.deviceNum];
        NSMutableArray *inducmodals = [LVFmdbTool queryInductionData:phInductionQuerySql];
        if (swi.isOn) {
            
            UIAlertController * alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"reminders", nil) message:NSLocalizedString(@"induction_function_phone_to_near", nil) preferredStyle:UIAlertControllerStyleAlert];//UIAlertControllerStyleAlert视图在中央
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"sure", nil) style:UIAlertActionStyleDefault handler:nil];//https在iTunes中找，这里的事件是前往手机端App store下载微信
            [alertController addAction:okAction];
            [self presentViewController:alertController animated:YES completion:nil];
            
            if (inducmodals.count == 0) {
                
                InductionModel *inducmodel = [InductionModel modalWith:self.deviceNum inductionValue:70 induction:1];
                [LVFmdbTool insertInductionModel:inducmodel];
                
            }else{
                
                NSString *updateSql = [NSString stringWithFormat:@"UPDATE induction_modals SET induction = '%d' WHERE bikeid = '%zd'",1,self.deviceNum];
                [LVFmdbTool modifyData:updateSql];
            }
            
        }else{
            
            if (inducmodals.count == 0) {
                
                InductionModel *inducmodel = [InductionModel modalWith:self.deviceNum inductionValue:70 induction:0];
                [LVFmdbTool insertInductionModel:inducmodel];
                
            }else{
                
                NSString *updateSql = [NSString stringWithFormat:@"UPDATE induction_modals SET induction = '%d' WHERE bikeid = '%zd'",0,self.deviceNum];
                [LVFmdbTool modifyData:updateSql];
            }
        }
        
        if([self.delegate respondsToSelector:@selector(regulatePhoneInduction:)])
        {
            [self.delegate regulatePhoneInduction:swi.isOn];
        }
        
        NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:1];
        [self.bikeSubmitView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}


//车辆的连接状态改变响应函数
-(void)updateDeviceStatusAction2:(NSNotification*)notification{
    
    NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:2];
    [self.bikeSubmitView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
}

//解绑回调
-(void)UnbundBtnClick{
    
    LoadView *loadview = [LoadView sharedInstance];
    loadview.protetitle.text = NSLocalizedString(@"unbinding", nil);
    [loadview show];
    
    NSString *deleteBikeSql = [NSString stringWithFormat:@"DELETE FROM bike_modals WHERE bikeid LIKE '%zd'", self.deviceNum];
    [LVFmdbTool deleteBikeData:deleteBikeSql];
    
    NSString *deleteBrandSql = [NSString stringWithFormat:@"DELETE FROM brand_modals WHERE bikeid LIKE '%zd'", self.deviceNum];
    [LVFmdbTool deleteBrandData:deleteBrandSql];
    
    NSString *deleteInfoSql = [NSString stringWithFormat:@"DELETE FROM info_modals WHERE bikeid LIKE '%zd'", self.deviceNum];
    [LVFmdbTool deleteModelData:deleteInfoSql];
    
    NSString *deletePeripherSql = [NSString stringWithFormat:@"DELETE FROM periphera_modals WHERE bikeid LIKE '%zd'", self.deviceNum];
    [LVFmdbTool deletePeripheraData:deletePeripherSql];
    
    NSString *deleteFingerSql = [NSString stringWithFormat:@"DELETE FROM fingerprint_modals WHERE bikeid LIKE '%zd'", self.deviceNum];
    [LVFmdbTool deleteFingerprintData:deleteFingerSql];
    
    [[AppDelegate currentAppDelegate].device remove];
    [USER_DEFAULTS removeObjectForKey:Key_DeviceUUID];
    [USER_DEFAULTS removeObjectForKey:Key_MacSTRING];
    [USER_DEFAULTS removeObjectForKey:SETRSSI];
    [USER_DEFAULTS removeObjectForKey:passwordDIC];
    [USER_DEFAULTS synchronize];
    
    NSString *deleteuuidSql = [NSString stringWithFormat:@"DELETE FROM peripherauuid_modals WHERE bikeid LIKE '%zd'", self.deviceNum];
    [LVFmdbTool deletePeripheraUUIDData:deleteuuidSql];
    
    NSString *inductionSql = [NSString stringWithFormat:@"DELETE FROM induction_modals WHERE bikeid LIKE '%zd'", self.deviceNum];
    [LVFmdbTool deleteInductionData:inductionSql];
    
    NSString *deleteinduckey = [NSString stringWithFormat:@"DELETE FROM induckey_modals WHERE bikeid LIKE '%zd'", self.deviceNum];
    [LVFmdbTool deleteInduckeyData:deleteinduckey];
    
    NSString *deletePressurelock = [NSString stringWithFormat:@"DELETE FROM pressurelock_models WHERE bikeid LIKE '%zd'", self.deviceNum];
    [LVFmdbTool deletePressureLockData:deletePressurelock];
    
    NSString *deleteAutomaticlockkey = [NSString stringWithFormat:@"DELETE FROM automaticlock_models WHERE bikeid LIKE '%zd'", self.deviceNum];
    [LVFmdbTool deleteAutomaticLockData:deleteAutomaticlockkey];
    
    if ([LVFmdbTool queryBikeData:nil].count >0) {
        
        if([self.delegate respondsToSelector:@selector(submitUnbundDevice:)])
        {
            [self.delegate submitUnbundDevice:self.deviceNum];
        }
        
        [loadview hide];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }else{
        
        [loadview hide];
        [NSNOTIC_CENTER postNotificationName:KNOTIFICATION_LOGINCHANGE object:@YES];
    }
    
}


#pragma mark - ManagerDelegate
-(void)manager:(Manager *)manager updatebikeName:(NSString *)name :(NSInteger)bikeId{
    
    [self.navView.centerButton setTitle:name forState:UIControlStateNormal];
    NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:0];
    [self.bikeSubmitView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
}

-(void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[Manager shareManager] deleteDelegate:self];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
    
}

//****************以上是固件升级**********//
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
