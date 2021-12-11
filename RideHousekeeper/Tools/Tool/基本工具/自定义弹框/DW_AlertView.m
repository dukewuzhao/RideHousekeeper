//
//  DW_AlertView.m
//  RideHousekeeper
//
//  Created by Apple on 2019/12/5.
//  Copyright © 2019 Duke Wu. All rights reserved.
//

#import "DW_AlertView.h"
@interface DW_AlertView()<UIGestureRecognizerDelegate>
@property (nonatomic,strong)UIView *alertView;
@property(nonatomic,strong)RACDisposable *dispoable;
@end
@implementation DW_AlertView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(instancetype)initBackroundImage:(NSString *)imageB Title:(NSString *)tltleString contentString:(NSString *)contentString sureButtionTitle:(NSString *)sureBtnstring cancelButtionTitle:(NSString *)cancelBtnString {

    self = [super init];
    if (self) {
        self.frame = [UIScreen mainScreen].bounds;
        
        _alertView = [[UIView alloc] init];
        _alertView.backgroundColor = [UIColor whiteColor];
        _alertView.layer.cornerRadius=5.0;
        _alertView.layer.masksToBounds=YES;
        _alertView.userInteractionEnabled=YES;
        [self addSubview:_alertView];
        [_alertView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.centerY.equalTo(self).multipliedBy(.9);
            make.left.equalTo(self).offset(ScreenWidth*.2);
            
        }];

//        if (imageB) {
//            UIImageView *backImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0,ALERTVIEW_WIDTH , ALERTVIEW_HEIGHT)];
//            backImage.image = [UIImage imageNamed:imageB];
//            [_alertView addSubview:backImage];
//        }
        UILabel *titleLabe = [[UILabel alloc]init];
        if (tltleString) {
            titleLabe.text = tltleString;
            titleLabe.textAlignment = NSTextAlignmentLeft;
            titleLabe.font = [UIFont systemFontOfSize:17];
            titleLabe.textColor = [UIColor blackColor];
            [_alertView addSubview:titleLabe];
            [titleLabe mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self.alertView);
                make.top.equalTo(self.alertView.mas_top).offset(12);
                make.height.mas_equalTo(30);
            }];
            
        }
        UILabel *contentLab = [[UILabel alloc]init];
        if (contentString) {
            contentLab.text = contentString;
            contentLab.textColor = [UIColor colorWithRed:47/255 green:60/255 blue:67/255 alpha:1];
            contentLab.font = [UIFont systemFontOfSize:16];
            contentLab.textAlignment = NSTextAlignmentLeft;
            contentLab.numberOfLines = 0;
            [_alertView addSubview:contentLab];
            [contentLab mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.alertView).offset(15);
                make.top.equalTo(titleLabe.mas_bottom).offset(15);
                make.right.equalTo(self.alertView).offset(-15);
            }];

        }
        UIButton *OkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        if (sureBtnstring) {
            [OkBtn setTitle:sureBtnstring forState:UIControlStateNormal];
            OkBtn.backgroundColor = [UIColor colorWithRed:25.0/255 green:182.0/255 blue:157.0/255 alpha:1.0];
            [OkBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            OkBtn.titleLabel.font = [UIFont systemFontOfSize:15];
            OkBtn.layer.cornerRadius = 15;
            OkBtn.layer.masksToBounds=YES;
            [OkBtn addTarget:self action:@selector(sureClick:) forControlEvents:UIControlEventTouchUpInside];
            [_alertView addSubview:OkBtn];
            [OkBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(contentLab);
                make.top.equalTo(contentLab.mas_bottom).offset(30);
                make.size.mas_equalTo(CGSizeMake(90, 30));
                make.bottom.equalTo(self.alertView.mas_bottom).offset(-25);
            }];
        }
        UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        if (cancelBtnString) {
            
            [cancelBtn setTitle:cancelBtnString forState:UIControlStateNormal];
            cancelBtn.backgroundColor = [UIColor colorWithRed:241.0/255 green:241.0/255 blue:241.0/255 alpha:1.0];
            [cancelBtn setTitleColor:[UIColor colorWithRed:25.0/255 green:182.0/255 blue:157.0/255 alpha:1.0] forState:UIControlStateNormal];
            cancelBtn.titleLabel.font = [UIFont systemFontOfSize:15];
            cancelBtn.layer.cornerRadius= 15;
            cancelBtn.layer.masksToBounds=YES;
            [cancelBtn addTarget:self action:@selector(cancelClick:) forControlEvents:UIControlEventTouchUpInside];
            [_alertView addSubview:cancelBtn];
            [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(OkBtn);
                make.right.equalTo(contentLab);
                make.size.mas_equalTo(CGSizeMake(90, 30));
                make.bottom.equalTo(self.alertView.mas_bottom).offset(-25);
            }];
                
        }
    }

   [self showView];
    return  self;
}

