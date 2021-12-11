//
//  WXApiManager.h
//  SDKSample
//
//  Created by Jeason on 16/07/2015.
//
//

#import <Foundation/Foundation.h>
#import "WXApiRequestHandler.h"
#import "WXApi.h"

typedef void(^WEChatResp)(BaseResp *resp);
typedef void(^WEChatReq)(BaseReq  *req);

@protocol WXApiManagerDelegate <NSObject>
@optional

@end

@interface WXApiManager : NSObject<WXApiDelegate>

@property (nonatomic, assign) id<WXApiManagerDelegate> delegate;

+ (instancetype)sharedManager;
@property(nonatomic,copy) WEChatResp wechatResp;
@property(nonatomic,copy) WEChatReq wechatReq;



@end
