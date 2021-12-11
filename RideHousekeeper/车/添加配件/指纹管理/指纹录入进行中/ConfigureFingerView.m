//
//  ConfigureFingerView.m
//  TaiwanIntelligence
//
//  Created by Apple on 2018/3/21.
//  Copyright © 2018年 DUKE.Wu. All rights reserved.
//

#import "ConfigureFingerView.h"

@implementation ConfigureFingerView

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
        
        UILabel *PromptLab = [[UILabel alloc] initWithFrame:CGRectMake(20, 22, ScreenWidth - 40, 20)];
        PromptLab.textAlignment = NSTextAlignmentCenter;
        PromptLab.textColor = [UIColor blackColor];
        PromptLab.text = @"重复放置手指";
        PromptLab.font = [UIFont systemFontOfSize:20];
        [self addSubview:PromptLab];
        
        _operationLab = [[UILabel alloc] initWithFrame:CGRectMake(40, CGRectGetMaxY(PromptLab.frame)+15, ScreenWidth - 80, 50)];
        _operationLab.textAlignment = NSTextAlignmentCenter;
        _operationLab.textColor = [UIColor blackColor];
        _operationLab.numberOfLines = 0;
        _operationLab.text = @"将手指放在车辆指纹模组按钮上再移开，持续录入手指正面及边缘不同位置，重复此步骤";
        _operationLab.font = [UIFont systemFontOfSize:15];
        [self addSubview:_operationLab];
        
        _fingerIcon = [[UIImageView alloc] init];
        _fingerIcon.frame = CGRectMake(ScreenWidth*.28, CGRectGetMaxY(_operationLab.frame)+50, ScreenWidth*.44, ScreenWidth*.44);
        _fingerIcon.image = [UIImage imageNamed:@"fingerprint_nomal"];
        [self addSubview:_fingerIcon];
        
    }
    return self;
}



@end
