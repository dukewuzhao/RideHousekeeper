//
//  CenterControlTableViewCell.h
//  RideHousekeeper
//
//  Created by Apple on 2019/10/22.
//  Copyright © 2019 Duke Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CenterControlTableViewCell : UITableViewCell

@property (nonatomic, strong) UILabel *title;
@property (nonatomic, strong) UIImageView *icon;
@property (nonatomic, strong) UILabel *deviceDesc;
@property (nonatomic, strong) UILabel *brandLab;

@end

NS_ASSUME_NONNULL_END
