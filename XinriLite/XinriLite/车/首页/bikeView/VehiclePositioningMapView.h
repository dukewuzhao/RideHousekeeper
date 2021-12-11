//
//  VehiclePositioningMapView.h
//  RideHousekeeper
//
//  Created by Apple on 2018/2/27.
//  Copyright © 2018年 Duke Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface VehiclePositioningMapView : UIView

@property (nonatomic, strong) UILabel    *locationLab;
@property (nonatomic, strong) UILabel    *timeLab;
@property (nonatomic, strong) UIView     *maskView;

@property (nonatomic, copy) void (^ bikeMapClickBlock)();
@end
