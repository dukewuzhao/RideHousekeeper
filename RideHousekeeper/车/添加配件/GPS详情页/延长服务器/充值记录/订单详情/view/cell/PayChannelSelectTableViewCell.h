//
//  PayChannelSelectTableViewCell.h
//  RideHousekeeper
//
//  Created by Apple on 2020/3/18.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PayChannelSelectTableViewCell;
typedef void(^PayChannelSelectBlock)(void);
NS_ASSUME_NONNULL_BEGIN

@interface PayChannelSelectTableViewCell : UITableViewCell

@property(nonatomic,strong)UIImageView *icon;
@property(nonatomic,strong)UILabel *titleLab;
@property(nonatomic,strong)UIButton *selectBtn;
@property(nonatomic,copy)PayChannelSelectBlock selectBlock;
@end

NS_ASSUME_NONNULL_END
