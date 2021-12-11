//
//  WuPageControl.m
//  RideHousekeeper
//
//  Created by Apple on 2017/9/1.
//  Copyright © 2017年 Duke Wu. All rights reserved.
//

#import "WuPageControl.h"
#define dotW 20
#define magrin 8
@implementation WuPageControl

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = NO;
    }
    return self;
}

//- (void) setCurrentPage:(NSInteger)page {
//    [super setCurrentPage:page];
//    for (NSUInteger subviewIndex = 0; subviewIndex < [self.subviews count]; subviewIndex++) {
//
//        UIImageView* subview = [self.subviews objectAtIndex:subviewIndex];
//        CGSize size;
//        size.height = 5;
//        size.width = 12;
//        [subview setFrame:CGRectMake(subview.frame.origin.x, subview.frame.origin.y, size.width,size.height)];
//        if (subviewIndex == page) {
//
////            subview.layer.masksToBounds = YES;
////            subview.layer.cornerRadius = size.width/2;
//            [subview setBackgroundColor:[QFTools colorWithHexString:@"#31d9c9"]];
//        } else {
//
//            [subview setBackgroundColor:[UIColor colorWithRed:49/255.0 green:217/255.0 blue:201/255.0 alpha:0.5f]];
//        }
//    }
//}

- (void)layoutSubviews
{
    [super layoutSubviews];

    //计算圆点间距
    CGFloat marginX = dotW + magrin;

    //计算整个pageControll的宽度
    CGFloat newW = self.subviews.count * marginX - magrin;

    //设置新frame
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, newW, self.frame.size.height);

    //设置居中
    CGPoint center = self.center;
    center.x = self.superview.center.x;
    self.center = center;

    //遍历subview,设置圆点frame
    for (int i=0; i<[self.subviews count]; i++) {
        UIImageView* dot = [self.subviews objectAtIndex:i];

        if (i == self.currentPage) {
            [dot setFrame:CGRectMake(i * marginX, dot.centerY, dotW, 3)];
            //dot.image = [UIImage imageNamed:@"bike_select"];
        }else {
            [dot setFrame:CGRectMake(i * marginX, dot.centerY, dotW, 3)];
            //dot.image = [UIImage imageNamed:@"bike_unselect"];
        }
    }
}


- (void) setCurrentPage:(NSInteger)page {
    [super setCurrentPage:page];

    for (NSUInteger i =0; i < [self.subviews count]; i++) {
        UIView* dot = [self.subviews objectAtIndex:i];
        [dot setFrame:CGRectMake(dot.frame.origin.x, dot.frame.origin.y,dotW, 3)];
        if ([dot.subviews count] == 0) {
            UIImageView * view = [[UIImageView alloc]initWithFrame:dot.bounds];
            [dot addSubview:view];
        };
        UIImageView *imageView = dot.subviews[0];
        if (i == page) {
            imageView.image = [UIImage imageNamed:@"bike_select"];
        } else {
            imageView.image = [UIImage imageNamed:@"bike_unselect"];
        }
        dot.backgroundColor = [UIColor clearColor];
    }
}

@end
