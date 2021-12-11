//
//  ChangeDeviceModel.h
//  RideHousekeeper
//
//  Created by Apple on 2020/4/23.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import <Foundation/Foundation.h>
@class BikeInfoModel;
NS_ASSUME_NONNULL_BEGIN

@interface ChangeDeviceModel : NSObject
@property (strong, nonatomic) BikeInfoModel* bike_info;
@property (assign, nonatomic) NSInteger device_type;
@property (assign, nonatomic) NSInteger device_id;
@property (assign, nonatomic) NSInteger can_not_force;
@property (copy,   nonatomic) NSArray* ecu_missing_func;
@end

NS_ASSUME_NONNULL_END
