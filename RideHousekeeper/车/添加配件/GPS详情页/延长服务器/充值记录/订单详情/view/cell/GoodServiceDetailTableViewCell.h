//
//  GoodServiceDetailTableViewCell.h
//  RideHousekeeper
//
//  Created by Apple on 2020/3/13.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GoodServiceDetailTableViewCell : UITableViewCell
@property(nonatomic,strong)UIImageView *icon;
@property(nonatomic,strong)UILabel *titleLab;
@property(nonatomic,strong)UILabel *durationLab;
@property(nonatomic,strong)UILabel *numLab;
@end

NS_ASSUME_NONNULL_END
