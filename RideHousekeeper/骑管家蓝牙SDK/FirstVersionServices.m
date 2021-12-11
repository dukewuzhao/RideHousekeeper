//
//  FirstVersionServices.m
//  myTest
//
//  Created by Apple on 2019/8/26.
//  Copyright © 2019 Apple. All rights reserved.
//

#import "FirstVersionServices.h"
#import "WYDeviceServices.h"

@interface FirstVersionServices ()

@property (nonatomic,strong) MSWeakTimer * queraTime;//0.5秒的计时器，用于查询数据
@end

@implementation FirstVersionServices

- (instancetype)init{
    if (self = [super init]) {
        NSLog(@"运行了第一个services");
    }
    return self;
}

- (void)didConnect:(NSInteger)tag :(CBPeripheral *)peripheral{
    
    [self begainTimer];
}

- (void)didDisconnect:(NSInteger)tag :(CBPeripheral *)peripheral{
    
    [_queraTime invalidate];
    _queraTime = nil;
}

-(void)begainTimer{
    _queraTime = [MSWeakTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(queryFired) userInfo:nil repeats:YES dispatchQueue:dispatch_get_main_queue()];
}

-(void)queryFired{
    
    if ([[APPStatusManager sharedManager] getBikeBindingStstus] || [[APPStatusManager sharedManager] getBikeFirmwareUpdateStstus]) {
        return;
    }
    
    [[WYDeviceServices shareInstance] sendHexstring:[ConverUtil stringToByte:@"A50000061001"] callBack:nil error:nil];
}

-(void)connectGPSByMac:(NSString *_Nonnull)mac data:(void (^_Nonnull)(id data))data error:(void (^_Nullable)(CommandStatus status))error{
    [[WYDeviceServices shareInstance] sendHexstring:[ConverUtil stringToByte: [NSString stringWithFormat:@"A500000C1010%@",mac]] callBack:data error:error];
}

-(void)queryVehicleStatusOnce:(void (^_Nonnull)(BikeStatusModel *model))data error:(void (^_Nullable)(CommandStatus status))error{
    [[WYDeviceServices shareInstance] sendHexstring:[ConverUtil stringToByte:@"A50000061001"] callBack:data error:error];
}

-(void)sendPasswordCommend:(NSString *)password data:(void (^ _Nonnull)(id data))data error:(void (^)(CommandStatus))error{
    
    NSString *bikePassWord = password;
    if (bikePassWord.length !=8) {
        int masterpwdCount = 8 - (int)bikePassWord.length;
        for (int i = 0; i<masterpwdCount; i++) {
            bikePassWord = [@"0" stringByAppendingFormat:@"%@",bikePassWord];
        }
    }
    
    [[WYDeviceServices shareInstance] sendHexstring:[ConverUtil stringToByte: [NSString stringWithFormat:@"A500000A1002%@",bikePassWord]] callBack:data error:error];
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
    
    [[WYDeviceServices shareInstance] sendHexstring:[ConverUtil stringToByte:@"A50000061004"] callBack:data error:error];
}

-(void)querykeyVersionNumber:(void (^)(NSString *data))data error:(void (^)(CommandStatus status))error{
    
    [[WYDeviceServices shareInstance] sendHexstring:[ConverUtil stringToByte:@"A50000061005"] callBack:data error:error];
}

