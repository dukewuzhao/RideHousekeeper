//
//  WYDevice.m
//  WYDevice
//
//  Created by AlanWang on 14-9-10.
//  Copyright (c) 2014年 AlanWang. All rights reserved.
//

#import "WYDevice.h"
#import "CommandModel.h"

@interface WYDevice ()
@property (nonatomic,assign)  int deviceStatus;
@end

@implementation WYDevice{
    
    CBCharacteristic *  AccelerationChar;//Read 设备的mac地址值
    CBCharacteristic *  editionChar;//固件版本号
    CBCharacteristic *  versionChar;//硬件版本号
    CBCharacteristic *  writeChar;//write特征值属性
    CBCharacteristic *  indicateChar;//Indicate通知上报传感器数据
    
    CBCharacteristic *  GPSWriteChar;//GPS的write特征值属性
    CBCharacteristic *  GPSIndicateChar;//GPS的Indicate通知上报传感器数据
}

@synthesize deviceDelegate;
@synthesize scanDelete;
@synthesize centralManager;

-(id)init{
    self = [super init];
    if(self){
        centralManager   = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:@{CBCentralManagerOptionRestoreIdentifierKey:BLE_MAIN_RESTORE_IDENTIFIER}];
        }
    return self;
}

-(id)initWithRestoreIdentifier:(NSString *)identifier{
    self = [super init];
    if(self){
        centralManager=[[CBCentralManager alloc]initWithDelegate:self queue:nil options:@{CBCentralManagerOptionRestoreIdentifierKey:identifier}];
   }
    return  self;
}

//这个方法的作用,就是根据uuid取到外设.
-(BOOL)retrievePeripheralWithUUID:(NSString *)uuidString{
    
    if(uuidString!=nil && ![uuidString isEqualToString:@""]){
        NSUUID *nsuuid=[[NSUUID alloc]initWithUUIDString:uuidString];
        NSArray *deices=  [centralManager retrievePeripheralsWithIdentifiers:[[NSArray alloc]initWithObjects:nsuuid, nil]];
        if(deices.count>0){
            _peripheral=deices[0];
            return YES;
        }
    }      
    return NO;
}

-(void)startScan{
      //[centralManager scanForPeripheralsWithServices:[NSArray arrayWithObject:[CBUUID UUIDWithString:@"FFE1"]]  options:nil];//能在后台扫描特定的设备，不被后台挂起
    [centralManager scanForPeripheralsWithServices:nil options:nil];
}

-(void)startBackstageScan{
    [centralManager scanForPeripheralsWithServices:[NSArray arrayWithObject:[CBUUID UUIDWithString:@"FFE1"]]  options:@{ CBCentralManagerScanOptionAllowDuplicatesKey:@YES }];//能在后台扫描特定的设备，不被后台挂起
}

-(void)startInfiniteScan{
    
    [centralManager scanForPeripheralsWithServices:nil options:@{ CBCentralManagerScanOptionAllowDuplicatesKey:@YES }];
}

-(void)stopScan{
    [centralManager stopScan];
}
-(void)remove{
    if(_peripheral && [[APPStatusManager sharedManager] getBLEStstus]){
        NSLog(@"主动断开设备连接");
        [centralManager cancelPeripheralConnection:_peripheral];
    }
    
    _peripheral=nil;
    _deviceStatus=0;
    [self reset];
}
-(void)reset{
    
    //services=nil;
    AccelerationChar = nil;
    editionChar = nil;
    versionChar = nil;
    writeChar = nil;
    indicateChar = nil;
    GPSWriteChar = nil;
    GPSIndicateChar = nil;
}



-(void)connect{
    if(_peripheral && [[APPStatusManager sharedManager] getBLEStstus]){
        NSLog(@"开始设备连接");
        [centralManager connectPeripheral:_peripheral options:nil];
    }
}

-(void)cancelConnect{
    if(_peripheral)
        [centralManager cancelPeripheralConnection:_peripheral];
}

