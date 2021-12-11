//
//  BLEScanPopview.h
//  RideHousekeeper
//
//  Created by Apple on 2018/4/24.
//  Copyright © 2018年 Duke Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WMZBannerView.h"
@interface BLEScanPopview : UIView
@property(nonatomic,strong) UIButton *bindingBtn;
@property(nonatomic,strong) WMZBannerView *bikeListView;
@property (nonatomic, copy) void (^ bindingBikeClickBlock)(NSInteger index);
-(instancetype)initWithType:(BindingType)type;
-(void)setParams:(NSArray *)ary;
-(void)showInView:(UIView *)view;
-(void)disMissView;

@end
