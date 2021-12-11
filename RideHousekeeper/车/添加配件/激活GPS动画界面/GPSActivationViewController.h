//
//  BindingGPSViewController.h
//  RideHousekeeper
//
//  Created by Apple on 2018/3/13.
//  Copyright © 2018年 Duke Wu. All rights reserved.
//

#import "BaseViewController.h"

@interface GPSActivationViewController : BaseViewController
@property (nonatomic,assign) BOOL isOnlyGPSActivation;
-(void)setpGPSParameters:(BikeModel *)model;

@end
