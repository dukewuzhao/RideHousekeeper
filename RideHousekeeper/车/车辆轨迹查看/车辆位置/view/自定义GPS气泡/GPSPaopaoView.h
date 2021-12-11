//
//  GPSPaopaoView.h
//  RideHousekeeper
//
//  Created by 吴兆华 on 2018/3/11.
//  Copyright © 2018年 Duke Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^RideReportBtnClick)();
typedef void (^NavigationBtnClick)();

@interface GPSPaopaoView : UIView
@property (nonatomic, copy) RideReportBtnClick rideReportBtnClick;
@property (nonatomic, copy) NavigationBtnClick navigationBtnClick;
-(void)setBikeStatusPosModel:(BikeStatusPosModel *)model;
@end
