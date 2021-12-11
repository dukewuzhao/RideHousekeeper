//
//  AppDelegate.h
//  RideHousekeeper
//
//  Created by 同时科技 on 16/6/20.
//  Copyright © 2016年 Duke Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WYDevice.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (assign, nonatomic) BOOL isPop;

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UIViewController *mainController;
@property (nonatomic,strong)  WYDevice *device;

+ (AppDelegate *)currentAppDelegate;


@end

