//
//  CommandDistributionServices.m
//  myTest
//
//  Created by Apple on 2019/6/21.
//  Copyright © 2019 Apple. All rights reserved.
//

#import "CommandDistributionServices.h"
#import "WYDeviceServices.h"
@implementation CommandDistributionServices


+(CBCentralManager *)restoreCentralManager:(NSString *)identifier{
    return [[WYDeviceServices shareInstance] restoreCentralManager:identifier];
}

+(CBCentralManager *)getCentralManager{
    
    return [[WYDeviceServices shareInstance] getCentralManager];
}

+(void)restCentralManagerStatus{
    [[WYDeviceServices shareInstance] restCentralManagerStatus];
}

+(BOOL)isConnect{
    
    return [[WYDeviceServices shareInstance] isConnect];
}

+(void)monitorBLEStatus:(void (^_Nonnull)(BLEStatus status))managerBlock{
    [[WYDeviceServices shareInstance] monitorBLEStatus:managerBlock];
}

+(void)startScan:(DeviceScanType)type PeripheralList:(void (^_Nonnull)(NSMutableArray *arry))peripheraAry{
    [[WYDeviceServices shareInstance] startScan:type];
    [WYDeviceServices shareInstance].scanBlock = peripheraAry;
}

//+(void)startScan:(DeviceScanType)type{
//    [[WYDeviceServices shareInstance] startScan:type];
//}

+(void)stopScan{
    [[WYDeviceServices shareInstance] stopScan];
}

+(void)connectPeripheral:(CBPeripheral *)peripheral{
    
    [[WYDeviceServices shareInstance] connectPeripheral:peripheral];
}

+(void)connectPeripheralByUUIDString:(NSString *__nullable)UUIDSting{
    [[WYDeviceServices shareInstance] connectPeripheralByUUIDString:UUIDSting];
}

+(void)connectGPSByMac:(NSString *_Nonnull)mac data:(void (^_Nonnull)(id data))data error:(void (^_Nullable)(CommandStatus status))error{
    [[WYDeviceServices shareInstance] connectGPSByMac:mac data:data  error:error];
}

+(void)queryVehicleStatusOnce:(void (^_Nonnull)(BikeStatusModel *model))data error:(void (^_Nullable)(CommandStatus status))error{
    [[WYDeviceServices shareInstance] queryVehicleStatusOnce:data error:error];
}

+(void)sendPasswordCommend:(NSString *)password data:(void (^_Nonnull)(id data))data error:(void (^_Nullable)(CommandStatus status))error{
    
    [[WYDeviceServices shareInstance] sendPasswordCommend:password data:data error:error];
}

+(void)GPSAuthentication:(NSString *)authenticationCode data:(void (^_Nonnull)(id data))data error:(void (^_Nullable)(CommandStatus status))error{
    [[WYDeviceServices shareInstance] GPSAuthentication:authenticationCode data:data error:error];
}

+(BOOL)getGPSAuthenticationStatus{
    return [[WYDeviceServices shareInstance] getGPSAuthenticationStatus];
}

+(void)QueryGPSActivationStatus:(GPSOperationMode)mode  data:(void (^_Nonnull)(id data))data error:(void (^_Nullable)(CommandStatus status))error{
    [[WYDeviceServices shareInstance] QueryGPSActivationStatus:mode data:data error:error];
}

+(void)SetGPSWorkingMode:(GPSWorkingMode)mode data:(void (^_Nonnull)(id data))data error:(void (^_Nullable)(CommandStatus status))error{
    [[WYDeviceServices shareInstance] SetGPSWorkingMode:mode data:data error:error];
}

+(void)sendSingleGPSActivationCommend:(SwitchStatus)behavior data:(void (^_Nonnull)(id data))data error:(void (^_Nullable)(CommandStatus status))error{
    [[WYDeviceServices shareInstance] sendSingleGPSActivationCommend:behavior data:data error:error];
}

+(void)getSatelliteDataCommend:(void (^_Nonnull)(id data))data error:(void (^_Nullable)(CommandStatus status))error{
    [[WYDeviceServices shareInstance] getSatelliteDataCommend:data error:error];
}

