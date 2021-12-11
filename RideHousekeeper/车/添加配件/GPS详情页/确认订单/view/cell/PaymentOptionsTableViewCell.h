//
//  PaymentOptionsTableViewCell.h
//  RideHousekeeper
//
//  Created by Apple on 2020/3/3.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    SelectNone,     //什么都没选
    WeChat,         //微信
    Alipay          //支付宝
} PayChannel;

NS_ASSUME_NONNULL_BEGIN
typedef void(^SelectPayChannel)(PayChannel code);
@interface PaymentOptionsTableViewCell : UITableViewCell
@property (nonatomic, copy)SelectPayChannel selectPayChannel;
@end

NS_ASSUME_NONNULL_END
