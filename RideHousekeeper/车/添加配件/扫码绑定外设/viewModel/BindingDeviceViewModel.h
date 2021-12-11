//
//  BindingDeviceViewModel.h
//  RideHousekeeper
//
//  Created by Apple on 2019/10/12.
//  Copyright © 2019 Duke Wu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BindingDeviceViewModel : NSObject

- (void)checkKey:(NSInteger)bikeid :(NSString *)sn success:(void (^)(id))success
         failure:(void (^)(NSError *))failure;

- (void)checkECUDevices:(NSString *)sn success:(void (^)(id))success
failure:(void (^)(NSError *))failure;

- (void)bindKey:(NSInteger)bikeid :(DeviceInfoModel *)deviceInfoModel success:(void (^)(id))success
        failure:(void (^)(NSError *))failure;

-(void)BindingDeviceWithBikeId:(NSInteger)bikeid messageinfo:(id)model success:(void (^)(id))success
                       failure:(void (^)(NSError *))failure;

- (void)startblescan:(DeviceScanType)scanType :(NSString *)mac :(NSInteger)timeNum scanCallBack:(void (^)(id))callBack countDown:(void (^)(NSInteger))countDownBack;

-(void)nextStep:(NSInteger)bikeid :(DeviceInfoModel *)deviceInfoModel success:(void (^)(id))success
        failure:(void (^)(NSError *))failure;

@end

NS_ASSUME_NONNULL_END
