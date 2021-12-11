//
//  VehicleConfigurationView.m
//  RideHousekeeper
//
//  Created by Apple on 2018/2/26.
//  Copyright © 2018年 Duke Wu. All rights reserved.
//

#import "VehicleConfigurationView.h"

@implementation VehicleConfigurationView

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
        [self setupView];
    }
    return self;
}

-(void)setupView{
    
    for (int i = 0; i<3; i++) {
        
        if (i == 0) {
            self.bikeTestLabel.text = @"故障检测";
            [self addSubview:self.bikeTestImge];
            [self addSubview:self.bikeTestLabel];
        }else if (i == 1){
            
            [self addSubview:self.bikeSetUpImge];
            [self addSubview:self.bikeSetUpLabel];
            self.bikeSetUpLabel.text = @"车辆设置";
        }else if (i == 2){
            
            self.bikePartsManageLabel.text = @"配件管理";
            [self addSubview:self.bikePartsManageImge];
            [self addSubview:self.bikePartsManageLabel];
        }
    }
    
    [@[self.bikeTestImge, self.bikeSetUpImge, self.bikePartsManageImge] mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedItemLength:50 leadSpacing:40 tailSpacing:40];
    [@[self.bikeTestImge, self.bikeSetUpImge, self.bikePartsManageImge] mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.height.mas_equalTo(50);
    }];
    
    [self.bikeTestLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bikeTestImge.mas_bottom).offset(7.5);
        make.centerX.equalTo(self.bikeTestImge);
        make.height.mas_equalTo(20);
    }];
    
    [self.bikeSetUpLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bikeSetUpImge.mas_bottom).offset(7.5);
        make.centerX.equalTo(self.bikeSetUpImge);
        make.height.mas_equalTo(20);
    }];
    
    [self.bikePartsManageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bikePartsManageImge.mas_bottom).offset(7.5);
        make.centerX.equalTo(self.bikePartsManageImge);
        make.height.mas_equalTo(20);
    }];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectZero];
    title.text = @"车辆服务";
    title.font = FONT_PINGFAN(17);
    [self addSubview:title];
    [title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(10);
        make.left.equalTo(self).offset(20);
        make.height.mas_equalTo(20);
    }];
    
    [self setupMaskView];
}

-(UIImageView *)bikeTestImge{
    
    if (!_bikeTestImge) {
        _bikeTestImge = [UIImageView new];
        _bikeTestImge.image = [UIImage imageNamed:@"vehicle_physical_examination"];
    }
    return _bikeTestImge;
}

-(UILabel *)bikeTestLabel{
    
    if (!_bikeTestLabel) {
        _bikeTestLabel = [UILabel new];
        _bikeTestLabel.font = [UIFont systemFontOfSize:15];
        _bikeTestLabel.textColor = [QFTools colorWithHexString:@"#111111"];
    }
    return _bikeTestLabel;
}

-(UIImageView *)bikeSetUpImge{
    
    if (!_bikeSetUpImge) {
        _bikeSetUpImge = [UIImageView new];
        _bikeSetUpImge.image = [UIImage imageNamed:@"vehicle_setting"];
    }
    return _bikeSetUpImge;
}

-(UILabel *)bikeSetUpLabel{
    
    if (!_bikeSetUpLabel) {
        _bikeSetUpLabel = [UILabel new];
        _bikeSetUpLabel.font = [UIFont systemFontOfSize:15];
        _bikeSetUpLabel.textColor = [QFTools colorWithHexString:@"#111111"];
    }
    return _bikeSetUpLabel;
}

-(UIImageView *)bikePartsManageImge{
    
    if (!_bikePartsManageImge) {
        _bikePartsManageImge = [UIImageView new];
        _bikePartsManageImge.image = [UIImage imageNamed:@"spare_parts_management"];
    }
    return _bikePartsManageImge;
}


-(UILabel *)bikePartsManageLabel{
    
    if (!_bikePartsManageLabel) {
        _bikePartsManageLabel = [UILabel new];
        _bikePartsManageLabel.font = [UIFont systemFontOfSize:15];
        _bikePartsManageLabel.textColor = [QFTools colorWithHexString:@"#111111"];
    }
    return _bikePartsManageLabel;
}


-(UIView *)clickView{
    
    if (!_clickView) {
        _clickView = [UIView new];
        
    }
    return _clickView;
}



-(void)setupMaskView{
    
    [self.clickView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self addSubview:self.clickView];
    [self.clickView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.bottom.equalTo(self);
    }];
    NSMutableArray *arry = [NSMutableArray array];
    for (int i = 0; i<3; i++) {
        UIView *maskview = [[UIView alloc] initWithFrame:CGRectZero];
        maskview.tag = 30+i;
        [self.clickView addSubview:maskview];
        maskview.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickImage:)];
        [maskview addGestureRecognizer:tap];
        [arry addObject:maskview];
    }
    
    [arry mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:0 leadSpacing:0 tailSpacing:0];
    [arry mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.bottom.equalTo(self);
    }];
}

-(void)clickImage:(UITapGestureRecognizer *)tap{
    
    if ([tap view].tag == 30) {
        
        if (_viewType == 1) {
            if (self.bikeTestClickBlock) {
                self.bikeTestClickBlock();
            }
        }else{
            if (self.RidingTrackClick) {
                self.RidingTrackClick();
            }
        }
        
    }else if ([tap view].tag == 31){
        
        if (self.bikeSetUpClickBlock) {
            self.bikeSetUpClickBlock();
        }
    }else if ([tap view].tag == 32){
        
        if (_viewType == 3) {
            if (self.PositioningServiceClick) {
                self.PositioningServiceClick();
            }
        }else{
            if (self.bikePartsManagClickBlock) {
                self.bikePartsManagClickBlock();
            }
        }
    }
}

- (void)setViewType:(NSInteger)viewType{
    _viewType = viewType;
    if (viewType == 3) {
        
        self.bikeTestImge.image = [UIImage imageNamed:@"icon_riding_track"];
        self.bikeTestLabel.text = @"行车报告";
        self.bikePartsManageImge.image = [UIImage imageNamed:@"icon_positioning_service"];
        self.bikePartsManageLabel.text = @"定位装置";
    }else if(viewType == 2){
        
        self.bikeTestImge.image = [UIImage imageNamed:@"icon_riding_track"];
        self.bikeTestLabel.text = @"行车报告";
        self.bikePartsManageImge.image = [UIImage imageNamed:@"spare_parts_management"];
        self.bikePartsManageLabel.text = @"配件管理";
    }else{
        
        self.bikeTestImge.image = [UIImage imageNamed:@"vehicle_physical_examination"];
        self.bikeTestLabel.text = @"故障检测";
        self.bikePartsManageImge.image = [UIImage imageNamed:@"spare_parts_management"];
        self.bikePartsManageLabel.text = @"配件管理";
    }
}



@end
