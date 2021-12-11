//
//  JpushModel.h
//  RideHousekeeper
//
//  Created by Apple on 2020/3/2.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JpushModel : NSObject

@property (assign, nonatomic) NSInteger bike_id;//车辆id
@property (assign, nonatomic) NSInteger user_id;//用户id
@property (assign, nonatomic) NSInteger type;//推送消息的类型
@property (copy, nonatomic) NSString* title;//自定义标题
@property (copy, nonatomic) NSString* content;//自定义内容
@property (assign, nonatomic) NSInteger category;//消息分类
@property (assign, nonatomic) NSInteger ts;//时间

@end

NS_ASSUME_NONNULL_END
