//
//  PayChannelHeadView.h
//  RideHousekeeper
//
//  Created by Apple on 2020/3/18.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^PayChannelClickBlock)(BOOL select);
@interface PayChannelHeadView : UIView
@property(nonatomic,strong) UIImageView *icon;
@property(nonatomic,strong) UILabel *selectLab;
@property(nonatomic,strong) UIImageView *arrow;
@property(nonatomic,copy) PayChannelClickBlock payChannelClickBlock;
@end

NS_ASSUME_NONNULL_END
