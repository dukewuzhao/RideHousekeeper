//
//  UserIconTableViewCell.m
//  RideHousekeeper
//
//  Created by Apple on 2018/11/29.
//  Copyright © 2018年 Duke Wu. All rights reserved.
//

#import "UserIconTableViewCell.h"

@interface UserIconTableViewCell ()
@property(nonatomic,strong) UIView *userimageback;
@end

@implementation UserIconTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        _name = [[UILabel alloc] init];
        _name.font = [UIFont systemFontOfSize:15];
        _name.textColor = [UIColor blackColor];
        _name.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:_name];
        [_name mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left).offset(15);
            make.centerY.equalTo(self.mas_centerY);
            make.height.mas_equalTo(20);
        }];
        
        _userIcon = [[UIImageView alloc] init];
        [self.contentView addSubview:_userIcon];
        [_userIcon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.mas_right).offset(-40);
            make.centerY.equalTo(self.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(ScreenHeight *.13*2/3+4, ScreenHeight *.13*2/3+4));
        }];
        
        
        
        _arrow = [[UIImageView alloc] init];
        _arrow.image = [UIImage imageNamed:@"arrow"];
        [self.contentView addSubview:_arrow];
        [_arrow mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.mas_right).offset(-12);
            make.centerY.equalTo(self.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(8.4, 15));
        }];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [_userIcon lm_addCorner:_userIcon.width/2.0 borderWidth:2.5 borderColor:[QFTools colorWithHexString:MainColor] backGroundColor:[UIColor clearColor]];
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
