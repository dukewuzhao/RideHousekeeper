//
//  TrackSwitchView.h
//  RideHousekeeper
//
//  Created by Apple on 2020/3/5.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^TrackSelectBlock)(NSInteger code);
@interface TrackSwitchView : UIView
@property(nonatomic ,copy) TrackSelectBlock selectCode;
@property (nonatomic,assign) int selectedSegmentIndex;
@end

NS_ASSUME_NONNULL_END
