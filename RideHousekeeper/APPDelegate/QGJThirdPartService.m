//
//  QGJThirdPartService.m
//  RideHousekeeper
//
//  Created by Apple on 2017/6/9.
//  Copyright © 2017年 Duke Wu. All rights reserved.
//

#import "QGJThirdPartService.h"
#import "sys/utsname.h"
#import <Bugly/Bugly.h>

@interface QGJThirdPartService ()<BuglyDelegate>

@end

@implementation QGJThirdPartService

+ (void)load {
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        [[self class] setupBugly];
        [[self class] setupLFY];
    });
}

+ (void)setupBugly {
    // Get the default config
    BuglyConfig * config = [[BuglyConfig alloc] init];
    config.debugMode = YES;
    config.blockMonitorEnable = YES;
    config.blockMonitorTimeout = 1.5;
    config.channel = @"Bugly";
    config.delegate = (id)self;
    config.consolelogEnable = NO;
    config.viewControllerTrackingEnable = NO;
    [Bugly startWithAppId:BUGLY_APP_ID
#if DEBUG
        developmentDevice:YES
#endif
                    config:config];
    
    // Set the customizd tag thats config in your APP registerd on the  bugly.qq.com
    // [Bugly setTag:1799];
    [Bugly setUserIdentifier:[NSString stringWithFormat:@"User: %@", [UIDevice currentDevice].name]];
    [Bugly setUserValue:[NSProcessInfo processInfo].processName forKey:@"Process"];
}

#pragma mark - BuglyDelegate
- (NSString *)attachmentForException:(NSException *)exception {
    NSLog(@"(%@:%d) %s %@",[[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, __PRETTY_FUNCTION__,exception);
    
    return @"This is an attachment";
}


+(void)setupLFY{

    
}


@end
