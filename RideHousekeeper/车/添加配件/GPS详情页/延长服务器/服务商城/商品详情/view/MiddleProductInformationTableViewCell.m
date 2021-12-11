//
//  MiddleProductInformationTableViewCell.m
//  RideHousekeeper
//
//  Created by Apple on 2020/3/12.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import "MiddleProductInformationTableViewCell.h"

@implementation MiddleProductInformationTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        UIView *backView = [[UIView alloc] init];
        [self.contentView addSubview:backView];
        [backView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(20);
            make.centerX.equalTo(self.contentView.mas_centerX);
            make.top.equalTo(self.contentView).offset(5);
            make.centerY.equalTo(self.contentView.mas_centerY);
            make.height.mas_equalTo(65).priorityHigh();
        }];
        
        backView.layer.masksToBounds = YES;
        backView.layer.cornerRadius = 10;
        backView.layer.borderWidth = 0.5;
        backView.layer.borderColor = [QFTools colorWithHexString:@"#cccccc"].CGColor;
        
        _durationLab = [[UILabel alloc] init];
        _durationLab.text = @"180天";
        _durationLab.textColor = [QFTools colorWithHexString:@"#333333"];
        _durationLab.font = FONT_PINGFAN(14);
        [backView addSubview:_durationLab];
        [_durationLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(backView).offset(9);
            make.centerY.equalTo(backView.mas_centerY);
            make.height.mas_equalTo(23).priorityHigh();
        }];
        
        _titleLab = [[UILabel alloc] init];
        _titleLab.text = @"骑管家平台GPS服务";
        _titleLab.textColor = [QFTools colorWithHexString:@"#333333"];
        _titleLab.font = FONT_PINGFAN(12);
        [backView addSubview:_titleLab];
        [_titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_durationLab.mas_right).offset(25);
            make.bottom.equalTo(backView.mas_centerY).offset(-2);
            make.height.mas_equalTo(17).priorityHigh();
        }];
        
        _detailLab = [[UILabel alloc] init];
        _detailLab.text = @"用于车辆定位，GPS数据上传，车辆追踪，远程控制";
        _detailLab.textColor = [QFTools colorWithHexString:@"#666666"];
        _detailLab.font = FONT_PINGFAN(11);
        [backView addSubview:_detailLab];
        [_detailLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_titleLab);
            make.top.equalTo(backView.mas_centerY).offset(2);
            make.height.mas_equalTo(16).priorityHigh();
        }];
    }
    return self;
}

@end
