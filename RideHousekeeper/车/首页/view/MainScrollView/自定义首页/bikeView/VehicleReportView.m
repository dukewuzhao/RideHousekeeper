//
//  VehicleReportView.m
//  RideHousekeeper
//
//  Created by 吴兆华 on 2018/4/1.
//  Copyright © 2018年 Duke Wu. All rights reserved.
//

#import "VehicleReportView.h"

@implementation VehicleReportView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        [self addSubview:self.BikeStatusImg];
        [self addSubview:self.BikeStatusLab];
    }
    return self;
}




-(UIImageView *)BikeStatusImg{
    if (!_BikeStatusImg) {
        _BikeStatusImg = [UIImageView new];
        //_BikeStatusImg.image = [UIImage imageNamed:@"bike_BLE_braekconnect"];
    }
    return _BikeStatusImg;
}

-(UILabel *)BikeStatusLab{
    if (!_BikeStatusLab) {
        _BikeStatusLab = [UILabel new];
        _BikeStatusLab.textColor = [UIColor blackColor];
        _BikeStatusLab.font = FONT_PINGFAN(14);
        
    }
    return _BikeStatusLab;
}

-(UILabel *)CentralWithGPScConnection{
    if (!_CentralWithGPScConnection) {
        _CentralWithGPScConnection = [UILabel new];
        _CentralWithGPScConnection.textColor = [UIColor redColor];
        _CentralWithGPScConnection.text = @"中控连接丢失";
        _CentralWithGPScConnection.font = FONT_PINGFAN(14);
    }
    return _CentralWithGPScConnection;
}

- (void)setViewType:(NSInteger)viewType{
    _viewType = viewType;
    
    if (viewType == 1) {
        
        self.layer.cornerRadius = 20;
        self.layer.masksToBounds = YES;
        self.layer.borderWidth = 1;
        self.layer.borderColor = [[UIColor whiteColor] CGColor];
        [self removeSomeView];
        self.BikeStatusImg.image = [UIImage imageNamed:@"bike_BLE_braekconnect"];
        self.BikeStatusLab.text = NSLocalizedString(@"未连接", nil);
        [self.BikeStatusImg mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.left.equalTo(self.mas_left).offset(20);
            make.size.mas_equalTo(CGSizeMake(25, 25));
        }];
        
        [self.BikeStatusLab mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.left.equalTo(self.BikeStatusImg.mas_right).offset(5);
            make.right.equalTo(self).offset(-20);
            make.height.mas_equalTo(20);
        }];
        
    }else if (viewType == 2){
        
        self.layer.cornerRadius = 0;
        self.layer.borderWidth = 0;
        [self removeSomeView];
        self.BikeStatusImg.image = [UIImage imageNamed:@"bike_BLE_braekconnect"];
        self.BikeStatusLab.text = NSLocalizedString(@"未连接", nil);
        [self.BikeStatusImg mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(23);
            make.centerY.equalTo(self);
            make.size.mas_equalTo(CGSizeMake(25, 25));
        }];
        
        [self.BikeStatusLab mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.left.equalTo(self.BikeStatusImg.mas_right).offset(5);
            make.height.mas_equalTo(20);
        }];
        
        [self addSubview:self.CentralWithGPScConnection];
        [self.CentralWithGPScConnection mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.mas_right).offset(-23);
            make.centerY.equalTo(self);
            make.height.mas_equalTo(20);
        }];
        
        
    }else if (viewType == 3) {
        self.layer.cornerRadius = 20;
        self.layer.masksToBounds = YES;
        self.layer.borderWidth = 1;
        self.layer.borderColor = [[UIColor whiteColor] CGColor];
        [self removeSomeView];
        self.BikeStatusImg.image = [UIImage imageNamed:@"icon_gps_door_close"];
        self.BikeStatusLab.text = NSLocalizedString(@"电门关闭", nil);
        [self.BikeStatusImg mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.left.equalTo(self.mas_left).offset(20);
            make.size.mas_equalTo(CGSizeMake(15, 24));
        }];//5.8
        
        [self.BikeStatusLab mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.left.equalTo(self.BikeStatusImg.mas_right).offset(5);
            make.right.equalTo(self).offset(-20);
            make.height.mas_equalTo(20);
        }];
    }
}

-(void)removeSomeView{
    
    [self.CentralWithGPScConnection removeFromSuperview];
    self.CentralWithGPScConnection = nil;
}

- (void)setBikeid:(NSInteger)bikeid{
    _bikeid = bikeid;
}

@end
