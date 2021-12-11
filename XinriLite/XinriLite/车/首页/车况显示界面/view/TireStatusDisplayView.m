//
//  TireStatusDisplayView.m
//  RideHousekeeper
//
//  Created by Apple on 2019/7/12.
//  Copyright © 2019 Duke Wu. All rights reserved.
//

#import "TireStatusDisplayView.h"

@implementation TireStatusDisplayView


- (instancetype)init{
    if (self = [super init]) {
        [self setupView];
    }
    return self;
}

-(void)setupView{
    
    [self addSubview:self.symbolLab];
    [self.symbolLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.top.equalTo(self);
        make.height.mas_equalTo(10);
    }];
    
    [self addSubview:self.tirePressureLab];
    [self.tirePressureLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.bottom.equalTo(self.mas_bottom);
        make.height.mas_equalTo(20);
    }];
}

-(UILabel *)symbolLab{
    
    if (!_symbolLab) {
        _symbolLab = [UILabel new];
        _symbolLab.textColor = [QFTools colorWithHexString:MainColor];
        _symbolLab.text = @"Kpa";
        _symbolLab.font = FONT_PINGFAN(10);
    }
    return _symbolLab;
}

-(UILabel *)tirePressureLab{
    
    if (!_tirePressureLab) {
        _tirePressureLab = [UILabel new];
        _tirePressureLab.textColor = [QFTools colorWithHexString:MainColor];
        _tirePressureLab.text = @"0";
        _tirePressureLab.font = FONT_PINGFAN(18);
    }
    return _tirePressureLab;
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
