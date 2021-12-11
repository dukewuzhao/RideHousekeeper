//
//  BikeHeadView.h
//  RideHousekeeper
//
//  Created by Apple on 2018/3/1.
//  Copyright © 2018年 Duke Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InformationHintsView.h"
#import "VehicleStateView.h"
#import "VehiclePositioningMapView.h"
#import "VehicleReportView.h"

@interface BikeHeadView : UIView
@property (nonatomic, assign) NSInteger           bikeid; //车辆内部id
@property (nonatomic, assign) NSInteger           viewType;
@property (nonatomic, strong) InformationHintsView  *carCondition;
@property (nonatomic, strong) UIImageView    *bikeLogo;//车辆品牌logo
@property (nonatomic, strong) UIImageView    *bikeBrandImg;//车辆品牌图片
@property (nonatomic, strong) VehicleStateView     *vehicleStateView;
@property (nonatomic, strong) VehiclePositioningMapView           *vehiclePositioningMapView;
@property (nonatomic, strong) VehicleReportView                   *vehicleReportView;
@end
