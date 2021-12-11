//
//  BikeMessageSelectTableViewCell.h
//  RideHousekeeper
//
//  Created by Apple on 2020/4/7.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^DeleteBtnSelect)(BOOL isClick);
@interface BikeMessageSelectTableViewCell : UITableViewCell

@property(nonatomic,strong) UIImageView *remindImg;
@property(nonatomic,strong) UILabel *timeLab;
@property(nonatomic,strong) UILabel *newsType;
@property(nonatomic,strong) UILabel *RemindLab;
@property(nonatomic,strong) UIButton *selectBtn;
@property(nonatomic,copy) DeleteBtnSelect btnSelect;
@end

NS_ASSUME_NONNULL_END
