//
//  CustomBike.h
//  RideHousekeeper
//
//  Created by Apple on 2018/3/1.
//  Copyright © 2018年 Duke Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VehicleConfigurationView.h"
#import "GPSVehicleDetailsViewController.h"
#import "BikeHeadView.h"
@class BikeStatusModel;

@interface CustomBike : UIView<ClickDelegate>
@property (nonatomic, assign) NSInteger                           bikeid; //车辆内部id
@property (nonatomic, assign) NSInteger                           tpm_func; //胎压功能
@property (nonatomic, assign) NSInteger                           wheels; //车轮数
@property (nonatomic, assign) BOOL                                havePressureMonitoring;//是否具有胎压监测功能
@property (nonatomic, assign) NSInteger                           viewType; //首页布局
@property (nonatomic, strong) VehicleConfigurationView            *vehicleConfigurationView;
@property (nonatomic, strong) BikeHeadView                        *bikeHeadView;
@property (nonatomic, strong) BikeStatusModel                     *bikeStatusModel;

-(void)viewReset;
-(void)begainTimer;
-(void)stopTimer;
-(void)getbikestatus:(NSInteger)bikeid;
-(void)restAnimationView;
@end
