//
//  VehicleTravelView.h
//  RideHousekeeper
//
//  Created by 吴兆华 on 2018/4/1.
//  Copyright © 2018年 Duke Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VehicleTravelView : UIView

@property (nonatomic, strong) UIImageView   *dayMileageImg;
@property (nonatomic, strong) UILabel       *dayMileageLab;
@property (nonatomic, strong) UILabel       *dayMileageDes;
@property (nonatomic, strong) UILabel       *dayKMLab;
@property (nonatomic, strong) UIView        *splitView;
@property (nonatomic, strong) UIImageView   *totalMileageImg;
@property (nonatomic, strong) UILabel       *totalMileageLab;
@property (nonatomic, strong) UILabel       *totalMileageDes;
@property (nonatomic, strong) UILabel       *totalKMLab;

@end
