//
//  BikeStatusModel.m
//  myTest
//
//  Created by Apple on 2019/6/21.
//  Copyright © 2019 Apple. All rights reserved.
//

#import "BikeStatusModel.h"
#import "FaultModel.h"
@implementation BikeStatusModel

- (instancetype)init{
    if (self = [super init]) {
        _faultModel = [[FaultModel alloc] init];
    }
    
    return self;

}
@end
