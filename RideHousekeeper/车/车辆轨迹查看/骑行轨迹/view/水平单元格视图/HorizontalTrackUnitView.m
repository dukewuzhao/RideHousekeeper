//
//  HorizontalTrackUnitView.m
//  RideHousekeeper
//
//  Created by Apple on 2020/3/5.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import "HorizontalTrackUnitView.h"

@implementation HorizontalTrackUnitView

- (instancetype)init{
    if (self = [super init]) {
        
        _unitValueLab = [[UILabel alloc] init];
        _unitValueLab.font = FONT_PINGFAN(15);
        _unitValueLab.textColor = [QFTools colorWithHexString:@"#333333"];
        [self addSubview:_unitValueLab];
        [_unitValueLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.bottom.equalTo(self.mas_centerY).offset(-5);
            make.height.mas_equalTo(21);
        }];
        
        _annotationLab = [[UILabel alloc] init];
        _annotationLab.font = FONT_PINGFAN(10);
        _annotationLab.textColor = [QFTools colorWithHexString:@"#999999"];
        [self addSubview:_annotationLab];
        [_annotationLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.top.equalTo(self.mas_centerY).offset(5);
            make.height.mas_equalTo(14);
        }];
        
    }
    return self;
}

@end
