//
//  ServiceInfoModel.h
//  RideHousekeeper
//
//  Created by Apple on 2019/10/12.
//  Copyright © 2019 Duke Wu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ServiceInfoModel : NSObject

@property (copy, nonatomic) NSString* begin_date;//服务开始时间
@property (assign, nonatomic) NSInteger brand_id;
@property (copy, nonatomic) NSString* end_date;//服务结束时间
@property (assign, nonatomic) NSInteger ID;//服务剩余时间(天数)
@property (assign, nonatomic) NSInteger left_days;//服务剩余时间(天数)
@property (copy, nonatomic) NSString* title;
@property (assign, nonatomic) NSInteger type;
@end

NS_ASSUME_NONNULL_END
