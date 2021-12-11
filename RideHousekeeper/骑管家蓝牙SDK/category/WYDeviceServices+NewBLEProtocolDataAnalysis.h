//
//  WYDeviceServices+NewBLEProtocolDataAnalysis.h
//  myTest
//
//  Created by Apple on 2019/8/21.
//  Copyright © 2019 Apple. All rights reserved.
//

#import "WYDeviceServices.h"
@class BikeStatusModel,DeviceConfigurationModel;
NS_ASSUME_NONNULL_BEGIN

@interface WYDeviceServices (NewBLEProtocolDataAnalysis)

- (NSInteger)RSPAnalysis:(NSString *)data;

- (BikeStatusModel *)newAnalysisBikestatus:(BikeStatusModel *)model :(NSString *)data;

- (void)analysisDeviceSettingStatus:(NSString *)data callBack:(void (^_Nonnull)(BOOL boolValue))callBack;

- (void)newAnalysisAddNomalKey:(NSInteger)hardwareNum data:(NSString *)data steps:(void (^)(ConfigurationSteps step))step;

- (DeviceConfigurationModel *)newAnalysisBikeConfiguration:(NSString *)data;

- (void)newAnalysisDeviceInductionValue:(NSString *)data callBack:(void (^_Nonnull)(NSInteger value))callBack;

-(void)newAnalysisAddFingerPrint:(NSString *)data status:(void (^_Nullable)(FingerPrintStatus status))status;

- (void)newAnalysisInquireFingerPrint:(NSString *)data status:(void (^_Nullable)(FingerPrintStatus status))status;

@end

NS_ASSUME_NONNULL_END
