//
//  SuccessInputFingerprint.m
//  RideHousekeeper
//
//  Created by Apple on 2017/11/21.
//  Copyright © 2017年 Duke Wu. All rights reserved.
//

#import "SuccessInputFingerprint.h"

@implementation SuccessInputFingerprint

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        //self.backgroundColor = [UIColor whiteColor];
        UIImageView *successImg = [[UIImageView alloc] init];
        
        UILabel *successLab = [[UILabel alloc] init];
        successLab.textColor = [UIColor blackColor];
        successLab.textAlignment = NSTextAlignmentCenter;
        successLab.text = @"录入成功";
        [self addSubview:successLab];
        
        successImg.frame = CGRectMake(ScreenWidth*.28, self.height *.3, ScreenWidth*.44, ScreenWidth*.44);
        successLab.frame = CGRectMake(40, 25, ScreenWidth - 80, 20);
        successLab.font = [UIFont systemFontOfSize:20];
        
        UILabel *printSuc = [[UILabel alloc] initWithFrame:CGRectMake(40, CGRectGetMaxY(successLab.frame)+10, ScreenWidth - 80, 20)];
        printSuc.text = @"指纹录入成功";
        printSuc.textColor = [UIColor blackColor];
        printSuc.textAlignment = NSTextAlignmentCenter;
        [self addSubview:printSuc];
                
        successImg.image = [UIImage imageNamed:@"fingerprint_step_three"];
        [self addSubview:successImg];
        
        @weakify(self);
        UIButton *inputNext = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth/2 - 80, ScreenHeight- navHeight - 140, 160, 35)];
        [inputNext setTitle:@"录入下一个指纹" forState:UIControlStateNormal];
        [inputNext setTitleColor:[QFTools colorWithHexString:MainColor] forState:UIControlStateNormal];
        [[inputNext rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            if([self.delegate respondsToSelector:@selector(InputFingerprintNext)])
            {
                [self.delegate InputFingerprintNext];
            }
        }];
//        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"查看所有中奖记录"];
//        NSRange strRange = {0,[str length]};
//        [str addAttribute:NSForegroundColorAttributeName value:[QFTools colorWithHexString:@"#06c1ae"] range:strRange];
//        [str addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:strRange];
//        [inputNext setAttributedTitle:str forState:UIControlStateNormal];
        [self addSubview:inputNext];
        
        UIView *partingline = [[UIView alloc] initWithFrame:CGRectMake(inputNext.x+10, CGRectGetMaxY(inputNext.frame), inputNext.width - 20, 1.0)];
        partingline.backgroundColor = [QFTools colorWithHexString:MainColor];
        [self addSubview:partingline];
        
        UIButton *successBtn = [[UIButton alloc] initWithFrame:CGRectMake(25, CGRectGetMaxY(inputNext.frame)+30, ScreenWidth - 50, 45)];
        successBtn.backgroundColor = [UIColor redColor];
        [[successBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            if([self.delegate respondsToSelector:@selector(InputFingerprintSuccess)])
            {
                [self.delegate InputFingerprintSuccess];
            }
        }];
        [successBtn setTitle:@"完成" forState:UIControlStateNormal];
        successBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [successBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        successBtn.backgroundColor = [QFTools colorWithHexString:MainColor];
        [successBtn.layer setCornerRadius:10.0]; // 切圆角
        [self addSubview:successBtn];
    }
    return self;
}

@end
