//
//  MultipleBindingLogicProcessingFootView.m
//  RideHousekeeper
//
//  Created by Apple on 2019/12/5.
//  Copyright © 2019 Duke Wu. All rights reserved.
//

#import "MultipleBindingLogicProcessingFootView.h"

@interface MultipleBindingLogicProcessingFootView()
@property (nonatomic,strong) UILabel *WarningLab;
@property (nonatomic,strong) UIButton *ClickBtn;
@property (nonatomic,strong) UIImageView *WarningImg;
@end

@implementation MultipleBindingLogicProcessingFootView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithType:(ProcessingtType)type{
    if (self = [super init]) {
        switch (type) {
            case DuplicateBinding:
                [self setupDuplicateBindingFoot];
            break;
            case DuplicateChangeGPS:
                [self setupDuplicateChangeGPSFoot];
            break;
            case SingleGPSBinding:
                [self setupSingleGPSBindingFoot];
            break;
            case AccessoriesGPSBinding:
                [self setupAccessoriesGPSbBindingFoot];
            break;
            case GPSKitWithECU:
                [self setupGPSKitFoot];
            break;
            case UnbindingBike:
                [self setupUnbindingBikeFoot];
            break;
            case UnbindingGPS:
                [self setupUnbindingGPSFoot];
            break;
            case UnbindingSingelGPS:
                [self setupUnbindingGPSFoot];
            break;
            default:
            break;
        }
    }
    return self;
}

-(void)setupDuplicateBindingFoot{
    
    [self addSubview:self.ClickBtn ];
    [self.ClickBtn setTitle:@"强制绑定" forState:UIControlStateNormal];
    [self.ClickBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.ClickBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self).offset(10);
        make.size.mas_equalTo(CGSizeMake(170, 40));
    }];
    @weakify(self);
    [[self.ClickBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        if (self.bindingBike) {
            self.bindingBike();
        }
    }];
    
    
    [self addSubview:self.WarningImg];
    self.WarningImg.image = [UIImage imageNamed:@"icon_binding_warning"];
    [self.WarningImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(35);
        make.top.equalTo(self.ClickBtn.mas_bottom).offset(60);
        make.bottom.equalTo(self).offset(-25);
        make.size.mas_equalTo(CGSizeMake(45, 45));
    }];
    
    [self addSubview:self.WarningLab];
    self.WarningLab.textAlignment = NSTextAlignmentLeft;
    self.WarningLab.text = @"强制绑定车辆会使当前车辆用户强制解绑车辆\n车辆信息会被清空，仅保留配件，请谨慎操作";
    self.WarningLab.textColor = [UIColor blackColor];
    [self.WarningLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.WarningImg.mas_right).offset(15);
        make.right.equalTo(self).offset(-30);
        make.centerY.equalTo(self.WarningImg);
    }];
    
}

-(void)setupDuplicateChangeGPSFoot{
    
    [self addSubview:self.ClickBtn ];
    [self.ClickBtn setTitle:@"强制绑定" forState:UIControlStateNormal];
    [self.ClickBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.ClickBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self).offset(10);
        make.size.mas_equalTo(CGSizeMake(170, 40));
    }];
    @weakify(self);
    [[self.ClickBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        if (self.bindingBike) {
            self.bindingBike();
        }
    }];
    
    
    [self addSubview:self.WarningImg];
    self.WarningImg.image = [UIImage imageNamed:@"icon_binding_warning"];
    [self.WarningImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(35);
        make.top.equalTo(self.ClickBtn.mas_bottom).offset(60);
        make.bottom.equalTo(self).offset(-25);
        make.size.mas_equalTo(CGSizeMake(45, 45));
    }];
    
    [self addSubview:self.WarningLab];
    self.WarningLab.textAlignment = NSTextAlignmentLeft;
    self.WarningLab.text = @"强制绑定定位器会使当前绑定用户强制删除配件定位器 ，原用户定位器信息也会被清空，请谨慎操作";
    self.WarningLab.textColor = [UIColor blackColor];
    [self.WarningLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.WarningImg.mas_right).offset(15);
        make.right.equalTo(self).offset(-30);
        make.centerY.equalTo(self.WarningImg);
    }];
}

-(void)setupSingleGPSBindingFoot{
//    [self addSubview:self.WarningLab];
//    self.WarningLab.text = @"靠近车辆将自动搜索绑定车辆";
//    self.WarningLab.textColor = [UIColor blackColor];
//    [self.WarningLab mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerX.equalTo(self);
//        make.top.equalTo(self).offset(10);
//        make.height.mas_equalTo(20);
//        make.bottom.equalTo(self).offset(-135);
//        make.left.equalTo(self).offset(45);
//        make.right.equalTo(self).offset(-45);
//    }];
}


