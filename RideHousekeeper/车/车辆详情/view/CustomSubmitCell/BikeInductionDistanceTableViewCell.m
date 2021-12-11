//
//  BikeInductionDistanceTableViewCell.m
//  RideHousekeeper
//
//  Created by Apple on 2017/12/29.
//  Copyright © 2017年 Duke Wu. All rights reserved.
//

#import "BikeInductionDistanceTableViewCell.h"

@implementation BikeInductionDistanceTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        _Icon = [[UIImageView alloc] init];
        _Icon.image = [UIImage imageNamed:@"icon_p4"];
        [self.contentView addSubview:_Icon];
        [_Icon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(15);
            make.top.equalTo(self.mas_top).offset(7.5);
            make.size.mas_equalTo(CGSizeMake(25, 25));
        }];
        
        _nameLab = [[UILabel alloc] init];
        _nameLab.textColor = [QFTools colorWithHexString:@"#111111"];
        _nameLab.textAlignment = NSTextAlignmentLeft;
        _nameLab.font = [UIFont systemFontOfSize:15];
        [self.contentView addSubview:_nameLab];
        [_nameLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_Icon.mas_right).offset(15);
            make.top.equalTo(self.mas_top).offset(10);
            make.height.mas_equalTo(20);
        }];
        
        _swit = [[UISwitch alloc]init];
        _swit.onTintColor = [QFTools colorWithHexString:MainColor];
        _swit.backgroundColor=[UIColor grayColor];
        _swit.thumbTintColor=[UIColor whiteColor];
        _swit.layer.masksToBounds = YES;
        _swit.layer.cornerRadius = 15;
        [self.contentView addSubview:_swit];
        [_swit mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).offset(-15);
            make.top.equalTo(self.mas_top).offset(7.5);
        }];
        
        _slider = [[LianUISlider alloc] init];
//        _slider.minimumTrackTintColor=[UIColor whiteColor];//滑轮左边颜色如果设置了左边的图片就不会显示
//        _slider.maximumTrackTintColor = [UIColor redColor];//滑轮右边颜色如果设置了右边的图片就不会显示
//        _slider.thumbTintColor=[UIColor whiteColor];//设置了滑轮的颜色如果设置了滑轮的样式图片就不会显示
        [_slider setThumbImage:[UIImage imageNamed:@"slideimage"] forState:UIControlStateHighlighted];
        [_slider setThumbImage:[UIImage imageNamed:@"slideimage"] forState:UIControlStateNormal];
        [_slider setMinimumTrackImage:[UIImage imageNamed:@"max"] forState:UIControlStateNormal];
        [_slider setMaximumTrackImage:[UIImage imageNamed:@"min"] forState:UIControlStateNormal];
        [self.contentView addSubview:_slider];
        [_slider mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_Icon.mas_right).offset(20);
            make.top.equalTo(_Icon.mas_bottom).offset(2);
            make.size.mas_equalTo(CGSizeMake(ScreenWidth - 120, 20));
        }];
        
        _weak = [[UILabel alloc] init];
        _weak.text = @"近";
        _weak.textAlignment = NSTextAlignmentCenter;
        _weak.textColor = [QFTools colorWithHexString:@"999999"];
        _weak.font = [UIFont systemFontOfSize:13];
        [self.contentView addSubview:_weak];
        [_weak mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_slider);
            make.top.equalTo(_slider.mas_bottom).offset(5);
        }];
        
        _strong = [[UILabel alloc] init];
        _strong.text = @"远";
        _strong.textColor = [QFTools colorWithHexString:@"999999"];
        _strong.font = [UIFont systemFontOfSize:13];
        _strong.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_strong];
        [_strong mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(_slider.mas_right);
            make.top.equalTo(_slider.mas_bottom).offset(5);
            make.size.mas_equalTo(CGSizeMake(40, 15));
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
