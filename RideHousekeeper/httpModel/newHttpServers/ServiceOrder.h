//
//  ServiceOrder.h
//  RideHousekeeper
//
//  Created by Apple on 2020/3/11.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ServiceOrder : NSObject
@property (assign,nonatomic) NSInteger ID;// 10005 # int 订单ID
@property (assign,nonatomic) NSInteger user_id;//user_id: 27 # int 订单用户ID
@property (assign,nonatomic) NSInteger binded_id;//binded_id: 400000107 # int 绑定的设备ID，当前为GPS ID
@property (assign,nonatomic) NSInteger stat;//stat: 0 # 订单状态 0 - 打开 1 - 已支付 2 - 取消 3 - 过期，与pay_stat关系见下
@property (copy,nonatomic) NSArray* commodities;//commodities: *[]service_commodity # 商品数组，部分接口调用时，返回的只含ID值
@property (assign,nonatomic) NSInteger pay_channel;//pay_channel: 4 # 支付渠道，具体渠道见下
@property (assign,nonatomic) NSInteger amount;//amount: 8000 # 订单金额
@property (assign,nonatomic) NSInteger promotion_id;//promotion_id: 0 # 优惠码id，实体卡支付时为实体卡考号，车辆转移时为原binded_id
@property (assign,nonatomic) NSInteger promotion_amount;//promotion_amount: 0 # 优惠金额
@property (assign,nonatomic) NSInteger pay_amount;//pay_amount: 8000 # 实际支付金额
@property (assign,nonatomic) NSInteger pay_stat;//pay_stat: 1 # 0 - 未支付 1 - 已支付（app反馈，但还未收到服务端回调） 2 - 支付成功 3 - 支付失败
@property (assign,nonatomic) NSInteger created_time;//created_time: 1582090233 # 订单建立时间，timestamp
@property (assign,nonatomic) NSInteger expire_time;//expire_time: 1582092033 # 订单过期时间，timestamp
@property (assign,nonatomic) NSInteger paid_time;//paid_time: 1582106481 # 订单支付时间, timestamp
@property (assign,nonatomic) NSInteger updated_time;//updated_time: 0 # 订单更新时间
@end

NS_ASSUME_NONNULL_END
