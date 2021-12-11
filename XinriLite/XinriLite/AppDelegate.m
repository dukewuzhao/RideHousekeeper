//
//  AppDelegate.m
//  RideHousekeeper
//
//  Created by 同时科技 on 16/6/20.
//  Copyright © 2016年 Duke Wu. All rights reserved.
//

#import "AppDelegate.h"
#import "QGJThirdPartService.h"
#import "BaseNavigationController.h"
#import "AddBikeViewController.h"
#import "AvoidCrash.h"//崩溃异常捕获第三方库
#import <Bugly/Bugly.h>
#import "DGLabel.h"
#import "AppDelegate+CheckUpdate.h"
#import "BikeViewController.h"

//#define NAVI_TEST_BUNDLE_ID @"com.baidu.navitest"  //sdk自测bundle ID
@interface AppDelegate ()<DeviceDelegate,UIAlertViewDelegate>{
    
    NSString *child;
    NSString *main;
    }
@property (nonatomic, strong) NSMutableArray *macArrM;
@property (nonatomic, strong) NSMutableArray *passwordArrM;
@property (nonatomic, strong)UIAlertView *BluetoothAlertView;
    
@end


@implementation AppDelegate
    
- (NSMutableArray *)macArrM {
    if (!_macArrM) {
        _macArrM = [[NSMutableArray alloc] init];
    }
    return _macArrM;
}
    
- (NSMutableArray *)passwordArrM {
    if (!_passwordArrM) {
        _passwordArrM = [[NSMutableArray alloc] init];
    }
    return _passwordArrM;
}
    
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
    
-(void)mbluetoohPowerOff:(NSNotification *)notification{
    
    int devicetag=[notification.object intValue];
    
    if(devicetag == _device.tag){
        
        self.BluetoothAlertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"reminders", nil) message:NSLocalizedString(@"bluetooth_status", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"sure", nil), nil];
        self.BluetoothAlertView.tag = 5555;
        [self.BluetoothAlertView show];
    }
    
    if(_device.deviceStatus>=2&&_device.deviceStatus<5){
        
        _device.deviceStatus=0;
        [NSNOTIC_CENTER postNotification:[NSNotification notificationWithName:KNotification_UpdateDeviceStatus object:nil]];
    }
}
    
