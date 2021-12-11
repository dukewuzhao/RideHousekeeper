//
//  RideReportModel.h
//  RideHousekeeper
//
//  Created by Apple on 2019/10/12.
//  Copyright © 2019 Duke Wu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RideReportModel : NSObject

@property (copy, nonatomic) NSString* day;
@property (copy, nonatomic) NSArray *detail;
@end

@class RideReportContentModel;
@interface DayRideReportModel : NSObject

@property (assign, nonatomic) NSInteger ts;
@property (assign, nonatomic) NSInteger type;
@property (strong, nonatomic) RideReportContentModel *content;
@end

@class RideReportLocModel;
@interface RideReportContentModel : NSObject

@property (strong, nonatomic)RideReportLocModel *begin_loc;
@property (assign, nonatomic)NSInteger begin_ts;
@property (assign, nonatomic)NSInteger distance;
@property (strong, nonatomic)RideReportLocModel *end_loc;
@property (assign, nonatomic)NSInteger end_ts;
@property (assign, nonatomic)NSInteger speed;
@property (assign, nonatomic)NSInteger time;
@end


@interface RideReportLocModel : NSObject

@property (copy, nonatomic)NSArray *gps;
@property (copy, nonatomic)NSString *road;
@end

@class RideReportShockContentModel;
@interface RideReportShockModel : NSObject

@property (assign, nonatomic) NSInteger ts;
@property (assign, nonatomic) NSInteger type;
@property (strong, nonatomic) RideReportShockContentModel *content;
@property (nonatomic, assign) BOOL isOpen;
@end

@interface RideReportShockContentModel : NSObject

@property (copy,   nonatomic) NSString* descriptions;
@property (assign, nonatomic) NSInteger from;
@property (assign, nonatomic) NSInteger level;
@property (assign, nonatomic) NSInteger ts;
@property (assign, nonatomic) NSInteger typ;
@end

NS_ASSUME_NONNULL_END
