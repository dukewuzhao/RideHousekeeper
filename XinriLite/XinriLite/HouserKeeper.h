//
//  HouserKeeper.h
//  RideHousekeeper
//
//  Created by 同时科技 on 16/6/20.
//  Copyright © 2016年 Duke Wu. All rights reserved.
//

#import <Availability.h>

#ifndef __IPHONE_5_0
#warning "This project uses features only available in iOS SDK 5.0 and later."
#endif

#ifdef __OBJC__
//#define HouserKeeper_h

#ifndef DEBUG
#undef NSLog
#define NSLog(args, ...)
#endif

#ifdef DEBUG
//#define QGJURL @"https://api.d.smart-qgj.cn/"
#define QGJURL @"https://xinri.api.smart-qgj.cn/" //新日远程访问ip
#else
#define QGJURL @"https://xinri.api.smart-qgj.cn/" //新日远程访问ip
#endif

#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height
#define MainColor @"#131313"
#define GradientColor @"#4469AB"

#define NAVI_TEST_APP_KEY   @"bYEk1tBfAFtnfLj2Blr6FxDTaTaW1l4D"  //sdk自测APP KEY
#define NAVI_TTS_APP_KEY   @"11656920"
#define BUGLY_APP_ID @"335ec4dba0"
#define STOREAPPID @"1493246065"
#define logInUSERDIC      @"logInUserDic"     // 登录用户中心
#define passwordDIC      @"passwordDIC"     // 密码所有
#define userInfoDic      @"userInfoDic"     // 用户信息
#define SETRSSI @"selected"
#define APPID_VALUE @"576a6330"
#define Downloadfile @"test.zip"
#define BLE_MAIN_RESTORE_IDENTIFIER @"XRCentralManagerIdentifier"
#define baidu @"http://api.map.baidu.com/telematics/v3/weather"
#define apple @"http://itunes.apple.com/cn/lookup"

#define TIP_OF_NO_NETWORK NSLocalizedString(@"no_network_connect", nil)

// 判断是否是ipad
#define isPad ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
// 判断iPhone4系列
#define kiPhone4 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) && !isPad : NO)
// 判断iPhone5系列
#define kiPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) && !isPad : NO)
// 判断iPhone6系列
#define kiPhone6 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) && !isPad : NO)
//判断iphone6+系列
#define kiPhone6Plus ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size) && !isPad : NO)
// 判断iPhoneX
#define IS_IPHONE_X ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) && !isPad : NO)
// 判断iPHoneXr
#define IS_IPHONE_Xr ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(828, 1792), [[UIScreen mainScreen] currentMode].size) && !isPad : NO)
// 判断iPhoneXs
#define IS_IPHONE_Xs ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) && !isPad : NO)
// 判断iPhoneXs Max
#define IS_IPHONE_Xs_Max ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2688), [[UIScreen mainScreen] currentMode].size) && !isPad : NO)

#define Height_StatusBar ((IS_IPHONE_X == YES || IS_IPHONE_Xr == YES || IS_IPHONE_Xs == YES || IS_IPHONE_Xs_Max == YES) ? 44.0 : 20.0)
#define Height_NavBar ((IS_IPHONE_X == YES || IS_IPHONE_Xr == YES || IS_IPHONE_Xs == YES || IS_IPHONE_Xs_Max == YES) ? 88.0 : 64.0)
#define Height_TabBar ((IS_IPHONE_X == YES || IS_IPHONE_Xr == YES || IS_IPHONE_Xs == YES || IS_IPHONE_Xs_Max == YES) ? 83.0 : 49.0)

#define IOS8 ([[UIDevice currentDevice].systemVersion intValue] >= 8 ? YES : NO)

#define LL_MoreStatusBarHeight  ((IS_IPHONE_X == YES || IS_IPHONE_Xr == YES || IS_IPHONE_Xs == YES || IS_IPHONE_Xs_Max == YES) ? 24.f : 0.f)
#define navHeight  ((IS_IPHONE_X == YES || IS_IPHONE_Xr == YES || IS_IPHONE_Xs == YES || IS_IPHONE_Xs_Max == YES) ? 88.0 : 64.0)
#define tabHeight  ((IS_IPHONE_X == YES || IS_IPHONE_Xr == YES || IS_IPHONE_Xs == YES || IS_IPHONE_Xs_Max == YES) ? (49.f+34.f) : 49.f)
#define QGJ_TabbarSafeBottomMargin   ((IS_IPHONE_X == YES || IS_IPHONE_Xr == YES || IS_IPHONE_Xs == YES || IS_IPHONE_Xs_Max == YES) ? 34.f : 0.f)
#define KStatusBarHeight ((IS_IPHONE_X == YES || IS_IPHONE_Xr == YES || IS_IPHONE_Xs == YES || IS_IPHONE_Xs_Max == YES) ? 24.f:0.f)
#define KStatusBarMargin ((IS_IPHONE_X == YES || IS_IPHONE_Xr == YES || IS_IPHONE_Xs == YES || IS_IPHONE_Xs_Max == YES) ? 22.f:0.f)

#import "UIView+Extension.h"
#import "BaseViewController.h"
#import "AppDelegate.h"
#import "QFTools.h"
#import "ConverUtil.h"
#import "SVProgressHUD.h"
#import "AFNetworking.h"
#import "MSWeakTimer.h"
#import "LoadView.h"
#import "YYModel.h"
#import "sqliteModel.h"
#import "AnnotatedHeader.h"
#import "UIImageView+WebCache.h"
#import "UINavigationController+FDFullscreenPopGesture.h"
#import "UIView+LMExtension.h"
#import "UIImageView+LMExtension.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "Masonry.h"
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>


#define HI_UINT16(a) (((a) >> 8) & 0xff)

#define LO_UINT16(a) ((a) & 0xff)

#define BUILD_UINT16(loByte, hiByte) ((uint16_t)(((loByte) & 0x00FF) + (((hiByte) & 0x00FF) << 8)))

#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]

//#define FONT_YAHEI(s) [UIFont fontWithName:@"PingFang Regular" size:s]
#define FONT_ZITI(s) [UIFont fontWithName:@"094-CAI978" size:s]
#define FONT_PINGFAN(s) [UIFont fontWithName:@"PingFangTC-Regular" size:s]
#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;

// 是否是iOS7
#define iOS7 ([UIDevice currentDevice].systemVersion.doubleValue >= 7.0)

#define PATHS NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES)

#define HCRandomColor [UIColor colorWithRed:arc4random_uniform(255)/255.0 green:arc4random_uniform(255)/255.0 blue:arc4random_uniform(255)/255.0 alpha:arc4random_uniform(255)/255.0]

#endif /* HouserKeeper_h */
