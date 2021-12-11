//
//  VehicleReportView.h
//  RideHousekeeper
//
//  Created by 吴兆华 on 2018/4/1.
//  Copyright © 2018年 Duke Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VehicleReportView : UIView

@property (nonatomic, strong) UIImageView   *reportImg;
@property (nonatomic, strong) UILabel       *reportLab;
@property (nonatomic, strong) UIView     *maskView;
@property (nonatomic, copy) void (^ bikeReportClickBlock)();
@end
