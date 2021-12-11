//
//  WYDeviceServices.m
//  myTest
//
//  Created by Apple on 2019/6/19.
//  Copyright © 2019 Apple. All rights reserved.
//

#import "WYDeviceServices.h"
#import "WYDeviceServices+DataAnalysis.h"
#import "WYDeviceServices+NewBLEProtocolDataAnalysis.h"
#import "Utility.h"
#import "DeviceConfigurationModel.h"
#import "BikeStatusModel.h"
#import "FaultModel.h"
#import "CommandModel.h"
#import "KVOModel.h"
#import "WYDevice.h"
#import "SearchBleModel.h"
#import <pthread.h>

pthread_mutex_t commandAddLock;

static inline void pthread_mutex_init_recursive(pthread_mutex_t *mutex, bool recursive) {
#define YYMUTEX_ASSERT_ON_ERROR(x_) do { \
__unused volatile int res = (x_); \
assert(res == 0); \
} while (0)
    assert(mutex != NULL);
    if (!recursive) {
        //普通锁
        YYMUTEX_ASSERT_ON_ERROR(pthread_mutex_init(mutex, NULL));
    } else {
        //递归锁
        pthread_mutexattr_t attr;
        YYMUTEX_ASSERT_ON_ERROR(pthread_mutexattr_init (&attr));
        YYMUTEX_ASSERT_ON_ERROR(pthread_mutexattr_settype (&attr, PTHREAD_MUTEX_RECURSIVE));
        YYMUTEX_ASSERT_ON_ERROR(pthread_mutex_init (mutex, &attr));
        YYMUTEX_ASSERT_ON_ERROR(pthread_mutexattr_destroy (&attr));
    }
#undef YYMUTEX_ASSERT_ON_ERROR
}

static WYDeviceServices *_singleInstance = nil;

typedef void(^centralManagerState)(BLEStatus status);

typedef void(^callBack)(DeviceConnectStatus status);

typedef void(^GPSConnectCallBack)(DeviceConnectStatus status);

typedef void(^configurationProcess)(ConfigurationSteps step);

typedef void(^fingerPrintProcess)(FingerPrintStatus step);

typedef void(^inquireBlock)(BikeStatusModel *model);

typedef void(^WaitingBackBlock)(id data);

typedef void(^bikeSetBlock)(BOOL status);

typedef void(^bikeInductionValue)(NSInteger value);

@interface WYDeviceServices ()<ScanDelegate,DeviceDelegate,removeDelegate>
@property (nonatomic,strong) WYDevice *device;
@property (nonatomic,copy) callBack callback;
@property (nonatomic,copy) centralManagerState managerBlock;
@property (nonatomic,copy) configurationProcess configurationprocess;
@property (nonatomic,copy) fingerPrintProcess fingerprintprocess;
@property (nonatomic,copy) inquireBlock inquireblock;
@property (nonatomic,copy) bikeSetBlock bikesetblock;
@property (nonatomic,copy) WaitingBackBlock waitingBackBlock;
@property (nonatomic,copy) bikeInductionValue bikeinductionvalue;
@property (nonatomic,strong) KVOModel *kvoModel;
@property (nonatomic,strong) BikeStatusModel *bikestatusModel;
@property (nonatomic,strong) DeviceConfigurationModel *deviceConfigurationModel;
@property (nonatomic,copy) NSString *fingerPrintTypeStr;
@property (nonatomic,strong) NSMutableDictionary* peripheralDic;
@property (nonatomic,strong) NSMutableArray* peripheralAry;
@property (nonatomic,copy) NSArray *localCommndList;//无应答指令列表
@property (nonatomic,copy) NSArray *GPSCommndList;//GPS指令列表
@end

@implementation WYDeviceServices

static BOOL isAuthentication;

-(KVOModel *)kvoModel{
    
    if (!_kvoModel) {
        _kvoModel = [[KVOModel alloc] init];
        _kvoModel.commandArray = [NSMutableArray array];
        _kvoModel.inquireCommandAry = [NSMutableArray array];
    }
    return _kvoModel;
}

-(BikeStatusModel *)bikestatusModel{
    
    if (!_bikestatusModel) {
        _bikestatusModel = [[BikeStatusModel alloc] init];
    }
    return _bikestatusModel;
}


-(NSMutableDictionary *)peripheralDic{
    if (!_peripheralDic) {
        _peripheralDic = [[NSMutableDictionary alloc] init];
    }
    return _peripheralDic;
}

-(NSMutableArray *)peripheralAry{
    if (!_peripheralAry) {
        _peripheralAry = [[NSMutableArray alloc] init];
    }
    return _peripheralAry;
}

-(NSArray *)localCommndList{
    if (!_localCommndList) {
        _localCommndList = [NSArray arrayWithObjects:@"1003",@"1007",@"2001",@"2002",@"2004",@"2021",@"3001",@"3004",@"3008", nil];
    }
    return _localCommndList;
}

-(NSArray *)GPSCommndList{
    if (!_GPSCommndList) {
        _GPSCommndList = [NSArray arrayWithObjects:@"3021",@"3054",@"3055",@"3057",@"3058", nil];
    }
    return _GPSCommndList;
}

-(instancetype)init{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pthread_mutex_init_recursive(&commandAddLock,YES);
        _device = [[WYDevice alloc]init];
        _device.scanDelete = self;
        _device.deviceDelegate = self;
    });
    return _singleInstance;
}

+(instancetype)shareInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (_singleInstance == nil) {
            _singleInstance = [[self alloc]init];
        }
    });
    return _singleInstance;
}

+(instancetype)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _singleInstance = [super allocWithZone:zone];
    });
    return _singleInstance;
}

-(id)copyWithZone:(NSZone *)zone{
    return _singleInstance;
}

-(id)mutableCopyWithZone:(NSZone *)zone {
    return _singleInstance;
}



-(CBCentralManager *)restoreCentralManager:(NSString *)identifier{
    _device = [_device initWithRestoreIdentifier:identifier];
    return _device.centralManager;
}

-(CBCentralManager *)getCentralManager{
    return _device.centralManager;
}

-(void)restCentralManagerStatus{
    _device.centralManager.delegate = _device;
}

-(BOOL)isConnect{
    return _device.isConnected? YES:NO;
}

-(void)monitorBLEStatus:(void (^_Nonnull)(BLEStatus status))managerBlock{
    _managerBlock = managerBlock;
}

