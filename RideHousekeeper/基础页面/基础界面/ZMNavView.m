//
//  ZMNavView.m
//
//
//  Created by Brance on 17/11/24.
//  Copyright © 2016年 Brance. All rights reserved.
//

#import "ZMNavView.h"
#import "YBPopupMenu.h"
#import "Manager.h"
@interface ZMNavView ()<YBPopupMenuDelegate>

@property (nonatomic, strong) UILabel *lineLabel;
@property (nonatomic, strong) UIView  *backView;
@property (nonatomic, strong) UIImageView *arrowImg;
@end

@implementation ZMNavView

- (UIView *)mainView{
    if (!_mainView) {
        _mainView = [UIView new];
        _mainView.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
        [self addSubview:_mainView];
        [_mainView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.bottom.mas_equalTo(0);
        }];
        [_mainView.superview layoutIfNeeded];
    }
    return _mainView;
}

- (UIButton *)leftButton{
    if (!_leftButton) {
        _leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _leftButton.titleLabel.font = [UIFont systemFontOfSize:15];
        _leftButton.adjustsImageWhenHighlighted = NO;
        _leftButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [_leftButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.mainView addSubview:_leftButton];
        [_leftButton addTarget:self action:@selector(clickLeftButton) forControlEvents:UIControlEventTouchUpInside];
        [_leftButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.width.mas_equalTo(50);
            make.height.mas_equalTo(40);
            make.centerY.mas_equalTo(self.mainView.mas_centerY).with.offset((KStatusBarHeight+20)/2);
        }];
    }
    return _leftButton;
}

-(UIButton *)rightButton{
    if (!_rightButton) {
        //右边按钮
        UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        rightButton.titleLabel.font = [UIFont systemFontOfSize:15];
        rightButton.adjustsImageWhenHighlighted = NO;
        [rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.mainView addSubview:rightButton];
        self.rightButton = rightButton;
        [_rightButton addTarget:self action:@selector(clickRightButton) forControlEvents:UIControlEventTouchUpInside];
        [self.rightButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-5);
            make.width.mas_greaterThanOrEqualTo(50);
            make.height.mas_equalTo(40);
            make.centerY.mas_equalTo(self.leftButton);
        }];
        [self.rightButton.superview layoutIfNeeded];
    }
    return _rightButton;
}

-(UIButton *)centerButton{
    if (!_centerButton) {
        //中间按钮
        UIButton *centerButton = [UIButton buttonWithType:UIButtonTypeCustom];
        centerButton.titleLabel.font = [UIFont boldSystemFontOfSize:20];
        [centerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        centerButton.adjustsImageWhenHighlighted = NO;
        [self.mainView addSubview:centerButton];
        self.centerButton = centerButton;
        [_centerButton addTarget:self action:@selector(clickCenterButton) forControlEvents:UIControlEventTouchUpInside];
        [self.centerButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.mas_centerX);
            make.height.mas_equalTo(self.leftButton.mas_height);
            make.centerY.mas_equalTo(self.leftButton);
        }];
        [self.centerButton.superview layoutIfNeeded];
    }
    return _centerButton;
}

-(UILabel *)lineLabel{
    if (!_lineLabel) {
        //底部分割线
        UILabel *lineLabel = [[UILabel alloc] init];
        lineLabel.backgroundColor = [QFTools colorWithHexString:@"0xDCDCDC"];
        self.lineLabel = lineLabel;
        [self.mainView addSubview:lineLabel];
        [self.lineLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.mas_equalTo(0);
            make.height.mas_equalTo(0.5);
        }];
        [self.mainView bringSubviewToFront:lineLabel];
    }
    return _lineLabel;
}

-(UIView *)backView{
    if (!_backView) {
        
        _backView = [[UIView alloc] init];
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wundeclared-selector"
        UITapGestureRecognizer *singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickCenterBtn)];
        singleRecognizer.numberOfTapsRequired = 1; //点击的次数 =1:单击
        [_backView addGestureRecognizer:singleRecognizer];//添加一个手势监测；
        @weakify(self);
        [[self rac_signalForSelector:@selector(clickCenterBtn)] subscribeNext:^(RACTuple* x) {
            @strongify(self);
            [self clickCenterButton];
        }];
        #pragma clang diagnostic pop
    }
    return _backView;
}

-(UIImageView *)arrowImg{
    if (!_arrowImg) {
        
        _arrowImg = [[UIImageView alloc] init];
    }
    return _arrowImg;
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        [self setupUI];
    }
    return self;
}

/**
 *  UI 界面
 */
- (void)setupUI{
    [self lineLabel];
}

- (void)setShowBottomLabel:(BOOL)showBottomLabel{
    self.lineLabel.hidden = !showBottomLabel;
}

