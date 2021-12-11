//
//  LoadView.m
//  RideHousekeeper
//
//  Created by Apple on 2017/2/18.
//  Copyright © 2017年 Duke Wu. All rights reserved.
//

#import "LoadView.h"
#import "AView.h"
#import "UIView+i7Rotate360.h"

@interface LoadView()

@property(nonatomic, retain)UIView *midview;


@end

@implementation LoadView
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

static id _loadView = nil;
+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    dispatch_once(&once, ^ { _loadView = [[self alloc] initWithFrame:[[UIScreen mainScreen] bounds]]; });
    return _loadView;
    
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _loadView = [super allocWithZone:zone];
    });
    return _loadView;
}

- (instancetype)init {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _loadView = [super init];
    });
    return _loadView;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        UIView *loading = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        loading.backgroundColor = [UIColor clearColor];
        [self addSubview:loading];
        
        UIView *midview = [[UIView alloc] init];
        midview.layer.masksToBounds = YES;
        midview.layer.cornerRadius = 10;
        midview.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
        [loading addSubview:midview];
        
        
        AView *aView = [[AView alloc] initWithImage:[UIImage imageNamed:@"toast_loading.png"]];
        aView.userInteractionEnabled = YES;
        [aView rotate360WithDuration:1.0 repeatCount:HUGE_VALF timingMode:i7Rotate360TimingModeLinear];
        [midview addSubview:aView];
        [aView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(midview.mas_left).offset(10);
            make.centerY.mas_equalTo(self.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(30, 30));
        }];
        
        _protetitle = [[UILabel alloc]  init];
        _protetitle.textColor = [UIColor whiteColor];
        _protetitle.textAlignment = NSTextAlignmentCenter;
        [midview addSubview:_protetitle];
        [_protetitle mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(aView.mas_right).offset(10);
            make.centerY.mas_equalTo(self.mas_centerY);
            make.height.mas_equalTo(20);
        }];
        
        [midview mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(aView.mas_left).offset(-10);
            make.right.mas_equalTo(_protetitle.mas_right).offset(10);
            make.centerX.equalTo(self.mas_centerX);
            make.centerY.mas_equalTo(self.mas_centerY);
            make.height.mas_equalTo(40);
        }];
    }
    return self;
}

- (void)layoutSubviews {

}

-(void)show{
    
    [[UIApplication sharedApplication].keyWindow addSubview:[LoadView sharedInstance]];
}

-(void)hide{
    
    [[LoadView sharedInstance] removeFromSuperview];
}

@end