+(void)getGPSGSMSignalValue:(void (^_Nonnull)(id data))data error:(void (^_Nullable)(CommandStatus status))error{
    [[WYDeviceServices shareInstance] getGPSGSMSignalValue:data error:error];
}

+(void)setGPSReset:(void (^_Nullable)(CommandStatus status))error{
    [[WYDeviceServices shareInstance] setGPSReset:error];
}

+(void)enterFirmwareUpgrade:(void (^)(id data))data error:(void (^_Nullable)(CommandStatus status))error{
    [[WYDeviceServices shareInstance] enterFirmwareUpgrade:data error:error];
}

+(void)querykeyVersionNumber:(void (^)(NSString *data))data error:(void (^)(CommandStatus status))error{
    [[WYDeviceServices shareInstance] querykeyVersionNumber:data error:error];
}

+(void)removePeripheral:(CBPeripheral *)peripheral{
    
    [[WYDeviceServices shareInstance] removePeripheral:peripheral];
}

+(void)monitorConnectStatus:(void (^)(DeviceConnectStatus status))callback{
    [[WYDeviceServices shareInstance] monitorConnectStatus:callback];
}

+(void)getBikeBasicStatues:(TimeNum)time data:(void (^)(BikeStatusModel *model))data{
    
    [[WYDeviceServices shareInstance] getBikeBasicStatues:time data:data];
}

+(void)setBikeBasicStatues:(NomalCommand)commandType error:(void (^)(CommandStatus code))error{
    [[WYDeviceServices shareInstance] setBikeBasicStatues:commandType error:error];
}

+(void)addNomalKeyConfiguration:(NSInteger)seq hardwareNum:(NSInteger)hardwareNum step:(void (^)(ConfigurationSteps step))step error:(void (^)(CommandStatus status))error{
    [[WYDeviceServices shareInstance] addNomalKeyConfiguration:seq hardwareNum:hardwareNum steps:step error:error];
}

+(void)deleteNomalKeyConfiguration:(NSInteger)seq error:(void (^)(CommandStatus code))error{
    [[WYDeviceServices shareInstance] deleteNomalKeyConfiguration:seq error:error];
}

+(void)quiteNomalKeyConfiguration:(void (^ _Nullable)(CommandStatus status))error{
    [[WYDeviceServices shareInstance] quiteNomalKeyConfiguration:error];
}

+(void)readingVehicleInformation:(void (^)(id data))data error:(void (^ _Nullable)(CommandStatus status))error{
    [[WYDeviceServices shareInstance] readingVehicleInformation:data error:error];
}

+(void)addInductionKey:(NSInteger)seq mac:(NSString *)Mac data:(void (^)(id data))data error:(void (^)(CommandStatus code))error{
    [[WYDeviceServices shareInstance] addInductionKey:seq mac:Mac data:data error:error];
}

+(void)deleteInductionKey:(NSInteger)seq mac:(NSString *)Mac data:(void (^)(id data))data error:(void (^)(CommandStatus code))error{
    [[WYDeviceServices shareInstance] deleteInductionKey:seq mac:Mac data:data error:error];
}

+(void)addBLEKey:(NSInteger)seq data:(void (^_Nonnull)(id data))data error:(void (^_Nullable)(CommandStatus status))error{
    [[WYDeviceServices shareInstance] addBLEKey:seq data:data error:error];
}

+(void)deleteBLEKey:(NSInteger)seq data:(void (^)(id data))data error:(void (^)(CommandStatus code))error{
    [[WYDeviceServices shareInstance] deleteBLEKey:seq data:data error:error];
}

+(void)quiteBLEKeyConfiguration:(NSInteger)seq data:(void (^_Nonnull)(id data))data error:(void (^_Nullable)(CommandStatus status))error{
    [[WYDeviceServices shareInstance] quiteBLEKeyConfiguration:seq data:data error:error];
}

+(void)addTirePressure:(NSInteger)seq mac:(NSString *)Mac data:(void (^_Nonnull)(id data))data error:(void (^_Nullable)(CommandStatus status))error{
    
    [[WYDeviceServices shareInstance] addTirePressure:seq mac:Mac data:data error:error];
}

