//
//  TimingPaymentView.m
//  RideHousekeeper
//
//  Created by Apple on 2020/3/18.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import "TimingPaymentView.h"

@implementation TimingPaymentView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(10, 10)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = self.bounds;
        maskLayer.path = maskPath.CGPath;
        self.layer.mask = maskLayer;
        
        _totalPriceLab = [[UILabel alloc] init];
        _totalPriceLab.text = @"总计：99.9";
        _totalPriceLab.textColor = [QFTools colorWithHexString:@"#333333"];
        _totalPriceLab.font = FONT_PINGFAN(13);
        [self addSubview:_totalPriceLab];
        [_totalPriceLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.left.equalTo(self).offset(25);
            make.height.mas_equalTo(24);
        }];
        
        _payBtn = [[UIButton alloc] init];
        _payBtn.layer.cornerRadius = 20;
        [_payBtn setTitle:@"抢先支付 29 : 14" forState:UIControlStateNormal];
        [_payBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _payBtn.titleLabel.font = FONT_PINGFAN(13);
        _payBtn.backgroundColor = [QFTools colorWithHexString:@"#06C1AE"];
        [self addSubview:_payBtn];
        [_payBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.right.equalTo(self).offset(-25);
            make.size.mas_equalTo(CGSizeMake(150, 40));
        }];
        @weakify(self);
        [[_payBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            if (self.selectAction) {
                self.selectAction();
            }
        }];
        
    }
    return self;
}


@end
