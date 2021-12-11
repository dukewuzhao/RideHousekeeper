//
//  TrafficReportHeadView.m
//  RideHousekeeper
//
//  Created by Apple on 2018/3/12.
//  Copyright © 2018年 Duke Wu. All rights reserved.
//

#import "TrafficReportHeadView.h"
#import "NSDate+HC.h"
@implementation TrafficReportHeadView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        
        [self setupView];
    }
    return self;
}

-(void)setupView{
    
    
    _mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth - 30, 40)];
    _mainView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_mainView];
    _mainView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickMainView)];
    tap.numberOfTapsRequired = 1;
    [_mainView addGestureRecognizer:tap];
    
    _dateLab = [[UILabel alloc] init];
    _dateLab.textColor = [QFTools colorWithHexString:@"#111111"];
    _dateLab.text = [[NSDate new] dateWithYMDHMS];
    _dateLab.font = FONT_PINGFAN(12);
    _dateLab.textAlignment = NSTextAlignmentCenter;
    [_mainView addSubview:_dateLab];
    [_dateLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_mainView);
        make.left.equalTo(self).offset(30);
        make.height.mas_equalTo(20);
    }];

    _weekTimeLab = [[UILabel alloc] init];
    _weekTimeLab.textColor = [QFTools colorWithHexString:@"#111111"];
    _weekTimeLab.font = FONT_PINGFAN(12);
    _weekTimeLab.text = @"星期几";
    _weekTimeLab.textAlignment = NSTextAlignmentCenter;
    [_mainView addSubview:_weekTimeLab];
    [_weekTimeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_mainView);
        make.left.equalTo(_dateLab.mas_right).offset(30);
        make.height.mas_equalTo(20);
    }];
}

-(void)clickMainView{
    
    if (self.trafficReportClickBlock) {
        self.trafficReportClickBlock();
    }
}

@end
