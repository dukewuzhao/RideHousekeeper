//
//  BottomPaymentView.h
//  RideHousekeeper
//
//  Created by Apple on 2020/3/11.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^SelectAction)(void);
@interface BottomPaymentView : UIView

@property(nonatomic,strong)UILabel *currentPriceLab;
@property(nonatomic,strong)UILabel *savePriceLab;
@property(nonatomic,copy)SelectAction selectAction;
@end

NS_ASSUME_NONNULL_END
