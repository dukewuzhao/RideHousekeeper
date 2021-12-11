//
//  FirstVersionServices.h
//  myTest
//
//  Created by Apple on 2019/8/26.
//  Copyright © 2019 Apple. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "BLEEnumerate.h"
NS_ASSUME_NONNULL_BEGIN

@interface FirstVersionServices : NSObject

-(void)readingVehicleInformation:(NSInteger)num data:(void (^)(id data))data error:(void (^ _Nullable)(CommandStatus status))error;

-(void)getDeviceAutomaticLockStatus:(BOOL)status automaticLockBlock:(void (^)(BOOL automaticLock))data error:(void (^_Nullable)(CommandStatus status))error;

-(void)connectGPSByMac:(NSString *_Nonnull)mac data:(void (^_Nonnull)(id data))data error:(void (^_Nullable)(CommandStatus status))error;

@end

NS_ASSUME_NONNULL_END
