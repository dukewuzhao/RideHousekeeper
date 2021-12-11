//
//  TirePressureMonitoringTableViewCell.h
//  RideHousekeeper
//
//  Created by Apple on 2018/12/3.
//  Copyright © 2018年 Duke Wu. All rights reserved.
//

#import <Foundation/Foundation.h>
@class TailSwitch;
NS_ASSUME_NONNULL_BEGIN

@interface TirePressureMonitoringTableViewCell : UITableViewCell

@property (strong, nonatomic) UIImageView *Icon;
@property (strong, nonatomic) UILabel *nameLab;
@property (strong, nonatomic) TailSwitch *swit;

@end

NS_ASSUME_NONNULL_END
