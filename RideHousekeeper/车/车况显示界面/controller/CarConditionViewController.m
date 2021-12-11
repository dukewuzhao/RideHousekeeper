//
//  CarConditionViewController.m
//  RideHousekeeper
//
//  Created by Apple on 2019/7/11.
//  Copyright © 2019 Duke Wu. All rights reserved.
//

#import "CarConditionViewController.h"
#import "VehicleDataView.h"
#import "TirePressureDisplay.h"
#import "TireStatusDisplayView.h"
#import "BikeStatusModel.h"

@interface CarConditionViewController ()
@property(nonatomic,strong)TirePressureDisplay *tirePressureDisplayView;
@end

@implementation CarConditionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupNavView];
    
    [self setupView];
}

- (void)setupNavView{
    [super setupNavView];
    self.navView.showBottomLabel = NO;
    [self.navView.centerButton setTitle:@"车况" forState:UIControlStateNormal];
    @weakify(self);
    [self.navView.leftButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    self.navView.leftButtonBlock = ^{
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    };
    
}


-(void)setupView{
    
    UIView *linView = [[UIView alloc] initWithFrame:CGRectMake(25, navHeight, ScreenWidth - 50, 0.2)];
    linView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:linView];
    
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, navHeight, ScreenWidth, ScreenHeight * .35)];
    headView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:headView];
    
    VehicleDataView *voltageView = [[VehicleDataView alloc] init];
    voltageView.titlelab.text = @"车辆电压";
    voltageView.titlelab.font = FONT_PINGFAN(14);
    voltageView.displayLab.text =  @"48V";
    voltageView.displayImg.image =  [UIImage imageNamed:@"bike_voltage"];
    [self.view addSubview:voltageView];
    [voltageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(20);
        make.size.mas_equalTo(CGSizeMake((ScreenWidth - 80)/3, ScreenWidth/2 - 10));
        make.top.equalTo(linView.mas_bottom).offset(30);
    }];
    
    VehicleDataView *temperatureView = [[VehicleDataView alloc] init];
    temperatureView.titlelab.text = @"车辆温度";
    temperatureView.titlelab.font = FONT_PINGFAN(14);
    temperatureView.displayLab.text =  @"30℃";
    temperatureView.displayImg.image =  [UIImage imageNamed:@"bike_temperature"];
    [self.view addSubview:temperatureView];
    [temperatureView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake((ScreenWidth - 80)/3, ScreenWidth/2 - 10));
        make.top.equalTo(linView.mas_bottom).offset(30);
    }];
    
    VehicleDataView *keyElectricity = [[VehicleDataView alloc] init];
    keyElectricity.titlelab.text = @"钥匙电量";
    keyElectricity.titlelab.font = FONT_PINGFAN(14);
    keyElectricity.displayLab.text =  @"(*%)";
    keyElectricity.displayImg.image =  [UIImage imageNamed:@"icon_key_bat"];
    [self.view addSubview:keyElectricity];
    [keyElectricity mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view).offset(-20);
        make.size.mas_equalTo(CGSizeMake((ScreenWidth - 80)/3, ScreenWidth/2 - 10));
        make.top.equalTo(linView.mas_bottom).offset(30);
    }];
    
    
    NSMutableArray *bikemodels = [LVFmdbTool queryBikeData:[NSString stringWithFormat:@"SELECT * FROM bike_modals WHERE bikeid LIKE '%zd'", _deviceNum]];
    BikeModel *bikeModel = bikemodels.firstObject;
    
    NSMutableArray *peripheraModals = [LVFmdbTool queryPeripheraData:[NSString stringWithFormat:@"SELECT * FROM periphera_modals WHERE type LIKE '%zd' AND bikeid LIKE '%zd'", 6,_deviceNum]];
    
    if (bikeModel.tpm_func == 1 && peripheraModals.count >0) {
        _tirePressureDisplayView = [[TirePressureDisplay alloc] init];
        _tirePressureDisplayView.backgroundColor = [UIColor whiteColor];
        _tirePressureDisplayView.titlelab.text = @"胎压状态";
        _tirePressureDisplayView.titlelab.textColor = [UIColor blackColor];
        _tirePressureDisplayView.numberWheels = bikeModel.wheels;
        [self.view addSubview:_tirePressureDisplayView];
        [_tirePressureDisplayView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view);
            make.width.mas_equalTo(ScreenWidth);
            make.top.equalTo(temperatureView.mas_bottom).offset(30);
            make.bottom.equalTo(self.view.mas_bottom);
        }];
    }
    
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
    
    [voltageView lm_addCorner:(ScreenWidth - 80)/6 borderWidth:1 borderColor:[UIColor clearColor] backGroundColor:[QFTools colorWithHexString:@"#F5F5F5"]];
    [temperatureView lm_addCorner:(ScreenWidth - 80)/6 borderWidth:1 borderColor:[UIColor clearColor] backGroundColor:[QFTools colorWithHexString:@"#F5F5F5"]];
    [keyElectricity lm_addCorner:(ScreenWidth - 80)/6 borderWidth:1 borderColor:[UIColor clearColor] backGroundColor:[QFTools colorWithHexString:@"#F5F5F5"]];
    
    @weakify(self);
    [[[NSNOTIC_CENTER rac_addObserverForName:KNotification_QueryData object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id x) {
        @strongify(self);
        NSNotification *userInfo = x;
        BikeStatusModel *model = userInfo.object;
        voltageView.displayLab.text = [NSString stringWithFormat:@"%dV",model.voltageValue];
        temperatureView.displayLab.text = [NSString stringWithFormat:@"%d℃",model.temperatureValue];
        
        if (model.keyInduction) {
            keyElectricity.displayLab.text = [NSString stringWithFormat:@"%d%%",model.inductionElectricity];
        }else{
            keyElectricity.displayLab.text = @"(*%)";
        }
        
        if (bikeModel.tpm_func == 1) {
         
            if (model.firstTireValue < 0) {
                if (model.firstTireValue == -3) {
                    self.tirePressureDisplayView.firstWheelView.tirePressureLab.text = @"未配置";
                    self.tirePressureDisplayView.firstWheelView.tirePressureLab.textColor = [QFTools colorWithHexString:MainColor];
                }else if (model.firstTireValue == -6){
                    self.tirePressureDisplayView.firstWheelView.tirePressureLab.text = @"数据异常";
                    self.tirePressureDisplayView.firstWheelView.tirePressureLab.textColor = [UIColor yellowColor];
                }
            }else if (model.firstTireValue == 0){
                self.tirePressureDisplayView.firstWheelView.tirePressureLab.text = @"读取中";
                self.tirePressureDisplayView.firstWheelView.tirePressureLab.textColor = [QFTools colorWithHexString:MainColor];
            }else if(model.firstTireValue > 0){
                
                if (model.firstTireValue >= 200 && model.firstTireValue <= 300) {
                    self.tirePressureDisplayView.firstWheelView.tirePressureLab.text = [NSString stringWithFormat:@"%d",model.firstTireValue];
                    self.tirePressureDisplayView.firstWheelView.tirePressureLab.textColor = [QFTools colorWithHexString:MainColor];
                }else if (model.firstTireValue > 0 && model.firstTireValue < 6){
                    self.tirePressureDisplayView.firstWheelView.tirePressureLab.text = @"读取中";
                    self.tirePressureDisplayView.firstWheelView.tirePressureLab.textColor = [QFTools colorWithHexString:MainColor];
                }else{
                    self.tirePressureDisplayView.firstWheelView.tirePressureLab.text = [NSString stringWithFormat:@"%d",model.firstTireValue];
                    self.tirePressureDisplayView.firstWheelView.tirePressureLab.textColor = [UIColor redColor];
                }
            }
            
            if (model.secondTireValue < 0) {
                if (model.secondTireValue == -3) {
                    self.tirePressureDisplayView.secondWheelView.tirePressureLab.text = @"未配置";
                    self.tirePressureDisplayView.secondWheelView.tirePressureLab.textColor = [QFTools colorWithHexString:MainColor];
                }else if (model.secondTireValue == -6){
                    self.tirePressureDisplayView.secondWheelView.tirePressureLab.text = @"数据异常";
                    self.tirePressureDisplayView.secondWheelView.tirePressureLab.textColor = [UIColor yellowColor];
                }
            }else if (model.secondTireValue == 0){
                self.tirePressureDisplayView.secondWheelView.tirePressureLab.text = @"读取中";
                self.tirePressureDisplayView.secondWheelView.tirePressureLab.textColor = [QFTools colorWithHexString:MainColor];
            }else if(model.secondTireValue > 0){
                
                if (model.secondTireValue >= 200 && model.secondTireValue <= 300) {
                    self.tirePressureDisplayView.secondWheelView.tirePressureLab.text = [NSString stringWithFormat:@"%d",model.secondTireValue];
                    self.tirePressureDisplayView.secondWheelView.tirePressureLab.textColor = [QFTools colorWithHexString:MainColor];
                }else if (model.secondTireValue > 0 && model.secondTireValue < 6){
                    self.tirePressureDisplayView.secondWheelView.tirePressureLab.text = @"读取中";
                    self.tirePressureDisplayView.secondWheelView.tirePressureLab.textColor = [QFTools colorWithHexString:MainColor];
                }else{
                    self.tirePressureDisplayView.secondWheelView.tirePressureLab.text = [NSString stringWithFormat:@"%d",model.secondTireValue];
                    self.tirePressureDisplayView.secondWheelView.tirePressureLab.textColor = [UIColor redColor];
                }
            }
            
            if (model.thirdTireValue < 0) {
                if (model.thirdTireValue == -3) {
                    self.tirePressureDisplayView.thirdWheelView.tirePressureLab.text = @"未配置";
                    self.tirePressureDisplayView.thirdWheelView.tirePressureLab.textColor = [QFTools colorWithHexString:MainColor];
                }else if (model.thirdTireValue == -6){
                    self.tirePressureDisplayView.thirdWheelView.tirePressureLab.text = @"数据异常";
                    self.tirePressureDisplayView.thirdWheelView.tirePressureLab.textColor = [UIColor yellowColor];
                }
            }else if (model.thirdTireValue == 0){
                self.tirePressureDisplayView.thirdWheelView.tirePressureLab.text = @"读取中";
                self.tirePressureDisplayView.thirdWheelView.tirePressureLab.textColor = [QFTools colorWithHexString:MainColor];
            }else if(model.thirdTireValue > 0){
                
                if (model.thirdTireValue >= 200 && model.thirdTireValue <= 300) {
                    self.tirePressureDisplayView.thirdWheelView.tirePressureLab.text = [NSString stringWithFormat:@"%d",model.thirdTireValue];
                    self.tirePressureDisplayView.thirdWheelView.tirePressureLab.textColor = [QFTools colorWithHexString:MainColor];
                }else if (model.thirdTireValue > 0 && model.thirdTireValue < 6){
                    self.tirePressureDisplayView.thirdWheelView.tirePressureLab.text = @"读取中";
                    self.tirePressureDisplayView.thirdWheelView.tirePressureLab.textColor = [QFTools colorWithHexString:MainColor];
                }else{
                    self.tirePressureDisplayView.thirdWheelView.tirePressureLab.text = [NSString stringWithFormat:@"%d",model.thirdTireValue];
                    self.tirePressureDisplayView.thirdWheelView.tirePressureLab.textColor = [UIColor redColor];
                }
            }
            
            
            if (model.fourthTireValue < 0) {
                if (model.fourthTireValue == -3) {
                    self.tirePressureDisplayView.fourthWheelView.tirePressureLab.text = @"未配置";
                    self.tirePressureDisplayView.fourthWheelView.tirePressureLab.textColor = [QFTools colorWithHexString:MainColor];
                }else if (model.fourthTireValue == -6){
                    self.tirePressureDisplayView.fourthWheelView.tirePressureLab.text = @"数据异常";
                    self.tirePressureDisplayView.fourthWheelView.tirePressureLab.textColor = [UIColor yellowColor];
                }
            }else if (model.fourthTireValue == 0){
                self.tirePressureDisplayView.fourthWheelView.tirePressureLab.text = @"读取中";
                self.tirePressureDisplayView.fourthWheelView.tirePressureLab.textColor = [QFTools colorWithHexString:MainColor];
            }else if(model.fourthTireValue > 0){
                
                if (model.fourthTireValue >= 200 && model.fourthTireValue <= 300) {
                    self.tirePressureDisplayView.fourthWheelView.tirePressureLab.text = [NSString stringWithFormat:@"%d",model.fourthTireValue];
                    self.tirePressureDisplayView.fourthWheelView.tirePressureLab.textColor = [QFTools colorWithHexString:MainColor];
                }else if (model.fourthTireValue > 0 && model.fourthTireValue < 6){
                    self.tirePressureDisplayView.fourthWheelView.tirePressureLab.text = @"读取中";
                    self.tirePressureDisplayView.fourthWheelView.tirePressureLab.textColor = [QFTools colorWithHexString:MainColor];
                }else{
                    self.tirePressureDisplayView.fourthWheelView.tirePressureLab.text = [NSString stringWithFormat:@"%d",model.fourthTireValue];
                    self.tirePressureDisplayView.fourthWheelView.tirePressureLab.textColor = [UIColor redColor];
                }
            }
            
            if ((model.firstTireValue >= 200 && model.firstTireValue <= 300) || model.firstTireValue<=0) {
                self.tirePressureDisplayView.firstWheelImg.image = [UIImage imageNamed:@"normal_tire_pressure"];
            }else {
                self.tirePressureDisplayView.firstWheelImg.image = [UIImage imageNamed:@"malfunction_tire_pressure"];
            }
            
            if ((model.secondTireValue >= 200 && model.secondTireValue <= 300) || model.secondTireValue<=0) {
                self.tirePressureDisplayView.secondWheelImg.image = [UIImage imageNamed:@"normal_tire_pressure"];
            }else {
                self.tirePressureDisplayView.secondWheelImg.image = [UIImage imageNamed:@"malfunction_tire_pressure"];
            }
            
            if ((model.thirdTireValue >= 200 && model.thirdTireValue <= 300) || model.thirdTireValue<=0) {
                self.tirePressureDisplayView.thirdWheelImg.image = [UIImage imageNamed:@"normal_tire_pressure"];
            }else {
                self.tirePressureDisplayView.thirdWheelImg.image = [UIImage imageNamed:@"malfunction_tire_pressure"];
            }
            
            if ((model.fourthTireValue >= 200 && model.fourthTireValue <= 300) || model.fourthTireValue<=0) {
                self.tirePressureDisplayView.fourthWheelImg.image = [UIImage imageNamed:@"normal_tire_pressure"];
            }else {
                self.tirePressureDisplayView.fourthWheelImg.image = [UIImage imageNamed:@"malfunction_tire_pressure"];
            }
            
        }
    }];
    
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
