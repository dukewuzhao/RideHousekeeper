//
//  ServiceItem.m
//  RideHousekeeper
//
//  Created by Apple on 2020/3/11.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import "ServiceItem.h"

@implementation ServiceItem
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"ID" : @"id",@"descriptions" : @"description"};
}
@end
