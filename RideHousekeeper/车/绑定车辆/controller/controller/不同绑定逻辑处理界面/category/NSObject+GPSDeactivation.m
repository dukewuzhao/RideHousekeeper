//
//  NSObject+GPSDeactivation.m
//  RideHousekeeper
//
//  Created by 晶 on 2020/3/29.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import "NSObject+GPSDeactivation.h"
#import "SearchBleModel.h"
@implementation NSObject (GPSDeactivation)

-(void)GPSDeactivation:(NSString *)ECUMac :(void (^)(id))operatingStatus{
    @weakify(self);
    if (![CommandDistributionServices isConnect]) {
        
        if (![QFTools isBlankString:[USER_DEFAULTS stringForKey:Key_DeviceUUID]]) {
            [CommandDistributionServices connectPeripheralByUUIDString:[USER_DEFAULTS stringForKey:Key_DeviceUUID]];
        }else{
            
            [CommandDistributionServices startScan:DeviceNomalType PeripheralList:^(NSMutableArray * arry) {
                for (SearchBleModel *model in arry) {
                    if ([model.mac.uppercaseString isEqualToString:ECUMac.uppercaseString]) {
                        [CommandDistributionServices connectPeripheral:model.peripher];
                        [CommandDistributionServices stopScan];
                    }
                }
            }];
        }
        
        RACSignal * deallocSignal = [self rac_signalForSelector:@selector(connectNextStep:)];
        [[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:KNotification_ConnectStatus object:nil] takeUntil:deallocSignal] timeout:10 onScheduler:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
            @strongify(self);
            NSNotification *userInfo = x;
            if (![userInfo.object boolValue]) {
                [self connectNextStep:operatingStatus];
            }
        }error:^(NSError *error) {
            [CommandDistributionServices stopScan];
            if (operatingStatus) {
                operatingStatus(@2);
            }
        }];
        
        
    }else{
        [self connectNextStep:operatingStatus];
    }
    
}

-(void)connectNextStep:(void (^)(id))operatingStatus{
    [CommandDistributionServices QueryGPSActivationStatus:QueryGPSActivateMode data:^(id _Nonnull data) {
        if ([data[@"status"] intValue] == 0 && [data[@"data"] intValue] == 1) {
            
            [CommandDistributionServices sendSingleGPSActivationCommend:Close data:^(id _Nonnull queryData) {
                NSLog(@"GPS已激活");
                if ([queryData intValue] == 0) {
                    NSLog(@"GPS关闭激活成功");
                    if (operatingStatus) {
                        operatingStatus(@0);
                    }
                }else{
                    NSLog(@"GPS关闭激活失败");
                    if (operatingStatus) {
                        operatingStatus(@1);
                    }
                }
                
            } error:^(CommandStatus status) {
                switch (status) {
                    case SendSuccess:
                        NSLog(@"GPS关闭激活发送成功");
                        break;
                        
                    default:
                        NSLog(@"GPS关闭激活发送失败");
                        if (operatingStatus) {
                            operatingStatus(@1);
                        }
                        break;
                }
            }];
        }else{
            NSLog(@"GPS未激活");
            if (operatingStatus) {
                operatingStatus(@1);
            }
        }
    } error:^(CommandStatus status) {
        switch (status) {
            case SendSuccess:
                NSLog(@"查询GPS发送成功");
                break;
                
            default:
                if (operatingStatus) {
                    operatingStatus(@1);
                }
                break;
        }
    }];
}

-(void)accessoryGPSDeactivation :(NSString *)ECUMac :(void (^)(id))operatingStatus{
    
    @weakify(self);
    if (![CommandDistributionServices isConnect]) {
        
        if (![QFTools isBlankString:[USER_DEFAULTS stringForKey:Key_DeviceUUID]]) {
            [CommandDistributionServices connectPeripheralByUUIDString:[USER_DEFAULTS stringForKey:Key_DeviceUUID]];
        }else{
            
            [CommandDistributionServices startScan:DeviceNomalType PeripheralList:^(NSMutableArray * arry) {
                for (SearchBleModel *model in arry) {
                    if ([model.mac.uppercaseString isEqualToString:ECUMac.uppercaseString]) {
                        [CommandDistributionServices connectPeripheral:model.peripher];
                        [CommandDistributionServices stopScan];
                    }
                }
            }];
        }
        
        RACSignal * deallocSignal = [self rac_signalForSelector:@selector(connectAccessoriesNextStep:)];
        [[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:KNotification_ConnectStatus object:nil] takeUntil:deallocSignal] timeout:10 onScheduler:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
            @strongify(self);
            NSNotification *userInfo = x;
            if (![userInfo.object boolValue]) {
                [self connectAccessoriesNextStep:operatingStatus];
            }
        }error:^(NSError *error) {
            [CommandDistributionServices stopScan];
            if (operatingStatus) {
                operatingStatus(@2);
            }
        }];
        
        
    }else{
        [self connectAccessoriesNextStep:operatingStatus];
    }
    
}

