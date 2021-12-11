//
//  TirePressureDisplay.m
//  RideHousekeeper
//
//  Created by Apple on 2019/7/11.
//  Copyright © 2019 Duke Wu. All rights reserved.
//

#import "TirePressureDisplay.h"
#import "TireStatusDisplayView.h"

@interface TirePressureDisplay()

@property (nonatomic, strong) UIImageView *frameImg;

@end

@implementation TirePressureDisplay

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)init{
    if (self = [super init]) {
        self.backgroundColor = [UIColor colorWithWhite:1 alpha:0.05];
        [self setupView];
    }
    return self;
}

-(void)setupView{
    
    [self addSubview:self.titlelab];
    [self.titlelab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(20);
        make.top.equalTo(self).offset(15);
        make.height.mas_equalTo(20);
    }];
    
    [self addSubview:self.frameImg];
    [self.frameImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
    }];
}


-(void)setNumberWheels:(NSInteger)numberWheels{
    _numberWheels = numberWheels;
    if (numberWheels == 0) {
        
        self.frameImg.image = [UIImage imageNamed:@"two_wheel_frame"];
        
        [self addSubview:self.firstWheelImg];
        [self.firstWheelImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.mas_centerX);
            make.bottom.equalTo(self.frameImg.mas_top);
            make.height.mas_equalTo(30);
            make.width.mas_equalTo(self.firstWheelImg.mas_height).multipliedBy(.5);
        }];
        
        [self addSubview:self.firstWheelView];
        [self.firstWheelView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.mas_centerX);
            make.size.mas_equalTo(CGSizeMake(50, 45));
            make.bottom.equalTo(self.firstWheelImg.mas_top).offset(-25);
        }];
        
        [self addSubview:self.secondWheelImg];
        [self.secondWheelImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.mas_centerX);
            make.top.equalTo(self.frameImg.mas_bottom);
            make.height.mas_equalTo(30);
            make.width.mas_equalTo(self.secondWheelImg.mas_height).multipliedBy(.5);
        }];
        
        [self addSubview:self.secondWheelView];
        [self.secondWheelView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.mas_centerX);
            make.size.mas_equalTo(CGSizeMake(50, 45));
            make.top.equalTo(self.secondWheelImg.mas_bottom).offset(25);
        }];
        
    }else if (numberWheels == 1){
        
        self.frameImg.image = [UIImage imageNamed:@"three_wheel_frame"];
        
        [self addSubview:self.firstWheelImg];
        [self.firstWheelImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.mas_centerX);
            make.bottom.equalTo(self.frameImg.mas_top);
            make.height.mas_equalTo(30);
            make.width.mas_equalTo(self.firstWheelImg.mas_height).multipliedBy(.5);
        }];
        
        [self addSubview:self.firstWheelView];
        [self.firstWheelView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.mas_centerX);
            make.size.mas_equalTo(CGSizeMake(50, 45));
            make.bottom.equalTo(self.firstWheelImg.mas_top).offset(-25);
        }];
        
        [self addSubview:self.secondWheelImg];
        [self.secondWheelImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.frameImg.mas_left);
            make.bottom.equalTo(self.frameImg.mas_bottom).offset(10);
            make.height.mas_equalTo(30);
            make.width.mas_equalTo(self.secondWheelImg.mas_height).multipliedBy(.5);
        }];
        
        [self addSubview:self.secondWheelView];
        [self.secondWheelView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(50, 45));
            make.right.equalTo(self.secondWheelImg.mas_left).offset(-25);
            make.top.equalTo(self.secondWheelImg.mas_bottom).offset(10);
        }];
        
        [self addSubview:self.thirdWheelImg];
        [self.thirdWheelImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.frameImg.mas_right);
            make.top.equalTo(self.secondWheelImg.mas_top);
            make.height.mas_equalTo(30);
            make.width.mas_equalTo(self.thirdWheelImg.mas_height).multipliedBy(.5);
        }];
        
        [self addSubview:self.thirdWheelView];
        [self.thirdWheelView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.thirdWheelImg.mas_right).offset(25);
            make.top.equalTo(self.thirdWheelImg.mas_bottom).offset(10);
            make.size.mas_equalTo(CGSizeMake(50, 45));
        }];
        [self setupLineView:numberWheels];
        
    }else if (numberWheels == 2){
        
        self.frameImg.image = [UIImage imageNamed:@"four_wheel_frame"];
        
        [self addSubview:self.firstWheelImg];
        [self.firstWheelImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.frameImg.mas_left);
            make.bottom.equalTo(self.frameImg.mas_top).offset(20);
            make.height.mas_equalTo(30);
            make.width.mas_equalTo(self.firstWheelImg.mas_height).multipliedBy(.5);
        }];
        
        [self addSubview:self.firstWheelView];
        [self.firstWheelView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.firstWheelImg.mas_left).offset(-25);
            make.bottom.equalTo(self.firstWheelImg.mas_top).offset(-25);
            make.size.mas_equalTo(CGSizeMake(50, 45));
        }];

        [self addSubview:self.secondWheelImg];
        [self.secondWheelImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.frameImg.mas_right);
            make.top.equalTo(self.firstWheelImg.mas_top);
            make.height.mas_equalTo(30);
            make.width.mas_equalTo(self.secondWheelImg.mas_height).multipliedBy(.5);
        }];

        [self addSubview:self.secondWheelView];
        [self.secondWheelView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.secondWheelImg.mas_right).offset(25);
            make.bottom.equalTo(self.secondWheelImg.mas_top).offset(-25);
            make.size.mas_equalTo(CGSizeMake(50, 45));
        }];

        [self addSubview:self.thirdWheelImg];
        [self.thirdWheelImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.frameImg.mas_left);
            make.bottom.equalTo(self.frameImg.mas_bottom).offset(10);
            make.height.mas_equalTo(30);
            make.width.mas_equalTo(self.thirdWheelImg.mas_height).multipliedBy(.5);
        }];

        [self addSubview:self.thirdWheelView];
        [self.thirdWheelView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.thirdWheelImg.mas_left).offset(-25);
            make.top.equalTo(self.thirdWheelImg.mas_bottom).offset(25);
            make.size.mas_equalTo(CGSizeMake(50, 45));
        }];

        [self addSubview:self.fourthWheelImg];
        [self.fourthWheelImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.frameImg.mas_right);
            make.top.equalTo(self.thirdWheelImg.mas_top);
            make.height.mas_equalTo(30);
            make.width.mas_equalTo(self.fourthWheelImg.mas_height).multipliedBy(.5);
        }];

        [self addSubview:self.fourthWheelView];
        [self.fourthWheelView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.fourthWheelImg.mas_right).offset(25);
            make.top.equalTo(self.fourthWheelImg.mas_bottom).offset(25);
            make.size.mas_equalTo(CGSizeMake(50, 45));
        }];
        [self setupLineView:numberWheels];
    }
}

