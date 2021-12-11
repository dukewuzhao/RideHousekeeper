//
//  MaskView.h
//  RideHousekeeper
//
//  Created by Apple on 2019/10/29.
//  Copyright © 2019 Duke Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MaskView : UIView
@property (nonatomic, assign) NSInteger             type;
-(void)setBikeStatusInfo:(BikeStatusInfoModel*)model;
@end

NS_ASSUME_NONNULL_END
