//
//  CFSettingLabelItem.m
//  TableViewSettingList
//
//  Created by wangchangfei on 15/9/24.
//  Copyright (c) 2015年 wangchangfei. All rights reserved.
//

#import "CFSettingLabelItem.h"

#import "CFSaveTool.h"

@implementation CFSettingLabelItem

-(void)setText_right:(NSString *)text_right{
    _text_right = text_right;
}

-(void)setRightLab_color:(UIColor *)rightLab_color{
    _rightLab_color = rightLab_color;
}

- (void)setTitle:(NSString *)title {
  [super setTitle:title];
}

@end
