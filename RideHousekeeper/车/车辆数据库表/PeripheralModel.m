//
//  PeripheralModel.m
//  RideHousekeeper
//
//  Created by smartwallit on 16/8/22.
//  Copyright © 2016年 Duke Wu. All rights reserved.
//

#import "PeripheralModel.h"

@implementation PeripheralModel

+ (instancetype)modalWith:(NSInteger)bikeid deviceid:(NSInteger)deviceid type:(NSInteger)type seq:(NSInteger)seq mac:(NSString *)mac sn:(NSString *)sn qr:(NSString *)qr firmversion:(NSString *)firmversion default_brand_id:(NSInteger)default_brand_id default_model_id:(NSInteger)default_model_id prod_date:(NSString *)prod_date imei:(NSString *)imei imsi:(NSString *)imsi sign:(NSString *)sign desc:(NSString *)desc ts:(NSInteger)ts bind_sn:(NSString *)bind_sn bind_mac:(NSString *)bind_mac is_used:(NSInteger)is_used{
    
    PeripheralModel *model = [[self alloc] init];
    model.bikeid = bikeid;
    model.deviceid = deviceid;
    model.seq = seq;
    model.type = type;
    model.mac = mac;
    model.sn = sn;
    model.qr = qr;
    model.firmversion = firmversion;
    model.default_brand_id = default_brand_id;
    model.default_model_id = default_model_id;
    model.prod_date = prod_date;
    model.imei = imei;
    model.imsi = imsi;
    model.sign = sign;
    model.desc = desc;
    model.ts = ts;
    model.bind_sn = bind_sn;
    model.bind_mac = bind_mac;
    model.is_used = is_used;
    return model;

}
@end
