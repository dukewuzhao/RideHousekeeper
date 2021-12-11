//
//  TailTableViewCell.m
//  RideHousekeeper
//
//  Created by Apple on 2019/8/1.
//  Copyright © 2019 Duke Wu. All rights reserved.
//

#import "TailTableViewCell.h"
#import "bikeFunctionTableViewCell.h"
#import "AutomaticLockTableViewCell.h"
#import "TirePressureMonitoringTableViewCell.h"
#import "PickerChoiceView.h"
#import "SubmitViewController.h"
#import "BikeStatusModel.h"
#import "TailSwitch.h"
#import "Manager.h"

@interface TailTableViewCell ()<UITableViewDelegate,UITableViewDataSource,TFPickerDelegate>

@property (nonatomic, assign)NSInteger speeding_alarm;
@property (nonatomic, assign)NSInteger pressureLock;
@property (nonatomic, assign)NSInteger bikeMute;
@property (nonatomic, copy)NSArray *cellIdentifiers;
@property (nonatomic, copy)NSArray *cellClasses;
@property (nonatomic, copy)NSArray *cellAry;
@end

@implementation TailTableViewCell

#pragma mark - Getter
- (NSArray *)cellIdentifiers {
    
    if (!_cellIdentifiers) {
        
        _cellIdentifiers = @[@"bikeFunctionTableViewCell",@"AutomaticLockTableViewCell",@"TirePressureMonitoringTableViewCell"];
    }
    return _cellIdentifiers;
}

- (NSArray *)cellClasses {
    
    if (!_cellClasses) {
        
        _cellClasses = @[[bikeFunctionTableViewCell class],
                         [AutomaticLockTableViewCell class],
                         [TirePressureMonitoringTableViewCell class]];
    }
    return _cellClasses;
}

//- (NSArray *)cellAry {
//
//    if (!_cellAry) {
//
//        _cellAry = [NSArray array];
//    }
//    return _cellAry;
//}

-(void)setDeviceNum:(NSInteger) deviceNum{
    
    _deviceNum = deviceNum;
    
    NSString *queraPressureLockSql = [NSString stringWithFormat:@"SELECT * FROM pressurelock_models WHERE bikeid LIKE '%zd'", _deviceNum];
    NSMutableArray *PressureLockmodels = [LVFmdbTool queryPressureLockData:queraPressureLockSql];
    PressureLockModel *PressureLockmodel = PressureLockmodels.firstObject;
    if (PressureLockmodels.count == 0) {
        
        self.speeding_alarm = 0;
        self.pressureLock = 0;
    }else{
        
        self.speeding_alarm = PressureLockmodel.speeding_alarm;
        self.pressureLock = PressureLockmodel.pressurelock;
    }
    
}

-(void)reloadModel:(NSMutableArray *)ary :(NSIndexPath *)index{
   
    _cellAry = [ary copy];
//    CGFloat tableViewHeight = ary.count * 40;
//    [_tailView mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.height.mas_equalTo(tableViewHeight);
//    }];
    _tailView.dataSource = self;
    _tailView.delegate = self;
    [_tailView reloadData];
}


-(void)getDeviceAutomaticLockStatus{
    @weakify(self);
    [CommandDistributionServices getDeviceAutomaticLockStatus:^(BOOL automaticLock) {
        @strongify(self);
        [self updateDeviceAutomaticLockStatus:automaticLock];
    } error:^(CommandStatus status) {
        switch (status) {
            case SendSuccess:
                NSLog(@"获取自动锁车发送成功");
                break;
                
            default:
                NSLog(@"获取自动锁车发送失败");
                break;
        }
    }];
}

-(void)setDeviceAutomaticLockStatus:(BOOL)automaticLockStatus{
    @weakify(self);
    [CommandDistributionServices setDeviceAutomaticLockStatus:automaticLockStatus data:^(BOOL automaticLock) {
        @strongify(self);
        [self updateDeviceAutomaticLockStatus:automaticLock];
    } error:^(CommandStatus status) {
        switch (status) {
            case SendSuccess:
                NSLog(@"设置自动锁车发送成功");
                break;
                
            default:
                NSLog(@"设置自动锁车发送失败");
                break;
        }
    }];
}

