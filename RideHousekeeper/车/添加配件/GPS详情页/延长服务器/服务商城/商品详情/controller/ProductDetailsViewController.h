//
//  ProductDetailsViewController.h
//  RideHousekeeper
//
//  Created by Apple on 2020/3/12.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ProductDetailsViewController : BaseViewController
-(void)setCommodityInfo:(ServiceCommoity *)model bikeid:(NSInteger)bikeid;
-(void)setRechargeCardNo:(NSString *)code bikeid:(NSInteger)bikeid;
-(void)setServiceTransferCode:(NSString *)code bikeid:(NSInteger)bikeid;
@end

NS_ASSUME_NONNULL_END
