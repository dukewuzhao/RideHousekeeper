//
//  BLEScanPopview.h
//  RideHousekeeper
//
//  Created by Apple on 2018/4/24.
//  Copyright © 2018年 Duke Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BLEScanPopview : UIView
@property(nonatomic,strong) UITableView *scandTabView;
@property(nonatomic, copy) void (^ bindingBikeClickBlock)();
-(void)showInView:(UIView *)view;
-(void)disMissView;
@end
