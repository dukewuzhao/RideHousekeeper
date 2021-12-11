//
//  TrackSwitchView.m
//  RideHousekeeper
//
//  Created by Apple on 2020/3/5.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import "TrackSwitchView.h"
@interface TrackSwitchView ()
@property(nonatomic,strong)UIView *lineView;
@property (nonatomic,weak) UIButton *selectBtn;
@end
@implementation TrackSwitchView


- (instancetype)initWithFrame:(CGRect)frame{
    if (self == [super initWithFrame:frame]) {
//        self.layer.cornerRadius = 5;
//        self.layer.masksToBounds = YES;
        
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(5, 5)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = self.bounds;
        maskLayer.path = maskPath.CGPath;
        self.layer.mask = maskLayer;
        
        self.backgroundColor = [UIColor whiteColor];
        UIButton *trackBtn = [[UIButton alloc] init];
        trackBtn.tag = 1;
        [trackBtn setTitle:@"轨迹" forState:UIControlStateNormal];
        [trackBtn setTitleColor:[QFTools colorWithHexString:MainColor] forState:UIControlStateSelected];
        [trackBtn setTitleColor:[QFTools colorWithHexString:@"#333333"] forState:UIControlStateNormal];
        trackBtn.titleLabel.font = FONT_PINGFAN(16);
        [trackBtn addTarget:self action:@selector(clickEvent:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:trackBtn];
        
        UIButton *allEventsBtn = [[UIButton alloc] init];
        allEventsBtn.tag = 2;
        [allEventsBtn setTitle:@"全部事件" forState:UIControlStateNormal];
        [allEventsBtn setTitleColor:[QFTools colorWithHexString:MainColor] forState:UIControlStateSelected];
        [allEventsBtn setTitleColor:[QFTools colorWithHexString:@"#333333"] forState:UIControlStateNormal];
        allEventsBtn.titleLabel.font = FONT_PINGFAN(16);
        [allEventsBtn addTarget:self action:@selector(clickEvent:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:allEventsBtn];
        
        [@[trackBtn,allEventsBtn] mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:0 leadSpacing:0 tailSpacing:0];
        [@[trackBtn,allEventsBtn] mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(2);
            make.bottom.equalTo(self).offset(-2);
        }];
        
        _lineView = [[UIView alloc] initWithFrame:CGRectMake(0, self.height - 1, self.width/2, 1)];
        _lineView.backgroundColor = [QFTools colorWithHexString:MainColor];
        [self addSubview:_lineView];
        
        UIView *verticalLineView = [[UIView alloc] init];
        verticalLineView.backgroundColor = [QFTools colorWithHexString:@"#cccccc"];
        [self addSubview:verticalLineView];
        [verticalLineView mas_makeConstraints:^(MASConstraintMaker *make) {

            make.centerX.equalTo(self);
            make.top.bottom.equalTo(self);
            make.width.mas_equalTo(0.5);
        }];
        
        
    }
    return self;
}



-(void)clickEvent:(UIButton *)btn{
    if (btn.tag == 1) {
        
        [UIView animateWithDuration:0.3 animations:^{
            _lineView.transform = CGAffineTransformMakeTranslation(0, 0);
        }];
        
    }else if (btn.tag == 2){
        [UIView animateWithDuration:0.3 animations:^{
            _lineView.transform = CGAffineTransformMakeTranslation(self.width/2, 0);
        }];
    }
    
    self.selectBtn.selected = NO;
    btn.selected = YES;
    self.selectBtn = btn;
    
    if (self.selectCode) {
        self.selectCode(btn.tag);
    }
    
}

#pragma mark - 使传入的对应索引数的按钮选中
- (void)setSelectedSegmentIndex:(int)selectedSegmentIndex
{
    if (selectedSegmentIndex < 0 || selectedSegmentIndex >= self.subviews.count) return;
    
    UIButton *btn = self.subviews[selectedSegmentIndex];
    [self clickEvent:btn];
}

- (int)selectedSegmentIndex
{
    return (int)self.selectBtn.tag;
}

@end
