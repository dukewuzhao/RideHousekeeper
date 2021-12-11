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
        self.layer.contents = (id)[UIImage imageNamed:@"icon_temp_bg"].CGImage;
        self.displayImg.image = [UIImage imageNamed:@"car_condition_pointing_arrow"];
        [self addSubview:self.displayImg];
        [self.displayImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.mas_right).offset(-2);
            make.centerY.equalTo(self.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(10, 10));
        }];
        
        self.displayLab.font = FONT_PINGFAN(14);
        self.displayLab.textColor = [UIColor blackColor];
        self.displayLab.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.displayLab];
        [self.displayLab mas_makeConstraints:^(MASConstraintMaker *make) {
    
            make.centerY.equalTo(self.mas_centerY);
            make.left.greaterThanOrEqualTo(self.mas_left).offset(10);
            make.right.equalTo(self.displayImg.mas_left).offset(-2);
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


-(UILabel *)displayLab{
    
    if (!_displayLab) {
        _displayLab = [UILabel new];
    }
    return _displayLab;
}

-(UIView *)caveatView{
    
    if (!_caveatView) {
        _caveatView = [UIView new];
    }
    return _caveatView;
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
