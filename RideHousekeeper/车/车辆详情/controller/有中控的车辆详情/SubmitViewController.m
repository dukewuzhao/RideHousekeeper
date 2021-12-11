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
#import "BindingUserViewController.h"
#import "VehicleFingerprintViewController.h"
#import "MultipleBindingLogicProcessingViewController.h"
#import "FaultViewController.h"
#import "BikeNameTableViewCell.h"
#import "bikeFunctionTableViewCell.h"
#import "BikeInductionDistanceTableViewCell.h"
#import "TailTableViewCell.h"
#import "LianUISlider.h"
#import "PickerChoiceView.h"
#import "Manager.h"
#import "FaultModel.h"

@interface SubmitViewController ()<UITableViewDelegate,UITableViewDataSource,BindingUserViewControllerDelegate,ManagerDelegate>
@property (nonatomic, strong)BikeModel *bikemodel;
@property (nonatomic, weak) UITableView *bikeSubmitView;
@property (nonatomic, copy)NSArray *cellIdentifiers;
@property (nonatomic, copy)NSArray *cellClasses;
@property (nonatomic, strong)NSMutableArray *cellAry;
@end

@implementation SubmitViewController

- (FaultModel *)faultmodel {
    if (!_faultmodel) {
        _faultmodel = [[FaultModel alloc] init];
    }
    return _faultmodel;
}

- (NSMutableArray *)cellAry {
    if (!_cellAry) {
        _cellAry = [NSMutableArray array] ;
    }
    return _cellAry;
}

-(void)getDeviceSensingDistanceValue{
    @weakify(self);
    [CommandDistributionServices getDeviceSensingDistanceValue:^(NSInteger value) {
        @strongify(self);
        [self updateDeviceSensingDistanceValue:value];
        
    } error:^(CommandStatus status) {
        switch (status) {
            case SendSuccess:
                NSLog(@"获取感应数据发送成功");
                break;
                
            default:
                NSLog(@"获取感应数据发送失败");
                break;
        }
    }];
}

-(void)setDeviceSensingDistanceValue:(NSInteger)value{
    @weakify(self);
    [CommandDistributionServices setDeviceSensingDistanceValue:value data:^(NSInteger value) {
        @strongify(self);
        [self updateDeviceSensingDistanceValue:value];
        
    } error:^(CommandStatus status) {
        
        switch (status) {
            case SendSuccess:
                NSLog(@"设置感应数据发送成功");
                break;
                
            default:
                NSLog(@"设置感应数据发送失败");
                break;
        }
     }];
}

-(void)updateDeviceSensingDistanceValue:(NSInteger)value{
    
    if (value > 92) return;
    
    NSMutableArray *indukeymodals = [LVFmdbTool queryInduckeyData:[NSString stringWithFormat:@"SELECT * FROM induckey_modals WHERE bikeid LIKE '%zd'", self.deviceNum]];
    
    if (indukeymodals.count == 0) {
        InduckeyModel *inducmodel = [InduckeyModel modalWith:self.deviceNum induckeyValue:value];
        [LVFmdbTool insertInduckeyModel:inducmodel];
    }else{
        [LVFmdbTool modifyData:[NSString stringWithFormat:@"UPDATE induckey_modals SET induckeyValue = '%zd' WHERE bikeid = '%zd'", value,self.deviceNum]];
    }
    
    InduckeyModel *inducmodel = [InduckeyModel modalWith:self.deviceNum induckeyValue:value];
    [LVFmdbTool insertInduckeyModel:inducmodel];
    
    [self.bikeSubmitView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:0 inSection:3],nil] withRowAnimation:UITableViewRowAnimationNone];
    
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
    [self setupNavView];
    [self setupMainView];
    @weakify(self);
    [[[NSNOTIC_CENTER rac_addObserverForName:KNotification_ConnectStatus object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id x) {
        @strongify(self);
        NSNotification *userInfo = x;
        [self.bikeSubmitView reloadSections:[[NSIndexSet alloc]initWithIndex:2] withRowAnimation:UITableViewRowAnimationNone];
        if (![userInfo.object boolValue]) {
            
            [self getDeviceSensingDistanceValue];
        }
    }];
}