-(instancetype)initTopTitle:(NSString *)tltleString contentImgString:(NSString *)imageStr sureButtionTitle:(NSString *)sureBtnstring{
    
    self = [super init];
        if (self) {
            self.frame = [UIScreen mainScreen].bounds;
            
            _alertView = [[UIView alloc] init];
            _alertView.backgroundColor = [UIColor whiteColor];
            _alertView.layer.cornerRadius=5.0;
            _alertView.layer.masksToBounds=YES;
            _alertView.userInteractionEnabled=YES;
            [self addSubview:_alertView];
            [_alertView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self);
                make.centerY.equalTo(self).multipliedBy(.9);
                make.left.equalTo(self).offset(35);
            }];

            UILabel *titleLabe = [[UILabel alloc]init];
            if (tltleString) {
                titleLabe.numberOfLines = 0;
                titleLabe.text = tltleString;
                titleLabe.textAlignment = NSTextAlignmentCenter;
                titleLabe.font = FONT_PINGFAN(14);
                titleLabe.textColor = [UIColor blackColor];
                [_alertView addSubview:titleLabe];
                [titleLabe mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.equalTo(self.alertView);
                    make.top.equalTo(self.alertView).offset(20);
                    make.left.equalTo(self.alertView).offset(25);
                }];
            }
            
            UIView *middleView = [[UIView alloc] init];
            if (imageStr) {
                middleView.backgroundColor = [QFTools colorWithHexString:@"#E5E5E5"];
                [_alertView addSubview:middleView];
                [middleView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.equalTo(self.alertView);
                    make.top.equalTo(titleLabe.mas_bottom).offset(20);
                    make.left.equalTo(self.alertView).offset(35);
                    make.height.mas_equalTo(140);
                }];
                
                UIImageView *backImage = [[UIImageView alloc]init];
                backImage.image = [UIImage imageNamed:imageStr];
                [middleView addSubview:backImage];
                [backImage mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.equalTo(middleView);
                    make.centerY.equalTo(middleView);
                    make.top.greaterThanOrEqualTo(middleView.mas_top);
                    make.left.greaterThanOrEqualTo(middleView.mas_left);
                }];
            }
            
            UIButton *OkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            if (sureBtnstring) {
                [OkBtn setTitle:sureBtnstring forState:UIControlStateNormal];
                OkBtn.backgroundColor = [UIColor whiteColor];
                [OkBtn setTitleColor:[QFTools colorWithHexString:@"#06C1AE"] forState:UIControlStateNormal];
                OkBtn.titleLabel.font = FONT_PINGFAN(16);
                [OkBtn addTarget:self action:@selector(sureClick:) forControlEvents:UIControlEventTouchUpInside];
                [_alertView addSubview:OkBtn];
                [OkBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.equalTo(self);
                    make.top.equalTo(middleView.mas_bottom).offset(45);
                    make.size.mas_equalTo(CGSizeMake(90, 30));
                    make.bottom.equalTo(self.alertView.mas_bottom).offset(-30);
                }];
            }
        }

       [self showView];
        return  self;
}

