//
//  JPushDataModel.h
//  RideHousekeeper
//
//  Created by Apple on 2020/3/2.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JPushDataModel : NSObject

@property (assign, nonatomic) NSInteger bikeid;//车辆id
@property (assign, nonatomic) NSInteger userid;//用户id
@property (assign, nonatomic) NSInteger type;//推送消息的类型
@property (copy, nonatomic) NSString* title;//自定义标题
@property (copy, nonatomic) NSString* content;//自定义内容
@property (assign, nonatomic) NSInteger category;//消息分类
@property (copy, nonatomic) NSString* time;//推送时间

+ (instancetype)modalWith:(NSInteger )bikeid userid:(NSInteger)userid type:(NSInteger )type title:(NSString *)title content:(NSString *)content category:(NSInteger)category time:(NSString *)time;

@end

NS_ASSUME_NONNULL_END
