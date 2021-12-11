//
//  AppDelegate.m
//  RideHousekeeper
//
//  Created by 同时科技 on 16/6/20.
//  Copyright © 2016年 Duke Wu. All rights reserved.
//

#import "AppDelegate.h"
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Base/BMKBaseComponent.h>
#import <BMKLocationkit/BMKLocationComponent.h>
#import <AlipaySDK/AlipaySDK.h>
#import "WXApiManager.h"
#import "QGJThirdPartService.h"
#import "BaseNavigationController.h"
#import "SideMenuViewController.h"
#import "LoginViewController.h"
#import "AddBikeViewController.h"
#import "BikeViewController.h"
#import "AppDelegate+Login.h"
#import "AppDelegate+GetBikeList.h"
#import "AppDelegate+CheckUpdate.h"
#import "AppDelegate+WYDeviceServices.h"
#import "ABCIntroView.h"
#import "AvoidCrash.h"//崩溃异常捕获第三方库
#import <Bugly/Bugly.h>
#import "JPUSHService.h"
#import "AlipayApiManager.h"
// iOS10注册APNs所需头文件
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif

//#define NAVI_TEST_BUNDLE_ID @"com.baidu.navitest"  //sdk自测bundle ID
@interface AppDelegate ()<BMKLocationAuthDelegate,BMKGeneralDelegate,UIAlertViewDelegate,JPUSHRegisterDelegate,ABCIntroViewDelegate>
{
    BMKMapManager* _mapManager;
}
    @property (nonatomic, strong) ABCIntroView *introView;
    @property (nonatomic, strong)UIAlertView *BluetoothAlertView;
    @property (retain, nonatomic ) CBCentralManager *centralManager;
@end


@implementation AppDelegate