+(void)deleteTirePressure:(NSInteger)seq mac:(NSString *)Mac data:(void (^_Nonnull)(id data))data error:(void (^_Nullable)(CommandStatus status))error{
    
    [[WYDeviceServices shareInstance] deleteTirePressure:seq mac:Mac data:data error:error];
}

+(void)addFingerPrint:(NSInteger)num fingerPrintType:(NSInteger)fingerPrintType status:(void (^_Nullable)(FingerPrintStatus status))status error:(void (^)(CommandStatus code))error{
    [[WYDeviceServices shareInstance] addFingerPrint:num fingerPrintType:fingerPrintType status:status error:error];
} //num（0-10）为指纹的配置次序，

+(void)deleteFingerPrint:(NSInteger)num data:(void (^)(id data))data error:(void (^)(CommandStatus code))error{
    [[WYDeviceServices shareInstance] deleteFingerPrint:num data:data error:error];
} // num为0则为清空所有指纹

+(void)quiteFingerPrint:(NSInteger)num fingerPrintType:(NSInteger)fingerPrintType error:(void (^ _Nullable)(CommandStatus status))error{
    [[WYDeviceServices shareInstance] quiteFingerPrint:num fingerPrintType:fingerPrintType error:error];
}

+(void)getDeviceSpeedingAlarmStatus:(void (^)(BOOL speedingAlarm))data{
    [[WYDeviceServices shareInstance] getDeviceSpeedingAlarmStatus:data];
}

+(void)setDeviceSpeedingAlarmStatus:(SwitchStatus)status error:(void (^)(CommandStatus code))error{
    [[WYDeviceServices shareInstance] setDeviceSpeedingAlarmStatus:status error:error];
}

+(void)getDeviceAutomaticLockStatus:(void (^)(BOOL automaticLock))data error:(void (^_Nullable)(CommandStatus code))error{
    [[WYDeviceServices shareInstance] getDeviceAutomaticLockStatus:data error:error];
}

+(void)setDeviceAutomaticLockStatus:(SwitchStatus)status data:(void (^)(BOOL automaticLock))data error:(void (^)(CommandStatus code))error{
    [[WYDeviceServices shareInstance] setDeviceAutomaticLockStatus:status data:data error:error];
    
}

+(void)getDeviceSensingDistanceValue:(void (^)(NSInteger value))data error:(void (^_Nullable)(CommandStatus code))error{
    [[WYDeviceServices shareInstance] getDeviceSensingDistanceValue:data error:error];
}

+(void)setDeviceSensingDistanceValue:(NSInteger)value data:(void (^)(NSInteger value))data error:(void (^)(CommandStatus code))error{
    [[WYDeviceServices shareInstance] setDeviceSensingDistanceValue:value data:data error:error];
    
}

+(void)getDeviceShockStatus:(void (^)(ShockState))data{
    [[WYDeviceServices shareInstance] getDeviceShockStatus:data];
}

+(void)setDeviceShockStatus:(ShockState)status error:(void (^)(CommandStatus code))error{
    [[WYDeviceServices shareInstance] setDeviceShockStatus:status error:error];
}

+(void)bikePasswordConfiguration:(NSDictionary *)passwordDic data:(void (^)(id data))data error:(void (^_Nullable)(CommandStatus status))error{
    [[WYDeviceServices shareInstance] bikePasswordConfiguration:passwordDic data:data error:error];
}

+(void)getDeviceSupportdata:(void (^)(DeviceConfigurationModel *model))data error:(void (^)(CommandStatus code))error{
    [[WYDeviceServices shareInstance] getDeviceSupportdata:data error:error];
}


+(void)getDeviceFirmwareRevisionString:(void (^ _Nonnull)(NSString *revision))firmwareStr error:(void (^_Nullable)(CommandStatus status))error{
    [[WYDeviceServices shareInstance] getDeviceFirmwareRevisionString:firmwareStr error:error];
}

+(void)getDeviceHardwareRevisionString:(void (^ _Nonnull)(NSString *revision))hardwareStr error:(void (^_Nullable)(CommandStatus status))error{
    [[WYDeviceServices shareInstance] getDeviceHardwareRevisionString:hardwareStr  error:error];
}

@end
