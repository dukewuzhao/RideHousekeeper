//
//  BindingView.h
//  NiuDingRideHousekeeper
//
//  Created by Apple on 2019/8/9.
//  Copyright © 2019 Duke Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AView;
NS_ASSUME_NONNULL_BEGIN
typedef void(^resetBindingClickBlock)();
@interface BindingView : UIView
@property(nonatomic,assign)BindingType bindingType;
@property(nonatomic,strong) AView *aView;
@property(nonatomic,strong) UIView *promptView;//中间的绑定提示
@property (nonatomic,copy) resetBindingClickBlock resetBindingBlock;
-(void)bndingfail;
-(instancetype)initWithFrame:(CGRect)frame bindType:(BindingType)type;
@end

NS_ASSUME_NONNULL_END
