//
//  MaskView.m
//  RideHousekeeper
//
//  Created by Apple on 2019/10/29.
//  Copyright © 2019 Duke Wu. All rights reserved.
//

#import "MaskView.h"
#import "GPSSignalStrengthView.h"
#import "GPSServiceStatusView.h"
#define K_X   CGRectGetWidth(self.frame)*.7
#define K_X2   CGRectGetWidth(self.frame)*.6
#define K_Y   0
#define K_W   CGRectGetWidth(self.frame)*.3
#define K_H   CGRectGetHeight(self.frame)

@interface MaskView()
@property (nonatomic, strong) UILabel    *estimatedMileage;
@property (nonatomic, strong) UILabel    *remainingPower;
@property (nonatomic, strong) GPSSignalStrengthView    *GPSSignalView;
@property (nonatomic, strong) GPSSignalStrengthView    *GSMSignalView;
@property (nonatomic, strong) GPSServiceStatusView    *remindView;
@end

@implementation MaskView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)setBikeStatusInfo:(BikeStatusInfoModel*)model{
    
    _GPSSignalView.value = (NSInteger)model.pos.level/20;
    _GSMSignalView.value = (NSInteger)model.signal/20;
    _estimatedMileage.text = [NSString stringWithFormat:@"%.1fV",model.bike.battery_vol/100.0];
    _remainingPower.text = [NSString stringWithFormat:@"%d%@",model.device.battery_level,@"%"];
    
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
        
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(10, 10)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = self.bounds;
        maskLayer.path = maskPath.CGPath;
        self.layer.mask = maskLayer;
        
        [self addSubview:self.remindView];
        self.remindView.fillColor = [UIColor clearColor];
        self.remindView.titleLab.hidden = YES;
        
        UILabel *titleLab = [[UILabel alloc] init];
        titleLab.text = @"电量";
        titleLab.textColor = [UIColor whiteColor];
        titleLab.font = FONT_PINGFAN(14);
        [self addSubview:titleLab];
        [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self).offset(self.width*.35);
            make.centerY.equalTo(self);
            make.height.mas_equalTo(11);
        }];
        
        _estimatedMileage = [[UILabel alloc] init];
        _estimatedMileage.text = @"0V";
        _estimatedMileage.font = FONT_ZITI(20);
        _estimatedMileage.textColor = [UIColor whiteColor];
        [self addSubview:_estimatedMileage];
        [_estimatedMileage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(titleLab);
            make.bottom.equalTo(titleLab.mas_top).offset(-5);
            make.height.mas_equalTo(23);
        }];
//        [self setTextColor:_estimatedMileage FontNumber:FONT_ZITI(13) AndRange:NSMakeRange(_estimatedMileage.text.length - 2, 2) AndColor:[UIColor whiteColor]];
        
        UIImageView *batteryImg = [[UIImageView alloc] init];
        batteryImg.image = [UIImage imageNamed:@"icon_bike_battery_power"];
        [self addSubview:batteryImg];
        [batteryImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_estimatedMileage);
            make.top.equalTo(titleLab.mas_bottom).offset(8);
            make.size.mas_equalTo(CGSizeMake(44, 22));
        }];
        
        _remainingPower = [[UILabel alloc] init];
        _remainingPower.textColor = [UIColor whiteColor];
        _remainingPower.text = @"0%";
        _remainingPower.font = FONT_ZITI(13);
        [self addSubview:_remainingPower];
        [_remainingPower mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(batteryImg.mas_centerY);
            make.centerX.equalTo(batteryImg.mas_centerX);
            make.height.mas_equalTo(20);
        }];
        
        _GPSSignalView = [[GPSSignalStrengthView alloc] init];
        _GPSSignalView.titleLab.text = @"GPS";
        [self addSubview:_GPSSignalView];
        [_GPSSignalView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self).offset(-2);
            make.left.equalTo(self).offset(K_X2 + 8);
            make.size.mas_equalTo(CGSizeMake(40, 8));
        }];
        
        _GSMSignalView = [[GPSSignalStrengthView alloc] init];
        _GSMSignalView.titleLab.text = @"GSM";
        [self addSubview:_GSMSignalView];
        [_GSMSignalView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self).offset(-2);
            make.right.equalTo(self).offset(-8);
            make.size.mas_equalTo(CGSizeMake(40, 8));
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

- (void)drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    //背景颜色设置
    [[[UIColor blackColor] colorWithAlphaComponent:0.0f] set];
    CGContextFillRect(context, rect);
    
    //边框
//    CGContextSetLineWidth(context, 2.0);
//    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
//    CGFloat dashArray[] = {1, 4};//表示先画1个点再画4个点（前者小后者大时，虚线点小且间隔大；前者大后者小时，虚线点大且间隔小）
//    CGContextSetLineDash(context, 1, dashArray, 2);//其中的2表示dashArray中的值的个数
    //方法1 正方形起点-终点
//        CGContextMoveToPoint(context, K_X, K_Y);
//        CGContextAddLineToPoint(context, K_X+K_W, K_Y);
//        CGContextAddLineToPoint(context, K_X+K_W, K_Y+K_H);
//        CGContextAddLineToPoint(context, K_X, K_Y+K_H);
//        CGContextAddLineToPoint(context, K_X, K_Y);
    //方法2 正方形起点-终点
    CGPoint pointsRect[5] = {CGPointMake(K_X, K_Y), CGPointMake(K_X+K_W, K_Y), CGPointMake(K_X+K_W, K_Y+K_H), CGPointMake(K_X2, K_Y+K_H), CGPointMake(K_X, K_Y)};
    CGContextAddLines(context, pointsRect, 5);
    //方法3 方形起点-终点
//    CGContextAddRect(context, CGRectMake(K_X, K_Y, K_W, K_H));
    //填充
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:0.5].CGColor);
    //绘制路径及填充模式
    CGContextDrawPath(context, kCGPathFillStroke);
}


@end
