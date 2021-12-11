//
//  ImproveUserNameTableViewCell.h
//  RideHousekeeper
//
//  Created by Apple on 2019/3/8.
//  Copyright © 2019年 Duke Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^ClearFieldBlock)();
@interface ImproveUserNameTableViewCell : UITableViewCell
@property(nonatomic,strong)UIImageView *icon;
@property(nonatomic,strong)UILabel *name;
@property(nonatomic,strong)UITextField *nickNameField;
@property(nonatomic,strong)UIImageView *arrow;
@property (nonatomic, copy) ClearFieldBlock clearfieldBlock;
@end

NS_ASSUME_NONNULL_END
