//
//  DateSelectionView.m
//  RideHousekeeper
//
//  Created by 晶 on 2020/4/12.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import "DateSelectionView.h"
#import "LXCalender.h"
@interface DateSelectionView()<UIGestureRecognizerDelegate>{
    UIView *_mainView;
    UIView *_contentView;
}
@property(nonatomic,strong)LXCalendarView *calenderView;
@end

@implementation DateSelectionView

- (id)initWithFrame:(CGRect)frame{
    if (self == [super initWithFrame:frame]){
        [self initContent];
    }
    return self;
}

- (void)initContent{
    
    self.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
    _mainView = [[UIView alloc]initWithFrame:self.frame];
    //alpha 0.0  白色   alpha 1 ：黑色   alpha 0～1 ：遮罩颜色，逐渐
    _mainView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    UITapGestureRecognizer *oneTapGestureReognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(disMissView)];
    oneTapGestureReognizer.delegate = self;
    oneTapGestureReognizer.numberOfTapsRequired = 1;
    [_mainView addGestureRecognizer:oneTapGestureReognizer];
    
    if (_contentView == nil){
        _contentView = [[UIView alloc]initWithFrame:CGRectMake(15, ScreenHeight - 430 - QGJ_TabbarSafeBottomMargin, ScreenWidth - 30, 430 + QGJ_TabbarSafeBottomMargin)];
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:_contentView.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(10, 10)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = self.bounds;
        maskLayer.path = maskPath.CGPath;
        _contentView.layer.mask = maskLayer;
        _contentView.backgroundColor = [UIColor whiteColor];
        [_mainView addSubview:_contentView];
    }
}

- (void)loadMaskView
{
}



//展示从底部向上弹出的UIView（包含遮罩）
- (void)showInView:(UIView *)view
{
    if (!view)
    {
        return;
    }
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:_mainView];
    [_mainView addSubview:_contentView];
    
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _contentView.width, 45)];
    headView.backgroundColor = [QFTools colorWithHexString:@"#F4FBFA"];
    [_contentView addSubview:headView];
    
//    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(10, 10)];
//    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
//    maskLayer.frame = self.bounds;
//    maskLayer.path = maskPath.CGPath;
//    headView.layer.mask = maskLayer;
    
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(headView.centerX - 50, 12.5, 100, 20)];
    titleLab.textAlignment = NSTextAlignmentCenter;
    titleLab.textColor = [QFTools colorWithHexString:@"#333333"];
    titleLab.font = FONT_PINGFAN(16);
    titleLab.text = @"按日期查找";
    [headView addSubview:titleLab];
    
    [_contentView setFrame:CGRectMake(15, ScreenHeight, ScreenWidth - 30, 430 + QGJ_TabbarSafeBottomMargin)];
    
    _calenderView =[[LXCalendarView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(headView.frame), _contentView.width, 0)];
    _calenderView.currentMonthTitleColor =[UIColor hexStringToColor:@"2c2c2c"];
    _calenderView.lastMonthTitleColor =[UIColor hexStringToColor:@"8a8a8a"];
    _calenderView.nextMonthTitleColor =[UIColor hexStringToColor:@"8a8a8a"];
    _calenderView.isHaveAnimation = YES;
    _calenderView.isCanScroll = YES;
    _calenderView.isShowLastAndNextBtn = YES;
    _calenderView.todayTitleColor =[UIColor whiteColor];
    _calenderView.selectBackColor =[QFTools colorWithHexString:MainColor];
    _calenderView.isShowLastAndNextDate = NO;
    [_calenderView dealData];
    _calenderView.backgroundColor =[UIColor whiteColor];
    [_contentView addSubview:_calenderView];
    @weakify(self);
    _calenderView.selectBlock = ^(NSInteger year, NSInteger month, NSInteger day) {
        @strongify(self);
        
        if (self.dateSelectBlock) {
            NSString *monthStr,*dayStr;
            if (month<10) {
                monthStr = [NSString stringWithFormat:@"0%d",month];
            }else{
                monthStr = [NSString stringWithFormat:@"%d",month];
            }
            
            if (day<10) {
                dayStr = [NSString stringWithFormat:@"0%d",day];
            }else{
                dayStr = [NSString stringWithFormat:@"%d",day];
            }
            
            self.dateSelectBlock([NSString stringWithFormat:@"%d-%@-%@",year,monthStr,dayStr]);
        }
        [self disMissView];
    };
    
    
    [UIView animateWithDuration:0.3 animations:^{
        
        self.alpha = 1.0;
        
        [_contentView setFrame:CGRectMake(15, ScreenHeight - 430 - QGJ_TabbarSafeBottomMargin, ScreenWidth - 30, 430 + QGJ_TabbarSafeBottomMargin)];
        
    } completion:nil];
}

//移除从上向底部弹下去的UIView（包含遮罩）
- (void)disMissView
{
    [_contentView setFrame:CGRectMake(15, ScreenHeight - 430 - QGJ_TabbarSafeBottomMargin, ScreenWidth - 30, 430 + QGJ_TabbarSafeBottomMargin)];
    [UIView animateWithDuration:0.3f
                     animations:^{
                         
                         _mainView.alpha = 0.0;
                         
                         [_contentView setFrame:CGRectMake(15, ScreenHeight, ScreenWidth - 30, 430 + QGJ_TabbarSafeBottomMargin)];
                     }
                     completion:^(BOOL finished){
                         
                         [_mainView removeFromSuperview];
                         [_contentView removeFromSuperview];
                         
                     }];
    
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    //设置为NO则不响应
    
    if ([touch.view isDescendantOfView:_contentView]) {
        return NO;
    }
    return  YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
}

@end
