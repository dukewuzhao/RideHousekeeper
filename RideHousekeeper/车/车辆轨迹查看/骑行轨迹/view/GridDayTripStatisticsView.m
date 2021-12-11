//
//  GridDayTripStatisticsView.m
//  RideHousekeeper
//
//  Created by Apple on 2020/3/5.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import "GridDayTripStatisticsView.h"
#import "VehicleTrackUnitView.h"

@interface GridDayTripStatisticsView()
@property (nonatomic,strong)VehicleTrackUnitView *ridingMileageView;
@property (nonatomic,strong)VehicleTrackUnitView *averageSpeedView;
@property (nonatomic,strong)VehicleTrackUnitView *rideTimeView;
@property (nonatomic,strong)VehicleTrackUnitView *alarmNumberView;
@end

@implementation GridDayTripStatisticsView



- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 10;
        self.layer.masksToBounds = YES;
        
        _ridingMileageView = [[VehicleTrackUnitView alloc] init];
        _ridingMileageView.unitValueLab.text = @"--";
        _ridingMileageView.annotationLab.text = @"骑行里程";
        [self addSubview:_ridingMileageView];
        
        _averageSpeedView = [[VehicleTrackUnitView alloc] init];
        _averageSpeedView.unitValueLab.text = @"--";
        _averageSpeedView.annotationLab.text = @"平均速度";
        [self addSubview:_averageSpeedView];
        
        _rideTimeView = [[VehicleTrackUnitView alloc] init];
        _rideTimeView.unitValueLab.text = @"--";
        _rideTimeView.annotationLab.text = @"骑行时间";
        [self addSubview:_rideTimeView];
        
        _alarmNumberView = [[VehicleTrackUnitView alloc] init];
        _alarmNumberView.unitValueLab.text = @"--";
        _alarmNumberView.annotationLab.text = @"告警次数";
        [self addSubview:_alarmNumberView];
        
        [@[_ridingMileageView, _averageSpeedView] mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:0 leadSpacing:0 tailSpacing:0];
        [@[_ridingMileageView, _averageSpeedView] mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self);
            make.bottom.equalTo(self.mas_centerY);
        }];
        
        [@[_rideTimeView, _alarmNumberView] mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:0 leadSpacing:0 tailSpacing:0];
        [@[_rideTimeView, _alarmNumberView] mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_centerY);
            make.bottom.equalTo(self);
        }];
        
        UIView *horizontalLineView = [[UIView alloc] init];
        horizontalLineView.backgroundColor = [QFTools colorWithHexString:@"#cccccc"];
        [self addSubview:horizontalLineView];
        [horizontalLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.left.right.equalTo(self);
            make.centerY.equalTo(self);
            make.height.mas_equalTo(0.5);
            
        }];
        
        UIView *verticalLineView = [[UIView alloc] init];
        verticalLineView.backgroundColor = [QFTools colorWithHexString:@"#cccccc"];
        [self addSubview:verticalLineView];
        [verticalLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.centerX.equalTo(self);
            make.top.bottom.equalTo(self);
            make.width.mas_equalTo(0.5);
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
        _rideTimeView.unitValueLab.text = @"约1min";
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
