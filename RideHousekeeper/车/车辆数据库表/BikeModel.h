//
//  BikeModel.h
//  RideHousekeeper
//
//  Created by smartwallit on 16/8/6.
//  Copyright © 2016年 Duke Wu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BikeModel : NSObject

@property (nonatomic, assign) NSInteger bikeid; //车辆内部id
@property (nonatomic, copy) NSString *bikename;//自定义车辆名称
@property (nonatomic, assign) NSInteger ownerflag;//主用户标志
@property (nonatomic, assign) NSInteger ecu_id;//ecu的id
@property (nonatomic, copy) NSString *hwversion;//硬件版本
@property (nonatomic, copy) NSString *firmversion;//固件版本
@property (nonatomic, copy) NSString *keyversion;//硬件版本
@property (nonatomic, copy) NSString *mac;//报警器mac地址
@property (nonatomic, copy) NSString* sn; //必传，为兼容性，如app不传，使用mac
@property (nonatomic, copy) NSString * password;//子密码
@property (nonatomic, copy) NSString * mainpass;//主密码
@property (nonatomic, assign) NSInteger bindedcount;//绑定用户数
@property (nonatomic, copy) NSString *ownerphone;//拥有者
@property (nonatomic, assign) NSInteger fp_func; //车辆指纹功能
@property (nonatomic, assign) NSInteger fp_conf_count; //车辆指纹功能
@property (nonatomic, assign) NSInteger tpm_func;//车辆胎压监测功能
@property (nonatomic, assign) NSInteger gps_func;//是否支持gps
@property (nonatomic, assign) NSInteger vibr_sens_func; //车辆震动灵敏度功能
@property (nonatomic, assign) NSInteger wheels; //车轮数
@property (nonatomic, assign) NSInteger builtin_gps; //是否内置gps  0无内置 1有内置


+ (instancetype)modalWith:(NSInteger)bikeid bikename:(NSString *)bikename ownerflag:(NSInteger)ownerflag ecu_id:(NSInteger)ecu_id hwversion:(NSString *)hwversion firmversion:(NSString *)firmversion keyversion:(NSString *)keyversion mac:(NSString *)mac sn:(NSString *)sn mainpass:(NSString *)mainpass password:(NSString *)password bindedcount:(NSInteger)bindedcount ownerphone:(NSString *)ownerphone fp_func:(NSInteger)fp_func fp_conf_count:(NSInteger)fp_conf_count tpm_func:(NSInteger)tpm_func gps_func:(NSInteger)gps_func vibr_sens_func:(NSInteger)vibr_sens_func wheels:(NSInteger)wheels builtin_gps:(NSInteger)builtin_gps;

@end
