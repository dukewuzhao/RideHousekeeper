//
//  AppDelegate+WYDeviceServices.m
//  RideHousekeeper
//
//  Created by Apple on 2019/9/25.
//  Copyright © 2019 Duke Wu. All rights reserved.
//

#import "AppDelegate+WYDeviceServices.h"

@implementation AppDelegate (WYDeviceServices)

-(void)monitorConnectStatus{
    //@weakify(self);
    [CommandDistributionServices monitorConnectStatus:^(DeviceConnectStatus status) {
        //@strongify(self);
        if (status == DeviceDisconnect) {
            
            if ([[APPStatusManager sharedManager] getBikeBindingStstus]) {
                [NSNOTIC_CENTER postNotificationName:KNotification_UpdateDeviceStatus object:@YES];
            }else{
                [NSNOTIC_CENTER postNotificationName:KNotification_ConnectStatus object:@YES];
            }
            
        }else{
            if ([[APPStatusManager sharedManager] getBikeBindingStstus]) {
                [NSNOTIC_CENTER postNotificationName:KNotification_UpdateDeviceStatus object:@NO];
            }else{
                [NSNOTIC_CENTER postNotificationName:KNotification_ConnectStatus object:@NO];
            }
        }
    }];
}

-(void)monitorBikeStatusModelCallback{
    
    [CommandDistributionServices getBikeBasicStatues:100 data:^(BikeStatusModel *model){
        
        [NSNOTIC_CENTER postNotificationName:KNotification_QueryData object:model];
        
    }];
}

-(void)monitorBLEStatus{
    
    [CommandDistributionServices monitorBLEStatus:^(BLEStatus status) {
        switch (status) {
            case StateUnknown:
                NSLog(@"手机蓝牙状态位置");
                [self mbluetoohPowerOff];
                break;
            case StateResetting:
                NSLog(@"手机蓝牙重启中");
                [[APPStatusManager sharedManager] setBLEStstus:NO];
                [NSNOTIC_CENTER postNotificationName:KNotification_BluetoothPowerOff object:nil];
                //CBCentralManger代表方法在iOS 11和以下iOS 11中的行为有所不同
                if (@available(iOS 11, *)){
                    //手动调用断开连接
                    [CommandDistributionServices removePeripheral:nil];
                    [NSNOTIC_CENTER postNotificationName:KNotification_ConnectStatus object:@YES];
                }
                [CommandDistributionServices removePeripheral:nil];
                break;
            case StateUnsupported:
                NSLog(@"手机蓝牙不支持ble");
                [self mbluetoohPowerOff];
                break;
            case StateUnauthorized:
                NSLog(@"手机蓝牙未授权");
                [self mbluetoohPowerOff];
                break;
            case StatePoweredOff:
                NSLog(@"手机蓝牙关闭");
                [self mbluetoohPowerOff];
                break;
            case StatePoweredOn:
                NSLog(@"手机蓝牙开启");
                [self mbluetoohPowerOn];
                break;
            default:
                break;
        }
    }];
}



@end
