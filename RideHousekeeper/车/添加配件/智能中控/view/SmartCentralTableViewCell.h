//
//  SmartCentralTableViewCell.h
//  RideHousekeeper
//
//  Created by Apple on 2020/4/1.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SmartCentralTableViewCell : UITableViewCell

@property (strong, nonatomic) UILabel *nameLab;
@property (strong, nonatomic) UILabel *detailLab;
@property (strong, nonatomic) UIImageView *arrow;
@property (strong, nonatomic) UIImageView *upgrade_red_dot;

@end

NS_ASSUME_NONNULL_END
