//
//  VehicleReportView.h
//  RideHousekeeper
//
//  Created by 吴兆华 on 2018/4/1.
//  Copyright © 2018年 Duke Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VehicleReportView : UIView
@property (nonatomic, assign) NSInteger           bikeid; //车辆内部id
@property (nonatomic, assign) NSInteger           viewType;
@property (nonatomic, strong) UIImageView   *BikeStatusImg;
@property (nonatomic, strong) UILabel       *BikeStatusLab;
@property (nonatomic, strong) UILabel       *CentralWithGPScConnection;
@end
