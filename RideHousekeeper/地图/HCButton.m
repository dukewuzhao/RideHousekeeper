//
//  HCButton.m
//  57-ipad(QQ空间)
//
//  Created by 黄辰 on 14-8-25.
//  Copyright (c) 2014年 itcast. All rights reserved.
//

#import "HCButton.h"
@implementation HCButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setTitleColor:[QFTools colorWithHexString:@"#999999"] forState:UIControlStateNormal];
        [self setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
        self.backgroundColor = [QFTools colorWithHexString:@"#F5F5F5"];
        self.titleLabel.font = [UIFont systemFontOfSize:12];
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted{}

@end
