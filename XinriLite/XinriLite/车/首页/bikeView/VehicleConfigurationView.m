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
        self.backgroundColor = [UIColor colorWithRed:17/255.0 green:19/255.0 blue:22/255.0 alpha:1];
        [self setupView];
    }
    return self;
}

-(void)setupView{
    
    float imageWith = self.width/3;
    float imageY = self.height*.25;
    float imgeSize = self.height *.4;
    [self addSubview:self.bikeTestImge];
    [self.bikeTestImge mas_makeConstraints:^(MASConstraintMaker *make){
        make.left.equalTo(self).offset(imageWith/2 - imgeSize/2);
        make.top.mas_equalTo(imageY);
        make.size.mas_equalTo(CGSizeMake(imgeSize, imgeSize));
    }];
    
    self.bikeTestLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.bikeTestLabel];
    [self.bikeTestLabel mas_makeConstraints:^(MASConstraintMaker *make){
        make.centerX.equalTo(self.bikeTestImge);
        make.bottom.equalTo(self).offset(-15);
        make.height.mas_equalTo(20);
    }];
    
    [self addSubview:self.bikeSetUpImge];
    [self.bikeSetUpImge mas_makeConstraints:^(MASConstraintMaker *make){
        make.centerX.equalTo(self);
        make.top.mas_equalTo(self.bikeTestImge);
        make.size.mas_equalTo(CGSizeMake(imgeSize, imgeSize));
    }];

    self.bikeSetUpLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.bikeSetUpLabel];
    [self.bikeSetUpLabel mas_makeConstraints:^(MASConstraintMaker *make){
        make.centerX.equalTo(self);
        make.top.equalTo(self.bikeTestLabel);
        make.height.mas_equalTo(20);
    }];

    [self addSubview:self.bikePartsManageImge];
    [self.bikePartsManageImge mas_makeConstraints:^(MASConstraintMaker *make){
        make.right.equalTo(self).offset(imgeSize/2 - imageWith/2);
        make.top.equalTo(self.bikeTestImge);
        make.size.mas_equalTo(CGSizeMake(imgeSize, imgeSize));
    }];

    self.bikePartsManageLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.bikePartsManageLabel];
    [self.bikePartsManageLabel mas_makeConstraints:^(MASConstraintMaker *make){
        make.centerX.equalTo(self.bikePartsManageImge);
        make.top.equalTo(self.bikeTestLabel);
        make.height.mas_equalTo(20);
    }];
    
    UILabel *title = [[UILabel alloc] init];
    title.textColor = [UIColor whiteColor];
    title.text = NSLocalizedString(@"vehicle_service", nil);
    title.font = FONT_PINGFAN(18);
    [self addSubview:title];
    [title mas_makeConstraints:^(MASConstraintMaker *make){
        make.left.equalTo(self.mas_left).offset(18);
        make.top.equalTo(self.mas_top);
        make.bottom.equalTo(self.bikeTestImge.mas_top);
    }];
    
    [self setupMaskView];
    
}

-(UIImageView *)bikeTestImge{
    
    if (!_bikeTestImge) {
        _bikeTestImge = [UIImageView new];
    }
    return _bikeTestImge;
}

-(UILabel *)bikeTestLabel{
    
    if (!_bikeTestLabel) {
        _bikeTestLabel = [UILabel new];
        _bikeTestLabel.font = [UIFont systemFontOfSize:14];
        _bikeTestLabel.textColor = [UIColor whiteColor];
    }
    return _bikeTestLabel;
}

-(UIImageView *)bikeSetUpImge{
    
    if (!_bikeSetUpImge) {
        _bikeSetUpImge = [UIImageView new];
    }
    return _bikeSetUpImge;
}

-(UILabel *)bikeSetUpLabel{
    
    if (!_bikeSetUpLabel) {
        _bikeSetUpLabel = [UILabel new];
        _bikeSetUpLabel.font = [UIFont systemFontOfSize:14];
        _bikeSetUpLabel.textColor = [UIColor whiteColor];
    }
    return _bikeSetUpLabel;
}



