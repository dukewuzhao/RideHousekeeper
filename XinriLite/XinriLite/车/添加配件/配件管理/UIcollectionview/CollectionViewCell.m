//
//  CollectionViewCell.m
//  UICollectionViewDemo1
//
//  Created by user on 15/11/2.
//  Copyright © 2015年 BG. All rights reserved.
//

#import "CollectionViewCell.h"

@implementation CollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _icon  = [[UIImageView alloc] initWithFrame:CGRectMake(0, 15, 65, 65)];
        [self.contentView addSubview:_icon];
        
        _textLabel = [[UILabel alloc] init];
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.textColor = [UIColor whiteColor];
        _textLabel.font = [UIFont systemFontOfSize:15];
        [self.contentView addSubview:_textLabel];
        [_textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_icon.mas_bottom).offset(10);
            make.centerX.equalTo(self.contentView);
            make.height.mas_equalTo(20);
        }];
    }
    
    return self;
}



@end
