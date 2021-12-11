//
//  ServiceCommoity.h
//  RideHousekeeper
//
//  Created by Apple on 2020/3/11.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ServiceCommoity : NSObject
@property (assign,nonatomic) NSInteger ID;//服务商品ID
@property (assign,nonatomic) NSInteger brand_id;//服务商品品牌，0为通用包
@property (copy,nonatomic) NSArray* items;//服务包数组
@property (copy,nonatomic) NSString* title;//服务商品标题，如不设置，自动获取首个服务包标题
@property (copy,nonatomic) NSString* descriptions;//服务商品描述
@property (assign,nonatomic) NSInteger price;//商品原价（分）
@property (assign,nonatomic) NSInteger actual_price;//商品售价（分）
@property (assign,nonatomic) NSInteger stat;//0 - 下架，不可购买 1 - 上架，可购买
@property (assign,nonatomic) NSInteger online_stat;//不可线上购买 1 - 可线上购买 注意stat和online_stat的关系，stat表示为商品是否有效，online_stat进一步标识在线是否可购买
@end

NS_ASSUME_NONNULL_END