-(void)setBikeBasicStatues:(NomalCommand)commandType error:(void (^_Nullable)(CommandStatus status))error{
    
    switch (commandType) {
        case DeviceSetSafe:
            NSLog(@"上锁");
            [[WYDeviceServices shareInstance] sendHexstring:[ConverUtil stringToByte:@"A5000007200102"] callBack:nil error:error];
            break;
        case DeviceOutSafe:
            NSLog(@"解锁");
            [[WYDeviceServices shareInstance] sendHexstring:[ConverUtil stringToByte:@"A5000007200101"] callBack:nil error:error];
            break;
        case DeviceSetSafeSound:
            NSLog(@"非静音");
            [[WYDeviceServices shareInstance] sendHexstring:[ConverUtil stringToByte:@"A5000007200106"] callBack:nil error:error];
            break;
        case DeviceSetSafeNoSound:
            NSLog(@"静音");
            [[WYDeviceServices shareInstance] sendHexstring:[ConverUtil stringToByte:@"A5000007200105"] callBack:nil error:error];
            break;
        case DeviceOpenSeat:
            NSLog(@"开座桶");
            [[WYDeviceServices shareInstance] sendHexstring:[ConverUtil stringToByte:@"A5000007200107"] callBack:nil error:error];
            break;
        case DeviceFindBike:
            NSLog(@"寻车");
            [[WYDeviceServices shareInstance] sendHexstring:[ConverUtil stringToByte:@"A5000007200108"] callBack:nil error:error];
            break;
        case DeviceOpenEleDoor:
            NSLog(@"开电门");
            [[WYDeviceServices shareInstance] sendHexstring:[ConverUtil stringToByte:@"A5000007200103"] callBack:nil error:error];
            break;
        case DeviceCloseEleDoor:
            NSLog(@"关电门");
            [[WYDeviceServices shareInstance] sendHexstring:[ConverUtil stringToByte:@"A5000007200104"] callBack:nil error:error];
            break;
            
        case DeviceOpenTirePressureAlarm:
            NSLog(@"打开胎压");
            [[WYDeviceServices shareInstance] sendHexstring:[ConverUtil stringToByte:@"A500000720010B"] callBack:nil error:error];
            break;
        case DeviceCloseTirePressureAlarm:
            NSLog(@"关闭胎压");
            [[WYDeviceServices shareInstance] sendHexstring:[ConverUtil stringToByte:@"A500000720010C"] callBack:nil error:error];
            break;
        case DeviceInductionSetSafe:
            NSLog(@"感应设防");
            [[WYDeviceServices shareInstance] sendHexstring:[ConverUtil stringToByte:@"A500000720010A"] callBack:nil error:error];
            break;
        case DeviceInductionOutSafe:
            NSLog(@"感应撤防");
            [[WYDeviceServices shareInstance] sendHexstring:[ConverUtil stringToByte:@"A5000007200109"] callBack:nil error:error];
        break;
        default:
            break;
    }
}

-(void)quiteNomalKeyConfiguration:(void (^)(CommandStatus code))error{
    
    [[WYDeviceServices shareInstance] sendHexstring:[ConverUtil stringToByte:@"A5000007100300"] callBack:nil error:error];
    [WYDeviceServices shareInstance].keyvalue = nil;
    [WYDeviceServices shareInstance].key1 = nil;
    [WYDeviceServices shareInstance].key2 = nil;
    [WYDeviceServices shareInstance].key3 = nil;
    [WYDeviceServices shareInstance].key4 = nil;
    [WYDeviceServices shareInstance].step = 0;
    [WYDeviceServices shareInstance].seq = 0;
}

-(void)readingVehicleInformation:(NSInteger)num data:(void (^)(id data))data error:(void (^ _Nullable)(CommandStatus status))error{
    
    [[WYDeviceServices shareInstance] sendHexstring:[ConverUtil stringToByte:@"A50000061006"] callBack:data error:error];
}

-(void)addNomalKeyConfiguration:(NSInteger)seq hardwareNum:(NSInteger)hardwareNum steps:(void (^)(ConfigurationSteps step))step error:(void (^)(CommandStatus status))error{
    
    [[WYDeviceServices shareInstance] sendHexstring:[ConverUtil stringToByte:@"A5000007100301"] callBack:nil error:error];
}

-(void)deleteNomalKeyConfiguration:(NSInteger)seq error:(void (^_Nullable)(CommandStatus status))error{
    
    [[WYDeviceServices shareInstance] sendHexstring:[ConverUtil stringToByte:[@"A500001730010" stringByAppendingFormat:@"%ld%@%@%@%@",(long)seq, @"FFFFFFFF", @"FFFFFFFF", @"FFFFFFFF", @"FFFFFFFF"]] callBack:nil error:NULL];
}

