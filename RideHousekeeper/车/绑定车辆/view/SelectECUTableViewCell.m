//
//  SelectECUTableViewCell.m
//  RideHousekeeper
//
//  Created by Apple on 2020/4/20.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import "SelectECUTableViewCell.h"

@implementation SelectECUTableViewCell

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
//            make.width.equalTo(self.contentView);
//            make.height.mas_equalTo(self.icon.mas_width).multipliedBy(1.371);
        }];
        self.titleLab = [UILabel new];
        self.titleLab.alpha = 0.8;
        self.titleLab.font = FONT_PINGFAN(15);
        self.titleLab.textColor = [UIColor blackColor];
        self.titleLab.numberOfLines = 1;
        self.titleLab.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.titleLab];
        [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.icon.mas_bottom).offset(self.height *.1);
            make.centerX.equalTo(self.contentView);
            make.height.mas_equalTo(15);
        }];
//        self.contentView.layer.masksToBounds = YES;
//        self.contentView.layer.cornerRadius = 8;
        
    }
    return self;
}


@end
