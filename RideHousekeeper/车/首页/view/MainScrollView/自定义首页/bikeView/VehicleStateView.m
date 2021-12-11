//
//  VehicleStateView.m
//  RideHousekeeper
//
//  Created by Apple on 2018/2/26.
//  Copyright © 2018年 Duke Wu. All rights reserved.
//

#import "VehicleStateView.h"
@interface VehicleStateView()

@end
@implementation VehicleStateView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        //self.layer.contents = (id)[UIImage imageNamed:@"bike_control_bottom_bg"].CGImage;
        
        [self setupUI];
    }
    return self;
}

-(void)setupUI{
    
    [self setupFootView:0];
    
}

//- (void)mas_distributeViewsAlongAxis:(MASAxisType)axisType withFixedItemLength:(CGFloat)fixedItemLength leadSpacing:(CGFloat)leadSpacing tailSpacing:(CGFloat)tailSpacing
//- (void)mas_distributeViewsAlongAxis:(MASAxisType)axisType withFixedSpacing:(CGFloat)fixedSpacing leadSpacing:(CGFloat)leadSpacing tailSpacing:(CGFloat)tailSpacing


-(void)setupFootView:(NSInteger)keyversionvalue{
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    if (keyversionvalue == 2 || keyversionvalue == 6 || keyversionvalue == 9) {
        _chamberpot = YES;
    }else{
        _chamberpot = NO;
    }
    
    if (_chamberpot) {
        for (int i = 0; i<4; i++) {
            UIButton *controlerBtn = [[UIButton alloc] initWithFrame:CGRectZero];
            UILabel *bikesearch = [[UILabel alloc] initWithFrame:CGRectZero];
            controlerBtn.tag = 20+i;
            bikesearch.tag = 100+i;
            
            if (controlerBtn.tag == 20) {
                _bikeUnLockBtn = controlerBtn;
                [controlerBtn setBackgroundImage:[UIImage imageNamed:NSLocalizedString(@"bike_unlock_icon", nil)] forState:UIControlStateNormal];
            }else if (controlerBtn.tag == 21){
                _bikeLockBtn = controlerBtn;
                [controlerBtn setBackgroundImage:[UIImage imageNamed:NSLocalizedString(@"bike_lock_icon", nil)] forState:UIControlStateNormal];
            }else if (controlerBtn.tag == 22){
                _bikeSwitchBtn = controlerBtn;
                [controlerBtn setBackgroundImage:[UIImage imageNamed:NSLocalizedString(@"icon_bike_switch", nil)] forState:UIControlStateNormal];
            }else if (controlerBtn.tag == 23){
                _bikeSeatBtn = controlerBtn;
                [controlerBtn setBackgroundImage:[UIImage imageNamed:NSLocalizedString(@"bike_seat_icon", nil)] forState:UIControlStateNormal];
            }
            
            if (bikesearch.tag == 100) {
                
                _bikeUnLockLabel = bikesearch;
                bikesearch.text = NSLocalizedString(@"解锁", nil);
                
            }else if (bikesearch.tag == 101){
                
                _bikeLockLabel = bikesearch;
                bikesearch.text = NSLocalizedString(@"上锁", nil);
                
            }else if (bikesearch.tag == 102){
                _bikeSwitchLabel = bikesearch;
                bikesearch.text = NSLocalizedString(@"电门", nil);
            }else if (bikesearch.tag == 103){
                _bikeSeatLabel = bikesearch;
                bikesearch.text = NSLocalizedString(@"座桶", nil);
            }
            bikesearch.textColor = [QFTools colorWithHexString:@"#666666"];
            bikesearch.textAlignment = NSTextAlignmentCenter;
            [self addSubview:bikesearch];
            [controlerBtn addTarget:self action:@selector(controlerClick:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:controlerBtn];
        }
        
        [@[_bikeUnLockBtn,_bikeLockBtn, _bikeSwitchBtn,_bikeSeatBtn] mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedItemLength:50 leadSpacing:15 tailSpacing:15];
        [@[_bikeUnLockBtn,_bikeLockBtn, _bikeSwitchBtn,_bikeSeatBtn] mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self);
            make.height.mas_equalTo(50);
        }];
        
        [@[_bikeUnLockLabel,_bikeLockLabel,_bikeSwitchLabel,_bikeSeatLabel] mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedItemLength:50 leadSpacing:15 tailSpacing:15];
        [@[_bikeUnLockLabel,_bikeLockLabel,_bikeSwitchLabel,_bikeSeatLabel] mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_bikeLockBtn.mas_bottom).offset(10);
            make.height.mas_equalTo(15);
        }];
        
