//
//  SmartCentralTableViewCell.m
//  RideHousekeeper
//
//  Created by Apple on 2020/4/1.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import "SmartCentralTableViewCell.h"

@implementation SmartCentralTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _nameLab = [[UILabel alloc] init];
        _nameLab.textColor = [QFTools colorWithHexString:@"#111111"];
        _nameLab.textAlignment = NSTextAlignmentLeft;
        _nameLab.font = FONT_PINGFAN(17);
        [self.contentView addSubview:_nameLab];
        [_nameLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(10);
            make.centerY.equalTo(self.mas_centerY);
            make.height.mas_equalTo(20);
        }];
        
        _detailLab = [[UILabel alloc] init];
        _detailLab.textAlignment = NSTextAlignmentRight;
        _detailLab.font = FONT_PINGFAN(15);
        _detailLab.textColor = [QFTools colorWithHexString:@"999999"];
        [self.contentView addSubview:_detailLab];
        [_detailLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).offset(-25);
            make.centerY.equalTo(self.mas_centerY);
            make.height.mas_equalTo(20);
        }];
        
        _upgrade_red_dot = [[UIImageView alloc] init];
        _upgrade_red_dot.backgroundColor = [UIColor redColor];
        _upgrade_red_dot.layer.masksToBounds = YES;
        _upgrade_red_dot.layer.cornerRadius = 5;
        [self.contentView addSubview:_upgrade_red_dot];
        _upgrade_red_dot.hidden = YES;
        [_upgrade_red_dot mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_nameLab.mas_right).offset(-10);
            make.top.equalTo(self).offset(10);
            make.size.mas_equalTo(CGSizeMake(10, 10));
        }];
        
        _arrow = [[UIImageView alloc] init];
        _arrow.image = [UIImage imageNamed:@"arrow"];
        [self.contentView addSubview:_arrow];
        [_arrow mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).offset(-12);
            make.centerY.equalTo(self.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(8.4, 15));
        }];
    }
    return self;
}

@end
