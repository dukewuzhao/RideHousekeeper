//
//  TimingPaymentView.h
//  RideHousekeeper
//
//  Created by Apple on 2020/3/18.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^SelectAction)(void);
NS_ASSUME_NONNULL_BEGIN

@interface TimingPaymentView : UIView
@property(nonatomic,strong) UILabel *totalPriceLab;
@property(nonatomic,strong) UIButton *payBtn;
@property(nonatomic,copy)SelectAction selectAction;
@end

NS_ASSUME_NONNULL_END
