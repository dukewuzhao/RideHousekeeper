//
//  AlipayApiManager.h
//  RideHousekeeper
//
//  Created by Apple on 2020/4/9.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void(^AlipayApiCallBack)(NSDictionary * _Nullable resultDic);
NS_ASSUME_NONNULL_BEGIN

@interface AlipayApiManager : NSObject

+ (instancetype)sharedManager;
@property(nonatomic,copy)AlipayApiCallBack alipayCallback;

-(void)callAlipay:(NSString *)pay_info fromScheme:(NSString *)appScheme;

-(void)processOrderWithPaymentResult:(NSURL*)url;
@end

NS_ASSUME_NONNULL_END
