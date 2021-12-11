//
//  CenterControlTableViewCell.m
//  RideHousekeeper
//
//  Created by Apple on 2019/10/22.
//  Copyright © 2019 Duke Wu. All rights reserved.
//

#import "CenterControlTableViewCell.h"

@implementation CenterControlTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        _title = [[UILabel alloc] init];
        _title.font = FONT_PINGFAN(16);
        [[self contentView] addSubview:_title];
        [_title mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(15);
            make.top.equalTo(self).offset(5);
            make.height.mas_equalTo(20);
        }];
        
        UIView *backView = [[UIView alloc] init];
        backView.backgroundColor = [UIColor whiteColor];
        backView.layer.cornerRadius = 10;
        backView.layer.masksToBounds = YES;
        [[self contentView] addSubview:backView];
        [backView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(15);
            make.top.equalTo(_title.mas_bottom).offset(10);
            make.right.equalTo(self).offset(-15);
            make.bottom.equalTo(self).offset(-5);
        }];
        
        _icon = [[UIImageView alloc] init];
        [backView addSubview:_icon];
        [_icon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(backView).offset(20);
            make.centerY.equalTo(backView);
        }];
        
        _deviceDesc = [[UILabel alloc] init];
        _deviceDesc.font = FONT_PINGFAN(15);
        _deviceDesc.textColor = [UIColor blackColor];
        [backView addSubview:_deviceDesc];
        [_deviceDesc mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_icon.mas_right).offset(26);
            make.bottom.equalTo(backView.mas_centerY);
            make.height.mas_equalTo(20);
        }];
        
        _brandLab = [[UILabel alloc] init];
        _brandLab.font = FONT_PINGFAN(13);
        _brandLab.textColor = [QFTools colorWithHexString:@"#666666"];
        [backView addSubview:_brandLab];
        [_brandLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_deviceDesc.mas_bottom).offset(5);
            make.left.equalTo(_deviceDesc);
            make.height.mas_equalTo(14);
        }];
        
        UIImageView *arrow = [[UIImageView alloc] init];
        arrow.image = [UIImage imageNamed:@"arrow"];
        [backView addSubview:arrow];
        [arrow mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(backView).offset(-10);
            make.centerY.equalTo(backView);
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
