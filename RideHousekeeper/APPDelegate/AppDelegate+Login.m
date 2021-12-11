//
//  AppDelegate+Login.m
//  RideHousekeeper
//
//  Created by Apple on 2018/1/5.
//  Copyright © 2018年 Duke Wu. All rights reserved.
//

#import "AppDelegate+Login.h"
#import <objc/runtime.h>
#import "Manager.h"
@implementation AppDelegate (Login)


- (void)logindata:(void(^)())success{
    
    if ([QFTools isBlankString:[QFTools getdata:@"phone_num"]]) {
        return;
    }
    NSMutableArray *arry = [NSMutableArray array];
    NSMutableArray *bikeAry = [LVFmdbTool queryBikeData:nil];
    for (BikeModel *bik in bikeAry) {
        [arry addObject:@(bik.bikeid)];
    }
    
    NSString *token = [QFTools getdata:@"token"];
    NSString *userid = [QFTools getdata:@"userid"];
    __block NSString *child2,*main2;
    NSMutableArray *macArrM2 = [NSMutableArray new];
    NSString *URLString = [NSString stringWithFormat:@"%@%@",QGJURL,@"app/getbikelist"];
    NSDictionary *parameters = @{@"token": token, @"user_id":userid};
    [[HttpRequest sharedInstance] postWithURLString:URLString parameters:parameters success:^(id _Nullable dict){
        
        if ([dict[@"status"] intValue] == 0) {
            NSDictionary *data = dict[@"data"];
            NSMutableArray *bike_info = data[@"bike_info"];
            [LVFmdbTool deleteBrandData:nil];
            [LVFmdbTool deleteBikeData:nil];
            [LVFmdbTool deleteModelData:nil];
            [LVFmdbTool deletePeripheraData:nil];
            [LVFmdbTool deleteFingerprintData:nil];
            [LVFmdbTool deletePerpheraServicesInfoData:nil];
            
            for (NSDictionary *bike in bike_info) {
                BikeInfoModel *bikeInfo = [BikeInfoModel yy_modelWithDictionary:bike];
                [macArrM2 addObject:@(bikeInfo.bike_id)];
                if (bikeInfo.owner_flag == 1) {
                    child2 = @"0";
                    main2 = bikeInfo.passwd_info.main;
                }else if (bikeInfo.owner_flag == 0){
                    child2 = bikeInfo.passwd_info.children.firstObject;
                    main2 = @"0";
                }
                
                NSString *logo = bikeInfo.brand_info.logo;
                BikeModel *pmodel = [BikeModel modalWith:bikeInfo.bike_id bikename:bikeInfo.bike_name ownerflag:bikeInfo.owner_flag ecu_id:bikeInfo.ecu_id hwversion:bikeInfo.hw_version firmversion:bikeInfo.firm_version keyversion:bikeInfo.key_version mac:bikeInfo.mac sn:bikeInfo.sn mainpass:main2 password:child2 bindedcount:bikeInfo.binded_count ownerphone:bikeInfo.owner_phone fp_func:bikeInfo.fp_func fp_conf_count:bikeInfo.fp_conf_count tpm_func:bikeInfo.tpm_func gps_func:bikeInfo.gps_func vibr_sens_func:bikeInfo.vibr_sens_func wheels:bikeInfo.wheels builtin_gps:bikeInfo.builtin_gps];
                [LVFmdbTool insertBikeModel:pmodel];
                
                if (bikeInfo.brand_info.brand_id == 0) {
                    logo = [QFTools getdata:@"defaultlogo"];
                }
                
                BrandModel *bmodel = [BrandModel modalWith:bikeInfo.bike_id brandid:bikeInfo.brand_info.brand_id brandname:bikeInfo.brand_info.brand_name logo:logo bike_pic:bikeInfo.brand_info.bike_pic];
                [LVFmdbTool insertBrandModel:bmodel];
                
                ModelInfo *Infomodel = [ModelInfo modalWith:bikeInfo.bike_id modelid:bikeInfo.model_info.model_id modelname:bikeInfo.model_info.model_name batttype:bikeInfo.model_info.batt_type battvol:bikeInfo.model_info.batt_vol wheelsize:bikeInfo.model_info.wheel_size brandid:bikeInfo.model_info.brand_id pictures:bikeInfo.model_info.picture_s pictureb:bikeInfo.model_info.picture_b];
                [LVFmdbTool insertModelInfo:Infomodel];
                
                for (DeviceInfoModel *device in bikeInfo.device_info){
                    
                    PeripheralModel *permodel = [PeripheralModel modalWith:bikeInfo.bike_id deviceid:device.device_id type:device.type seq:device.seq mac:device.mac sn:device.sn qr:device.qr firmversion:device.firm_version default_brand_id:device.default_brand_id default_model_id:device.default_model_id prod_date:device.prod_date imei:device.imei imsi:device.imsi sign:device.sign desc:device.desc ts:device.ts bind_sn:device.bind_mac bind_mac:device.bind_mac is_used:device.is_used];
                    [LVFmdbTool insertDeviceModel:permodel];
                    
                    for (ServiceInfoModel *servicesInfo in device.service){
                        
                        PerpheraServicesInfoModel *service = [PerpheraServicesInfoModel modelWith:bikeInfo.bike_id deviceid:device.device_id ID:servicesInfo.ID type:servicesInfo.type title:servicesInfo.title brand_id:servicesInfo.brand_id begin_date:servicesInfo.begin_date end_date:servicesInfo.end_date left_days:servicesInfo.left_days];
                        [LVFmdbTool insertPerpheraServicesInfoModel:service];
                    }
                }
                
                for (FingerModel *finger in bikeInfo.fps){
                    FingerprintModel *fingermodel = [FingerprintModel modalWith:bikeInfo.bike_id fp_id:finger.fp_id pos:finger.pos name:finger.name added_time:finger.added_time];
                    [LVFmdbTool insertFingerprintModel:fingermodel];
                }
            }
            
            //检测设备是否还存在
            if (![macArrM2 containsObject:@([USER_DEFAULTS integerForKey:Key_BikeId])]) {
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:Key_DeviceUUID];
                NSMutableArray *bikeAry = [LVFmdbTool queryBikeData:nil];
                if (bikeAry.count > 0) {
                    BikeModel *firstbikeinfo = bikeAry[0];
                    [USER_DEFAULTS setInteger:firstbikeinfo.bikeid forKey:Key_BikeId];
                }
                
                if ([[AppDelegate currentAppDelegate].mainController isKindOfClass:NSClassFromString(@"BikeViewController")] && bikeAry.count > 0) {
                    
                    [[Manager shareManager] bikeViewUpdateForNewConnect:YES];
                }
            }else if (![self array:[arry copy] isEqualTo:[macArrM2 copy]]){
                if ([[AppDelegate currentAppDelegate].mainController isKindOfClass:NSClassFromString(@"BikeViewController")] && bikeAry.count > 0) {
                    
                    [[Manager shareManager] bikeViewUpdateForNewConnect:YES];
                }
            }
            
            if ([LVFmdbTool queryBikeData:nil].count == 0) {
                
                if ([[AppDelegate currentAppDelegate].mainController isKindOfClass:NSClassFromString(@"BikeViewController")]) {
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:nil];
                }
            }else{
                
                if ([[AppDelegate currentAppDelegate].mainController isKindOfClass:NSClassFromString(@"AddBikeViewController")]) {
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:nil];
                }
            }
            
        }else{
            [SVProgressHUD showSimpleText:dict[@"status_info"]];
        }
        if (success) success();
    } failure:^(NSError *error) {
        NSLog(@"error :%@",error);
        if (success) success();
        [SVProgressHUD showSimpleText:TIP_OF_NO_NETWORK];
    }];
}

- (BOOL)array:(NSArray *)array1 isEqualTo:(NSArray *)array2 {
    if (array1.count != array2.count) {
        return NO;
    }
    for (NSString *str in array1) {
        if (![array2 containsObject:str]) {
            return NO;
        }
    }
    return YES;
    
}

@end
