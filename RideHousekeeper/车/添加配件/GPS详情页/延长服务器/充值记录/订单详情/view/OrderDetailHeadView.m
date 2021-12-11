//
//  OrderDetailHeadView.m
//  RideHousekeeper
//
//  Created by Apple on 2020/3/13.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import "OrderDetailHeadView.h"

@implementation OrderDetailHeadView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        UIView *mainView = [[UIView alloc] init];
        mainView.backgroundColor = [UIColor whiteColor];
        [self addSubview:mainView];
        [mainView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(15);
            make.right.equalTo(self).offset(-15);
            make.top.equalTo(self).offset(5);
            make.height.mas_equalTo(126);
        }];
        
        _payStatusImg = [[UIImageView alloc] init];
        [mainView addSubview:_payStatusImg];
        [_payStatusImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.top.equalTo(mainView).offset(10);
            make.size.mas_equalTo(CGSizeMake(50, 50));
        }];
        
        _promptLab = [[UILabel alloc] init];
        _promptLab.text = @"您的订单已提交，等待交付中，快去支付吧\n 超过30分钟未支付，订单将自动取消";
        _promptLab.textColor = [QFTools colorWithHexString:@"#333333"];
        _promptLab.font = FONT_PINGFAN(13);
        _promptLab.textAlignment = NSTextAlignmentCenter;
        _promptLab.numberOfLines = 0;
        [mainView addSubview:_promptLab];
        [_promptLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.top.equalTo(_payStatusImg.mas_bottom).offset(10);
            make.bottom.equalTo(mainView).offset(-16);
        }];
        
        UIButton *contactBtn = [[UIButton alloc] init];
        [contactBtn setImage:[UIImage imageNamed:@"order_customer_service_icon"] forState:UIControlStateNormal];
        [contactBtn setTitle:@"联系客服" forState:UIControlStateNormal];
        [contactBtn setTitleColor:[QFTools colorWithHexString:@"#999999"] forState:UIControlStateNormal];
        contactBtn.titleLabel.font = FONT_PINGFAN(13);
        [self addSubview:contactBtn];
        [contactBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.top.equalTo(mainView.mas_bottom);
            make.size.mas_equalTo(CGSizeMake(100, 33));
            make.bottom.equalTo(self);
        }];
        
        
    }
    return self;
}

@end
