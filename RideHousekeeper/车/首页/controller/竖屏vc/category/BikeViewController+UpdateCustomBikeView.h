//
//  BikeViewController+UpdateCustomBikeView.h
//  RideHousekeeper
//
//  Created by Apple on 2019/11/26.
//  Copyright © 2019 Duke Wu. All rights reserved.
//


#import "BikeViewController.h"
@class CustomBike;
NS_ASSUME_NONNULL_BEGIN

@interface BikeViewController (UpdateCustomBikeView)

-(void)updateCustomView:(CustomBike *)bikeView :(BikeStatusModel *)model;

-(void)BLEConnectlogicalAllocation:(CustomBike *)bikeView :(UIAlertView *)customAlertView :(BOOL)status;

//-(void)connectGPSByMac:(CustomBike *)bikeView Mac:(NSString *)mac;

-(void)queryBikeStatusOnce:(NSInteger)bikeid;



@end

NS_ASSUME_NONNULL_END