#pragma mark - UIAlertViewDelegate
    
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
    {
        if (alertView.tag == 5555) {
            if (buttonIndex != [alertView cancelButtonIndex]) {
                
                NSURL * url= [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                
                if (@available(iOS 10.0, *)) {
                    NSDictionary *options = @{UIApplicationOpenURLOptionsSourceApplicationKey : @YES};
                    [[UIApplication sharedApplication] openURL:url options:options completionHandler:nil];
                } else {
                    // Fallback on earlier versions
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                }
            }
            self.BluetoothAlertView = nil;
        }else if (alertView.tag == 3000) {
            if (buttonIndex != [alertView cancelButtonIndex]) {
                
                NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://itunes.apple.com/us/app/id%@?ls=1&mt=8", STOREAPPID]];
                [[UIApplication sharedApplication] openURL:url];
        }
    }
}

-(void)mbluetoohPowerOff{
    [[APPStatusManager sharedManager] setBLEStstus:NO];
    [NSNOTIC_CENTER postNotificationName:KNotification_BluetoothPowerOff object:nil];
    _BluetoothAlertView = [[UIAlertView alloc]initWithTitle:@"提示" message:NSLocalizedString( @"当前蓝牙未打开,是否打开", @"") delegate:self cancelButtonTitle:NSLocalizedString( @"取消", @"") otherButtonTitles:@"打开", nil];
    _BluetoothAlertView.tag = 5555;
    [_BluetoothAlertView show];
    //CBCentralManger代表方法在iOS 11和以下iOS 11中的行为有所不同
    if (@available(iOS 11, *)){
        //手动调用断开连接
        [CommandDistributionServices removePeripheral:nil];
        [NSNOTIC_CENTER postNotificationName:KNotification_ConnectStatus object:@YES];
    }
}
    
-(void)mbluetoohPowerOn{
    [[APPStatusManager sharedManager] setBLEStstus:YES];
    [NSNOTIC_CENTER postNotificationName:KNotification_BluetoothPowerOn object:nil];
    [_BluetoothAlertView dismissWithClickedButtonIndex:0 animated:YES];
    _BluetoothAlertView = nil;
    if ([[QFTools currentViewController] isKindOfClass:[AddBikeViewController class]]) {
        return;
    }
}
    
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSArray *centralManagerIdentifiers = launchOptions[UIApplicationLaunchOptionsBluetoothCentralsKey];
    
    if (centralManagerIdentifiers.count) {
        //重新初始化所有的 manager
        for (NSString *identifier in centralManagerIdentifiers) {
            NSLog(@"系统启动项目");
            //在这里创建的蓝牙实例一定要被当前类持有，不然出了这个函数就被销毁了，蓝牙检测会出现“XPC connection invalid”
            self.centralManager = [CommandDistributionServices restoreCentralManager:identifier];
        }
    }

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [SVProgressHUD setCornerRadius:5];
    [[UITextField appearance] setTintColor:[QFTools colorWithHexString:MainColor]];
    if (@available(iOS 11.0, *)){
        [[UIScrollView appearance] setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
        UITableView.appearance.estimatedRowHeight = 0;
        UITableView.appearance.estimatedSectionFooterHeight = 0;
        UITableView.appearance.estimatedSectionHeaderHeight = 0;
    }
    
    // 模式强制切换
//    if (darkMode) {
//        if (@available(iOS 13.0, *)) {
//            [UIApplication sharedApplication].keyWindow.overrideUserInterfaceStyle = UIUserInterfaceStyleDark;
//        }
//    } else {
//        if (@available(iOS 13.0, *)) {
//            [UIApplication sharedApplication].keyWindow.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
//        }
//    }
    [[HttpRequest sharedInstance] networkMonitor];
    
    if (![launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]) {
        [self logindata:nil];
    }
    
    [self updateApp];
    
    [self avoidCrash];
    
    [self monitorConnectStatus];
    
    [self monitorBLEStatus];
    
    [self monitorBikeStatusModelCallback];
    
    // 要使用百度地图，请先启动BaiduMapManager
    [[BMKLocationAuth sharedInstance] checkPermisionWithKey:NAVI_TEST_APP_KEY authDelegate:self];
    _mapManager = [[BMKMapManager alloc]init];
    [_mapManager start:NAVI_TEST_APP_KEY generalDelegate:self];
    //支付宝
    //[[AlipaySDK defaultService] setUrl:@"https://openapi.alipay.com/gateway.do"];
    //[[AlipaySDK defaultService] fetchSdkConfigWithBlock:^(BOOL success) {
    //
    //}];
    //向微信注册,发起支付必须注册
    [WXApi registerApp:@"wx626378f982b5c01d" universalLink:@"https://www.smart-qgj.com/"];
    [NSNOTIC_CENTER addObserver:self selector:@selector(loginStateChange:) name:KNOTIFICATION_LOGINCHANGE object:nil];
    
    // 3.0.0及以后版本注册可以这样写，也可以继续用旧的注册方式
    JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
    entity.types = JPAuthorizationOptionAlert|JPAuthorizationOptionBadge|JPAuthorizationOptionSound;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        //可以添加自定义categories
            if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) {
              NSSet<UNNotificationCategory *> *categories;
              entity.categories = categories;
            }
            else {
              NSSet<UIUserNotificationCategory *> *categories;
              entity.categories = categories;
            }
    }
    
    [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
    //如不需要使用IDFA，advertisingIdentifier 可为nil
    [JPUSHService setupWithOption:launchOptions appKey:JPush_key channel:@"Publish channel" apsForProduction:false advertisingIdentifier:nil];
    [JPUSHService setLogOFF];
    //2.1.9版本新增获取registration id block接口。
    [JPUSHService registrationIDCompletionHandler:^(int resCode, NSString *registrationID) {
        if(resCode == 0){
            
            NSLog(@"registrationID获取成功：%@",registrationID);
        }else{
            
            NSLog(@"registrationID获取失败，code：%d",resCode);
        }
    }];
    
    [self loginStateChange:nil];
    
    [self.window makeKeyAndVisible];
    
    if (![USER_DEFAULTS boolForKey:@"new_intro_screen_viewed"]) {
        [USER_DEFAULTS setBool:YES forKey:@"new_intro_screen_viewed"];
        _introView = [[ABCIntroView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
        _introView.delegate = self;
        _introView.backgroundColor = [UIColor whiteColor];
        [[UIApplication sharedApplication].keyWindow addSubview:_introView];
    }
            
    return YES;
}
    
#pragma mark - ABCIntroViewDelegate Methods
    
-(void)onDoneButtonPressed{
    
    [UIView animateWithDuration:1.0 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.introView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.introView removeFromSuperview];
        self.introView = nil;
    }];
}


#pragma mark - private
    //登陆状态改变
