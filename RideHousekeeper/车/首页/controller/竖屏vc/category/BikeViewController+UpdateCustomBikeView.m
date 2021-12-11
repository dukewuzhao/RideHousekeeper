//
//  BikeViewController+UpdateCustomBikeView.m
//  RideHousekeeper
//
//  Created by Apple on 2019/11/26.
//  Copyright © 2019 Duke Wu. All rights reserved.
//

#import "BikeViewController+UpdateCustomBikeView.h"
#import "BikeStatusModel.h"
#import "CustomBike.h"
@implementation BikeViewController (UpdateCustomBikeView)

-(void)updateCustomView:(CustomBike *)custombike :(BikeStatusModel *)model{
    
    if (custombike.havePressureMonitoring && custombike.tpm_func == 1) {
        
        if (custombike.wheels == 0) {
            
            if (((model.firstTireValue >=160 && model.firstTireValue <=260 )&&
                (model.secondTireValue >=160 && model.secondTireValue <=260 ))||
                model.firstTireValue==0 || model.secondTireValue==0){
                
                custombike.bikeHeadView.carCondition.displayLab.text = @"车况";
                custombike.bikeHeadView.carCondition.displayLab.textColor = [UIColor blackColor];
                custombike.bikeHeadView.carCondition.caveatView.hidden = YES;
                custombike.bikeHeadView.carCondition.displayImg.hidden = NO;
                
            }else if ((model.firstTireValue <160 && model.firstTireValue>0) || model.firstTireValue >260 ||
                      (model.secondTireValue <160 && model.secondTireValue>0) || model.secondTireValue >260){
                
                custombike.bikeHeadView.carCondition.displayLab.text = @"胎压异常";
                custombike.bikeHeadView.carCondition.displayLab.textColor = [UIColor redColor];
                custombike.bikeHeadView.carCondition.caveatView.hidden = NO;
                custombike.bikeHeadView.carCondition.displayImg.hidden = YES;
            }else if(model.firstTireValue == -6 || model.secondTireValue == -6){
                custombike.bikeHeadView.carCondition.displayLab.text = @"胎压异常";
                custombike.bikeHeadView.carCondition.displayLab.textColor = [UIColor redColor];
                custombike.bikeHeadView.carCondition.caveatView.hidden = NO;
                custombike.bikeHeadView.carCondition.displayImg.hidden = YES;
            }
            
        }else if (custombike.wheels == 1){
            
            if (((model.firstTireValue >=160 && model.firstTireValue <=260 )&&
                (model.secondTireValue >=160 && model.secondTireValue <=260) &&
                (model.thirdTireValue >=160 && model.thirdTireValue <=260 ))||
                model.firstTireValue==0 || model.secondTireValue==0 || model.thirdTireValue ==0){
                
                custombike.bikeHeadView.carCondition.displayLab.text = @"车况";
                custombike.bikeHeadView.carCondition.displayLab.textColor = [UIColor blackColor];
                custombike.bikeHeadView.carCondition.caveatView.hidden = YES;
                custombike.bikeHeadView.carCondition.displayImg.hidden = NO;
                
            }else if ((model.firstTireValue <160 && model.firstTireValue>0) || model.firstTireValue >260 ||
                      (model.secondTireValue <160 && model.secondTireValue>0) || model.secondTireValue >260 ||
                      (model.thirdTireValue <160 && model.thirdTireValue>0) || model.thirdTireValue >260){
                
                custombike.bikeHeadView.carCondition.displayLab.text = @"胎压异常";
                custombike.bikeHeadView.carCondition.displayLab.textColor = [UIColor redColor];
                custombike.bikeHeadView.carCondition.caveatView.hidden = NO;
                custombike.bikeHeadView.carCondition.displayImg.hidden = YES;
            }else if(model.firstTireValue == -6 || model.secondTireValue == -6 ||model.thirdTireValue == -6){
                custombike.bikeHeadView.carCondition.displayLab.text = @"胎压异常";
                custombike.bikeHeadView.carCondition.displayLab.textColor = [UIColor redColor];
                custombike.bikeHeadView.carCondition.caveatView.hidden = NO;
                custombike.bikeHeadView.carCondition.displayImg.hidden = YES;
            }
            
        }else if (custombike.wheels == 2){
            
            if (((model.firstTireValue >=160 && model.firstTireValue <=260 )&&
                (model.secondTireValue >=160 && model.secondTireValue <=260 ) &&
                (model.thirdTireValue >=160 && model.thirdTireValue <=260 ) &&
                (model.fourthTireValue >=160 && model.fourthTireValue <=260))||
                model.firstTireValue==0 || model.secondTireValue==0 || model.thirdTireValue ==0 || model.fourthTireValue ==0){
                
                custombike.bikeHeadView.carCondition.displayLab.text = @"车况";
                custombike.bikeHeadView.carCondition.displayLab.textColor = [UIColor blackColor];
                custombike.bikeHeadView.carCondition.caveatView.hidden = YES;
                custombike.bikeHeadView.carCondition.displayImg.hidden = NO;
                
            }else if ((model.firstTireValue <160 && model.firstTireValue>0) || model.firstTireValue >260 ||
                      (model.secondTireValue <160 && model.secondTireValue>0) || model.secondTireValue >260  ||
                      (model.thirdTireValue <160 && model.thirdTireValue>0) || model.thirdTireValue >260 ||
                      (model.fourthTireValue <160 && model.fourthTireValue>0) || model.fourthTireValue >260){
                
                custombike.bikeHeadView.carCondition.displayLab.text = @"胎压异常";
                custombike.bikeHeadView.carCondition.displayLab.textColor = [UIColor redColor];
                custombike.bikeHeadView.carCondition.caveatView.hidden = NO;
                custombike.bikeHeadView.carCondition.displayImg.hidden = YES;
            }else if(model.firstTireValue == -6 || model.secondTireValue == -6 ||model.thirdTireValue == -6||model.fourthTireValue == -6){
                custombike.bikeHeadView.carCondition.displayLab.text = @"胎压异常";
                custombike.bikeHeadView.carCondition.displayLab.textColor = [UIColor redColor];
                custombike.bikeHeadView.carCondition.caveatView.hidden = NO;
                custombike.bikeHeadView.carCondition.displayImg.hidden = YES;
            }
        }
        
    }else{
        custombike.bikeHeadView.carCondition.displayLab.text = @"车况";
        custombike.bikeHeadView.carCondition.displayLab.textColor = [UIColor blackColor];
        custombike.bikeHeadView.carCondition.caveatView.hidden = YES;
        custombike.bikeHeadView.carCondition.displayImg.hidden = NO;
    }
    
    if (model.isElectricDoorOpen) {
        
        custombike.bikeHeadView.vehicleReportView.BikeStatusImg.image = [UIImage imageNamed:@"bike_riding"];
        custombike.bikeHeadView.vehicleReportView.BikeStatusLab.text = @"骑行中";
        
    }else if (model.isLock){
        
        custombike.bikeHeadView.vehicleReportView.BikeStatusImg.image = [UIImage imageNamed:@"bike_lock"];
        custombike.bikeHeadView.vehicleReportView.BikeStatusLab.text = @"已上锁";
    }else if (!model.isLock){
        
        custombike.bikeHeadView.vehicleReportView.BikeStatusImg.image = [UIImage imageNamed:@"bike_unlock"];
        custombike.bikeHeadView.vehicleReportView.BikeStatusLab.text = @"已解锁";
    }
    
    if (custombike.viewType == 2 && model.gpsConnection) {
        
        if (!custombike.bikeHeadView.vehicleReportView.CentralWithGPScConnection.hidden) {
            
            [UIView animateWithDuration:0.3 animations:^{
                custombike.bikeHeadView.vehicleReportView.CentralWithGPScConnection.alpha = 0;
            } completion:^(BOOL finished) {
                custombike.bikeHeadView.vehicleReportView.CentralWithGPScConnection.hidden = YES;
            }];
            
        }
        
    }else if (custombike.viewType == 2 && !model.gpsConnection){
        
        if (custombike.bikeHeadView.vehicleReportView.CentralWithGPScConnection.hidden) {
            [UIView animateWithDuration:0.3 animations:^{
                custombike.bikeHeadView.vehicleReportView.CentralWithGPScConnection.alpha = 1;
            } completion:^(BOOL finished) {
                custombike.bikeHeadView.vehicleReportView.CentralWithGPScConnection.hidden = NO;
            }];
        }
    }
    
    if ([[custombike valueForKeyPath:@"isClickBtn"] integerValue] == 0) {
        return;
    }
    switch ([[custombike valueForKeyPath:@"commandType"] integerValue]) {
        case DeviceOutSafe:
                
                if (!model.isLock) {
                    [custombike restAnimationView];
                }
            break;
        case DeviceSetSafe:
                if (model.isLock) {
                    [custombike restAnimationView];
                }
            break;
        case DeviceOpenEleDoor:
                if (model.isElectricDoorOpen) {
                    [custombike restAnimationView];
                }
            break;
        default:
            break;
    }
}