- (void)setupNavView{
    [super setupNavView];
    self.navView.showBottomLabel = NO;
    [self.navView.centerButton setTitle:_bikemodel.bikename forState:UIControlStateNormal];
    @weakify(self);
    [self.navView.leftButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    self.navView.leftButtonBlock = ^{
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    };
}

-(void)setDeviceNum:(NSInteger) deviceNum{
    
    _deviceNum = deviceNum;
    NSMutableArray *bikemodals = [LVFmdbTool queryBikeData:[NSString stringWithFormat:@"SELECT * FROM bike_modals WHERE bikeid LIKE '%zd'", _deviceNum]];
    _bikemodel = bikemodals.firstObject;
    [self.cellAry addObject:@"BikeMuteTableViewCell"];
    if (_bikemodel.tpm_func == 1) {
        [self.cellAry addObject:@"TirePressureMonitoringTableViewCell"];
//        if (_bikemodel.wheels == 0) {
//            [self.cellAry addObject:@"SpeedingAlarmTableViewCell"];
//        }
    }
    
    if (_bikemodel.vibr_sens_func == 1) {
        [self.cellAry addObject:@"bikeFunctionTableViewCell"];
    }
    
    [self.cellAry addObject:@"AutomaticLockTableViewCell"];
    //[self.cellAry addObject:@"FirmwareUpgradeTableViewCell"];
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
    [bikeSubmitView setSeparatorColor:[QFTools colorWithHexString:SeparatorColor]];
    //bikeSubmitView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [bikeSubmitView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    [self.view addSubview:bikeSubmitView];
    self.bikeSubmitView = bikeSubmitView;
    [self.view sendSubviewToBack:bikeSubmitView];
    
    UIView *footview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 75)];
    footview.backgroundColor = [QFTools colorWithHexString:@"#f5f5f5"];
    [self.view addSubview:footview];
    
    UIButton *UnbundBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 15, ScreenWidth, 45)];
    UnbundBtn.backgroundColor = [UIColor whiteColor];
    [UnbundBtn addTarget:self action:@selector(UnbundDevice:) forControlEvents:UIControlEventTouchUpInside];
    [UnbundBtn setTitle:@"解绑车辆" forState:UIControlStateNormal];
    //UnbundBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [UnbundBtn setTitleColor:[QFTools colorWithHexString:MainColor] forState:UIControlStateNormal];
    [footview addSubview:UnbundBtn];
    bikeSubmitView.tableFooterView = footview;
}

