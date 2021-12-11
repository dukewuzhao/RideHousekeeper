//
//  PeripheralModel.h
//  RideHousekeeper
//
//  Created by smartwallit on 16/8/22.
//  Copyright © 2016年 Duke Wu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PeripheralModel : NSObject

@property (nonatomic, assign) NSInteger bikeid; //车辆内部id
@property (nonatomic, assign) NSInteger deviceid;//外设id
@property (nonatomic, assign) NSInteger type;//外设类型
@property (nonatomic, assign) NSInteger seq;//设备序号
@property (nonatomic, copy) NSString *mac;//mac地址
@property (nonatomic, copy) NSString *sn;//设备sn号
@property (nonatomic, copy) NSString *qr;//设备二维码
@property (nonatomic, copy) NSString *firmversion;//固件版本号
@property (nonatomic, assign) NSInteger default_brand_id;//默认车辆品牌id
@property (nonatomic, assign) NSInteger default_model_id;//默认车辆型号id
@property (nonatomic, copy) NSString *prod_date;//生产日期
@property (nonatomic, copy) NSString *imei;//IMEI码
@property (nonatomic, copy) NSString *imsi;//IMSI码
@property (nonatomic, copy) NSString *sign;//鉴权签名 该设备需要鉴权时的鉴权签名，非固定值，跟模式、用户、设备本身都相关，app不关心生成算法，可空
@property (nonatomic, copy) NSString *desc;//描述信息
@property (nonatomic, assign) NSInteger ts;//时间戳
@property (nonatomic, copy) NSString *bind_sn;//套装绑定sn
@property (nonatomic, copy) NSString *bind_mac;//套装绑定的mac
@property (nonatomic, assign) NSInteger is_used;//设备是否已经被使用了 0 - 未使用 1 - 已使用 2 - 在试用期

+ (instancetype)modalWith:(NSInteger)bikeid deviceid:(NSInteger)deviceid type:(NSInteger)type seq:(NSInteger)seq mac:(NSString *)mac sn:(NSString *)sn qr:(NSString *)qr firmversion:(NSString *)firmversion default_brand_id:(NSInteger)default_brand_id default_model_id:(NSInteger)default_model_id prod_date:(NSString *)prod_date imei:(NSString *)imei imsi:(NSString *)imsi sign:(NSString *)sign desc:(NSString *)desc ts:(NSInteger)ts bind_sn:(NSString *)bind_sn bind_mac:(NSString *)bind_mac is_used:(NSInteger)is_used;

@end
