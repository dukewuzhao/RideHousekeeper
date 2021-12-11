//
//  NSObject+GPSDeactivation.h
//  RideHousekeeper
//
//  Created by 晶 on 2020/3/29.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (GPSDeactivation)
-(void)GPSDeactivation :(NSString *)ECUMac :(void (^)(id))operatingStatus;
-(void)accessoryGPSDeactivation :(NSString *)ECUMac :(void (^)(id))operatingStatus;
-(void)SingleGPSDeactivation :(NSString *)GPSMac :(void (^)(id))operatingStatus;
@end

NS_ASSUME_NONNULL_END
