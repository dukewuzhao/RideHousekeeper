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
@interface CarConditionViewController ()
@property(nonatomic,strong)TirePressureDisplay *tirePressureDisplayView;
@end

@implementation CarConditionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [QFTools colorWithHexString:@"#ebecf2"];
    [self setupNavView];
    
    [self setupView];
}

- (void)setupNavView{
    [super setupNavView];
    self.navView.backgroundColor = [QFTools colorWithHexString:MainColor];
    self.navView.showBottomLabel = NO;
    [self.navView.centerButton setTitle:NSLocalizedString(@"Car_condition", nil) forState:UIControlStateNormal];
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
    
    VehicleDataView *temperatureView = [[VehicleDataView alloc] init];
    temperatureView.titlelab.text = NSLocalizedString(@"temp", nil);
    temperatureView.displayLab.text =  @"30℃";
    temperatureView.displayImg.image =  [UIImage imageNamed:@"bike_temperature"];
    [self.view addSubview:temperatureView];
    [temperatureView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(8);
        make.size.mas_equalTo(CGSizeMake(ScreenWidth/3 - 10, ScreenWidth/2 - 10));
        make.top.equalTo(linView.mas_bottom).offset(30);
    }];
    
    VehicleDataView *voltageView = [[VehicleDataView alloc] init];
    voltageView.titlelab.text = NSLocalizedString(@"voltage", nil);
    voltageView.displayLab.text =  @"48V";
    voltageView.displayImg.image =  [UIImage imageNamed:@"bike_voltage"];
    [self.view addSubview:voltageView];
    [voltageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(ScreenWidth/3 - 10, ScreenWidth/2 - 10));
        make.top.equalTo(linView.mas_bottom).offset(30);
    }];
    
    VehicleDataView *keyElectricity = [[VehicleDataView alloc] init];
    keyElectricity.titlelab.text = NSLocalizedString(@"key_charge", nil);
    keyElectricity.displayLab.text =  @"NULL";
    keyElectricity.displayImg.image =  [UIImage imageNamed:@"icon_key_bat"];
    [self.view addSubview:keyElectricity];
    [keyElectricity mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view).offset(-8);
        make.size.mas_equalTo(CGSizeMake(ScreenWidth/3 - 10, ScreenWidth/2 - 10));
        make.top.equalTo(linView.mas_bottom).offset(30);
    }];
    
    
    NSMutableArray *bikemodels = [LVFmdbTool queryBikeData:[NSString stringWithFormat:@"SELECT * FROM bike_modals WHERE bikeid LIKE '%zd'", self.deviceNum]];
    BikeModel *bikeModel = bikemodels.firstObject;
    
    if (bikeModel.tpm_func == 1) {
        _tirePressureDisplayView = [[TirePressureDisplay alloc] init];
        _tirePressureDisplayView.titlelab.text = NSLocalizedString(@"Tire_pressure_status", nil);
        _tirePressureDisplayView.numberWheels = 0;
        
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
    
    [voltageView lm_addCorner:ScreenWidth/6 - 5 borderWidth:1 borderColor:[UIColor clearColor] backGroundColor:[UIColor whiteColor]];
    [temperatureView lm_addCorner:ScreenWidth/6 - 5 borderWidth:1 borderColor:[UIColor clearColor] backGroundColor:[UIColor whiteColor]];
    [keyElectricity lm_addCorner:ScreenWidth/6 - 5 borderWidth:1 borderColor:[UIColor clearColor] backGroundColor:[UIColor whiteColor]];
    
    @weakify(self);
    [[[NSNOTIC_CENTER rac_addObserverForName:KNotification_QueryData object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id x) {
        @strongify(self);
        NSNotification *userInfo = x;
        NSString *date = userInfo.userInfo[@"data"];
        if ([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"1001"]) {
            
            NSData *datevalue = [ConverUtil parseHexStringToByteArray:date];
            Byte *byte=(Byte *)[datevalue bytes];
            
            int wendu = BUILD_UINT16(byte[12],byte[11]) * .1;
            int dianya = BUILD_UINT16(byte[10],byte[9]) * .1;
            voltageView.displayLab.text = [NSString stringWithFormat:@"%dV",dianya];
            temperatureView.displayLab.text = [NSString stringWithFormat:@"%d℃",wendu];
            int value = byte[15];
            keyElectricity.displayLab.text = [NSString stringWithFormat:@"%d%%",value];
            if (bikeModel.tpm_func == 1) {
                
                int frontWheelValue = (byte[16]==255? 0:byte[16])  * 3.1333;
                int rearWheelValue = (byte[17]==255? 0:byte[17])  * 3.1333;
                int leftFrontWheelValue = (byte[18]==255? 0:byte[16])  * 3.1333;
                int rightRearWheelValue = (byte[19]==255? 0:byte[16])  * 3.1333;
                self.tirePressureDisplayView.firstWheelView.tirePressureLab.text = [NSString stringWithFormat:@"%d",frontWheelValue];
                self.tirePressureDisplayView.secondWheelView.tirePressureLab.text = [NSString stringWithFormat:@"%d",rearWheelValue];
                self.tirePressureDisplayView.thirdWheelView.tirePressureLab.text = [NSString stringWithFormat:@"%d",leftFrontWheelValue];
                self.tirePressureDisplayView.fourthWheelView.tirePressureLab.text = [NSString stringWithFormat:@"%d",rightRearWheelValue];
                
                if (frontWheelValue > 200 && frontWheelValue < 260) {
                    self.tirePressureDisplayView.firstWheelImg.image = [UIImage imageNamed:@"normal_tire_pressure"];
                }else {
                    self.tirePressureDisplayView.firstWheelImg.image = [UIImage imageNamed:@"malfunction_tire_pressure"];
                }
                
                if (rearWheelValue > 200 && rearWheelValue < 260) {
                    self.tirePressureDisplayView.secondWheelImg.image = [UIImage imageNamed:@"normal_tire_pressure"];
                }else {
                    self.tirePressureDisplayView.secondWheelImg.image = [UIImage imageNamed:@"malfunction_tire_pressure"];
                }
                
                if (leftFrontWheelValue > 200 && leftFrontWheelValue < 260) {
                    self.tirePressureDisplayView.thirdWheelImg.image = [UIImage imageNamed:@"normal_tire_pressure"];
                }else {
                    self.tirePressureDisplayView.thirdWheelImg.image = [UIImage imageNamed:@"malfunction_tire_pressure"];
                }
                
                if (rightRearWheelValue > 200 && rightRearWheelValue < 260) {
                    self.tirePressureDisplayView.fourthWheelImg.image = [UIImage imageNamed:@"normal_tire_pressure"];
                }else {
                    self.tirePressureDisplayView.fourthWheelImg.image = [UIImage imageNamed:@"malfunction_tire_pressure"];
                }
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
