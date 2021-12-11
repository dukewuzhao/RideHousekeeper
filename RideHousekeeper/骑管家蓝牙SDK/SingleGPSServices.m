//
//  SingleGPSServices.m
//  RideHousekeeper
//
//  Created by Apple on 2019/11/12.
//  Copyright © 2019 Duke Wu. All rights reserved.
//

#import "SingleGPSServices.h"
#import "WYDeviceServices.h"
@implementation SingleGPSServices

- (void)didConnect:(NSInteger)tag :(CBPeripheral *)peripheral{
    
    
}

- (void)didDisconnect:(NSInteger)tag :(CBPeripheral *)peripheral{
    
    
}

-(void)GPSAuthentication:(NSString *)authenticationCode data:(void (^_Nonnull)(id data))data error:(void (^_Nullable)(CommandStatus status))error{
    //NSString *token = [NSString stringWithFormat:@"A60000203021%@",authenticationCode];
    [[WYDeviceServices shareInstance] sendHexstring:[ConverUtil stringToByte:[NSString stringWithFormat:@"A60000203021%@",authenticationCode]] callBack:data error:error ];
}

-(void)QueryGPSActivationStatus:(GPSOperationMode)mode  data:(void (^_Nonnull)(id data))data error:(void (^_Nullable)(CommandStatus status))error{
    
    switch (mode) {
        case QueryGPSWorkMode:
            [[WYDeviceServices shareInstance] sendHexstring:[ConverUtil stringToByte:@"A6000007305401"] callBack:data  error:error];
            break;
        case QueryGPSActivateMode:
            [[WYDeviceServices shareInstance] sendHexstring:[ConverUtil stringToByte:@"A6000007305402"] callBack:data  error:error];
            break;
        case QueryGPSPositionMode:
            [[WYDeviceServices shareInstance] sendHexstring:[ConverUtil stringToByte:@"A6000007305403"] callBack:data  error:error];
            break;
        case QueryGPSNetworkStatusMode:
            [[WYDeviceServices shareInstance] sendHexstring:[ConverUtil stringToByte:@"A6000007305404"] callBack:data  error:error];
        break;
        default:
            break;
    }
    
    
}

-(void)sendSingleGPSActivationCommend:(SwitchStatus)behavior data:(void (^_Nonnull)(id data))data error:(void (^_Nullable)(CommandStatus status))error{
    [[WYDeviceServices shareInstance] sendHexstring:[ConverUtil stringToByte:[NSString stringWithFormat:@"A60000083055020%d",behavior]] callBack:data error:error];
}

-(void)SetGPSWorkingMode:(GPSWorkingMode)mode data:(void (^_Nonnull)(NSString *data))data error:(void (^_Nullable)(CommandStatus status))error{
    [[WYDeviceServices shareInstance] sendHexstring:[ConverUtil stringToByte:[NSString stringWithFormat:@"A60000083055010%d",mode]] callBack:data error:error];
}

-(void)getSatelliteDataCommend:(void (^_Nonnull)(id data))data error:(void (^_Nullable)(CommandStatus status))error{
    [[WYDeviceServices shareInstance] sendHexstring:[ConverUtil stringToByte:@"A60000063058"] callBack:data  error:error];
}

-(void)getGPSGSMSignalValue:(void (^_Nonnull)(id data))data error:(void (^_Nullable)(CommandStatus status))error{
    
    [[WYDeviceServices shareInstance] sendHexstring:[ConverUtil stringToByte:@"A60000063057"] callBack:data  error:error];
    
}

-(void)setGPSReset:(void (^_Nullable)(CommandStatus status))error{
    [[WYDeviceServices shareInstance] sendHexstring:[ConverUtil stringToByte:@"A60000083055FF00"] callBack:nil error:error];
}

@end