-(void)addInductionKey:(NSInteger)seq mac:(NSString *)Mac data:(void (^)(id data))data error:(void (^_Nullable)(CommandStatus status))error{
    
    [[WYDeviceServices shareInstance] sendHexstring:[ConverUtil stringToByte:[NSString stringWithFormat:@"A500000E3002011%ld%@",(long)seq,Mac]] callBack:data error:error];
}

-(void)deleteInductionKey:(NSInteger)seq mac:(NSString *)Mac data:(void (^)(id data))data error:(void (^_Nullable)(CommandStatus status))error{
    
    [[WYDeviceServices shareInstance] sendHexstring:[ConverUtil stringToByte:[NSString stringWithFormat:@"A500000E3002010%ld%@",(long)seq,Mac]] callBack:data error:error];
}


-(void)addBLEKey:(NSInteger)seq data:(void (^)(id data))data error:(void (^_Nullable)(CommandStatus status))error{
    
    [[WYDeviceServices shareInstance] sendHexstring:[ConverUtil stringToByte:[NSString stringWithFormat:@"A50000081007010%ld",(long)seq]] callBack:data error:error];
}

-(void)deleteBLEKey:(NSInteger)seq data:(void (^)(id data))data error:(void (^_Nullable)(CommandStatus status))error{
    
    [[WYDeviceServices shareInstance] sendHexstring:[ConverUtil stringToByte:[NSString stringWithFormat:@"A50000081007000%ld",(long)seq]] callBack:data error:error];
}

-(void)quiteBLEKeyConfiguration:(NSInteger)seq data:(void (^_Nonnull)(id data))data error:(void (^_Nullable)(CommandStatus status))error{
    if (error) {
        error(NotSupport);
    }
}

-(void)addTirePressure:(NSInteger)seq mac:(NSString *)Mac data:(void (^_Nonnull)(id data))data error:(void (^_Nullable)(CommandStatus status))error{
    
    [[WYDeviceServices shareInstance] sendHexstring:[ConverUtil stringToByte:[NSString stringWithFormat:@"A500000C3007010%ld%@",(long)seq,Mac]] callBack:data error:error];
}

-(void)deleteTirePressure:(NSInteger)seq mac:(NSString *)Mac data:(void (^_Nonnull)(id data))data error:(void (^_Nullable)(CommandStatus status))error{
    
    [[WYDeviceServices shareInstance] sendHexstring:[ConverUtil stringToByte:[NSString stringWithFormat:@"A500000C3007000%ld%@",(long)seq,Mac]] callBack:data error:error];
}

