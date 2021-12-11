//
//  VehiclePositionViewController.m
//  RideHousekeeper
//
//  Created by Apple on 2018/3/8.
//  Copyright © 2018年 Duke Wu. All rights reserved.
//
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BMKLocationkit/BMKLocationComponent.h>
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreLocation/CLAvailability.h>
#import "VehiclePositionViewController.h"
#import "VehicleTrajectoryViewController.h"
#import "GPSActivationViewController.h"
#import "GPSPaopaoView.h"
#import "TrajectoryRouteInformationView.h"
#import "MapTool.h"
#import "AnimationObjectProtocol.h"
#import "GPSSignalPopupView.h"
#import "RouteAnnotation.h"
#import "UIImage+Rotate.h"
#define MYBUNDLE_NAME @ "mapapi.bundle"
#define MYBUNDLE_PATH [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: MYBUNDLE_NAME]
#define MYBUNDLE [NSBundle bundleWithPath: MYBUNDLE_PATH]

@interface VehiclePositionViewController ()<BMKGeoCodeSearchDelegate,BMKMapViewDelegate,BMKLocationManagerDelegate,AnimationObjectProtocol>{
    BMKGeoCodeSearch* _geocodesearch;
}

@property (nonatomic, strong) UIButton *enlarge;
@property (nonatomic, strong) UIButton *narrow;
@property (nonatomic, strong) BMKMapView* mapView;
@property (nonatomic, strong) GPSPaopaoView * popView;
@property (nonatomic, strong) BMKLocationManager* locationService;
@property (nonatomic, strong) BMKPointAnnotation* bikeAnnotation;
@property (nonatomic, strong) BMKPointAnnotation *annotation;//当前定位的位置
@property (nonatomic, strong) BMKUserLocation *userLocation; //当前位置对象
@property (nonatomic, strong) BMKPoiInfo* userAdressPoi;
@property (nonatomic, strong) BikeStatusInfoModel* statusModel;
@property (nonatomic, assign) BOOL isAlert;
@end

@implementation VehiclePositionViewController


- (void)setBikeid:(NSInteger)bikeid{
    _bikeid = bikeid;
    [self updateBikePosition:bikeid];
}