-(void)connectAccessoriesNextStep:(void (^)(id))operatingStatus{
    [CommandDistributionServices QueryGPSActivationStatus:QueryGPSActivateMode data:^(id _Nonnull data) {
        if ([data[@"status"] intValue] == 0 && [data[@"data"] intValue] == 1) {
            
            [CommandDistributionServices sendSingleGPSActivationCommend:Close data:^(id _Nonnull queryData) {
                NSLog(@"GPS已激活");
                if ([queryData intValue] == 0) {
                    NSLog(@"GPS关闭激活成功");
                    if (operatingStatus) {
                        operatingStatus(@0);
                    }
                }else{
                    NSLog(@"GPS关闭激活失败");
                    if (operatingStatus) {
                        operatingStatus(@1);
                    }
                }

            } error:^(CommandStatus status) {
                switch (status) {
                    case SendSuccess:
                        NSLog(@"GPS关闭激活发送成功");
                        break;

                    default:
                        NSLog(@"GPS关闭激活发送失败");
                        if (operatingStatus) {
                            operatingStatus(@1);
                        }
                        break;
                }
            }];
        }else{
            NSLog(@"GPS未激活");
            if (operatingStatus) {
                operatingStatus(@1);
            }
        }
    } error:^(CommandStatus status) {
        switch (status) {
            case SendSuccess:
                NSLog(@"查询GPS发送成功");
                break;

            default:
                if (operatingStatus) {
                    operatingStatus(@1);
                }
                break;
        }
    }];
}

-(void)SingleGPSDeactivation :(NSString *)GPSMac :(void (^)(id))operatingStatus{
    @weakify(self);
    if (![CommandDistributionServices isConnect]) {
        
        [CommandDistributionServices startScan:DeviceGPSType PeripheralList:^(NSMutableArray * arry) {
            for (SearchBleModel *model in arry) {
                if ([model.mac.uppercaseString isEqualToString:GPSMac.uppercaseString]) {
                    [CommandDistributionServices connectPeripheral:model.peripher];
                    [CommandDistributionServices stopScan];
                }
            }
        }];
        
        RACSignal * deallocSignal = [self rac_signalForSelector:@selector(connectSingleGPSNextStep:)];
        [[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:KNotification_ConnectStatus object:nil] takeUntil:deallocSignal] timeout:10 onScheduler:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
            @strongify(self);
            NSNotification *userInfo = x;
            if (![userInfo.object boolValue]) {
                [self connectSingleGPSNextStep:operatingStatus];
            }
        }error:^(NSError *error) {
            [CommandDistributionServices stopScan];
            if (operatingStatus) {
                operatingStatus(@1);
            }
        }];
        
        
    }else{
        [self connectSingleGPSNextStep:operatingStatus];
    }
}

-(void)connectSingleGPSNextStep:(void (^)(id))operatingStatus{
    [CommandDistributionServices QueryGPSActivationStatus:QueryGPSActivateMode data:^(id _Nonnull data) {
        if ([data[@"status"] intValue] == 0 && [data[@"data"] intValue] == 1) {
            
            [CommandDistributionServices sendSingleGPSActivationCommend:Close data:^(id _Nonnull queryData) {
                NSLog(@"GPS已激活");
                if ([queryData intValue] == 0) {
                    NSLog(@"GPS关闭激活成功");
                    if (operatingStatus) {
                        operatingStatus(@0);
                    }
                }else{
                    NSLog(@"GPS关闭激活失败");
                    if (operatingStatus) {
                        operatingStatus(@1);
                    }
                }

            } error:^(CommandStatus status) {
                switch (status) {
                    case SendSuccess:
                        NSLog(@"GPS关闭激活发送成功");
                        break;

                    default:
                        NSLog(@"GPS关闭激活发送失败");
                        if (operatingStatus) {
                            operatingStatus(@1);
                        }
                        break;
                }
            }];
        }else{
            NSLog(@"GPS未激活");
            if (operatingStatus) {
                operatingStatus(@2);
            }
        }
    } error:^(CommandStatus status) {
        switch (status) {
            case SendSuccess:
                NSLog(@"查询GPS发送成功");
                break;

            default:
                if (operatingStatus) {
                    operatingStatus(@1);
                }
                break;
        }
    }];
}

@end
