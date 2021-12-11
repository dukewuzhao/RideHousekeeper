//
//  MJDIYHeader.m
//  MJRefreshExample
//
//  Created by MJ Lee on 15/6/13.
//  Copyright © 2015年 小码哥. All rights reserved.
//

#import "MJDIYHeader.h"

@interface MJDIYHeader()
@property (nonatomic,strong) LOTAnimationView *refreshAnimation;
@property (strong, nonatomic) UILabel *label;
@end

@implementation MJDIYHeader
#pragma mark - 重写方法
#pragma mark 在这里做一些初始化配置（比如添加子控件）
- (void)prepare
{
    [super prepare];
    
    // 设置控件的高度
    self.mj_h = 70;
    
    [self addSubview:self.refreshAnimation];
    
    [self addSubview:self.label];
    
    
}

-(LOTAnimationView *)refreshAnimation{
    if (!_refreshAnimation) {
        _refreshAnimation = [[LOTAnimationView alloc] init];
        _refreshAnimation.contentMode = UIViewContentModeScaleAspectFill;
        _refreshAnimation.animation = @"qgj_refresh";
        _refreshAnimation.loopAnimation = YES;
    }
    return _refreshAnimation;
}

-(UILabel *)label{
    
    if (!_label) {
        _label = [[UILabel alloc] init];
        _label.textColor = [UIColor whiteColor];
        _label.font = FONT_PINGFAN(12);
        _label.textAlignment = NSTextAlignmentCenter;
    }
    return _label;
}

#pragma mark 在这里设置子控件的位置和尺寸
- (void)placeSubviews
{
    [super placeSubviews];

    [self.refreshAnimation mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self).offset(5);
        make.size.mas_equalTo(CGSizeMake(50, 30));
    }];
    
    [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self.refreshAnimation.mas_bottom).offset(5);
    }];
}

#pragma mark 监听scrollView的contentOffset改变
- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change
{
    [super scrollViewContentOffsetDidChange:change];

}

#pragma mark 监听scrollView的contentSize改变
- (void)scrollViewContentSizeDidChange:(NSDictionary *)change
{
    [super scrollViewContentSizeDidChange:change];
    
}

#pragma mark 监听scrollView的拖拽状态改变
- (void)scrollViewPanStateDidChange:(NSDictionary *)change
{
    [super scrollViewPanStateDidChange:change];

}

#pragma mark 监听控件的刷新状态
- (void)setState:(MJRefreshState)state
{
    MJRefreshCheckState;

    switch (state) {
        case MJRefreshStateIdle:

            [self.refreshAnimation pause];
            self.label.text = @"下拉刷新";
            break;
        case MJRefreshStatePulling:
//            [self.loading stopAnimating];
            [self.refreshAnimation play];
            self.label.text = @"松开刷新";
            break;
        case MJRefreshStateRefreshing:
            [self.refreshAnimation play];
            self.label.text = @"正在刷新";
            //[self.loading startAnimating];
            break;
        default:
            break;
    }
}

#pragma mark 监听拖拽比例（控件被拖出来的比例）
//- (void)setPullingPercent:(CGFloat)pullingPercent
//{
//    [super setPullingPercent:pullingPercent];
//
//    // 1.0 0.5 0.0
//    // 0.5 0.0 0.5
//    CGFloat red = 1.0 - pullingPercent * 0.5;
//    CGFloat green = 0.5 - 0.5 * pullingPercent;
//    CGFloat blue = 0.5 * pullingPercent;
//    self.label.textColor = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
//}

@end