-(void)updateBikePosition:(NSInteger)bikeid{
    
    NSString *token = [QFTools getdata:@"token"];
        NSNumber *bikeNum = [NSNumber numberWithInteger:bikeid];
        NSString *URLString = [NSString stringWithFormat:@"%@%@",QGJURL,@"app/getbikestatus"];
        NSDictionary *parameters = @{@"token":token,@"user_id": [QFTools getdata:@"userid"], @"bike_id": bikeNum};
        [[HttpRequest sharedInstance] postWithURLString:URLString parameters:parameters success:^(id _Nullable dict) {
            
            if ([dict[@"status"] intValue] == 0 || [dict[@"status"] intValue] == 1038) {
                NSDictionary *data = dict[@"data"];
                BikeStatusInfoModel *model = [BikeStatusInfoModel yy_modelWithDictionary:data[@"status"]];
                
                if(model.pos.lng == 0 && model.pos.lat == 0 && !_isAlert){
                    _isAlert = YES;
                    DW_AlertView *alertView = [[DW_AlertView alloc] initBackroundImage:nil Title:@"无有效定位信息" contentString:@"未成功获取到定位信息，请到空旷位置尝试定位，如一直无法定位，请进行定位检测？" sureButtionTitle:@"立即检测" cancelButtionTitle:@"取消"];
                    @weakify(self);
                    [alertView setSureBolck:^(BOOL clickStatu) {
                        @strongify(self);
                        //跳转到定位器检测界面
                        GPSActivationViewController *activationVc = [[GPSActivationViewController alloc] init];
                        [activationVc setpGPSParameters: [LVFmdbTool queryBikeData:[NSString stringWithFormat:@"SELECT * FROM bike_modals WHERE bikeid = '%zd'", self.bikeid]].firstObject];
                        [self.navigationController pushViewController:activationVc animated:YES];
                    }];
                }
                
                _statusModel = model;
                CLLocationCoordinate2D coor = BMKCoordTrans(CLLocationCoordinate2DMake(model.pos.lat, model.pos.lng), BMK_COORDTYPE_GPS, BMK_COORDTYPE_BD09LL);

                CLLocationDistance distance = BMKMetersBetweenMapPoints(BMKMapPointForCoordinate(coor),BMKMapPointForCoordinate(self.bikeAnnotation.coordinate));

                dispatch_async(dispatch_get_main_queue(), ^{
                    //[self.mapView removeAnnotation:self.bikeAnnotation];
                    if(distance>0){
                        self.bikeAnnotation.coordinate = coor;
                        [self locationInCoordinate:coor];
                    }
                    [self.popView setBikeStatusPosModel:model.pos];
                    [self.mapView addAnnotation:self.bikeAnnotation];
                });
                
                
            }else{
                [SVProgressHUD showSimpleText:dict[@"status_info"]];
            }
            
        }failure:^(NSError *error) {
            
            NSLog(@"error :%@",error);
            [SVProgressHUD showSimpleText:TIP_OF_NO_NETWORK];
        }];
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    [self.mapView viewWillAppear];
    self.mapView.delegate = self;
    _geocodesearch.delegate = self;
    [self.locationService startUpdatingLocation];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.mapView viewWillDisappear];
    [self.locationService stopUpdatingLocation];
    self.mapView.delegate = nil;
    _geocodesearch.delegate = nil;
    self.locationService = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupNavView];
    [self.view addSubview:self.mapView];
    _geocodesearch = [[BMKGeoCodeSearch alloc]init];
    
    [self.view addSubview:self.popView];
    [self.popView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(30);
        make.right.equalTo(self.view).offset(-30);
        make.bottom.equalTo(self.view).offset(-30-QGJ_TabbarSafeBottomMargin);
    }];
    
    UIButton *userLocationBtn = [[UIButton alloc] init];
    [userLocationBtn setImage:[UIImage imageNamed:@"icon_user_location"] forState:UIControlStateNormal];
    [self.view addSubview:userLocationBtn];
    [userLocationBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(10);
        make.bottom.equalTo(self.popView.mas_top).offset(-40);
        make.size.mas_equalTo(CGSizeMake(35, 35));
    }];
    @weakify(self);
    [[userLocationBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        [self.mapView setCenterCoordinate:self.annotation.coordinate animated:YES];
    }];
    
    UIButton *bikeLocationBtn = [[UIButton alloc] init];
    [bikeLocationBtn setImage:[UIImage imageNamed:@"icon_bike_location"] forState:UIControlStateNormal];
    [self.view addSubview:bikeLocationBtn];
    [bikeLocationBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view).offset(-10);
        make.bottom.equalTo(userLocationBtn);
        make.size.mas_equalTo(CGSizeMake(35, 35));
    }];
    [[bikeLocationBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        
        if (self.bikeAnnotation.coordinate.longitude == 0 && self.bikeAnnotation.coordinate.latitude == 0) {
            
            self.isAlert = YES;
            DW_AlertView *alertView = [[DW_AlertView alloc] initBackroundImage:nil Title:@"无有效定位信息" contentString:@"未成功获取到定位信息，请到空旷位置尝试定位，如一直无法定位，请进行定位检测？" sureButtionTitle:@"立即检测" cancelButtionTitle:@"取消"];
            @weakify(self);
            [alertView setSureBolck:^(BOOL clickStatu) {
                @strongify(self);
                //跳转到定位器检测界面
                GPSActivationViewController *activationVc = [[GPSActivationViewController alloc] init];
                [activationVc setpGPSParameters: [LVFmdbTool queryBikeData:[NSString stringWithFormat:@"SELECT * FROM bike_modals WHERE bikeid = '%zd'", self.bikeid]].firstObject];
                [self.navigationController pushViewController:activationVc animated:YES];
            }];
            
            return;
        }
        
        [self.mapView setCenterCoordinate:self.bikeAnnotation.coordinate animated:YES];
    }];
    
    _narrow = [UIButton buttonWithType:UIButtonTypeCustom];
    _narrow.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [_narrow addTarget:self action:@selector(narrowClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_narrow];
    [_narrow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view).offset(-10);
        make.bottom.equalTo(bikeLocationBtn.mas_top).offset(-20);
        make.size.mas_equalTo(CGSizeMake(35, 35));
    }];
    
    _enlarge = [UIButton buttonWithType:UIButtonTypeCustom];
    _enlarge.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [_enlarge addTarget:self action:@selector(enlargeClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_enlarge];
    [_enlarge mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view).offset(-10);
        make.bottom.equalTo(_narrow.mas_top);
        make.size.mas_equalTo(CGSizeMake(35, 35));
    }];
    
    UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 35, 70)];
    image.image =[UIImage imageNamed:@"map_zoom"];
    [_enlarge addSubview:image];
    /*
    UIButton *GPSSignalBtn = [[UIButton alloc] init];
    [GPSSignalBtn setImage:[UIImage imageNamed:@"incon_gps_signal"] forState:UIControlStateNormal];
    [self.view addSubview:GPSSignalBtn];
    [GPSSignalBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view).offset(-10);
        make.bottom.equalTo(_enlarge.mas_top).offset(-20);
        make.size.mas_equalTo(CGSizeMake(35, 35));
    }];
    @weakify(GPSSignalBtn);
    [[GPSSignalBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        @strongify(GPSSignalBtn);
        GPSSignalPopupView *popView = [[GPSSignalPopupView alloc] initWithModel:_statusModel origin:CGPointMake(GPSSignalBtn.x - 10, GPSSignalBtn.centerY + 30) width:200 height:60 direction:GPSSignalPopupDirectionLeft];
        @weakify(popView);
        popView.dismissOperation = ^(){
            @strongify(popView);
            popView = nil;
        };
        [popView pop];
    }];
    
    [GPSSignalBtn setNeedsLayout];
    [GPSSignalBtn layoutIfNeeded];
    */
}