- (void)setSwitchingOptions:(BOOL)switchingOptions{
    _switchingOptions = switchingOptions;
    NSLog(@"执行一次");
    if (switchingOptions) {
        
        
        self.backView.backgroundColor = RGBACOLOR(6, 193, 174,0.6);
        self.backView.userInteractionEnabled = YES;
        self.backView.layer.cornerRadius = 20;
        [self.mainView insertSubview:self.backView belowSubview:self.centerButton];
        [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.mainView);
            make.centerY.mas_equalTo(self.mainView.mas_centerY).with.offset((KStatusBarHeight+20)/2);
            make.height.mas_equalTo(self.leftButton.mas_height);
        }];
            
        [self.centerButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.backView).offset(20);
            make.centerY.equalTo(self.backView);
            make.height.mas_equalTo(self.leftButton.mas_height);
        }];
        
        self.arrowImg = [[UIImageView alloc] init];
        self.arrowImg.image = [UIImage imageNamed:@"icon_switch_bike_arrow"];
        [self.mainView addSubview:self.arrowImg];
        [self.arrowImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.centerButton.mas_right).offset(10);
            make.right.equalTo(self.backView).offset(-20);
            make.centerY.equalTo(self.backView);
            make.size.mas_equalTo(CGSizeMake(20, 10));
        }];
        
    }else{
        [self.backView removeFromSuperview];
        [self.arrowImg removeFromSuperview];
        [self.centerButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.mas_centerX);
            make.height.mas_equalTo(self.leftButton.mas_height);
            make.centerY.mas_equalTo(self.leftButton);
        }];
    }
    
}

-(void)ybPopupMenuBeganShow:(YBPopupMenu *)ybPopupMenu{
    if (self.switchingOptions) {
        //[UIView animateWithDuration:0.6 animations:^{
            self.arrowImg.transform = CGAffineTransformRotate(CGAffineTransformIdentity, M_PI_2 * 2);
        //}];
        //self.backView.backgroundColor = RGBACOLOR(255, 255, 255, 0.6);
    }
}

-(void)ybPopupMenuBeganDismiss:(YBPopupMenu *)ybPopupMenu{
    if (self.switchingOptions) {
        //[UIView animateWithDuration:0.6 animations:^{
            self.arrowImg.transform = CGAffineTransformRotate(CGAffineTransformIdentity, 0);
        //}];
        //self.backView.backgroundColor = RGBACOLOR(6, 193, 174,0.6);
    }
}

#pragma mark - private
- (void)clickLeftButton{
    if (self.leftButtonBlock) {
        self.leftButtonBlock();
    }
}

- (void)clickCenterButton{
    if (self.cenTerButtonBlock) {
        self.cenTerButtonBlock();
    }
    
    if (!self.switchingOptions) return ;
    NSMutableArray *ary = [NSMutableArray array];
    NSMutableArray *bikeAry = [NSMutableArray array];
    NSInteger bikeid = [[[QFTools viewController:self] valueForKeyPath:@"bikeid"] integerValue];
    for (BikeModel*model in [LVFmdbTool queryBikeData:nil]) {
        if (model.bikeid != bikeid) {
            [ary addObject:model.bikename];
            [bikeAry addObject:@(model.bikeid)];
        }
    }
    [YBPopupMenu showAtPoint:CGPointMake(ScreenWidth/2, navHeight) titles:ary.copy icons:nil menuWidth:130 otherSettings:^(YBPopupMenu *popupMenu) {
        popupMenu.dismissOnSelected = YES;
        popupMenu.isShowShadow = NO;
        popupMenu.delegate = self;
        popupMenu.type = YBPopupMenuTypeDefault;
        popupMenu.cornerRadius = 8;
        popupMenu.rectCorner = UIRectCornerAllCorners;
        popupMenu.arrowHeight = 0;
        popupMenu.backColor = [UIColor colorWithWhite:1 alpha:0.8];
        popupMenu.animationManager.duration = 0.2;
        popupMenu.animationManager.style = YBPopupMenuAnimationStyleNone;
        popupMenu.tag = 100;
        popupMenu.fontSize = 14;
        popupMenu.textColor = [QFTools colorWithHexString:@"#666666"];
        //如果不加这句默认是 UITableViewCellSeparatorStyleNone 的
        popupMenu.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    } action:^(YBPopupMenu *ybPopupMenu, NSInteger index) {
        NSLog(@"点击了 %@ 选项",ybPopupMenu.titles[index]);
        NSInteger biketag =  [bikeAry[index] integerValue];
        [USER_DEFAULTS setInteger:biketag forKey:Key_BikeId];
        [USER_DEFAULTS synchronize];
        [[Manager shareManager] switchingVehicle:[[NSDictionary alloc] initWithObjectsAndKeys:@(biketag),@"biketag", nil]];
    }];
}

- (void)clickRightButton{
    if (self.rightButtonBlock) {
        self.rightButtonBlock();
    }
}
@end
