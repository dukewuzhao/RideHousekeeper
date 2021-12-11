//
//  JPushDataModel.m
//  RideHousekeeper
//
//  Created by Apple on 2020/3/2.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import "JPushDataModel.h"

@implementation JPushDataModel

+(instancetype)modalWith:(NSInteger)bikeid userid:(NSInteger)userid type:(NSInteger)type title:(NSString *)title content:(NSString *)content category:(NSInteger)category time:(NSString *)time{
    JPushDataModel *model = [[self alloc] init];
    model.bikeid = bikeid;
    model.userid = userid;
    model.type = type;
    model.title = title;
    model.content = content;
    model.category = category;
    model.time = time;
    return model;
}

@end
