//
//  VehiclePositioningMapView.h
//  RideHousekeeper
//
//  Created by Apple on 2018/2/27.
//  Copyright © 2018年 Duke Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>
@class MaskView;
@interface VehiclePositioningMapView : UIView<BMKMapViewDelegate>
@property (nonatomic, assign) NSInteger             bikeid; //车辆内部id
@property (nonatomic, assign) NSInteger             viewType;
@property (nonatomic, strong) BMKMapView            *mapView;
@property (nonatomic, copy) void (^bikeMapClickBlock)();
@property (nonatomic, copy) void (^ bikeActivatedViewClickBlock)();
-(void)setBikeStatusInfo:(BikeStatusInfoModel*)model;
@end
