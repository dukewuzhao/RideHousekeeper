//
//  ServiceSelectionCardView.h
//  RideHousekeeper
//
//  Created by Apple on 2020/3/16.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^SelectAction)(void);
@interface ServiceSelectionCardView : UIView
@property(nonatomic,strong) UILabel *titleLab;
@property(nonatomic,strong) UILabel *subtitleLab;
@property(nonatomic,strong) UILabel *enterLab;
@property(nonatomic,strong) UIImageView *icon;
@property(nonatomic,copy) SelectAction action;
@end

NS_ASSUME_NONNULL_END