-(void)startScan:(DeviceScanType)type{
    _scanType = type;
    [self.peripheralDic removeAllObjects];
    [self.peripheralAry removeAllObjects];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        if (type == DeviceNomalType) {
            [_device startScan];
        }else if (type == DeviceBingDingType){
            [_device startBackstageScan];
        }else{
            [_device startScan];
        }
    });
}

-(void)stopScan{
    [self.peripheralAry removeAllObjects];
    [self.peripheralDic removeAllObjects];
    [_device stopScan];
}

-(void)connectPeripheral:(CBPeripheral *)peripheral{
    NSLog(@"设备连接的%@",peripheral.identifier.UUIDString);
    _device.peripheral = peripheral;
    [_device connect];
}

-(void)connectPeripheralByUUIDString:(NSString *__nullable)UUIDSting{
    NSLog(@"UUID连接的设备%@",UUIDSting);
    [_device retrievePeripheralWithUUID:UUIDSting];//导入外设 根据UUID
    [_device connect];
}

-(void)connectGPSByMac:(NSString *_Nonnull)mac  data:(void (^_Nonnull)(id data))data error:(void (^_Nullable)(CommandStatus status))error{
    [_device.commndServices connectGPSByMac:mac data:data error:error];
}

-(void)queryVehicleStatusOnce:(void (^_Nonnull)(BikeStatusModel *model))data error:(void (^_Nullable)(CommandStatus status))error{
    [_device.commndServices queryVehicleStatusOnce:data error:error];
}

-(void)sendPasswordCommend:(NSString *)password data:(void (^)(id data))data error:(void (^_Nullable)(CommandStatus status))error{
    
    [_device.commndServices sendPasswordCommend:password data:data error:error];
}
//gps鉴权
-(void)GPSAuthentication:(NSString *)authenticationCode data:(void (^_Nonnull)(id data))data error:(void (^_Nullable)(CommandStatus status))error{
    
    if (!_device.GPSCommndServices) {
        if (error) error(NotSupport);
        return;
    }
    [_device.GPSCommndServices GPSAuthentication:authenticationCode data:data error:error];
}

-(BOOL)getGPSAuthenticationStatus{
    
    if (!_device.GPSCommndServices) {
        return NO;
    }
    return isAuthentication;
}

//gps查询激活状态
-(void)QueryGPSActivationStatus:(GPSOperationMode)mode  data:(void (^_Nonnull)(id data))data error:(void (^_Nullable)(CommandStatus status))error{
    if (!_device.GPSCommndServices) {
        if (error) error(NotSupport);
        return;
    }
    [_device.GPSCommndServices QueryGPSActivationStatus:mode data:data error:error];
}
//gps设置工作模式
-(void)SetGPSWorkingMode:(GPSWorkingMode)mode data:(void (^_Nonnull)(id data))data error:(void (^_Nullable)(CommandStatus status))error{
    if (!_device.GPSCommndServices) {
        if (error) error(NotSupport);
        return;
    }
    [_device.GPSCommndServices SetGPSWorkingMode:mode data:data error:error];
}

//gps激活
-(void)sendSingleGPSActivationCommend:(SwitchStatus)behavior data:(void (^_Nonnull)(id data))data error:(void (^_Nullable)(CommandStatus status))error{
    if (!_device.GPSCommndServices) {
        if (error) error(NotSupport);
        return;
    }
    [_device.GPSCommndServices sendSingleGPSActivationCommend:behavior data:data error:error];
}

-(void)getSatelliteDataCommend:(void (^_Nonnull)(id data))data error:(void (^_Nullable)(CommandStatus status))error{
    if (!_device.GPSCommndServices) {
        if (error) error(NotSupport);
        return;
    }
    [_device.GPSCommndServices getSatelliteDataCommend:data error:error];
}

-(void)getGPSGSMSignalValue:(void (^_Nonnull)(id data))data error:(void (^_Nullable)(CommandStatus status))error{
    if (!_device.GPSCommndServices) {
        if (error) error(NotSupport);
        return;
    }
    [_device.GPSCommndServices getGPSGSMSignalValue:data error:error];
}

-(void)setGPSReset:(void (^_Nullable)(CommandStatus status))error{
    if (!_device.GPSCommndServices) {
        if (error) error(NotSupport);
        return;
    }
    [_device.GPSCommndServices setGPSReset:error];
}

-(void)enterFirmwareUpgrade:(void (^)(id data))data error:(void (^)(CommandStatus status))error{
    
    [_device.commndServices enterFirmwareUpgrade:data error:error];
}

-(void)querykeyVersionNumber:(void (^)(NSString *data))data error:(void (^)(CommandStatus status))error{
    
    [_device.commndServices querykeyVersionNumber:data error:error];
}

-(void)removePeripheral:(CBPeripheral *)peripheral{
    
    [_device remove];
}


-(void)monitorConnectStatus:(void (^)(DeviceConnectStatus status))callback{
    
    self.callback = callback;
}

-(void)setBikeBasicStatues:(NomalCommand)commandType error:(void (^_Nullable)(CommandStatus status))error{
    
    [_device.commndServices setBikeBasicStatues:commandType error:error];
}


-(void)getBikeBasicStatues:(TimeNum)time data:(void (^)(BikeStatusModel *model))data{
    _inquireblock = data;
}


-(void)quiteNomalKeyConfiguration:(void (^)(CommandStatus code))error{
    
    [_device.commndServices quiteNomalKeyConfiguration:error];
}

-(void)readingVehicleInformation:(void (^)(id data))data error:(void (^ _Nullable)(CommandStatus status))error{
    
    [_device.commndServices readingVehicleInformation:_deviceConfigurationModel.numberOfWheels data:data error:error];
}

-(void)addNomalKeyConfiguration:(NSInteger)seq hardwareNum:(NSInteger)hardwareNum steps:(void (^)(ConfigurationSteps step))step error:(void (^)(CommandStatus status))error{
    _seq = seq;
    _hardwareNum = hardwareNum;
    _configurationprocess = step;
    [_device.commndServices addNomalKeyConfiguration:seq hardwareNum:hardwareNum steps:step error:error];
}

-(void)deleteNomalKeyConfiguration:(NSInteger)seq error:(void (^_Nullable)(CommandStatus status))error{
    
    [_device.commndServices deleteNomalKeyConfiguration:seq error:error];
}


-(void)addInductionKey:(NSInteger)seq mac:(NSString *)Mac data:(void (^)(id data))data error:(void (^_Nullable)(CommandStatus status))error{
    
    [_device.commndServices addInductionKey:seq mac:Mac data:data error:error];
}

