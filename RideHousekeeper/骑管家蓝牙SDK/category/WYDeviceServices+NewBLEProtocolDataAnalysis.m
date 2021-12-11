//
//  WYDeviceServices+NewBLEProtocolDataAnalysis.m
//  myTest
//
//  Created by Apple on 2019/8/21.
//  Copyright © 2019 Apple. All rights reserved.
//

#import "WYDeviceServices+NewBLEProtocolDataAnalysis.h"
#import "BikeStatusModel.h"
#import "DeviceConfigurationModel.h"
#import "FaultModel.h"

#define HI_UINT16(a) (((a) >> 8) & 0xff)
#define LO_UINT16(a) ((a) & 0xff)
#define BUILD_UINT16(loByte, hiByte) ((uint16_t)(((loByte) & 0x00FF) + (((hiByte) & 0x00FF) << 8)))

@implementation WYDeviceServices (NewBLEProtocolDataAnalysis)

- (NSInteger)RSPAnalysis:(NSString *)data{
    
    NSString *headStr = [ConverUtil getBinaryByhex:[data substringWithRange:NSMakeRange(2, 2)]];
    if ([[headStr substringWithRange:NSMakeRange(4, 4)] isEqualToString:@"0000"]) {
        return 0;
    }else if([[headStr substringWithRange:NSMakeRange(4, 4)] isEqualToString:@"0001"]){
        return 1;
    }else if([[headStr substringWithRange:NSMakeRange(4, 4)] isEqualToString:@"0010"]){
        return 2;
    }else if([[headStr substringWithRange:NSMakeRange(4, 4)] isEqualToString:@"0011"]){
        return 3;
    }else if([[headStr substringWithRange:NSMakeRange(4, 4)] isEqualToString:@"0100"]){
        return 4;
    }else if([[headStr substringWithRange:NSMakeRange(4, 4)] isEqualToString:@"0101"]){
        return 5;
    }
    return 0;
}

