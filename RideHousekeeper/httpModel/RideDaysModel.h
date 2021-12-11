//
//  RideDaysModel.h
//  RideHousekeeper
//
//  Created by Apple on 2020/1/14.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RideDaysModel : NSObject
+ (NSArray *)jsonsToModelsWithJsons:(NSArray *)jsons;
@end

@class RideDaysSummaryModel;
@interface RideOneDayModel : NSObject
@property (copy, nonatomic) NSString* day;
@property (strong, nonatomic) RideDaysSummaryModel *summary;
@end

@interface RideDaysSummaryModel : NSObject
@property (assign, nonatomic) NSInteger ride_count;
@property (assign, nonatomic) NSInteger ride_distance;
@property (assign, nonatomic) NSInteger ride_time;
@property (assign, nonatomic) NSInteger warn_count;
@end

NS_ASSUME_NONNULL_END
