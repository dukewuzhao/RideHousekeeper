//
//  GpsPointModel.h
//  RideHousekeeper
//
//  Created by Apple on 2019/11/4.
//  Copyright © 2019 Duke Wu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GpsPointModel : NSObject
@property (assign, nonatomic) NSInteger ts;
@property (assign, nonatomic) double lng;
@property (assign, nonatomic) double lat;
@end

NS_ASSUME_NONNULL_END
