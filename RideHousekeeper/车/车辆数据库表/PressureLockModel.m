//
//  PressureLockModel.m
//  RideHousekeeper
//
//  Created by Apple on 2018/11/30.
//  Copyright © 2018年 Duke Wu. All rights reserved.
//

#import "PressureLockModel.h"

@implementation PressureLockModel

+ (instancetype)modalWith:(NSInteger )bikeid pressureLock:(NSInteger )pressureLock speeding_alarm:(NSInteger )speeding_alarm{
    
    PressureLockModel *model = [[self alloc] init];
    model.bikeid = bikeid;
    model.pressurelock = pressureLock;
    model.speeding_alarm = speeding_alarm;
    return model;
}

@end
