//
//  OrderDetailViewController.h
//  RideHousekeeper
//
//  Created by Apple on 2020/3/13.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface OrderDetailViewController : BaseViewController
-(void)setOrderInfo:(ServiceOrder *)model bikeid:(NSInteger)bikeid type:(NSUInteger)type;
@end

NS_ASSUME_NONNULL_END