- (void)setupNavView{
    [super setupNavView];
    self.navView.showBottomLabel = NO;
    [self.navView.centerButton setTitle:@"位置" forState:UIControlStateNormal];
    @weakify(self);
    [self.navView.leftButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    self.navView.leftButtonBlock = ^{
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    };
}

- (BMKMapView *)mapView
{
    if (!_mapView) {
        
        _mapView = [[BMKMapView alloc]initWithFrame:CGRectMake(0, navHeight, ScreenWidth, ScreenHeight - navHeight)];
        _mapView.mapType = BMKMapTypeStandard;
        _mapView.showMapScaleBar = YES;
        _mapView.rotateEnabled = NO; //设置是否可以旋转
        _mapView.showsUserLocation = NO;
        _mapView.userTrackingMode = BMKUserTrackingModeNone;
        _mapView.showsUserLocation = NO;
        _mapView.buildingsEnabled = NO;
        [_mapView setZoomLevel:15];//缩小地图
        [self customLocationAccuracyCircle];
    }
    return _mapView;
}

- (void)customLocationAccuracyCircle {
    
    BMKLocationViewDisplayParam* testParam = [[BMKLocationViewDisplayParam alloc] init];
    testParam.isRotateAngleValid = false;// 跟随态旋转角度是否生效
    testParam.isAccuracyCircleShow = false;// 精度圈是否显示
    //testParam.locationViewImgName = @"icon_user_position";// 定位图标名称
    testParam.locationViewOffsetX = 0;//定位图标偏移量(经度)
    testParam.locationViewOffsetY = 0;// 定位图标偏移量(纬度)
    [self.mapView updateLocationViewWithParam:testParam];
}

- (GPSPaopaoView *)popView
{
    if (!_popView) {
        
        _popView = [[GPSPaopaoView alloc]init];
        _popView.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
        @weakify(self);
        _popView.rideReportBtnClick = ^{
            @strongify(self);
            VehicleTrajectoryViewController *trajectoryVc = [[VehicleTrajectoryViewController alloc] init];
            trajectoryVc.bikeid = _bikeid;
            [self.navigationController pushViewController:trajectoryVc animated:YES];
        };
        
        _popView.navigationBtnClick = ^{
            @strongify(self);
            if (self.bikeAnnotation.coordinate.longitude == 0 && self.bikeAnnotation.coordinate.latitude == 0) {
                
                self.isAlert = YES;
                DW_AlertView *alertView = [[DW_AlertView alloc] initBackroundImage:nil Title:@"无有效定位信息" contentString:@"未成功获取到定位信息，请到空旷位置尝试定位，如一直无法定位，请进行定位检测？" sureButtionTitle:@"立即检测" cancelButtionTitle:@"取消"];
                @weakify(self);
                [alertView setSureBolck:^(BOOL clickStatu) {
                    @strongify(self);
                    //跳转到定位器检测界面
                    GPSActivationViewController *activationVc = [[GPSActivationViewController alloc] init];
                    [activationVc setpGPSParameters: [LVFmdbTool queryBikeData:[NSString stringWithFormat:@"SELECT * FROM bike_modals WHERE bikeid = '%zd'", self.bikeid]].firstObject];
                    [self.navigationController pushViewController:activationVc animated:YES];
                }];
                
                return;
            }

            [[MapTool sharedMapTool] navigationActionWithCoordinate:self.annotation.coordinate fromName:_userAdressPoi.name tocoordinate:self.bikeAnnotation.coordinate WithENDName:@"车位置" tager:self];
        };
        
    }
    return _popView;
}


-(BMKLocationManager *)locationService{
    
    if (!_locationService) {
        
        _locationService = [[BMKLocationManager alloc] init];
        _locationService.delegate = self;
        _locationService.coordinateType = BMKLocationCoordinateTypeBMK09LL;
        _locationService.desiredAccuracy = kCLLocationAccuracyBest;
        _locationService.activityType = CLActivityTypeAutomotiveNavigation;
        _locationService.pausesLocationUpdatesAutomatically = NO;
        _locationService.allowsBackgroundLocationUpdates = NO;
        _locationService.locationTimeout = 10;
    }
    return _locationService;
}

- (BMKUserLocation *)userLocation {
    if (!_userLocation) {
        _userLocation = [[BMKUserLocation alloc] init];
    }
    return _userLocation;
}

- (BMKPointAnnotation *)annotation
{
    if (!_annotation) {
        _annotation = [[BMKPointAnnotation alloc] init];
        _annotation.title = @"我在这里";
    }
    return _annotation;
}

//添加固定屏幕位置的标注
- (BMKPointAnnotation *)bikeAnnotation
{
    if (!_bikeAnnotation) {
        _bikeAnnotation = [[BMKPointAnnotation alloc]init];
//        _bikeAnnotation.isLockedToScreen = YES;
//        _bikeAnnotation.screenPointToLock = CGPointMake(ScreenWidth/2, 300);
        
    }
    
    return _bikeAnnotation;
}

//放大缩小
-(void)enlargeClick{
    
    
    [self.mapView setZoomLevel:self.mapView.zoomLevel+1];//缩小地图
}

-(void)narrowClick{
    
    [self.mapView setZoomLevel:self.mapView.zoomLevel-1];//缩小地图
}

-(void)locationClick{
    
    [self.mapView setCenterCoordinate:self.bikeAnnotation.coordinate animated:YES];
    
}

#pragma mark ————— 转场动画起始View —————
-(UIView *)targetTransitionView{
    
    return self.view;
}

-(BOOL)isNeedTransition{
    
    return YES;
}

-(void)dealloc{
    if (_mapView) {
        [_mapView removeAnnotations:[NSArray arrayWithArray:self.mapView.annotations]];
        _mapView.delegate = nil;
        _mapView = nil;
    }
    self.locationService = nil;
    if (_userLocation) {
        _userLocation = nil;
    }
    
    if (_annotation) {
        _annotation = nil;
    }
    
    if (_bikeAnnotation) {
        _bikeAnnotation = nil;
    }
    
    if (_popView) {
        _popView = nil;
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/**
 *在地图View将要启动定位时，会调用此函数
 *@param mapView 地图View
 */
- (void)willStartLocatingUser
{
    NSLog(@"start locate");
}

/**
 *用户方向更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation
{
    [self.mapView updateLocationData:userLocation];
    NSLog(@"heading is %@",userLocation.heading);
}


/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 *- (void)BMKLocationManager:(BMKLocationManager *)manager didUpdateLocation:(BMKLocation *)location orError:(NSError *)error {
 */
- (void)BMKLocationManager:(BMKLocationManager *)manager didUpdateLocation:(BMKLocation *)location orError:(NSError *)error {
    
    if (error) {
        NSLog(@"locError:{%ld - %@};", (long)error.code, error.localizedDescription);
    }
    if (!location) {
        return;
    }
    //NSLog(@"didUpdateUserLocation lat %f,long %f",location.location.coordinate.latitude,location.location.coordinate.longitude);
    CLLocationCoordinate2D coor;
    coor.latitude = location.location.coordinate.latitude;
    coor.longitude = location.location.coordinate.longitude;
    self.annotation.coordinate = coor;
    self.userLocation.location = location.location;
    [self.mapView updateLocationData:self.userLocation];
    [self.mapView addAnnotation:self.annotation];
    [self updateBikePosition:_bikeid];
    
    //发起反向地理编码检索
    CLLocationCoordinate2D pt = (CLLocationCoordinate2D){coor.latitude, coor.longitude};
    BMKReverseGeoCodeSearchOption *reverseGeoCodeSearchOption = [[BMKReverseGeoCodeSearchOption alloc]init];
    reverseGeoCodeSearchOption.location = pt;
    [_geocodesearch reverseGeoCode:reverseGeoCodeSearchOption];
    
}

//接收反向地理编码结果
-(void) onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeSearchResult *)result errorCode:(BMKSearchErrorCode)error{
  if (error == BMK_SEARCH_NO_ERROR) {
      
      _userAdressPoi = [result.poiList objectAtIndex:0];
      
  }else {
      NSLog(@"抱歉，未找到结果");
  }
}

/**
 *在地图View停止定位后，会调用此函数
 *@param mapView 地图View
 */
- (void)didStopLocatingUser
{
    NSLog(@"stop locate");
}

/**
 *定位失败后，会调用此函数
 *@param mapView 地图View
 *@param error 错误号，参考CLError.h中定义的错误号
 */
- (void)didFailToLocateUserWithError:(NSError *)error
{
    NSLog(@"location error");
}

// 根据anntation生成对应的View
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation{
    //普通annotation
    if ([[annotation class] isEqual:[BMKPointAnnotation class]]) {
        NSString *AnnotationViewID = @"bikeMark";
        BMKPinAnnotationView *annotationView = (BMKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
        if (annotationView == nil) {
            annotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
            if (annotation == self.bikeAnnotation) {
                // 设置颜色
                annotationView.pinColor = BMKPinAnnotationColorGreen;
                // 设置可拖拽
                annotationView.draggable = NO;
                annotationView.image = [UIImage imageNamed:@"bike_position"];
                annotationView.annotation = annotation;
                
            }else if (annotation == self.annotation) {
                // 设置颜色
                annotationView.pinColor = BMKPinAnnotationColorGreen;
                // 设置可拖拽
                annotationView.draggable = NO;
                annotationView.image = [UIImage imageNamed:@"icon_user_position"];
                annotationView.annotation = annotation;
            }else {
                // 设置可拖拽
                annotationView.draggable = YES;
            }
            // 从天上掉下效果
            annotationView.animatesDrop = NO;
        }
        return annotationView;
    }
    return nil;
}

#pragma mark 获取路线的标注，显示到地图
- (BMKAnnotationView*)getRouteAnnotationView:(BMKMapView *)mapview viewForAnnotation:(RouteAnnotation*)routeAnnotation{
    
    BMKAnnotationView *view = nil;
    switch (routeAnnotation.type) {
        case 0:
        {
            view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"start_node"];
            if (view == nil) {
                view = [[BMKAnnotationView alloc] initWithAnnotation:routeAnnotation reuseIdentifier:@"start_node"];
                view.image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"images/icon_nav_start"]];
                view.centerOffset = CGPointMake(0, -(view.frame.size.height * 0.5));
                view.canShowCallout = true;
            }
            view.annotation = routeAnnotation;
        }
            break;
        case 1:
        {
            view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"end_node"];
            if (view == nil) {
                view = [[BMKAnnotationView alloc] initWithAnnotation:routeAnnotation reuseIdentifier:@"end_node"];
                view.image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"images/icon_nav_end"]];
                view.centerOffset = CGPointMake(0, -(view.frame.size.height * 0.5));
                view.canShowCallout = true;
            }
            view.annotation =routeAnnotation;
        }
            break;
        case 4:
        {
            view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"route_node"];
            if (view == nil) {
                view = [[BMKAnnotationView alloc] initWithAnnotation:routeAnnotation reuseIdentifier:@"route_node"];
                view.canShowCallout = true;
            } else {
                [view setNeedsDisplay];
            }
            UIImage *image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"images/icon_direction"]];
            view.image = [image imageRotatedByDegrees:routeAnnotation.degree];
            view.annotation = routeAnnotation;
        }
            break;
        default:
            break;
    }
    return view;
}