//ble连接状态
-(void)BLEConnectlogicalAllocation:(CustomBike *)bikeView :(UIAlertView *)customAlertView :(BOOL)status{
    
    @weakify(self);
    if (status) {
        [bikeView viewReset];
        if (customAlertView) {
            [customAlertView dismissWithClickedButtonIndex:0 animated:YES];
            customAlertView = nil;
        }
        if (bikeView.viewType == 3) {
            [CommandDistributionServices removePeripheral:nil];
        }else{
            bikeView.bikeHeadView.carCondition.BLEConnectStatusPointView.backgroundColor = [QFTools colorWithHexString:@"#999999"];
        }
        
    }else{
        
        if (bikeView.viewType != 3){
            
            BikeModel *model =  [[LVFmdbTool queryBikeData:[NSString stringWithFormat:@"SELECT * FROM bike_modals WHERE bikeid LIKE '%d'", bikeView.bikeid]] firstObject];
            NSString *passWord = @"";
            if (model.ownerflag == 1) {
                passWord = [QFTools toHexString:[model.mainpass longLongValue]];
            }else if (model.ownerflag == 0){
                passWord = [QFTools toHexString:[model.password longLongValue]];
            }
            
            [CommandDistributionServices sendPasswordCommend:passWord data:^(id data) {
                @strongify(self);
                if ([data intValue] == ConfigurationFail) {
                    
                    [SVProgressHUD showSimpleText:@"连接失效，请重新绑定"];
                    [CommandDistributionServices removePeripheral:nil];
                    bikeView.bikeHeadView.vehicleReportView.BikeStatusImg.image = [UIImage imageNamed:@"bike_BLE_braekconnect"];
                }else{
                    
                    [CommandDistributionServices getDeviceFirmwareRevisionString:^(NSString * _Nonnull revision) {
                        @strongify(self);
//                        if (bikeView.viewType == 2) {
//                            PeripheralModel *model = [[LVFmdbTool queryPeripheraData:
//                            [NSString stringWithFormat:@"SELECT * FROM periphera_modals WHERE type = '%d' AND bikeid = '%zd'",4,bikeView.bikeid]] firstObject];
//                            [self connectGPSByMac:bikeView Mac: model.mac];
//                        }
                        bikeView.bikeHeadView.carCondition.BLEConnectStatusPointView.backgroundColor = [QFTools colorWithHexString:@"#0A84FF"];
                        [self editionData:revision];
                        [self queryBikeStatusOnce:bikeView.bikeid];
                        
                        if ([bikeView valueForKeyPath:@"alert"]) {
                            
                            [UIView animateWithDuration:0.3 animations:^{
                                [[bikeView valueForKeyPath:@"alert"] removeFromSuperview];
                            } completion:^(BOOL finished) {
                                [bikeView setValue:nil forKeyPath:@"alert"];
                                [bikeView restAnimationView];
                            }];
                        }
                        
                    } error:^(CommandStatus status) {
                        switch (status) {
                            case SendSuccess:
                                NSLog(@"固件信息获取发送成功");
                                break;

                            default:
                                NSLog(@"固件信息获取发送失败");
                                break;
                        }
                    }];
                }
            }error:^(CommandStatus status) {
                switch (status) {
                    case SendSuccess:
                        NSLog(@"密码发送成功");
                        break;
                        
                    default:
                        break;
                }
            }];
            
        }
    }
}