-(void)updateDeviceAutomaticLockStatus:(BOOL)status{
    
    NSMutableArray *AutomaticLockmodels = [LVFmdbTool queryAutomaticLockData:[NSString stringWithFormat:@"SELECT * FROM automaticlock_models WHERE bikeid LIKE '%zd'", self.deviceNum]];
    if (AutomaticLockmodels.count == 0) {
        
        if (status){
            
            AutomaticLockModel *automaticlockmodel = [AutomaticLockModel modalWith:self.deviceNum automaticlock:1];
            [LVFmdbTool insertAutomaticLockModel:automaticlockmodel];
            
        }else {
            
            AutomaticLockModel *automaticlockmodel = [AutomaticLockModel modalWith:self.deviceNum automaticlock:0];
            [LVFmdbTool insertAutomaticLockModel:automaticlockmodel];
        }
    }else{
        if (status){
            
            NSString *updateSql = [NSString stringWithFormat:@"UPDATE automaticlock_models SET automaticlock = '%zd' WHERE bikeid = '%zd'", 1,self.deviceNum];
            [LVFmdbTool modifyData:updateSql];
        }else{
            
            NSString *updateSql = [NSString stringWithFormat:@"UPDATE automaticlock_models SET automaticlock = '%zd' WHERE bikeid = '%zd'", 0,self.deviceNum];
            [LVFmdbTool modifyData:updateSql];
        }
    }
    [self.tailView reloadData];
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        @weakify(self);
        [[[NSNOTIC_CENTER rac_addObserverForName:KNotification_ConnectStatus object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id x) {
            @strongify(self);
            NSNotification *userInfo = x;
            if (![userInfo.object boolValue]) {
                
                [self getDeviceAutomaticLockStatus];
            }
        }];
        
        [[[NSNOTIC_CENTER rac_addObserverForName:KNotification_FirmwareUpgradeCompleted object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id x) {
            @strongify(self);

            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tailView reloadData];
            });
        }];
        
        [self addObserver:self forKeyPath:@"speeding_alarm" options:NSKeyValueObservingOptionNew context:nil];
        [self addObserver:self forKeyPath:@"pressureLock" options:NSKeyValueObservingOptionNew context:nil];
        [self addObserver:self forKeyPath:@"bikeMute" options:NSKeyValueObservingOptionNew context:nil];
        [[[NSNOTIC_CENTER rac_addObserverForName:KNotification_QueryData object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id x) {
            @strongify(self);
            NSNotification *userInfo = x;
            BikeStatusModel *model = userInfo.object;
            
                if (model.speedingAlarm && self.speeding_alarm == 1) {
                    
                    self.speeding_alarm = 0;
                }else if (!model.speedingAlarm && self.speeding_alarm == 0){
                    
                    self.speeding_alarm = 1;
                }
                
                if (!model.tirePressureAlarm && self.pressureLock == 1) {
                    
                    self.pressureLock = 0;
                }else if (model.tirePressureAlarm && self.pressureLock == 0){
                    
                    self.pressureLock = 1;
                }
            
            if (!model.isMute && self.bikeMute == 1) {
                
                self.bikeMute = 0;
            }else if (model.isMute && self.bikeMute == 0){
                
                self.bikeMute = 1;
            }
            
        }];
        _tailView = [[UITableView alloc] init];
        _tailView.scrollEnabled = NO;
        _tailView.bounces = NO;
        _tailView.backgroundColor = [UIColor clearColor];
        for (NSInteger index = 0; index < self.cellIdentifiers.count; index++) {
            
            [_tailView registerClass:self.cellClasses[index] forCellReuseIdentifier:self.cellIdentifiers[index]];
        }
        [_tailView setSeparatorColor:[QFTools colorWithHexString:SeparatorColor]];
        [_tailView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
        [self.contentView addSubview:_tailView];
        
        [_tailView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.bottom.mas_equalTo(0);
        }];
    }
    return self;
}

