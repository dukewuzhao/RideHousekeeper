//
//  BrandModel.m
//  RideHousekeeper
//
//  Created by smartwallit on 16/8/20.
//  Copyright © 2016年 Duke Wu. All rights reserved.
//

#import "BrandModel.h"

@implementation BrandModel

+ (instancetype)modalWith:(NSInteger)bikeid brandid:(NSInteger)brandid brandname:(NSString *)brandname logo:(NSString *)logo bike_pic:(NSString *)bike_pic;
{
    BrandModel *model = [[self alloc] init];
    model.bikeid = bikeid;
    model.brandid = brandid;
    model.brandname = brandname;
    model.logo = logo;
    model.bike_pic = bike_pic;
    return model;
}


@end
