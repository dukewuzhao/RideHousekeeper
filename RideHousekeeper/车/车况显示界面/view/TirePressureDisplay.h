//
//  TirePressureDisplay.h
//  RideHousekeeper
//
//  Created by Apple on 2019/7/11.
//  Copyright © 2019 Duke Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TireStatusDisplayView;
NS_ASSUME_NONNULL_BEGIN

@interface TirePressureDisplay : UIView

@property (nonatomic, assign) NSInteger numberWheels;

@property (nonatomic, strong) UILabel     *titlelab;
@property (nonatomic, strong) TireStatusDisplayView     *firstWheelView;
@property (nonatomic, strong) TireStatusDisplayView     *secondWheelView;
@property (nonatomic, strong) TireStatusDisplayView     *thirdWheelView;
@property (nonatomic, strong) TireStatusDisplayView     *fourthWheelView;
@property (nonatomic, strong) UIImageView               *firstWheelImg;
@property (nonatomic, strong) UIImageView               *secondWheelImg;
@property (nonatomic, strong) UIImageView               *thirdWheelImg;
@property (nonatomic, strong) UIImageView               *fourthWheelImg;


@end

NS_ASSUME_NONNULL_END
