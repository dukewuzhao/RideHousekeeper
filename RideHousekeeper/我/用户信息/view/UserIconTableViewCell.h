//
//  UserIconTableViewCell.h
//  RideHousekeeper
//
//  Created by Apple on 2018/11/29.
//  Copyright © 2018年 Duke Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UserIconTableViewCell : UITableViewCell
@property(nonatomic,strong)UILabel *name;
@property(nonatomic,strong)UIImageView *userIcon;
@property(nonatomic,strong)UIImageView *arrow;
@end

NS_ASSUME_NONNULL_END
