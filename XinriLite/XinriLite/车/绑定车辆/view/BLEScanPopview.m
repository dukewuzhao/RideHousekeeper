//
//  BLEScanPopview.m
//  RideHousekeeper
//
//  Created by Apple on 2018/4/24.
//  Copyright © 2018年 Duke Wu. All rights reserved.
//

#import "BLEScanPopview.h"

@interface BLEScanPopview(){
    UIView *mainView;
    UIView *contentView;
}

@end
@implementation BLEScanPopview

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        [self setupUI];
    }
    return self;
}
-(void)setupUI{
    
    self.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
    
    mainView = [[UIView alloc]initWithFrame:self.frame];
    
    //alpha 0.0  白色   alpha 1 ：黑色   alpha 0～1 ：遮罩颜色，逐渐
    mainView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
//    mainView.userInteractionEnabled = YES;
//    [mainView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(disMissView)]];
    
    if (contentView == nil)
    {
        contentView = [[UIView alloc]initWithFrame:CGRectMake(ScreenWidth * .2, ScreenHeight *.3, ScreenWidth *.6, ScreenHeight * .376)];
        contentView.backgroundColor = [UIColor whiteColor];
        contentView.layer.mask = [self UiviewRoundedRect:contentView.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(10, 10)];
        [mainView addSubview:contentView];
        
        UILabel *findLab = [[UILabel alloc] initWithFrame:CGRectMake(0, contentView.height * .1, contentView.width, 20)];
        findLab.text = NSLocalizedString(@"searched_bike", nil);
        findLab.textColor = [QFTools colorWithHexString:@"#666666"];
        findLab.textAlignment = NSTextAlignmentCenter;
        findLab.font = [UIFont systemFontOfSize:18];
        [contentView addSubview:findLab];
        
        self.scandTabView.frame = CGRectMake(0, CGRectGetMaxY(findLab.frame)+contentView.height * .1, contentView.width, contentView.height * .4);
        [self.scandTabView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
        [contentView addSubview:self.scandTabView];
        
        UIButton *bindingBtn = [[UIButton alloc] initWithFrame:CGRectMake(contentView.width/2 - 45, contentView.height/2 + CGRectGetMaxY(self.scandTabView.frame)/2 - 16, 90, 32)];
        [bindingBtn setTitle:NSLocalizedString(@"bind", nil) forState:UIControlStateNormal];
        bindingBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        bindingBtn.backgroundColor = [QFTools colorWithHexString:NSLocalizedString(@"VCControlColor", nil)];
        bindingBtn.layer.mask = [self UiviewRoundedRect:bindingBtn.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(10, 10)];
        [bindingBtn addTarget:self action:@selector(bindingBike) forControlEvents:UIControlEventTouchUpInside];
        [contentView addSubview:bindingBtn];
    }
}

-(void)bindingBike{
    
    if (self.bindingBikeClickBlock) {
        self.bindingBikeClickBlock();
    }
}

-(UITableView *)scandTabView{
    if (!_scandTabView) {
        _scandTabView = [UITableView new];
    }
    return _scandTabView;
}

- (void)disMissView
{
    [UIView animateWithDuration:0.3f
                     animations:^{
                         
                         mainView.alpha = 0.0;
                     }
                     completion:^(BOOL finished){
                         
                         [mainView removeFromSuperview];
                     }];
    
}

-(void)showInView:(UIView *)view{
    
    if (!view){
        return;
    }
    //UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [view addSubview:mainView];
    
    [UIView animateWithDuration:0.3 animations:^{
        
        self.alpha = 1.0;
                
    } completion:nil];
}

@end
