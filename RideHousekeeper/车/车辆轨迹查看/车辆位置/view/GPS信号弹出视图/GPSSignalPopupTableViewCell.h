//
//  GPSSignalPopupTableViewCell.h
//  RideHousekeeper
//
//  Created by Apple on 2019/12/11.
//  Copyright © 2019 Duke Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GPSSignalPopupTableViewCell : UITableViewCell

@property (strong, nonatomic) UIImageView *signalStrengthImg;
@property (strong, nonatomic) UILabel *signalStrengthLab;
@property (strong, nonatomic) UILabel *communicationTime;

@end

NS_ASSUME_NONNULL_END