- (BikeStatusModel *)newAnalysisBikestatus:(BikeStatusModel *)model :(NSString *)data{
    
    BikeStatusModel *bikeModel = model;
    NSData *datavalue = [ConverUtil stringToByte:data];
    Byte *byte=(Byte *)[datavalue bytes];
    
    NSString *deviceStatusDescription = [ConverUtil getBinaryByhex:[data substringWithRange:NSMakeRange(12, 2)]];//设备状态说明
    NSString *bikestate = [ConverUtil getBinaryByhex:[data substringWithRange:NSMakeRange(26, 2)]];
    NSString *keystatenumber = [ConverUtil getBinaryByhex:[data substringWithRange:NSMakeRange(16, 2)]];
    
    if (byte[13] == 0) {
        bikeModel.faultModel.motorfault = 0;
        bikeModel.faultModel.rotationfault = 0;
        bikeModel.faultModel.controllerfault = 0;
        bikeModel.faultModel.brakefault = 0;
        bikeModel.faultModel.lackvoltage = 0;
        bikeModel.faultModel.motordefectNum = 0;
        
    }else{
        if([[bikestate substringWithRange:NSMakeRange(7, 1)] isEqualToString:@"1"]){
            //电机故障
            bikeModel.faultModel.motorfault = 1;
        }else if([[bikestate substringWithRange:NSMakeRange(7, 1)] isEqualToString:@"0"]){
            bikeModel.faultModel.motorfault = 0;
        }
        
        if([[bikestate substringWithRange:NSMakeRange(6, 1)] isEqualToString:@"1"]){
            //转把故障
            bikeModel.faultModel.rotationfault = 1;
        }else if([[bikestate substringWithRange:NSMakeRange(6, 1)] isEqualToString:@"0"]){
            bikeModel.faultModel.rotationfault = 0;
        }
        
        if([[bikestate substringWithRange:NSMakeRange(5, 1)] isEqualToString:@"1"]){
            //控制器故障
            bikeModel.faultModel.controllerfault = 1;
        }else if([[bikestate substringWithRange:NSMakeRange(5, 1)] isEqualToString:@"0"]){
            bikeModel.faultModel.controllerfault = 0;
        }
        
        if([[bikestate substringWithRange:NSMakeRange(4, 1)] isEqualToString:@"1"]){
            //控制器故障
            bikeModel.faultModel.motordefectNum = 1;
        }else if([[bikestate substringWithRange:NSMakeRange(4, 1)] isEqualToString:@"0"]){
            bikeModel.faultModel.motordefectNum = 0;
        }
        
        if([[bikestate substringWithRange:NSMakeRange(3, 1)] isEqualToString:@"1"]){
            //刹车故障
            bikeModel.faultModel.brakefault = 1;
        }else if([[bikestate substringWithRange:NSMakeRange(3, 1)] isEqualToString:@"0"]){
            bikeModel.faultModel.brakefault = 0;
        }
        
        if([[bikestate substringWithRange:NSMakeRange(2, 1)] isEqualToString:@"1"]){
            //电池欠压故障
            bikeModel.faultModel.lackvoltage = 1;
        }else if([[bikestate substringWithRange:NSMakeRange(2, 1)] isEqualToString:@"0"]){
            bikeModel.faultModel.lackvoltage = 0;
        }
    }
    
    if ([[keystatenumber substringWithRange:NSMakeRange(7, 1)] isEqualToString:@"1"]) {
        bikeModel.keyInduction = YES;
    }else if ([[keystatenumber substringWithRange:NSMakeRange(7, 1)] isEqualToString:@"0"]){
        bikeModel.keyInduction = NO;
    }
    
    if ([[keystatenumber substringWithRange:NSMakeRange(6, 1)] isEqualToString:@"1"]) {
        bikeModel.gpsConnection = YES;
    }else if ([[keystatenumber substringWithRange:NSMakeRange(6, 1)] isEqualToString:@"0"]){
        bikeModel.gpsConnection = NO;
    }
    
    bikeModel.rssiValue = byte[15] - 255;
    bikeModel.temperatureValue = (NSInteger)BUILD_UINT16(byte[12],byte[11]) * .1;
    bikeModel.voltageValue = (NSInteger)BUILD_UINT16(byte[10],byte[9]) * .1;
    bikeModel.inductionElectricity = byte[14];
    
    bikeModel.firstTireValue = (NSInteger)(byte[16]==255? -1:byte[16])  * 3.1333;
    bikeModel.secondTireValue = (NSInteger)(byte[17]==255? -1:byte[17])  * 3.1333;
    bikeModel.thirdTireValue = (NSInteger)(byte[18]==255? -1:byte[18])  * 3.1333;
    bikeModel.fourthTireValue = (NSInteger)(byte[19]==255? -1:byte[19])  * 3.1333;
    
    if ([[deviceStatusDescription substringWithRange:NSMakeRange(7, 1)] isEqualToString:@"0"]) {
        bikeModel.isLock = NO;
    }else if ([[deviceStatusDescription substringWithRange:NSMakeRange(7, 1)] isEqualToString:@"1"]){
        bikeModel.isLock = YES;
    }
    
    if ([[deviceStatusDescription substringWithRange:NSMakeRange(6, 1)] isEqualToString:@"0"]) {
        bikeModel.isElectricDoorOpen = NO;
    }else{
        bikeModel.isElectricDoorOpen = YES;
    }
    
    if ([[deviceStatusDescription substringWithRange:NSMakeRange(5, 1)] isEqualToString:@"0"]) {
        bikeModel.isMute = NO;
    }else{
        bikeModel.isMute = YES;
    }
    
    if ([[deviceStatusDescription substringWithRange:NSMakeRange(3, 2)] isEqualToString:@"00"]) {
        
        bikeModel.shockState = low;
    }else if([[deviceStatusDescription substringWithRange:NSMakeRange(3, 2)] isEqualToString:@"01"]){
        
        bikeModel.shockState = middle;
    }else if([[deviceStatusDescription substringWithRange:NSMakeRange(3, 2)] isEqualToString:@"10"]){
        
        bikeModel.shockState = high;
    }
    
    if ([[deviceStatusDescription substringWithRange:NSMakeRange(2, 1)] isEqualToString:@"0"]) {
        
        bikeModel.speedingAlarm = 0;
    }else if ([[deviceStatusDescription substringWithRange:NSMakeRange(2, 1)] isEqualToString:@"1"]){
        
        bikeModel.speedingAlarm = 1;
    }
    
    if ([[deviceStatusDescription substringWithRange:NSMakeRange(1, 1)] isEqualToString:@"0"]) {
        
        bikeModel.automaticLock = 0;//自动上锁关
    }else if ([[deviceStatusDescription substringWithRange:NSMakeRange(1, 1)] isEqualToString:@"1"]){
        
        bikeModel.automaticLock = 1;//自动上锁开
    }
    
    return bikeModel;
}