-(void)deleteInductionKey:(NSInteger)seq mac:(NSString *)Mac data:(void (^)(id data))data error:(void (^_Nullable)(CommandStatus status))error{
    
    [_device.commndServices deleteInductionKey:seq mac:Mac data:data error:error];
}


-(void)addBLEKey:(NSInteger)seq data:(void (^)(id data))data error:(void (^_Nullable)(CommandStatus status))error{
    _waitingBackBlock = data;
    [_device.commndServices addBLEKey:seq data:nil error:error];
}

-(void)deleteBLEKey:(NSInteger)seq data:(void (^)(id data))data error:(void (^_Nullable)(CommandStatus status))error{
    _waitingBackBlock = data;
    [_device.commndServices deleteBLEKey:seq data:data error:error];
}

-(void)quiteBLEKeyConfiguration:(NSInteger)seq data:(void (^_Nonnull)(id data))data error:(void (^_Nullable)(CommandStatus status))error{
    [_device.commndServices quiteBLEKeyConfiguration:seq data:data error:error];
}

-(void)addTirePressure:(NSInteger)seq mac:(NSString *)Mac data:(void (^_Nonnull)(id data))data error:(void (^_Nullable)(CommandStatus status))error{
    
    [_device.commndServices addTirePressure:seq mac:Mac data:data error:error];
}

-(void)deleteTirePressure:(NSInteger)seq mac:(NSString *)Mac data:(void (^_Nonnull)(id data))data error:(void (^_Nullable)(CommandStatus status))error{
    
    [_device.commndServices deleteTirePressure:seq mac:Mac data:data error:error];
}

-(void)addFingerPrint:(NSInteger)num fingerPrintType:(NSInteger)fingerPrintType status:(void (^_Nullable)(FingerPrintStatus status))status error:(void (^_Nullable)(CommandStatus status))error{
    _fingerprintprocess = status;
    if (fingerPrintType == 3) {
        _fingerPrintTypeStr = @"3004";
    }else{
        _fingerPrintTypeStr = @"3008";
    }
    
    [_device.commndServices addFingerPrint:num fingerPrintType:fingerPrintType status:status error:error];
}

-(void)deleteFingerPrint:(NSInteger)num data:(void (^)(id data))data error:(void (^_Nullable)(CommandStatus status))error{
    
    [_device.commndServices deleteFingerPrint:num data:data error:error];
}

-(void)quiteFingerPrint:(NSInteger)num fingerPrintType:(NSInteger)fingerPrintType error:(void (^ _Nullable)(CommandStatus status))error{
    [_device.commndServices quiteFingerPrint:num fingerPrintType:fingerPrintType error:error];
}

-(void)getDeviceSpeedingAlarmStatus:(void (^)(BOOL speedingAlarm))data{
    
    if (data) {
        data(self.bikestatusModel.speedingAlarm);
    }
}

-(void)setDeviceSpeedingAlarmStatus:(SwitchStatus)status error:(void (^_Nullable)(CommandStatus status))error{
    [_device.commndServices setDeviceSpeedingAlarmStatus:status error:error];
}

-(void)getDeviceAutomaticLockStatus:(void (^)(BOOL automaticLock))data error:(void (^_Nullable)(CommandStatus status))error{
    
    _bikesetblock = data;
    [_device.commndServices getDeviceAutomaticLockStatus:self.bikestatusModel.automaticLock automaticLockBlock:data error:error];
}

-(void)setDeviceAutomaticLockStatus:(SwitchStatus)status data:(void (^)(BOOL automaticLock))data error:(void (^_Nullable)(CommandStatus status))error{
    
    _bikesetblock = data;
    [_device.commndServices setDeviceAutomaticLockStatus:status data:data error:error];
}

-(void)getDeviceSensingDistanceValue:(void (^)(NSInteger value))data error:(void (^_Nullable)(CommandStatus status))error{
    _bikeinductionvalue = data;
    [_device.commndServices getDeviceSensingDistanceValue:data error:error];
}

-(void)setDeviceSensingDistanceValue:(NSInteger)value data:(void (^)(NSInteger value))data error:(void (^_Nullable)(CommandStatus status))error{
    _bikeinductionvalue = data;
    [_device.commndServices setDeviceSensingDistanceValue:value data:data error:error];
}

-(void)setDeviceShockStatus:(ShockState)status error:(void (^_Nullable)(CommandStatus status))error{
    
    [_device.commndServices setDeviceShockStatus:status error:error];
}

-(void)getDeviceShockStatus:(void (^)(ShockState))data{
    if (data) {
        data(self.bikestatusModel.shockState);
    }
}

-(void)bikePasswordConfiguration:(NSDictionary *)passwordDic data:(void (^)(id data))data error:(void (^_Nullable)(CommandStatus status))error{
    [_device.commndServices bikePasswordConfiguration:passwordDic data:data error:error];
}

-(void)getDeviceSupportdata:(void (^)(DeviceConfigurationModel *model))data error:(void (^_Nullable)(CommandStatus status))error{
    [_device.commndServices getDeviceSupportdata:data error:error];
}

-(void)getDeviceFirmwareRevisionString:(void (^)(NSString *revision))firmwareStr error:(void (^_Nullable)(CommandStatus status))error{
    [self sendHexstring:[ConverUtil stringToByte:@"A50000062A26"] callBack:firmwareStr error:error];
}

-(void)getDeviceHardwareRevisionString:(void (^)(NSString *revision))hardwareStr error:(void (^_Nullable)(CommandStatus status))error{
    [self sendHexstring:[ConverUtil stringToByte:@"A50000062A27"] callBack:hardwareStr error:error];
}

