//
//  VehiclePositioningMapView.m
//  RideHousekeeper
//
//  Created by Apple on 2018/2/27.
//  Copyright © 2018年 Duke Wu. All rights reserved.
//

#import "VehiclePositioningMapView.h"

@implementation VehiclePositioningMapView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        
        self.maskView.frame = CGRectMake(0, -1, self.width, self.height);
        self.maskView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickMaskView)];
        [self.maskView addGestureRecognizer:tap];
        [self addSubview:self.maskView];
    }
    return self;
}

-(void)clickMaskView{
    
    if (self.bikeMapClickBlock) {
        self.bikeMapClickBlock();
    }
}






-(UIView *)maskView{
    
    if (!_maskView) {
        _maskView = [UIView new];
    }
    return _maskView;
}


@end
