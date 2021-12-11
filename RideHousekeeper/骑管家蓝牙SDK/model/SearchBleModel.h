//
//  SearchBleModel.h
//  RideHousekeeper
//
//  Created by Apple on 2017/10/17.
//  Copyright © 2017年 Duke Wu. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@protocol removeDelegate <NSObject>
@optional
-(void)removePeripher:(NSString *)mac;

@end

@interface SearchBleModel : NSObject
@property (weak, nonatomic ) id<removeDelegate> delegate;
//@property (nonatomic,assign) NSInteger tag;

@property (nonatomic,retain) CBPeripheral *peripher;

@property (nonatomic,copy) NSString *titlename;

@property (nonatomic,copy) NSString *mac;

@property(nonatomic,strong) NSNumber* rssi;

@property(nonatomic,assign) NSInteger searchCount;

-(instancetype)initWithType:(DeviceScanType)type;

-(void)stopSearchBle;

@end