#pragma mark---主页车辆扫描的回调
-(void)didDiscoverPeripheral:(NSInteger)tag :(CBPeripheral *)peripheral scanData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    
    if (_scanType == DeviceNomalType) {
        if(![peripheral.name isEqualToString: @"Qgj-SmartBike"]) return;
        NSString *title = [ConverUtil data2HexString:[advertisementData objectForKey:@"kCBAdvDataManufacturerData"]];
        if (title == NULL) {
            return;
        }else if (title.length < 16) {
            return;
        }
        if (![title hasPrefix: @"0000A501"]) {

            NSString *mac = [title substringWithRange:NSMakeRange(4, 12)];
            if(![self.peripheralDic objectForKey:mac]){
                SearchBleModel *model=[[SearchBleModel alloc]init];
                model.peripher=peripheral;
                model.rssi = RSSI;
                model.titlename = peripheral.name;
                model.mac = mac;
                [self.peripheralDic setObject:model forKey:mac];
                [self.peripheralAry addObject:model];
            }
        }
    }else if (_scanType == DeviceBingDingType) {
        
        NSString *title = [ConverUtil data2HexString:[advertisementData objectForKey:@"kCBAdvDataManufacturerData"]];
        if (title == NULL) {
            return;
        }else if (title.length < 16) {
            return;
        }
        if ([title hasPrefix:@"0000A501"]) {
            
            NSString *mac = [title substringWithRange:NSMakeRange(8, 12)];
            if(![self.peripheralDic objectForKey:mac]){
                
                SearchBleModel *model= [[SearchBleModel alloc] initWithType:DeviceBingDingType];
                model.delegate = self;
                model.peripher=peripheral;
                model.rssi = RSSI;
                model.titlename = peripheral.name;
                model.mac = mac;
                [self.peripheralDic setObject:model forKey:mac];
                [self.peripheralAry addObject:model];
            }else{
                
                SearchBleModel *model = [self.peripheralDic objectForKey:mac];
                model.searchCount = 1;
                if (RSSI.intValue >0 ) {
                    model.rssi = [NSNumber numberWithInt:-64];;
                }else{
                    model.rssi = RSSI;
                }
            }
            
        }else{
            NSString *mac = [title substringWithRange:NSMakeRange(4, 12)];
            if([self.peripheralDic objectForKey:mac]){
                
                [self.peripheralAry removeObject:[self.peripheralDic objectForKey:mac]];
                [self.peripheralDic removeObjectForKey:mac];
            }
        }
    }else if (_scanType == DeviceDFUType){
        if (peripheral.name.length == 7) {
            if([peripheral.name isEqualToString: @"Qgj-Ota"]){
                
                NSString *mac = peripheral.identifier.UUIDString;
                if(![self.peripheralDic objectForKey:mac]){
                    SearchBleModel *model=[[SearchBleModel alloc]init];
                    model.peripher=peripheral;
                    model.rssi = RSSI;
                    model.titlename = peripheral.name;
                    model.mac = mac;
                    [self.peripheralDic setObject:model forKey:mac];
                    [self.peripheralAry addObject:model];
                }
            }
        
        }else if (peripheral.name.length == 11){
            
            if([peripheral.name isEqualToString: @"Qgj-DfuTarg"]){
                
                NSString *mac = peripheral.identifier.UUIDString;
                if(![self.peripheralDic objectForKey:mac]){
                    SearchBleModel *model=[[SearchBleModel alloc]init];
                    model.peripher=peripheral;
                    model.rssi = RSSI;
                    model.titlename = peripheral.name;
                    model.mac = mac;
                    [self.peripheralDic setObject:model forKey:mac];
                    [self.peripheralAry addObject:model];
                }
                
                
            }
        }else if (peripheral.name.length == 8){
            
            NSString *mac = peripheral.identifier.UUIDString;
            if(![self.peripheralDic objectForKey:mac]){
                SearchBleModel *model=[[SearchBleModel alloc]init];
                model.peripher=peripheral;
                model.rssi = RSSI;
                model.titlename = peripheral.name;
                model.mac = mac;
                [self.peripheralDic setObject:model forKey:mac];
                [self.peripheralAry addObject:model];
            }
        }
    }else if (_scanType == DeviceGPSType){
        
        if([peripheral.name containsString: @"QGJ-GPSBLE"]){
            NSString *mac = [ConverUtil data2HexString:[advertisementData objectForKey:@"kCBAdvDataManufacturerData"]];
            if (mac == NULL) {
                return;
            }else if (mac.length < 12) {
                return;
            }
            if(![self.peripheralDic objectForKey:mac]){
                SearchBleModel *model=[[SearchBleModel alloc]init];
                model.peripher=peripheral;
                model.rssi = RSSI;
                model.titlename = peripheral.name;
                model.mac = mac;
                [self.peripheralDic setObject:model forKey:mac];
                [self.peripheralAry addObject:model];
            }
        }
        
    }
    if (self.scanBlock) {
        self.scanBlock([self.peripheralAry mutableCopy]);
    }
}

-(void)WYCentralManagerDidUpdateState:(CBManagerState)state{
    
    switch (state) {
        case CBManagerStateUnknown:
            if (_managerBlock) {
                _managerBlock(StateUnknown);
            }
            break;
        case CBManagerStateResetting:
            if (_managerBlock) {
                _managerBlock(StateResetting);
            }
            break;
        case CBManagerStateUnsupported:
            if (_managerBlock) {
                _managerBlock(StateUnsupported);
            }
            break;
        case CBManagerStateUnauthorized:
            if (_managerBlock) {
                _managerBlock(StateUnauthorized);
            }
            break;
        case CBManagerStatePoweredOff:
            if (_managerBlock) {
                _managerBlock(StatePoweredOff);
            }
            break;
        case CBManagerStatePoweredOn:
            if (_managerBlock) {
                _managerBlock(StatePoweredOn);
            }
            break;
        default:
            break;
    }
}

#pragma mark - 蓝牙连接回调

- (void)didConnect:(NSInteger)tag :(CBPeripheral *)peripheral{
    [self.kvoModel.commandArray removeAllObjects];
    [self.kvoModel.inquireCommandAry removeAllObjects];
    isAuthentication = NO;
    if (self.callback) {
        self.callback(DeviceConnect);
        [[WYDeviceServices shareInstance] monitorConnectStatus:self.callback];
    }
    [_device.commndServices didConnect:tag :peripheral];
}

- (void)didDisconnect:(NSInteger)tag :(CBPeripheral *)peripheral{
    
    if (self.kvoModel.commandArray.count > 0) {
        NSLog(@"断开连接，直接返回异步错误");
        
        [[self.kvoModel.commandArray mutableCopy] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            CommandModel *model = obj;
            [model stopMonitorTime];
            if (model.error) model.error(SendFail);
            [self.kvoModel.commandArray removeObject:obj];
        }];
        
//        CommandModel *model = self.kvoModel.commandArray.firstObject;
//        [model stopMonitorTime];
//        if (model.error) model.error(SendFail);
//        [self.kvoModel.commandArray removeAllObjects];
    }
    [self.kvoModel.inquireCommandAry removeAllObjects];
    
    isAuthentication = NO;
    if (self.callback) {
        self.callback(DeviceDisconnect);
        [[WYDeviceServices shareInstance] monitorConnectStatus:self.callback];
    }
    [_device.commndServices didDisconnect:tag :peripheral];
}

