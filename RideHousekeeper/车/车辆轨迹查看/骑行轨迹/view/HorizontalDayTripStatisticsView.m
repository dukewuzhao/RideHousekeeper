//
//  HorizontalDayTripStatisticsView.m
//  RideHousekeeper
//
//  Created by Apple on 2020/3/5.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import "HorizontalDayTripStatisticsView.h"
#import "HorizontalTrackUnitView.h"

@interface HorizontalDayTripStatisticsView()
@property (nonatomic,strong)HorizontalTrackUnitView *alarmNumberView;
@property (nonatomic,strong)HorizontalTrackUnitView *ridingMileageView;
@property (nonatomic,strong)HorizontalTrackUnitView *rideTimeView;
@property (nonatomic,strong)HorizontalTrackUnitView *averageSpeedView;
@end

@implementation HorizontalDayTripStatisticsView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 5;
        self.layer.masksToBounds = YES;
        
        _alarmNumberView = [[HorizontalTrackUnitView alloc] init];
        _alarmNumberView.unitValueLab.text = @"--";
        _alarmNumberView.annotationLab.text = @"告警次数";
        [self addSubview:_alarmNumberView];
        
        _ridingMileageView = [[HorizontalTrackUnitView alloc] init];
        _ridingMileageView.unitValueLab.text = @"--";
        _ridingMileageView.annotationLab.text = @"骑行里程";
        [self addSubview:_ridingMileageView];
        
        _rideTimeView = [[HorizontalTrackUnitView alloc] init];
        _rideTimeView.unitValueLab.text = @"--";
        _rideTimeView.annotationLab.text = @"骑行时间";
        [self addSubview:_rideTimeView];
        
        _averageSpeedView = [[HorizontalTrackUnitView alloc] init];
        _averageSpeedView.unitValueLab.text = @"--";
        _averageSpeedView.annotationLab.text = @"平均速度";
        [self addSubview:_averageSpeedView];
        
        [@[_alarmNumberView,_ridingMileageView,_rideTimeView, _averageSpeedView] mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:10 leadSpacing:10 tailSpacing:10];
        [@[_alarmNumberView,_ridingMileageView,_rideTimeView, _averageSpeedView] mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(5);
            make.bottom.equalTo(self).offset(-10);
        }];
    }
    return self;
}

-(void)setOneDayModel:(RideOneDayModel*)model{
    
    if (model.summary.ride_distance == 0){
        _ridingMileageView.unitValueLab.text = @"--";
    }else if (model.summary.ride_distance/1000.0 <= 0.1 && model.summary.ride_distance > 0) {
        _ridingMileageView.unitValueLab.text = @"约0.1km";
    }else if (model.summary.ride_distance/1000.0 >= 999) {
        _ridingMileageView.unitValueLab.text = @"999km";
    }else{
        _ridingMileageView.unitValueLab.text = [NSString stringWithFormat:@"%.1fkm", model.summary.ride_distance/1000.0];
    }
    
    if (model.summary.ride_distance == 0){
        _averageSpeedView.unitValueLab.text = @"--";
    }else if ((model.summary.ride_distance/(float)model.summary.ride_time)*3.6 <= 0.1 && model.summary.ride_distance > 0) {
        _averageSpeedView.unitValueLab.text = @"约0.1km/h";
    }else{
        _averageSpeedView.unitValueLab.text = [NSString stringWithFormat:@"%.1fkm", model.summary.ride_distance/1000.0];
    }
    
    if (model.summary.ride_time == 0){
        _rideTimeView.unitValueLab.text = @"--";
    }else if (model.summary.ride_time <= 60 && model.summary.ride_time > 0) {
        _rideTimeView.unitValueLab.text = @"约0.1min";
    }else{
        _rideTimeView.unitValueLab.text = [NSString stringWithFormat:@"%.1fh", model.summary.ride_time/3600.0];
    }
    
    if (model.summary.warn_count == 0){
        _alarmNumberView.unitValueLab.text = @"--";
    }else{
        _alarmNumberView.unitValueLab.text = [NSString stringWithFormat:@"%d次", model.summary.warn_count];
    }
}

@end
