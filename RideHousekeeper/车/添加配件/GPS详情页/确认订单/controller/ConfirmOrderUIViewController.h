//
//  ConfirmOrderUIViewController.h
//  RideHousekeeper
//
//  Created by Apple on 2020/3/3.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN



@interface ConfirmOrderUIViewController : BaseViewController

-(void)setCommodityInfo:(ServiceOrder *)model deviceInfo:(DeviceInfoModel*)devide serviceCardInfo:(ServiceCard*)card type:(NSInteger)type bikeid:(NSInteger)bikeid;

@end

NS_ASSUME_NONNULL_END
