//
//  PayChannelHeadView.m
//  RideHousekeeper
//
//  Created by Apple on 2020/3/18.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import "PayChannelHeadView.h"
@interface PayChannelHeadView()
@property(nonatomic,assign) BOOL select;
@end
@implementation PayChannelHeadView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        UILabel *titleLab = [[UILabel alloc] init];
        titleLab.text = @"支付方式";
        titleLab.textColor = [QFTools colorWithHexString:@"#333333"];
        titleLab.font = FONT_PINGFAN(15);
        [self addSubview:titleLab];
        [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(10);
            make.centerY.equalTo(self);
            make.height.mas_equalTo(21);
        }];
        
        _icon = [[UIImageView alloc] init];
        [self addSubview:_icon];
        [_icon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(titleLab.mas_right).offset(30);
            make.centerY.equalTo(self);
            make.size.mas_equalTo(CGSizeMake(25, 25));
        }];
        
        _selectLab = [[UILabel alloc] init];
        _selectLab.textColor = [QFTools colorWithHexString:@"#333333"];
        _selectLab.font = FONT_PINGFAN(13);
        [self addSubview:_selectLab];
        [_selectLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_icon.mas_right).offset(10);
            make.centerY.equalTo(self);
            make.height.mas_equalTo(18);
        }];
        
        _arrow = [[UIImageView alloc] init];
        _arrow.image = [UIImage imageNamed:@"icon_down"];
        [self addSubview:_arrow];
        [_arrow mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).offset(-10);
            make.centerY.equalTo(self);
        }];
        
        self.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clicView)];
        [self addGestureRecognizer:tap];
        
    }
    return self;
}

-(void)clicView{
    self.select = !self.select;
    if (self.payChannelClickBlock) {
        self.payChannelClickBlock(self.select);
    }
}

@end
