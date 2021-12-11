//
//  HeadPriceTableViewCell.h
//  RideHousekeeper
//
//  Created by Apple on 2020/3/12.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HeadPriceTableViewCell : UITableViewCell

@property(nonatomic,strong) UIImageView *icon;
@property(nonatomic,strong) UILabel *titleLab;
@property(nonatomic,strong) UILabel *currentPriceLab;
@property(nonatomic,strong) UILabel *originalPriceLab;
@end

NS_ASSUME_NONNULL_END
