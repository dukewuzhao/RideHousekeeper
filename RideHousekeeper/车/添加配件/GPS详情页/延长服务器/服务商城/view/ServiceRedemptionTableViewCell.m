//
//  ServiceRedemptionTableViewCell.m
//  RideHousekeeper
//
//  Created by Apple on 2020/3/11.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import "ServiceRedemptionTableViewCell.h"

@implementation ServiceRedemptionTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        _mainIcon = [[UIImageView alloc] init];
        _mainIcon.backgroundColor = [QFTools colorWithHexString:@"#06C1AE"];
        _mainIcon.layer.cornerRadius = 10;
        [self.contentView addSubview:_mainIcon];
        [_mainIcon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(25);
            make.centerY.equalTo(self.contentView);
            make.size.mas_equalTo(CGSizeMake(97, 63));
        }];
        
        _mainTitle = [[UILabel alloc] init];
        _mainTitle.text = @"服务兑换卡充值";
        _mainTitle.font = FONT_PINGFAN(14);
        _mainTitle.textColor = [QFTools colorWithHexString:@"#333333"];
        [self.contentView addSubview:_mainTitle];
        [_mainTitle mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_mainIcon.mas_right).offset(10);
            make.bottom.equalTo(self.contentView.mas_centerY).offset(-2);
            make.height.mas_equalTo(20);
        }];
        
        _usageLab = [[UILabel alloc] init];
        _usageLab.text = @"适合购买实体兑换卡方式";
        _usageLab.font = FONT_PINGFAN(11);
        _usageLab.textColor = [QFTools colorWithHexString:@"#666666"];
        [self.contentView addSubview:_usageLab];
        [_usageLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_mainTitle);
            make.top.equalTo(self.contentView.mas_centerY).offset(2);
            make.height.mas_equalTo(16);
        }];
        
        UIImageView *arrow = [[UIImageView alloc] init];
        arrow.image = [UIImage imageNamed:@"arrow"];
        [self.contentView addSubview:arrow];
        [arrow mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView).offset(-10);
            make.centerY.equalTo(self.contentView);
        }];
        
    }
    return self;
}

@end
