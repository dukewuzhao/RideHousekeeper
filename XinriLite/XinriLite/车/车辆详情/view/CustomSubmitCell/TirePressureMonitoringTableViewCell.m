//
//  TirePressureMonitoringTableViewCell.m
//  RideHousekeeper
//
//  Created by Apple on 2018/12/3.
//  Copyright © 2018年 Duke Wu. All rights reserved.
//

#import "TirePressureMonitoringTableViewCell.h"

@implementation TirePressureMonitoringTableViewCell

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
            make.centerY.equalTo(self.mas_centerY);
            make.height.mas_equalTo(20);
        }];
        
        _swit = [[UISwitch alloc]init];
        _swit.onTintColor = [QFTools colorWithHexString:NSLocalizedString(@"VCControlColor", nil)];
        _swit.backgroundColor=[UIColor grayColor];
        _swit.thumbTintColor=[UIColor whiteColor];
        _swit.layer.masksToBounds = YES;
        _swit.layer.cornerRadius = 15;
        [self.contentView addSubview:_swit];
        [_swit mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).offset(-20);
            make.centerY.equalTo(self.mas_centerY);
        }];
        
    }
    return self;
}

@end