// 当点击annotation view弹出的泡泡时，调用此接口
- (void)mapView:(BMKMapView *)mapView annotationViewForBubble:(BMKAnnotationView *)view;
{
    NSLog(@"paopaoclick");
}

- (void)mapViewFitPolyLine:(BMKPolyline *) polyLine {
    CGFloat ltX, ltY, rbX, rbY;
    if (polyLine.pointCount < 1) {
        return;
    }
    BMKMapPoint pt = polyLine.points[0];
    static_cast<void>(ltX = pt.x), ltY = pt.y;
    static_cast<void>(rbX = pt.x), rbY = pt.y;
    for (int i = 1; i < polyLine.pointCount; i++) {
        BMKMapPoint pt = polyLine.points[i];
        if (pt.x < ltX) {
            ltX = pt.x;
        }
        if (pt.x > rbX) {
            rbX = pt.x;
        }
        if (pt.y > ltY) {
            ltY = pt.y;
        }
        if (pt.y < rbY) {
            rbY = pt.y;
        }
    }
    BMKMapRect rect;
    rect.origin = BMKMapPointMake(ltX , ltY);
    rect.size = BMKMapSizeMake(rbX - ltX, rbY - ltY);
    [self.mapView setVisibleMapRect:rect];
    self.mapView.zoomLevel = self.mapView.zoomLevel - 1;
}
#pragma mark -- BMKMapView Delegate
- (void)mapViewDidFinishLoading:(BMKMapView *)mapView{
    //[self updateBikePosition:_bikeid];
}

