//
//  GPSAllotedTimeTableViewCell.h
//  RideHousekeeper
//
//  Created by Apple on 2019/10/30.
//  Copyright © 2019 Duke Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^RenewalFeeBtnClick)(void);
NS_ASSUME_NONNULL_BEGIN

@interface GPSAllotedTimeTableViewCell : UITableViewCell
@property(nonatomic, strong)UILabel *activationTimeLab;
@property(nonatomic, strong)UILabel *lastDateLab;
@property(nonatomic, copy)RenewalFeeBtnClick renewalFeeBtnClick;
@end

NS_ASSUME_NONNULL_END
