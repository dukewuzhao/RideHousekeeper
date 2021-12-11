//
//  SecondVersionServices.m
//  myTest
//
//  Created by Apple on 2019/8/26.
//  Copyright © 2019 Apple. All rights reserved.
//

#import "SecondVersionServices.h"
#import "WYDeviceServices.h"
#import "MD5Encrypt.h"
#import <CommonCrypto/CommonDigest.h>
@interface SecondVersionServices ()

@property (nonatomic,strong) MSWeakTimer * queraTime;
@end

@implementation SecondVersionServices

- (instancetype)init{
    if (self = [super init]) {
        NSLog(@"运行了第二个services");
    }
    return self;
}

- (void)didConnect:(NSInteger)tag :(CBPeripheral *)peripheral{
    [self begainTimer];
}

-(void)begainTimer{
    _queraTime = [MSWeakTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(queryFired) userInfo:nil repeats:NO dispatchQueue:dispatch_get_main_queue()];
}

-(void)queryFired{
    [[WYDeviceServices shareInstance] sendHexstring:[ConverUtil stringToByte:@"A60000061011"] callBack:nil error:nil];
}

- (void)didDisconnect:(NSInteger)tag :(CBPeripheral *)peripheral{
    
    [_queraTime invalidate];
    _queraTime = nil;
}

-(void)connectGPSByMac:(NSString *_Nonnull)mac data:(void (^_Nonnull)(id data))data error:(void (^_Nullable)(CommandStatus status))error{
    [[WYDeviceServices shareInstance] sendHexstring:[ConverUtil stringToByte: [NSString stringWithFormat:@"A600000C1034%@",mac]] callBack:data error:error];
}

-(void)queryVehicleStatusOnce:(void (^_Nonnull)(BikeStatusModel *model))data error:(void (^_Nullable)(CommandStatus status))error{
    [[WYDeviceServices shareInstance] sendHexstring:[ConverUtil stringToByte:@"A60000061011"] callBack:data error:error];
}

-(void)sendPasswordCommend:(NSString *)password data:(void (^ _Nonnull)(id data))data error:(void (^)(CommandStatus))error{
    NSString *bikePassWord = password;
    if (bikePassWord.length !=8) {
        int masterpwdCount = 8 - (int)bikePassWord.length;
        for (int i = 0; i<masterpwdCount; i++) {
            bikePassWord = [@"0" stringByAppendingFormat:@"%@",bikePassWord];
        }
    }
    [[WYDeviceServices shareInstance] sendHexstring:[ConverUtil stringToByte: [NSString stringWithFormat:@"A600000A1033%@",bikePassWord]] callBack:data error:error];
}

-(void)GPSAuthentication:(NSString *)authenticationCode data:(void (^_Nonnull)(id data))data error:(void (^_Nullable)(CommandStatus status))error{
    
    if (error) {
        error(NotSupport);
    }
}

-(void)QueryGPSActivationStatus:(GPSOperationMode)mode  data:(void (^_Nonnull)(id data))data error:(void (^_Nullable)(CommandStatus status))error{
    if (error) {
        error(NotSupport);
    }
}

-(void)sendSingleGPSActivationCommend:(SwitchStatus)behavior data:(void (^_Nonnull)(id data))data error:(void (^_Nullable)(CommandStatus status))error{
    if (error) {
        error(NotSupport);
    }
}

-(void)enterFirmwareUpgrade:(void (^)(id data))data error:(void (^)(CommandStatus status))error{
    
    [[WYDeviceServices shareInstance] sendHexstring:[ConverUtil stringToByte:@"A60000061031"] callBack:data error:error];
}

-(void)querykeyVersionNumber:(void (^)(NSString *data))data error:(void (^)(CommandStatus status))error{
    
    [[WYDeviceServices shareInstance] sendHexstring:[ConverUtil stringToByte:@"A60000062013"] callBack:data error:error];
}

