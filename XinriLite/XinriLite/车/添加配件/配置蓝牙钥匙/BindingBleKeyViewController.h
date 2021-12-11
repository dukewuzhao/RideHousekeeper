//
//  BindingBleKeyViewController.h
//  RideHousekeeper
//
//  Created by Apple on 2019/2/13.
//  Copyright © 2019年 Duke Wu. All rights reserved.
//

#import "BaseViewController.h"

@protocol BindingBlekeyDelegate <NSObject>

@required
- (void)bidingBleKeyOver;

@end

NS_ASSUME_NONNULL_BEGIN

@interface BindingBleKeyViewController : BaseViewController

@property(nonatomic,assign) NSInteger deviceNum;
@property(nonatomic,assign) NSInteger seq;
@property (nonatomic, weak) id<BindingBlekeyDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
