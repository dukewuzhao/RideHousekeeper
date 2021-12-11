//
//  WYDeviceServices.h
//  myTest
//
//  Created by Apple on 2019/6/19.
//  Copyright © 2019 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BikeStatusModel,DeviceConfigurationModel;
NS_ASSUME_NONNULL_BEGIN

typedef void(^BLEScanBlock)(NSMutableArray *peripheralAry);

@interface WYDeviceServices : NSObject
@property (nonatomic,assign) DeviceScanType scanType;
@property (nonatomic, copy) BLEScanBlock scanBlock;
@property (nonatomic, copy,nullable) NSString *keyvalue,*key1,*key2,*key3,*key4;
@property (nonatomic, assign) NSInteger step,seq,hardwareNum;

@property (nonatomic, assign) NSInteger fingerPressNum,pressSecond;
@property (nonatomic, assign) CFAbsoluteTime startTime;
+(instancetype)shareInstance;

-(CBCentralManager *)restoreCentralManager:(NSString *)identifier;

-(CBCentralManager *)getCentralManager;

-(void)restCentralManagerStatus;

-(BOOL)isConnect;

-(void)sendHexstring:(NSData *)data callBack:(void (^_Nullable)(id response))backdata error:(void (^_Nullable)(CommandStatus code))error;

-(void)monitorBLEStatus:(void (^_Nonnull)(BLEStatus status))managerBlock;

-(void)startScan:(DeviceScanType)type;

-(void)stopScan;

-(void)connectPeripheral:(CBPeripheral *__nullable)peripheral;

-(void)connectPeripheralByUUIDString:(NSString *__nullable)UUIDSting;

-(void)connectGPSByMac:(NSString *_Nonnull)mac data:(void (^_Nonnull)(id data))data error:(void (^_Nullable)(CommandStatus status))error;

-(void)queryVehicleStatusOnce:(void (^_Nonnull)(BikeStatusModel *model))data error:(void (^_Nullable)(CommandStatus status))error;

-(void)sendPasswordCommend:(NSString *)password data:(void (^)(id data))data error:(void (^_Nullable)(CommandStatus status))error;

-(void)GPSAuthentication:(NSString *)authenticationCode data:(void (^_Nonnull)(id data))data error:(void (^_Nullable)(CommandStatus status))error;

-(BOOL)getGPSAuthenticationStatus;

-(void)QueryGPSActivationStatus:(GPSOperationMode)mode  data:(void (^_Nonnull)(id data))data error:(void (^_Nullable)(CommandStatus status))error;

-(void)SetGPSWorkingMode:(GPSWorkingMode)mode data:(void (^_Nonnull)(id data))data error:(void (^_Nullable)(CommandStatus status))error;

-(void)sendSingleGPSActivationCommend:(SwitchStatus)behavior data:(void (^_Nonnull)(id data))data error:(void (^_Nullable)(CommandStatus status))error;

-(void)getSatelliteDataCommend:(void (^_Nonnull)(id data))data error:(void (^_Nullable)(CommandStatus status))error;

-(void)getGPSGSMSignalValue:(void (^_Nonnull)(id data))data error:(void (^_Nullable)(CommandStatus status))error;

-(void)setGPSReset:(void (^_Nullable)(CommandStatus status))error;

-(void)enterFirmwareUpgrade:(void (^)(id data))data error:(void (^_Nullable)(CommandStatus status))error;

-(void)querykeyVersionNumber:(void (^)(NSString *data))data error:(void (^)(CommandStatus status))error;

-(void)removePeripheral:(CBPeripheral *__nullable)peripheral;//如果参数为空，断开所有连接，有参数，断开指定连接

-(void)monitorConnectStatus:(void (^)(DeviceConnectStatus status))callback;

-(void)setBikeBasicStatues:(NomalCommand)commandType error:(void (^_Nullable)(CommandStatus status))error;

-(void)getBikeBasicStatues:(TimeNum)time data:(void (^)(BikeStatusModel *model))data;

-(void)addNomalKeyConfiguration:(NSInteger)seq hardwareNum:(NSInteger)hardwareNum steps:(void (^)(ConfigurationSteps step))step error:(void (^_Nullable)(CommandStatus status))error;//没有返回值

