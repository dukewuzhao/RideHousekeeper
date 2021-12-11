//
//  Manger.h
//  MultiDelegateDemo
//
//  Created by JiangMing on 2017/3/20.
//  Copyright © 2017年 JiangMing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MultiDelegate.h"
#import <UIKit/UIKit.h>
@class UpdateViewModel;
@protocol ManagerDelegate;

@interface Manager : NSObject

+ (instancetype)shareManager;

- (void)bindingBikeSucceeded:(BikeInfoModel *)model :(UpdateViewModel *)updateModel;

- (void)unbundBike:(NSInteger)bikeid;

- (void)bindingPeripheralSucceeded:(PeripheralModel *)model;

- (void)deletePeripheralSucceeded:(PeripheralModel *)model;

- (void)updatebikeName:(NSString *)name :(NSInteger)bikeId;

- (void)updateUserMessage:(NSString *)name :(UIImage *)img;

- (void)postRemoteJPush:(NSDictionary *)dict;

- (void)switchingVehicle:(NSDictionary *)dict;

- (void)bikeViewUpdateForNewConnect:(BOOL)isNeed;

- (void)updateGPSMapActivationStatus:(NSInteger)bikeid;

- (void)BikeFirmwareUpgrade:(NSInteger)bikeid;

- (void)updateGPSServiceInfo:(NSInteger)bikeid;

- (void)addDelegate:(id<ManagerDelegate>)delegate;

- (void)deleteDelegate:(id<ManagerDelegate>)delegate;

- (void)clearAllDelegates;

@end

@protocol ManagerDelegate <NSObject>

@optional

- (void)manager:(Manager *)manager bindingBikeSucceeded:(BikeInfoModel *)model :(UpdateViewModel *)updateModel;

- (void)manager:(Manager *)manager unbundBike:(NSInteger)bikeid;

- (void)manager:(Manager *)manager bindingPeripheralSucceeded:(PeripheralModel *)model;

- (void)manager:(Manager *)manager deletePeripheralSucceeded:(PeripheralModel *)model;

- (void)manager:(Manager *)manager updatebikeName:(NSString *)name :(NSInteger)bikeId;

- (void)manager:(Manager *)manager updateUserMessage:(NSString *)name :(UIImage *)img;

- (void)manager:(Manager *)manager postRemoteJPush:(NSDictionary *)dict;

- (void)manager:(Manager *)manager switchingVehicle:(NSDictionary *)dict;

- (void)managerBikeViewUpdatet:(Manager *)manager needNewConnect:(BOOL)isNeed;

- (void)manager:(Manager *)manager updateGPSMapActivationStatus:(NSInteger)bikeid;

- (void)manager:(Manager *)manager BikeFirmwareUpgrade:(NSInteger)bikeid;

- (void)manager:(Manager *)manager updateGPSServiceInfo:(NSInteger)bikeid;

@end