-(void)sendHexstring:(NSData *)data callBack:(void (^)(id response))backdata error:(void (^)(CommandStatus code))error{
    if(_device.peripheral.state != CBPeripheralStateConnected){
        if (error) {
            error(SendFail);
        }
        return;
    }else if (data == nil){
        NSLog(@"data为空值");
        if (error) {
            error(SendFail);
        }
        return;
    }
    pthread_mutex_lock(&commandAddLock);
    NSMutableArray *arry = [[NSMutableArray alloc] init];
    CommandModel *model = [[CommandModel alloc] init];
    @weakify(self);
    model.timeFire = ^(CommandModel * model2){
        @strongify(self);
        
        if ([model2.data isEqual:[ConverUtil stringToByte:@"a50000061001"]] || [model2.data isEqual:[ConverUtil stringToByte:@"a60000061011"]]) {
            [self.kvoModel.inquireCommandAry removeObject:model2];
        }else{
            [self.kvoModel.commandArray removeObject:model2];
        }
        [self nextCommentStep];
    };
    
    backdata? (model.backdata = backdata) : (model.backdata = nil);
    model.data = data;
    model.error = error;
    if ([self.localCommndList containsObject:[[ConverUtil data2HexString:data] substringWithRange:NSMakeRange(8, 4)]]) {
        model.noNeedRSP = YES;
    }
    if ([data isEqual:[ConverUtil stringToByte:@"A60000083055FF00"]]){
        model.noNeedRSP = YES;
    }
    
    BOOL sendGPS = [self.GPSCommndList containsObject:[[ConverUtil data2HexString:data] substringWithRange:NSMakeRange(8, 4)]]? YES:NO;
    NSInteger intDatalength = data.length/20;
    
    if (data.length > 20) {
        
        for (int i = 0; i < intDatalength; i++) {
            
            NSData *data01 = [data subdataWithRange:NSMakeRange(i * 20, 20)];
            SingerPacketCommandModel * model = [[SingerPacketCommandModel alloc] init];
            model.commndData = data01;
            model.sendGPS = sendGPS;
            [arry addObject:model];
        }
        
        if (data.length%20 > 0) {
            
            NSData *data02 =  [data subdataWithRange:NSMakeRange(intDatalength * 20,data.length - intDatalength * 20)];
            SingerPacketCommandModel * model = [[SingerPacketCommandModel alloc] init];
            model.commndData = data02;
            model.sendGPS = sendGPS;
            [arry addObject:model];
        }
        model.commandAry = arry;
        
    }else{
        
        SingerPacketCommandModel * packetModel = [[SingerPacketCommandModel alloc] init];
        packetModel.commndData = data;
        packetModel.sendGPS = sendGPS;
        [arry addObject:packetModel];
        model.commandAry = arry;
        
    }
    if ([data isEqual:[ConverUtil stringToByte:@"a50000061001"]] || [data isEqual:[ConverUtil stringToByte:@"a60000061011"]]) {

        if (self.kvoModel.inquireCommandAry.count >= 5) {
            [self.kvoModel.inquireCommandAry removeLastObject];
        }
        [self.kvoModel.inquireCommandAry addObject:model];
    }else{
        
        if (self.kvoModel.commandArray.count >= 5) {
            
            if (error) {
                error(SendFrequently);
            }
            pthread_mutex_unlock(&commandAddLock);
            return;
        }
        [self.kvoModel.commandArray addObject:model];
    }
    
    if (self.kvoModel.commandArray.count + self.kvoModel.inquireCommandAry.count == 1) {
        
        if (self.kvoModel.commandArray.count == 1) {
            model = [self.kvoModel.commandArray firstObject];
            [model startMonitorTime];
            if ([data isEqual:[ConverUtil stringToByte:@"a50000062A26"]]) {
                NSLog(@"发送固件版本获取指令a50000062A26");
                [_device readFirmwareDiviceVersion];
            }else if ([data isEqual:[ConverUtil stringToByte:@"a50000062A27"]]){
                NSLog(@"发送硬件版本获取指令a50000062A27");
                [_device readDiviceHardwareVersion];
            }else {
                [_device sendKeyValue:[model.commandAry firstObject]];
            }
        }else{
            model = [self.kvoModel.inquireCommandAry firstObject];
            [model startMonitorTime];
            [_device sendKeyValue:[model.commandAry firstObject]];
        }
    }
    pthread_mutex_unlock(&commandAddLock);
}

-(void)didWriteValueForCharacteristic:(NSInteger)tag :(CBPeripheral *)peripheral :(CBCharacteristic *)characteristic :(NSError *)error{
    if (error) {
        NSLog(@"didWriteValueForCharacteristic error：%@",[error localizedDescription]);
    }
    
    if (![[ConverUtil data2HexString:_device.commndData] isEqualToString:@"A50000061001"] && ![[ConverUtil data2HexString:_device.commndData] isEqualToString:@"A60000061011"]) {
        
        CommandModel *model = [self.kvoModel.commandArray firstObject];
        if (error) {
            if (model.error) {
                model.error(SendFail);
            }
            [model stopMonitorTime];
            [self.kvoModel.commandArray removeObject:model];
            [self nextCommentStep];
        }else if (model.noNeedRSP){
            
            [model.commandAry removeObjectAtIndex:0];
            if (model.commandAry.count > 0) {
                [_device sendKeyValue:[model.commandAry firstObject]];
                return;
            }else{
                if (model.error) {
                    model.error(SendSuccess);
                }
                [model stopMonitorTime];
                [self.kvoModel.commandArray removeObject:model];
                [self nextCommentStep];
            }
        }else if(model.commandAry.count > 1){
            [model.commandAry removeObjectAtIndex:0];
            if (model.commandAry.count > 0) {
                [_device sendKeyValue:[model.commandAry firstObject]];
            }
        }
        
    }else{
        CommandModel *model = [self.kvoModel.inquireCommandAry firstObject];
        if (error) {
            if (model.error) {
                model.error(SendFail);
            }
            [model stopMonitorTime];
            [self.kvoModel.inquireCommandAry removeObject:model];
            [self nextCommentStep];
        }
    }
}

