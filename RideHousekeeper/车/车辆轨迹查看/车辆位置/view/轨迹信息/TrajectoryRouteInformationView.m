//
//  TrajectoryRouteInformationView.m
//  RideHousekeeper
//
//  Created by Apple on 2019/10/29.
//  Copyright © 2019 Duke Wu. All rights reserved.
//

#import "TrajectoryRouteInformationView.h"
#import "NSDate+HC.h"
#import "SportAnnotationView.h"
@interface TrajectoryRouteInformationView ()
@property(nonatomic, strong) UILabel *dateLab;
//@property(nonatomic, strong) UILabel *weekdayLab;
//@property(nonatomic, strong) UILabel *timeLab;
//@property(nonatomic, strong) UILabel *begainLab;
//@property(nonatomic, strong) UILabel *endLab;
@property (strong, nonatomic) UILabel *mileageLab;
@property (strong, nonatomic) UILabel *timeConsumingLab;
@property (strong, nonatomic) UILabel *speedImgLab;
@end

@implementation TrajectoryRouteInformationView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 10;
        self.layer.masksToBounds = YES;
        [self setupUI];
    }
    return self;
}

-(void)setupUI{
    
    _dateLab = [[UILabel alloc] init];
    _dateLab.textColor = [UIColor blackColor];
    _dateLab.font = FONT_PINGFAN(16);
    _dateLab.text = @"2019/10/29";
    [self addSubview:_dateLab];
    [_dateLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(15);
        make.top.equalTo(self).offset(10);
        make.height.mas_equalTo(20);
    }];
    
    
//    _weekdayLab = [[UILabel alloc] init];
//    _weekdayLab.textColor = [UIColor blackColor];
//    _weekdayLab.font = FONT_PINGFAN(16);
//    _weekdayLab.text = @"星期三";
//    [self addSubview:_weekdayLab];
//    [_weekdayLab mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(_dateLab.mas_right).offset(10);
//        make.centerY.equalTo(_dateLab.mas_centerY);
//        make.height.mas_equalTo(20);
//    }];
//
//    _timeLab = [[UILabel alloc] init];
//    _timeLab.textColor = [QFTools colorWithHexString:@"#999999"];
//    _timeLab.font = FONT_PINGFAN(13);
//    _timeLab.text = @"10:18";
//    [self addSubview:_timeLab];
//    [_timeLab mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.right.equalTo(self).offset(-15);
//        make.centerY.equalTo(_weekdayLab.mas_centerY);
//        make.height.mas_equalTo(15);
//    }];
    