//        UIImageView *imageView = [[UIImageView alloc] init];
//        imageView.backgroundColor = [UIColor blackColor];
//        imageView.image = [UIImage imageNamed:NSLocalizedString(@"icon_bike_switch", nil)];
//        [self addSubview:imageView];
//        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.top.right.bottom.equalTo(_bikeSwitchBtn);
//        }];
        
    }else{
        for (int i = 0; i<3; i++) {
            UIButton *controlerBtn = [[UIButton alloc] initWithFrame:CGRectZero];
            UILabel *bikesearch = [[UILabel alloc] initWithFrame:CGRectZero];
            controlerBtn.tag = 20+i;
            bikesearch.tag = 100+i;
            
            if (controlerBtn.tag == 20) {
                _bikeUnLockBtn = controlerBtn;
                [controlerBtn setBackgroundImage:[UIImage imageNamed:NSLocalizedString(@"bike_unlock_icon", nil)] forState:UIControlStateNormal];
            }else if (controlerBtn.tag == 21){
                _bikeLockBtn = controlerBtn;
                [controlerBtn setBackgroundImage:[UIImage imageNamed:NSLocalizedString(@"bike_lock_icon", nil)] forState:UIControlStateNormal];
            }else if (controlerBtn.tag == 22){
                _bikeSwitchBtn = controlerBtn;
                [controlerBtn setBackgroundImage:[UIImage imageNamed:NSLocalizedString(@"icon_bike_switch", nil)] forState:UIControlStateNormal];
            }
            
            if (bikesearch.tag == 100) {
                
                _bikeUnLockLabel = bikesearch;
                bikesearch.text = NSLocalizedString(@"解锁", nil);
                
            }else if (bikesearch.tag == 101){
                
                _bikeLockLabel = bikesearch;
                bikesearch.text = NSLocalizedString(@"上锁", nil);
                
            }else if (bikesearch.tag == 102){
                _bikeSwitchLabel = bikesearch;
                bikesearch.text = NSLocalizedString(@"电门", nil);
            }
            bikesearch.textColor = [QFTools colorWithHexString:@"#666666"];
            bikesearch.textAlignment = NSTextAlignmentCenter;
            [self addSubview:bikesearch];
            [controlerBtn addTarget:self action:@selector(controlerClick:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:controlerBtn];
        }
        
        [@[_bikeUnLockBtn,_bikeLockBtn, _bikeSwitchBtn] mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedItemLength:50 leadSpacing:15 tailSpacing:15];
        [@[_bikeUnLockBtn,_bikeLockBtn, _bikeSwitchBtn] mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self);
            make.height.mas_equalTo(50);
        }];
        
        [@[_bikeUnLockLabel,_bikeLockLabel, _bikeSwitchLabel] mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedItemLength:50 leadSpacing:15 tailSpacing:15];
        [@[_bikeUnLockLabel,_bikeLockLabel, _bikeSwitchLabel] mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_bikeLockBtn.mas_bottom).offset(15).priorityLow();;
            make.height.mas_equalTo(15);
            make.trailing.bottom.lessThanOrEqualTo(self).offset(-5);
        }];
    }
}



-(void)controlerClick:(UIButton *)btn{
    if (self.bikeControlClickBlock) {
        self.bikeControlClickBlock(btn.tag);
    }
}

@end
