//
//  AppDelegate.h
//  RideHousekeeper
//
//  Created by 同时科技 on 16/6/20.
//  Copyright © 2016年 Duke Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JPUSHService.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UIViewController *mainController;

+ (AppDelegate *)currentAppDelegate;

-(void)mbluetoohPowerOff;

-(void)mbluetoohPowerOn;

@end

