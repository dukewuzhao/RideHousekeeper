//
//  CustomBike.m
//  RideHousekeeper
//
//  Created by Apple on 2018/3/1.
//  Copyright © 2018年 Duke Wu. All rights reserved.
//

#import "CustomBike.h"
#import "CarConditionViewController.h"

@implementation CustomBike

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithRed:14/255.0 green:14/255.0 blue:14/255.0 alpha:1];
        
        [self setupUI];
    }
    return self;
}

-(void)setupUI{
    [self addSubview:self.bikeHeadView];
    self.vehicleConfigurationView.bikeTestImge.image = [UIImage imageNamed:@"vehicle_physical_examination"];
    self.vehicleConfigurationView.bikeTestLabel.text = NSLocalizedString(@"click_medical", nil);
    self.vehicleConfigurationView.bikeSetUpImge.image = [UIImage imageNamed:@"vehicle_setting"];
    self.vehicleConfigurationView.bikeSetUpLabel.text = NSLocalizedString(@"bike_set", nil);
    self.vehicleConfigurationView.bikePartsManageImge.image = [UIImage imageNamed:@"spare_parts_management"];
    self.vehicleConfigurationView.bikePartsManageLabel.text = NSLocalizedString(@"accessories_manager", nil);
    [self.bikeHeadView addSubview:self.vehicleStateView];
    [self addSubview:self.vehicleConfigurationView];
}


-(VehicleConfigurationView *)vehicleConfigurationView{
    
    if (!_vehicleConfigurationView) {
        _vehicleConfigurationView = [[VehicleConfigurationView alloc] initWithFrame: CGRectMake(0, (self.height - QGJ_TabbarSafeBottomMargin) * .8, ScreenWidth, (self.height - QGJ_TabbarSafeBottomMargin) *.2)];
    }
    return _vehicleConfigurationView;
}

-(VehicleStateView *)vehicleStateView{
    
    if (!_vehicleStateView) {
        _vehicleStateView = [[VehicleStateView alloc] initWithFrame: CGRectMake(0, self.bikeHeadView.height - (self.height - QGJ_TabbarSafeBottomMargin) *.25, ScreenWidth, (self.height - QGJ_TabbarSafeBottomMargin) *.25)];
    }
    return _vehicleStateView;
}

-(VehicleTravelView *)vehicleTravelView{
    
    if (!_vehicleTravelView) {
        _vehicleTravelView = [[VehicleTravelView alloc] initWithFrame:CGRectMake( 15, CGRectGetMaxY(self.bikeHeadView.frame), ScreenWidth - 30, (self.height - QGJ_TabbarSafeBottomMargin)*.1) ];
        _vehicleTravelView.layer.mask = [self UiviewRoundedRect:_vehicleTravelView.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(10, 10)];
    }
    return _vehicleTravelView;
}

-(VehicleReportView *)vehicleReportView{
    
    if (!_vehicleReportView) {
        
        _vehicleReportView = [[VehicleReportView alloc] initWithFrame:CGRectMake( 15, (self.height - QGJ_TabbarSafeBottomMargin) * .87, ScreenWidth - 30, (self.height - QGJ_TabbarSafeBottomMargin)*.1) ];
        _vehicleReportView.layer.mask = [self UiviewRoundedRect:_vehicleReportView.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(10, 10)];
    }
    return _vehicleReportView;
}

-(VehiclePositioningMapView *)vehiclePositioningMapView{
    
    if (!_vehiclePositioningMapView) {
        
        if (_haveGPS) {
            _vehiclePositioningMapView = [[VehiclePositioningMapView alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(self.bikeHeadView.frame)+ 10, ScreenWidth - 30, (self.height - QGJ_TabbarSafeBottomMargin)*.248)];
            _vehiclePositioningMapView.layer.cornerRadius = 10;
            [_vehiclePositioningMapView UIviewSetShadow:_vehiclePositioningMapView ShadowColor:[UIColor blackColor] ShadowOffset:CGSizeMake(0.0f, 0.0f) ShadowOpacity:0.15f shadowRadius:5.0f];
        }else if (_haveCentralControl){
            NSInteger viewY = (self.vehicleReportView.y - CGRectGetMaxY(self.vehicleTravelView.frame))/2 - (self.height - QGJ_TabbarSafeBottomMargin)*.161 + CGRectGetMaxY(self.vehicleTravelView.frame);
            _vehiclePositioningMapView = [[VehiclePositioningMapView alloc] initWithFrame:CGRectMake(15, viewY, ScreenWidth - 30, (self.height - QGJ_TabbarSafeBottomMargin)*.323)];
            _vehiclePositioningMapView.layer.mask = [self UiviewRoundedRect:_vehiclePositioningMapView.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(10, 10)];
        }
    }
    return _vehiclePositioningMapView;
    
}

