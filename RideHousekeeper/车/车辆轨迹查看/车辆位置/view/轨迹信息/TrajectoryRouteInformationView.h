//
//  TrajectoryRouteInformationView.h
//  RideHousekeeper
//
//  Created by Apple on 2019/10/29.
//  Copyright © 2019 Duke Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LianUISlider.h"
NS_ASSUME_NONNULL_BEGIN

typedef void (^SliderSlidingValue)(NSInteger value);

typedef void (^PlayBtnStep)(BOOL selected);

@interface TrajectoryRouteInformationView : UIView
@property (strong, nonatomic) LianUISlider *slider;
@property (strong, nonatomic) UIButton *playBtn;
@property(nonatomic, strong)DayRideReportModel *model;
@property (copy, nonatomic) SliderSlidingValue slidingValue;
@property (copy, nonatomic) PlayBtnStep playBtnStep;
@end

NS_ASSUME_NONNULL_END