-(instancetype)initHeadLottiAnimation:(NSString *)name Title:(NSString *)tltleString contentString:(NSString *)contentString cancelButtionTitle:(NSString *)cancelBtnString{
    
    self = [super init];
     if (self) {
         self.frame = [UIScreen mainScreen].bounds;
         
         _alertView = [[UIView alloc] init];
         _alertView.backgroundColor = [UIColor whiteColor];
         _alertView.layer.cornerRadius=5.0;
         _alertView.layer.masksToBounds=YES;
         _alertView.userInteractionEnabled=YES;
         [self addSubview:_alertView];
         [_alertView mas_makeConstraints:^(MASConstraintMaker *make) {
             make.centerX.equalTo(self);
             make.centerY.equalTo(self).multipliedBy(.9);
             make.left.equalTo(self).offset(35);
         }];

         
         LOTAnimationView *lanimation = [LOTAnimationView animationNamed:name];
         [self addSubview:lanimation];
         lanimation.animationSpeed = 0.2;
         [lanimation playWithCompletion:^(BOOL animationFinished) {
             
         }];
         [lanimation mas_makeConstraints:^(MASConstraintMaker *make) {
             make.centerX.equalTo(_alertView);
             make.top.equalTo(_alertView).offset(10);
             make.size.mas_equalTo(CGSizeMake(100, 100));
         }];
         
         UILabel *titleLabe = [[UILabel alloc]init];
         if (tltleString) {
             titleLabe.numberOfLines = 0;
             titleLabe.text = tltleString;
             titleLabe.textAlignment = NSTextAlignmentCenter;
             titleLabe.font = FONT_PINGFAN(16);
             titleLabe.textColor = [UIColor blackColor];
             [_alertView addSubview:titleLabe];
             [titleLabe mas_makeConstraints:^(MASConstraintMaker *make) {
                 make.centerX.equalTo(self.alertView);
                 make.top.equalTo(lanimation.mas_bottom).offset(30);
                 make.left.equalTo(self.alertView).offset(25);
             }];
             
             __block int32_t timeOutCount = 15;
             @weakify(self);
             self.dispoable = [[[RACSignal interval:1.0 onScheduler:[RACScheduler mainThreadScheduler]] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id x) {
                 @strongify(self);
                 timeOutCount--;
                 NSLog(@"计时器执行一次");
                 titleLabe.text = [NSString stringWithFormat:@"正在连接车辆蓝牙（%dS）...",timeOutCount];
                 if (timeOutCount == 0) {
                     [self cancelClick:nil];
                 }
             }];
         }
         
         UILabel *contentLab = [[UILabel alloc]init];
         if (contentString) {
             contentLab.text = contentString;
             contentLab.textColor = [QFTools colorWithHexString:@"#666666"];
             contentLab.font = FONT_PINGFAN(12);
             contentLab.textAlignment = NSTextAlignmentCenter;
             contentLab.numberOfLines = 0;
             [_alertView addSubview:contentLab];
             [contentLab mas_makeConstraints:^(MASConstraintMaker *make) {
                 make.left.equalTo(_alertView).offset(15);
                 make.top.equalTo(titleLabe.mas_bottom).offset(10);
                 make.right.equalTo(_alertView).offset(-15);
             }];

         }
         
         UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
         if (cancelBtnString) {
             
             [cancelBtn setTitle:cancelBtnString forState:UIControlStateNormal];
             cancelBtn.backgroundColor = [QFTools colorWithHexString:@"#91E8DF"];
             [cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
             cancelBtn.titleLabel.font = [UIFont systemFontOfSize:16];
             cancelBtn.layer.cornerRadius= 22;
             //cancelBtn.layer.masksToBounds=YES;
             [cancelBtn addTarget:self action:@selector(cancelClick:) forControlEvents:UIControlEventTouchUpInside];
             [_alertView addSubview:cancelBtn];
             [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                 make.centerX.equalTo(self);
                 make.left.equalTo(_alertView).offset(60);
                 make.top.equalTo(contentLab.mas_bottom).offset(50);
                 make.height.mas_equalTo(44);
                 make.bottom.equalTo(_alertView.mas_bottom).offset(-30);
             }];
             @weakify(self);
             [[self rac_signalForSelector:@selector(cancelClick:)] subscribeNext:^(id x) {
                 @strongify(self);
                 NSLog(@"执行了取消");
                 if (self.dispoable) {
                     [self.dispoable dispose];
                     self.dispoable = nil;
                 }
             }error:^(NSError *error) {
                 
             }];
         }
     }

    [self showView];
     return  self;
}

-(void)showView{

    self.backgroundColor = [UIColor whiteColor];
    [[UIApplication sharedApplication].keyWindow addSubview:self];

    CGAffineTransform transform = CGAffineTransformScale(CGAffineTransformIdentity,1.0,1.0);
    self.alertView.transform = CGAffineTransformScale(CGAffineTransformIdentity,0.5,0.5);
    self.alertView.alpha = 0;
    [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:1.0 initialSpringVelocity:10 options:UIViewAnimationOptionCurveLinear animations:^{
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.4f];
        self.alertView.transform = transform;
        self.alertView.alpha = 1;
    } completion:^(BOOL finished) {

    }];
}

-(void)cancelClick:(UIButton *)sender{
    
    if (self.cancleBolck!=nil) {
        self.cancleBolck(nil);
    }
    [self removeView];
}

-(void)sureClick:(UIButton *)sender{

    if (self.sureBolck!=nil) {
        self.sureBolck(nil);
    }
    [self removeView];
}

-(void)removeView{
    [UIView animateWithDuration:0.3 animations:^{
        [self removeFromSuperview];
    }];
}

-(void)clickSureBtn:(sureBtnClick)block{
    _sureBolck = block;
}

-(void)clickCancleBtn:(cancleBtnClick)block{
    _cancleBolck = block;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
}

@end
