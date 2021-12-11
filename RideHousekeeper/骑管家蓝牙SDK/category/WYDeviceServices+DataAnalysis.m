//
//  WYDeviceServices+DataAnalysis.m
//  myTest
//
//  Created by Apple on 2019/7/9.
//  Copyright © 2019 Apple. All rights reserved.
//

#import "WYDeviceServices+DataAnalysis.h"
#import "BikeStatusModel.h"
#import "DeviceConfigurationModel.h"
#import "FaultModel.h"

#define HI_UINT16(a) (((a) >> 8) & 0xff)
#define LO_UINT16(a) ((a) & 0xff)
#define BUILD_UINT16(loByte, hiByte) ((uint16_t)(((loByte) & 0x00FF) + (((hiByte) & 0x00FF) << 8)))

@implementation WYDeviceServices (DataAnalysis)


- (BikeStatusModel *)analysisBikestatus:(BikeStatusModel *)model :(NSString *)data{
    
    BikeStatusModel *bikeModel = model;
    NSData *datavalue = [ConverUtil stringToByte:data];
    Byte *byte=(Byte *)[datavalue bytes];

    NSString *binary = [ConverUtil getBinaryByhex:[data substringWithRange:NSMakeRange(12, 2)]];
    NSString *bikestate = [ConverUtil getBinaryByhex:[data substringWithRange:NSMakeRange(28, 2)]];
    NSString *keystatenumber = [ConverUtil getBinaryByhex:[data substringWithRange:NSMakeRange(16, 2)]];
    
    if (byte[14] == 0) {
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
    
//    if ([[keystatenumber substringWithRange:NSMakeRange(7, 1)] isEqualToString:@"1"]) {
//
//        bikeModel.keyInduction = YES;
//    }else if ([[keystatenumber substringWithRange:NSMakeRange(7, 1)] isEqualToString:@"0"]){
//
//        bikeModel.keyInduction = NO;
//    }
    
    if ([[keystatenumber substringWithRange:NSMakeRange(6, 1)] isEqualToString:@"1"]) {
        bikeModel.gpsConnection = YES;
    }else if ([[keystatenumber substringWithRange:NSMakeRange(6, 1)] isEqualToString:@"0"]){
        bikeModel.gpsConnection = NO;
    }
    
    bikeModel.temperatureValue = (NSInteger)BUILD_UINT16(byte[12],byte[11]) * .1;
    bikeModel.voltageValue = (NSInteger)BUILD_UINT16(byte[10],byte[9]) * .1;
    bikeModel.rssiValue = (char)byte[13];
    bikeModel.inductionElectricity = (char)byte[15];
    bikeModel.firstTireValue = (char)byte[16]*3.1333;
    bikeModel.secondTireValue = (char)byte[17]*3.1333;
    bikeModel.thirdTireValue = (char)byte[18]*3.1333;
    bikeModel.fourthTireValue = (char)byte[19]*3.1333;
    
    if ([[binary substringWithRange:NSMakeRange(7, 1)] isEqualToString:@"0"]) {
        bikeModel.isLock = NO;
    }else if ([[binary substringWithRange:NSMakeRange(7, 1)] isEqualToString:@"1"]){
        bikeModel.isLock = YES;
    }
    
    if ([[binary substringWithRange:NSMakeRange(6, 1)] isEqualToString:@"0"]) {
        bikeModel.isElectricDoorOpen = NO;
        
    }else{
        bikeModel.isElectricDoorOpen = YES;
    }
    
    if ([[binary substringWithRange:NSMakeRange(5, 1)] isEqualToString:@"0"]) {
        bikeModel.isMute = NO;
    }else{
        bikeModel.isMute = YES;
    }
    
    if ([[binary substringWithRange:NSMakeRange(3, 2)] isEqualToString:@"00"]) {
        
        bikeModel.shockState = low;
    }else if([[binary substringWithRange:NSMakeRange(3, 2)] isEqualToString:@"01"]){
        
        bikeModel.shockState = middle;
    }else if([[binary substringWithRange:NSMakeRange(3, 2)] isEqualToString:@"10"]){
        
        bikeModel.shockState = high;
    }
    
    if ([[binary substringWithRange:NSMakeRange(2, 1)] isEqualToString:@"0"]) {
        
        bikeModel.speedingAlarm = YES;
    }else if ([[binary substringWithRange:NSMakeRange(2, 1)] isEqualToString:@"1"]){
        
        bikeModel.speedingAlarm = NO;
    }
    
    if ([[binary substringWithRange:NSMakeRange(1, 1)] isEqualToString:@"0"]) {
        
        bikeModel.tirePressureAlarm = NO;
    }else if ([[binary substringWithRange:NSMakeRange(1, 1)] isEqualToString:@"1"]){
        
        bikeModel.tirePressureAlarm = YES;
    }
    
    return bikeModel;
}

- (DeviceConfigurationModel *)analysisBikeConfiguration:(NSString *)data{
    
    NSString *bikefunction = [ConverUtil getBinaryByhex:[data substringWithRange:NSMakeRange(18, 2)]];
    DeviceConfigurationModel *model = [[DeviceConfigurationModel alloc] init];
    
    if([[bikefunction substringWithRange:NSMakeRange(7, 1)] isEqualToString:@"1"]){
        model.supportFingerprint = YES;
    }
    
    if([[bikefunction substringWithRange:NSMakeRange(6, 1)] isEqualToString:@"1"]){
        model.supportVibrationSensor = YES;
    }
    
    if([[bikefunction substringWithRange:NSMakeRange(5, 1)] isEqualToString:@"1"]){
        model.supportTirePressure = YES;
    }
    
    if([[bikefunction substringWithRange:NSMakeRange(2, 1)] isEqualToString:@"1"]){
        model.fingerprintConfigurationTimes = 5;
    }else if ([[bikefunction substringWithRange:NSMakeRange(2, 1)] isEqualToString:@"0"]){
        model.fingerprintConfigurationTimes = 3;
    }
    return model;
}

- (void)analysisAddNomalKey:(NSInteger)hardwareNum data:(NSString *)date steps:(void (^)(ConfigurationSteps step))step{
    
    if (!self.keyvalue) {
        self.keyvalue = [date substringWithRange:NSMakeRange(12, 6)];
    }
    [self sendHexstring:[ConverUtil stringToByte:@"A5000007100301"] callBack:nil error:nil];
    if ([[date substringWithRange:NSMakeRange(12, 6)] isEqualToString:self.keyvalue]) {
        
        self.step ++;
        
        if (self.step == 1) {
            self.key1 = [date substringWithRange:NSMakeRange(12, 8)];
            
            if (step) {
                step(FirstStep);
            }
            
            if (hardwareNum == 7) {
                
                [self sendHexstring:[ConverUtil stringToByte:[@"A500001730010" stringByAppendingFormat:@"%ld%@%@%@%@", self.seq,self.key1, @"00000000",@"00000000",@"00000000"]] callBack:nil error:^(CommandStatus status){
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
            
            if ([self.key1 isEqualToString:[date substringWithRange:NSMakeRange(12, 8)]]) {
                //[SVProgressHUD showSimpleText:@"按键重复"];
                if (step) {
                    step(KeyRepeat);
                }
                [self restNomalKeyData];
                return;
            }
            
            self.key2 = [date substringWithRange:NSMakeRange(12, 8)];
            
            if (step) {
                step(SecondStep);
            }
            
            if (hardwareNum == 3) {
                
                [self sendHexstring:[ConverUtil stringToByte:[@"A500001730010" stringByAppendingFormat:@"%ld%@%@%@%@", self.seq,self.key1, self.key2,@"00000000",@"00000000"]] callBack:nil error:^(CommandStatus status){
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
            
            if ([self.key1 isEqualToString:[date substringWithRange:NSMakeRange(12, 8)]] || [self.key2 isEqualToString:[date substringWithRange:NSMakeRange(12, 8)]]) {
                
                if (step) {
                    step(KeyRepeat);
                }
                [self restNomalKeyData];
                return;
            }
            
            self.key3 = [date substringWithRange:NSMakeRange(12, 8)];
            if (step) {
                step(ThirdStep);
            }
            if (hardwareNum == 4 || hardwareNum == 5 || hardwareNum == 6 || hardwareNum == 8 || hardwareNum == 9) {
                [self sendHexstring:[ConverUtil stringToByte:[@"A500001730010" stringByAppendingFormat:@"%ld%@%@%@%@", self.seq,self.key1,self.key2,self.key3,@"00000000"]] callBack:nil error:^(CommandStatus status){
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
            if ([self.key1 isEqualToString:[date substringWithRange:NSMakeRange(12, 8)]] || [self.key2 isEqualToString:[date substringWithRange:NSMakeRange(12, 8)]] || [self.key3 isEqualToString:[date substringWithRange:NSMakeRange(12, 8)]]) {
                
                if (step) {
                    step(KeyRepeat);
                }
                [self restNomalKeyData];
                return;
            }
            self.key4 = [date substringWithRange:NSMakeRange(12, 8)];
            [self sendHexstring:[ConverUtil stringToByte:[@"A500001730010" stringByAppendingFormat:@"%ld%@%@%@%@",self.seq,self.key1,self.key2,self.key3,self.key4]] callBack:nil error:^(CommandStatus status){
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

-(void)analysisAddFingerPrint:(NSString *)data status:(void (^_Nullable)(FingerPrintStatus status))status{
    
    if ([[data substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"00"]) {
        if (status) {
            status(PrintSuccess);
        }
        [self restFingerPrintParameter];
        
    }else if ([[data substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"01"]){
        
        if (status) {
            status(PrintFirst);
        }
        [self sendHexstring:[ConverUtil stringToByte:@"A50000063006"] callBack:nil error:nil];
        
    }else if ([[data substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"02"]){
        
        if (status) {
            status(PrintSecond);
        }
        [self sendHexstring:[ConverUtil stringToByte:@"A50000063006"] callBack:nil error:nil];
        
    }else if ([[data substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"03"]){
        
        if (status) {
            status(PrintThird);
        }
        [self sendHexstring:[ConverUtil stringToByte:@"A50000063006"] callBack:nil error:nil];
        
    }else if ([[data substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"04"]){
        
        if (status) {
            status(PrintFourth);
        }
        [self sendHexstring:[ConverUtil stringToByte:@"A50000063006"] callBack:nil error:nil];
        
    }else if ([[data substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"FF"]){
        
        if (status) {
            status(PrintFail);
        }
        [self restFingerPrintParameter];
    }
    
}

- (void)analysisInquireFingerPrint:(NSString *)data fingerPrinttype:(NSString *)type status:(void (^_Nullable)(FingerPrintStatus status))status{
    
    if ([[data substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"00"]) {
        
        if (status) {
            status(PrintLiftUp);
        }
        
        self.pressSecond = 0;
        self.fingerPressNum++;
        [self sendHexstring:[ConverUtil stringToByte:[NSString stringWithFormat:@"A5000007%@F%ld",type,self.fingerPressNum]] callBack:nil error:nil];
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

- (NSNumber *)analysisVehicleInformationReading:(NSString *)data{
    
    NSString *binary = [[ConverUtil getBinaryByhex:[data substringWithRange:NSMakeRange(12, 2)]] substringWithRange:NSMakeRange(6, 2)];
    if ([binary isEqualToString:@"00"]) {
        return @2;
    }else if ([binary isEqualToString:@"01"]){
        return @3;
    }else if ([binary isEqualToString:@"10"]){
        return @4;
    }
    
    return @2;
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

- (void)analysisDeviceInductionValue:(NSString *)data callBack:(void (^_Nonnull)(NSInteger value))callBack{
    
    NSData *datevalue = [ConverUtil parseHexStringToByteArray:data];
    Byte *byte=(Byte *)[datevalue bytes];
    NSInteger inducKeyValue = byte[6];
    if (callBack) {
        callBack(inducKeyValue);
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
    
    //_fingerPressNum = _pressSecond = _startTime = 0;
    self.fingerPressNum = 0;
    self.pressSecond = 0;
    self.startTime = 0;
}

@end
