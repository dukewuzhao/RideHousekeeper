//
//  RechargeRecordTableViewCell.h
//  RideHousekeeper
//
//  Created by Apple on 2020/3/4.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^OrderProcessingBlock)(void);
@interface RechargeRecordTableViewCell : UITableViewCell

@property(nonatomic ,copy) OrderProcessingBlock OrderProcessingCode;

-(void)setServiceOrderModel:(ServiceOrder *)model bikeID:(NSInteger)bikeid;

@end

NS_ASSUME_NONNULL_END
