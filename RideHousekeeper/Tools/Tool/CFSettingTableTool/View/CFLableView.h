//
//  CFLableView.h
//  RideHousekeeper
//
//  Created by Apple on 2019/11/1.
//  Copyright © 2019 Duke Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CFLableView : UIView

/** 文本内容 */
@property(nonatomic,copy)NSString* text;

/** cell右边Label字体 */
@property (nonatomic, strong) UIFont *rightLabelFont;

/** cell右边Label字体颜色 */
@property (nonatomic, strong) UIColor *rightLabelFontColor;

@end

NS_ASSUME_NONNULL_END
