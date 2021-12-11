//
//  NoticeTableViewCell.h
//  RideHousekeeper
//
//  Created by Apple on 2018/3/12.
//  Copyright © 2018年 Duke Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
@class NoticeModel;
@interface NoticeTableViewCell : UITableViewCell

- (void)configCellWithModel:(NSArray *)model indexPath:(NSIndexPath *)indexPath;

@property (nonatomic, copy) void (^ noticeClickBlock)();
@property (strong, nonatomic) UIView *mainView;
@property (strong, nonatomic) UIImageView *arrowImg;
@property (strong, nonatomic) UIImageView *noticeImg;
@property (strong, nonatomic) UIImageView *linView;
@property (strong, nonatomic) UIView *dotView;
@property (strong, nonatomic) UILabel *timeLab;
@property (strong, nonatomic) UILabel *noticeTitleLab;
@property (strong, nonatomic) UILabel *noticeTimeLab;

@end
