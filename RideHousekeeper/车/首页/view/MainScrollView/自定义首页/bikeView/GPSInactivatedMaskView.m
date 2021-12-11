//
//  GPSInactivatedMaskView.m
//  RideHousekeeper
//
//  Created by Apple on 2020/3/26.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import "GPSInactivatedMaskView.h"

@implementation GPSInactivatedMaskView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
        
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(10, 10)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = self.bounds;
        maskLayer.path = maskPath.CGPath;
        self.layer.mask = maskLayer;
        
        UILabel* titleLab = [[UILabel alloc] init];
        titleLab.text = @"GPS设备未激活";
        titleLab.textColor = [UIColor whiteColor];
        titleLab.font = FONT_PINGFAN_BOLD(30);
        titleLab.textAlignment = NSTextAlignmentCenter;
        [self addSubview:titleLab];
        [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    return self;
}

@end