- (void)analysisDeviceSettingStatus:(NSString *)data callBack:(void (^_Nonnull)(BOOL boolValue))callBack{
    
    if ([[data substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"01"]){
        
        if (callBack) {
            callBack(true);
        }
    }else {
        
        if (callBack) {
            callBack(false);
        }
    }
}

- (void)newAnalysisAddNomalKey:(NSInteger)hardwareNum data:(NSString *)data steps:(void (^)(ConfigurationSteps step))step{
    
    if (!self.keyvalue) {
        self.keyvalue = [data substringWithRange:NSMakeRange(12, 6)];
    }
    [self sendHexstring:[ConverUtil stringToByte:@"A6000007201101"] callBack:nil error:nil];
    if ([[data substringWithRange:NSMakeRange(12, 6)] isEqualToString:self.keyvalue]) {
        
        self.step ++;
        if (self.step == 1) {
            self.key1 = [data substringWithRange:NSMakeRange(12, 8)];
            
            if (step) {
                step(FirstStep);
            }
            
            if (hardwareNum == 7) {
                
                [self sendHexstring:[ConverUtil stringToByte:[@"A600001720120" stringByAppendingFormat:@"%ld%@%@%@%@", self.seq,self.key1, @"00000000",@"00000000",@"00000000"]] callBack:nil error:^(CommandStatus status){
                    if (status == SendSuccess) {
                        [self quiteNomalKeyConfiguration:NULL];
                    }
                }];
                if (step) {
                    step(Success);
                }
                [self restNomalKeyData];
                return;
            }
            
        }else if (self.step == 2){
            
            if ([self.key1 isEqualToString:[data substringWithRange:NSMakeRange(12, 8)]]) {
                //[SVProgressHUD showSimpleText:@"按键重复"];
                if (step) {
                    step(KeyRepeat);
                }
                [self restNomalKeyData];
                return;
            }
            
            self.key2 = [data substringWithRange:NSMakeRange(12, 8)];
            
            if (step) {
                step(SecondStep);
            }
            
            if (hardwareNum == 3) {
                
                [self sendHexstring:[ConverUtil stringToByte:[@"A600001720120" stringByAppendingFormat:@"%ld%@%@%@%@", self.seq,self.key1, self.key2,@"00000000",@"00000000"]] callBack:nil error:^(CommandStatus status){
                    if (status == SendSuccess) {
                        NSLog(@"钥匙配置完成");
                        [self quiteNomalKeyConfiguration:NULL];
                    }
                }];
                if (step) {
                    step(Success);
                }
                [self restNomalKeyData];
                return;
            }
            
            
        }else if (self.step == 3){
            
            if ([self.key1 isEqualToString:[data substringWithRange:NSMakeRange(12, 8)]] || [self.key2 isEqualToString:[data substringWithRange:NSMakeRange(12, 8)]]) {
                
                if (step) {
                    step(KeyRepeat);
                }
                [self restNomalKeyData];
                return;
            }
            
            self.key3 = [data substringWithRange:NSMakeRange(12, 8)];
            if (step) {
                step(ThirdStep);
            }
            if (hardwareNum == 4 || hardwareNum == 5 || hardwareNum == 6 || hardwareNum == 8 || hardwareNum == 9) {
                [self sendHexstring:[ConverUtil stringToByte:[@"A600001720120" stringByAppendingFormat:@"%ld%@%@%@%@", self.seq,self.key1,self.key2,self.key3,@"00000000"]] callBack:nil error:^(CommandStatus status){
                    if (status == SendSuccess) {
                        [self quiteNomalKeyConfiguration:NULL];
                    }
                }];
                if (step) {
                    step(Success);
                }
                [self restNomalKeyData];
                return;
            }
            
        }else if (self.step == 4){
            if ([self.key1 isEqualToString:[data substringWithRange:NSMakeRange(12, 8)]] || [self.key2 isEqualToString:[data substringWithRange:NSMakeRange(12, 8)]] || [self.key3 isEqualToString:[data substringWithRange:NSMakeRange(12, 8)]]) {
                
                if (step) {
                    step(KeyRepeat);
                }
                [self restNomalKeyData];
                return;
            }
            self.key4 = [data substringWithRange:NSMakeRange(12, 8)];
            [self sendHexstring:[ConverUtil stringToByte:[@"A600001720120" stringByAppendingFormat:@"%ld%@%@%@%@",self.seq,self.key1,self.key2,self.key3,self.key4]] callBack:nil error:^(CommandStatus status){
                if (status == SendSuccess) {
                    [self quiteNomalKeyConfiguration:NULL];
                }
            }];
            if (step) {
                step(Success);
            }
        }
    }else{
        
        if (step) {
            step(KeyConflict);
        }
        [self restNomalKeyData];
        return;
    }
}

- (DeviceConfigurationModel *)newAnalysisBikeConfiguration:(NSString *)data{
    
    NSString *bikefunction = [ConverUtil getBinaryByhex:[data substringWithRange:NSMakeRange(18, 2)]];
    DeviceConfigurationModel *model = [[DeviceConfigurationModel alloc] init];
    
    if([[bikefunction substringWithRange:NSMakeRange(1, 1)] isEqualToString:@"1"]){
        model.supportTirePressure = YES;
    }
    
    if([[bikefunction substringWithRange:NSMakeRange(2, 2)] isEqualToString:@"00"]){
        model.supportFingerprint = NO;
    }else if ([[bikefunction substringWithRange:NSMakeRange(2, 2)] isEqualToString:@"01"]){
        model.supportFingerprint = YES;
        model.fingerprintConfigurationTimes = 3;
    }else if ([[bikefunction substringWithRange:NSMakeRange(2, 2)] isEqualToString:@"10"]){
        model.supportFingerprint = YES;
        model.fingerprintConfigurationTimes = 5;
    }
    
    if([[bikefunction substringWithRange:NSMakeRange(4, 1)] isEqualToString:@"1"]){
        model.supportSpeedAlarm = YES;
    }
    
    if([[bikefunction substringWithRange:NSMakeRange(5, 1)] isEqualToString:@"1"]){
        model.supportVibrationSensor = YES;
    }
    
    if([[bikefunction substringWithRange:NSMakeRange(6, 2)] isEqualToString:@"00"]){
        model.numberOfWheels = 2;
    }else if ([[bikefunction substringWithRange:NSMakeRange(6, 2)] isEqualToString:@"01"]){
        model.numberOfWheels = 3;
    }else if ([[bikefunction substringWithRange:NSMakeRange(6, 2)] isEqualToString:@"10"]){
        model.numberOfWheels = 4;
    }
    
    return model;
}

- (void)newAnalysisDeviceInductionValue:(NSString *)data callBack:(void (^_Nonnull)(NSInteger value))callBack{
    
    NSData *datevalue = [ConverUtil parseHexStringToByteArray:data];
    Byte *byte=(Byte *)[datevalue bytes];
    NSInteger inducKeyValue = byte[6];
    if (callBack) {
        callBack(inducKeyValue);
    }
}

-(void)newAnalysisAddFingerPrint:(NSString *)data status:(void (^_Nullable)(FingerPrintStatus status))status{
    
    if ([[data substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"00"]) {
        if (status) {
            status(PrintSuccess);
        }
        [self restFingerPrintParameter];
        
    }else if ([[data substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"01"]){
        
        if (status) {
            status(PrintFirst);
        }
        [self sendHexstring:[ConverUtil stringToByte:@"A60000066012"] callBack:nil error:nil];
        
    }else if ([[data substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"02"]){
        
        if (status) {
            status(PrintSecond);
        }
        [self sendHexstring:[ConverUtil stringToByte:@"A60000066012"] callBack:nil error:nil];
        
    }else if ([[data substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"03"]){
        
        if (status) {
            status(PrintThird);
        }
        [self sendHexstring:[ConverUtil stringToByte:@"A60000066012"] callBack:nil error:nil];
        
    }else if ([[data substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"04"]){
        
        if (status) {
            status(PrintFourth);
        }
        [self sendHexstring:[ConverUtil stringToByte:@"A60000066012"] callBack:nil error:nil];
        
    }else if ([[data substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"FF"]){
        
        if (status) {
            status(PrintFail);
        }
        [self restFingerPrintParameter];
    }
    
}

- (void)newAnalysisInquireFingerPrint:(NSString *)data status:(void (^_Nullable)(FingerPrintStatus status))status{
    
    if ([[data substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"00"]) {
        
        if (status) {
            status(PrintLiftUp);
        }
        
        self.pressSecond = 0;
        self.fingerPressNum++;
        [self sendHexstring:[ConverUtil stringToByte:[NSString stringWithFormat:@"A600000760130%ld",self.fingerPressNum]] callBack:nil error:nil];
    }else if ([[data substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"01"]){
        
        if (self.fingerPressNum >= 1 && self.fingerPressNum < 5){
            
            if (self.pressSecond<1) {
                self.pressSecond ++;
                self.startTime = CFAbsoluteTimeGetCurrent();
            }
            CFAbsoluteTime linkTime = (CFAbsoluteTimeGetCurrent() - self.startTime);
            if ((NSInteger)linkTime >=3) {
                if (status) {
                    status(PrintTooLong);
                }
            }
        }
        [self sendHexstring:[ConverUtil stringToByte:@"A50000063006"] callBack:nil error:nil];
    }else{
        
        [self sendHexstring:[ConverUtil stringToByte:@"A50000063006"] callBack:nil error:nil];
    }
}

-(void)restNomalKeyData{
    
    self.keyvalue = nil;
    self.key1 = nil;
    self.key2 = nil;
    self.key3 = nil;
    self.key4 = nil;
    self.step = 0;
    self.seq = 0;
}

-(void)restFingerPrintParameter{
    
    self.fingerPressNum = 0;
    self.pressSecond = 0;
    self.startTime = 0;
}

@end
