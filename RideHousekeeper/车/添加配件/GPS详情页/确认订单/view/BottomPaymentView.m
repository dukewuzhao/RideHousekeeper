//
//  BottomPaymentView.m
//  RideHousekeeper
//
//  Created by Apple on 2020/3/11.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import "BottomPaymentView.h"

@implementation BottomPaymentView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        UIView *backView = [[UIView alloc] init];
        backView.backgroundColor = [QFTools colorWithHexString:@"#555555"];
        [self addSubview:backView];
        [backView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self);
            make.top.bottom.equalTo(self);
            make.right.equalTo(self);
        }];

        _currentPriceLab = [[UILabel alloc] init];
        _currentPriceLab.textColor = [UIColor whiteColor];
        _currentPriceLab.font = FONT_PINGFAN(20);
        _currentPriceLab.text = @"￥0";
        _currentPriceLab.textAlignment = NSTextAlignmentCenter;
        [backView addSubview:_currentPriceLab];
        [_currentPriceLab mas_makeConstraints:^(MASConstraintMaker *make) {

            make.left.equalTo(backView).offset(30);
            make.centerY.equalTo(backView);
            make.height.mas_equalTo(28);
        }];

        _savePriceLab = [[UILabel alloc] init];
        _savePriceLab.textColor = [QFTools colorWithHexString:@"#CCCCCC"];
        _savePriceLab.font = FONT_PINGFAN(9);
        _savePriceLab.text = @"已优惠￥0";
        _savePriceLab.textAlignment = NSTextAlignmentCenter;
        [backView addSubview:_savePriceLab];
        [_savePriceLab mas_makeConstraints:^(MASConstraintMaker *make) {

            make.left.equalTo(_currentPriceLab.mas_right).offset(10);
            make.centerY.equalTo(backView);
            make.height.mas_equalTo(13);
        }];

        UIButton *buyBtn = [[UIButton alloc] init];
        buyBtn.layer.cornerRadius = 33;
        buyBtn.backgroundColor = [QFTools colorWithHexString:@"#06C1AE"];
        [buyBtn setTitle:@"立即购买" forState:UIControlStateNormal];
        [buyBtn setTitleColor:[QFTools colorWithHexString:@"#FFFFFF"] forState:UIControlStateNormal];
        buyBtn.titleLabel.font = FONT_PINGFAN(17);
        [backView addSubview:buyBtn];
        [buyBtn mas_makeConstraints:^(MASConstraintMaker *make) {

            make.right.equalTo(backView).offset(1);
            make.top.bottom.equalTo(backView);
            make.width.mas_equalTo(130);
        }];
        @weakify(self);
        [[buyBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            if(self.selectAction) self.selectAction();
        }];
        
        [self layoutIfNeeded];

        backView.layer.cornerRadius = 5;
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:backView.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(33, 33)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = backView.bounds;
        maskLayer.path = maskPath.CGPath;
        backView.layer.mask = maskLayer;
        
    }
    return self;
}

@end
