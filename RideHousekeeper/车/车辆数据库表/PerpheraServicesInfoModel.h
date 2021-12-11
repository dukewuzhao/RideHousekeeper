//
//  PerpheraServicesInfoModel.h
//  RideHousekeeper
//
//  Created by Apple on 2020/3/25.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PerpheraServicesInfoModel : NSObject

@property (nonatomic, assign) NSInteger bikeid; //车辆内部id
@property (nonatomic, assign) NSInteger deviceid;//外设id
@property (nonatomic, assign) NSInteger ID;//设备序号
@property (nonatomic, assign) NSInteger type;//服务类型
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) NSInteger brand_id;
@property (nonatomic, copy) NSString *begin_date;
@property (nonatomic, copy) NSString *end_date;
@property (nonatomic, assign) NSInteger left_days;
+(instancetype)modelWith:(NSInteger)bikeid deviceid:(NSInteger)deviceid ID:(NSInteger)ID type:(NSInteger)type title:(NSString *)title brand_id:(NSInteger)brand_id begin_date:(NSString *)begin_date end_date:(NSString *)end_date left_days:(NSInteger)left_days;
@end

NS_ASSUME_NONNULL_END