-(void)deleteNomalKeyConfiguration:(NSInteger)seq error:(void (^_Nullable)(CommandStatus status))error;//没有返回值

-(void)quiteNomalKeyConfiguration:(void (^ _Nullable)(CommandStatus status))error;//退出普通钥匙配置模式

-(void)readingVehicleInformation:(void (^)(id data))data error:(void (^ _Nullable)(CommandStatus status))error;

-(void)addInductionKey:(NSInteger)seq mac:(NSString *)Mac data:(void (^)(id data))data error:(void (^_Nullable)(CommandStatus status))error;

-(void)deleteInductionKey:(NSInteger)seq mac:(NSString *)Mac data:(void (^)(id data))data error:(void (^_Nullable)(CommandStatus status))error;

-(void)addBLEKey:(NSInteger)seq data:(void (^)(id data))data error:(void (^_Nullable)(CommandStatus status))error;

-(void)deleteBLEKey:(NSInteger)seq data:(void (^)(id data))data error:(void (^_Nullable)(CommandStatus status))error;

-(void)quiteBLEKeyConfiguration:(NSInteger)seq data:(void (^_Nonnull)(id data))data error:(void (^_Nullable)(CommandStatus status))error;


-(void)addTirePressure:(NSInteger)seq mac:(NSString *)Mac data:(void (^_Nonnull)(id data))data error:(void (^_Nullable)(CommandStatus status))error;

-(void)deleteTirePressure:(NSInteger)seq mac:(NSString *)Mac data:(void (^_Nonnull)(id data))data error:(void (^_Nullable)(CommandStatus status))error;

-(void)addFingerPrint:(NSInteger)num fingerPrintType:(NSInteger)fingerPrintType status:(void (^_Nullable)(FingerPrintStatus status))status error:(void (^_Nullable)(CommandStatus status))error;

-(void)deleteFingerPrint:(NSInteger)num data:(void (^)(id data))data error:(void (^_Nullable)(CommandStatus status))error;

-(void)quiteFingerPrint:(NSInteger)num fingerPrintType:(NSInteger)fingerPrintType error:(void (^ _Nullable)(CommandStatus status))error;

-(void)getDeviceSpeedingAlarmStatus:(void (^)(BOOL speedingAlarm))data;//一般查询中获取

-(void)setDeviceSpeedingAlarmStatus:(SwitchStatus)status error:(void (^_Nullable)(CommandStatus status))error;//获取查询中的返回值

-(void)getDeviceAutomaticLockStatus:(void (^)(BOOL automaticLock))data error:(void (^_Nullable)(CommandStatus status))error;//查询自动锁车 300302

-(void)setDeviceAutomaticLockStatus:(SwitchStatus)status data:(void (^)(BOOL automaticLock))data error:(void (^_Nullable)(CommandStatus status))error;//设置制动锁车状态 00 01


-(void)getDeviceSensingDistanceValue:(void (^)(NSInteger value))data error:(void (^_Nullable)(CommandStatus status))error;//获取设备感应距离

-(void)setDeviceSensingDistanceValue:(NSInteger)value data:(void (^)(NSInteger value))data error:(void (^_Nullable)(CommandStatus status))error;//设置设备感应距离


-(void)setDeviceShockStatus:(ShockState)status error:(void (^_Nullable)(CommandStatus status))error;//设置设备震动灵敏度，

-(void)getDeviceShockStatus:(void (^)(ShockState))data;//获取设备震动灵敏度，一般查询中获取

-(void)bikePasswordConfiguration:(NSDictionary *)passwordDic data:(void (^)(id data))data error:(void (^_Nullable)(CommandStatus status))error;

-(void)getDeviceSupportdata:(void (^)(DeviceConfigurationModel *model))data error:(void (^_Nullable)(CommandStatus status))error;//获取设备支持的类型

-(void)getDeviceFirmwareRevisionString:(void (^ _Nonnull)(NSString *revision))firmwareStr error:(void (^_Nullable)(CommandStatus status))error;

-(void)getDeviceHardwareRevisionString:(void (^ _Nonnull)(NSString *revision))hardwareStr error:(void (^_Nullable)(CommandStatus status))error;


@end

NS_ASSUME_NONNULL_END
