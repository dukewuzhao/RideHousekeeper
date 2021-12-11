//
//  CommandDistributionServices.h
//  myTest
//
//  Created by Apple on 2019/6/21.
//  Copyright © 2019 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
@class BikeStatusModel,DeviceConfigurationModel;
NS_ASSUME_NONNULL_BEGIN

@interface CommandDistributionServices : NSObject

/**
恢复CBCentralManager实例对象

@return 蓝牙中控实例
*/
+(CBCentralManager *)restoreCentralManager:(NSString *)identifier;

/**
 获取APP的CBCentralManager实例对象方法

 @return 蓝牙中控实例
 */
+(CBCentralManager *)getCentralManager;

/**
 复位蓝牙中控的状态
 */
+(void)restCentralManagerStatus;

/**
 检测是否连接

 @return 返回是否连接的bool
 */
+(BOOL)isConnect;


/**
 监听centralManagerDidUpdateState

 @param managerBlock 蓝牙centralManager返回的当前状态
 */
+(void)monitorBLEStatus:(void (^_Nonnull)(BLEStatus status))managerBlock;

/**
 开启扫描

 @param type 扫描模式
 */
+(void)startScan:(DeviceScanType)type PeripheralList:(void (^_Nonnull)(NSMutableArray *arry))peripheraAry;

/**
 停止扫描
 */
+(void)stopScan;


/**
 连接指定蓝牙设备

 @param peripheral 蓝牙设备
 */
+(void)connectPeripheral:(CBPeripheral *__nullable)peripheral;

/**
 通过UUID连接指定蓝牙设备
 
 @param peripheral 蓝牙设备
 */
+(void)connectPeripheralByUUIDString:(NSString *__nullable)UUIDSting;

/**
告诉中控开始连接GPS设备

@param mac GPS设备Macs地址
@param callback GPS设备与中控连接状态
 @param error 返回错误码
*/
+(void)connectGPSByMac:(NSString *_Nonnull)mac data:(void (^_Nonnull)(id data))data error:(void (^_Nullable)(CommandStatus status))error;

/**
 连接状态监听
 
 @param callback 连接、断开的状态hblock
 */
+(void)monitorConnectStatus:(void (^_Nonnull)(DeviceConnectStatus status))callback;

/// 查询车辆状态
/// @param data 返回数据
/// @param error 返回错误码
+(void)queryVehicleStatusOnce:(void (^_Nonnull)(BikeStatusModel *model))data error:(void (^_Nullable)(CommandStatus status))error;

/**
 发送密码

 @param password 密码
 @param data 返回数据
 */
+(void)sendPasswordCommend:(NSString *)password data:(void (^_Nonnull)(id data))data error:(void (^_Nullable)(CommandStatus status))error;

/**
 GPS鉴权方法

 @param authenticationCode 鉴权码
 @param data 返回数据
 @param error 返回错误码
 */
+(void)GPSAuthentication:(NSString *)authenticationCode data:(void (^_Nonnull)(id data))data error:(void (^_Nullable)(CommandStatus status))error;

/**
GPS鉴权状态查询
*/
+(BOOL)getGPSAuthenticationStatus;

/**
 查询GPS工作模式，激活，网络，定位等能力

 @param data 返回数据
 @param error 返回错误码
 */
+(void)QueryGPSActivationStatus:(GPSOperationMode)mode  data:(void (^_Nonnull)(id data))data error:(void (^_Nullable)(CommandStatus status))error;


/**
 设置GPS工作方法

 @param data 返回数据
 @param error 返回错误码
 */
+(void)SetGPSWorkingMode:(GPSWorkingMode)mode data:(void (^_Nonnull)(id data))data error:(void (^_Nullable)(CommandStatus status))error;

/// GPS激活方法
/// @param behavior 行为码
/// @param data 返回数据
/// @param error 返回错误码
+(void)sendSingleGPSActivationCommend:(SwitchStatus)behavior data:(void (^_Nonnull)(id data))data error:(void (^_Nullable)(CommandStatus status))error;

/**
GPS的定位卫星数据获取
@param data 返回数据
@param error 返回错误码
*/
+(void)getSatelliteDataCommend:(void (^_Nonnull)(id data))data error:(void (^_Nullable)(CommandStatus status))error;

/**
GPS设备GSM信号强度获取
@param data 返回数据
@param error 返回错误码
*/
+(void)getGPSGSMSignalValue:(void (^_Nonnull)(id data))data error:(void (^_Nullable)(CommandStatus status))error;

