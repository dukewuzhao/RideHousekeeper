//
//  GPSDetectionProcessingView.m
//  RideHousekeeper
//
//  Created by Apple on 2020/3/25.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import "GPSDetectionProcessingView.h"

@implementation GPSDetectionProcessingView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        
        UIButton *leftBtn = [[UIButton alloc] init];
        [leftBtn setImage:[UIImage imageNamed:@"stop_gps_binding"] forState:UIControlStateNormal];
        [self addSubview:leftBtn];
        [leftBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.top.equalTo(self).offset(22+KStatusBarMargin);
            make.size.mas_equalTo(CGSizeMake(50, 40));
        }];
        @weakify(self);
        [[leftBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            if(self.btnClick) self.btnClick();
        }];
        
        _titleLab = [[UILabel alloc] init];
        _titleLab.font = FONT_PINGFAN_BOLD(18);
        _titleLab.textColor = [QFTools colorWithHexString:@"111111"];
        _titleLab.text = @"未找到车辆设备";
        [self addSubview:_titleLab];
        [_titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(74);
            make.centerX.equalTo(self);
            make.height.mas_equalTo(25);
        }];
        
        _headView = [[UIImageView alloc] init];
        [self addSubview:_headView];
        [_headView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_titleLab.mas_bottom).offset(30);
            make.left.equalTo(self).offset(84);
            make.right.equalTo(self).offset(-84);
            make.height.equalTo(_headView.mas_width).multipliedBy(1.0);
        }];
        
        _mobileTitle = [[UILabel alloc] init];
        _mobileTitle.textColor = [UIColor blackColor];
        _mobileTitle.font = FONT_PINGFAN(16);
        _mobileTitle.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_mobileTitle];
        [_mobileTitle mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_headView.mas_bottom).offset(20);
            make.centerX.equalTo(self);
            make.left.equalTo(self).offset(10);
        }];
        
        _promptTitle = [[YYLabel alloc] init];
        _promptTitle.textColor = [QFTools colorWithHexString:@"#333333"];
        _promptTitle.font = FONT_PINGFAN(14);
        _promptTitle.numberOfLines = 0;
        _promptTitle.textAlignment = NSTextAlignmentCenter;
        //_promptTitle.textVerticalAlignment = YYTextVerticalAlignmentCenter;
        _promptTitle.preferredMaxLayoutWidth = ScreenWidth - 20; //设置最大的宽度
        _promptTitle.text = @"请检查\n车辆是否处于网络覆盖良好区域\n车辆是否处于空旷地带，避免建筑物遮挡";
        [self addSubview:_promptTitle];
        [_promptTitle mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_mobileTitle.mas_bottom).offset(10);
            make.centerX.equalTo(self);
            make.left.equalTo(self).offset(10);
        }];
        
       _scanAgainBtn = [[UIButton alloc] init];
       [_scanAgainBtn setTitle:@"确定" forState:UIControlStateNormal];
       [_scanAgainBtn setTitleColor:[QFTools colorWithHexString:MainColor] forState:UIControlStateNormal];
       _scanAgainBtn.backgroundColor = [UIColor whiteColor];
       _scanAgainBtn.contentMode = UIViewContentModeCenter;
       [_scanAgainBtn.layer setCornerRadius:22.0]; // 切圆角
        _scanAgainBtn.layer.borderWidth = 1;
        _scanAgainBtn.layer.borderColor = [QFTools colorWithHexString:MainColor].CGColor;
       [self addSubview:_scanAgainBtn];
       [_scanAgainBtn mas_makeConstraints:^(MASConstraintMaker *make) {
           make.centerX.equalTo(self);
           make.bottom.equalTo(self.mas_bottom).offset(-40);
           make.size.mas_equalTo(CGSizeMake(214, 44));
       }];
        
        [[_scanAgainBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            if(self.restClick) self.restClick();
        }];
    }
    return self;
}



@end
