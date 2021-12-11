//
//  VehicleDataView.m
//  RideHousekeeper
//
//  Created by Apple on 2019/7/11.
//  Copyright © 2019 Duke Wu. All rights reserved.
//

#import "VehicleDataView.h"

@implementation VehicleDataView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)init{
    if (self = [super init]) {
        self.backgroundColor = [UIColor colorWithWhite:1 alpha:0.05];
        [self setupView];
    }
    return self;
}

-(void)setupView{
    
    [self addSubview:self.titlelab];
    [self.titlelab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.bottom.equalTo(self.mas_top);
        make.height.mas_equalTo(30);
    }];
    
    
    [self addSubview:self.displayLab];
    [self.displayLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.bottom.equalTo(self.mas_centerY).offset(-10);
        make.height.mas_equalTo(20);
    }];
    
    [self addSubview:self.displayImg];
    [self.displayImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.top.equalTo(self.mas_centerY).offset(10);
        //make.height.mas_equalTo(20);
    }];
    
}

-(UILabel *)displayLab{
    
    if (!_displayLab) {
        _displayLab = [UILabel new];
        _displayLab.textColor = [QFTools colorWithHexString:MainColor];
    }
    return _displayLab;
}



-(UILabel *)titlelab{
    
    if (!_titlelab) {
        _titlelab = [UILabel new];
        _titlelab.textColor = [UIColor blackColor];
    }
    return _titlelab;
}

-(UIImageView *)displayImg{

    if (!_displayImg) {
        _displayImg = [UIImageView new];
    }
    return _displayImg;
}

@end
