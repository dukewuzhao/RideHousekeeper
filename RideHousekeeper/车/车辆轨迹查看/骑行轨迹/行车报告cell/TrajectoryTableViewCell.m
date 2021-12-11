//
//  TrajectoryTableViewCell.m
//  RideHousekeeper
//
//  Created by 吴兆华 on 2018/3/11.
//  Copyright © 2018年 Duke Wu. All rights reserved.
//

#import "TrajectoryTableViewCell.h"
#import "WZHTapGestureRecognizer.h"
@interface TrajectoryTableViewCell ()
@property (strong, nonatomic) UIImageView *startImg;
@property (strong, nonatomic) UIImageView *endImg;
@end

@implementation TrajectoryTableViewCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        UIView *backView = [[UIView alloc] init];
        backView.layer.cornerRadius = 10;
        backView.backgroundColor = [QFTools colorWithHexString:@"#F5F5F5"];
        [self.contentView addSubview:backView];
        [backView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(70);
            make.top.equalTo(self.contentView).offset(5);
            make.right.equalTo(self.contentView).offset(-10);
            make.bottom.equalTo(self.contentView).offset(-5);
        }];
        
        _mainView = [[UIView alloc] init];
        [self.contentView addSubview:_mainView];
        _mainView.userInteractionEnabled = YES;
        WZHTapGestureRecognizer *tap = [[WZHTapGestureRecognizer alloc] initWithTarget:self action:@selector(clickMainView)];
        tap.delegate = (UITapGestureRecognizer<UIGestureRecognizerDelegate> *)tap;
        tap.numberOfTapsRequired = 1; //点击的次数 =1:单击
        [tap setNumberOfTouchesRequired:1];//1个手指操作
        [_mainView addGestureRecognizer:tap];
        [_mainView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(5);
            make.left.equalTo(self.contentView).offset(70);
            make.right.equalTo(self.contentView).offset(-10);
            make.bottom.equalTo(self.contentView).offset(-5);
        }];
        
        _linView = [[UIImageView alloc] init];
        _linView.backgroundColor = [QFTools colorWithHexString:@"#666666"];
        [self.contentView addSubview:_linView];
        [_linView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.mainView.mas_left).offset(-10);
            make.top.equalTo(self.contentView).priorityMedium();
            make.bottom.equalTo(self.contentView).priorityMedium();
            make.width.mas_equalTo(1);
        }];
        
        _timeLab = [[UILabel alloc] init];
        _timeLab.textColor = [QFTools colorWithHexString:@"#666666"];
        _timeLab.font = FONT_PINGFAN(12);
        _timeLab.text = @"08:35";
        [self.contentView addSubview:_timeLab];
        [_timeLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(10);
            make.centerY.equalTo(self.mainView.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(40, 15));
        }];
        
        _dotView = [[UIView alloc] init];
        _dotView.layer.borderWidth = 1;
        _dotView.layer.borderColor = [QFTools colorWithHexString:@"#7EDFD7"].CGColor;
        _dotView.backgroundColor = [QFTools colorWithHexString:@"#7EDFD7"];
        [self.contentView addSubview:_dotView];
        [_dotView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_linView);
            make.centerY.equalTo(self.mainView);
            make.size.mas_equalTo(CGSizeMake(10, 10));
        }];
        
        _startImg = [[UIImageView alloc] init];
        _startImg.image = [UIImage imageNamed:@"trajectory_start"];
        [_mainView addSubview:_startImg];
        [_startImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mainView.mas_top).offset(20);
            make.left.equalTo(_mainView).offset(10);
            make.size.mas_equalTo(CGSizeMake(15, 15));
        }];
        
        _startLab = [[UILabel alloc] init];
        _startLab.font = FONT_PINGFAN(13);
        _startLab.text = @"春申路";
        _startLab.textColor = [QFTools colorWithHexString:@"#333333"];
        [_mainView addSubview:_startLab];
        [_startLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_startImg);
            make.centerX.equalTo(self.mainView);
            make.left.equalTo(_startImg.mas_right).offset(10);
            make.height.mas_equalTo(20);
        }];
        
        _endImg = [[UIImageView alloc] init];
        _endImg.image = [UIImage imageNamed:@"trajectory_end"];
        [_mainView addSubview:_endImg];
        [_endImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_startImg.mas_bottom).offset(10);
            make.left.equalTo(_startImg);
            make.size.mas_equalTo(CGSizeMake(15, 15));
        }];

        _endLab = [[UILabel alloc] init];
        _endLab.font = FONT_PINGFAN(13);
        _endLab.text = @"龙吴路";
        _endLab.textColor = [QFTools colorWithHexString:@"#333333"];
        [_mainView addSubview:_endLab];
        [_endLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_endImg);
            make.centerX.equalTo(self.mainView);
            make.left.equalTo(_startLab);
            make.height.mas_equalTo(20);
        }];

        UIImageView *mileageImg = [[UIImageView alloc] init];
        mileageImg.image = [UIImage imageNamed:@"part_riding_mileage_icon"];
        [_mainView addSubview:mileageImg];
        [mileageImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_mainView).offset(12);
            make.bottom.equalTo(_mainView.mas_bottom).offset(-10);
            make.size.mas_equalTo(CGSizeMake(10, 10));
        }];
        
        _mileageLab = [[UILabel alloc] init];
        _mileageLab.font = FONT_PINGFAN(10);
        _mileageLab.text = @"20.2km";
        _mileageLab.textColor = [QFTools colorWithHexString:@"#666666"];
        [_mainView addSubview:_mileageLab];
        [_mileageLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(mileageImg.mas_right).offset(5);
            make.centerY.equalTo(mileageImg);
            make.height.mas_equalTo(15);
        }];

        _timeConsumingLab = [[UILabel alloc] init];
        _timeConsumingLab.font = FONT_PINGFAN(11);
        _timeConsumingLab.text = @"12.5分钟";
        _timeConsumingLab.textColor = [QFTools colorWithHexString:@"#666666"];
        [_mainView addSubview:_timeConsumingLab];
        [_timeConsumingLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_mileageLab.mas_right).offset(45);
            make.top.equalTo(_mileageLab);
            make.height.mas_equalTo(15);
        }];

        UIImageView *timeConsumingImg = [[UIImageView alloc] init];
        timeConsumingImg.image = [UIImage imageNamed:@"part_ride_time_icon"];
        [_mainView addSubview:timeConsumingImg];
        [timeConsumingImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(_timeConsumingLab.mas_left).offset(-5);
            make.bottom.equalTo(mileageImg);
            make.size.mas_equalTo(CGSizeMake(10, 10));
        }];
        
        _speedImgLab = [[UILabel alloc] init];
        _speedImgLab.font = FONT_PINGFAN(11);
        _speedImgLab.text = @"30.0km/h";
        _speedImgLab.textColor = [QFTools colorWithHexString:@"#666666"];
        [_mainView addSubview:_speedImgLab];
        [_speedImgLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_timeConsumingLab.mas_right).offset(45);
            make.top.equalTo(_mileageLab);
            make.height.mas_equalTo(15);
            //make.bottom.equalTo(_mainView.mas_bottom).offset(-10);
        }];

        UIImageView *speedImg = [[UIImageView alloc] init];
        speedImg.image = [UIImage imageNamed:@"part_average_speed_icon"];
        [_mainView addSubview:speedImg];
        [speedImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(_speedImgLab.mas_left).offset(-5);
            make.bottom.equalTo(mileageImg);
            make.size.mas_equalTo(CGSizeMake(10, 10));
        }];
        
        UIImageView *arrowImg = [[UIImageView alloc] init];
        arrowImg.image = [UIImage imageNamed:@"arrow"];
        [_mainView addSubview:arrowImg];
        [arrowImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(_mainView).offset(-23);
            make.centerY.equalTo(_mainView);
        }];
    }
    return self;
}

