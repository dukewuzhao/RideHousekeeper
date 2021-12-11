//
//  ShoppingTableViewCell.m
//  RideHousekeeper
//
//  Created by Apple on 2020/3/10.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import "ShoppingTableViewCell.h"

@implementation ShoppingTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        _mainIcon = [[UIImageView alloc] init];
        _mainIcon.backgroundColor = [QFTools colorWithHexString:@"#06C1AE"];
        _mainIcon.layer.cornerRadius = 10;
        [self.contentView addSubview:_mainIcon];
        [_mainIcon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(25);
            make.top.equalTo(self.contentView).offset(10);
            make.size.mas_equalTo(CGSizeMake(97, 63));
        }];
        
        _mainTitle = [[UILabel alloc] init];
        _mainTitle.text = @"GPS服务包—90天";
        _mainTitle.font = FONT_PINGFAN(14);
        _mainTitle.textColor = [QFTools colorWithHexString:@"#333333"];
        [self.contentView addSubview:_mainTitle];
        [_mainTitle mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_mainIcon.mas_right).offset(10);
            make.top.equalTo(_mainIcon);
            make.height.mas_equalTo(20);
        }];
        
        _usageLab = [[UILabel alloc] init];
        _usageLab.numberOfLines = 0;
        _usageLab.text = @"适合服务包方式充值";
        _usageLab.font = FONT_PINGFAN(11);
        _usageLab.textColor = [QFTools colorWithHexString:@"#666666"];
        [self.contentView addSubview:_usageLab];
        [_usageLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_mainTitle);
            make.right.equalTo(self.contentView.mas_right).offset(-10);
            make.top.equalTo(_mainTitle.mas_bottom).offset(5);
            make.height.mas_equalTo(20);
        }];
        
        _promptLab = [[UILabel alloc] init];
        _promptLab.textAlignment = NSTextAlignmentCenter;
        _promptLab.text = @"省";
        _promptLab.font = FONT_PINGFAN(9);
        _promptLab.textColor = [QFTools colorWithHexString:@"#06C1AE"];
        _promptLab.layer.borderWidth = 0.5;
        _promptLab.layer.borderColor = [[QFTools colorWithHexString:@"#06C1AE"] CGColor];
        [self.contentView addSubview:_promptLab];
        [_promptLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_usageLab);
            make.top.equalTo(_usageLab.mas_bottom).offset(5);
            make.size.mas_equalTo(CGSizeMake(15, 17));
        }];
        
        _savePriceLab = [[UILabel alloc] init];
        _savePriceLab.text = @"立省40.1元，1天低至0.4元";
        _savePriceLab.font = FONT_PINGFAN(10);
        _savePriceLab.textColor = [QFTools colorWithHexString:@"#666666"];
        [self.contentView addSubview:_savePriceLab];
        [_savePriceLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_promptLab.mas_right).offset(5);
            make.top.equalTo(_usageLab.mas_bottom).offset(5);
            make.height.mas_equalTo(14);
        }];
        
        _currentPriceLab = [[UILabel alloc] init];
        _currentPriceLab.text = @"¥49.9";
        _currentPriceLab.font = FONT_ZITI(20);
        _currentPriceLab.textColor = [QFTools colorWithHexString:@"#FF5E00"];
        [self.contentView addSubview:_currentPriceLab];
        [_currentPriceLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_mainTitle);
            make.bottom.equalTo(self.contentView).offset(-12);
            make.height.mas_equalTo(20);
        }];
        
        _originalPriceLab = [[UILabel alloc] init];
        _originalPriceLab.text = @"¥60";
        _originalPriceLab.font = FONT_PINGFAN(10);
        _originalPriceLab.textColor = [QFTools colorWithHexString:@"#666666"];
        [self.contentView addSubview:_originalPriceLab];
        [_originalPriceLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_currentPriceLab.mas_right).offset(5);
            make.bottom.equalTo(_currentPriceLab.mas_bottom);
            make.height.mas_equalTo(10);
        }];
        
        UIButton *btn = [[UIButton alloc] init];
        btn.backgroundColor = [QFTools colorWithHexString:@"#06C1AE"];
        [btn setTitle:@"查看详情" forState:UIControlStateNormal];
        btn.titleLabel.font = FONT_PINGFAN(10);
        btn.titleLabel.textColor = [UIColor whiteColor];
        btn.layer.cornerRadius = 10;
        [self.contentView addSubview:btn];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView).offset(-20);
            make.bottom.equalTo(self.contentView).offset(-12);
            make.size.mas_equalTo(CGSizeMake(58, 20));
        }];
        @weakify(self);
        [[btn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            if (self.clickBtn) self.clickBtn();
        }];
    }
    return self;
}

@end
