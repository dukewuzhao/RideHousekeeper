//
//  TrackAnnotation.h
//  RideHousekeeper
//
//  Created by Apple on 2019/12/9.
//  Copyright © 2019 Duke Wu. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <BaiduMapAPI_Base/BMKBaseComponent.h>//引入base相关所有的头文件
#import <BaiduMapAPI_Map/BMKMapComponent.h>//引入地图功能所有的头文件
NS_ASSUME_NONNULL_BEGIN

@interface TrackAnnotation : BMKPointAnnotation<BMKAnnotation>

@end

NS_ASSUME_NONNULL_END
