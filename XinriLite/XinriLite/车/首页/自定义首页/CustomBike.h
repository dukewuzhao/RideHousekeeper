//
//  CustomBike.h
//  RideHousekeeper
//
//  Created by Apple on 2018/3/1.
//  Copyright © 2018年 Duke Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VehicleConfigurationView.h"
#import "VehicleStateView.h"
#import "VehiclePositioningMapView.h"
#import "BikeHeadView.h"
#import "VehicleTravelView.h"
#import "VehicleReportView.h"


@interface CustomBike : UIView
@property (nonatomic, assign) NSInteger                           bikeid; //车辆内部id
@property (nonatomic, assign) BOOL                                haveGPS;
@property (nonatomic, assign) BOOL                                haveCentralControl;
@property (nonatomic, strong) VehicleConfigurationView            *vehicleConfigurationView;
@property (nonatomic, strong) VehicleStateView                    *vehicleStateView;
@property (nonatomic, strong) VehiclePositioningMapView           *vehiclePositioningMapView;
@property (nonatomic, strong) BikeHeadView                        *bikeHeadView;
@property (nonatomic, strong) VehicleTravelView                   *vehicleTravelView;
@property (nonatomic, strong) VehicleReportView                   *vehicleReportView;
-(void)viewReset;
@end