//写操作
-(void)sendKeyValue:(SingerPacketCommandModel *)model{
    
    NSString *date = [ConverUtil data2HexString:model.commndData];
    if (![[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"1001"] ) {
        NSLog(@"发送的指令%@",model.commndData);
    }
    
    if (_peripheral.state != CBPeripheralStateConnected) {
        return;
    }
    _commndData = model.commndData;
    if(model.sendGPS && GPSWriteChar){
        [_peripheral writeValue:model.commndData forCharacteristic:GPSWriteChar type:CBCharacteristicWriteWithResponse];
    }else if(!model.sendGPS && writeChar){
        [_peripheral writeValue:model.commndData forCharacteristic:writeChar type:CBCharacteristicWriteWithResponse];
    }
}

//读操作
-(void)sendAccelerationValue:(NSData *)data{
    
    if(AccelerationChar==nil){
        NSLog(@"AccelerationChar is nil");
        return;
    }
    if(_peripheral==nil){
        NSLog(@"peripheral is nil");
        return;
    }
    [_peripheral readValueForCharacteristic: AccelerationChar];
}

-(void)readFirmwareDiviceVersion{
    
    if(editionChar==nil){
        NSLog(@"editionChar is nil");
        return;
    }
    if(_peripheral==nil){
        NSLog(@"peripheral is nil");
        return;
        
    }
    [_peripheral readValueForCharacteristic: editionChar];
}

-(void)readDiviceHardwareVersion{
    
    if(versionChar==nil){
        NSLog(@"versionChar is nil");
        return;
    }
    if(_peripheral==nil){
        NSLog(@"peripheral is nil");
        return;
        
    }
    
    [_peripheral readValueForCharacteristic: versionChar];
}
/*
 
CBCentralManagerRestoredStatePeripheralsKey;
CBCentralManagerRestoredStateScanServicesKey;
CBCentralManagerRestoredStateScanOptionsKey;
*/
#pragma mark - CBCentralManager delegate
-(void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary *)dict{
    NSLog(@"willRestoreState:%@",dict);
    NSArray *peripherals = dict[CBCentralManagerRestoredStatePeripheralsKey];
}

-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    if([peripheral.name hasPrefix: @"Qgj-"] || [peripheral.name hasPrefix: @"QGJ-"]){
        if(scanDelete && [scanDelete respondsToSelector:@selector(didDiscoverPeripheral::scanData:RSSI:)]){
            
            [scanDelete didDiscoverPeripheral:_tag :peripheral scanData:advertisementData RSSI:RSSI];
        }else{
            
            NSLog(@"scandelete为空");
        }
    }
}
-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
   
    NSLog(@"---SDK---- :  didConnectPeripheral, start discover services  tag:%@---%@",peripheral.name,peripheral.identifier.UUIDString);
    _peripheral=peripheral;
    _peripheral.delegate=self;
    [_peripheral discoverServices:nil];
}

-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"---SDK---- :  didFailToConnectPeripheral, error %@",error);
}
-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    [self reset];
    _deviceStatus = 0;
    NSLog(@"---SDK---- :  didDisconnectPeripheral,   tag:%d  ,error:%@",_tag, error);
    
    if (deviceDelegate && [deviceDelegate respondsToSelector:@selector(didDisconnect::)]){
        [deviceDelegate didDisconnect:_tag :peripheral];
    }
    if (_commndServices) {
        _commndServices = nil;
    }
    
    if (_GPSCommndServices) {
        _GPSCommndServices = nil;
    }
    
    if (![[APPStatusManager sharedManager] getBikeBindingStstus]){
        
        [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(connect) object:nil];
        [self performSelector:@selector(connect) withObject:nil  afterDelay:1.0];
    }
}

-(void)centralManagerDidUpdateState:(CBCentralManager *)central{
    
    if (central.state == CBManagerStatePoweredOn) {
        NSArray *arr = [central retrieveConnectedPeripheralsWithServices:@[[CBUUID UUIDWithString:@"FFE1"],[CBUUID UUIDWithString:@"FE01"]]];
        [arr enumerateObjectsUsingBlock:^(CBPeripheral *obj, NSUInteger idx, BOOL *stop) {
        //连接首个被连接的设备（一般只有一个设备被系统连接上）
            NSLog(@"连接=====%@ %lu   \n%@",obj,(unsigned long)idx,obj.services);
        //利用中心将设备连接起来，并确保设备没被本APP连接
             if ((obj.state == CBPeripheralStateConnected || obj.state == CBPeripheralStateConnecting) && idx == 0 && self.deviceStatus == 0) {
                obj.delegate = self; //@{CBConnectPeripheralOptionNotifyOnDisconnectionKey:[NSNumber numberWithBool:TRUE]}
                 [central cancelPeripheralConnection:obj];
                //[central connectPeripheral:obj options:nil];
            }
        }];
    }
    
    if(scanDelete&& [scanDelete respondsToSelector:@selector(WYCentralManagerDidUpdateState:)]){
        [scanDelete WYCentralManagerDidUpdateState:central.state];
    }
}

