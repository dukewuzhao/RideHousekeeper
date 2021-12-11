//
//  PayChannelSelectTableViewCell.m
//  RideHousekeeper
//
//  Created by Apple on 2020/3/18.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import "PayChannelSelectTableViewCell.h"

@implementation PayChannelSelectTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        _icon = [[UIImageView alloc] init];
        _icon.image = [UIImage imageNamed:@"discounted_good_icon"];
        _icon.layer.cornerRadius = 10;
        [self.contentView addSubview:_icon];
        [_icon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(20);
            make.centerY.equalTo(self.contentView);
            make.size.mas_equalTo(CGSizeMake(25, 25));
        }];
        
        _titleLab = [[UILabel alloc] init];
        _titleLab.text = @"GPS服务包半年";
        _titleLab.textColor = [QFTools colorWithHexString:@"#333333"];
        _titleLab.font = FONT_PINGFAN(13);
        [self.contentView addSubview:_titleLab];
        [_titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_icon.mas_right).offset(20);
            make.centerY.equalTo(self.contentView.mas_centerY);
            make.height.mas_equalTo(18);
        }];
        
        _selectBtn = [[UIButton alloc] init];
        [self.contentView addSubview:_selectBtn];
        [_selectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView).offset(-20);
            make.centerY.equalTo(self.contentView);
            make.size.mas_equalTo(CGSizeMake(30, 30));
        }];
        @weakify(self);
        [[_selectBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            if (self.selectBlock) self.selectBlock();
//            UIButton *btn = x;
//            btn.selected = !btn.selected;
        }];
    }
    return self;
}

@end