/**
gps设备重启
@param data 返回数据
@param error 返回错误码
*/
+(void)setGPSReset:(void (^_Nullable)(CommandStatus status))error;

/**
 进入固件升级模式

 @param data 返回数据
 */
+(void)enterFirmwareUpgrade:(void (^_Nonnull)(id data))data error:(void (^_Nullable)(CommandStatus status))error;

/**
 查询钥匙版本号

 @param data 返回数据
 */
+(void)querykeyVersionNumber:(void (^_Nonnull)(NSString *data))data error:(void (^_Nullable)(CommandStatus status))error;

/**
 断开蓝牙连接

 @param peripheral 指定设备
 */
+(void)removePeripheral:(CBPeripheral *__nullable)peripheral;//如果参数为空，断开所有连接，有参数，断开指定连接

/**
 获取车辆上锁、解锁、骑行、静音等状态

 @param time 查询次数
 @param data 返回车辆信息当前数据
 */
+(void)getBikeBasicStatues:(TimeNum)time data:(void (^_Nonnull)(BikeStatusModel *model))data;

/**
 设置车辆状态

 @param commandType 车辆设置指令类型
 @param error 指令发送状态监听
 结果从getBikeBasicStatues中获取信息
 */
+(void)setBikeBasicStatues:(NomalCommand)commandType error:(void (^_Nullable)(CommandStatus status))error;

/**
 添加普通钥匙

 @param seq 钥匙配置编号
 @param hardwareNum 硬件版本号
 @param step 配置进程监听
 @param error 指令发送状态监听
 */
+(void)addNomalKeyConfiguration:(NSInteger)seq hardwareNum:(NSInteger)hardwareNum step:(void (^_Nonnull)(ConfigurationSteps step))step error:(void (^_Nullable)(CommandStatus status))error;

/**
 删除普通钥匙

 @param seq 钥匙配置编号
 @param error 指令发送状态监听
 */
+(void)deleteNomalKeyConfiguration:(NSInteger)seq error:(void (^_Nullable)(CommandStatus status))error;


/**
 退出普通钥匙配置模式

 @param error 命令发送状态
 */
+(void)quiteNomalKeyConfiguration:(void (^ _Nullable)(CommandStatus status))error;


/**
 读取车辆信息

 @param error 命令发送状态
 */
+(void)readingVehicleInformation:(void (^)(id data))data error:(void (^ _Nullable)(CommandStatus status))error;

/**
 添加感应钥匙

 @param seq 钥匙配置编号
 @param Mac 配件的Mac地址
 @param error 指令发送状态监听
 */
+(void)addInductionKey:(NSInteger)seq mac:(NSString *)Mac data:(void (^)(id data))data error:(void (^_Nullable)(CommandStatus status))error;


/**
 删除感应钥匙

 @param seq 钥匙配置编号
 @param Mac 配件的Mac地址
 @param error 指令发送状态监听
 */
+(void)deleteInductionKey:(NSInteger)seq mac:(NSString *)Mac data:(void (^)(id data))data error:(void (^_Nullable)(CommandStatus status))error;


/**
 添加蓝牙钥匙

 @param seq 钥匙配置编号
 @param error 指令发送状态监听
 */
+(void)addBLEKey:(NSInteger)seq data:(void (^_Nonnull)(id data))data error:(void (^_Nullable)(CommandStatus status))error;

/**
 删除蓝牙钥匙

 @param seq 钥匙配置编号
 @param error 指令发送状态监听
 */
+(void)deleteBLEKey:(NSInteger)seq data:(void (^_Nonnull)(id data))data error:(void (^_Nullable)(CommandStatus status))error;


/// 退出蓝牙钥匙配置
/// @param seq   钥匙配置编号 0-1
/// @param data 返回数据
/// @param error 指令发送状态监听
+(void)quiteBLEKeyConfiguration:(NSInteger)seq data:(void (^_Nonnull)(id data))data error:(void (^_Nullable)(CommandStatus status))error;

/**
 添加胎压外设

 @param seq 编号
 @param Mac MAC地址
 @param data 设备返回数据
 @param error 命令发送状态
 */
+(void)addTirePressure:(NSInteger)seq mac:(NSString *)Mac data:(void (^_Nonnull)(id data))data error:(void (^_Nullable)(CommandStatus status))error;

