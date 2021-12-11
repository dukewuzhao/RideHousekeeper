//
//  SearchBleModel.m
//  RideHousekeeper
//
//  Created by Apple on 2017/10/17.
//  Copyright © 2017年 Duke Wu. All rights reserved.
//

#import "SearchBleModel.h"

@interface SearchBleModel()
@property(nonatomic, strong) MSWeakTimer * queraTime;
@end

@implementation SearchBleModel

- (instancetype)init{
    return [self initWithType:DeviceNomalType];
}


- (instancetype)initWithType:(DeviceScanType)type {
    if (self = [super init]) {
        if (type == DeviceBingDingType || type == DeviceDFUType) {
            
            _queraTime = [MSWeakTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(queryFired) userInfo:nil repeats:YES dispatchQueue:dispatch_get_main_queue()];
        }
    }
    
    return self;
}

-(void)queryFired{
    
    if (self.searchCount == 0) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(removePeripher:)]) {
            [self.delegate removePeripher:self.mac];
        }
        [_queraTime invalidate];
        _queraTime = nil;
    }else{
        
        self.searchCount = 0;
    }
    
}

-(void)stopSearchBle{
    
    [self.queraTime invalidate];
    self.queraTime = nil;
}

-(void)dealloc{
    [_queraTime invalidate];
    _queraTime = nil;
}

@end
