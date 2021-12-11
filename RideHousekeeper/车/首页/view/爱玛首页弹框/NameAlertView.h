//
//  NameAlertView.h
//  RideHousekeeper
//
//  Created by Apple on 2018/8/3.
//  Copyright © 2018年 Duke Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NameAlertView : UIView

@property (nonatomic,strong) UITextField *bikenameField; // 车辆名

@property (nonatomic, copy) void (^ NameSureBlock)(NSString * name);

@end