-(void)addFingerPrint:(NSInteger)num fingerPrintType:(NSInteger)fingerPrintType status:(void (^_Nullable)(FingerPrintStatus status))status error:(void (^_Nullable)(CommandStatus status))error{
    NSString *_fingerPrintTypeStr;
    if (fingerPrintType == 3) {
        _fingerPrintTypeStr = @"3004";
    }else{
        _fingerPrintTypeStr = @"3008";
    }
    
    [self deleteFingerPrint:num data:^(id _Nonnull data) {
        
        if ([data intValue] == ConfigurationSuccess) {
            
            NSString *HEX;
            if (num >= 10) {
                HEX = [NSString stringWithFormat:@"A5000007%@0A",_fingerPrintTypeStr];
            }else{
                HEX = [NSString stringWithFormat:@"A5000007%@0%ld",_fingerPrintTypeStr,(long)num];
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
        HEX = [NSString stringWithFormat:@"A500000730050A"];
    }else{
        HEX = [NSString stringWithFormat:@"A500000730050%ld",(long)num];
    }
    [[WYDeviceServices shareInstance] sendHexstring:[ConverUtil stringToByte:HEX] callBack:data error:error];
}

-(void)quiteFingerPrint:(NSInteger)num fingerPrintType:(NSInteger)fingerPrintType error:(void (^ _Nullable)(CommandStatus status))error{
    NSString *HEX;
    if (fingerPrintType == 3) {
        HEX = @"A50000073004FF";
    }else{
        HEX = @"A50000073008FF";
    }
    [[WYDeviceServices shareInstance] sendHexstring:[ConverUtil stringToByte:HEX] callBack:nil error:error];
    [WYDeviceServices shareInstance].fingerPressNum = 0;
    [WYDeviceServices shareInstance].pressSecond = 0;
    [WYDeviceServices shareInstance].startTime = 0;
    
}

-(void)setDeviceSpeedingAlarmStatus:(SwitchStatus)status error:(void (^_Nullable)(CommandStatus status))error{
    [[WYDeviceServices shareInstance] sendHexstring:[ConverUtil stringToByte:[NSString stringWithFormat:@"A500000720040%ld",(long)status]] callBack:nil error:error];
}

-(void)getDeviceAutomaticLockStatus:(BOOL)status automaticLockBlock:(void (^)(BOOL automaticLock))data error:(void (^_Nullable)(CommandStatus status))error{
    
    [[WYDeviceServices shareInstance] sendHexstring:[ConverUtil stringToByte:@"A5000007300302"] callBack:nil error:error];
}

-(void)setDeviceAutomaticLockStatus:(SwitchStatus)status data:(void (^)(BOOL automaticLock))data error:(void (^_Nullable)(CommandStatus status))error{
    [[WYDeviceServices shareInstance] sendHexstring:[ConverUtil stringToByte:[NSString stringWithFormat:@"A500000730030%ld",(long)status]] callBack:nil error:error];
}

-(void)getDeviceSensingDistanceValue:(void (^)(NSInteger value))data error:(void (^_Nullable)(CommandStatus status))error{
    [[WYDeviceServices shareInstance] sendHexstring:[ConverUtil stringToByte:@"A5000007200300"] callBack:nil error:error];
}

-(void)setDeviceSensingDistanceValue:(NSInteger)value data:(void (^)(NSInteger value))data error:(void (^_Nullable)(CommandStatus status))error{
    
    [[WYDeviceServices shareInstance] sendHexstring:[ConverUtil stringToByte:[NSString stringWithFormat:@"A50000072003%@",[ConverUtil ToHex:value]]] callBack:nil error:error];
}

-(void)setDeviceShockStatus:(ShockState)status error:(void (^_Nullable)(CommandStatus status))error{
    
    [[WYDeviceServices shareInstance] sendHexstring:[ConverUtil stringToByte:[NSString stringWithFormat:@"A500000720020%ld",(long)status]] callBack:nil error:error];
    
}


-(void)bikePasswordConfiguration:(NSDictionary *)passwordDic data:(void (^)(id data))data error:(void (^_Nullable)(CommandStatus status))error{
    //_callbackdateblock = data;
    NSArray *child = passwordDic[@"children"];
    NSString *main = [ConverUtil ToHex:[passwordDic[@"main"] longLongValue]];
    NSString *childpwdone = [ConverUtil ToHex:[child[0] longLongValue]];
    NSString *childpwdtwo = [ConverUtil ToHex:[child[1] longLongValue]];
    NSString *childpwdthree = [ConverUtil ToHex:[child[2] longLongValue]];
    NSString *childpwdfour = [ConverUtil ToHex:[child[3] longLongValue]];
    NSString *childpwdfive = [ConverUtil ToHex:[child[4] longLongValue]];
    
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
    [[WYDeviceServices shareInstance] sendHexstring:[ConverUtil stringToByte:[@"A500001E5001" stringByAppendingFormat:@"%@%@%@%@%@%@",main, childpwdone,childpwdtwo,childpwdthree, childpwdfour,childpwdfive]] callBack:data error:error];
}

-(void)getDeviceSupportdata:(void (^)(DeviceConfigurationModel *model))data error:(void (^_Nullable)(CommandStatus status))error{
    
    [[WYDeviceServices shareInstance] sendHexstring:[ConverUtil stringToByte:@"A50000065002"] callBack:data error:error];
}



-(void)dealloc{
    [_queraTime invalidate];
    _queraTime = nil;
}

@end
