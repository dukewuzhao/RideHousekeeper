//
//  ServiceSelectionCardView.m
//  RideHousekeeper
//
//  Created by Apple on 2020/3/16.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import "ServiceSelectionCardView.h"

@implementation ServiceSelectionCardView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        _titleLab = [[UILabel alloc] init];
        _titleLab.font = FONT_PINGFAN(17);
        _titleLab.textColor = [QFTools colorWithHexString:@"#ffffff"];
        [self addSubview:_titleLab];
        [_titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(26);
            make.left.equalTo(self).offset(29);
            make.height.mas_equalTo(24);
        }];
        
        _subtitleLab = [[UILabel alloc] init];
        _subtitleLab.font = FONT_PINGFAN(17);
        _subtitleLab.textColor = [QFTools colorWithHexString:@"#ffffff"];
        [self addSubview:_subtitleLab];
        [_subtitleLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_titleLab.mas_bottom);
            make.left.equalTo(_titleLab);
            make.height.mas_equalTo(16);
        }];
        
        _enterLab = [[UILabel alloc] init];
        _enterLab.layer.masksToBounds = YES;
        _enterLab.layer.cornerRadius = 12;
        _enterLab.font = FONT_PINGFAN(17);
        _enterLab.textAlignment = NSTextAlignmentCenter;
        _enterLab.textColor = [QFTools colorWithHexString:@"#ffffff"];
        _enterLab.text = @"进入";
        [self addSubview:_enterLab];
        [_enterLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_subtitleLab.mas_bottom).offset(20);
            make.left.equalTo(_titleLab);
            make.width.mas_equalTo(60);
            make.height.mas_equalTo(24);
        }];
        
        _icon = [[UIImageView alloc] init];
        [self addSubview:_icon];
        [_icon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.right.equalTo(self).offset(-10);
            
        }];
    }
    return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (self.action) self.action();
}

@end