//    UIView *begainView = [[UIView alloc] init];
//    begainView.backgroundColor = [QFTools colorWithHexString:MainColor];
//    begainView.layer.cornerRadius = 5;
//    begainView.layer.masksToBounds = YES;
//    [self addSubview:begainView];
//    [begainView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(_dateLab.mas_left);
//        make.top.equalTo(line.mas_bottom).offset(10);
//        make.size.mas_equalTo(CGSizeMake(10, 10));
//    }];
//
//    _begainLab = [[UILabel alloc] init];
//    _begainLab.textColor = [QFTools colorWithHexString:@"#999999"];
//    _begainLab.font = FONT_PINGFAN(12);
//    _begainLab.text = @"徐汇上海南站南广场";
//    [self addSubview:_begainLab];
//    [_begainLab mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(begainView.mas_right).offset(10);
//        make.centerY.equalTo(begainView.mas_centerY);
//        make.height.mas_equalTo(15);
//    }];
//
//    UIView *endView = [[UIView alloc] init];
//    endView.backgroundColor = [UIColor redColor];
//    endView.layer.cornerRadius = 5;
//    endView.layer.masksToBounds = YES;
//    [self addSubview:endView];
//    [endView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(_dateLab.mas_left);
//        make.top.equalTo(begainView.mas_bottom).offset(10);
//        make.size.mas_equalTo(CGSizeMake(10, 10));
//    }];
//
//    _endLab = [[UILabel alloc] init];
//    _endLab.textColor = [QFTools colorWithHexString:@"#999999"];
//    _endLab.font = FONT_PINGFAN(12);
//    _endLab.text = @"徐汇区h桂平路481号桂中园";
//    [self addSubview:_endLab];
//    [_endLab mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(endView.mas_right).offset(10);
//        make.centerY.equalTo(endView.mas_centerY);
//        make.height.mas_equalTo(15);
//    }];
    
    _playBtn = [[UIButton alloc] init];
    [_playBtn setImage:[UIImage imageNamed:@"icon_track_stop"] forState:UIControlStateNormal];
    [_playBtn setImage:[UIImage imageNamed:@"icon_track_run"] forState:UIControlStateSelected];
    [_playBtn addTarget:self action:@selector(playBtnclick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_playBtn];
    [_playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(10);
        make.top.equalTo(_dateLab.mas_bottom).offset(10);
        make.height.mas_equalTo(30);
        make.width.mas_equalTo(_playBtn.mas_height).multipliedBy(1);
    }];
    
    _slider = [[LianUISlider alloc] init];
    _slider.minimumTrackTintColor=[UIColor whiteColor];
    _slider.thumbTintColor=[UIColor whiteColor];
    [_slider setThumbImage:[UIImage imageNamed:@"icon_track_stop"] forState:UIControlStateNormal];
    [_slider setThumbImage:[UIImage imageNamed:@"icon_track_run"] forState:UIControlStateSelected];
    [_slider setMinimumTrackImage:[UIImage imageNamed:@"max"] forState:UIControlStateNormal];
    [_slider setMaximumTrackImage:[UIImage imageNamed:@"min"] forState:UIControlStateNormal];
    [_slider addTarget:self action:@selector(sliderClick:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:_slider];
    [_slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_playBtn.mas_right).offset(10);
        make.top.equalTo(_dateLab.mas_bottom).offset(15);
        make.right.equalTo(self).offset(-15);
        make.height.mas_equalTo(20);
    }];
    
    _mileageLab = [[UILabel alloc] init];
    _mileageLab.textColor = [UIColor blackColor];
    _mileageLab.font = FONT_PINGFAN(12);
    _mileageLab.text = @"20.2km";
    [self addSubview:_mileageLab];
    [_mileageLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_dateLab.mas_left);
        make.top.equalTo(_slider.mas_bottom).offset(10);
        make.height.mas_equalTo(15);
    }];
    
    UILabel *mileage = [[UILabel alloc] init];
    mileage.textColor = [QFTools colorWithHexString:@"#666666"];
    mileage.font = FONT_PINGFAN(10);
    mileage.text = @"总里程";
    [self addSubview:mileage];
    [mileage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_mileageLab);
        make.top.equalTo(_mileageLab.mas_bottom).offset(5);
        make.height.mas_equalTo(10);
    }];
    
    
    _timeConsumingLab = [[UILabel alloc] init];
    _timeConsumingLab.textColor = [UIColor blackColor];
    _timeConsumingLab.font = FONT_PINGFAN(12);
    _timeConsumingLab.text = @"30分钟";
    [self addSubview:_timeConsumingLab];
    [_timeConsumingLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(_mileageLab.mas_top);
        make.height.mas_equalTo(15);
    }];
    
    UILabel *timeConsuming = [[UILabel alloc] init];
    timeConsuming.textColor = [QFTools colorWithHexString:@"#666666"];
    timeConsuming.font = FONT_PINGFAN(10);
    timeConsuming.text = @"总时长";
    [self addSubview:timeConsuming];
    [timeConsuming mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_timeConsumingLab);
        make.top.equalTo(mileage);
        make.height.mas_equalTo(10);
    }];
    
    _speedImgLab = [[UILabel alloc] init];
    _speedImgLab.textColor = [UIColor blackColor];
    _speedImgLab.font = FONT_PINGFAN(12);
    _speedImgLab.text = @"30km/h";
    [self addSubview:_speedImgLab];
    [_speedImgLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-15);
        make.top.equalTo(_mileageLab.mas_top);
        make.height.mas_equalTo(15);
    }];
    
    UILabel *speed = [[UILabel alloc] init];
    speed.textColor = [QFTools colorWithHexString:@"#666666"];
    speed.font = FONT_PINGFAN(10);
    speed.text = @"平均速度";
    [self addSubview:speed];
    [speed mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_speedImgLab);
        make.top.equalTo(mileage);
        make.height.mas_equalTo(10);
    }];
    
}

-(void)sliderClick:(LianUISlider *)slider{
    if (self.slidingValue) self.slidingValue((NSInteger)slider.value);
}

-(void)playBtnclick:(UIButton *)sender{
    sender.selected = !sender.selected;
    _slider.selected = sender.selected;
    if (self.playBtnStep) self.playBtnStep(sender.selected);
}


-(void)setModel:(DayRideReportModel *)model{
    
    _dateLab.text = [QFTools stringFromInt:@"yyyy/MM/dd HH:MM" :model.content.begin_ts];
//    _weekdayLab.text = [[NSDate date] getDateDisplayString:model.content.begin_ts];
//    _timeLab.text = [QFTools stringFromInt:@"HH:mm" :model.content.begin_ts];
//    _begainLab.text = model.content.begin_loc.road;
//    _endLab.text = model.content.end_loc.road;
    _mileageLab.text = [NSString stringWithFormat:@"%.1fkm",(float)model.content.distance/1000];
    _timeConsumingLab.text = [NSString stringWithFormat:@"%.1f分钟",(float)model.content.time/60];
    _speedImgLab.text = [NSString stringWithFormat:@"%.1fkm/h",(float)model.content.speed * 0.001];
}

@end
