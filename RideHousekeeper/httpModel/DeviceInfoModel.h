//
//  DeviceInfoModel.h
//  RideHousekeeper
//
//  Created by Apple on 2017/11/27.
//  Copyright © 2017年 Duke Wu. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ServiceInfoModel;
@interface DeviceInfoModel : NSObject

@property (assign, nonatomic) NSInteger device_id;
@property (assign, nonatomic) NSInteger type;
@property (copy, nonatomic) NSString* mac;
@property (copy, nonatomic) NSString* sn;
@property (copy, nonatomic) NSString* qr;//设备二维码 可空，特定设备有（GPS）
@property (copy, nonatomic) NSString* firm_version;
@property (assign, nonatomic) NSInteger seq;
@property (assign, nonatomic) NSInteger default_brand_id;
@property (assign, nonatomic) NSInteger default_model_id;
@property (copy, nonatomic) NSString* prod_date;// 生产日期 设备生产日期，字符串YYYY-MM-DD
@property (copy, nonatomic) NSString* imei;
@property (copy, nonatomic) NSString* imsi;
@property (copy, nonatomic) NSString* sign;
@property (copy, nonatomic) NSString* desc;
@property (strong, nonatomic) NSMutableArray *service;
@property (assign, nonatomic) NSInteger ts;
@property (copy, nonatomic) NSString* bind_sn;
@property (copy, nonatomic) NSString* bind_mac;
@property (assign, nonatomic) NSInteger is_used;
@end