- (BMKOverlayView*)mapView:(BMKMapView *)map viewForOverlay:(id<BMKOverlay>)overlay
{
    if ([overlay isKindOfClass:[BMKPolyline class]]) {
        BMKPolylineView* polylineView = [[BMKPolylineView alloc] initWithOverlay:overlay];
        polylineView.fillColor = [[UIColor alloc] initWithRed:67/255.0 green:129/255.0 blue:253/255.0 alpha:1];
        polylineView.strokeColor = [[UIColor alloc] initWithRed:67/255.0 green:129/255.0 blue:253/255.0 alpha:0.7];
        polylineView.lineWidth = 3.0;
        polylineView.lineDash = NO;
        polylineView.tileTexture = YES;
        polylineView.keepScale = YES;
        return polylineView;
    }
    return nil;
}

-(void)clearMapView{
    [self.mapView removeOverlays:self.mapView.overlays];
    NSArray *annotations = [NSArray arrayWithArray:self.mapView.annotations];
    for (BMKPointAnnotation *annotation in annotations) {
        if (![[annotation class] isMemberOfClass:[BMKUserLocation class]]) {
            [self.mapView removeAnnotation:annotation];
        }
    }
}

- (NSString*)getMyBundlePath1:(NSString *)filename {
    
    NSBundle * libBundle = MYBUNDLE ;
    if ( libBundle && filename ) {
        NSString * s=[[libBundle resourcePath ] stringByAppendingPathComponent:filename];
        return s;
    }
    return nil ;
}

#pragma mark - 轨迹回放
- (void)locationInCoordinate:(CLLocationCoordinate2D)coordinate {
    CGPoint point = [self.mapView convertCoordinate:coordinate toPointToView:self.mapView];
    
    if (point.x < 20 || (point.x > self.mapView.frame.size.width - 20 )|| point.y < 20 || (point.y > self.mapView.frame.size.height - 130 ))
    {//&& point.y < 2000 && point.x < 1000
        if (coordinate.latitude != 0 && coordinate.longitude!= 0 ) {
            [self.mapView setCenterCoordinate:coordinate animated:YES];
        }
    }
}

-(void)startAnimation{
    
//    if (self.isDrawingRoute) {
//
//        [UIView animateWithDuration:0.3 animations:^{
//            _enlarge.transform =CGAffineTransformMakeTranslation(0, -60);
//            _narrow.transform =CGAffineTransformMakeTranslation(0, -60);
//        }];
//    }else{
//        [UIView animateWithDuration:0.3 animations:^{
//            _enlarge.transform =CGAffineTransformMakeTranslation(0, 0);
//            _narrow.transform =CGAffineTransformMakeTranslation(0, 0);
//        }];
//    }
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
