//
//  PayChannelSelectView.h
//  RideHousekeeper
//
//  Created by Apple on 2020/3/18.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^UpdatePayChannelBlock)(BOOL select);
typedef void(^SelectPayChannel)(NSInteger code);
NS_ASSUME_NONNULL_BEGIN

@interface PayChannelSelectView : UIView
@property(nonatomic,copy)UpdatePayChannelBlock updatePayChannelBlock;
@property(nonatomic,copy)SelectPayChannel selectPayChannel;
-(void)setOrderInfo:(ServiceOrder *)model;
@end

@interface PayChannelSelectModel : NSObject
@property(nonatomic,assign)NSInteger channel;
@end


NS_ASSUME_NONNULL_END