-(void)setBikeBasicStatues:(NomalCommand)commandType error:(void (^_Nullable)(CommandStatus status))error{
    
    switch (commandType) {
        case DeviceSetSafe:
            [[WYDeviceServices shareInstance] sendHexstring:[ConverUtil stringToByte:@"A6000007102102"] callBack:nil error:error];
            break;
        case DeviceOutSafe:
            
            [[WYDeviceServices shareInstance] sendHexstring:[ConverUtil stringToByte:@"A6000007102101"] callBack:nil error:error];
            break;
        case DeviceSetSafeNoSound:
            [[WYDeviceServices shareInstance] sendHexstring:[ConverUtil stringToByte:@"A6000007102110"] callBack:nil error:error];
            break;
        case DeviceSetSafeSound:
            [[WYDeviceServices shareInstance] sendHexstring:[ConverUtil stringToByte:@"A6000007102111"] callBack:nil error:error];
            break;
        case DeviceOpenSeat:
            [[WYDeviceServices shareInstance] sendHexstring:[ConverUtil stringToByte:@"A6000007102107"] callBack:nil error:error];
            break;
        case DeviceFindBike:
            [[WYDeviceServices shareInstance] sendHexstring:[ConverUtil stringToByte:@"A6000007102108"] callBack:nil error:error];
            break;
        case DeviceOpenEleDoor:
            [[WYDeviceServices shareInstance] sendHexstring:[ConverUtil stringToByte:@"A6000007102103"] callBack:nil error:error];
            break;
        case DeviceCloseEleDoor:
            [[WYDeviceServices shareInstance] sendHexstring:[ConverUtil stringToByte:@"A6000007102104"] callBack:nil error:error];
            break;
            
        case DeviceOpenTirePressureAlarm:
            if (error) {
                error(NotSupport);
            }
            break;
        case DeviceCloseTirePressureAlarm:
            if (error) {
                error(NotSupport);
            }
            break;
            
        default:
            break;
    }
}

-(void)quiteNomalKeyConfiguration:(void (^)(CommandStatus code))error{
    
    [[WYDeviceServices shareInstance] sendHexstring:[ConverUtil stringToByte:@"A6000007201100"] callBack:nil error:error];
}

-(void)readingVehicleInformation:(NSInteger)num data:(void (^)(id data))data error:(void (^ _Nullable)(CommandStatus status))error{
    
    if (data) {
        data([NSString stringWithFormat:@"%ld",(long)num]);
    }
    
    if (error) {
        error(SendSuccess);
    }
}

-(void)addNomalKeyConfiguration:(NSInteger)seq hardwareNum:(NSInteger)hardwareNum steps:(void (^)(ConfigurationSteps step))step error:(void (^)(CommandStatus status))error{
    
    [[WYDeviceServices shareInstance] sendHexstring:[ConverUtil stringToByte:@"A6000007201101"] callBack:nil error:error];
}

-(void)deleteNomalKeyConfiguration:(NSInteger)seq error:(void (^_Nullable)(CommandStatus status))error{
    
    [[WYDeviceServices shareInstance] sendHexstring:[ConverUtil stringToByte:[@"A600001720120" stringByAppendingFormat:@"%ld%@%@%@%@",(long)seq, @"FFFFFFFF", @"FFFFFFFF", @"FFFFFFFF", @"FFFFFFFF"]] callBack:nil error:NULL];
}

-(void)addInductionKey:(NSInteger)seq mac:(NSString *)Mac data:(void (^)(id data))data error:(void (^_Nullable)(CommandStatus status))error{
    
    if (error) {
        error(NotSupport);
    }
}

-(void)deleteInductionKey:(NSInteger)seq mac:(NSString *)Mac data:(void (^)(id data))data error:(void (^_Nullable)(CommandStatus status))error{
    
    if (error) {
        error(NotSupport);
    }
}


-(void)addBLEKey:(NSInteger)seq data:(void (^)(id data))data error:(void (^_Nullable)(CommandStatus status))error{
    
    [[WYDeviceServices shareInstance] sendHexstring:[ConverUtil stringToByte:[NSString stringWithFormat:@"A60000082021010%ld",(long)seq]] callBack:data error:error];
}

-(void)deleteBLEKey:(NSInteger)seq data:(void (^)(id data))data error:(void (^_Nullable)(CommandStatus status))error{
    
    [[WYDeviceServices shareInstance] sendHexstring:[ConverUtil stringToByte:[NSString stringWithFormat:@"A60000082021000%ld",(long)seq]] callBack:data error:error];
}

