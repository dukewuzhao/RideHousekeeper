//
//  CommandModel.h
//  myTest
//
//  Created by Apple on 2019/6/28.
//  Copyright © 2019 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class CommandModel;
typedef void(^commandBlock)(CommandStatus status);
typedef void(^timeFiredBlock)(CommandModel *model);
typedef void(^callBackDateBlock)(id data);
@interface CommandModel : NSObject
@property (nonatomic, assign) BOOL noNeedRSP;//是否需要应答
@property (nonatomic, copy) NSData *data;
@property (nonatomic, strong) NSMutableArray *commandAry;
@property (nonatomic, copy) callBackDateBlock __nullable backdata;
@property (nonatomic, copy) commandBlock error;
@property (nonatomic, copy) timeFiredBlock timeFire;
-(void)startMonitorTime;
-(void)stopMonitorTime;

@end

@interface SingerPacketCommandModel : NSObject

@property (assign, nonatomic)BOOL sendGPS;
@property (nonatomic,strong) NSData *commndData;
@end

NS_ASSUME_NONNULL_END
