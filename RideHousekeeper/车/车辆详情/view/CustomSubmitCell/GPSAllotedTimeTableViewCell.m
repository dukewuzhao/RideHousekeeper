//
//  GPSAllotedTimeTableViewCell.m
//  RideHousekeeper
//
//  Created by Apple on 2019/10/30.
//  Copyright © 2019 Duke Wu. All rights reserved.
//

#import "GPSAllotedTimeTableViewCell.h"

@implementation GPSAllotedTimeTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UILabel *titleLab = [[UILabel alloc] init];
        titleLab.text = @"激活日期";
        titleLab.textColor = [UIColor blackColor];
        titleLab.font = [UIFont systemFontOfSize:15];
        [self.contentView addSubview:titleLab];
        [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self).offset(-ScreenWidth/4);
            make.top.equalTo(self).offset(15);
            make.height.mas_equalTo(20);
        }];
        
        _activationTimeLab = [[UILabel alloc] init];
        _activationTimeLab.text = @"2018-3-18";
        _activationTimeLab.textColor = [QFTools colorWithHexString:MainColor];
        _activationTimeLab.font = [UIFont systemFontOfSize:15];
        [self.contentView addSubview:_activationTimeLab];
        [_activationTimeLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(titleLab.mas_centerX);
            make.top.equalTo(titleLab.mas_bottom).offset(5);
            make.height.mas_equalTo(20);
        }];
        
        UIView *line = [[UIView alloc] init];
        line.backgroundColor = [UIColor blackColor];
        [self.contentView addSubview:line];
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.top.equalTo(self).offset(10);
            make.bottom.equalTo(self).offset(-10);
            make.width.mas_equalTo(0.5);
        }];
        
        UILabel *lastLab = [[UILabel alloc] init];
        lastLab.text = @"剩余服务时间";
        lastLab.textColor = [UIColor blackColor];
        lastLab.font = [UIFont systemFontOfSize:15];
        [self.contentView addSubview:lastLab];
        [lastLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self).offset(ScreenWidth/4);
            make.top.equalTo(titleLab);
            make.height.mas_equalTo(20);
        }];
        
        _lastDateLab = [[UILabel alloc] init];
        _lastDateLab.text = @"120天";
        _lastDateLab.textColor = [QFTools colorWithHexString:MainColor];
        _lastDateLab.font = [UIFont systemFontOfSize:15];
        [self.contentView addSubview:_lastDateLab];
        [_lastDateLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(lastLab.mas_centerX);
            make.top.equalTo(_activationTimeLab);
            make.height.mas_equalTo(20);
        }];
        
        UIButton *RenewalFeeBtn = [[UIButton alloc] init];
        RenewalFeeBtn.layer.cornerRadius = 12.5;
        RenewalFeeBtn.layer.masksToBounds = YES;
        RenewalFeeBtn.backgroundColor = [QFTools colorWithHexString:@"#F5F5F5"];
        [RenewalFeeBtn setTitle:@"续费充值" forState:UIControlStateNormal];
        [RenewalFeeBtn setTitleColor:[QFTools colorWithHexString:MainColor] forState:UIControlStateNormal];
        RenewalFeeBtn.titleLabel.font = FONT_PINGFAN(13);
        [self.contentView addSubview:RenewalFeeBtn];
        [RenewalFeeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(lastLab.mas_centerX);
            make.bottom.equalTo(self).offset(-10);
            make.width.mas_equalTo(70);
            make.height.mas_equalTo(25);
        }];
        
        @weakify(self);
        [[RenewalFeeBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            if (self.renewalFeeBtnClick) self.renewalFeeBtnClick();
        }];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
