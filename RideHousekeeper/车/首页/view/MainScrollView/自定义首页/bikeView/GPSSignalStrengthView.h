//
//  GPSSignalStrengthView.h
//  RideHousekeeper
//
//  Created by Apple on 2020/3/25.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GPSSignalStrengthView : UIView
@property(nonatomic,strong)UILabel *titleLab;
@property(nonatomic,assign)NSInteger value;
@end

NS_ASSUME_NONNULL_END