-(void)clickMainView{
    
    if (self.trajectoryClickBlock) {
        self.trajectoryClickBlock();
    }
}
/*
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return [gestureRecognizer gestureRecognizer:gestureRecognizer shouldReceiveTouch:touch];
}
*/

- (UIImage *)drawLineOfDashByImageView:(UIImageView *)imageView {
    // 开始划线 划线的frame
    UIGraphicsBeginImageContext(imageView.frame.size);

    [imageView.image drawInRect:CGRectMake(0, 0, imageView.frame.size.width, imageView.frame.size.height)];

    // 获取上下文
    CGContextRef line = UIGraphicsGetCurrentContext();

    // 设置线条终点的形状
    CGContextSetLineCap(line, kCGLineCapRound);
    // 设置虚线的长度 和 间距
    CGFloat lengths[] = {5,3};

    CGContextSetStrokeColorWithColor(line, [QFTools colorWithHexString:@"#707070"].CGColor);
    
    CGContextSetLineWidth(line, 1);
    
    // 开始绘制虚线
    CGContextSetLineDash(line, 0, lengths, 2);

    CGContextMoveToPoint(line, 0, 0);

    CGContextAddLineToPoint(line, 0, imageView.height);

    CGContextStrokePath(line);

    // UIGraphicsGetImageFromCurrentImageContext()返回的就是image
    return UIGraphicsGetImageFromCurrentImageContext();
}

- (void)layoutSubviews{
    [super layoutSubviews];
    //self.linView.frame
    NSLog(@"%@",NSStringFromCGRect(self.linView.frame));
    //self.linView.image = [self drawLineOfDashByImageView:self.linView];
}

@end
