//
//  VehicleTrackPlaybackViewController.m
//  RideHousekeeper
//
//  Created by Apple on 2020/5/18.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import "VehicleTrackPlaybackViewController.h"
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>
#import "TrajectoryRouteInformationView.h"
#import "AnimationObjectProtocol.h"
#import "RouteAnnotation.h"
#import "UIImage+Rotate.h"
#import "SportNode.h"
#import "SportAnnotationView.h"
#import "TrackAnnotation.h"
#import "GPSSignalPopupView.h"

#define MYBUNDLE_NAME @ "mapapi.bundle"
#define MYBUNDLE_PATH [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: MYBUNDLE_NAME]
#define MYBUNDLE [NSBundle bundleWithPath: MYBUNDLE_PATH]

@interface VehicleTrackPlaybackViewController ()<BMKMapViewDelegate,AnimationObjectProtocol>

@property (nonatomic, strong) BMKMapView* mapView;
@property (nonatomic, strong) SportAnnotationView *sportAnnotationView;//车辆运动轨迹
@property (nonatomic, strong) NSMutableArray *sportNodes; // 轨迹点
@property (nonatomic, strong) TrajectoryRouteInformationView *trajectoryRoute;

@end

@implementation VehicleTrackPlaybackViewController

-(TrajectoryRouteInformationView *)trajectoryRoute{
    
    if (!_trajectoryRoute) {
        _trajectoryRoute = [[TrajectoryRouteInformationView alloc] init];
        _trajectoryRoute.backgroundColor = [UIColor whiteColor];
        @weakify(self);
        _trajectoryRoute.playBtnStep = ^(BOOL selected) {
            @strongify(self);
            if (selected) {
                [self.sportAnnotationView start];
            } else {
                [self.sportAnnotationView pause];
            }
        };
        
        _trajectoryRoute.slidingValue = ^(NSInteger value) {
            @strongify(self);
            
            self.sportAnnotationView.annotation.coordinate = [[self.sportNodes objectAtIndex:value] coordinate];
            [self locationInCoordinate:[[self.sportNodes objectAtIndex:value] coordinate]];
            self.sportAnnotationView->_currentIndex = value;
            
            if (!self.trajectoryRoute.playBtn.selected) {
                self.trajectoryRoute.playBtn.selected = YES;
                self.trajectoryRoute.slider.selected = YES;
                [self.sportAnnotationView start];
            }
        };
    }
    return _trajectoryRoute;
}

-(NSMutableArray*)sportNodes{
    if (!_sportNodes) {
        _sportNodes = [NSMutableArray array];
    }
    return _sportNodes;
}