- (void)loginStateChange:(NSNotification *)notification{
    
    UIViewController *nav = nil;
    BOOL loginSuccess = [notification.object boolValue];
    if (![QFTools isBlankString:[QFTools getdata:@"phone_num"]] || loginSuccess) {//登陆成功加载主窗口控制器
        NSMutableArray *bikearray = [LVFmdbTool queryBikeData:nil];
        if (bikearray.count >0) {
            if ([_mainController isKindOfClass:[BikeViewController class]]) {
                [self clearAllModalView];
                BaseNavigationController *navOne = [[BaseNavigationController alloc] initWithRootViewController:_mainController];
                nav = [[XYSideViewController alloc] initWithSideVC:[[SideMenuViewController alloc] init] currentVC:navOne change:NO];
            }else{
                [self clearAllModalView];
                _mainController = nil;
                _mainController = [[BikeViewController alloc] init];
                BaseNavigationController *navOne = [[BaseNavigationController alloc] initWithRootViewController:_mainController];
                nav = [[XYSideViewController alloc] initWithSideVC:[[SideMenuViewController alloc] init] currentVC:navOne change:NO];
            }
        }else{
            if ([_mainController isKindOfClass:[AddBikeViewController class]]) {
                
                [self clearAllModalView];
                nav  = _mainController.navigationController;
            }else{
                [self clearAllModalView];
                _mainController = nil;
                _mainController = [[AddBikeViewController alloc] init];
                nav = [[BaseNavigationController alloc] initWithRootViewController:_mainController];
            }
        }
        
    }else{//登陆失败加载登陆页面控制器
        
        [self clearAllModalView];
        _mainController = nil;
        LoginViewController *loginController = [[LoginViewController alloc] init];
        nav = [[BaseNavigationController alloc] initWithRootViewController:loginController];
    }
    
    CATransition *anima = [CATransition animation];
    anima.type = @"fade";//设置动画的类型
    anima.subtype = kCATransitionFromRight; //设置动画的方向
    anima.duration = 0.3f;
    
    self.window.rootViewController = nav;
    [[UIApplication sharedApplication].delegate.window.layer addAnimation:anima forKey:@"revealAnimation"];
}
    
-(void)clearAllModalView{
    if (_mainController.presentedViewController != nil) {
        [_mainController dismissViewControllerAnimated:false completion:nil];
    }
}
    
+ (AppDelegate *)currentAppDelegate{
    
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    NSLog(@"%@", [NSString stringWithFormat:@"Device Token: %@", deviceToken]);
    [JPUSHService registerDeviceToken:deviceToken];
}
    
    
- (void)application:(UIApplication *)application
didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
}
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_7_1
- (void)application:(UIApplication *)application
didRegisterUserNotificationSettings:
(UIUserNotificationSettings *)notificationSettings {
    
}
    
    // Called when your app has been activated by the user selecting an action from
    // a local notification.
    // A nil action identifier indicates the default action.
    // You should call the completion handler as soon as you've finished handling
    // the action.
- (void)application:(UIApplication *)application
handleActionWithIdentifier:(NSString *)identifier
forLocalNotification:(UILocalNotification *)notification
  completionHandler:(void (^)())completionHandler {
    
}
    
    // Called when your app has been activated by the user selecting an action from
    // a remote notification.
    // A nil action identifier indicates the default action.
    // You should call the completion handler as soon as you've finished handling
    // the action.
- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler {
    
}
#endif
    
- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [JPUSHService handleRemoteNotification:userInfo];
    //NSLog(@"iOS6及以下系统收到通知:%@", [self logDic:userInfo]);
}
    
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    [JPUSHService handleRemoteNotification:userInfo];
    //NSLog(@"iOS7及以上系统收到通知:%@", [self logDic:userInfo]);
    [self JPushOperation:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
}
    
- (void)application:(UIApplication *)application
didReceiveLocalNotification:(UILocalNotification *)notification {
    
    [JPUSHService showLocalNotificationAtFront:notification identifierKey:nil];
    
}
    
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#pragma mark- JPUSHRegisterDelegate
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler {
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    [JPUSHService setBadge:0];
    
    NSDictionary * userInfo = notification.request.content.userInfo;
    
    UNNotificationRequest *request = notification.request; // 收到推送的请求
    UNNotificationContent *content = request.content; // 收到推送的消息内容
    
    NSNumber *badge = content.badge;  // 推送消息的角标
    NSString *body = content.body;    // 推送消息体
    UNNotificationSound *sound = content.sound;  // 推送消息的声音
    NSString *subtitle = content.subtitle;  // 推送消息的副标题
    NSString *title = content.title;  // 推送消息的标题
    
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
        //NSLog(@"iOS10 前台收到远程通知:%@", [self logDic:userInfo]);
        //[self JPushOperation:userInfo];
    }else {
        // 判断为本地通知
        //NSLog(@"iOS10 前台收到本地通知:{\nbody:%@，\ntitle:%@,\nsubtitle:%@,\nbadge：%@，\nsound：%@，\nuserInfo：%@\n}",body,title,subtitle,badge,sound,userInfo);
    }
    completionHandler(UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionSound|UNNotificationPresentationOptionAlert); // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以设置
}
    
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    [JPUSHService setBadge:0];
    
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    UNNotificationRequest *request = response.notification.request; // 收到推送的请求
    UNNotificationContent *content = request.content; // 收到推送的消息内容
    
    NSNumber *badge = content.badge;  // 推送消息的角标
    NSString *body = content.body;    // 推送消息体
    UNNotificationSound *sound = content.sound;  // 推送消息的声音
    NSString *subtitle = content.subtitle;  // 推送消息的副标题
    NSString *title = content.title;  // 推送消息的标题
    
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
        //NSLog(@"iOS10 收到远程通知:%@", [self logDic:userInfo]);
        [self JPushOperation:userInfo];
    }else {
        // 判断为本地通知
        //NSLog(@"iOS10 收到本地通知:{\nbody:%@，\ntitle:%@,\nsubtitle:%@,\nbadge：%@，\nsound：%@，\nuserInfo：%@\n}",body,title,subtitle,badge,sound,userInfo);
    }
    
    completionHandler();  // 系统要求执行这个方法
}

- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center openSettingsForNotification:(UNNotification *)notification{
    
}

#endif
    
    // log NSSet with UTF8
    // if not ,log will be \Uxxx
- (NSString *)logDic:(NSDictionary *)dic {
    if (![dic count]) {
        return nil;
    }
    NSString *tempStr1 =
    [[dic description] stringByReplacingOccurrencesOfString:@"\\u"
                                                 withString:@"\\U"];
    NSString *tempStr2 =
    [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString *tempStr3 =
    [[@"\"" stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    NSString *str =
    [NSPropertyListSerialization propertyListFromData:tempData
                                     mutabilityOption:NSPropertyListImmutable
                                               format:NULL
                                     errorDescription:NULL];
    return str;
}
    
-(void)JPushOperation:(NSDictionary *)userInfo{
    NSLog(@"iOS7及以上系统收到通知");
    JpushModel *pushModel = [JpushModel yy_modelWithDictionary:userInfo];
    NSNumber *bikeid = @(pushModel.bike_id);
    NSNumber *type = @(pushModel.type);
    if (pushModel.category != 0) {
        JPushDataModel *model = [JPushDataModel modalWith:pushModel.bike_id userid:pushModel.user_id type:pushModel.type title:pushModel.title content:pushModel.content category:pushModel.category time:[QFTools stringFromInt:nil :pushModel.ts]];
        BOOL inseart = [LVFmdbTool insertJPushDataModel:model];
        if (inseart) {
            NSLog(@"插入成功");
        }else{
            NSLog(@"插入失败");
        }
    }
    if ([QFTools isBlankString:[QFTools getdata:@"phone_num"]]) {
        
        return;
    }else if (type.intValue < 1 || type.intValue > 4){
        
        if (pushModel.type == 7) {
            [NSNOTIC_CENTER postNotificationName:KNOTIFICATION_UPDATEORDERLIST object:nil];
        }else if (type.intValue == 8) {
            
            if ([QFTools isBlankString:[QFTools getdata:@"phone_num"]]) {
                return;
            }
            
            [[HttpRequest sharedInstance] cancelRequest];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [SVProgressHUD showSimpleText:@"账号已在其它设备上登录"];
            });
        }
        return;//不是车辆信息更新信息，不需要刷新本地数据
    }
    
    NSDictionary *jpushDict =[[NSDictionary alloc] initWithObjectsAndKeys:bikeid,@"bikeid",type,@"type", nil];
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [self getbikelist:jpushDict];
        
        dispatch_group_leave(group);
    });
    dispatch_group_enter(group);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"second API got data");
        dispatch_group_leave(group);
    });
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        //更新主界面
        
    });
}
    
- (UIInterfaceOrientationMask) application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {

    //id presentedViewController = [window.rootViewController presentedViewController];

    //NSString *className = presentedViewController ? NSStringFromClass([presentedViewController class]) : nil;

    // NSString *className1 = [self.window.subviews.lastObject class].description;

    //return UIInterfaceOrientationMaskPortrait;
    return self.window.rootViewController.supportedInterfaceOrientations;
}

    
    //app当有电话进来或者锁屏，这时你的应用程会挂起调用
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
}
    
- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    //[application setApplicationIconBadgeNumber:1];
    [application setApplicationIconBadgeNumber:0];
    [application cancelAllLocalNotifications];
}
    
