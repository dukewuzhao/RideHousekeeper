//
//  OrderListModel.h
//  RideHousekeeper
//
//  Created by Apple on 2020/3/12.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OrderListModel : NSObject

@property(nonatomic,assign) NSInteger count;
@property(nonatomic,assign) NSInteger offset;
@property(nonatomic,copy) NSArray* orders;
@property(nonatomic,assign) NSInteger total;

@end

NS_ASSUME_NONNULL_END
