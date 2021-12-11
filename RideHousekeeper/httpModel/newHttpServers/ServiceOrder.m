//
//  ServiceOrder.m
//  RideHousekeeper
//
//  Created by Apple on 2020/3/11.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import "ServiceOrder.h"

@implementation ServiceOrder

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"ID" : @"id"};
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"commodities" : ServiceCommoity.class };
}

@end
