//
//  CardCollectionViewCell.m
//  RideHousekeeper
//
//  Created by Apple on 2019/10/22.
//  Copyright © 2019 Duke Wu. All rights reserved.
//

#import "CardCollectionViewCell.h"

@implementation CardCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self){
        _cardView  = [[CardView alloc] init];
        [self.contentView addSubview:_cardView];
        [_cardView mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.left.equalTo(self).offset(15);
            make.top.equalTo(self).offset(10);
            make.right.equalTo(self);
            make.bottom.equalTo(self);
        }];
    }
    
    return self;
}

@end
