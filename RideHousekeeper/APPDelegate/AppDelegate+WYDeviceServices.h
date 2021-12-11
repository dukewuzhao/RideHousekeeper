//
//  AppDelegate+WYDeviceServices.h
//  RideHousekeeper
//
//  Created by Apple on 2019/9/25.
//  Copyright © 2019 Duke Wu. All rights reserved.
//

#import "AppDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface AppDelegate (WYDeviceServices)

-(void)monitorConnectStatus;

-(void)monitorBikeStatusModelCallback;

-(void)monitorBLEStatus;
@end

NS_ASSUME_NONNULL_END
