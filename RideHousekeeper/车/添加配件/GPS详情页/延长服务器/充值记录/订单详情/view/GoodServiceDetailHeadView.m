//
//  GoodServiceDetailHeadView.m
//  RideHousekeeper
//
//  Created by Apple on 2020/3/13.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import "GoodServiceDetailHeadView.h"

@implementation GoodServiceDetailHeadView

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        _icon = [[UIImageView alloc] init];
        _icon.image = [UIImage imageNamed:@"discounted_good_icon"];
        _icon.layer.cornerRadius = 10;
        [self addSubview:_icon];
        [_icon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(15);
            make.bottom.equalTo(self);
            make.size.mas_equalTo(CGSizeMake(73, 50));
        }];
        
        _titleLab = [[UILabel alloc] init];
        _titleLab.text = @"GPS服务包半年";
        _titleLab.textColor = [QFTools colorWithHexString:@"#333333"];
        _titleLab.font = FONT_PINGFAN(13);
        [self addSubview:_titleLab];
        [_titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_icon.mas_right).offset(10);
            make.bottom.equalTo(self.mas_centerY);
            make.height.mas_equalTo(18);
        }];
        
        _descriptionLab = [[UILabel alloc] init];
        _descriptionLab.numberOfLines = 0;
        _descriptionLab.text = @"GPS流量包";
        _descriptionLab.textColor = [QFTools colorWithHexString:@"#999999"];
        _descriptionLab.font = FONT_PINGFAN(10);
        [self addSubview:_descriptionLab];
        [_descriptionLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_titleLab);
            make.right.equalTo(self.mas_right).offset(-10);
            make.top.equalTo(_titleLab.mas_bottom).offset(5);
            //make.height.mas_equalTo(14);
        }];
        
        _numLab = [[UILabel alloc] init];
        _numLab.text = @"×1";
        _numLab.textColor = [QFTools colorWithHexString:@"#666666"];
        _numLab.font = FONT_PINGFAN(10);
        [self addSubview:_numLab];
        [_numLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).offset(-10);
            make.centerY.equalTo(self);
            make.height.mas_equalTo(14);
        }];
    }
    return self;
}

@end
