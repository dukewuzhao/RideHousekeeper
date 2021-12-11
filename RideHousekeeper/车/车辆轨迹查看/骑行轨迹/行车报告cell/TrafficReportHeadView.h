//
//  TrafficReportHeadView.h
//  RideHousekeeper
//
//  Created by Apple on 2018/3/12.
//  Copyright © 2018年 Duke Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TrafficReportHeadView : UIView

@property (strong, nonatomic) UIView *mainView;
@property (strong, nonatomic) UILabel *dateLab;
@property (strong, nonatomic) UILabel *weekTimeLab;

@property (nonatomic, copy) void (^ trafficReportClickBlock)();
@end
