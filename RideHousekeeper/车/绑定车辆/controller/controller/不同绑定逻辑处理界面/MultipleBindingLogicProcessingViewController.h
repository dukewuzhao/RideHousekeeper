//
//  MultipleBindingLogicProcessingViewController.h
//  RideHousekeeper
//
//  Created by Apple on 2019/12/5.
//  Copyright © 2019 Duke Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MultipleBindingLogicProcessingViewController : BaseViewController
@property(nonatomic,strong) BikeInfoModel *bikeinfomodel;

- (void)showView:(ProcessingtType)type :(id)model :(NSInteger)bikeid;


@end

NS_ASSUME_NONNULL_END
