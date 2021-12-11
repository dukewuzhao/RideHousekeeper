//
//  SelectBikeCell.m
//  RideHousekeeper
//
//  Created by Apple on 2019/11/6.
//  Copyright © 2019 Duke Wu. All rights reserved.
//

#import "SelectBikeCell.h"

@implementation SelectBikeCell

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self){
        self.icon = [UIImageView new];
        self.icon.contentMode = UIViewContentModeScaleAspectFill;
        self.icon.layer.masksToBounds = YES;
        [self.contentView addSubview:self.icon];
        [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView);
            make.centerX.equalTo(self.contentView);
            make.width.equalTo(self.contentView);
            make.height.mas_equalTo(self.icon.mas_width).multipliedBy(.648);
        }];
        self.leftText = [UILabel new];
        self.leftText.alpha = 0.8;
        self.leftText.font = FONT_PINGFAN(15);
        self.leftText.textColor = [UIColor blackColor];
        self.leftText.numberOfLines = 1;
        self.leftText.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.leftText];
        [self.leftText mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.icon.mas_bottom).offset(self.height *.05);
            make.centerX.equalTo(self.contentView);
            make.height.mas_equalTo(15);
        }];
//        self.contentView.layer.masksToBounds = YES;
//        self.contentView.layer.cornerRadius = 8;
        
    }
    return self;
}

@end