//-(void)CommunicateWithGPS:(GPSWorkingMode)mode :(CustomBike *)bikeView{
//
//    PeripheralModel *model = [[LVFmdbTool queryPeripheraData:[NSString stringWithFormat:@"SELECT * FROM periphera_modals WHERE type = '%d' AND bikeid = '%zd'",4,bikeView.bikeid]] firstObject];
//    [CommandDistributionServices GPSAuthentication:[NSString stringWithFormat:@"0%d01%@%@%@",mode,[QFTools completionStr:[ConverUtil ToHex:[QFTools getdata:@"userid"].intValue] needLength:8],[QFTools completionStr:[ConverUtil ToHex:model.ts] needLength:8],model.sign] data:^(id _Nonnull data) {
//
//            if ([data intValue] == 0) {
//
//                [CommandDistributionServices QueryGPSActivationStatus:QueryGPSActivateMode data:^(id _Nonnull data) {
//                    if ([data[@"status"] intValue] == 0 && [data[@"data"] intValue] == 1) {
//                        NSLog(@"GPS已经激活");
//                    }else{
//
//                        [CommandDistributionServices SetGPSWorkingMode:mode data:^(NSString * _Nonnull data) {
//
//                            if ([data intValue] == 0) {
//                                NSLog(@"GPS设置工作模式");
//
//                                [CommandDistributionServices sendSingleGPSActivationCommend:Open data:^(id _Nonnull queryData) {
//
//                                    if ([queryData intValue] == 0) {
//                                        NSLog(@"GPS激活成功");
//                                    }else{
//                                        NSLog(@"GPS激活失败");
//                                    }
//
//                                } error:^(CommandStatus status) {
//                                    switch (status) {
//                                        case SendSuccess:
//                                            NSLog(@"激活GPS发送成功");
//                                            break;
//
//                                        default:
//                                            break;
//                                    }
//                                }];
//
//                            }else{
//                                NSLog(@"GPS设置工作模式失败");
//                            }
//
//                        } error:^(CommandStatus status) {
//                            switch (status) {
//                                case SendSuccess:
//                                    NSLog(@"查询GPS发送成功");
//                                    break;
//
//                                default:
//
//                                    break;
//                            }
//                        }];
//                    }
//                } error:^(CommandStatus status) {
//                    switch (status) {
//                        case SendSuccess:
//                            NSLog(@"查询GPS发送成功");
//                            break;
//
//                        default:
//
//                            break;
//                    }
//                }];
//
//            }else{
//                NSLog(@"GPS鉴权失败");
//            }
//
//        } error:^(CommandStatus status) {
//            switch (status) {
//                case SendSuccess:
//                    NSLog(@"鉴权GPS发送成功");
//                    break;
//
//                default:
//                    break;
//            }
//        }];
//}
//
//
//-(void)connectGPSByMac:(CustomBike *)bikeView Mac:(NSString *)mac{
//
//    [CommandDistributionServices connectGPSByMac:mac data:^(id _Nonnull data) {
//        switch ([data intValue]) {
//            case DeviceConnect:
//
//                NSLog(@"GPS连接成功");
//                [self CommunicateWithGPS:ECUMode :bikeView];
//                break;
//
//            default:
//                NSLog(@"GPS连接失败");
//                break;
//        }
//
//
//    } error:^(CommandStatus status) {
//        switch (status) {
//            case ConfigurationSuccess:
//                NSLog(@"GPS连接发送成功");
//                break;
//
//            default:
//                NSLog(@"GPS连接发送失败");
//                break;
//        }
//    }];
//    
//}

