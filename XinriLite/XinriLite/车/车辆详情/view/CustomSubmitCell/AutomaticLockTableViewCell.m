//
//  AutomaticLockTableViewCell.m
//  RideHousekeeper
//
//  Created by Apple on 2017/12/29.
//  Copyright © 2017年 Duke Wu. All rights reserved.
//

#import "AutomaticLockTableViewCell.h"

@implementation AutomaticLockTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        _Icon = [[UIImageView alloc] init];
        [self.contentView addSubview:_Icon];
        [_Icon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(13);
            make.centerY.equalTo(self.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(25, 25));
        }];
        
        _nameLab = [[UILabel alloc] init];
        _nameLab.textColor = [UIColor whiteColor];
        _nameLab.textAlignment = NSTextAlignmentLeft;
        _nameLab.font = [UIFont systemFontOfSize:15];
        [self.contentView addSubview:_nameLab];
        [_nameLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_Icon.mas_right).offset(15);
            make.top.equalTo(self).offset(7.5);
            make.height.mas_equalTo(20);
        }];
        
        _swit = [[UISwitch alloc] init];
        _swit.onTintColor = [QFTools colorWithHexString:NSLocalizedString(@"VCControlColor", nil)];
        _swit.backgroundColor=[UIColor grayColor];
        _swit.thumbTintColor=[UIColor whiteColor];
        _swit.layer.masksToBounds = YES;
        _swit.layer.cornerRadius = 15;
        [self.contentView addSubview:_swit];
        [_swit mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).offset(-20);
            make.top.equalTo(self).offset(2);
        }];
        
        
        _detailLab = [[UILabel alloc] init];
        _detailLab.textColor = [QFTools colorWithHexString:@"999999"];
        _detailLab.textAlignment = NSTextAlignmentLeft;
        _detailLab.font = [UIFont systemFontOfSize:9];
        _detailLab.numberOfLines = 0;
        [self.contentView addSubview:_detailLab];
        [_detailLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_nameLab.mas_left);
            make.top.equalTo(_nameLab.mas_bottom);
            make.right.equalTo(_swit.mas_left).offset(-2);
            make.bottom.equalTo(self.contentView);
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
