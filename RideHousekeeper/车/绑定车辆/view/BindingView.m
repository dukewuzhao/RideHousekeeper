//
//  BindingView.m
//  NiuDingRideHousekeeper
//
//  Created by Apple on 2019/8/9.
//  Copyright © 2019 Duke Wu. All rights reserved.
//

#import "BindingView.h"
#import "AView.h"
#import "UIView+i7Rotate360.h"

@interface BindingView()
@property(nonatomic,strong) UILabel *search;
@property(nonatomic,strong) UIImageView *qgjlogo;
@property(nonatomic,strong) UIImageView *giftImage;

@end

@implementation BindingView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(instancetype)initWithFrame:(CGRect)frame bindType:(BindingType)type{
    if (self = [super init]) {
        self.frame = frame;
        
        if (type == BindingBike) {
            _qgjlogo = [[UIImageView alloc] init];
            _qgjlogo.image = [UIImage imageNamed:@"addbikelogo"];
            [self addSubview:_qgjlogo];
            [_qgjlogo mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self.mas_centerX);
                make.top.equalTo(self).offset(20);
            }];
        }
        
        _search = [[UILabel alloc] init];
        _search.textAlignment = NSTextAlignmentCenter;
        _search.text = @"正在搜索车辆";
        _search.textColor = [QFTools colorWithHexString:@"333333"];
        _search.font = FONT_PINGFAN(20);
        [self addSubview:_search];
        [_search mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.mas_centerX);
            
            if (type == BindingBike) {
                make.top.equalTo(_qgjlogo.mas_bottom).offset(10);
            }else{
                make.top.equalTo(self).offset(20);
            }
            make.height.mas_equalTo(28);
        }];
        _giftImage = [[UIImageView alloc] init];
        _giftImage.image = [UIImage imageNamed:@"icon_find_center_bg"];
        [self addSubview:_giftImage];
        [_giftImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.mas_centerX);
            make.top.equalTo(_search.mas_bottom).offset(35);
            make.size.mas_equalTo(CGSizeMake(ScreenWidth * .6, ScreenWidth * .6));
        }];
        
        _aView = [[AView alloc] initWithImage:[UIImage imageNamed:@"turnaround"]];
        _aView.userInteractionEnabled = NO;
        [_aView rotate360WithDuration:2.0 repeatCount:HUGE_VALF timingMode:i7Rotate360TimingModeLinear];
        [self addSubview:_aView];
        if (![[APPStatusManager sharedManager] getBLEStstus]) {
            [self pauseLayer:_aView.layer];
        }
        [_aView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(_giftImage);
            make.top.equalTo(_aView.mas_top);
            make.size.mas_equalTo(CGSizeMake(ScreenWidth * .6, ScreenWidth * .6));
        }];
        
        _promptView = [[UIView alloc] init];
        [self addSubview:_promptView];
        [_promptView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left);
            make.top.equalTo(_giftImage.mas_bottom).offset(ScreenWidth * 0.05);
            make.right.equalTo(self);
            make.bottom.equalTo(self);
        }];
        
        UILabel *prompt = [[UILabel alloc] init];
        prompt.text = @"长按钥匙解锁键激活车辆";
        prompt.textColor = [QFTools colorWithHexString:@"#666666"];
        prompt.font = FONT_PINGFAN(20);
        prompt.textAlignment = NSTextAlignmentCenter;
        [_promptView addSubview:prompt];
        [prompt mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_promptView);
            make.top.equalTo(_promptView).offset(5);
            make.height.mas_equalTo(28);
        }];
        
        UILabel *prompt2 = [[UILabel alloc] init];
        prompt2.text = @"请将手机靠近车辆";
        prompt2.textColor = [QFTools colorWithHexString:@"#666666"];
        prompt2.font = FONT_PINGFAN(14);
        prompt2.textAlignment = NSTextAlignmentCenter;
        [_promptView addSubview:prompt2];
        [prompt2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_promptView);
            make.top.equalTo(prompt.mas_bottom).offset(10);
            make.height.mas_equalTo(20);
        }];
        
        if (type == BindingBike) {
            
            UIImageView *middleView = [[UIImageView alloc] init];
            middleView.image = [UIImage imageNamed:@"icon_split_line"];
            [_promptView addSubview:middleView];
            [middleView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self);
                make.centerY.equalTo(self.mas_bottom).offset(-90);
                make.right.equalTo(self);
                make.height.mas_equalTo(self.mas_width).multipliedBy(0.013);
            }];
            
            UIButton *scanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [scanBtn setImage:[UIImage imageNamed:@"icon_toggle_scan"] forState:UIControlStateNormal];
            scanBtn.adjustsImageWhenHighlighted = NO;
            @weakify(self);
            [[scanBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
                @strongify(self);
                Class className = NSClassFromString(@"TwoDimensionalCodecanViewController");
                id CodecanVc = [[className alloc] init];
                [CodecanVc setValue:@4 forKey:@"type"];
                [CodecanVc setValue:@"绑定车辆" forKey:@"naVtitle"];
                [[QFTools viewController:self].navigationController pushViewController:CodecanVc animated:YES];
            }];
            [_promptView addSubview:scanBtn];
            [scanBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self.mas_centerX).offset(-65);
                make.centerY.equalTo(self.mas_bottom).offset(-45);
                make.size.mas_equalTo(CGSizeMake(40, 40));
            }];
            
            UILabel *title = [[UILabel alloc] init];
            title.textColor = [QFTools colorWithHexString:@"#999999"];
            title.text = @"扫描二维码绑定";
            [_promptView addSubview:title];
            [title mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(scanBtn.mas_right).offset(20);
                make.centerY.equalTo(scanBtn.mas_centerY);
                make.height.mas_equalTo(20);
            }];
        }
    }
    return self;
}


-(void)setupUI{
    
    
}

-(void)bndingfail{
    _search.hidden = YES;
    _aView.hidden = YES;
    _giftImage.image = [UIImage imageNamed:@"binding_fail"];
    UIButton *scanAgainBtn = [[UIButton alloc] init];
    [scanAgainBtn setTitle:@"重新搜索" forState:UIControlStateNormal];
    [scanAgainBtn setTitleColor:[QFTools colorWithHexString:MainColor] forState:UIControlStateNormal];
    scanAgainBtn.backgroundColor = [UIColor whiteColor];
    scanAgainBtn.contentMode = UIViewContentModeCenter;
    [scanAgainBtn.layer setCornerRadius:10.0]; // 切圆角
    [scanAgainBtn.layer setBorderColor:[QFTools colorWithHexString:MainColor].CGColor];
    [scanAgainBtn.layer setBorderWidth:1];
    [scanAgainBtn.layer setMasksToBounds:YES];
    [scanAgainBtn addTarget:self action:@selector(scanAgain:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:scanAgainBtn];
    [scanAgainBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.centerY.equalTo(self.promptView).offset(-self.height*.01);
        make.size.mas_equalTo(CGSizeMake(ScreenWidth - 150, 45));
    }];
}

-(void)scanAgain:(UIButton *)btn{
    
    [btn removeFromSuperview];
    _giftImage.image = [UIImage imageNamed:@"icon_find_center_bg"];
    _search.hidden = NO;
    _aView.hidden = NO;
    [self resumeLayer:_aView.layer];
    if (self.resetBindingBlock) {
        self.resetBindingBlock();
    }
}

@end
