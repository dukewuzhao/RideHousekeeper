//
//  AccessoriesModel.m
//  RideHousekeeper
//
//  Created by Apple on 2018/11/22.
//  Copyright © 2018年 Duke Wu. All rights reserved.
//

#import "AccessoriesModel.h"

@implementation AccessoriesModel

-(instancetype)init{
    if (self = [super init]) {
        
        _infoAry = [NSMutableArray new];
        _pictureName = [UIImage new];
    }
        return self;
}

@end