#pragma mark - CBCentralManager delegate


#pragma mark - peripheral delegate
- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error{
//-(void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error{
    if(deviceDelegate && [deviceDelegate respondsToSelector:@selector(didGetRssi:::)]){
        [deviceDelegate didGetRssi:_tag :[RSSI intValue] :_peripheral];
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    if (!error){
        [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(checkSuccess:) object:peripheral];
        [self performSelector:@selector(checkSuccess:) withObject:peripheral  afterDelay:2.0];
        for (CBService *aService in peripheral.services){
            NSLog(@"---------didDiscoverServices-- = %@   tag:%d",aService.UUID,_tag);
            // Discovers the characteristics for a given service
            if ([aService.UUID isEqual:[CBUUID UUIDWithString:@"FFE1"]]){
                
                _commndServices = [FirstVersionServices new];
                [peripheral discoverCharacteristics:nil forService:aService];
            }else if ([aService.UUID isEqual:[CBUUID UUIDWithString:@"FEB0"]]){
                _commndServices = [SecondVersionServices new];
                [peripheral discoverCharacteristics:nil forService:aService];
            }else if ([aService.UUID isEqual:[CBUUID UUIDWithString:@"180A"]]){
                
                [peripheral discoverCharacteristics:nil forService:aService];
            }else if ([aService.UUID isEqual:[CBUUID UUIDWithString:@"FE01"]]){
                _GPSCommndServices = [SingleGPSServices new];
                [peripheral discoverCharacteristics:nil forService:aService];
            }
        }
    }else{
         NSLog(@"---SDK---- :  didDiscoverServices, error %@",error);
    }
    
}
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    if(!error){
        
        if([service.UUID isEqual:[CBUUID UUIDWithString:@"180A"]]){
            
            for (CBCharacteristic *BChar in service.characteristics)
            {
                if ([BChar.UUID isEqual:[CBUUID UUIDWithString:@"2A26"]]){
                    editionChar = BChar;
                    
                }else if ([BChar.UUID isEqual:[CBUUID UUIDWithString:@"2A27"]]){
                    versionChar = BChar;
                }
            }
        }else if([service.UUID isEqual:[CBUUID UUIDWithString:@"FFE1"]]){
            
            for (CBCharacteristic *aChar in service.characteristics)
            {
                NSLog(@" aChar:%@",aChar.UUID.UUIDString);
                
                if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"FEE2"]]){
                    writeChar = aChar;
                    
                }else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"FEE3"]]){
                    
                    [peripheral setNotifyValue:YES forCharacteristic:aChar];
                    indicateChar = aChar;
                }else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"FEE4"]]){
                    
                    AccelerationChar = aChar;
                }
            }
        }else if ([service.UUID isEqual:[CBUUID UUIDWithString:@"FEB0"]]){
            
            for (CBCharacteristic *bChar in service.characteristics){
                NSLog(@" aChar:%@",bChar.UUID.UUIDString);
                
                if ([bChar.UUID isEqual:[CBUUID UUIDWithString:@"FEB1"]]){
                    
                    writeChar = bChar;
                }else if ([bChar.UUID isEqual:[CBUUID UUIDWithString:@"FEB2"]]){
                    
                    [peripheral setNotifyValue:YES forCharacteristic:bChar];
                    indicateChar = bChar;
                }
            }
        }else if ([service.UUID isEqual:[CBUUID UUIDWithString:@"FE01"]]){
            
            for (CBCharacteristic *bChar in service.characteristics){
                NSLog(@" aChar:%@",bChar.UUID.UUIDString);
                
                if ([bChar.UUID isEqual:[CBUUID UUIDWithString:@"FE02"]]){
                    GPSWriteChar = bChar;
                    
                }else if ([bChar.UUID isEqual:[CBUUID UUIDWithString:@"FE03"]]){
                    
                    [peripheral setNotifyValue:YES forCharacteristic:bChar];
                    GPSIndicateChar = bChar;
                }
            }
        }
    }else{
        NSLog(@"---SDK---- :  didDiscoverCharacteristics, error %@",error);
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    //2秒之后检测是否还是连接状态，来决定连接是否稳定了，因为有时候一开始会反复断连
    
    if (error) {
        NSLog(@"Error changing notification state: %@", error.localizedDescription);
    }
    
    // Notification has started
        if (!characteristic.isNotifying) {
            
            // so disconnect from the peripheral
            NSLog(@"Notification stopped on %@.  Disconnecting", characteristic);
            //[self updateLog:[NSString stringWithFormat:@"Notification stopped on %@.  Disconnecting", characteristic]];
            [centralManager cancelPeripheralConnection:_peripheral];
        }
}

