//
//  GPSActivationManager.h
//  RideHousekeeper
//
//  Created by Apple on 2020/3/27.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AnnotatedHeader.h"
NS_ASSUME_NONNULL_BEGIN

@interface APPStatusManager : NSObject
+(instancetype)sharedManager;

-(void)setActivatedJumpStstus:(BOOL)status;
-(BOOL)getActivatedJumpStstus;

-(void)setBikeBindingStstus:(BOOL)status;
-(BOOL)getBikeBindingStstus;

-(void)setBLEStstus:(BOOL)status;
-(BOOL)getBLEStstus;

-(void)setBikeFirmwareUpdateStstus:(BOOL)status;
-(BOOL)getBikeFirmwareUpdateStstus;

-(void)setUpdatePaymentStatus:(BOOL)status;
-(BOOL)getUpdatePaymentStatus;

-(void)setChangeDeviceType:(BindingType)type;
-(BindingType)getChangeDeviceType;
@end

NS_ASSUME_NONNULL_END
