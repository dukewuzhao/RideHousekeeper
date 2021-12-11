//
//  HeadPriceTableViewCell.m
//  RideHousekeeper
//
//  Created by Apple on 2020/3/12.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import "HeadPriceTableViewCell.h"

@implementation HeadPriceTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        _icon = [[UIImageView alloc] init];
        _icon.image = [UIImage imageNamed:@"discounted_good_icon"];
        [self.contentView addSubview:_icon];
        [_icon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(10);
            make.left.equalTo(self.contentView).offset(15);
            make.width.mas_equalTo(ScreenWidth - 30);
            make.height.mas_equalTo(_icon.mas_width).multipliedBy(.65).priorityHigh();
        }];
        
        _titleLab = [[UILabel alloc] init];
        _titleLab.numberOfLines = 0;
        _titleLab.text = @"GPS平台服务半年包";
        _titleLab.textColor = [QFTools colorWithHexString:@"#333333"];
        _titleLab.font = FONT_PINGFAN(17);
        [self.contentView addSubview:_titleLab];
        [_titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_icon).offset(5);
            make.right.equalTo(self.contentView).offset(-20);
            make.top.equalTo(_icon.mas_bottom).offset(10).priorityHigh();
            //make.height.mas_equalTo(24);
        }];

        _currentPriceLab = [[UILabel alloc] init];
        _currentPriceLab.text = @"￥99.9";
        _currentPriceLab.textColor = [QFTools colorWithHexString:@"#FF5E00"];
        _currentPriceLab.font = FONT_ZITI(20);
        [self.contentView addSubview:_currentPriceLab];
        [_currentPriceLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_titleLab);
            make.top.equalTo(_titleLab.mas_bottom).offset(10);
            make.height.mas_equalTo(20).priorityHigh();
            make.bottom.equalTo(@-30);
        }];

        _originalPriceLab = [[UILabel alloc] init];
        _originalPriceLab.text = @"￥120";
        _originalPriceLab.textColor = [QFTools colorWithHexString:@"#666666"];
        _originalPriceLab.font = FONT_PINGFAN(10);
        [self.contentView addSubview:_originalPriceLab];
        [_originalPriceLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_currentPriceLab.mas_right).offset(6);
            make.bottom.equalTo(_currentPriceLab.mas_bottom);
            make.height.mas_equalTo(14).priorityHigh();
        }];
    }
    return self;
}

@end
