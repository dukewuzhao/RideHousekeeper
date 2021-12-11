//
//  OrderListModel.m
//  RideHousekeeper
//
//  Created by Apple on 2020/3/12.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import "OrderListModel.h"

@implementation OrderListModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"orders" : ServiceOrder.class };
}
@end
