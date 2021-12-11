//
//  CommandModel.m
//  myTest
//
//  Created by Apple on 2019/6/28.
//  Copyright © 2019 Apple. All rights reserved.
//

#import "CommandModel.h"

@interface CommandModel()
{
    NSTimeInterval timeNum;
}
@property(nonatomic, strong) MSWeakTimer * monitorTime;

@end
@implementation CommandModel

- (instancetype)init{
    if (self = [super init]) {
        
    }
    
    return self;
}

-(void)setData:(NSData *)data{
    _data = data;
    if ([[[ConverUtil data2HexString:data] substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"3021"]) {
        timeNum = 10;
    }else if ([[[ConverUtil data2HexString:data] substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"1010"]) {
        timeNum = 10;
    }else{
        timeNum = 3;
    }
    
}

-(void)startMonitorTime{
    
    _monitorTime = [MSWeakTimer scheduledTimerWithTimeInterval:timeNum target:self selector:@selector(monitorFired) userInfo:nil repeats:NO dispatchQueue:dispatch_get_main_queue()];
}

-(void)monitorFired{
    NSLog(@"发送失败的指令%@",_data);
    
    if (_error) {
        _error(SendFail);
    }
    if (_timeFire) {
        _timeFire(self);
    }
}

-(void)stopMonitorTime{
    
    [_monitorTime invalidate];
    _monitorTime = nil;
}

-(void)dealloc{
    //[[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(monitorFired) object:self];
    [_monitorTime invalidate];
    _monitorTime = nil;
}

@end

@implementation SingerPacketCommandModel



@end
