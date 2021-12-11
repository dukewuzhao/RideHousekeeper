//
//  BikeNameTableViewCell.m
//  RideHousekeeper
//
//  Created by Apple on 2017/12/29.
//  Copyright © 2017年 Duke Wu. All rights reserved.
//

#import "BikeNameTableViewCell.h"

@implementation BikeNameTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        _bikeimage = [[UIImageView alloc] init];
        _bikeimage.layer.masksToBounds = YES;
        _bikeimage.layer.cornerRadius = 25;
        _bikeimage.image = [UIImage imageNamed:@"default_logo"];
        [self.contentView addSubview:_bikeimage];
        [_bikeimage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(15);
            make.centerY.equalTo(self.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(50, 50));
        }];
        
        _nameLab = [[UILabel alloc] init];
        _nameLab.font = [UIFont systemFontOfSize:16];
        _nameLab.textColor = [QFTools colorWithHexString:@"#111111"];
        [self.contentView addSubview:_nameLab];
        [_nameLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_bikeimage.mas_right).offset(25);
            make.top.equalTo(_bikeimage);
            make.height.mas_equalTo(20);
        }];
        
        _usericon = [[UIImageView alloc] init];
        [self.contentView addSubview:_usericon];
        [_usericon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_nameLab.mas_left);
            make.top.equalTo(_nameLab.mas_bottom).offset(15);
            make.size.mas_equalTo(CGSizeMake(15, 15));
        }];
        
        
        _phone = [[UILabel alloc] init];
        _phone.textColor = [QFTools colorWithHexString:@"999999"];
        _phone.font = [UIFont systemFontOfSize:13];
        [self.contentView addSubview:_phone];
        [_phone mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_usericon.mas_right).offset(5);
            make.top.equalTo(_usericon);
            make.height.mas_equalTo(15);
        }];
        
        _modifyBtn = [[UIButton alloc] init];
        [self.contentView addSubview:_modifyBtn];
        [_modifyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).offset(-15);
            make.centerY.equalTo(self);
            make.size.mas_equalTo(CGSizeMake(50, 50));
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
