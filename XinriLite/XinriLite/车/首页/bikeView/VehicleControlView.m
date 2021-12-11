//
//  VehicleControlView.m
//  RideHousekeeper
//
//  Created by Apple on 2018/2/26.
//  Copyright © 2018年 Duke Wu. All rights reserved.
//

#import "VehicleControlView.h"

@implementation VehicleControlView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        //self.backgroundColor = [QFTools colorWithHexString:@"#ebecf2"];
        self.layer.cornerRadius = 20;
        self.layer.masksToBounds = YES;
        //给图层添加一个有色边框
        self.layer.borderWidth = 1;
        self.layer.borderColor = [[QFTools colorWithHexString:@"#cb0016"] CGColor];
        [self setupUI];
    }
    return self;
}

-(void)setupUI{
    
    self.bikestateImge.image = [UIImage imageNamed:@"bike_BLE_braekconnect"];
    [self addSubview:self.bikestateImge];
    [self.bikestateImge mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.left.equalTo(self.mas_left).offset(20);
        make.size.mas_equalTo(CGSizeMake(25, 25));
    }];
    
    self.bikestateLabel.text = NSLocalizedString(@"no_connect_state", nil);
    self.bikestateLabel.textColor = [UIColor whiteColor];
    self.bikestateLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.bikestateLabel];
    [self.bikestateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.left.equalTo(self.bikestateImge.mas_right).offset(5);
        make.right.equalTo(self).offset(-20);
        make.height.mas_equalTo(20);
    }];
    
}



-(UIImageView *)bikestateImge{
    
    if (!_bikestateImge) {
        _bikestateImge = [UIImageView new];
    }
    return _bikestateImge;
}

-(UILabel *)bikestateLabel{
    
    if (!_bikestateLabel) {
        _bikestateLabel = [UILabel new];
        _bikestateLabel.textAlignment = NSTextAlignmentCenter;
        _bikestateLabel.font = [UIFont systemFontOfSize:16];
    }
    return _bikestateLabel;
}



@end