-(void)quiteBLEKeyConfiguration:(NSInteger)seq data:(void (^_Nonnull)(id data))data error:(void (^_Nullable)(CommandStatus status))error{
    [[WYDeviceServices shareInstance] sendHexstring:[ConverUtil stringToByte:[NSString stringWithFormat:@"A60000082021020%ld",(long)seq]] callBack:data error:error];
}

-(void)addTirePressure:(NSInteger)seq mac:(NSString *)Mac data:(void (^_Nonnull)(id data))data error:(void (^_Nullable)(CommandStatus status))error{
    
    if (error) {
        error(NotSupport);
    }
}

-(void)deleteTirePressure:(NSInteger)seq mac:(NSString *)Mac data:(void (^_Nonnull)(id data))data error:(void (^_Nullable)(CommandStatus status))error{
    
    if (error) {
        error(NotSupport);
    }
}

-(void)addFingerPrint:(NSInteger)num fingerPrintType:(NSInteger)fingerPrintType status:(void (^_Nullable)(FingerPrintStatus status))status error:(void (^_Nullable)(CommandStatus status))error{
    
    [self deleteFingerPrint:num data:^(id _Nonnull data) {
        
        if ([data isEqualToString:@"00"]) {
            
            NSString *HEX;
            if (num >= 10) {
                HEX = @"A600000760130A";
            }else{
                HEX = [NSString stringWithFormat:@"A600000760130%ld",(long)num];
            }
            [[WYDeviceServices shareInstance] sendHexstring:[ConverUtil stringToByte:HEX] callBack:nil error:error];
        }else{
            if (status) {
                status(PrintFail);
            }
        }
        
    } error:error];
}

-(void)deleteFingerPrint:(NSInteger)num data:(void (^)(id data))data error:(void (^_Nullable)(CommandStatus status))error{
    
    NSString *HEX;
    if (num == 10) {
        HEX = @"A500000760140A";
    }else{
        HEX = [NSString stringWithFormat:@"A500000760140%ld",(long)num];
    }
    [[WYDeviceServices shareInstance] sendHexstring:[ConverUtil stringToByte:HEX] callBack:data error:error];
}

-(void)quiteFingerPrint:(NSInteger)num fingerPrintType:(NSInteger)fingerPrintType error:(void (^ _Nullable)(CommandStatus status))error{
    
    [WYDeviceServices shareInstance].fingerPressNum = 0;
    [WYDeviceServices shareInstance].pressSecond = 0;
    [WYDeviceServices shareInstance].startTime = 0;
    [[WYDeviceServices shareInstance] sendHexstring:[ConverUtil stringToByte:@"A50000076013FF"] callBack:nil error:error];
}

-(void)setDeviceSpeedingAlarmStatus:(SwitchStatus)status error:(void (^_Nullable)(CommandStatus status))error{
    [[WYDeviceServices shareInstance] sendHexstring:[ConverUtil stringToByte:[NSString stringWithFormat:@"A600000710210%@",status?@"F":@"E"]] callBack:nil error:error];
}

-(void)getDeviceAutomaticLockStatus:(BOOL)status automaticLockBlock:(void (^)(BOOL automaticLock))data error:(void (^_Nullable)(CommandStatus status))error{
    
    if (data) {
        data(status);
    }
    if (error) {
        error(SendSuccess);
    }
    
}

-(void)setDeviceAutomaticLockStatus:(SwitchStatus)status data:(void (^)(BOOL automaticLock))data error:(void (^_Nullable)(CommandStatus status))error{
    [[WYDeviceServices shareInstance] sendHexstring:[ConverUtil stringToByte:[NSString stringWithFormat:@"A600000710210%@",status?@"9":@"A"]] callBack:nil error:error];
}

-(void)getDeviceSensingDistanceValue:(void (^)(NSInteger value))data error:(void (^_Nullable)(CommandStatus status))error{
    [[WYDeviceServices shareInstance] sendHexstring:[ConverUtil stringToByte:@"A6000007202200"] callBack:nil error:error];
}

-(void)setDeviceSensingDistanceValue:(NSInteger)value data:(void (^)(NSInteger value))data error:(void (^_Nullable)(CommandStatus status))error{
    
    [[WYDeviceServices shareInstance] sendHexstring:[ConverUtil stringToByte:[NSString stringWithFormat:@"A60000072022%@",[ConverUtil ToHex:value]]] callBack:nil error:error];
}

