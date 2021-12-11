//
//  AppDelegate+GetBikeList.m
//  RideHousekeeper
//
//  Created by Apple on 2018/11/16.
//  Copyright © 2018年 Duke Wu. All rights reserved.
//

#import "AppDelegate+GetBikeList.h"
#import "Manager.h"
@implementation AppDelegate (GetBikeList)

- (void)getbikelist:(NSDictionary *)jpushDict{
    
    __block NSString *child,*main;
    NSMutableArray *bikeIdArrM = [NSMutableArray new];
    NSNumber *type = jpushDict[@"type"];
    NSString *token = [QFTools getdata:@"token"];
    NSString *userid = [QFTools getdata:@"userid"];
    
    NSString *URLString = [NSString stringWithFormat:@"%@%@",QGJURL,@"app/getbikelist"];
    NSDictionary *parameters = @{@"token": token, @"user_id":userid};
    
    [[HttpRequest sharedInstance] postWithURLString:URLString parameters:parameters success:^(id _Nullable dict) {
        
        if ([dict[@"status"] intValue] == 0) {
            if ([type integerValue] == 1 || [type integerValue] == 2 || [type integerValue] == 3  ) {
                
                [LVFmdbTool deleteBrandData:nil];
                [LVFmdbTool deleteBikeData:nil];
                [LVFmdbTool deleteModelData:nil];
                [LVFmdbTool deletePeripheraData:nil];
                [LVFmdbTool deleteFingerprintData:nil];
                [LVFmdbTool deletePerpheraServicesInfoData:nil];
                NSDictionary *data = dict[@"data"];
                NSMutableArray *bike_info = data[@"bike_info"];
                
                for (NSDictionary *bike in bike_info) {
                    
                    BikeInfoModel *bikeInfo = [BikeInfoModel yy_modelWithDictionary:bike];
                    [bikeIdArrM addObject:@(bikeInfo.bike_id)];
                    
                    if (bikeInfo.owner_flag == 1) {
                        
                        child = @"0";
                        main = bikeInfo.passwd_info.main;
                    }else if (bikeInfo.owner_flag == 0){
                        
                        child = bikeInfo.passwd_info.children.firstObject;
                        main = @"0";
                    }
                    
                    NSString *logo = bikeInfo.brand_info.logo;
                    NSString *picture_b = bikeInfo.model_info.picture_b;
                    
                    BikeModel *pmodel = [BikeModel modalWith:bikeInfo.bike_id bikename:bikeInfo.bike_name ownerflag:bikeInfo.owner_flag ecu_id:bikeInfo.ecu_id hwversion:bikeInfo.hw_version firmversion:bikeInfo.firm_version keyversion:bikeInfo.key_version mac:bikeInfo.mac sn:bikeInfo.sn mainpass:main password:child bindedcount:bikeInfo.binded_count ownerphone:bikeInfo.owner_phone fp_func:bikeInfo.fp_func fp_conf_count:bikeInfo.fp_conf_count tpm_func:bikeInfo.tpm_func gps_func:bikeInfo.gps_func vibr_sens_func:bikeInfo.vibr_sens_func wheels:bikeInfo.wheels builtin_gps:bikeInfo.builtin_gps];
                    [LVFmdbTool insertBikeModel:pmodel];
                    
                    if (bikeInfo.brand_info.brand_id == 0) {
                        logo = [QFTools getdata:@"defaultlogo"];
                    }
                    
                    BrandModel *bmodel = [BrandModel modalWith:bikeInfo.bike_id brandid:bikeInfo.brand_info.brand_id brandname:bikeInfo.brand_info.brand_name logo:logo bike_pic:bikeInfo.brand_info.bike_pic];
                    [LVFmdbTool insertBrandModel:bmodel];
                    
                    if (bikeInfo.model_info.model_id == 0) {
                        picture_b = [QFTools getdata:@"defaultimage"];
                    }
                    
                    ModelInfo *Infomodel = [ModelInfo modalWith:bikeInfo.bike_id modelid:bikeInfo.model_info.model_id modelname:bikeInfo.model_info.model_name batttype:bikeInfo.model_info.batt_type battvol:bikeInfo.model_info.batt_vol wheelsize:bikeInfo.model_info.wheel_size brandid:bikeInfo.model_info.brand_id pictures:bikeInfo.model_info.picture_s pictureb:bikeInfo.model_info.picture_b];
                    [LVFmdbTool insertModelInfo:Infomodel];
                    
                    for (DeviceInfoModel *device in bikeInfo.device_info){
                        PeripheralModel *permodel = [PeripheralModel modalWith:bikeInfo.bike_id deviceid:device.device_id type:device.type seq:device.seq mac:device.mac sn:device.sn qr:device.qr firmversion:device.firm_version default_brand_id:device.default_brand_id default_model_id:device.default_model_id prod_date:device.prod_date imei:device.imei imsi:device.imsi sign:device.sign desc:device.desc ts:device.ts bind_sn:device.bind_sn bind_mac:device.bind_mac is_used:device.is_used];
                        [LVFmdbTool insertDeviceModel:permodel];
                        
                        for (ServiceInfoModel *servicesInfo in device.service){
                            
                            PerpheraServicesInfoModel *service = [PerpheraServicesInfoModel modelWith:bikeInfo.bike_id deviceid:device.device_id ID:servicesInfo.ID type:servicesInfo.type title:servicesInfo.title brand_id:servicesInfo.brand_id begin_date:servicesInfo.begin_date end_date:servicesInfo.end_date left_days:servicesInfo.left_days];
                            [LVFmdbTool insertPerpheraServicesInfoModel:service];
                        }
                        
                    }
                    
                    for (FingerModel *fpsInfo in bikeInfo.fps){
                        
                        FingerprintModel *fingermodel = [FingerprintModel modalWith:bikeInfo.bike_id fp_id:fpsInfo.fp_id pos:fpsInfo.pos name:fpsInfo.name added_time:fpsInfo.added_time];
                        [LVFmdbTool insertFingerprintModel:fingermodel];
                    }
                }
                
                
                if (![bikeIdArrM containsObject:@([USER_DEFAULTS integerForKey:Key_BikeId])]) {
                    [USER_DEFAULTS removeObjectForKey:Key_DeviceUUID];
                    [USER_DEFAULTS removeObjectForKey:Key_BikeId];
                    [USER_DEFAULTS synchronize];
                    NSMutableArray *bikeAry = [LVFmdbTool queryBikeData:nil];
                    if (bikeAry.count > 0) {
                        BikeModel *firstbikeinfo = bikeAry[0];
                        [USER_DEFAULTS setInteger:firstbikeinfo.bikeid forKey:Key_BikeId];
                    }
                    
                    [CommandDistributionServices removePeripheral:nil];
                    
                }
                
                if ([LVFmdbTool queryBikeData:nil].count == 0) {
                    
                    if ([self.mainController isKindOfClass:NSClassFromString(@"BikeViewController")]) {
                        
                        if (![[APPStatusManager sharedManager] getBikeBindingStstus]) {
                            [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:nil];
                        }
                    }
                }else{
                    
                    if ([self.mainController isKindOfClass:NSClassFromString(@"AddBikeViewController")]) {
                        
                        if (![[APPStatusManager sharedManager] getBikeBindingStstus]) {
                            [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:nil];
                        }
                    }
                }
            }else if ([type integerValue] == 4){
                
                NSDictionary *data = dict[@"data"];
                NSMutableArray *bike_info = data[@"bike_info"];
                
                for (NSDictionary *bike in bike_info) {
                    
                    BikeInfoModel *bikeInfo = [BikeInfoModel yy_modelWithDictionary:bike];
                    if (bikeInfo.bike_id == [jpushDict[@"bikeid"] integerValue]) {
                        NSString *updateSql = [NSString stringWithFormat:@"UPDATE bike_modals SET bikename = '%@' , firmversion = '%@', bindedcount = '%zd' WHERE bikeid = '%zd'", bikeInfo.bike_name,bikeInfo.firm_version,bikeInfo.binded_count,bikeInfo.bike_id];
                        [LVFmdbTool modifyData:updateSql];
                    }
                }
            }
            
            if ([LVFmdbTool queryBikeData:nil].count > 0) {
                
                [[Manager shareManager] postRemoteJPush:jpushDict];
            }
            
        }else if([dict[@"status"] intValue] == 1001){
            [SVProgressHUD showSimpleText:dict[@"status_info"]];
            
        }else{
            [SVProgressHUD showSimpleText:dict[@"status_info"]];
        }
        
    }failure:^(NSError *error) {
        
        NSLog(@"error :%@",error);
        [SVProgressHUD showSimpleText:TIP_OF_NO_NETWORK];
    }];
}

@end
