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

//#ifndef DEBUG
//#undef NSLog
//#define NSLog(args, ...)
//#endif


#define MainColor @"#06c1ae"
#define GradientColor @"#c4ede8"
#define CellColor [UIColor colorWithWhite:1 alpha:1]
#define SeparatorColor @"#a7a9b0"


#if Target == 1
#define NAVI_TEST_APP_KEY   @"hYo42TqfplKFbxIEYpI7d6pDUzSsT5NG"  //百度sdk APP KEY
#define JPush_key @"801964875e8ff89ec5f10a41"
#define UserAgentHead @"qgjapp"
#ifdef DEBUG
#define BUGLY_APP_ID @"a0e2b1751b"
//#define QGJURL @"https://api.smart-qgj.cn/"
#define QGJURL @"https://api.d.smart-qgj.cn/"
#else
#define BUGLY_APP_ID @"335ec4dba0"
#define QGJURL @"https://api.smart-qgj.cn/" //骑管家远程访问ip
#endif

#elif Target == 2
#define NAVI_TEST_APP_KEY   @"VUOWNiUkqygNVsawdwceA16TaT6b9rZ2"  //百度sdk APP KEY
#define JPush_key @"e73abfabe205bc9c7db32308"
#define UserAgentHead @"qgjapp-niuding"
#ifdef DEBUG
#define BUGLY_APP_ID @"a0e2b1751b"
#define QGJURL @"https://niuding.d.smart-qgj.cn/"
#else
#define BUGLY_APP_ID @"335ec4dba0"
#define QGJURL @"https://api.smart-qgj.cn/" //骑管家远程访问ip
#endif

#endif

#define STOREAPPID @"1172731287"
#define logInUSERDIC      @"logInUserDic"     // 登录用户中心
#define userInfoDic      @"userInfoDic"     // 用户信息

#define APPID_VALUE @"576a6330"
#define BLE_MAIN_RESTORE_IDENTIFIER @"QGJCentralManagerIdentifier"
#define baidu @"http://api.map.baidu.com/telematics/v3/weather"
#define apple @"http://itunes.apple.com/cn/lookup"
#define Downloadfile @"qgj.zip"
#define TIP_OF_NO_NETWORK @"网络未连接,请检查网络配置"
#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

//#define  LL_iPhoneX (ScreenWidth == 375.f && ScreenHeight >= 812.f ? YES : NO)
#define IOS8 ([[UIDevice currentDevice].systemVersion intValue] >= 8 ? YES : NO)
#define  LL_iPhoneX (((int)((ScreenHeight/ScreenWidth)*100) == 216)?YES:NO)
#define  LL_MoreStatusBarHeight  (LL_iPhoneX ? 24.f : 0.f)
#define  navHeight  (LL_iPhoneX ? 88.f : 64.f)
#define  tabHeight  (LL_iPhoneX ? (49.f+34.f) : 49.f)
#define  QGJ_TabbarSafeBottomMargin   (LL_iPhoneX ? 34.f : 0.f)
#define KStatusBarHeight (LL_iPhoneX ? 24.f:0.f)
#define KStatusBarMargin (LL_iPhoneX ? 22.f:0.f)

#import "UIView+Extension.h"
#import "UIImage+PQImage.h"
#import "LxButton.h"
#import "DW_AlertView.h"
#import "UIColor+Expanded.h"
#import "UILabel+LXLabel.h"
#import "UIView+LX_Frame.h"
#import "UIView+FTCornerdious.h"
#import "UIView+LMExtension.h"
#import "UIControl+UIControl_button.h"
#import "UITableView+Placeholder.h"
#import "SGQRCode.h"
#import "BaseViewController.h"
#import "XYSideViewController.h"
#import "UIViewController+XYSideCategory.h"
#import "AppDelegate.h"
#import "QFTools.h"
#import "TFHpple.h"
#import "APPStatusManager.h"
#import "APPPermissionDetectionManager.h"
#import "BLEEnumerate.h"
#import "SelectProcessingtType.h"
#import "CommandDistributionServices.h"
#import "ConverUtil.h"
#import "SVProgressHUD.h"
#import "AFNetworking.h"
#import "HttpRequest.h"
#import "MSWeakTimer.h"
#import "LoadView.h"
#import "YYModel.h"
#import <YYText/YYText.h>
#import <SDWebImage/SDWebImage.h>
#import "httpModel.h"
#import "sqliteModel.h"
#import "AnnotatedHeader.h"
#import "UINavigationController+FDFullscreenPopGesture.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <Lottie/Lottie.h>
#import "Masonry.h"
#import "MJRefresh.h"
#import "TableViewSettingList.h"
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#if __has_include(<YYImage/YYImage.h>)
#import <YYImage/YYImage.h>
#elif __has_include("YYImage.h")
#import "YYImage.h"
#endif

#define HI_UINT16(a) (((a) >> 8) & 0xff)

#define LO_UINT16(a) ((a) & 0xff)

#define BUILD_UINT16(loByte, hiByte) ((uint16_t)(((loByte) & 0x00FF) + (((hiByte) & 0x00FF) << 8)))

#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]

#define FONT_ZITI(s) [UIFont fontWithName:@"094-CAI978" size:s]
#define FONT_PINGFAN(s) [UIFont fontWithName:@"PingFangTC-Regular" size:s]
#define FONT_PINGFAN_BOLD(s) [UIFont fontWithName:@"PingFangTC-Semibold" size:s]

#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;

// 是否是iOS7
#define iOS7 ([UIDevice currentDevice].systemVersion.doubleValue >= 7.0)

#define PATHS NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES)

#define HCRandomColor [UIColor colorWithRed:arc4random_uniform(255)/255.0 green:arc4random_uniform(255)/255.0 blue:arc4random_uniform(255)/255.0 alpha:arc4random_uniform(255)/255.0]

#endif /* HouserKeeper_h */
