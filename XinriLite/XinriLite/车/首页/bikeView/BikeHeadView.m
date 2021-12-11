//
//  BikeHeadView.m
//  RideHousekeeper
//
//  Created by Apple on 2018/3/1.
//  Copyright © 2018年 Duke Wu. All rights reserved.
//

#import "BikeHeadView.h"

@interface BikeHeadView() 

@end

@implementation BikeHeadView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithRed:17/255.0 green:19/255.0 blue:22/255.0 alpha:1];
        [self addSubview:self.backImg];
        [self setupUI];
    }
    return self;
}

-(void)setupUI{
    
    [self addSubview:self.bikeBrandImg];
    [self.bikeBrandImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self).offset(ScreenHeight*.0375+navHeight);
        make.width.mas_equalTo(ScreenWidth * .7);
        make.height.mas_equalTo(self.bikeBrandImg.mas_width).multipliedBy(.727);
    }];
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
    //int intervalHeight = ((ScreenHeight - QGJ_TabbarSafeBottomMargin) *.63 - self.bikeBrandImg.frame.origin.y - self.bikeBrandImg.bounds.size.height - 10)/2;
    
    [self addSubview:self.vehicleView];
    [self.vehicleView mas_makeConstraints:^(MASConstraintMaker *make){
        make.centerX.equalTo(self);
        //make.centerY.equalTo(self.bikeBrandImg.mas_bottom).offset(intervalHeight);
        make.bottom.equalTo(self.backImg).offset(-self.backImg.height*.3);
        make.height.mas_equalTo(40);
    }];
}

-(UILabel *)bikeBleLab{
    if (!_bikeBleLab) {
        
        _bikeBleLab.textColor = [QFTools colorWithHexString:MainColor];
        _bikeBleLab.font = [UIFont systemFontOfSize:15];
    }
    return  _bikeBleLab;
}

- (UIImageView *)bikeStateImg{
    if (!_bikeStateImg) {
        float imgeSize = self.height *.18;
        _bikeStateImg = [[UIImageView alloc] initWithFrame:CGRectMake(20, self.height - imgeSize - 10, imgeSize, imgeSize)];
//        _bikeStateImg.backgroundColor = [QFTools colorWithHexString:MainColor];
//        _bikeStateImg.clipsToBounds = YES;
//        _bikeStateImg.layer.cornerRadius = _bikeStateImg.width/2;
    }
    return _bikeStateImg;
}

-(UIImageView *)backImg{
    
    if (!_backImg) {
        _backImg = [UIImageView new];
        _backImg.frame = CGRectMake(0, 0, ScreenWidth, ScreenWidth*1.4);
        _backImg.image = [UIImage imageNamed:NSLocalizedString(@"bike_head_img", nil)];
    }
    return _backImg;
}

-(UIImageView *)bikeBrandImg{
    
    if (!_bikeBrandImg) {
        _bikeBrandImg = [UIImageView new];
        _bikeBrandImg.image = [UIImage imageNamed:@"icon_default_model"];
    }
    return _bikeBrandImg;
}

-(VehicleControlView *)vehicleView{
    
    if (!_vehicleView) {
        _vehicleView = [[VehicleControlView alloc] init];
    }
    return _vehicleView;
}


- (void)setHaveGPS:(BOOL)haveGPS{
    _haveGPS = haveGPS;
    if (haveGPS) {
        
        self.bikeStateImg.hidden = NO;
        self.bikeBrandImg.frame = CGRectMake(self.width * .26,navHeight + self.height *.23, ScreenWidth*.46, ScreenWidth *.46*.722);
        [self addSubview:self.bikeStateImg];
        [self addSubview:self.bikeBleLab];
        [self.vehicleView removeFromSuperview];
        self.vehicleView = nil;
    }else{
        
        self.bikeStateImg.hidden = YES;
        self.bikeBrandImg.frame = CGRectMake(self.width*.146,ScreenHeight *.165, self.width*.708, self.width*.708*.722);
        [self.bikeStateImg removeFromSuperview];
        [self.bikeBleLab removeFromSuperview];
        self.bikeStateImg = nil;
        self.bikeBleLab = nil;
        [self addSubview:self.vehicleView];
    }
    [self layoutIfNeeded];
}

- (void)setHaveCentralControl:(BOOL)haveCentralControl{
    _haveCentralControl = haveCentralControl;
    
    if (haveCentralControl) {
        self.bikeBrandImg.frame = CGRectMake(self.width * .162,navHeight + self.height *.21, self.width*.676, self.width *.676*.722);
        [self.vehicleView removeFromSuperview];
        self.vehicleView = nil;
    }
}



//-(void)setFrame:(CGRect)frame{
//
//
//}

@end