#pragma mark -- TableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        return 1;
    }else if (section == 1){
        return 5;
    }else if (section == 2 || section == 3){
        return 1;
    }else {
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        
        return ScreenHeight *.13 + 5;
    }else if (indexPath.section == 1){
        
        return 50.0f;
    }else if (indexPath.section == 2 || indexPath.section == 3){
        
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
- (void)tableView:( UITableView  *)tableView  willDisplayCell :( UITableViewCell  *)cell  forRowAtIndexPath :( NSIndexPath  *)indexPath{
    
    cell.backgroundColor = CellColor;
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section{
    
    view.tintColor = [QFTools colorWithHexString:@"#cccccc"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *brandQuerySql = [NSString stringWithFormat:@"SELECT * FROM brand_modals WHERE bikeid LIKE '%zd'", self.deviceNum];
    NSMutableArray *brandmodals = [LVFmdbTool queryBrandData:brandQuerySql];
    BrandModel *brandmodel = brandmodals.firstObject;
    
    if (indexPath.section == 0) {
        
        BikeNameTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BikeNameTableViewCell"];
        cell.bikeimage.image = [UIImage imageNamed:@"default_logo"];
        cell.nameLab.text = _bikemodel.bikename;
        cell.usericon.image = [UIImage imageNamed:@"smalluserIcon"];
        [cell.modifyBtn setImage:[UIImage imageNamed:@"pen"] forState:UIControlStateNormal];
        NSString* text = _bikemodel.ownerphone;
        cell.phone.text = [QFTools replaceStringWithAsterisk:text startLocation:3 lenght:text.length -7];
        
        UIButton * modifyBtn = cell.modifyBtn;
        [modifyBtn addTarget:self action:@selector(modifyBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }else if (indexPath.section == 1) {
        
        bikeFunctionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"bikeFunctionTableViewCell"];
        cell.upgrade_red_dot.hidden = YES;
        UIImageView *icon = cell.Icon;
        UILabel *name = cell.nameLab;
        UILabel *detailLab = cell.detailLab;
        
        if (indexPath.row == 0) {
            icon.image = [UIImage imageNamed:@"icon_p1"];
            name.text = @"车辆品牌";
            detailLab.text = [NSString stringWithFormat:@"%@",brandmodel.brandname];
            [cell.arrow removeFromSuperview];
        }else if (indexPath.row == 1){
            
            icon.image = [UIImage imageNamed:@"icon_bike_examination"];
            name.text = @"故障检测";
            [detailLab removeFromSuperview];
        }else if (indexPath.row == 2){
            
            icon.image = [UIImage imageNamed:@"icon_p2"];
            name.text = @"分享车辆";
            detailLab.text = [NSString stringWithFormat:@"%ld",(long)_bikemodel.bindedcount];
        }else if (indexPath.row == 3){
            
            icon.image = [UIImage imageNamed:@"icon_p3"];
            name.text = @"配件管理";
            [detailLab removeFromSuperview];
        }else if (indexPath.row == 4){
            
            icon.image = [UIImage imageNamed:@"fingerprint_icon"];
            name.text = @"车辆指纹";
            [detailLab removeFromSuperview];
        }
        
        return cell;
    }else if (indexPath.section == 2){
        
        BikeInductionDistanceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BikeInductionDistanceTableViewCell"];
        UISwitch *swi1 = cell.swit;
        LianUISlider *slider = cell.slider;
        
        swi1.hidden = NO;
        cell.Icon.image = [UIImage imageNamed:@"icon_p4"];
        cell.nameLab.text = @"手机感应";
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
    }else if (indexPath.section == 3){
        
        BikeInductionDistanceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BikeDeviceInductionDistanceTableViewCell"];
        UISwitch *swi1 = cell.swit;
        LianUISlider *slider = cell.slider;
        
        swi1.hidden = YES;
        cell.Icon.image = [UIImage imageNamed:@"icon_p5"];
        cell.nameLab.text = @"配件感应";
        
        slider.tag = 201;
        slider.minimumValue = 72;
        slider.maximumValue = 92;
        
        if (![CommandDistributionServices isConnect]) {
            
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
            
            if([CommandDistributionServices isConnect]){
                
                [self getDeviceSensingDistanceValue];
            }else{
                slider.value = 78;
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
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.section == 1) {
        
        if (indexPath.row == 1) {
            
            if (![CommandDistributionServices isConnect]) {
                [SVProgressHUD showSimpleText:@"车辆未连接"];
                return;
            }
            FaultViewController *faultVc = [FaultViewController new];
            faultVc.faultmodel = self.faultmodel;
            [self.navigationController pushViewController:faultVc animated:YES];
            
        }else if (indexPath.row == 2) {
            BindingUserViewController *bindingVc = [BindingUserViewController new];
            bindingVc.bikeid = self.deviceNum;
            bindingVc.delegate = self;
            [self.navigationController pushViewController:bindingVc animated:YES];
        }else if (indexPath.row == 3){
            
            AccessoriesViewController *accessVc = [AccessoriesViewController new];
            accessVc.deviceNum = self.deviceNum;
            [self.navigationController pushViewController:accessVc animated:YES];

        }else if (indexPath.row == 4){
            
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
        
        _cellIdentifiers = @[@"BikeNameTableViewCell",@"bikeFunctionTableViewCell",@"BikeInductionDistanceTableViewCell",@"BikeDeviceInductionDistanceTableViewCell",@"TailTableViewCell"];
    }
    return _cellIdentifiers;
}

- (NSArray *)cellClasses {
    
    if (!_cellClasses) {
        
        _cellClasses = @[[BikeNameTableViewCell class],
                         [bikeFunctionTableViewCell class],
                         [BikeInductionDistanceTableViewCell class],[BikeInductionDistanceTableViewCell class],[TailTableViewCell class]];
    }
    return _cellClasses;
}



-(void)UnbundDevice:(UIButton *)btn{
    
    MultipleBindingLogicProcessingViewController* MultipleUnBindVC = [[MultipleBindingLogicProcessingViewController alloc] init];
    [MultipleUnBindVC showView:UnbindingBike :nil :_deviceNum];
    [self.navigationController pushViewController:MultipleUnBindVC animated:YES];
}


- (void)modifyBtnClick:(UIButton *)btn{

    NSString *bikeQuerySql = [NSString stringWithFormat:@"SELECT * FROM bike_modals WHERE bikeid LIKE '%zd'", self.deviceNum];
    NSMutableArray *bikemodals = [LVFmdbTool queryBikeData:bikeQuerySql];
    BikeModel *bikemodel = bikemodals.firstObject;
    if (bikemodel.ownerflag == 0) {
        
        [SVProgressHUD showSimpleText:@"子用户无此权限"];
        return;
    }
    
    nameTextFiledController * nameText = [nameTextFiledController new];
    nameText.deviceNum = self.deviceNum;
    [self.navigationController pushViewController:nameText animated:NO];
}


- (void)updateValue:(UISlider *)sender{
    
    if (sender.tag == 180) {
        
        NSInteger phInductionValue = sender.value;
        if (phInductionValue <= 65) {
            UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"蓝牙信号易受环境影响，感应距离过低可能体验不佳" preferredStyle:UIAlertControllerStyleAlert];//UIAlertControllerStyleAlert视图在中央
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];//https在iTunes中找，这里的事件是前往手机端App store下载微信
            [alertController addAction:okAction];
            [self presentViewController:alertController animated:YES completion:nil];
        }
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
        
        if (![CommandDistributionServices isConnect]) {
            
            [SVProgressHUD showSimpleText:@"车辆未连接"];
            return;
        }
            
        int f = sender.value;
        if (f <= 81) {
            UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"蓝牙信号易受环境影响，感应距离过低可能体验不佳" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:okAction];
            [self presentViewController:alertController animated:YES completion:nil];
        }
        [self setDeviceSensingDistanceValue:f];
    }
}


- (void)getValue1:(id)sender{
    
    UISwitch *swi=(UISwitch *)sender;
    
    if (swi.tag == 7000) {
        NSString *phInductionQuerySql = [NSString stringWithFormat:@"SELECT * FROM induction_modals WHERE bikeid LIKE '%zd'", self.deviceNum];
        NSMutableArray *inducmodals = [LVFmdbTool queryInductionData:phInductionQuerySql];
        if (swi.isOn) {
            
            UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"为保证您流畅的使用感应，请保持APP在后台运行" preferredStyle:UIAlertControllerStyleAlert];//UIAlertControllerStyleAlert视图在中央
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:okAction];
            [self presentViewController:alertController animated:YES completion:nil];
            
            if (inducmodals.count == 0) {
                
                InductionModel *inducmodel = [InductionModel modalWith:self.deviceNum inductionValue:70 induction:1];
                [LVFmdbTool insertInductionModel:inducmodel];
                
            }else{
                
                NSString *updateSql = [NSString stringWithFormat:@"UPDATE induction_modals SET induction = '%zd' WHERE bikeid = '%zd'",1,self.deviceNum];
                [LVFmdbTool modifyData:updateSql];
            }
            
        }else{
            
            if (inducmodals.count == 0) {
                
                InductionModel *inducmodel = [InductionModel modalWith:self.deviceNum inductionValue:70 induction:0];
                [LVFmdbTool insertInductionModel:inducmodel];
                
            }else{
                
                NSString *updateSql = [NSString stringWithFormat:@"UPDATE induction_modals SET induction = '%zd' WHERE bikeid = '%zd'",0,self.deviceNum];
                [LVFmdbTool modifyData:updateSql];
            }
        }
        
        if([self.delegate respondsToSelector:@selector(regulatePhoneInduction:)])
        {
            [self.delegate regulatePhoneInduction:swi.isOn];
        }
        
        NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:2];
        [self.bikeSubmitView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

-(void)showPickerSelectorView:(float)value :(NSIndexPath *)indexPath{
    
    //self.bikeSubmitView.contentInset = UIEdgeInsetsMake(self.bikeSubmitView.contentInset.top, 0, value, 0);
//    UITableViewCell *cell = [_bikeSubmitView cellForRowAtIndexPath:indexPath];
//    CGRect cellIFrame = [_bikeSubmitView convertRect:cell.frame toView:[self.view superview]];
//    [self.bikeSubmitView scrollRectToVisible:CGRectMake(cellIFrame.origin.x, cellIFrame.origin.y, cellIFrame.size.width, cellIFrame.size.height+20) animated:YES];
}

-(void)hidePickerSelectorView:(float)value{
    
    //self.bikeSubmitView.contentInset = UIEdgeInsetsMake(_bikeSubmitView.contentInset.top, 0, 0, 0);
    //[self.bikeSubmitView setContentOffset:CGPointMake(0, 0) animated:YES];
}


#pragma mark - ManagerDelegate
-(void)manager:(Manager *)manager updatebikeName:(NSString *)name :(NSInteger)bikeId{
    
    [self.navView.centerButton setTitle:name forState:UIControlStateNormal];
    
    _bikemodel = [LVFmdbTool queryBikeData:[NSString stringWithFormat:@"SELECT * FROM bike_modals WHERE bikeid LIKE '%zd'", _deviceNum]].firstObject;
    
    NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:0];
    [self.bikeSubmitView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
}

-(void)dealloc{
    
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