- (void)applicationWillEnterForeground:(UIApplication *)application {
    
    //[application setApplicationIconBadgeNumber:1];
    [application setApplicationIconBadgeNumber:0];
    [application cancelAllLocalNotifications];
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}
    //app进入前台
- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    if ([[APPStatusManager sharedManager] getUpdatePaymentStatus]) {
        NSLog(@"前台APP支付状态检测");
        [[APPStatusManager sharedManager] setUpdatePaymentStatus:NO];
        [NSNOTIC_CENTER postNotificationName:KNOTIFICATION_UPDATEORDERLIST object:nil];
    }
}
    
    //crash 会调用的接口
- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    
}

- (void)onGetNetworkState:(int)iError
    {
        if (0 == iError) {
            NSLog(@"联网成功");
        }else{
            NSLog(@"onGetNetworkState %d",iError);
        }
        
    }
    
- (void)onGetPermissionState:(int)iError
    {
        if (0 == iError) {
            NSLog(@"授权成功");
        }else {
            NSLog(@"onGetPermissionState %d",iError);
        }
    }
    
- (void)avoidCrash {
    
    /*
     * 项目初期不需要对"unrecognized selector sent to instance"错误进行处理，因为还没有相关的崩溃的类
     * 后期出现后，再使用makeAllEffective方法，把所有对应崩溃的类添加到数组中，避免崩溃
     * 对于正式线可以启用该方法，测试线建议关闭该方法
     */
    [AvoidCrash becomeEffective];
    
    //    [AvoidCrash makeAllEffective];
    //    NSArray *noneSelClassStrings = @[
    //                                     @"NSString"
    //                                     ];
    
    //    [AvoidCrash setupNoneSelClassStringsArr:noneSelClassStrings];
    
    //监听通知:AvoidCrashNotification, 获取AvoidCrash捕获的崩溃日志的详细信息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dealwithCrashMessage:) name:AvoidCrashNotification object:nil];
}

//AvoidCrash异常通知监听方法，在这里我们可以调用reportException方法进行上报
- (void)dealwithCrashMessage:(NSNotification *)notification {
    NSLog(@"\n🚫\n🚫监测到崩溃信息🚫\n🚫\n");
    
    NSException *exception = [NSException exceptionWithName:@"AvoidCrash" reason:[notification valueForKeyPath:@"userInfo.errorName"] userInfo:notification.userInfo];
    [Bugly reportException:exception];
}

#pragma mark - 第三方SDK回调
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if ([url.host isEqualToString:@"safepay"]) {
        // 支付跳转支付宝钱包进行支付，处理支付结果
        [[AlipayApiManager sharedManager] processOrderWithPaymentResult:url];
        // 授权跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processAuth_V2Result:url standbyCallback:^(NSDictionary *resultDic) {
            NSLog(@"result = %@",resultDic);
            // 解析 auth code
            NSString *result = resultDic[@"result"];
            NSString *authCode = nil;
            if (result.length>0) {
                NSArray *resultArr = [result componentsSeparatedByString:@"&"];
                for (NSString *subResult in resultArr) {
                    if (subResult.length > 10 && [subResult hasPrefix:@"auth_code="]) {
                        authCode = [subResult substringFromIndex:10];
                        break;
                    }
                }
            }
            NSLog(@"授权结果 authCode = %@", authCode?:@"");
        }];
    }else if ([url.host isEqualToString:@"pay"]){
        return [WXApi handleOpenURL:url delegate:[WXApiManager sharedManager]];
    }
    return YES;
}

// NOTE: 9.0以后使用新API接口
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options
{
    if ([url.host isEqualToString:@"safepay"]) {
        // 支付跳转支付宝钱包进行支付，处理支付结果
        [[AlipayApiManager sharedManager] processOrderWithPaymentResult:url];
        
        // 授权跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processAuth_V2Result:url standbyCallback:^(NSDictionary *resultDic) {
            NSLog(@"result = %@",resultDic);
            // 解析 auth code
            NSString *result = resultDic[@"result"];
            NSString *authCode = nil;
            if (result.length>0) {
                NSArray *resultArr = [result componentsSeparatedByString:@"&"];
                for (NSString *subResult in resultArr) {
                    if (subResult.length > 10 && [subResult hasPrefix:@"auth_code="]) {
                        authCode = [subResult substringFromIndex:10];
                        break;
                    }
                }
            }
            NSLog(@"授权结果 authCode = %@", authCode?:@"");
        }];
    }else if ([url.host isEqualToString:@"pay"]){
        return  [WXApi handleOpenURL:url delegate:[WXApiManager sharedManager]];
    }
    return YES;
}

@end