/**
 删除胎压设备

 @param seq 编号
 @param Mac MAC地址
 @param data 设备返回数据
 @param error 命令发送状态
 */
+(void)deleteTirePressure:(NSInteger)seq mac:(NSString *)Mac data:(void (^_Nonnull)(id data))data error:(void (^_Nullable)(CommandStatus status))error;

/**
 添加指纹

 @param num 指纹编号
 @param error 指令发送状态监听
 */
+(void)addFingerPrint:(NSInteger)num fingerPrintType:(NSInteger)fingerPrintType status:(void (^_Nullable)(FingerPrintStatus status))status error:(void (^_Nullable)(CommandStatus status))error; //num（0-10）为指纹的配置次序，

/**
 删除指纹

 @param num 指纹编号
 @param error 指令发送状态监听
 */
+(void)deleteFingerPrint:(NSInteger)num data:(void (^_Nonnull)(id data))data error:(void (^_Nullable)(CommandStatus status))error; // num为0则为清空所有指纹


/**
 退出指纹配置
 @param fingerPrintType 指纹编号
 @param error 指令发送状态监听
 */
+(void)quiteFingerPrint:(NSInteger)num fingerPrintType:(NSInteger)fingerPrintType error:(void (^ _Nullable)(CommandStatus status))error;

/**
 获取设备的超速报警状态

 @param data 返回数据
 */
+(void)getDeviceSpeedingAlarmStatus:(void (^_Nonnull)(BOOL speedingAlarm))data;

/**
 设置设备的超速报警状态

 @param status 状态类型
 @param error 指令发送状态监听
 */
+(void)setDeviceSpeedingAlarmStatus:(SwitchStatus)status error:(void (^_Nullable)(CommandStatus status))error;

/**
 获取设备自动锁车状态

 @param error 指令发送状态监听
 */
+(void)getDeviceAutomaticLockStatus:(void (^_Nonnull)(BOOL automaticLock))status error:(void (^_Nullable)(CommandStatus status))error;

/**
 设置设备自动锁车状态

 @param status 状态类型
 @param error 指令发送状态监听
 */
+(void)setDeviceAutomaticLockStatus:(SwitchStatus)status data:(void (^_Nonnull)(BOOL automaticLock))status error:(void (^_Nullable)(CommandStatus status))error;

/**
 获取设备感应距离

 @param error 指令发送状态监听
 */
+(void)getDeviceSensingDistanceValue:(void (^_Nonnull)(NSInteger value))data error:(void (^_Nullable)(CommandStatus status))error;

/**
 设置设备的感应距离

 @param value 感应值
 @param error 指令发送状态监听
 */
+(void)setDeviceSensingDistanceValue:(NSInteger)value data:(void (^_Nonnull)(NSInteger value))data error:(void (^_Nullable)(CommandStatus status))error;

/**
 获取震动灵敏度数据

 @param data 返回数据
 */
+(void)getDeviceShockStatus:(void (^)(ShockState))data;

/**
 设置设备震动灵敏度

 @param status 灵敏度状态
 @param error 指令发送状态监听
 */
+(void)setDeviceShockStatus:(ShockState)status error:(void (^_Nullable)(CommandStatus status))error;

/**
 车辆密码配置

 @param passwordDic 密码组
 @param data 返回的数据
 @param error 命令发送状态
 */
+(void)bikePasswordConfiguration:(NSDictionary *)passwordDic data:(void (^)(id data))data error:(void (^_Nullable)(CommandStatus status))error;

/**
 获取设备的支持

 @param data 返回数据
 @param error 命令发送状态
 */
+(void)getDeviceSupportdata:(void (^_Nonnull)(DeviceConfigurationModel *model))data error:(void (^_Nullable)(CommandStatus status))error;


/**
 获取设备的固件版本

 @param firmwareStr 固件版本信息
 @param error 指令发送状态
 */
+(void)getDeviceFirmwareRevisionString:(void (^ _Nonnull)(NSString *revision))firmwareStr error:(void (^_Nullable)(CommandStatus code))error;


/**
 获取设备的t硬件版本号

 @param hardwareStr 设备硬件版本号
 @param error 指令发送状态
 */
+(void)getDeviceHardwareRevisionString:(void (^ _Nonnull)(NSString *revision))hardwareStr error:(void (^_Nullable)(CommandStatus code))error;


@end

NS_ASSUME_NONNULL_END