-(void)mbluetoohPowerOn:(NSNotification *)notification{
    int devicetag=[notification.object intValue];
    
    if(devicetag ==_device.tag){
        
        [self.BluetoothAlertView dismissWithClickedButtonIndex:0 animated:YES];
        self.BluetoothAlertView = nil;
        NSString*deviceuuid=[USER_DEFAULTS stringForKey:Key_DeviceUUID];
        if ([[QFTools currentViewController] isKindOfClass:[AddBikeViewController class]]) {
            return;
        }
        if (deviceuuid) {
            [_device retrievePeripheralWithUUID:deviceuuid];//导入外设 根据UUID
            [_device connect];
        }
    }
}
    
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSArray *centralManagerIdentifiers = launchOptions[UIApplicationLaunchOptionsBluetoothCentralsKey];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self avoidCrash];//异常捕获防止crash
    
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    //设置HUD和文本的颜色
    //[SVProgressHUD setForegroundColor:[UIColor greenColor]];
    //设置HUD背景颜色
    //[SVProgressHUD setBackgroundColor:[UIColor magentaColor]];
    //设置提示框的边角弯曲半径
    [SVProgressHUD setCornerRadius:5];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    if (@available(iOS 11.0, *)){
        [[UIScrollView appearance] setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
        UITableView.appearance.estimatedRowHeight = 0;
        UITableView.appearance.estimatedSectionFooterHeight = 0;
        UITableView.appearance.estimatedSectionHeaderHeight = 0;
    }
    
    [NSNOTIC_CENTER addObserver:self selector:@selector(mbluetoohPowerOff:) name:KNotification_BluetoothPowerOff object:nil];
    
    [NSNOTIC_CENTER addObserver:self selector:@selector(mbluetoohPowerOn:) name:KNotification_BluetoothPowerOn object:nil];
    
    _device =[[WYDevice alloc]init ];
    
    _device.deviceDelegate=self;
    
    [NSNOTIC_CENTER addObserver:self selector:@selector(loginStateChange:) name:KNOTIFICATION_LOGINCHANGE object:nil];
    
    //[self updateApp];
    
    [self loginStateChange:nil];
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

#pragma mark - 蓝牙连接回调
    
- (void)didConnect:(NSInteger)tag :(CBPeripheral *)peripheral
    {
        _device.deviceStatus=2;
        
        if (_device.binding) {
            [NSNOTIC_CENTER postNotification:[NSNotification notificationWithName:KNotification_ConnectStatus object:nil]];
        }else{
            [NSNOTIC_CENTER postNotification:[NSNotification notificationWithName:KNotification_UpdateDeviceStatus object:nil]];
        }
    }
    
- (void)didDisconnect:(NSInteger)tag :(CBPeripheral *)peripheral
    {
        _device.deviceStatus=0;
        [NSNOTIC_CENTER postNotification:[NSNotification notificationWithName:KNotification_UpdateDeviceStatus object:nil]];
    }
    
    
    
#pragma mark---接收到了数据 蓝牙indication
- (void)didGetSensorData:(NSInteger)tag :(NSData *)data :(CBPeripheral *)peripheral{
    
    NSString *result = [ConverUtil data2HexString:data];
    //NSLog(@"返回数据 :%@",result);
    NSDictionary *dict =[[NSDictionary alloc] initWithObjectsAndKeys:result,@"data", nil];
    
    if ([[result substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"1005"]) {
        
        [NSNOTIC_CENTER postNotification:[NSNotification notificationWithName:KNotification_QueryKeyType object:nil userInfo:dict]];
        
    }else if ([[result substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"5001"]){
        
        [NSNOTIC_CENTER postNotification:[NSNotification notificationWithName:KNotification_BindingQGJSuccess object:nil userInfo:dict]];
        
    }else if ([[result substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"3002"] || [[result substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"3007"]){
        
        [NSNOTIC_CENTER postNotification:[NSNotification notificationWithName:KNotification_BindingBLEKEY object:nil userInfo:dict]];
        
    }else if ([[result substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"3004"] || [[result substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"3008"]){
        
        [NSNOTIC_CENTER postNotification:[NSNotification notificationWithName:KNotification_FingerPrint object:nil userInfo:dict]];
        
    }else if ([[result substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"3005"]){
        
        [NSNOTIC_CENTER postNotification:[NSNotification notificationWithName:KNotification_DeleteFinger object:nil userInfo:dict]];
        
    }else if ([[result substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"3006"]){
        
        [NSNOTIC_CENTER postNotification:[NSNotification notificationWithName:KNotification_TestFingerPress object:nil userInfo:dict]];
        
    }else if ([[result substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"2003"] || [[result substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"3003"]){
        
        [NSNOTIC_CENTER postNotification:[NSNotification notificationWithName:KNotification_QueryBleKeyData object:nil userInfo:dict]];
        
    }else if ([[result substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"1003"]){
        
        [NSNOTIC_CENTER postNotification:[NSNotification notificationWithName:KNotification_Bindingkey object:nil userInfo:dict]];
        
    }else if ([[result substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"1007"]){
        
        [NSNOTIC_CENTER postNotification:[NSNotification notificationWithName:KNotification_BindingNewBLEKEY object:nil userInfo:dict]];
        
    }else if ([[result substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"1001"] || [[result substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"1002"] || [[result substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"1004"]){
        
        [NSNOTIC_CENTER postNotification:[NSNotification notificationWithName:KNotification_QueryData object:nil userInfo:dict]];
    }else if ([[result substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"5002"]){
        
        [NSNOTIC_CENTER postNotification:[NSNotification notificationWithName:KNotification_SupportableAccessories object:nil userInfo:dict]];
    }
}

    
#pragma mark---接收到了数据 读蓝牙中的报警器的mac地址
- (void)didGetBurglarCharData:(NSInteger)tag :(NSData *)data :(CBPeripheral *)peripheral
    {
        
        
    }
    
    
    //蓝牙自带的读取固件版本信息
- (void)didGetEditionCharData:(NSInteger)tag :(NSData *)data :(CBPeripheral *)peripheral
    {
        
        NSString *result = [[NSString alloc] initWithData:data  encoding:NSUTF8StringEncoding];
        NSDictionary *dict =[[NSDictionary alloc] initWithObjectsAndKeys:result,@"data", nil];
        [NSNOTIC_CENTER postNotification:[NSNotification notificationWithName:KNotification_UpdateeditionValue object:nil userInfo:dict]];
        
    }
    
    //蓝牙自带的读取硬件版本信息
- (void)didGetVersionCharData:(NSInteger)tag :(NSData *)data :(CBPeripheral *)peripheral
    {
        
        NSString *version = [[NSString alloc] initWithData:data  encoding:NSUTF8StringEncoding];
        NSDictionary *dict =[[NSDictionary alloc] initWithObjectsAndKeys:version,@"data", nil];
        [NSNOTIC_CENTER postNotification:[NSNotification notificationWithName:KNotification_VersionValue object:nil userInfo:dict]];
    }
    

#pragma mark - private
    //登陆状态改变
- (void)loginStateChange:(NSNotification *)notification{
        UINavigationController *nav = nil;
        NSMutableArray *bikearray = [LVFmdbTool queryBikeData:nil];
        if (bikearray.count >0) {
            if ([_mainController isKindOfClass:[BikeViewController class]]) {
                nav = [[BaseNavigationController alloc] initWithRootViewController:_mainController];
            }else{
                _mainController = nil;
                _mainController = [[BikeViewController alloc] init];
                nav = [[BaseNavigationController alloc] initWithRootViewController:_mainController];
            }
        }else{
            if ([_mainController isKindOfClass:[AddBikeViewController class]]) {
                nav  = _mainController.navigationController;
            }else{
                _mainController = nil;
                _mainController = [[AddBikeViewController alloc] init];
                nav = [[BaseNavigationController alloc] initWithRootViewController:_mainController];
            }
        }
            
        CATransition *anima = [CATransition animation];
        anima.type = @"fade";//设置动画的类型
        anima.subtype = kCATransitionFromRight; //设置动画的方向
        anima.duration = 0.3f;
        
        self.window.rootViewController = nav;
        [[UIApplication sharedApplication].delegate.window.layer addAnimation:anima forKey:@"revealAnimation"];
    }
    
    
+ (AppDelegate *)currentAppDelegate
    {
        return (AppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
    {
        return YES;
    }
    
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options
    {
        
        return YES;
    }
    

    
- (UIInterfaceOrientationMask) application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    
    //id presentedViewController = [window.rootViewController presentedViewController];
    
    //NSString *className = presentedViewController ? NSStringFromClass([presentedViewController class]) : nil;
    
    // NSString *className1 = [self.window.subviews.lastObject class].description;
    
    return UIInterfaceOrientationMaskPortrait;
    
}
    
    
    //app当有电话进来或者锁屏，这时你的应用程会挂起调用
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
}
    
- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
}
    
- (void)applicationWillEnterForeground:(UIApplication *)application {
    
    
}
    //app进入前台
- (void)applicationDidBecomeActive:(UIApplication *)application {
    

}
    
    //crash 会调用的接口
- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    
}
    
    //每天进行一次版本判断
- (BOOL)judgeNeedVersionUpdate {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    //获取年-月-日
    NSString *dateString = [formatter stringFromDate:[NSDate date]];
    NSString *currentDate = [USER_DEFAULTS objectForKey:@"currentDate"];
    if ([currentDate isEqualToString:dateString]) {
        return NO;
    }
    [USER_DEFAULTS setObject:dateString forKey:@"currentDate"];
    return YES;
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



    @end
