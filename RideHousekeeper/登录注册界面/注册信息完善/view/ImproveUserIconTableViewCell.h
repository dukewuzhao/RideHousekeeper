//
//  UserIconTableViewCell.h
//  RideHousekeeper
//
//  Created by Apple on 2018/12/4.
//  Copyright © 2018年 Duke Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void (^UserIconClickedBlock)(UITapGestureRecognizer *gesture);
@interface ImproveUserIconTableViewCell : UITableViewCell
@property(nonatomic,strong)UIImageView *userIcon;
@property (nonatomic, copy) UserIconClickedBlock userIconClickedBlock;//声明一个block
- (void)passingClickEvents:(UserIconClickedBlock)block;
@end

NS_ASSUME_NONNULL_END