-(void)setupLineView:(NSInteger)num{
    
    if (num == 2) {
        
        UIView *upView = [[UIView alloc] init];
        upView.backgroundColor = [QFTools colorWithHexString:MainColor];
        [self addSubview:upView];
        [upView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.mas_centerX);
            make.top.equalTo(self.mas_top).offset(50);
            make.width.mas_equalTo(1);
            make.bottom.equalTo(self.frameImg.mas_top).offset(-25);
        }];
    }
    
    UIView *leftView = [[UIView alloc] init];
    leftView.backgroundColor = [QFTools colorWithHexString:MainColor];
    [self addSubview:leftView];
    [leftView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(80);
        make.centerY.equalTo(self.mas_centerY);
        make.height.mas_equalTo(1);
        make.right.equalTo(self.frameImg.mas_left).offset(-25);
    }];
    
    UIView *downView = [[UIView alloc] init];
    downView.backgroundColor = [QFTools colorWithHexString:MainColor];
    [self addSubview:downView];
    [downView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.top.equalTo(self.frameImg.mas_bottom).offset(25);
        make.width.mas_equalTo(1);
        make.bottom.equalTo(self.mas_bottom).offset(-50);
    }];
    
    UIView *rightView = [[UIView alloc] init];
    rightView.backgroundColor = [QFTools colorWithHexString:MainColor];
    [self addSubview:rightView];
    [rightView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.frameImg.mas_right).offset(25);
        make.centerY.equalTo(self.mas_centerY);
        make.height.mas_equalTo(1);
        make.right.equalTo(self.mas_right).offset(-80);
    }];
    
}

-(UILabel *)titlelab{
    
    if (!_titlelab) {
        _titlelab = [UILabel new];
        _titlelab.textColor = [UIColor whiteColor];
    }
    return _titlelab;
}


-(UIImageView *)frameImg{
    
    if (!_frameImg) {
        _frameImg = [UIImageView new];
        _frameImg.image = [UIImage imageNamed:@"two_wheel_frame"];
    }
    return _frameImg;
}

-(TireStatusDisplayView *)firstWheelView{
    
    if (!_firstWheelView) {
        _firstWheelView = [TireStatusDisplayView new];
    }
    return _firstWheelView;
}


-(TireStatusDisplayView *)secondWheelView{
    
    if (!_secondWheelView) {
        _secondWheelView = [TireStatusDisplayView new];
    }
    return _secondWheelView;
}

-(TireStatusDisplayView *)thirdWheelView{
    
    if (!_thirdWheelView) {
        _thirdWheelView = [TireStatusDisplayView new];
    }
    return _thirdWheelView;
}

-(TireStatusDisplayView *)fourthWheelView{
    
    if (!_fourthWheelView) {
        _fourthWheelView = [TireStatusDisplayView new];
    }
    return _fourthWheelView;
}

-(UIImageView *)firstWheelImg{
    
    if (!_firstWheelImg) {
        _firstWheelImg = [UIImageView new];
        _firstWheelImg.image = [UIImage imageNamed:@"normal_tire_pressure"];
    }
    return _firstWheelImg;
}

-(UIImageView *)secondWheelImg{
    
    if (!_secondWheelImg) {
        _secondWheelImg = [UIImageView new];
        _secondWheelImg.image = [UIImage imageNamed:@"normal_tire_pressure"];
    }
    return _secondWheelImg;
}

-(UIImageView *)thirdWheelImg{
    
    if (!_thirdWheelImg) {
        _thirdWheelImg = [UIImageView new];
        _thirdWheelImg.image = [UIImage imageNamed:@"normal_tire_pressure"];
    }
    return _thirdWheelImg;
}

-(UIImageView *)fourthWheelImg{
    
    if (!_fourthWheelImg) {
        _fourthWheelImg = [UIImageView new];
        _fourthWheelImg.image = [UIImage imageNamed:@"normal_tire_pressure"];
    }
    return _fourthWheelImg;
}

@end