-(void)nextCommentStep{
    
    if (self.kvoModel.commandArray.count > 0 ) {
        
        CommandModel *model = [self.kvoModel.commandArray firstObject];
        [model startMonitorTime];
        if ([model.data isEqual:[ConverUtil stringToByte:@"a50000062A26"]]) {
            NSLog(@"发送固件版本获取指令a50000062A26");
            [_device readFirmwareDiviceVersion];
        }else if ([model.data isEqual:[ConverUtil stringToByte:@"a50000062A27"]]){
            NSLog(@"发送硬件版本获取指令a50000062A27");
            [_device readDiviceHardwareVersion];
        }else {
            [_device sendKeyValue:[model.commandAry firstObject]];
        }
        
    }else if (self.kvoModel.inquireCommandAry.count > 0){
        
        CommandModel *model = [self.kvoModel.inquireCommandAry firstObject];
        [model startMonitorTime];
        [_device sendKeyValue:[model.commandAry firstObject]];
    }else{
        //NSLog(@"没数据了");
    }
}

/**
 接收到了数据1.0 蓝牙协议indication

 @param tag 当前蓝牙标记
 @param data 数据返回
 @param peripheral 连接的设备
 */
- (void)didGetIndicateData:(NSInteger)tag :(NSData *)data :(CBPeripheral *)peripheral{
    
    NSString *date = [ConverUtil data2HexString:data];
    if ([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"1001"]){
        
        CommandModel *model = [self.kvoModel.inquireCommandAry firstObject];
        [self analysisBikestatus:self.bikestatusModel :date];
        
        if (_inquireblock) {
            _inquireblock(self.bikestatusModel);
        }
        
        if (model.backdata) {
            model.backdata(self.bikestatusModel);
        }
        
        if (model.error) {
            model.error(SendSuccess);
        }
        [model stopMonitorTime];
        [self.kvoModel.inquireCommandAry removeObject:model];
        [self nextCommentStep];
        
    }else if ([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"1002"]) {
        
        if ([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"00"]) {
            [self resetCommandTable:0 data: @"1"];
        }else{
            [self resetCommandTable:0 data:@"0"];
        }
    }else if ([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"1003"]) {
        
        [self analysisAddNomalKey:_hardwareNum data:date steps:_configurationprocess];
    }else if ([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"1004"]) {
        
        if ([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"00"]) {
            [self resetCommandTable:0 data:@1];
        }else{
            [self resetCommandTable:0 data:@0];
        }
    }else if ([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"1005"]) {
        
        [self resetCommandTable:0 data:[date substringWithRange:NSMakeRange(13, 1)]];
    }else if ([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"1006"]) {
        [self resetCommandTable:0 data:[self analysisVehicleInformationReading:date]];
    }else if ([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"1007"]) {
        
        if ([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"00"]) {
            if (_waitingBackBlock) {
                _waitingBackBlock(@1);
            }
        }else{
            if (_waitingBackBlock) {
                _waitingBackBlock(@0);
            }
        }
        [self resetCommandTable:0 data:date];
    }else if ([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"1010"]) {
        if ([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"00"]) {
            [self resetCommandTable:0 data:@1];
        }else{
            [self resetCommandTable:0 data:@0];
        }
        
    }else if ([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"2003"]) {
        
        [self analysisDeviceInductionValue:date callBack:_bikeinductionvalue];
        [self resetCommandTable:0 data:[date substringWithRange:NSMakeRange(12, 2)]];
    }else if ([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:_fingerPrintTypeStr]) {
        // 3004   3008
        NSLog(@"指纹配置返回%@",date);
        [self analysisAddFingerPrint:date status:_fingerprintprocess];
        //[self resetCommandTable:[date substringWithRange:NSMakeRange(12, 2)]];
    }else if ([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"3002"]) {
        
        if ([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"00"]) {
            [self resetCommandTable:0 data:@1];
        }else{
            [self resetCommandTable:0 data:@0];
        }
    }else if ([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"3003"]) {
        
        [self analysisDeviceSettingStatus:date callBack:_bikesetblock];
        [self resetCommandTable:0 data:[date substringWithRange:NSMakeRange(12, 2)]];
    }else if ([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"3005"]) {
        
        if ([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"00"]) {
            [self resetCommandTable:0 data:@1];
        }else{
            [self resetCommandTable:0 data:@0];
        }
        
    }else if ([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"3006"]) {
        
        [self analysisInquireFingerPrint:date fingerPrinttype:_fingerPrintTypeStr status:_fingerprintprocess];
        [self resetCommandTable:0 data:[date substringWithRange:NSMakeRange(12, 2)]];
    }else if ([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"3007"]) {
        
        if ([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"00"]) {
            [self resetCommandTable:0 data:@1];
        }else{
            [self resetCommandTable:0 data:@0];
        }
        
    }else if ([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"5001"]) {
        
        if ([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"00"]) {
            [self resetCommandTable:0 data:@1];
        }else{
            [self resetCommandTable:0 data:@0];
        }
        
    }else if ([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"5002"]) {
        
        _deviceConfigurationModel = [self analysisBikeConfiguration:date];
        
        if (_device.GPSCommndServices) {
            _deviceConfigurationModel.supportGPS = YES;
        }else{
            _deviceConfigurationModel.supportGPS = NO;
        }
        
        [self resetCommandTable:0 data:_deviceConfigurationModel];
    }
}

/**
 接收到了数据2.0 蓝牙协议indication
 
 @param tag 当前蓝牙标记
 @param data 返回数据
 @param peripheral 连接的设备
 */
