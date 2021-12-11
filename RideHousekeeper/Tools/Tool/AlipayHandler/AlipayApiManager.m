//
//  AlipayApiManager.m
//  RideHousekeeper
//
//  Created by Apple on 2020/4/9.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import "AlipayApiManager.h"
#import <AlipaySDK/AlipaySDK.h>
@implementation AlipayApiManager

#pragma mark - LifeCycle
+(instancetype)sharedManager {
    static dispatch_once_t onceToken;
    static AlipayApiManager *instance;
    dispatch_once(&onceToken, ^{
        instance = [[AlipayApiManager alloc] init];
    });
    return instance;
}

-(void)callAlipay:(NSString *)pay_info fromScheme:(NSString *)appScheme{
    @weakify(self);
    [[AlipaySDK defaultService] payOrder:pay_info fromScheme:appScheme callback:^(NSDictionary *resultDic) {
        NSLog(@"网页支付回调 = %@",resultDic);
        @strongify(self);
        if (self.alipayCallback) {
            self.alipayCallback(resultDic);
        }
    }];
}

-(void)processOrderWithPaymentResult:(NSURL*)url{
    
    [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
        NSLog(@"支付宝内部回调 = %@",resultDic);
        if (self.alipayCallback) {
            self.alipayCallback(resultDic);
        }
    }];
}

@end
