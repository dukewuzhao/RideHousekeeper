//
//  BikeInfoModel.h
//  RideHousekeeper
//
//  Created by Apple on 2017/11/28.
//  Copyright © 2017年 Duke Wu. All rights reserved.
//

#import <Foundation/Foundation.h>
@class BikeBrandInfoModel;
@class BikeModelInfoModel;
@class BikePasswdInfoModel;
@interface BikeInfoModel : NSObject

@property (assign, nonatomic) NSInteger bike_id;
@property (copy, nonatomic) NSString* bike_name;
@property (assign, nonatomic) NSInteger owner_flag;//主用户标志
@property (assign, nonatomic) NSInteger ecu_id;//主用户标志
@property (copy, nonatomic) NSString* hw_version;//ecu的id
@property (copy, nonatomic) NSString* firm_version;//固件版本
@property (copy, nonatomic) NSString* key_version;//钥匙版本
@property (copy, nonatomic) NSString* mac;//ecu报警器mac地址
@property (copy, nonatomic) NSString* sn;//ecu报警器SN
@property (assign, nonatomic) NSInteger binded_count;//绑定用户数
@property (strong, nonatomic) BikeBrandInfoModel *brand_info;
@property (strong, nonatomic) BikeModelInfoModel *model_info;
@property (strong, nonatomic) BikePasswdInfoModel *passwd_info;
/** 存放着外设数据（里面都是DeviceInfo模型） */
@property (strong, nonatomic) NSMutableArray *device_info;
@property (copy, nonatomic) NSString* owner_phone;
/** 存放着指纹数据（里面都是FingerModel模型） */
@property (strong, nonatomic) NSMutableArray *fps;
@property (assign, nonatomic) NSInteger fp_func;
@property (assign, nonatomic) NSInteger fp_conf_count;
@property (assign, nonatomic) NSInteger vibr_sens_func;
@property (assign, nonatomic) NSInteger tpm_func;
@property (assign, nonatomic) NSInteger gps_func;
@property (assign, nonatomic) NSInteger wheels;
@property (assign, nonatomic) NSInteger builtin_gps;//是否内置gps
@end
