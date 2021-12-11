//
//  LoadView.m
//  RideHousekeeper
//
//  Created by Apple on 2017/2/18.
//  Copyright © 2017年 Duke Wu. All rights reserved.
//

#import "LoadView.h"

@interface LoadView()
@property(nonatomic, strong)UIView *midview;
@property (nonatomic, strong) LOTAnimationView *laAnimation;
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
        
        _midview = [[UIView alloc] init];
        _midview.layer.masksToBounds = YES;
        _midview.layer.cornerRadius = 10;
        _midview.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
        [loading addSubview:_midview];
        [_midview mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.centerY.equalTo(self);
            make.width.lessThanOrEqualTo(@(ScreenWidth));
            make.width.greaterThanOrEqualTo(@100);
        }];
        
        [self.midview addSubview:[self laAnimationWithName:@"loginAnimation"]];
        [_laAnimation playWithCompletion:^(BOOL animationFinished) {
            
        }];
        [_laAnimation mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_midview);
            make.top.equalTo(_midview).offset(5);
            make.size.mas_equalTo(CGSizeMake(80, 80));
        }];
        
        [_midview addSubview:self.protetitle];
        [self.protetitle mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_midview);
            make.left.equalTo(_midview).offset(10);
            make.top.equalTo(_laAnimation.mas_bottom);
            make.bottom.equalTo(_midview).offset(-5);
        }];
    }
    return self;
}


-(void)show{
    
    [[UIApplication sharedApplication].keyWindow addSubview:[LoadView sharedInstance]];
}

-(UILabel *)protetitle{
    if (!_protetitle) {
        _protetitle = [[UILabel alloc]  init];
        _protetitle.numberOfLines = 0;
        _protetitle.font = FONT_PINGFAN(15);
        _protetitle.textColor = [UIColor whiteColor];
        _protetitle.textAlignment = NSTextAlignmentCenter;
    }
    return _protetitle;
}

-(LOTAnimationView*)laAnimationWithName:(NSString *)name{
    if (!_laAnimation) {
        _laAnimation = [LOTAnimationView animationNamed:name];
        _laAnimation.contentMode = UIViewContentModeScaleAspectFit;
        _laAnimation.loopAnimation = YES;
    }
    return _laAnimation;
}

-(void)hide{
    [[LoadView sharedInstance] removeFromSuperview];
}
@end
