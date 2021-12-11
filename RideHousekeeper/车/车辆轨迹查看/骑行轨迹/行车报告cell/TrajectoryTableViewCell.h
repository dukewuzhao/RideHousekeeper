//
//  TrajectoryTableViewCell.h
//  RideHousekeeper
//
//  Created by 吴兆华 on 2018/3/11.
//  Copyright © 2018年 Duke Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TrajectoryTableViewCell : UITableViewCell
@property (strong, nonatomic) UIView *mainView;
@property (strong, nonatomic) UIImageView *linView;
@property (strong, nonatomic) UIView *dotView;
@property (strong, nonatomic) UILabel *timeLab;
@property (strong, nonatomic) UILabel *startLab;
@property (strong, nonatomic) UILabel *endLab;
@property (strong, nonatomic) UILabel *mileageLab;
@property (strong, nonatomic) UILabel *timeConsumingLab;
@property (strong, nonatomic) UILabel *speedImgLab;
@property (nonatomic, copy) void (^ trajectoryClickBlock)();
@end
