//
//  OrderCommodityCollectionViewCell.m
//  RideHousekeeper
//
//  Created by Apple on 2020/3/16.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import "OrderCommodityCollectionViewCell.h"

@implementation OrderCommodityCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self){
        _icon  = [[UIImageView alloc] init];
        [self.contentView addSubview:_icon];
        [_icon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.bottom.equalTo(self);
        }];
    }
    
    return self;
}

@end
