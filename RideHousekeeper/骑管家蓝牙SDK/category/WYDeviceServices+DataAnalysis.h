//
//  WYDeviceServices+DataAnalysis.h
//  myTest
//
//  Created by Apple on 2019/7/9.
//  Copyright © 2019 Apple. All rights reserved.
//

#import "WYDeviceServices.h"
@class BikeStatusModel,DeviceConfigurationModel;

NS_ASSUME_NONNULL_BEGIN

@interface WYDeviceServices (DataAnalysis)

- (BikeStatusModel *)analysisBikestatus:(BikeStatusModel *)model :(NSString *)data;

- (DeviceConfigurationModel *)analysisBikeConfiguration:(NSString *)data;

- (void)analysisAddNomalKey:(NSInteger)hardwareNum data:(NSString *)data steps:(void (^)(ConfigurationSteps step))step;

- (void)analysisAddFingerPrint:(NSString *)data status:(void (^_Nullable)(FingerPrintStatus status))status;

- (void)analysisInquireFingerPrint:(NSString *)data fingerPrinttype:(NSString *)type status:(void (^_Nullable)(FingerPrintStatus status))status;

- (NSNumber *)analysisVehicleInformationReading:(NSString *)data;
//Vehicle information reading

- (void)analysisDeviceSettingStatus:(NSString *)data callBack:(void (^_Nonnull)(BOOL boolValue))callBack;

- (void)analysisDeviceInductionValue:(NSString *)data callBack:(void (^_Nonnull)(NSInteger value))callBack;

@end

NS_ASSUME_NONNULL_END