-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    [self.mapView viewWillAppear];
    self.mapView.delegate = self;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.mapView viewWillDisappear];
    self.mapView.delegate = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupNavView];
    [self.view addSubview:self.mapView];
    //        for (UIView *view in _mapView.subviews) {
    //            for (UIImageView *imageView in view.subviews) {
    //                static int a = 0;
    //                a ++;
    //                if (a == 4) {
    //                    [imageView removeFromSuperview];
    //                    a = 0;
    //                }
    //            }
    //        }
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
    }
    return _mapView;
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
    if (_sportAnnotationView) {
        _sportAnnotationView = nil;
    }
    
    if (_trajectoryRoute) {
        _trajectoryRoute = nil;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// 根据anntation生成对应的View
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation{
    //普通annotation
    if ([[annotation class] isEqual:[RouteAnnotation class]]){
        return [self getRouteAnnotationView:self.mapView viewForAnnotation:(RouteAnnotation *)annotation];
    }else if ([[annotation class] isEqual:[TrackAnnotation class]]){
        __weak typeof(self) weakSelf = self;
        _sportAnnotationView = (SportAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"SportsAnnotation"];
        //if (_sportAnnotationView == nil) {
            _sportAnnotationView = [[SportAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"SportsAnnotation"];
            _sportAnnotationView.sportNodes = self.sportNodes;
            _sportAnnotationView.selected = YES;
            _sportAnnotationView.completion = ^{
                weakSelf.trajectoryRoute.slider.selected = NO;
                weakSelf.trajectoryRoute.playBtn.selected = NO;
                [weakSelf.sportAnnotationView stop];
                [weakSelf.trajectoryRoute.slider setValue:0 animated:NO];
            };
            _sportAnnotationView.nextStep = ^(SportNode *node,NSInteger num) {
                [weakSelf.trajectoryRoute.slider setValue:num animated:YES];
                [weakSelf locationInCoordinate:node.coordinate];
            };
        //}
        //[_sportAnnotationView stop];
        return _sportAnnotationView;
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

#pragma CyclingRouteDrawingDelegate
-(void)DrawingCyclingRoute:(DayRideReportModel *)model{
    [self clearMapView];
    NSString *token = [QFTools getdata:@"token"];
    NSNumber *bikeNum = [NSNumber numberWithInteger:_bikeid];
    NSString *URLString = [NSString stringWithFormat:@"%@%@",QGJURL,@"app/getbiketrack"];
    NSDictionary *parameters = @{@"token":token, @"bike_id": bikeNum,@"begin_ts": [NSNumber numberWithInteger:model.content.begin_ts],@"end_ts": [NSNumber numberWithInteger:model.content.end_ts]};
    [[HttpRequest sharedInstance] postWithURLString:URLString parameters:parameters success:^(id _Nullable dict) {

        if ([dict[@"status"] intValue] == 0) {
            NSDictionary *data = dict[@"data"];
            NSArray *track = data[@"track"];
            
            if ([track isEqual:[NSNull null]]){
                [SVProgressHUD showSimpleText:dict[@"status_info"]];
                return ;
            }
            
            [self.sportNodes removeAllObjects];
            for (int i = 0; i < track.count; i++) {
                GpsPointModel *gpsModel = [GpsPointModel yy_modelWithDictionary:track[i]];
                CLLocationCoordinate2D Coord = BMKCoordTrans(CLLocationCoordinate2DMake(gpsModel.lat, gpsModel.lng), BMK_COORDTYPE_GPS, BMK_COORDTYPE_BD09LL);
                SportNode *node = [[SportNode alloc] init];
                node.coordinate = Coord;
                node.ts = gpsModel.ts;
                [self.sportNodes addObject:node];
                
                if (i == 0) {
                    RouteAnnotation* item = [[RouteAnnotation alloc]init];
                    item.coordinate = Coord;
                    item.title = @"起点";
                    item.type = 0;
                    [self.mapView addAnnotation:item]; // 添加起点标注
                } else if(i==track.count-1){
                    RouteAnnotation* item = [[RouteAnnotation alloc]init];
                    item.coordinate = Coord;
                    item.title = @"终点";
                    item.type = 1;
                    [self.mapView addAnnotation:item]; // 添加起点标注
                }
//                else{
//
//                    RouteAnnotation* item = [[RouteAnnotation alloc]init];
//                    item.coordinate = Coord;
//                    item.title = @"经过点";
//                    item.type = 4;
//                    [self.mapView addAnnotation:item];
//                }
            }
            //轨迹点
            CLLocationCoordinate2D * temppoints = new CLLocationCoordinate2D[track.count];
            for (int i = 0; i < track.count; i++) {

                GpsPointModel *gpsModel = [GpsPointModel yy_modelWithDictionary:track[i]];
                temppoints[i] = BMKCoordTrans(CLLocationCoordinate2DMake(gpsModel.lat, gpsModel.lng), BMK_COORDTYPE_GPS, BMK_COORDTYPE_BD09LL);
            }
             //通过points构建BMKPolyline
            BMKPolyline* polyLine = [BMKPolyline polylineWithCoordinates:temppoints count:track.count];
            [self.mapView addOverlay:polyLine]; // 添加路线overlay
            delete []temppoints;
            [self mapViewFitPolyLine:polyLine];

            [self.view addSubview:self.trajectoryRoute];
            [_trajectoryRoute mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.view).offset(30);
                make.bottom.equalTo(self.view).offset(-30);
                make.right.equalTo(self.view).offset(-30);
                make.height.mas_equalTo(110);
            }];
            _trajectoryRoute.model = model;
            //[self addSubViews];
            TrackAnnotation *sportAnnotation = [[TrackAnnotation alloc]init];
            sportAnnotation.coordinate = [self.sportNodes.firstObject coordinate];
            [self.mapView addAnnotation:sportAnnotation];
            _trajectoryRoute.slider.minimumValue = 0;
            _trajectoryRoute.slider.maximumValue = self.sportNodes.count - 1;
        }else{
            
            [SVProgressHUD showSimpleText:dict[@"status_info"]];
        }

    }failure:^(NSError *error) {
        NSLog(@"error :%@",error);
        [SVProgressHUD showSimpleText:TIP_OF_NO_NETWORK];
    }];
    
    
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

@end
