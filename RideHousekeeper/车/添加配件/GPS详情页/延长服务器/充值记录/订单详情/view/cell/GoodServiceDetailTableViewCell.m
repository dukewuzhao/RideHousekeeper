//
//  GoodServiceDetailTableViewCell.m
//  RideHousekeeper
//
//  Created by Apple on 2020/3/13.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import "GoodServiceDetailTableViewCell.h"

@implementation GoodServiceDetailTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        _icon = [[UIImageView alloc] init];
        _icon.image = [UIImage imageNamed:@"discounted_good_icon"];
        _icon.layer.cornerRadius = 10;
        [self.contentView addSubview:_icon];
        [_icon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(38);
            make.bottom.equalTo(self.contentView);
            make.size.mas_equalTo(CGSizeMake(45, 45));
        }];
        
        _titleLab = [[UILabel alloc] init];
        _titleLab.text = @"GPS服务包半年";
        _titleLab.textColor = [QFTools colorWithHexString:@"#333333"];
        _titleLab.font = FONT_PINGFAN(13);
        [self.contentView addSubview:_titleLab];
        [_titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_icon.mas_right).offset(10);
            make.bottom.equalTo(self.contentView.mas_centerY);
            make.height.mas_equalTo(18);
        }];
        
        _durationLab = [[UILabel alloc] init];
        _durationLab.numberOfLines = 0;
        _durationLab.text = @"180天";
        _durationLab.textColor = [QFTools colorWithHexString:@"#999999"];
        _durationLab.font = FONT_PINGFAN(10);
        [self.contentView addSubview:_durationLab];
        [_durationLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_titleLab);
            make.right.equalTo(self.contentView.mas_right).offset(-10);
            make.top.equalTo(_titleLab.mas_bottom).offset(5);
            //make.height.mas_equalTo(14);
        }];
        
        _numLab = [[UILabel alloc] init];
        _numLab.text = @"×1";
        _numLab.textColor = [QFTools colorWithHexString:@"#666666"];
        _numLab.font = FONT_PINGFAN(10);
        [self.contentView addSubview:_numLab];
        [_numLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView).offset(-10);
            make.top.equalTo(_titleLab.mas_bottom);
            make.height.mas_equalTo(14);
        }];
    }
    return self;
}

@end
