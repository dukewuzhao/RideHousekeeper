//
//  SecondRechargeRecordTableViewCell.h
//  RideHousekeeper
//
//  Created by Apple on 2020/3/16.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^OrderProcessingBlock)(void);
@interface SecondRechargeRecordTableViewCell : UITableViewCell
@property(nonatomic ,copy) OrderProcessingBlock OrderProcessingCode;

-(void)setServiceOrderModel:(ServiceOrder *)model bikeID:(NSInteger)bikeid;
@end

NS_ASSUME_NONNULL_END
