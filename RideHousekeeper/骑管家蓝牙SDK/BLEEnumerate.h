//
//  BLEEnumerate.h
//  myTest
//
//  Created by Apple on 2019/6/21.
//  Copyright © 2019 Apple. All rights reserved.
//

#ifndef BLEEnumerate_h
#define BLEEnumerate_h
#import <Foundation/Foundation.h>

typedef enum : NSUInteger {

    ConfigurationSuccess = 0,//配置成功
    ConfigurationFail,//配置失败
} CallbackStatus;

typedef enum : NSUInteger {
    SendSuccess = 0,  //发送成功
    SendFail,        //发送失败
    SendFrequently,//发送太频繁
    InvalidCommand,//无效指令
    PermissionError,//权限错误
    InvalidData,//无效数据
    UnknownMistake,//未知错误
    NotSupport,//指令不支持
} CommandStatus;

typedef enum : NSUInteger {
    
    StateUnknown,//未知状态
    StateResetting,//蓝牙重启中
    StateUnsupported,//手机不支持蓝牙
    StateUnauthorized,//手机蓝牙未授权使用
    StatePoweredOff, //手机断开关闭
    StatePoweredOn,//手机蓝牙已开启
    
} BLEStatus;


typedef enum : NSUInteger {
    DeviceNomalType,          //普通广播模式
    DeviceBingDingType,       //绑定广播模式
    DeviceDFUType,            //OTA广播模式
    DeviceGPSType,            //GPS广播模式
} DeviceScanType;

typedef enum : NSUInteger {
    DeviceDisconnect,    //设备断开连接
    DeviceConnect,       //设备已连接
} DeviceConnectStatus;

typedef enum : NSUInteger {
    FirstStep,
    SecondStep,
    ThirdStep,
    FourthStep,
    KeyRepeat,          //按键重复，某一个键按了一次以上
    KeyConflict,        //按键冲突,按到了其它的钥匙
    Success,
} ConfigurationSteps;//

typedef enum : NSUInteger {
    PrintFirst,
    PrintSecond,
    PrintThird,
    PrintFourth,
    PrintSuccess,
    PrintTooLong,
    PrintLiftUp,//指纹抬起
    PrintFail,
} FingerPrintStatus;//指纹按压状态



typedef enum : NSUInteger {
    DeviceSetSafe = 01,                     //设防
    DeviceOutSafe,                          //撤防
    DeviceSetSafeNoSound,                   //静音
    DeviceSetSafeSound,                     //非静音
    DeviceOpenSeat,                         //开坐桶
    DeviceFindBike,                         //寻车
    DeviceOpenEleDoor,                      //开电门
    DeviceCloseEleDoor,                     //关电门
    DeviceOpenTirePressureAlarm,            //胎压警报开启
    DeviceCloseTirePressureAlarm,           //胎压警报关闭
    DeviceInductionSetSafe,                 //感应设防
    DeviceInductionOutSafe                         //感应撤防
} NomalCommand;//此行为类型命令属于DeviceNomalSet类

typedef enum : NSUInteger {
    Close = 0,     //关闭模式
    Open,          //打开模式
} SwitchStatus;

typedef enum : NSUInteger {
    PureGPSMode = 0,       //单GPS模式
    ECUMode,          //ECU模式
} GPSWorkingMode;

typedef enum : NSUInteger {
    low,
    middle,
    high
} ShockState;

typedef enum : NSUInteger {
    unlimiteTme= 0,
    oneTme= 1,
    hundure= 100,
    thurand= 1000,
} TimeNum;

/*
 *GPS操作状态读取指令
 */
typedef enum : NSUInteger {
    QueryGPSWorkMode = 0,
    QueryGPSActivateMode = 1,
    QueryGPSPositionMode = 2,
    QueryGPSNetworkStatusMode = 3,
} GPSOperationMode;

#endif /* BLEEnumerate_h */
