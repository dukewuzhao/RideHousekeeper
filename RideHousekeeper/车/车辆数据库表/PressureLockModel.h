//
//  PressureLockModel.h
//  RideHousekeeper
//
//  Created by Apple on 2018/11/30.
//  Copyright © 2018年 Duke Wu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PressureLockModel : NSObject

@property (nonatomic, assign) NSInteger bikeid;
@property (nonatomic, assign) NSInteger pressurelock;
@property (nonatomic, assign) NSInteger speeding_alarm;
+ (instancetype)modalWith:(NSInteger )bikeid pressureLock:(NSInteger)pressureLock speeding_alarm:(NSInteger)speeding_alarm;
@end

NS_ASSUME_NONNULL_END
