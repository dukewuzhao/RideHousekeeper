//
//  VehicleConfigurationView.h
//  RideHousekeeper
//
//  Created by Apple on 2018/2/26.
//  Copyright © 2018年 Duke Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VehicleConfigurationView : UIView
@property (nonatomic, assign) NSInteger          viewType;
@property (nonatomic, strong) UIImageView   *bikeTestImge;
@property (nonatomic, strong) UILabel       *bikeTestLabel;//车辆故障状态显示

@property (nonatomic, strong) UIImageView   *bikeSetUpImge;//车辆设置图片
@property (nonatomic, strong) UILabel       *bikeSetUpLabel;//车辆设置

@property (nonatomic, strong) UIImageView   *bikePartsManageImge;//配件管理图片
@property (nonatomic, strong) UILabel       *bikePartsManageLabel;//配件管理
@property (nonatomic, strong) UIView       *clickView;
@property (nonatomic, copy) void (^ bikeTestClickBlock)();
@property (nonatomic, copy) void (^ bikeSetUpClickBlock)();
@property (nonatomic, copy) void (^ bikePartsManagClickBlock)();

@property (nonatomic, copy) void (^ RidingTrackClick)();
@property (nonatomic, copy) void (^ PositioningServiceClick)();

@end
