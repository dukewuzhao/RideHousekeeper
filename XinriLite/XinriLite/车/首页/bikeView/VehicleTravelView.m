//
//  VehicleTravelView.m
//  RideHousekeeper
//
//  Created by 吴兆华 on 2018/4/1.
//  Copyright © 2018年 Duke Wu. All rights reserved.
//

#import "VehicleTravelView.h"

@implementation VehicleTravelView

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
        
        self.dayMileageImg.frame = CGRectMake(self.height *.58, self.height/2 - self.height *.3, self.height *.6, self.height *.6);
        self.dayMileageImg.image = [UIImage imageNamed:@"day_mileage"];
        [self addSubview:self.dayMileageImg];
        
        self.dayMileageLab.text = @"36";
        self.dayMileageLab.frame = CGRectMake(CGRectGetMaxX(self.dayMileageImg.frame) + self.height *.25, self.dayMileageImg.y - 5, [self getViewSize:self.dayMileageLab.text :self.dayMileageLab.font].width, 25);
        
        [self addSubview:self.dayMileageLab];
        
        self.dayKMLab.frame = CGRectMake(CGRectGetMaxX(self.dayMileageLab.frame), self.dayMileageLab.y, 30, 15);
        self.dayKMLab.text = @"KM";
        [self addSubview:self.dayKMLab];
        
        self.dayMileageDes.frame = CGRectMake(self.dayMileageLab.x, CGRectGetMaxY(self.dayMileageImg.frame) - 10, 70, 20);
        self.dayMileageDes.text = NSLocalizedString(@"today_trip", nil);
        [self addSubview:self.dayMileageDes];
        
        self.splitView.frame = CGRectMake(self.width/2 - 2, 0, 4, self.height);
        [self addSubview:self.splitView];
        
        self.totalMileageImg.frame = CGRectMake(CGRectGetMaxX(self.splitView.frame) + self.height *.58, self.height/2 - self.height *.3, self.height *.6, self.height *.6);
        self.totalMileageImg.image = [UIImage imageNamed:@"total_mileage"];
        [self addSubview:self.totalMileageImg];
        
        self.totalMileageLab.text = @"136";
        self.totalMileageLab.frame = CGRectMake(CGRectGetMaxX(self.totalMileageImg.frame) + self.height *.25, self.totalMileageImg.y - 5, [self getViewSize:self.totalMileageLab.text :self.totalMileageLab.font].width, 25);
        [self addSubview:self.totalMileageLab];
        
        self.totalKMLab.frame = CGRectMake(CGRectGetMaxX(self.totalMileageLab.frame), self.totalMileageLab.y, 30, 15);
        self.totalKMLab.text = @"KM";
        [self addSubview:self.totalKMLab];
        
        self.totalMileageDes.frame = CGRectMake(self.totalMileageLab.x, self.dayMileageDes.y, 70, 15);
        self.totalMileageDes.text = NSLocalizedString(@"all_trip", nil);
        [self addSubview:self.totalMileageDes];
    }
    return self;
}

-(CGSize)getViewSize:(NSString *) title :(UIFont *)font{
    CGSize size = [title sizeWithAttributes:@{NSFontAttributeName: font}];
    //ceilf()向上取整函数, 只要大于1就取整数2. floor()向下取整函数, 只要小于2就取整数1.
    CGSize adaptionSize = CGSizeMake(ceilf(size.width), ceilf(size.height));
    return adaptionSize;
}

-(UIImageView *)dayMileageImg{
    if (!_dayMileageImg) {
        _dayMileageImg = [UIImageView new];
    }
    
    return _dayMileageImg;
}

-(UILabel *)dayMileageLab{
    if (!_dayMileageLab) {
        _dayMileageLab = [UILabel new];
        _dayMileageLab.textColor = [QFTools colorWithHexString:@"#333333"];
        _dayMileageLab.font = [UIFont fontWithName:@"Verdana-Bold" size:20];
        _dayMileageLab.textAlignment = NSTextAlignmentCenter;
    }
    
    return _dayMileageLab;
}

-(UILabel *)dayMileageDes{
    if (!_dayMileageDes) {
        _dayMileageDes = [UILabel new];
        _dayMileageDes.textColor = [QFTools colorWithHexString:@"#999999"];
        _dayMileageDes.font = [UIFont systemFontOfSize:13];
    }
    
    return _dayMileageDes;
}

-(UILabel *)dayKMLab{
    if (!_dayKMLab) {
        _dayKMLab = [UILabel new];
        _dayKMLab.textColor = [QFTools colorWithHexString:@"#333333"];
        _dayKMLab.font = [UIFont systemFontOfSize:14];
    }
    
    return _dayKMLab;
}

-(UIView *)splitView{
    
    if (!_splitView) {
        _splitView = [UIView new];
        
    }
    return _splitView;
    
}

-(UIImageView *)totalMileageImg{
    if (!_totalMileageImg) {
        _totalMileageImg = [UIImageView new];
    }
    
    return _totalMileageImg;
}

-(UILabel *)totalMileageLab{
    if (!_totalMileageLab) {
        _totalMileageLab = [UILabel new];
        _totalMileageLab.textColor = [QFTools colorWithHexString:@"#333333"];
        _totalMileageLab.font = [UIFont fontWithName:@"Verdana-Bold" size:20];
        _totalMileageLab.textAlignment = NSTextAlignmentCenter;
    }
    
    return _totalMileageLab;
}

-(UILabel *)totalMileageDes{
    if (!_totalMileageDes) {
        _totalMileageDes = [UILabel new];
        _totalMileageDes.textColor = [QFTools colorWithHexString:@"#999999"];
        _totalMileageDes.font = [UIFont systemFontOfSize:13];
    }
    
    return _totalMileageDes;
}

-(UILabel *)totalKMLab{
    if (!_totalKMLab) {
        _totalKMLab = [UILabel new];
        _totalKMLab.textColor = [QFTools colorWithHexString:@"#333333"];
        _totalKMLab.font = [UIFont systemFontOfSize:14];
    }
    
    return _totalKMLab;
}

@end