-(void)queryBikeStatusOnce:(NSInteger)bikeid{
    @weakify(self);
    [CommandDistributionServices queryVehicleStatusOnce:^(BikeStatusModel *model) {
        @strongify(self);
        if (model.firstTireValue >= 0) {
            [self addDeviceAccessories:1 :bikeid];
        }
        
        if (model.secondTireValue >= 0) {
            [self addDeviceAccessories:2 :bikeid];
        }
        
        if (model.thirdTireValue >= 0) {
            [self addDeviceAccessories:3 :bikeid];
        }
        
        if (model.fourthTireValue >= 0) {
            [self addDeviceAccessories:4 :bikeid];
        }
        
    } error:^(CommandStatus status) {
        switch (status) {
            case SendSuccess:
                NSLog(@"一次性查询发送成功");
                break;
            default:
                NSLog(@"一次性查询发送失败");
                break;
        }
    }];
}


-(void)addDeviceAccessories:(NSInteger)seq :(NSInteger)bikeid{
    
    NSMutableArray *pressureModals = [LVFmdbTool queryPeripheraData:[NSString stringWithFormat:@"SELECT * FROM periphera_modals WHERE type = '%d' AND seq = '%zd' AND bikeid = '%zd'",6,seq,bikeid]];
    if (pressureModals.count== 0) {

        PeripheralModel *pmodel = [PeripheralModel modalWith:bikeid deviceid:seq type:6 seq:seq mac:@"00000000" sn:@"300000000000" qr:@"" firmversion:@"00000000" default_brand_id:0 default_model_id:0 prod_date:@"" imei:@"" imsi:@"" sign:@"" desc:@"" ts:0 bind_sn:@"" bind_mac:@"" is_used:1];
        [LVFmdbTool insertDeviceModel:pmodel];
    }
}

@end
