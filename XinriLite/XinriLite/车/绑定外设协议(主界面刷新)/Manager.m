//
//  Manger.m
//  MultiDelegateDemo
//
//  Created by JiangMing on 2017/3/20.
//  Copyright © 2017年 JiangMing. All rights reserved.
//

#import "Manager.h"

@interface Manager()

{
    MultiDelegate<ManagerDelegate>     *_multiDelegate;
    
}

@end

@implementation Manager

+ (instancetype)shareManager{
    static Manager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}


- (id)init {
    if (self = [super init]) {
        _multiDelegate = (MultiDelegate<ManagerDelegate> *)[[MultiDelegate alloc] init];
        _multiDelegate.silentWhenEmpty = YES;
    }
    return self;
}


#pragma mark - Public Methods
- (void)addDelegate:(id<ManagerDelegate>)delegate{
    if (delegate && ![_multiDelegate.delegates.allObjects containsObject:delegate]) {
        [_multiDelegate addDelegate:delegate];
    }
}

- (void)deleteDelegate:(id<ManagerDelegate>)delegate{
    [_multiDelegate removeDelegate:delegate];
}

- (void)clearAllDelegates{
    [_multiDelegate removeAllDelegates];
}


- (void)bindingPeripheralSucceeded:(PeripheralModel *)model{
    
    if ([_multiDelegate respondsToSelector:@selector(manager:bindingPeripheralSucceeded:)]) {
        [_multiDelegate manager:self bindingPeripheralSucceeded:model];
    }
}

- (void)deletePeripheralSucceeded:(PeripheralModel *)model{
    
    if ([_multiDelegate respondsToSelector:@selector(manager:deletePeripheralSucceeded:)]) {
        [_multiDelegate manager:self deletePeripheralSucceeded:model];
    }
}

- (void)updatebikeName:(NSString *)name :(NSInteger)bikeId{
    
    if ([_multiDelegate respondsToSelector:@selector(manager:updatebikeName::)]) {
        [_multiDelegate manager:self updatebikeName:name :bikeId];
    }
}
- (void)updateUserMessage:(NSString *)name :(UIImage *)img{
    
    if ([_multiDelegate respondsToSelector:@selector(manager:updateUserMessage::)]) {
        [_multiDelegate manager:self updateUserMessage:name :img];
    }
}

- (void)postRemoteJPush:(NSDictionary *)dict{
    
    if ([_multiDelegate respondsToSelector:@selector(manager:postRemoteJPush:)]) {
        [_multiDelegate manager:self postRemoteJPush:dict];
    }
}

- (void)switchingVehicle:(NSDictionary *)dict{
    
    if ([_multiDelegate respondsToSelector:@selector(manager:switchingVehicle:)]) {
        [_multiDelegate manager:self switchingVehicle:dict];
    }
}



@end
