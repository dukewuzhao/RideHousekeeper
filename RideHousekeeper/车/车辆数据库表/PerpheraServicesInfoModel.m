//
//  PerpheraServicesInfoModel.m
//  RideHousekeeper
//
//  Created by Apple on 2020/3/25.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import "PerpheraServicesInfoModel.h"

@implementation PerpheraServicesInfoModel

+(instancetype)modelWith:(NSInteger)bikeid deviceid:(NSInteger)deviceid ID:(NSInteger)ID type:(NSInteger)type title:(NSString *)title brand_id:(NSInteger)brand_id begin_date:(NSString *)begin_date end_date:(NSString *)end_date left_days:(NSInteger)left_days{
    PerpheraServicesInfoModel *model = [[self alloc] init];
    model.bikeid = bikeid;
    model.deviceid = deviceid;
    model.ID = ID;
    model.type = type;
    model.title = title;
    model.brand_id = brand_id;
    model.begin_date = begin_date;
    model.end_date = end_date;
    model.left_days = left_days;
    return model;
}

@end
