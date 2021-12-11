//
//  GPSPaopaoView.m
//  RideHousekeeper
//
//  Created by 吴兆华 on 2018/3/11.
//  Copyright © 2018年 Duke Wu. All rights reserved.
//

#import "GPSPaopaoView.h"
#import "GPSSignalStrengthView.h"
@interface GPSPaopaoView()
@property (nonatomic, strong) UILabel    *locationAddress;
@property (nonatomic, strong) UILabel    *locationTime;
@property (nonatomic, strong) GPSSignalStrengthView    *GPSSignalView;
@end

@implementation GPSPaopaoView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
    }
    return self;
}

- (void)setBikeStatusPosModel:(BikeStatusPosModel *)model{
    
    if ([QFTools isBlankString:model.desc]) {
        self.locationAddress.text = @"";
        return;
    }
    
    NSString *timeStr = [NSString stringWithFormat:@"数据更新：%@   %@",[QFTools stringFromInt:@"yyyy-MM-dd" :model.ts],[self intervalSinceNow:[QFTools stringFromInt:nil :model.ts]]];
    self.locationTime.text = timeStr;
    
    NSMutableAttributedString * timeAttriStr = [[NSMutableAttributedString alloc] initWithString:model.desc];
    NSMutableParagraphStyle *timeParagraphStyle = [[NSMutableParagraphStyle alloc] init];
    timeParagraphStyle.headIndent = 15;
    NSTextAttachment *timeAttchImage = [[NSTextAttachment alloc] init];
    timeAttchImage.image = [UIImage imageNamed:@"navigation _arrow"];
    timeAttchImage.bounds = CGRectMake(0, -4, 15, 15);
    NSAttributedString *timeStringImage = [NSAttributedString attributedStringWithAttachment:timeAttchImage];
    [timeAttriStr insertAttributedString:timeStringImage atIndex:0];
    [timeAttriStr addAttribute:NSParagraphStyleAttributeName value:timeParagraphStyle range:NSMakeRange(0, model.desc.length)];
    self.locationAddress.attributedText = timeAttriStr;
    
}

/**
 
 * 计算指定时间与当前的时间差
 
 * @param compareDate   某一指定时间
 
 * @return 多少(秒or分or天or月or年)+前 (比如，3天前、10分钟前)
 
 */
 
- (NSString *)intervalSinceNow: (NSString *) theDate{

    NSDateFormatter *date=[[NSDateFormatter alloc] init];

    [date setDateFormat:@"yyyy-MM-dd HH:mm:ss"];

    NSDate *d=[date dateFromString:theDate];

    NSTimeInterval late=[d timeIntervalSince1970]*1;

    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];

    NSTimeInterval now=[dat timeIntervalSince1970]*1;

    NSString *timeString=@"";
    NSTimeInterval cha = now - late;
//1589535412.4405241 1589509032
    if (cha/60<1){
//        timeString = [NSString stringWithFormat:@"%.0f", cha];
//        timeString=[NSString stringWithFormat:@"%@秒前", timeString];
        timeString = @"刚刚";

    }else if (cha/3600<1) {

        timeString = [NSString stringWithFormat:@"%.0f", cha/60];
        timeString=[NSString stringWithFormat:@"%@分钟前", timeString];

    }else if (cha/3600>1&&cha/86400<1) {

        timeString = [NSString stringWithFormat:@"%.0f", cha/3600];
        timeString=[NSString stringWithFormat:@"%@小时前", timeString];

    }else if (cha/86400>1){
        timeString = [NSString stringWithFormat:@"%.0f", cha/86400];
        timeString=[NSString stringWithFormat:@"%@天前", timeString];
    }
    return timeString;

}

