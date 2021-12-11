//
//  AnnotatedHeader.h
//  RideHousekeeper
//
//  Created by Apple on 2017/11/29.
//  Copyright © 2017年 Duke Wu. All rights reserved.
//

#ifndef AnnotatedHeader_h
#define AnnotatedHeader_h

//蓝牙通知
#define NSNOTIC_CENTER  [NSNotificationCenter defaultCenter]//通知

#define KNOTIFICATION_LOGINCHANGE @"loginStateChange"

#define KNOTIFICATION_UPDATEORDERLIST @"updateOrderList"

#define KNotification_BluetoothPowerOn @"KNotification_BluetoothPowerOn"//蓝牙开关开启

#define KNotification_BluetoothPowerOff @"KNotification_BluetoothPowerOff"//蓝牙开关关闭

#define KNotification_UpdateDeviceStatus @"KNotification_UpdateDeviceStatus"//蓝牙连接断开与连上

#define KNotification_ConnectStatus @"KNotification_ConnectStatus"

#define KNotification_QueryData @"KNotification_QueryData"

#define KNotification_FirmwareUpgradeCompleted @"KNotification_FirmwareUpgradeCompleted"//固件升级完成通知

typedef enum : NSUInteger {

    BindingBike = 0,//绑定车辆
    BindingChangeECU,//更换ECU
    BindingChangeECUFail,//更换ECU失败
    BindingChangeGPS,//更换GPS
    BindingChangeGPSFail//更换GPS失败
} BindingType;

#define USER_DEFAULTS [NSUserDefaults standardUserDefaults]
#define Key_DeviceUUID @"com.comtime.smartbike.DeviceUUID"
#define Key_BikeId @"com.comtime.smartbike.bikeid"
#endif /* AnnotatedHeader_h */
