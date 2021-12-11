//
//  DateSelectionView.h
//  RideHousekeeper
//
//  Created by 晶 on 2020/4/12.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^DateSelectBlock)(NSString *date);
@interface DateSelectionView : UIView

- (void)showInView:(UIView *)view ;
@property(nonatomic,copy) DateSelectBlock dateSelectBlock;
@end

NS_ASSUME_NONNULL_END
