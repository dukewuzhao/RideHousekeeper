//
//  DeviceConfigurationModel.h
//  myTest
//
//  Created by Apple on 2019/7/9.
//  Copyright © 2019 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DeviceConfigurationModel : NSObject

@property (assign, nonatomic) BOOL supportFingerprint;//指纹
@property (assign, nonatomic) BOOL supportVibrationSensor;//震动灵敏度
@property (assign, nonatomic) BOOL supportTirePressure;//胎压
@property (assign, nonatomic) BOOL supportSpeedAlarm;//超速警报
@property (assign, nonatomic) BOOL supportGPS;//是否支持GPS
@property (assign, nonatomic) NSInteger fingerprintConfigurationTimes;//指纹几次配置
@property (assign, nonatomic) NSInteger numberOfWheels;//车轮数
@end

NS_ASSUME_NONNULL_END
