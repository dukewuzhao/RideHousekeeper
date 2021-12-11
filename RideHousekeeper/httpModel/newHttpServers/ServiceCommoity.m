//
//  ServiceCommoity.m
//  RideHousekeeper
//
//  Created by Apple on 2020/3/11.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import "ServiceCommoity.h"

@implementation ServiceCommoity
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"ID" : @"id",@"descriptions" : @"description"};
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"items" : ServiceItem.class };
}

@end
