//
//  MultipleBindingLogicProcessingView.h
//  RideHousekeeper
//
//  Created by Apple on 2019/12/5.
//  Copyright © 2019 Duke Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MultipleBindingLogicProcessingFootView.h"
NS_ASSUME_NONNULL_BEGIN

typedef void(^ScanAgainBlock)(NSInteger code);
typedef void(^ScanSearchBlock)(NSInteger code);
typedef void(^NoGPSBindingBlock)(NSInteger code);

@interface MultipleBindingLogicProcessingView : UIView
@property (nonatomic, strong)UILabel * operatingPromptLab;
@property (nonatomic, strong)UIImageView * mainPictureView;
@property (nonatomic, strong)UILabel * operatingSubtitleLab;
@property (nonatomic, strong)UILabel * unbindPromptLab;
@property (nonatomic, strong)UILabel * tipsForNextStepsLab;
@property (nonatomic, strong)MultipleBindingLogicProcessingFootView * footView;
@property (nonatomic, copy)ScanAgainBlock scanAgainBlock;
@property (nonatomic, copy)ScanSearchBlock scanSearchBlock;
@property (nonatomic, copy)NoGPSBindingBlock noGPSBindingBlock;

- (instancetype)initWithType:(ProcessingtType)type;
- (void)switchScanGPSView;
- (void)switchBindBikeView;
- (void)switchChangeGPSView;
- (void)bindFailedWithCode:(NSInteger)code;

@end

NS_ASSUME_NONNULL_END
