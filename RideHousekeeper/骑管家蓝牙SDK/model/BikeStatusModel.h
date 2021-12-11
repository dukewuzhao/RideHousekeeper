//
//  BikeStatusModel.h
//  myTest
//
//  Created by Apple on 2019/6/21.
//  Copyright © 2019 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FaultModel;
NS_ASSUME_NONNULL_BEGIN

@interface BikeStatusModel : NSObject

@property (assign, nonatomic) BOOL isLock;
@property (assign, nonatomic) BOOL isMute;
@property (assign, nonatomic) BOOL isElectricDoorOpen;
@property (assign, nonatomic) BOOL keyInduction;
@property (assign, nonatomic) BOOL gpsConnection;
@property (assign, nonatomic) BOOL speedingAlarm;//超速警报
@property (assign, nonatomic) BOOL tirePressureAlarm;//胎压警报
@property (assign, nonatomic) BOOL automaticLock;//自动锁车
@property (assign, nonatomic) NSInteger temperatureValue;
@property (assign, nonatomic) NSInteger voltageValue;
@property (assign, nonatomic) NSInteger inductionElectricity;
@property (assign, nonatomic) NSInteger firstTireValue;
@property (assign, nonatomic) NSInteger secondTireValue;
@property (assign, nonatomic) NSInteger thirdTireValue;//第三胎压
@property (assign, nonatomic) NSInteger fourthTireValue;//第四胎压
@property (assign, nonatomic) NSInteger rssiValue;
@property (assign, nonatomic) ShockState shockState;
@property (strong, nonatomic) FaultModel* faultModel;


@end

NS_ASSUME_NONNULL_END
