//
//  NameAlertView.m
//  RideHousekeeper
//
//  Created by Apple on 2018/8/3.
//  Copyright © 2018年 Duke Wu. All rights reserved.
//

#import "NameAlertView.h"

@implementation NameAlertView

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
    
    UIView *whiteView = [[UIView alloc] init];
    whiteView.width = ScreenWidth *.6;
    whiteView.height = ScreenWidth *.6 *.67;
    whiteView.center = CGPointMake(ScreenWidth/2, ScreenHeight + whiteView.height);
    whiteView.backgroundColor = [UIColor whiteColor];
    whiteView.userInteractionEnabled = YES;
    whiteView.center = self.center;
    whiteView.alpha = 0;
    whiteView.layer.mask = [self UiviewRoundedRect:whiteView.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(10, 10)];
    [self addSubview:whiteView];
    
    [UIView animateWithDuration:0.5 delay:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        //whiteView.center = self.center;
        whiteView.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
    
    UILabel *nameLab = [[UILabel alloc] initWithFrame:CGRectMake(20, 15, whiteView.width *.5, 20)];
    nameLab.textColor = [UIColor blackColor];
    nameLab.text = @"车辆名称:";
    nameLab.font = [UIFont systemFontOfSize:17];
    [whiteView addSubview:nameLab];
    
    _bikenameField = [[UITextField alloc]init];
    _bikenameField.frame = CGRectMake(30, whiteView.height/2 - 20, whiteView.width - 60, 40);
    _bikenameField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _bikenameField.textColor = [QFTools colorWithHexString:@"#adaaa8"];
    _bikenameField.text = @"爱玛电动车";
    _bikenameField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    _bikenameField.leftViewMode = UITextFieldViewModeAlways;
    _bikenameField.borderStyle = UITextBorderStyleNone;
    [whiteView addSubview:_bikenameField];
    
    UIView *lineView =[[UIView alloc] initWithFrame:CGRectMake(_bikenameField.x, CGRectGetMaxY(_bikenameField.frame), _bikenameField.width, 1)];
    lineView.backgroundColor = [QFTools colorWithHexString:MainColor];
    [whiteView addSubview:lineView];
    
    UIButton *sureBtn = [[UIButton alloc] initWithFrame:CGRectMake(_bikenameField.x, whiteView.height - 40, _bikenameField.width, 30)];
    sureBtn.backgroundColor = [UIColor whiteColor];
    [sureBtn setTitle:@"确定" forState:UIControlStateNormal];
    [sureBtn setTitleColor:[QFTools colorWithHexString:MainColor] forState:UIControlStateNormal];
    [sureBtn addTarget:self action:@selector(sureBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [whiteView addSubview:sureBtn];
    
}

#pragma mark - 点击屏幕取消键盘
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self endEditing:YES];
    
}

-(void)sureBtnClick{
    
    if ([QFTools isBlankString:_bikenameField.text ]) {
        [SVProgressHUD showSimpleText:@"车名不能为空"];
        return;
    }else if (_bikenameField.text.length>6) {
        
        [SVProgressHUD showSimpleText:@"车名不能超过六位"];
        return ;
    }
    
    [self endEditing:YES];
    if (self.NameSureBlock) {
        self.NameSureBlock(_bikenameField.text);
    }
    
}

@end
