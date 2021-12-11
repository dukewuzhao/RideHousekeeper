//
//  UpdateUserNameTableViewCell.h
//  RideHousekeeper
//
//  Created by Apple on 2018/11/29.
//  Copyright © 2018年 Duke Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^ClearFieldBlock)();
@interface UpdateUserNameTableViewCell : UITableViewCell

@property(nonatomic,strong)UILabel *name;
@property(nonatomic,strong)UITextField *nickNameField;
@property(nonatomic,strong)UIImageView *arrow;
@property (nonatomic, copy) ClearFieldBlock clearfieldBlock;
@end

NS_ASSUME_NONNULL_END
