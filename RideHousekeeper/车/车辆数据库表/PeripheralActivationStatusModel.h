//
//  PeripheralActivationStatusModel.h
//  RideHousekeeper
//
//  Created by Apple on 2020/3/27.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PeripheralActivationStatusModel : NSObject
@property (nonatomic, assign) NSInteger bikeid; //车辆内部id
@property (nonatomic, assign) NSInteger deviceid;//外设id
@property (nonatomic, assign) NSInteger type;//设备类型
@property (nonatomic, assign) NSInteger activationStatus;//激活状态

+(instancetype)modelWith:(NSInteger)bikeid deviceid:(NSInteger)deviceid type:(NSInteger)type activationStatus:(NSInteger)activationStatus;

@end

NS_ASSUME_NONNULL_END
