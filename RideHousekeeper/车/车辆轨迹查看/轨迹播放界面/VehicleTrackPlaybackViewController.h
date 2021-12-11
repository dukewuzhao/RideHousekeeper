//
//  VehicleTrackPlaybackViewController.h
//  RideHousekeeper
//
//  Created by Apple on 2020/5/18.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface VehicleTrackPlaybackViewController : BaseViewController
@property (nonatomic, assign) NSInteger           bikeid;
-(void)DrawingCyclingRoute:(DayRideReportModel *)model;
@end

NS_ASSUME_NONNULL_END
