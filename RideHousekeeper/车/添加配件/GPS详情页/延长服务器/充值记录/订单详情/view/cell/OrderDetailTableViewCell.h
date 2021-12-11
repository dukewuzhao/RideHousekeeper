//
//  OrderDetailTableViewCell.h
//  RideHousekeeper
//
//  Created by Apple on 2020/3/13.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^UpdateCellHeight)(BOOL update);
typedef void(^SelectPayChannel)(NSInteger code);
typedef enum : NSUInteger {
    OrderWithHead,
    OrderWithOutHead,
    OrderWithOutPayChannel
} OrderType;

NS_ASSUME_NONNULL_BEGIN
@interface OrderDetailTableViewCell : UITableViewCell
@property(nonatomic,copy)UpdateCellHeight updateCellHeight;
@property(nonatomic,copy)SelectPayChannel selectPayChannel;
-(void)setOrderInfo:(ServiceOrder *)model type:(OrderType)type;
@end

NS_ASSUME_NONNULL_END
