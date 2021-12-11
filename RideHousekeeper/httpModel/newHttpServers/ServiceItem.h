//
//  ServiceItem.h
//  RideHousekeeper
//
//  Created by Apple on 2020/3/11.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ServiceItem : NSObject
@property (assign,nonatomic) NSInteger ID;// 服务包ID
@property (assign,nonatomic) NSInteger type;// 1 # int, 见 *服务包类型*
@property (copy,nonatomic) NSString* title;//: "一年平台服务包" # string, 服务包标题
@property (copy,nonatomic) NSString* descriptions;//description: '' # string, 服务包描述
@property (assign,nonatomic) NSInteger duration;//: 365 # int, 服务期（天）
@property (assign,nonatomic) NSInteger stat;//: 0 # 服务包状态 0 - 可用 1 - 不可用 2 - 当前车辆不适用（此状态非数据库状态）
@end

NS_ASSUME_NONNULL_END
