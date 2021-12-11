//
//  FillTransferPasswordViewController.h
//  RideHousekeeper
//
//  Created by Apple on 2020/3/4.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface FillTransferPasswordViewController : BaseViewController
-(void)setDeviceInfoModel:(DeviceInfoModel *)deviceModel bikeid:(NSInteger)bikeid;
@end

NS_ASSUME_NONNULL_END
