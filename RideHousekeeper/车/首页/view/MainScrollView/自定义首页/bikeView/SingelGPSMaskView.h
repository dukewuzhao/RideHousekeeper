//
//  SingelGPSMaskView.h
//  RideHousekeeper
//
//  Created by Apple on 2020/3/25.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SingelGPSMaskView : UIView
@property (nonatomic, assign) NSInteger             type;
-(void)setBikeStatusInfo:(BikeStatusInfoModel*)model;
@end

NS_ASSUME_NONNULL_END
