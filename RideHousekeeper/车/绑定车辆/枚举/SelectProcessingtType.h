//
//  SelectProcessingtType.h
//  RideHousekeeper
//
//  Created by Apple on 2019/12/5.
//  Copyright © 2019 Duke Wu. All rights reserved.
//

#ifndef SelectProcessingtType_h
#define SelectProcessingtType_h
#import <Foundation/Foundation.h>
typedef enum : NSUInteger {
    DuplicateBinding,//重复绑定设备
    DuplicateBindingKitWithGPS,//重复绑定有GPS的ecu套件
    DuplicateBindingKitWithECU,//重复绑定有ecu的GPS套件
    DuplicateBindingWithOutGPS,//重复绑定套件没有GPS
    DuplicateBindingWithOutECU,//重复绑定套件没有ECU
    DuplicateChangeECU,//更换设备为已被绑定的ECU
    ChangeGPS,//更换GPS
    DuplicateChangeGPS,//更换设备为已被试用绑定的GPS
    SingleGPSBinding,//单GPS绑定
    DuplicateSingleGPSBinding,//试用单GPS绑定
    AccessoriesGPSBinding,//配件绑定
    DuplicateAccessoriesGPSBinding,//试用GPS配件绑定
    ECUKitWithOutGPS,//套件没有GPS
    ECUKitWithGPS,//套件有GPS
    GPSKitWithECU,//套件有ECU
    DuplicateGPSKitWithECU,//套件试用GPS有ECU
    GPSKitWithOutECU,//套件没有ECU
    DuplicateGPSKitWithOutECU,//套件试用GPS没有ECU
    UnbindingBike,//ECU解绑
    UnbindingGPS,//GPS配件解绑
    UnbindingSingelGPS//单GPS解绑
} ProcessingtType;
#endif /* SelectProcessingtType_h */
