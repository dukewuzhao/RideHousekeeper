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
        PromptLab.textColor = [UIColor whiteColor];
        PromptLab.text = NSLocalizedString(@"fingerpring_set_down", nil);
        PromptLab.font = [UIFont systemFontOfSize:20];
        [self addSubview:PromptLab];
        
        _operationLab = [[UILabel alloc] initWithFrame:CGRectMake(40, CGRectGetMaxY(PromptLab.frame)+15, ScreenWidth - 80, 60)];
        _operationLab.textAlignment = NSTextAlignmentCenter;
        _operationLab.textColor = [UIColor whiteColor];
        _operationLab.numberOfLines = 0;
        _operationLab.text = NSLocalizedString(@"fingerpring_content", nil);
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
