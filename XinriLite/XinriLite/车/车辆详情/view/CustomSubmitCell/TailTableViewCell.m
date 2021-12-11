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

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    
        @weakify(self);
        [self addObserver:self forKeyPath:@"speeding_alarm" options:NSKeyValueObservingOptionNew context:nil];
        [self addObserver:self forKeyPath:@"pressureLock" options:NSKeyValueObservingOptionNew context:nil];
        [self addObserver:self forKeyPath:@"bikeMute" options:NSKeyValueObservingOptionNew context:nil];
        [[[NSNOTIC_CENTER rac_addObserverForName:KNotification_QueryData object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id x) {
            @strongify(self);
            NSNotification *userInfo = x;
            NSString *date = userInfo.userInfo[@"data"];
            if ([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"1001"]) {
                NSString *binary = [QFTools getBinaryByhex:[date substringWithRange:NSMakeRange(12, 2)]];
                if ([[binary substringWithRange:NSMakeRange(2, 1)] isEqualToString:@"0"] && self.speeding_alarm == 1) {
                    
                    self.speeding_alarm = 0;
                }else if ([[binary substringWithRange:NSMakeRange(2, 1)] isEqualToString:@"1"]&& self.speeding_alarm == 0){
                    
                    self.speeding_alarm = 1;
                }
                
                if ([[binary substringWithRange:NSMakeRange(1, 1)] isEqualToString:@"0"] && self.pressureLock == 1) {
                    
                    self.pressureLock = 0;
                }else if ([[binary substringWithRange:NSMakeRange(1, 1)] isEqualToString:@"1"]&& self.pressureLock == 0){
                    
                    self.pressureLock = 1;
                }
                
                if ([[binary substringWithRange:NSMakeRange(1, 1)] isEqualToString:@"0"] && self.bikeMute == 1) {
                    
                    self.bikeMute = 0;
                }else if ([[binary substringWithRange:NSMakeRange(1, 1)] isEqualToString:@"1"]&& self.bikeMute == 0){
                    
                    self.bikeMute = 1;
                }
                
            }
        }];
        _tailView = [[UITableView alloc] init];
        _tailView.scrollEnabled = NO;
        _tailView.bounces = NO;
        _tailView.backgroundColor = [UIColor clearColor];
        for (NSInteger index = 0; index < self.cellIdentifiers.count; index++) {
            
            [_tailView registerClass:self.cellClasses[index] forCellReuseIdentifier:self.cellIdentifiers[index]];
        }
        [_tailView setSeparatorColor:[UIColor colorWithWhite:1 alpha:0.06]];
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
    
    if ([_cellAry[indexPath.row] isEqualToString:@"TirePressureMonitoringTableViewCell"]) {
        
        TirePressureMonitoringTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TirePressureMonitoringTableViewCell"];
        cell.Icon.image = [UIImage imageNamed:@"Tire_pressure_alarm"];
        cell.nameLab.text = NSLocalizedString(@"pressure_wain", nil);
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UISwitch *swi1 = cell.swit;
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
        cell.nameLab.text = NSLocalizedString(@"tirt_wain", nil);
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UISwitch *swi1 = cell.swit;
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
        cell.nameLab.text = NSLocalizedString(@"vibration_sensor_sensitivity", nil);
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (self.shockState != nil) {
            cell.detailLab.text = self.shockState;
        }else{
            cell.detailLab.text = NSLocalizedString(@"low", nil);
        }
        return cell;
        
    }else if ([_cellAry[indexPath.row] isEqualToString:@"AutomaticLockTableViewCell"]){
        
        AutomaticLockTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AutomaticLockTableViewCell"];
        cell.Icon.image = [UIImage imageNamed:@"icon_p7"];
        cell.nameLab.text = NSLocalizedString(@"automatic_lock", nil);
        cell.detailLab.text =  NSLocalizedString(@"automatic_lock_show", nil);
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UISwitch *swi1 = cell.swit;
        swi1.tag = 8000;
        NSString *queraAutomaticLockSql = [NSString stringWithFormat:@"SELECT * FROM automaticlock_models WHERE bikeid LIKE '%zd'", self.deviceNum];
        NSMutableArray *AutomaticLockmodels = [LVFmdbTool queryAutomaticLockData:queraAutomaticLockSql];
        AutomaticLockModel *AutomaticLockmodel = AutomaticLockmodels.firstObject;
        
        if (AutomaticLockmodels.count == 0) {
            
            if ([[AppDelegate currentAppDelegate].device isConnected]) {
                [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:@"A5000007300302"]];
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
        cell.nameLab.text = NSLocalizedString(@"firmware_version", nil);
        cell.detailLab.text = bikemodel.firmversion;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.arrow.hidden = YES;
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
            picker.selectStr = NSLocalizedString(@"low", nil);
        }
        [[UIApplication sharedApplication].keyWindow addSubview:picker];
        
    }
}

