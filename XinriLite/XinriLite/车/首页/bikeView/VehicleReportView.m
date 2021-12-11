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
        self.backgroundColor = [UIColor whiteColor];
        
        self.reportImg.frame = CGRectMake(10, self.height/2 - 12.5, 25, 25);
        self.reportImg.image = [UIImage imageNamed:@"bike_report"];
        [self addSubview:self.reportImg];
        
        self.reportLab.frame = CGRectMake(CGRectGetMaxX(self.reportImg.frame)+10, self.height/2 - 10, 100, 20);
        self.reportLab.text = NSLocalizedString(@"driving_report", nil);
        [self addSubview:self.reportLab];
        
        self.maskView.frame = CGRectMake(0, -1, self.width, self.height);
        self.maskView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickMaskView)];
        [self.maskView addGestureRecognizer:tap];
        [self addSubview:self.maskView];
    }
    return self;
}

-(void)clickMaskView{
    
    if (self.bikeReportClickBlock) {
        self.bikeReportClickBlock();
    }
}

-(UIImageView *)reportImg{
    if (!_reportImg) {
        _reportImg = [UIImageView new];
    }
    
    return _reportImg;
}

-(UILabel *)reportLab{
    if (!_reportLab) {
        _reportLab = [UILabel new];
        _reportLab.textColor = [QFTools colorWithHexString:@"#111111"];
        _reportLab.font = [UIFont systemFontOfSize:16];
    }
    
    return _reportLab;
}

-(UIView *)maskView{
    
    if (!_maskView) {
        _maskView = [UIView new];
    }
    return _maskView;
}

@end
