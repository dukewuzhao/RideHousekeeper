//
//  BikeMessageTableViewCell.m
//  RideHousekeeper
//
//  Created by Apple on 2018/3/15.
//  Copyright © 2018年 Duke Wu. All rights reserved.
//

#import "BikeMessageTableViewCell.h"

@implementation BikeMessageTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        UIView *backView = [[UIView alloc] init];
        backView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:backView];
        backView.layer.cornerRadius = 10;
        backView.layer.masksToBounds = YES;
        [backView mas_makeConstraints:^(MASConstraintMaker *make) {

            make.left.equalTo(self.contentView).offset(20);
            make.top.equalTo(self.contentView);
            make.right.equalTo(self.contentView).offset(-20);
            make.bottom.equalTo(self.contentView);
        }];
        
        self.remindImg.image = [UIImage imageNamed:@"message_clock"];
        [backView addSubview:self.remindImg];
        [self.remindImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(backView).offset(10);
            make.top.equalTo(backView).offset(10);
            make.size.mas_equalTo(CGSizeMake(30, 30));
        }];
        
        self.newsType.textColor = [UIColor blackColor];
        self.newsType.font = FONT_PINGFAN(15);
        [backView addSubview:self.newsType];
        [self.newsType mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.remindImg.mas_right).offset(10);
            make.centerY.equalTo(self.remindImg);
            make.height.mas_equalTo(20);
        }];
        
        self.timeLab.textColor = [QFTools colorWithHexString:@"#999999"];
        [backView addSubview:self.timeLab];
        [self.timeLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(backView).offset(-10);
            make.top.equalTo(backView).offset(5);
            make.height.mas_equalTo(10);
        }];
        
        self.RemindLab.textColor = [QFTools colorWithHexString:@"#999999"];
        self.RemindLab.numberOfLines = 0;
        self.RemindLab.font = FONT_PINGFAN(13);
        [backView addSubview:self.RemindLab];
        [self.RemindLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.remindImg);
            make.top.equalTo(self.remindImg.mas_bottom).offset(10);
            make.right.equalTo(backView.mas_right).offset(-10);
            make.height.mas_equalTo(50);
        }];
        
        UIView *line = [[UIView alloc] init];
        line.backgroundColor = [QFTools colorWithHexString:@"#666666"];
        [backView addSubview:line];
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(backView);
            make.bottom.equalTo(backView).offset(-45);
            make.right.equalTo(backView);
            make.height.mas_equalTo(0.5);
        }];
        
        UIView *footView = [[UIView alloc] init];
        [backView addSubview:footView];
        [footView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(backView);
            make.top.equalTo(line.mas_bottom);
            make.right.equalTo(backView);
            make.bottom.equalTo(backView);
        }];
        
        UILabel *checkLab = [[UILabel alloc] init];
        checkLab.text = @"查看详情";
        checkLab.font = FONT_PINGFAN(14);
        checkLab.textColor = [QFTools colorWithHexString:@"#333333"];
        [footView addSubview:checkLab];
        [checkLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.remindImg);
            make.centerY.equalTo(footView);
            make.height.mas_equalTo(20);
        }];
        
        UIImageView *arrow = [[UIImageView alloc] init];
        arrow.image = [UIImage imageNamed:@"arrow"];
        [footView addSubview:arrow];
        [arrow mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.RemindLab);
            make.centerY.equalTo(footView);
        }];
    }
    return self;
}

- (void)layoutSubviews{
    
    for (UIView *subView in self.subviews) {
        if ([subView isKindOfClass:NSClassFromString(@"UITableViewCellDeleteConfirmationView")]) {
            for (UIButton *btn in subView.subviews) {
                if ([btn isKindOfClass:[UIButton class]]) {
                    btn.titleLabel.font = [UIFont systemFontOfSize:15.0f];
                }
            }
        }
    }
}



-(UIImageView *)remindImg{
    
    if (!_remindImg) {
        _remindImg = [UIImageView new];
    }
    return _remindImg;
}

-(UILabel *)newsType{
    
    if (!_newsType) {
        _newsType = [UILabel new];
    }
    return _newsType;
}

-(UILabel *)timeLab{
    
    if (!_timeLab) {
        _timeLab = [UILabel new];
        _timeLab.font = FONT_PINGFAN(8);
    }
    return _timeLab;
}

-(UILabel *)RemindLab{
    
    if (!_RemindLab) {
        _RemindLab = [UILabel new];
    }
    return _RemindLab;
}

@end
