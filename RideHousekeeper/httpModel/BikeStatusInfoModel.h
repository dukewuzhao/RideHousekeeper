//
//  BikeStatusInfoModel.h
//  RideHousekeeper
//
//  Created by Apple on 2019/10/12.
//  Copyright © 2019 Duke Wu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class BikeStatusBikeModel,BikeStatusNetPosModel,BikeStatusNetPosModel,BikeStatusDeviceModel,BikeStatusPosModel;
@interface BikeStatusInfoModel : NSObject

@property (assign, nonatomic) NSInteger is_fix;
@property (assign, nonatomic) NSInteger is_online;
@property (assign, nonatomic) NSInteger signal;
@property (assign, nonatomic) NSInteger updated_ts;
@property (strong, nonatomic) BikeStatusBikeModel *bike;
@property (strong, nonatomic) BikeStatusNetPosModel *net_pos;
@property (strong, nonatomic) BikeStatusDeviceModel *device;
@property (strong, nonatomic) BikeStatusPosModel *pos;
@end

@interface BikeStatusBikeModel : NSObject
@property (assign, nonatomic) NSInteger acc;
@property (assign, nonatomic) NSInteger battery_exist;
@property (assign, nonatomic) NSInteger battery_vol;
@property (assign, nonatomic) NSInteger force_lock;
@property (assign, nonatomic) NSInteger lock;
@property (assign, nonatomic) NSInteger mute;
@end

@interface BikeStatusNetPosModel : NSObject
@property (copy, nonatomic) NSString *bts;
@property (copy, nonatomic) NSString *near_bts;
@property (assign, nonatomic) NSInteger ts;
@end

@interface BikeStatusDeviceModel : NSObject
@property (assign, nonatomic) NSInteger battery_flag;
@property (assign, nonatomic) NSInteger battery_level;
@end

@interface BikeStatusPosModel : NSObject
@property (assign, nonatomic) NSInteger alt;
@property (assign, nonatomic) NSInteger degree;
@property (copy, nonatomic) NSString *desc;
@property (assign, nonatomic) double lat;
@property (assign, nonatomic) NSInteger level;
@property (assign, nonatomic) double lng;
@property (assign, nonatomic) NSInteger radius;
@property (assign, nonatomic) NSInteger speed;
@property (assign, nonatomic) NSInteger ts;
@end

NS_ASSUME_NONNULL_END