- (void)didGetNewCommndBackData:(NSInteger)tag :(NSData *)data :(CBPeripheral *)peripheral{
    
    NSString *date = [ConverUtil data2HexString:data];
    if ([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"1011"]){
        
        CommandModel *model = [self.kvoModel.inquireCommandAry firstObject];
        
        switch ([self RSPAnalysis:date]) {
            case 0:
                self.bikestatusModel = [self newAnalysisBikestatus:self.bikestatusModel :date];
                if (_inquireblock) {
                    _inquireblock(self.bikestatusModel);
                }
                
                if (model.backdata) {
                    model.backdata(self.bikestatusModel);
                }
                
                if (model.error) {
                    model.error(SendSuccess);
                }
                break;
            case 1:
                if (model.error) {
                    model.error(SendFail);
                }
                break;
            case 2:
                if (model.error) {
                    model.error(InvalidCommand);
                }
                break;
            case 3:
                if (model.error) {
                    model.error(PermissionError);
                }
                break;
            case 4:
                if (model.error) {
                    model.error(InvalidData);
                }
                break;
            case 5:
                if (model.error) {
                    model.error(UnknownMistake);
                }
                break;
            default:
                break;
        }
        [model stopMonitorTime];
        [self.kvoModel.inquireCommandAry removeObject:model];
        [self nextCommentStep];
        
    }else if([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"1012"]){
        _deviceConfigurationModel = [self RSPAnalysis:date]>0? [DeviceConfigurationModel new]:[self newAnalysisBikeConfiguration:date];
        [self resetCommandTable:[self RSPAnalysis:date] data: _deviceConfigurationModel];
        
    }else if([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"1021"]){
        
        [self resetCommandTable:[self RSPAnalysis:date] data: [self RSPAnalysis:date]>0? @1:[NSNumber numberWithInt:[[date substringWithRange:NSMakeRange(12, 2)] intValue]]];
        
    }else if([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"1031"]){
        //蓝牙升级指令
        [self resetCommandTable:[self RSPAnalysis:date] data: [self RSPAnalysis:date]>0? @1:[NSNumber numberWithInt:[[date substringWithRange:NSMakeRange(12, 2)] intValue]]];
        
    }else if([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"1032"]){
        
        [self resetCommandTable:[self RSPAnalysis:date] data: [self RSPAnalysis:date]>0? @1:[NSNumber numberWithInt:[[date substringWithRange:NSMakeRange(12, 2)] intValue]]];
        
    }else if([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"1033"]){
        
        [self resetCommandTable:[self RSPAnalysis:date] data: [self RSPAnalysis:date]>0? @"1":[date substringWithRange:NSMakeRange(12, 2)]];
    }else if([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"1034"]){
        
        [self resetCommandTable:[self RSPAnalysis:date] data: [self RSPAnalysis:date]>0? @"1":[date substringWithRange:NSMakeRange(12, 2)]];
    }else if([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"1134"]){
        
//        if ([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"00"]) {
//            if (_gpsConnectCallback) {
//                _gpsConnectCallback(DeviceDisconnect);
//            }
//        }else{
//            if (_gpsConnectCallback) {
//                _gpsConnectCallback(DeviceConnect);
//            }
//        }
        
    }else if([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"1141"]){
        
        self.bikestatusModel = [self newAnalysisBikestatus:self.bikestatusModel :date];
    }else if([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"2011"]){
        //编码获取进退出模式
        [self resetCommandTable:[self RSPAnalysis:date] data: [self RSPAnalysis:date]>0? @1:[NSNumber numberWithInt:[[date substringWithRange:NSMakeRange(12, 2)] intValue]]];
    }else if([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"2111"]){
        
        [self newAnalysisAddNomalKey:_hardwareNum data:date steps:_configurationprocess];
    }else if([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"2012"]){
        
        [self resetCommandTable:[self RSPAnalysis:date] data: [self RSPAnalysis:date]>0? @1:[NSNumber numberWithInt:[[date substringWithRange:NSMakeRange(12, 2)] intValue]]];
    }else if([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"2013"]){
        
        [self resetCommandTable:[self RSPAnalysis:date] data: [self RSPAnalysis:date]>0? @"0":[date substringWithRange:NSMakeRange(13, 1)]];
    }else if([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"2021"]){//蓝牙钥匙配置指令RSP
        
        [self resetCommandTable:[self RSPAnalysis:date] data:[self RSPAnalysis:date]>0? @1:[NSNumber numberWithInt:[[date substringWithRange:NSMakeRange(12, 2)] intValue]]];
    }else if([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"2121"]){//蓝牙钥匙配置指令IND
        
        if ([self RSPAnalysis:date]>0) {
            if (_waitingBackBlock) {
                _waitingBackBlock(@1);
            }
        }else{
           if (_waitingBackBlock) {
                _waitingBackBlock([NSNumber numberWithInt:[[date substringWithRange:NSMakeRange(12, 2)] intValue]]);
            }
        }
        
    }else if([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"2022"]){//感应钥匙RSSI设置指令
        
        if ([self RSPAnalysis:date]==0) [self newAnalysisDeviceInductionValue:date callBack:_bikeinductionvalue];
        [self resetCommandTable:[self RSPAnalysis:date] data:[date substringWithRange:NSMakeRange(12, 2)]];
    }else if([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"5011"]){//胎压数据ind开启关闭指令
        
        [self resetCommandTable:[self RSPAnalysis:date] data:[self RSPAnalysis:date]>0? @1:[NSNumber numberWithInt:[[date substringWithRange:NSMakeRange(12, 2)] intValue]]];
    }else if([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"5111"]){//胎压数据ind
        
    }else if([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"5012"]){//胎压语音报警开关指令
        
        [self resetCommandTable:[self RSPAnalysis:date] data:[self RSPAnalysis:date]>0? @1:[NSNumber numberWithInt:[[date substringWithRange:NSMakeRange(12, 2)] intValue]]];
    }else if([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"6012"]){//指纹查询手指按压指令
        
        [self newAnalysisInquireFingerPrint:date status:_fingerprintprocess];
        [self resetCommandTable:[self RSPAnalysis:date] data:[date substringWithRange:NSMakeRange(12, 2)]];
    }else if([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"6013"]){//指纹注册指令
        
        [self analysisCommandRsp:[self RSPAnalysis:date]];
    }else if([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"6113"]){//指纹注册指令 INC
        
        [self newAnalysisAddFingerPrint:date status:_fingerprintprocess];
    }else if([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"6014"]){//指纹删除指令
        [self resetCommandTable:[self RSPAnalysis:date] data:[self RSPAnalysis:date]>0? @1:[NSNumber numberWithInt:[[date substringWithRange:NSMakeRange(12, 2)] intValue]]];
    }else if([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"3021"]){
        //鉴权GPS
        [self resetCommandTable:[self RSPAnalysis:date] data: [self RSPAnalysis:date]>0? @1:[NSNumber numberWithInt:[[date substringWithRange:NSMakeRange(12, 2)] intValue]]];
    }else if([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"3054"]){
        
        Byte *byte=(Byte *)[[ConverUtil stringToByte:date] bytes];
        NSInteger value = (char)byte[6];
        NSDictionary *dict;
        if (value == 1) {
            if ([self RSPAnalysis:date]>0) {
                dict = [NSDictionary dictionaryWithObjectsAndKeys:@1,@"status", nil];
            }else{
                dict = [NSDictionary dictionaryWithObjectsAndKeys:@0,@"status",@((char)byte[7]),@"data", nil];
            }
        }else if (value == 2){
            if ([self RSPAnalysis:date]>0) {
                isAuthentication = NO;
                dict = [NSDictionary dictionaryWithObjectsAndKeys:@1,@"status", nil];
            }else{
                
                if ((char)byte[7] == 1) {
                    isAuthentication = YES;
                }else{
                    isAuthentication = NO;
                }
                
                dict = [NSDictionary dictionaryWithObjectsAndKeys:@0,@"status",@((char)byte[7]),@"data", nil];
            }
        }else if (value == 3){
            if ([self RSPAnalysis:date]>0) {
                dict = [NSDictionary dictionaryWithObjectsAndKeys:@1,@"status", nil];
            }else{
                dict = [NSDictionary dictionaryWithObjectsAndKeys:@0,@"status",@((char)byte[7]),@"data", nil];
            }
        }else if (value == 4){
            if ([self RSPAnalysis:date]>0) {
                dict = [NSDictionary dictionaryWithObjectsAndKeys:@1,@"status", nil];
            }else{
                dict = [NSDictionary dictionaryWithObjectsAndKeys:@0,@"status",@((char)byte[7]),@"data", nil];
            }
        }
        [self resetCommandTable:[self RSPAnalysis:date] data:dict];
    }else if([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"3055"]){
        //查询GPS
        [self resetCommandTable:[self RSPAnalysis:date] data: [self RSPAnalysis:date]>0? @1:[NSNumber numberWithInt:[[date substringWithRange:NSMakeRange(12, 2)] intValue]]];
    }else if([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"3057"]){
        
        NSDictionary *dict;
        if ([self RSPAnalysis:date]>0) {
            dict = [NSDictionary dictionaryWithObjectsAndKeys:@1,@"status", nil];
        }else{
            Byte *byte=(Byte *)[[ConverUtil stringToByte:date] bytes];
            NSInteger gsmValue = (char)byte[6];
            dict = [NSDictionary dictionaryWithObjectsAndKeys:@0,@"status",@(gsmValue),@"data", nil];
        }
        
        [self resetCommandTable:[self RSPAnalysis:date] data:dict];
    }else if([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"3058"]){
        
        NSDictionary *dict;
        if ([self RSPAnalysis:date]>0) {
            dict = [NSDictionary dictionaryWithObjectsAndKeys:@1,@"status", nil];
        }else{
            
            Byte *byte=(Byte *)[[ConverUtil stringToByte:date] bytes];
            NSMutableArray *dataAry = [NSMutableArray array];
            NSInteger length = date.length/2 - 6;
            for (int i = 7; i <= length; i = i+2 ) {
                NSInteger value = (char)byte[i];
                if (value > 30) {
                    [dataAry addObject:@(value)];
                }
            }
            dict = [NSDictionary dictionaryWithObjectsAndKeys:@0,@"status",dataAry,@"data", nil];
        }
        [self resetCommandTable:[self RSPAnalysis:date] data:dict];
    }
}


