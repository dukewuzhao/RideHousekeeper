//
//  GPSTableViewCell.h
//  RideHousekeeper
//
//  Created by Apple on 2019/10/22.
//  Copyright © 2019 Duke Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^RechargeBtnClick)(void);
@interface GPSTableViewCell : UITableViewCell
@property (nonatomic, strong) UILabel *title;
@property (nonatomic, strong) UIImageView *icon;
@property (nonatomic, copy) RechargeBtnClick rechargeBtnClick;

-(void)setBikeModel:(BikeModel *)bikeModel brandModel:(BrandModel *)brandModel peripheraAry:(NSArray *)ary;
@end

NS_ASSUME_NONNULL_END
