//
//  CommodityListModel.m
//  RideHousekeeper
//
//  Created by Apple on 2020/3/11.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import "CommodityListModel.h"

@implementation CommodityListModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"commodities" : ServiceCommoity.class };
}
@end
