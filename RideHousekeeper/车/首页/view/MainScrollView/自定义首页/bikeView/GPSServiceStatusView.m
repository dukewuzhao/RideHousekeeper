//
//  GPSServiceStatusView.m
//  RideHousekeeper
//
//  Created by Apple on 2020/3/26.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import "GPSServiceStatusView.h"
#define K_X   0
#define K_X2  CGRectGetWidth(self.frame)
#define K_Y   CGRectGetHeight(self.frame)
#define K_Y2  0
@implementation GPSServiceStatusView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
        
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:UIRectCornerTopLeft cornerRadii:CGSizeMake(10, 10)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = self.bounds;
        maskLayer.path = maskPath.CGPath;
        self.layer.mask = maskLayer;
        
        _titleLab = [[UILabel alloc] init];
        _titleLab.text = @"试用";
        _titleLab.textColor = [UIColor whiteColor];
        _titleLab.font = FONT_PINGFAN(13);
        [self addSubview:_titleLab];
        [_titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(8);
            make.top.equalTo(self).offset(8);
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
    CGPoint pointsRect[4] = {CGPointMake(K_X, K_Y), CGPointMake(K_X, K_Y2),  CGPointMake(K_X2, K_Y2), CGPointMake(K_X, K_Y)};
    CGContextAddLines(context, pointsRect, 5);
    //方法3 方形起点-终点
//    CGContextAddRect(context, CGRectMake(K_X, K_Y, K_W, K_H));
    //填充
    CGContextSetFillColorWithColor(context, self.fillColor.CGColor);
    //绘制路径及填充模式
    CGContextDrawPath(context, kCGPathFillStroke);
}

- (void)setFillColor:(UIColor *)fillColor{
    _fillColor = fillColor;
    [self setNeedsDisplay];
}

@end
