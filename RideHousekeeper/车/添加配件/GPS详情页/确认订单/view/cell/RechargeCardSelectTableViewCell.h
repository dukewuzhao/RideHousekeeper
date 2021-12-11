//
//  RechargeCardSelectTableViewCell.h
//  RideHousekeeper
//
//  Created by Apple on 2020/3/3.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^SelectRechargeCard)(NSInteger code);
@interface RechargeCardSelectTableViewCell : UITableViewCell
@property (nonatomic, copy)SelectRechargeCard selectPayChannel;
@end

NS_ASSUME_NONNULL_END
