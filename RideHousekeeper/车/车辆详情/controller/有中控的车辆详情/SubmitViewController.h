//
//  SubmitViewController.h
//  RideHousekeeper
//
//  Created by smartwallit on 16/7/14.
//  Copyright © 2016年 Duke Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FaultModel;
@protocol SubmitDelegate <NSObject>

@optional

-(void) regulatePhoneInduction:(BOOL)isOpen;

-(void) regulatePhoneInductionValue:(NSInteger)phInductionValue;

@end

@interface SubmitViewController : BaseViewController
@property(nonatomic,copy) NSString* shockState;
@property(nonatomic,assign) NSInteger deviceNum;
@property(nonatomic,strong) NSString* keystate;
@property(nonatomic,strong) FaultModel *faultmodel;//故障model
@property (nonatomic,weak) id<SubmitDelegate> delegate;
@end