- (UIViewController *)viewController {
    for (UIView *view = self; view; view = view.superview) {
        UIResponder *nextResponder = [view nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}


- (void)getValue1:(id)sender{
    
    UISwitch *swi=(UISwitch *)sender;
    if (swi.tag == 8000){
        
        if (![[AppDelegate currentAppDelegate].device isConnected]) {
            
            [SVProgressHUD showSimpleText:NSLocalizedString(@"device_disconnect", nil)];
            return;
        }
        
        NSString *queraAutomaticLockSql = [NSString stringWithFormat:@"SELECT * FROM automaticlock_models WHERE bikeid LIKE '%zd'", self.deviceNum];
        NSMutableArray *AutomaticLockmodels = [LVFmdbTool queryAutomaticLockData:queraAutomaticLockSql];
        
        if (AutomaticLockmodels.count == 0) {
            
            if (swi.isOn) {
                UIAlertController * alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"reminders", nil) message:NSLocalizedString(@"auto_content", nil) preferredStyle:UIAlertControllerStyleAlert];//UIAlertControllerStyleAlert视图在中央
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"sure", nil) style:UIAlertActionStyleDefault handler:nil];//https在iTunes中找，这里的事件是前往手机端App store下载微信
                [alertController addAction:okAction];
                [[QFTools currentViewController] presentViewController:alertController animated:YES completion:nil];
                if ([[AppDelegate currentAppDelegate].device isConnected]) {
                    [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:@"A5000007300301"]];
                }
                
            }else{
                if ([[AppDelegate currentAppDelegate].device isConnected]) {
                    [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:@"A5000007300300"]];
                }
            }
            
        }else{
            
            if (swi.isOn) {
                UIAlertController * alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"reminders", nil) message:NSLocalizedString(@"auto_content", nil) preferredStyle:UIAlertControllerStyleAlert];//UIAlertControllerStyleAlert视图在中央
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"sure", nil) style:UIAlertActionStyleDefault handler:nil];//https在iTunes中找，这里的事件是前往手机端App store下载微信
                [alertController addAction:okAction];
                [[QFTools currentViewController] presentViewController:alertController animated:YES completion:nil];
                [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:@"A5000007300301"]];
            }else{
                [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:@"A5000007300300"]];
            }
        }
    }else if (swi.tag == 9000){
        
        if (![[AppDelegate currentAppDelegate].device isConnected]) {
            
            [SVProgressHUD showSimpleText:NSLocalizedString(@"device_disconnect", nil)];
            return;
        }
        if (swi.isOn) {
            [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:@"A5000007200401"]];
        }else{
            
            [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:@"A5000007200400"]];
        }
    }else if (swi.tag == 10000){
        
        if (![[AppDelegate currentAppDelegate].device isConnected]) {
            
            [SVProgressHUD showSimpleText:NSLocalizedString(@"device_disconnect", nil)];
            return;
        }
        if (swi.isOn) {
            [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:@"A500000720010B"]];
        }else{
            [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:@"A500000720010C"]];
        }
        
    }
}

-(void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeObserver:self forKeyPath:@"speeding_alarm"];
    [self removeObserver:self forKeyPath:@"pressureLock"];
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
    }
}



#pragma mark -------- TFPickerDelegate

- (void)PickerSelectorIndixString:(NSString *)str{
    
    if (![[AppDelegate currentAppDelegate].device isConnected]) {
        
        [SVProgressHUD showSimpleText:NSLocalizedString(@"device_disconnect", nil)];
        return;
    }
    
    if ([str isEqualToString:NSLocalizedString(@"low", nil)]) {
        
        [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:@"A5000007200200"]];
        
    }else if ([str isEqualToString:NSLocalizedString(@"middle", nil)]){
        
        [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:@"A5000007200201"]];
    }else if ([str isEqualToString:NSLocalizedString(@"high", nil)]){
        
        [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:@"A5000007200202"]];
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
    NSLog(@"p----%@",str);
}

- (void)PickerSelectorIndixColour:(UIColor *)color{
    
    NSLog(@"p----%@",color);
}

@end
