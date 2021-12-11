//
//  InformationHintsView.m
//  RideHousekeeper
//
//  Created by Apple on 2018/3/27.
//  Copyright © 2018年 Duke Wu. All rights reserved.
//

#import "InformationHintsView.h"

@implementation InformationHintsView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        //self.backgroundColor = [UIColor whiteColor];
        
        self.displayImg.image = [UIImage imageNamed:@"car_condition_pointing_arrow"];
        [self addSubview:self.displayImg];
        [self.displayImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.mas_right).offset(-2);
            make.centerY.equalTo(self.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(10, 10));
        }];
        
        if ([CommandDistributionServices isConnect]) {
            self.BLEConnectStatusPointView.backgroundColor = [QFTools colorWithHexString:@"#0A84FF"];
        }else{
            self.BLEConnectStatusPointView.backgroundColor = [QFTools colorWithHexString:@"#999999"];
        }
        
        
        self.BLEConnectStatusPointView.layer.cornerRadius = 2.5;
        [self addSubview:self.BLEConnectStatusPointView];
        [self.BLEConnectStatusPointView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(10);
            make.centerY.equalTo(self);
            make.size.mas_equalTo(CGSizeMake(5, 5));
        }];
        
        self.displayLab.font = FONT_PINGFAN(14);
        self.displayLab.textColor = [UIColor blackColor];
        self.displayLab.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.displayLab];
        [self.displayLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.mas_centerX).priorityLow();
            make.centerY.equalTo(self.mas_centerY);
            make.left.greaterThanOrEqualTo(self.mas_left).offset(15);
            make.height.mas_equalTo(15);
        }];
        
        self.caveatView.backgroundColor = [UIColor redColor];
        self.caveatView.layer.cornerRadius = 5;
        self.caveatView.layer. masksToBounds = YES;
        self.caveatView.hidden = YES;
        [self addSubview:self.caveatView];
        [self.caveatView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.greaterThanOrEqualTo(self.mas_left).offset(10);
            make.top.equalTo(self.mas_top).offset(5);
            make.size.mas_equalTo(CGSizeMake(10, 10));
        }];
    }
    return self;
}


-(UIView *)BLEConnectStatusPointView{
    
    if (!_BLEConnectStatusPointView) {
        _BLEConnectStatusPointView = [UIView new];
    }
    return _BLEConnectStatusPointView;
}

-(UIView *)caveatView{
    
    if (!_caveatView) {
        _caveatView = [UIView new];
    }
    return _caveatView;
}


-(UILabel *)displayLab{
    
    if (!_displayLab) {
        _displayLab = [UILabel new];
    }
    return _displayLab;
}


-(UIImageView *)displayImg{
    
    if (!_displayImg) {
        _displayImg = [UIImageView new];
    }
    return _displayImg;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    if (_clickDelegate && [_clickDelegate respondsToSelector:@selector(didClickView)]){
        [_clickDelegate didClickView];
    }
}


@end
