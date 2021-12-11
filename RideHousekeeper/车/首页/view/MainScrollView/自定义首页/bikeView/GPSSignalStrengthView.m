//
//  GPSSignalStrengthView.m
//  RideHousekeeper
//
//  Created by Apple on 2020/3/25.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import "GPSSignalStrengthView.h"
@interface GPSSignalStrengthView()
@property(nonatomic,strong)UIView *view1;
@property(nonatomic,strong)UIView *view2;
@property(nonatomic,strong)UIView *view3;
@property(nonatomic,strong)UIView *view4;
@property(nonatomic,strong)UIView *view5;
@property(nonatomic,strong)NSArray *viewAry;
@end

@implementation GPSSignalStrengthView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        //self.backgroundColor = [UIColor whiteColor];
        _titleLab = [[UILabel alloc] init];
        _titleLab.text = @"GPS";
        _titleLab.textColor = [QFTools colorWithHexString:@"#999999"];
        _titleLab.font = FONT_PINGFAN(10);
        [self addSubview:_titleLab];
        [_titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self);
            make.centerY.equalTo(self);
            make.height.mas_equalTo(15);
        }];
        
        UIView *backView = [[UIView alloc] init];
        [self addSubview:backView];
        [backView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_titleLab.mas_right).offset(6);
            make.top.bottom.equalTo(self);
            make.width.mas_equalTo(20);
            make.right.equalTo(self);
        }];
        
        for (int i = 0; i<5; i++) {
            UIView *signalView = [[UIView alloc] init];
            signalView.tag = 20+i;
            signalView.backgroundColor = [QFTools colorWithHexString:@"#00FFE5"];
            signalView.alpha = 0.2;
            signalView.layer.cornerRadius = 0.8;
            if (signalView.tag == 20) {
                _view1 = signalView;
            }else if (signalView.tag == 21){
                _view2 = signalView;
            }else if (signalView.tag == 22){
                _view3 = signalView;
            }else if (signalView.tag == 23){
                _view4 = signalView;
            }else if(signalView.tag == 24){
                _view5 = signalView;
            }
            [backView addSubview:signalView];
        }
        
        [@[_view1,_view2, _view3,_view4,_view5] mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedItemLength:2 leadSpacing:0 tailSpacing:0];
        [@[_view1,_view2, _view3,_view4,_view5] mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.top.equalTo(self).offset(2);
        }];
        _viewAry = @[_view1,_view2, _view3,_view4,_view5];
        
    }
    return self;
}

- (void)setValue:(NSInteger)value{
    [self restAllView];
    for (int i = 0; i<value; i++) {
        UIView *view = _viewAry[i];
        view.alpha = 1;
    }
}

-(void)restAllView{
    for (int i = 0; i<5; i++) {
        UIView *view = _viewAry[i];
        view.alpha = 0.2;
    }
}

@end
