//
//  BindingHitView.m
//  RideHousekeeper
//
//  Created by Apple on 2020/4/20.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import "BindingHitView.h"

@implementation BindingHitView

- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title color:(UIColor *)color{
    self = [super init];
    if (self) {
        self.backgroundColor = color;
        self.frame = frame;
        UILabel *label = [[UILabel alloc] init];
        label.numberOfLines = 0;
        label.text = title;
        //label.backgroundColor = color;
        label.textColor = [QFTools colorWithHexString:@"#FF5E00"];
        label.font = FONT_PINGFAN(12);
        //label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(20);
            make.right.equalTo(self).offset(-20);
            make.top.equalTo(self).offset(5);
            make.bottom.equalTo(self).offset(-5);
        }];
    }
    return self;
}
    
@end