#pragma mark -- TableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _cellAry.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 50.0f;
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
    
    return 0.1;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.1;
}
- (void)tableView:( UITableView  *)tableView  willDisplayCell :( UITableViewCell  *)cell  forRowAtIndexPath :( NSIndexPath  *)indexPath{
    
    cell.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section{
    
    view.tintColor = [QFTools colorWithHexString:@"#cccccc"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *bikeQuerySql = [NSString stringWithFormat:@"SELECT * FROM bike_modals WHERE bikeid LIKE '%zd'", _deviceNum];
    NSMutableArray *bikemodals = [LVFmdbTool queryBikeData:bikeQuerySql];
    BikeModel *bikemodel = bikemodals.firstObject;
    
    if ([_cellAry[indexPath.row] isEqualToString:@"BikeMuteTableViewCell"]) {
        
        TirePressureMonitoringTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TirePressureMonitoringTableViewCell"];
        cell.Icon.image = [UIImage imageNamed:@"icon_bike_mute"];
        cell.nameLab.text = @"车辆静音";
        TailSwitch *swi1 = cell.swit;
        swi1.tag = 9999;
        if (self.bikeMute == 0) {
            [swi1 setOn:NO animated:NO];
        }else if (self.bikeMute == 1){
            [swi1 setOn:YES animated:NO];
        }
        [swi1 addTarget:self action:@selector(getValue1:) forControlEvents:UIControlEventValueChanged];
        
        return cell;
        
    }else if ([_cellAry[indexPath.row] isEqualToString:@"TirePressureMonitoringTableViewCell"]) {
        
        TirePressureMonitoringTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TirePressureMonitoringTableViewCell"];
        cell.Icon.image = [UIImage imageNamed:@"Tire_pressure_alarm"];
        cell.nameLab.text = @"胎压警报";
        TailSwitch *swi1 = cell.swit;
        swi1.tag = 10000;
        if (self.pressureLock == 0) {
            [swi1 setOn:NO animated:NO];
        }else if (self.pressureLock == 1){
            [swi1 setOn:YES animated:NO];
        }
        [swi1 addTarget:self action:@selector(getValue1:) forControlEvents:UIControlEventValueChanged];
        
        return cell;
        
    }else if ([_cellAry[indexPath.row] isEqualToString:@"SpeedingAlarmTableViewCell"]){
        
        TirePressureMonitoringTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TirePressureMonitoringTableViewCell"];
        cell.Icon.image = [UIImage imageNamed:@"speeding_alarm"];
        cell.nameLab.text = @"超速警报";
        TailSwitch *swi1 = cell.swit;
        swi1.tag = 9000;
        if (self.speeding_alarm == 0) {
            [swi1 setOn:NO animated:NO];
        }else if (self.speeding_alarm == 1){
            [swi1 setOn:YES animated:NO];
        }
        [swi1 addTarget:self action:@selector(getValue1:) forControlEvents:UIControlEventValueChanged];
        
        return cell;
        
    }else if ([_cellAry[indexPath.row] isEqualToString:@"bikeFunctionTableViewCell"]){
        
        bikeFunctionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"bikeFunctionTableViewCell"];
        cell.upgrade_red_dot.hidden = YES;
        cell.Icon.image = [UIImage imageNamed:@"icon_inductive_sensitivity"];
        cell.nameLab.text = @"震动灵敏度";
        
        if (self.shockState != nil) {
            cell.detailLab.text = self.shockState;
        }else{
            cell.detailLab.text = @"低";
        }
        return cell;
        
    }else if ([_cellAry[indexPath.row] isEqualToString:@"AutomaticLockTableViewCell"]){
        
        AutomaticLockTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AutomaticLockTableViewCell"];
        cell.Icon.image = [UIImage imageNamed:@"icon_p7"];
        cell.nameLab.text = @"自动锁车";
        cell.detailLab.text = @"手机未连接，车辆解锁且车轮一定时间不转，自动锁车";
        TailSwitch *swi1 = cell.swit;
        swi1.tag = 8000;
        NSString *queraAutomaticLockSql = [NSString stringWithFormat:@"SELECT * FROM automaticlock_models WHERE bikeid LIKE '%zd'", self.deviceNum];
        NSMutableArray *AutomaticLockmodels = [LVFmdbTool queryAutomaticLockData:queraAutomaticLockSql];
        AutomaticLockModel *AutomaticLockmodel = AutomaticLockmodels.firstObject;
        
        if (AutomaticLockmodels.count == 0) {
            
            if ([CommandDistributionServices isConnect]) {
                [self getDeviceAutomaticLockStatus];
            }else{
                [swi1 setOn:NO animated:NO];
            }
            
        }else if(AutomaticLockmodel.automaticlock == 0){
            
            [swi1 setOn:NO animated:NO];
        }else if (AutomaticLockmodel.automaticlock == 1){
            
            [swi1 setOn:YES animated:NO];
        }
        
        [swi1 addTarget:self action:@selector(getValue1:) forControlEvents:UIControlEventValueChanged];
        return cell;
        
    }else if ([_cellAry[indexPath.row] isEqualToString:@"FirmwareUpgradeTableViewCell"]){
        bikeFunctionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"bikeFunctionTableViewCell"];
        cell.Icon.image = [UIImage imageNamed:@"icon_p6"];
        cell.nameLab.text = @"固件版本";
        cell.detailLab.text = bikemodel.firmversion;
        
        if ([USER_DEFAULTS boolForKey:[NSString stringWithFormat:@"%ld",(long)self.deviceNum]]) {
            cell.upgrade_red_dot.hidden = NO;
        }else{
            cell.upgrade_red_dot.hidden = YES;
        }
        
        return cell;
    }else{
        UITableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:@"Cell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:0 reuseIdentifier:@"Cell"];
        }
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if ([_cellAry[indexPath.row] isEqualToString:@"bikeFunctionTableViewCell"]) {
        
        PickerChoiceView *picker = [[PickerChoiceView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
        picker.delegate = self;
        picker.arrayType = GenderArray;
        
        if (self.shockState != nil) {
            picker.selectStr = self.shockState;
        }else{
            picker.selectStr = @"低";
        }
        [[UIApplication sharedApplication].keyWindow addSubview:picker];
        
    }else if ([_cellAry[indexPath.row] isEqualToString:@"FirmwareUpgradeTableViewCell"]){
        
        NSString *bikeQuerySql = [NSString stringWithFormat:@"SELECT * FROM bike_modals WHERE bikeid LIKE '%zd'", self.deviceNum];
        NSMutableArray *bikemodals = [LVFmdbTool queryBikeData:bikeQuerySql];
        BikeModel *bikemodel = bikemodals.firstObject;
        
        if (bikemodel.ownerflag == 0) {
            
            [SVProgressHUD showSimpleText:@"子用户无此权限"];
            return;
        }
        [[Manager shareManager] BikeFirmwareUpgrade:_deviceNum];
    }
}


- (void)getValue1:(id)sender{
    
    UISwitch *swi=(UISwitch *)sender;
    if (swi.tag == 8000){
        
        if (![CommandDistributionServices isConnect]) {
            [SVProgressHUD showSimpleText:@"车辆未连接"];
            return;
        }
        [self setDeviceAutomaticLockStatus:swi.on];
        
    }else if (swi.tag == 9000){
        
        if (![CommandDistributionServices isConnect]) {
            
            [SVProgressHUD showSimpleText:@"车辆未连接"];
            return;
        }
        
        [CommandDistributionServices setDeviceSpeedingAlarmStatus:swi.isOn error:^(CommandStatus status) {
            
            switch (status) {
                case SendSuccess:
                    NSLog(@"设置超速警报发送成功");
                    break;
                default:
                    NSLog(@"设置超速警报发送失败");
                    break;
            }
        }];
        
    }else if (swi.tag == 9999){
        
        if (![CommandDistributionServices isConnect]) {
            
            [SVProgressHUD showSimpleText:@"车辆未连接"];
            return;
        }
        
        if (swi.isOn) {
            [CommandDistributionServices setBikeBasicStatues:DeviceSetSafeNoSound error:nil];
        }else{
            [CommandDistributionServices setBikeBasicStatues:DeviceSetSafeSound error:nil];
        }
        
    }else if (swi.tag == 10000){
        
        if (![CommandDistributionServices isConnect]) {
            
            [SVProgressHUD showSimpleText:@"车辆未连接"];
            return;
        }
        if (swi.isOn) {
            [CommandDistributionServices setBikeBasicStatues:DeviceOpenTirePressureAlarm error:nil];
        }else{
            [CommandDistributionServices setBikeBasicStatues:DeviceCloseTirePressureAlarm error:nil];
        }
    }
}

-(void)dealloc{
    
    [self removeObserver:self forKeyPath:@"speeding_alarm"];
    [self removeObserver:self forKeyPath:@"pressureLock"];
    [self removeObserver:self forKeyPath:@"bikeMute"];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


/**
 kvo监听

 @param keyPath keyPath description
 @param object object description
 @param change change description
 @param context context description
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void *)context{
    
    if (([keyPath isEqualToString:@"pressureLock"] || [keyPath isEqualToString:@"speeding_alarm"]) && object == self){
        
        NSString *queraPressureLockSql = [NSString stringWithFormat:@"SELECT * FROM pressurelock_models WHERE bikeid LIKE '%zd'", self.deviceNum];
        NSMutableArray *pressureLockmodels = [LVFmdbTool queryPressureLockData:queraPressureLockSql];
        
        if (pressureLockmodels.count == 0) {
            
            PressureLockModel *model = [PressureLockModel modalWith:self.deviceNum pressureLock:self.pressureLock speeding_alarm:self.speeding_alarm];
            [LVFmdbTool insertPressureLockModel:model];
            
        }else{
            NSString *updateSql = [NSString stringWithFormat:@"UPDATE pressurelock_models SET pressureLock = '%zd', speeding_alarm = '%zd' WHERE bikeid = '%zd'",self.pressureLock, self.speeding_alarm,self.deviceNum];
            [LVFmdbTool modifyData:updateSql];
        }
//        NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:4];
//        [_tailView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [_tailView reloadData];
        });
    }else if ([keyPath isEqualToString:@"bikeMute"] && object == self){
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [_tailView reloadData];
        });
    }
}



#pragma mark -------- TFPickerDelegate

- (void)PickerSelectorIndixString:(NSString *)str{
    
    if (![CommandDistributionServices isConnect]) {
        
        [SVProgressHUD showSimpleText:@"车辆未连接"];
        return;
    }
    
    if ([str isEqualToString:@"低"]) {
        
        [CommandDistributionServices setDeviceShockStatus:low error:^(CommandStatus status) {
            switch (status) {
                case SendSuccess:
                    NSLog(@"设置低震动模式成功");
                    break;
                    
                default:
                    NSLog(@"设置低震动模式失败");
                    break;
            }
        }];
        
    }else if ([str isEqualToString:@"中"]){
        
        [CommandDistributionServices setDeviceShockStatus:middle error:^(CommandStatus status) {
            switch (status) {
                case SendSuccess:
                    NSLog(@"设置中震动模式成功");
                    break;
                    
                default:
                    NSLog(@"设置中震动模式失败");
                    break;
            }
        }];
    }else if ([str isEqualToString:@"高"]){
        
        [CommandDistributionServices setDeviceShockStatus:high error:^(CommandStatus status) {
            switch (status) {
                case SendSuccess:
                    NSLog(@"设置高震动模式成功");
                    break;
                    
                default:
                    NSLog(@"设置高震动模式失败");
                    break;
            }
        }];
    }
    
    self.shockState = str;
    NSIndexPath *indexPath;
    if ([_cellAry[0] isEqualToString:@"bikeFunctionTableViewCell"]) {
        indexPath=[NSIndexPath indexPathForRow:0 inSection:0];
    }else if ([_cellAry[1] isEqualToString:@"bikeFunctionTableViewCell"]){
        indexPath=[NSIndexPath indexPathForRow:1 inSection:0];
    }else if ([_cellAry[2] isEqualToString:@"bikeFunctionTableViewCell"]){
        indexPath=[NSIndexPath indexPathForRow:2 inSection:0];
    }
    [_tailView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)PickerSelectorIndixColour:(UIColor *)color{
    
    NSLog(@"p----%@",color);
}


@end
