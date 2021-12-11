//
//  SingelGPSMaskView.m
//  RideHousekeeper
//4
//  Created by Apple on 2020/3/25.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import "SingelGPSMaskView.h"
#import "GPSServiceStatusView.h"
@interface SingelGPSMaskView()
@property(nonatomic,strong)UIView *bottomView;
@property(nonatomic,strong)UILabel *title;
@property(nonatomic,strong)UIImageView *icon;
@property(nonatomic,strong)GPSServiceStatusView *remindView;
@end

@implementation SingelGPSMaskView

-(void)setBikeStatusInfo:(BikeStatusInfoModel*)model{
    switch (model.is_online) {
        case 0:
            self.title.text = @"离线";
            self.title.textColor = [QFTools colorWithHexString:@"#333333"];
            self.icon.image = [UIImage imageNamed:@"gps_disconnection_status_icon"];
            self.bottomView.backgroundColor = RGBACOLOR(196, 196, 196, .8);
            
            break;
        case 1:
            self.title.text = @"在线";
            self.title.textColor = [UIColor whiteColor];
            self.icon.image = [UIImage imageNamed:@"gps_connection_status_icon"];
            self.bottomView.backgroundColor = [QFTools colorWithHexString:@"#7EDFD7"];
            break;
        default:
            break;
    }
    
}

- (void)setType:(NSInteger)type{
    _type = type;
    
    switch (type) {
        case 0://试用
            
            self.remindView.fillColor = [UIColor colorWithRed:126/255.0 green:223/255.0 blue:215/255.0 alpha:0.9];
            self.remindView.titleLab.hidden = NO;
            self.remindView.titleLab.text = @"试用";
            break;
        case 1://正式服务
            
            self.remindView.fillColor = [UIColor clearColor];
            self.remindView.titleLab.hidden = YES;
            break;
        case 2://停用
        
            self.remindView.fillColor = [UIColor colorWithRed:250/255.0 green:17/255.0 blue:22/255.0 alpha:0.9];
            self.remindView.titleLab.hidden = NO;
            self.remindView.titleLab.text = @"停用";
            break;
        default:
            break;
    }
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
        [self addSubview:self.remindView];
        
        _bottomView = [[UIView alloc] init];
        _bottomView.backgroundColor = [QFTools colorWithHexString:@"#7EDFD7"];
        [self addSubview:_bottomView];
        [_bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
           make.right.equalTo(self);
            make.bottom.equalTo(self);
            make.size.mas_equalTo(CGSizeMake(84, 32));
        }];
        
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 84, 32) byRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(10, 10)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = CGRectMake(0, 0, 84, 32);
        maskLayer.path = maskPath.CGPath;
        _bottomView.layer.mask = maskLayer;
        
        _icon = [[UIImageView alloc] init];
        _icon.image = [UIImage imageNamed:@"gps_connection_status_icon"];
        [_bottomView addSubview:_icon];
        [_icon mas_makeConstraints:^(MASConstraintMaker *make) {
           make.centerY.equalTo(_bottomView);
            make.left.equalTo(_bottomView).offset(15);
            make.size.mas_equalTo(CGSizeMake(17, 17));
        }];
        
        _title = [[UILabel alloc] init];
        _title.font = FONT_PINGFAN(13);
        _title.text = @"在线";
        _title.textColor = [UIColor whiteColor];
        [_bottomView addSubview:_title];
        [_title mas_makeConstraints:^(MASConstraintMaker *make) {
           make.centerY.equalTo(_bottomView);
            make.left.equalTo(_icon.mas_right).offset(5);
            make.height.mas_equalTo(18);
        }];
    }
    return self;
}

-(GPSServiceStatusView *)remindView{
    if (!_remindView) {
        _remindView = [[GPSServiceStatusView alloc] initWithFrame:CGRectMake(0, 0, self.height * .5, self.height * .5)];
    }
    return _remindView;
}

@end