-(void)setDeviceShockStatus:(ShockState)status error:(void (^_Nullable)(CommandStatus status))error{
    
    switch (status) {
        case low:
            [[WYDeviceServices shareInstance] sendHexstring:[ConverUtil stringToByte:[NSString stringWithFormat:@"A600000710210%@",@"B"]] callBack:nil error:error];
            break;
        case middle:
            [[WYDeviceServices shareInstance] sendHexstring:[ConverUtil stringToByte:[NSString stringWithFormat:@"A600000710210%@",@"C"]] callBack:nil error:error];
            break;
        case high:
            [[WYDeviceServices shareInstance] sendHexstring:[ConverUtil stringToByte:[NSString stringWithFormat:@"A600000710210%@",@"D"]] callBack:nil error:error];
            break;
        default:
            break;
    }
}

-(void)bikePasswordConfiguration:(NSDictionary *)passwordDic data:(void (^)(id data))data error:(void (^_Nullable)(CommandStatus status))error{
    //_callbackdateblock = data;
    NSArray *child = passwordDic[@"children"];
    NSString *main = [ConverUtil ToHex:(long)[passwordDic[@"main"] longLongValue]];
    NSString *childpwdone = [ConverUtil ToHex:(long)[child[0] longLongValue]];
    NSString *childpwdtwo = [ConverUtil ToHex:(long)[child[1] longLongValue]];
    NSString *childpwdthree = [ConverUtil ToHex:(long)[child[2] longLongValue]];
    NSString *childpwdfour = [ConverUtil ToHex:(long)[child[3] longLongValue]];
    NSString *childpwdfive = [ConverUtil ToHex:(long)[child[4] longLongValue]];
    
    if (main.length !=8) {
        int masterpwdCount = 8 - (int)main.length;
        for (int i = 0; i<masterpwdCount; i++) {
            main = [@"0" stringByAppendingFormat:@"%@",main];
        }
    }
    
    if (childpwdone.length !=8) {
        int childpwdoneCount = 8 - (int)childpwdone.length;
        for (int i = 0; i<childpwdoneCount; i++) {
            childpwdone = [@"0" stringByAppendingFormat:@"%@", childpwdone];
        }
    }
    
    if (childpwdtwo.length !=8) {
        int childpwdtwoCount = 8 - (int)childpwdtwo.length;
        for (int i = 0; i<childpwdtwoCount; i++) {
            childpwdtwo = [@"0" stringByAppendingFormat:@"%@", childpwdtwo];
        }
    }
    //16777216 1099511627775
    if (childpwdthree.length !=8) {
        int childpwdthreeCount = 8 - (int)childpwdthree.length;
        for (int i = 0; i<childpwdthreeCount; i++) {
            childpwdthree = [@"0" stringByAppendingFormat:@"%@",childpwdthree];
        }
    }
    
    if (childpwdfour.length !=8) {
        int childpwdfourCount = 8 - (int)childpwdfour.length;
        for (int i = 0; i<childpwdfourCount; i++) {
            childpwdfour = [@"0" stringByAppendingFormat:@"%@",childpwdfour];
        }
    }
    
    if (childpwdfive.length !=8) {
        int childpwdfiveCount = 8 - (int)childpwdfive.length;
        for (int i = 0; i<childpwdfiveCount; i++) {
            childpwdfive = [@"0" stringByAppendingFormat:@"%@",childpwdfive];
        }
    }
    [[WYDeviceServices shareInstance] sendHexstring:[ConverUtil stringToByte:[@"A600001E1032" stringByAppendingFormat:@"%@%@%@%@%@%@",main, childpwdone,childpwdtwo,childpwdthree, childpwdfour,childpwdfive]] callBack:data error:error];
}

-(void)getDeviceSupportdata:(void (^)(DeviceConfigurationModel *model))data error:(void (^_Nullable)(CommandStatus status))error{
    [[WYDeviceServices shareInstance] sendHexstring:[ConverUtil stringToByte:@"A60000061012"] callBack:data error:error];
}


-(void)dealloc{
    [_queraTime invalidate];
    _queraTime = nil;
}

@end
