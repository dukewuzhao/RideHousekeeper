//
//  PeripheralActivationStatusModel.m
//  RideHousekeeper
//
//  Created by Apple on 2020/3/27.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import "PeripheralActivationStatusModel.h"

@implementation PeripheralActivationStatusModel

+(instancetype)modelWith:(NSInteger)bikeid deviceid:(NSInteger)deviceid type:(NSInteger)type activationStatus:(NSInteger)activationStatus{
    
    PeripheralActivationStatusModel *model = [[self alloc] init];
    model.bikeid = bikeid;
    model.deviceid = deviceid;
    model.type = type;
    model.activationStatus = activationStatus;
    return model;
}

@end
