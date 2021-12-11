//
//  CFLableView.m
//  RideHousekeeper
//
//  Created by Apple on 2019/11/1.
//  Copyright © 2019 Duke Wu. All rights reserved.
//

#import "CFLableView.h"
@interface CFLableView()
@property(nonatomic, weak) UILabel *lbMsg;
@end
@implementation CFLableView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        UILabel *lbMsg = [[UILabel alloc] init];
        self.lbMsg = lbMsg;
        [self addSubview:lbMsg];
        
    }
    return self;
}


- (void)layoutSubviews {
    [super layoutSubviews];
    self.lbMsg.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}


- (void)setText:(NSString *)text {
    _text = text;
    self.lbMsg.text = text;
    self.lbMsg.textAlignment = NSTextAlignmentRight;
}


-(void)setRightLabelFont:(UIFont *)rightLabelFont{
    _rightLabelFont = rightLabelFont;
    self.lbMsg.font = rightLabelFont;
}

-(void)setRightLabelFontColor:(UIColor *)rightLabelFontColor{
    _rightLabelFontColor = rightLabelFontColor;
    self.lbMsg.textColor = rightLabelFontColor;
}

@end
