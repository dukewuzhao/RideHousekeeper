//
//  BikeModel.m
//  RideHousekeeper
//
//  Created by smartwallit on 16/8/6.
//  Copyright © 2016年 Duke Wu. All rights reserved.
//

#import "BikeModel.h"

@implementation BikeModel

+ (instancetype)modalWith:(NSInteger)bikeid bikename:(NSString *)bikename ownerflag:(NSInteger)ownerflag ecu_id:(NSInteger)ecu_id hwversion:(NSString *)hwversion firmversion:(NSString *)firmversion keyversion:(NSString *)keyversion mac:(NSString *)mac sn:(NSString *)sn mainpass:(NSString *)mainpass password:(NSString *)password bindedcount:(NSInteger)bindedcount ownerphone:(NSString *)ownerphone fp_func:(NSInteger)fp_func fp_conf_count:(NSInteger)fp_conf_count tpm_func:(NSInteger)tpm_func gps_func:(NSInteger)gps_func vibr_sens_func:(NSInteger)vibr_sens_func wheels:(NSInteger)wheels builtin_gps:(NSInteger)builtin_gps{
    BikeModel *model = [[self alloc] init];
    model.bikeid = bikeid;
    model.bikename = bikename;
    model.ownerflag = ownerflag;
    model.ecu_id = ecu_id;
    model.hwversion = hwversion;
    model.firmversion = firmversion;
    model.keyversion = keyversion;
    model.mac = mac;
    model.sn = sn;
    model.password = password;
    model.mainpass = mainpass;
    model.bindedcount = bindedcount;
    model.ownerphone = ownerphone;
    model.fp_func = fp_func;
    model.fp_conf_count = fp_conf_count;
    model.tpm_func = tpm_func;
    model.gps_func = gps_func;
    model.vibr_sens_func = vibr_sens_func;
    model.wheels = wheels;
    model.builtin_gps = builtin_gps;
    return model;
}


@end
