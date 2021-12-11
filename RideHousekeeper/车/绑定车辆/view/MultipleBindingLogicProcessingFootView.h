//
//  MultipleBindingLogicProcessingFootView.h
//  RideHousekeeper
//
//  Created by Apple on 2019/12/5.
//  Copyright © 2019 Duke Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

typedef void(^forceBinding)();
typedef void(^unbindImmediately)();
typedef void(^forceUnbindImmediately)();
@class proProcessingtTypeces;
@interface MultipleBindingLogicProcessingFootView : UIView
@property (nonatomic,strong) UIButton *forcedUnbundBtn;
@property (nonatomic, copy)forceBinding bindingBike;
@property (nonatomic, copy)unbindImmediately unbindBike;
@property (nonatomic, copy)forceUnbindImmediately forceUnbind;
- (instancetype)initWithType:(ProcessingtType)type;
@end

NS_ASSUME_NONNULL_END
