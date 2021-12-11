//
//  UIControl+UIControl_button.h
//  RideHousekeeper
//
//  Created by Apple on 2020/4/14.
//  Copyright © 2020 Duke Wu. All rights reserved.
//



#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
#define defaultInterval .5//默认时间间隔
@interface UIControl (UIControl_button)
@property(nonatomic,assign)NSTimeInterval timeInterval;//用这个给重复点击加间隔
@property(nonatomic,assign)BOOL isIgnoreEvent;//YES不允许点击NO允许点击
@end

NS_ASSUME_NONNULL_END