-(void)setupUI{
    
    self.layer.cornerRadius = 10;
    self.layer.masksToBounds = YES;
    self.backgroundColor = [UIColor whiteColor];
    
    _GPSSignalView = [[GPSSignalStrengthView alloc] init];
    _GPSSignalView.titleLab.text = @"GPS";
    _GPSSignalView.titleLab.textColor = [QFTools colorWithHexString:MainColor];
    [self addSubview:_GPSSignalView];
    [_GPSSignalView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(10);
        make.right.equalTo(self).offset(-20);
        make.height.mas_equalTo(15);
    }];
    
    
    self.locationTime.font = FONT_PINGFAN(10);
    self.locationTime.text = @"数据更新：";
    self.locationTime.textColor = [QFTools colorWithHexString:@"#666666"];
    [self addSubview:self.locationTime];
    [self.locationTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(20);
        make.right.equalTo(_GPSSignalView.mas_left).offset(-10);
        make.top.equalTo(self).offset(10);
        make.height.mas_greaterThanOrEqualTo(20);
    }];
    
    self.locationAddress.font = FONT_PINGFAN(12);
    self.locationAddress.textColor = [UIColor blackColor];
    [self addSubview:self.locationAddress];
    [self.locationAddress mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(20);
        make.top.equalTo(self.locationTime.mas_bottom).offset(10);
        make.right.equalTo(self).offset(-10);
        make.height.mas_greaterThanOrEqualTo(20);
    }];
    
    UIButton *rideReportBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:rideReportBtn];
    rideReportBtn.layer.cornerRadius = 20;
    //rideReportBtn.layer.masksToBounds = YES;
    rideReportBtn.backgroundColor = [QFTools colorWithHexString:@"#F5F5F5"];
    [rideReportBtn setTitle:@"行车报告" forState:UIControlStateNormal];
    [rideReportBtn setTitleColor:[QFTools colorWithHexString:@"#06C1AE"] forState:UIControlStateNormal];
    rideReportBtn.titleLabel.font = FONT_PINGFAN(15);
    [rideReportBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.locationAddress.mas_bottom).offset(20);
        make.right.equalTo(self).offset(-20);
        make.bottom.equalTo(self).offset(-20);
        make.size.mas_equalTo(CGSizeMake(120, 40));
    }];
    @weakify(self);
    [[rideReportBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        if (self.rideReportBtnClick) self.rideReportBtnClick();
    }];
    
    UIButton *navigationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:navigationBtn];
    navigationBtn.layer.cornerRadius = 20;
    //navigationBtn.layer.masksToBounds = YES;
    navigationBtn.backgroundColor = [QFTools colorWithHexString:@"#F5F5F5"];
    [navigationBtn setTitleColor:[QFTools colorWithHexString:@"#06C1AE"] forState:UIControlStateNormal];
    [navigationBtn setTitle:@"开始导航" forState:UIControlStateNormal];
    navigationBtn.titleLabel.font = FONT_PINGFAN(15);
    [navigationBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(20);
        make.bottom.equalTo(self).offset(-20);
        make.size.mas_equalTo(CGSizeMake(120, 40));
    }];
    
    [[navigationBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        if (self.navigationBtnClick) self.navigationBtnClick();
    }];
    
}

////画出尖尖
//- (void)drawRect:(CGRect)rect {
//    //拿到当前视图准备好的画板
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    //利用path进行绘制三角形
//    CGContextBeginPath(context);//标记
//
//    CGFloat startX = self.width/2 -8;
//    CGFloat startY = self.height - 10;
//    CGContextMoveToPoint(context, startX, startY);//设置起点
//
//    CGContextAddLineToPoint(context, startX + 8, startY + 8);
//
//    CGContextAddLineToPoint(context, startX + 16, startY);
//
//    CGContextClosePath(context);//路径结束标志，不写默认封闭
//
//    [[UIColor whiteColor] setFill]; //设置填充色
//    [[UIColor whiteColor] setStroke];
//
//    CGContextDrawPath(context, kCGPathFillStroke);//绘制路径path
//}

-(UILabel *)locationTime{
    
    if (!_locationTime) {
        _locationTime = [UILabel new];
        _locationTime.numberOfLines = 0;
        
    }
    return _locationTime;
}

-(UILabel *)locationAddress{
    
    if (!_locationAddress) {
        _locationAddress = [UILabel new];
        _locationAddress.numberOfLines = 0;
    }
    return _locationAddress;
}



@end
