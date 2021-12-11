//
//  BikeHeadView.h
//  RideHousekeeper
//
//  Created by Apple on 2018/3/1.
//  Copyright © 2018年 Duke Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InformationHintsView.h"
#import "VehicleControlView.h"
@interface BikeHeadView : UIView
@property (nonatomic, strong) UILabel    *bikeBleLab;//车辆连接 状态
@property (nonatomic, strong) UIImageView   *backImg;
@property (nonatomic, strong) UIImageView    *bikeBrandImg;//车辆图片
@property (nonatomic, strong) UIImageView   *bikeStateImg;
@property (nonatomic, strong) VehicleControlView   *vehicleView;
@property (nonatomic, assign) BOOL           haveGPS;
@property (nonatomic, assign) BOOL       haveCentralControl;
@end