- (void)peripheral:(CBPeripheral *)peripheral didModifyServices:(nonnull NSArray<CBService *> *)invalidatedServices{
    NSLog(@"didModifyServices:%@",invalidatedServices);
    [_peripheral discoverServices:nil];
}

//上报值
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if (!error){
        
        if (peripheral != _peripheral) {
            return;
        }
        
        NSString *date = [ConverUtil data2HexString:characteristic.value];
        if (![[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"1001"] ) {
            NSLog(@"设备收到数据：%@",characteristic.value);
        }
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A26"]]){
            if (deviceDelegate && [deviceDelegate respondsToSelector:@selector(didGetEditionCharData:::)])
            {
                [deviceDelegate didGetEditionCharData:_tag :characteristic.value :_peripheral];
            }
        }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A27"]]){
            if (deviceDelegate && [deviceDelegate respondsToSelector:@selector(didGetVersionCharData:::)])
            {
                [deviceDelegate didGetVersionCharData:_tag :characteristic.value :_peripheral];
            }
        }
        else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FEE3"]]){
        
            if (deviceDelegate && [deviceDelegate respondsToSelector:@selector(didGetIndicateData:::)])
            {
                [deviceDelegate didGetIndicateData:_tag :characteristic.value :_peripheral];
            }
        }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FEB2"]]){
            
            if (deviceDelegate && [deviceDelegate respondsToSelector:@selector(didGetNewCommndBackData:::)])
            {
                [deviceDelegate didGetNewCommndBackData:_tag :characteristic.value :_peripheral];
            }
        }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FEE4"]]){
            
            if (deviceDelegate && [deviceDelegate respondsToSelector:@selector(didGetBurglarCharData:::)])
            {
                [deviceDelegate didGetBurglarCharData:_tag :characteristic.value :_peripheral];
            }
        }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FE03"]]){
            
            if (deviceDelegate && [deviceDelegate respondsToSelector:@selector(didGetNewCommndBackData:::)])
            {
                [deviceDelegate didGetNewCommndBackData:_tag :characteristic.value :_peripheral];
            }
        }
    }else{
        NSLog(@"设备收到数据：error");
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    //NSLog(@"写成功指令%@",_commndData);
    if (deviceDelegate && [deviceDelegate respondsToSelector:@selector(didWriteValueForCharacteristic::::)]){
        [deviceDelegate didWriteValueForCharacteristic:_tag :peripheral :characteristic :error];
    }
}

#pragma mark - peripheral delegate
//检测连接是否稳定
-(void)checkSuccess:(CBPeripheral *)peripheral{
    if( peripheral.state==CBPeripheralStateConnected){
          NSLog(@"检测设备%d 蓝牙已经连接稳定  ",_tag);
        _deviceStatus=2;
        
        if (deviceDelegate && [deviceDelegate respondsToSelector:@selector(didConnect::)]){
            [deviceDelegate didConnect:_tag :peripheral];
        }
    }
}

-(BOOL)isConnected{
    
    return  _deviceStatus == 2? YES:NO;
    
}



@end
