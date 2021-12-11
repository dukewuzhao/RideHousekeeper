//
//  FillPrepaidCardActivationCodeViewController.h
//  RideHousekeeper
//
//  Created by Apple on 2020/3/4.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN
typedef void(^PayOrderSuccess)(void);
@interface FillPrepaidCardActivationCodeViewController : BaseViewController
-(void)setOrderInfo:(ServiceOrder *)model serviceCardModel:(ServiceCard *)cardModel bikeid:(NSInteger)bikeid;
@property(nonatomic,copy) PayOrderSuccess payOrderSuccess;
@end

NS_ASSUME_NONNULL_END