-(UIImageView *)bikePartsManageImge{
    
    if (!_bikePartsManageImge) {
        _bikePartsManageImge = [UIImageView new];
    }
    return _bikePartsManageImge;
}


-(UILabel *)bikePartsManageLabel{
    
    if (!_bikePartsManageLabel) {
        _bikePartsManageLabel = [UILabel new];
        _bikePartsManageLabel.font = [UIFont systemFontOfSize:14];
        _bikePartsManageLabel.textColor = [UIColor whiteColor];
    }
    return _bikePartsManageLabel;
}


-(UIView *)clickView{
    
    if (!_clickView) {
        _clickView = [UIView new];
        
    }
    return _clickView;
}

//-(void)setFrame:(CGRect)frame{
//
//    self.frame = frame;
//    //NSLog(@"%@",frame);
//}

-(void)setupMaskView{
    //NSLog(@"frame-->%@",NSStringFromCGRect(self.frame));
    float imageWith = self.width/3;
    [self.clickView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.clickView.frame = CGRectMake(0, 0, self.width, self.height);
    [self addSubview:self.clickView];
    for (int i = 0; i<3; i++) {
        UIView *maskview = [[UIView alloc] initWithFrame:CGRectMake(imageWith*i, 0, imageWith, self.height)];
        maskview.tag = 30+i;
        [self.clickView addSubview:maskview];
        maskview.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickImage:)];
        [maskview addGestureRecognizer:tap];
    }
}

-(void)clickImage:(UITapGestureRecognizer *)tap{
    
    if ([tap view].tag == 30) {
        
        if (self.bikeTestClickBlock) {
            self.bikeTestClickBlock();
        }
    }else if ([tap view].tag == 31){
        
        if (self.bikeSetUpClickBlock) {
            self.bikeSetUpClickBlock();
        }
    }else if ([tap view].tag == 32){
        
        if (self.bikePartsManagClickBlock) {
            self.bikePartsManagClickBlock();
        }
    }
}


- (void)setHaveGPS:(BOOL)haveGPS{
    _haveGPS = haveGPS;
    float imageWith = self.width/3;
    
    if (haveGPS) {
        
        float imageY = self.height*.1;
        float imgeSize = self.height *.5;
        self.bikeTestImge.frame = CGRectMake(imageWith/2 - imgeSize/2, imageY, imgeSize, imgeSize);
        
        self.bikeTestLabel.frame = CGRectMake(0, self.height*.9 - 15, imageWith, 20);
        
        self.bikeSetUpImge.frame = CGRectMake(imageWith+imageWith/2 - imgeSize/2, self.bikeTestImge.y, imgeSize, imgeSize);
        
        self.bikeSetUpLabel.frame = CGRectMake(imageWith, self.bikeTestLabel.y, imageWith, 20);

        self.bikePartsManageImge.frame = CGRectMake(imageWith*2+imageWith/2 - imgeSize/2, self.bikeTestImge.y, imgeSize, imgeSize);
        
        self.bikePartsManageLabel.frame = CGRectMake(imageWith*2, self.bikeTestLabel.y, imageWith, 20);
        
        [self setupMaskView];
    }else{
        
        float imageY = self.height*.15;
        float imgeSize = self.height *.4;
        self.bikeTestImge.frame = CGRectMake(imageWith/2 - imgeSize/2, imageY, imgeSize, imgeSize);
        
        self.bikeTestLabel.frame = CGRectMake(0, self.height *.85 - 15, imageWith, 20);
        
        self.bikeSetUpImge.frame = CGRectMake(imageWith+imageWith/2 - imgeSize/2, self.bikeTestImge.y, imgeSize, imgeSize);
        
        self.bikeSetUpLabel.frame = CGRectMake(imageWith, self.bikeTestLabel.y, imageWith, 20);
        
        self.bikePartsManageImge.frame = CGRectMake(imageWith*2+imageWith/2 - imgeSize/2, self.bikeTestImge.y, imgeSize, imgeSize);
        
        self.bikePartsManageLabel.frame = CGRectMake(imageWith*2, self.bikeTestLabel.y, imageWith, 20);
        
        [self setupMaskView];
    }
    [self layoutIfNeeded];
}



@end
