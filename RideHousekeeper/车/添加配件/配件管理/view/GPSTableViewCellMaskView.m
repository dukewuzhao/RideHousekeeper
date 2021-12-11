//
//  GPSTableViewCellMaskView.m
//  RideHousekeeper
//
//  Created by 晶 on 2020/3/29.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import "GPSTableViewCellMaskView.h"
#define K_X   CGRectGetWidth(self.frame) - 66
#define K_Y   0
#define K_X2  CGRectGetWidth(self.frame)
#define K_Y2  66

@interface GPSTableViewCellMaskView()
@property(nonatomic,strong)UILabel *titleLab;
@property(nonatomic,strong)UIColor *fillColor;
@end

@implementation GPSTableViewCellMaskView

- (void)setType:(NSInteger)type{
    _type = type;
    
    switch (type) {
        case 0://试用
            
            _fillColor = [UIColor colorWithRed:126/255.0 green:223/255.0 blue:215/255.0 alpha:0.9];
            _titleLab.hidden = NO;
            _titleLab.text = @"试用";
            break;
        case 1://正式服务
            
            _fillColor = [UIColor clearColor];
            _titleLab.hidden = YES;
            break;
        case 2://停用
            
            _fillColor = [UIColor colorWithRed:250/255.0 green:17/255.0 blue:22/255.0 alpha:0.9];
            _titleLab.hidden = NO;
            _titleLab.text = @"停用";
            break;
        default:
            break;
    }
    [self setNeedsDisplay];
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
                
        _titleLab = [[UILabel alloc] init];
        _titleLab.text = @"试用";
        _titleLab.textColor = [UIColor whiteColor];
        _titleLab.font = FONT_PINGFAN(13);
        [self addSubview:_titleLab];
        [_titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).offset(-8);
            make.top.equalTo(self).offset(13);
            make.height.mas_equalTo(18);
        }];
        
        
    }
    return self;
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
    //方法2 三角行起点-终点
    CGPoint pointsRect[4] = {CGPointMake(K_X, K_Y), CGPointMake(K_X2, K_Y),  CGPointMake(K_X2, K_Y2), CGPointMake(K_X, K_Y)};
    CGContextAddLines(context, pointsRect, 5);
    //方法3 方形起点-终点
    //    CGContextAddRect(context, CGRectMake(K_X, K_Y, K_W, K_H));
    //填充
    CGContextSetFillColorWithColor(context, self.fillColor.CGColor);
    //绘制路径及填充模式
    CGContextDrawPath(context, kCGPathFillStroke);
}



@end
