//
//  bikeFunctionTableViewCell.m
//  RideHousekeeper
//
//  Created by Apple on 2017/12/29.
//  Copyright © 2017年 Duke Wu. All rights reserved.
//

#import "bikeFunctionTableViewCell.h"

@implementation bikeFunctionTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        _Icon = [[UIImageView alloc] init];
        [self.contentView addSubview:_Icon];
        [_Icon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(15);
            make.centerY.equalTo(self.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(25, 25));
        }];
        
        _nameLab = [[UILabel alloc] init];
        _nameLab.textColor = [QFTools colorWithHexString:@"#111111"];
        _nameLab.textAlignment = NSTextAlignmentLeft;
        _nameLab.font = [UIFont systemFontOfSize:15];
        [self.contentView addSubview:_nameLab];
        [_nameLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_Icon.mas_right).offset(15);
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
        //_upgrade_red_dot.layer.mask = [self UiviewRoundedRect:_upgrade_red_dot.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(5, 5)];
        _arrow = [[UIImageView alloc] init];
        _arrow.image = [UIImage imageNamed:@"arrow"];
        [self.contentView addSubview:_arrow];
        [_arrow mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).offset(-15);
            make.centerY.equalTo(self.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(8.4, 15));
        }];
        
        _detailLab = [[UILabel alloc] init];
        _detailLab.textAlignment = NSTextAlignmentRight;
        _detailLab.font = [UIFont systemFontOfSize:13];
        _detailLab.textColor = [QFTools colorWithHexString:@"999999"];
        [self.contentView addSubview:_detailLab];
        [_detailLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_lessThanOrEqualTo(-15);
            make.right.equalTo(_arrow.mas_left).offset(-5);
            make.centerY.equalTo(self.mas_centerY);
            make.height.mas_equalTo(20);
        }];
        
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
