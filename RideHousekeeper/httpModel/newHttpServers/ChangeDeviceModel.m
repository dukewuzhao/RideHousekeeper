//
//  ChangeDeviceModel.m
//  RideHousekeeper
//
//  Created by Apple on 2020/4/23.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import "ChangeDeviceModel.h"

@implementation ChangeDeviceModel
+ (nullable NSDictionary<NSString *, id> *)modelContainerPropertyGenericClass{
    
    return @{
             @"ecu_missing_func" : NSString.class
             };
}
@end