-(BikeHeadView *)bikeHeadView{
    
    if (!_bikeHeadView) {
        _bikeHeadView = [[BikeHeadView alloc] initWithFrame:CGRectMake( 0, 0, ScreenWidth, (self.height - QGJ_TabbarSafeBottomMargin) * .8 - 10) ];
    }
    return _bikeHeadView;
}

- (void)setHaveGPS:(BOOL)haveGPS{
    _haveGPS = haveGPS;
    if (haveGPS) {
        @weakify(self);
        self.bikeHeadView.frame = CGRectMake( 0, 0, ScreenWidth, (self.height - QGJ_TabbarSafeBottomMargin) * .346);
        self.vehiclePositioningMapView.locationLab.text = @"徐汇区桂平路桂中园";
        self.vehiclePositioningMapView.timeLab.text = @"2分钟前";
        [self addSubview:self.vehiclePositioningMapView];
        
        self.vehiclePositioningMapView.bikeMapClickBlock = ^{
            
            @strongify(self);
            
        };
        
        float heighty = ( (self.height - QGJ_TabbarSafeBottomMargin) * .787 - CGRectGetMaxY(self.vehiclePositioningMapView.frame) - (self.height - QGJ_TabbarSafeBottomMargin) *.142)/2;
        self.vehicleConfigurationView.frame = CGRectMake(15,  CGRectGetMaxY(self.vehiclePositioningMapView.frame) + heighty, ScreenWidth - 30, (self.height - QGJ_TabbarSafeBottomMargin) *.142);
        self.vehicleConfigurationView.layer.mask = [self UiviewRoundedRect:self.vehicleConfigurationView.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(10, 10)];
        self.bikeHeadView.bikeStateImg.image = [UIImage imageNamed:@"bike_BLE_braekconnect"];
        self.bikeHeadView.bikeBleLab.text = NSLocalizedString(@"no_connect_state", nil);
        self.bikeHeadView.bikeBleLab.textColor = [UIColor redColor];
        self.bikeHeadView.haveGPS = YES;
        self.vehicleConfigurationView.haveGPS = YES;
        
    }else{
        
        self.bikeHeadView.frame = CGRectMake( 0, 0, ScreenWidth, ScreenHeight * .4);
        float heighty = ((self.height - QGJ_TabbarSafeBottomMargin) * .787 - CGRectGetMaxY(self.bikeHeadView.frame) - (self.height - QGJ_TabbarSafeBottomMargin) *.185)/2;
        self.vehicleConfigurationView.frame = CGRectMake(15, CGRectGetMaxY(self.bikeHeadView.frame)+heighty, ScreenWidth - 30, (self.height - QGJ_TabbarSafeBottomMargin) *.185);
        self.vehicleConfigurationView.bikeTestImge.image = [UIImage imageNamed:@"vehicle_physical_examination"];
        self.vehicleConfigurationView.bikeTestLabel.text = NSLocalizedString(@"click_medical", nil);
        self.vehicleConfigurationView.bikeTestLabel.textColor = [UIColor blackColor];
        self.vehicleConfigurationView.layer.mask = [self UiviewRoundedRect:self.vehicleConfigurationView.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(10, 10)];
        [self.vehiclePositioningMapView removeFromSuperview];
        self.vehiclePositioningMapView = nil;
        self.bikeHeadView.haveGPS = NO;
        self.vehicleConfigurationView.haveGPS = NO;
    }
    [self layoutIfNeeded];
}

- (void)setHaveCentralControl:(BOOL)haveCentralControl{
    _haveCentralControl = haveCentralControl;
    
    if (haveCentralControl) {
        @weakify(self);
        self.bikeHeadView.frame = CGRectMake( 0, 0, ScreenWidth, (self.height - QGJ_TabbarSafeBottomMargin)*.414);
        self.bikeHeadView.haveCentralControl = YES;

        [self.vehicleConfigurationView removeFromSuperview];
        self.vehicleConfigurationView = nil;
        [self.vehicleStateView removeFromSuperview];
        self.vehicleStateView = nil;
        
        [self addSubview: self.vehicleTravelView];
        self.vehiclePositioningMapView.bikeMapClickBlock = ^{
            
            @strongify(self);
            
        };
        self.vehiclePositioningMapView.locationLab.text = @"徐汇区桂平路桂中园";
        self.vehiclePositioningMapView.timeLab.text = @"2分钟前";
        [self addSubview: self.vehiclePositioningMapView];
        
        self.vehicleReportView.bikeReportClickBlock = ^{
            
            @strongify(self);
        };
        [self addSubview:self.vehicleReportView];
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

-(void)viewReset{
    
    if (self.haveCentralControl) {
        return;
    }
    self.bikeHeadView.vehicleView.bikestateImge.image = [UIImage imageNamed:@"bike_BLE_braekconnect"];
    self.bikeHeadView.vehicleView.bikestateLabel.text = NSLocalizedString(@"no_connect_state", nil);
    self.bikeHeadView.vehicleView.bikestateLabel.textColor = [UIColor whiteColor];
}


-(void)dealloc{
    
    NSLog(@"释放了");
}

@end