-(void)setupAccessoriesGPSbBindingFoot{
    [self addSubview:self.WarningLab];
    //self.WarningLab.text = @"靠近定位器后自动搜索绑定设备";
    self.WarningLab.textColor = [UIColor blackColor];
    [self.WarningLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self).offset(10);
        make.height.mas_equalTo(20);
        make.bottom.equalTo(self).offset(-135);
        make.left.equalTo(self).offset(45);
        make.right.equalTo(self).offset(-45);
    }];
}

-(void)setupGPSKitFoot{
    [self addSubview:self.WarningLab];
    self.WarningLab.text = @"请在车旁边长按钥匙解锁激活车辆\n再点击“绑定车辆”";
    self.WarningLab.textColor = [UIColor blackColor];
    [self.WarningLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self).offset(10);
        make.bottom.equalTo(self).offset(-135);
        make.left.equalTo(self).offset(45);
        make.right.equalTo(self).offset(-45);
    }];
}

-(void)setupUnbindingBikeFoot{
    
    [self addSubview:self.ClickBtn ];
    [self.ClickBtn setTitle:@"立即解绑" forState:UIControlStateNormal];
    [self.ClickBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.ClickBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self).offset(10);
        make.size.mas_equalTo(CGSizeMake(170, 40));
    }];
    
    @weakify(self);
    [[self.ClickBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        if (self.unbindBike) {
            self.unbindBike();
        }
    }];
    
    [self addSubview:self.forcedUnbundBtn];
    [self.forcedUnbundBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self.ClickBtn.mas_bottom).offset(10);
        make.height.mas_equalTo(35);
        make.bottom.equalTo(self).offset(-55);
    }];
    [[self.forcedUnbundBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        if (self.forceUnbind) {
            self.forceUnbind();
        }
    }];
    
}

-(void)setupUnbindingGPSFoot{
    [self addSubview:self.ClickBtn ];
    [self.ClickBtn setTitle:@"立即解绑" forState:UIControlStateNormal];
    [self.ClickBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.ClickBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self).offset(10);
        make.size.mas_equalTo(CGSizeMake(170, 40));
    }];
    
    @weakify(self);
    [[self.ClickBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        if (self.unbindBike) {
            self.unbindBike();
        }
    }];
    
    [self addSubview:self.forcedUnbundBtn];
    [self.forcedUnbundBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self.ClickBtn.mas_bottom).offset(10);
        make.height.mas_equalTo(35);
        make.bottom.equalTo(self).offset(-55);
    }];
    [[self.forcedUnbundBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        if (self.forceUnbind) {
            self.forceUnbind();
        }
    }];
}

-(UIButton *)ClickBtn{
    if (!_ClickBtn) {
        _ClickBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _ClickBtn.backgroundColor = [UIColor colorWithRed:25.0/255 green:182.0/255 blue:157.0/255 alpha:1.0];
        _ClickBtn.titleLabel.font = FONT_PINGFAN(18);
        [_ClickBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _ClickBtn.layer.cornerRadius=20.0;
        _ClickBtn.layer.masksToBounds=YES;
        
    }
    return _ClickBtn;
}

-(UILabel *)WarningLab{
    if (!_WarningLab) {
        _WarningLab = [[UILabel alloc] init];
        _WarningLab.font = FONT_PINGFAN(12);
        _WarningLab.textAlignment = NSTextAlignmentCenter;
        _WarningLab.numberOfLines = 0;
    }
    return _WarningLab;
}

-(UIButton *)forcedUnbundBtn{
    if (!_forcedUnbundBtn) {
        _forcedUnbundBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _forcedUnbundBtn.backgroundColor = [UIColor whiteColor];
        [_forcedUnbundBtn setTitle:@"强制解绑" forState:UIControlStateNormal];
        _forcedUnbundBtn.titleLabel.font = FONT_PINGFAN(12);
        [_forcedUnbundBtn setTitleColor:[QFTools colorWithHexString:@"#666666"] forState:UIControlStateNormal];
    }
    return _forcedUnbundBtn;
}

-(UIImageView *)WarningImg{
    if (!_WarningImg) {
        _WarningImg = [[UIImageView alloc] init];
    }
    return _WarningImg;
}

@end
