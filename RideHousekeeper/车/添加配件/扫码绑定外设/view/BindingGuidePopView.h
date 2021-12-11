//
//  BindingGuidePopView.h
//  RideHousekeeper
//
//  Created by Apple on 2020/4/10.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WMZBannerView.h"
NS_ASSUME_NONNULL_BEGIN

@interface BindingGuidePopView : UIView
@property(nonatomic,strong)WMZBannerView *bikeListView;
@property (nonatomic, copy) void (^bindingBikeClickBlock)(NSInteger index);
-(void)showInView:(UIView *)view withParams:(NSArray *)ary;
@end

NS_ASSUME_NONNULL_END
