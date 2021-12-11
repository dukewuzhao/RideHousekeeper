//
//  ServiceCard.h
//  RideHousekeeper
//
//  Created by Apple on 2020/3/11.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ServiceCommoity;
NS_ASSUME_NONNULL_BEGIN

@interface ServiceCard : NSObject
@property (assign,nonatomic) NSInteger ID;//服务卡ID
@property (copy,nonatomic) NSString* card_no;//服务卡卡号
@property (strong,nonatomic) ServiceCommoity* commodity;//服务卡所包含的服务商品
@property (assign,nonatomic) NSInteger stat;//服务卡状态 0 - 未使用 1 - 已使用 2 - 已回收（不可使用）

@end

NS_ASSUME_NONNULL_END
