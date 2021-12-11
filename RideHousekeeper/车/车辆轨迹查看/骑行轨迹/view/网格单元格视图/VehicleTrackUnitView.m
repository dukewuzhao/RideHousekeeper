//
//  VehicleTrackUnitView.m
//  RideHousekeeper
//
//  Created by Apple on 2020/3/5.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import "VehicleTrackUnitView.h"

@implementation VehicleTrackUnitView

- (instancetype)init{
    if (self = [super init]) {
        
        _unitValueLab = [[UILabel alloc] init];
        _unitValueLab.font = FONT_ZITI(23);
        _unitValueLab.textColor = [QFTools colorWithHexString:@"#333333"];
        [self addSubview:_unitValueLab];
        [_unitValueLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(30);
            make.top.equalTo(self).offset(20);
            make.height.mas_equalTo(30);
        }];
        
        _annotationLab = [[UILabel alloc] init];
        _annotationLab.font = FONT_PINGFAN(11);
        _annotationLab.textColor = [QFTools colorWithHexString:@"#999999"];
        [self addSubview:_annotationLab];
        [_annotationLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).offset(-10);
            make.bottom.equalTo(self).offset(-10);
            make.height.mas_equalTo(16);
        }];
        
    }
    return self;
}

@end