-(void)resetCommandTable:(NSInteger)RSPAnalysisNum data:(id)data{
    
    CommandModel *model = [self.kvoModel.commandArray firstObject];
    if (model.backdata) {
        model.backdata(data);
    }
    
    [model.commandAry removeObjectAtIndex:0];
    if (model.commandAry.count > 0) {
        [_device sendKeyValue:[model.commandAry firstObject]];
        return;
    }else{
        
        switch (RSPAnalysisNum) {
            case 0:
                if (model.error) {
                    model.error(SendSuccess);
                }
                break;
            case 1:
                if (model.error) {
                    model.error(SendFail);
                }
                break;
            case 2:
                if (model.error) {
                    model.error(InvalidCommand);
                }
                break;
            case 3:
                if (model.error) {
                    model.error(PermissionError);
                }
                break;
            case 4:
                if (model.error) {
                    model.error(InvalidData);
                }
                break;
            case 5:
                if (model.error) {
                    model.error(UnknownMistake);
                }
                break;
            default:
                break;
        }
    }
    
    [model stopMonitorTime];
    [self.kvoModel.commandArray removeObject:model];
    [self nextCommentStep];
}

-(void)analysisCommandRsp:(NSInteger)RSPAnalysisNum{
    
    CommandModel *model = [self.kvoModel.commandArray firstObject];
    switch (RSPAnalysisNum) {
        case 0:
            if (model.error) {
                model.error(SendSuccess);
            }
            break;
        case 1:
            if (model.error) {
                model.error(SendFail);
            }
            break;
        case 2:
            if (model.error) {
                model.error(InvalidCommand);
            }
            break;
        case 3:
            if (model.error) {
                model.error(PermissionError);
            }
            break;
        case 4:
            if (model.error) {
                model.error(InvalidData);
            }
            break;
        case 5:
            if (model.error) {
                model.error(UnknownMistake);
            }
            break;
        default:
            break;
    }
    [model stopMonitorTime];
}

#pragma mark---接收到了数据 读蓝牙中的报警器的mac地址
- (void)didGetBurglarCharData:(NSInteger)tag :(NSData *)data :(CBPeripheral *)peripheral{
    
}


//蓝牙自带的读取固件版本信息
- (void)didGetEditionCharData:(NSInteger)tag :(NSData *)data :(CBPeripheral *)peripheral{
    
    NSString *result = [[NSString alloc] initWithData:data  encoding:NSUTF8StringEncoding];
    [self resetCommandTable:0 data:result];
}

//蓝牙自带的读取硬件版本信息
- (void)didGetVersionCharData:(NSInteger)tag :(NSData *)data :(CBPeripheral *)peripheral{
    
    NSString *version = [[NSString alloc] initWithData:data  encoding:NSUTF8StringEncoding];
    [self resetCommandTable:0 data:version];
}


-(void)removePeripher:(NSString *)mac{
    
    if ([self.peripheralDic objectForKey:mac]) {
        
        [self.peripheralAry removeObject:[self.peripheralDic objectForKey:mac]];
        [self.peripheralDic removeObjectForKey:mac];
        if (self.scanBlock) {
            self.scanBlock(self.peripheralAry);
        }
    }
}



-(void)restFingerPrintParameter{
    
    _fingerPressNum = _pressSecond = _startTime = 0;

}


-(void)dealloc{
    //[self.bikestatusModel removeObserver:self forKeyPath:@"gpsConnection"];
}

@end
