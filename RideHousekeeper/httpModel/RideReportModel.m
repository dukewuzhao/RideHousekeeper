//
//  RideReportModel.m
//  RideHousekeeper
//
//  Created by Apple on 2019/10/12.
//  Copyright © 2019 Duke Wu. All rights reserved.
//

#import "RideReportModel.h"

@implementation RideReportModel

////把数组里面带有对象的类型专门按照这个方法，这个格式写出来*****
//+ (nullable NSDictionary<NSString *, id> *)modelContainerPropertyGenericClass{
//
//    return @{
//                @"detail" : DayRideReportModel.class, // @"statuses" : [MJStatus class],
//             };
//}

@end

@implementation DayRideReportModel



@end


@implementation RideReportContentModel



@end

@implementation RideReportLocModel



@end

@implementation RideReportShockModel



@end

@implementation RideReportShockContentModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"descriptions" : @"description"};
}

@end

