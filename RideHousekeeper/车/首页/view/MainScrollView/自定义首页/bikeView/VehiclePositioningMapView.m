//
//  VehiclePositioningMapView.m
//  RideHousekeeper
//
//  Created by Apple on 2018/2/27.
//  Copyright © 2018年 Duke Wu. All rights reserved.
//

#import "VehiclePositioningMapView.h"
#import "MaskView.h"
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>
#import "SingelGPSMaskView.h"
#import "GPSInactivatedMaskView.h"
#import "Manager.h"
@interface VehiclePositioningMapView()<ManagerDelegate>

@property (nonatomic, strong) BMKPointAnnotation    *annotation;
//@property (nonatomic, strong) MaskView                  *maskView;
@property (nonatomic, strong) SingelGPSMaskView         *coverView,*maskView;
@property (nonatomic, strong) GPSInactivatedMaskView    *inactivatedMaskView;
@property (nonatomic, assign) BOOL                      isActivation;
@end

@implementation VehiclePositioningMapView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)setBikeid:(NSInteger)bikeid{
    _bikeid = bikeid;
    
}


-(void)setBikeStatusInfo:(BikeStatusInfoModel*)model{
    
    CLLocationCoordinate2D coor = BMKCoordTrans(CLLocationCoordinate2DMake(model.pos.lat, model.pos.lng), BMK_COORDTYPE_GPS, BMK_COORDTYPE_BD09LL);
    CLLocationDistance distance = BMKMetersBetweenMapPoints(BMKMapPointForCoordinate(coor),BMKMapPointForCoordinate(self.annotation.coordinate));
    
    if(distance>0){
        self.annotation.coordinate = coor;
        self.annotation.title = model.pos.desc;
        self.mapView.centerCoordinate = coor;
        [self.mapView selectAnnotation:self.annotation animated:YES];
    }
    
    [self.mapView addAnnotation:self.annotation];
    
    if (_viewType == 2){
            
        [self.maskView setBikeStatusInfo:model];
    }else if (_viewType == 3){
            
        [self.coverView setBikeStatusInfo:model];
    }
    
   // if (model.is_online == 1 && !_isActivation) {
      if (!_isActivation) {
        NSMutableArray *ary = [LVFmdbTool queryPeripheralActivationStatusData:[NSString stringWithFormat:@"SELECT * FROM peripheralActivationStatus_models WHERE bikeid = '%zd'",_bikeid]];
        
        if (ary.count > 0) {
            
            PeripheralActivationStatusModel *model = ary.firstObject;
            if (model.activationStatus == 0) {
                [LVFmdbTool modifyData:[NSString stringWithFormat:@"UPDATE peripheralActivationStatus_models SET activationStatus = '%zd' WHERE bikeid = '%zd'",1,_bikeid]];
                [[Manager shareManager] updateGPSMapActivationStatus:_bikeid];
            }
            
        }else{
            
            PeripheralModel *peripheralModel = [[LVFmdbTool queryPeripheraData:[NSString stringWithFormat:@"SELECT * FROM periphera_modals WHERE type = '%d' AND bikeid = '%zd'",4,_bikeid]] firstObject];
            PeripheralActivationStatusModel *model = [PeripheralActivationStatusModel modelWith:_bikeid deviceid:peripheralModel.deviceid type:4 activationStatus:1];
            [LVFmdbTool insertPeripheralActivationStatusModel:model];
            [[Manager shareManager] updateGPSMapActivationStatus:_bikeid];
        }
    }
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [[Manager shareManager] addDelegate:self];
        [self UIviewSetShadow:self ShadowColor:[UIColor blackColor] ShadowOffset:CGSizeMake(0.0f, 0.0f) ShadowOpacity:0.15f shadowRadius:5.0f];
        [self setupUI];
    }
    return self;
}




- (BMKMapView *)mapView
{
    if (!_mapView) {
        //_mapView = [[BMKMapView alloc]initWithFrame:self.bounds];
        _mapView = [[BMKMapView alloc]initWithFrame:CGRectMake(0, 0, self.width, (int)self.height)];
        _mapView.layer.cornerRadius = 10;
        _mapView.layer.masksToBounds = YES;
        _mapView.mapType = BMKMapTypeStandard;
        _mapView.buildingsEnabled = NO;
        [_mapView setZoomLevel:15];//缩小地图
    }
    return _mapView;
}

-(void)setupUI{
    [self addSubview:self.mapView];
    self.mapView.delegate = self;
    
    for (UIView *view in self.mapView.subviews) {
        for (UIImageView *imageView in view.subviews) {
            static int a = 0;
            a ++;
            if (a == 4) {
                [imageView removeFromSuperview];
                a = 0;
            }
        }
    }
}

- (BMKPointAnnotation *)annotation
{
    if (!_annotation) {
        _annotation = [[BMKPointAnnotation alloc] init];
    }
    return _annotation;
}


- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation
{
    //普通annotation
    if ([annotation isKindOfClass:[BMKPointAnnotation class]]) {
        NSString *AnnotationViewID = @"renameMark";
        BMKPinAnnotationView *annotationView = (BMKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
        if (annotationView == nil) {
            annotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
            if (annotation == self.annotation) {
                // 设置颜色
                annotationView.pinColor = BMKPinAnnotationColorGreen;
                // 设置可拖拽
                annotationView.draggable = NO;
                annotationView.image = [UIImage imageNamed:@"bike_position"];
                annotationView.annotation = annotation;
            }
            // 从天上掉下效果
            annotationView.animatesDrop = NO;
        }
        return annotationView;
    }
    return nil;
}

//-(MaskView *)maskView{
//
//    if (!_maskView) {
//        _maskView = [[MaskView alloc] initWithFrame:self.bounds];
//    }
//    return _maskView;
//}

-(SingelGPSMaskView *)maskView{
    
    if (!_maskView) {
        _maskView = [[SingelGPSMaskView alloc] initWithFrame:self.bounds];
    }
    return _maskView;
}


-(SingelGPSMaskView *)coverView{
    
    if (!_coverView) {
        _coverView = [[SingelGPSMaskView alloc] initWithFrame:self.bounds];
    }
    return _coverView;
}

-(GPSInactivatedMaskView *)inactivatedMaskView{
    
    if (!_inactivatedMaskView) {
        _inactivatedMaskView = [[GPSInactivatedMaskView alloc] initWithFrame:self.bounds];
        _inactivatedMaskView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickInactivatedMaskView)];
        [_inactivatedMaskView addGestureRecognizer:tap];
    }
    return _inactivatedMaskView;
}

-(void)clickInactivatedMaskView{
    
    if (self.bikeActivatedViewClickBlock) {
        self.bikeActivatedViewClickBlock();
    }
}


- (void)setViewType:(NSInteger)viewType{
    _viewType = viewType;
    if (viewType == 2){
        
        [self addSubview:self.maskView];
        self.maskView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickMaskView)];
        [self.maskView addGestureRecognizer:tap];
        
        PerpheraServicesInfoModel *serviceInfo = [[LVFmdbTool queryPerpheraServicesInfoData:[NSString stringWithFormat:@"SELECT * FROM peripheraServicesInfo_modals WHERE (type = '%zd' OR type = '%zd') AND bikeid = '%zd'", 0,1,_bikeid]] firstObject];
        
        switch (serviceInfo.type) {
                
            case 0:{
                
                if (serviceInfo.left_days >0) {
                    self.maskView.type = 0;
                }else{
                    self.maskView.type = 2;
                }
                break;
            }
            case 1:{
                
                if (serviceInfo.left_days >0) {
                    self.maskView.type = 1;
                }else{
                    self.maskView.type = 2;
                }
                
                break;
                
            }
            default:
                break;
        }
        
    }else if (viewType == 3){
        
        [self addSubview:self.coverView];
        self.coverView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickMaskView)];
        [self.coverView addGestureRecognizer:tap];
        
        PerpheraServicesInfoModel *serviceInfo = [[LVFmdbTool queryPerpheraServicesInfoData:[NSString stringWithFormat:@"SELECT * FROM peripheraServicesInfo_modals WHERE (type = '%zd' OR type = '%zd') AND bikeid = '%zd'", 0,1,_bikeid]] firstObject];
        
        switch (serviceInfo.type) {
            case 0:{
                
                if (serviceInfo.left_days >0) {
                    self.coverView.type = 0;
                }else{
                    self.coverView.type = 2;
                }
                break;
            }
            case 1:{
                
                if (serviceInfo.left_days >0) {
                    self.coverView.type = 1;
                }else{
                    self.coverView.type = 2;
                }
                break;
            }
            default:
                break;
        }
    }
    
    [self determineGPSIsActivated:_bikeid];
}

-(void)clickMaskView{
    
    if (self.bikeMapClickBlock) {
        self.bikeMapClickBlock();
    }
}

-(void)determineGPSIsActivated:(NSInteger)bikeid{
    PeripheralActivationStatusModel *model = [[LVFmdbTool queryPeripheralActivationStatusData:[NSString stringWithFormat:@"SELECT * FROM peripheralActivationStatus_models WHERE bikeid = '%zd'",bikeid]] firstObject];
    switch (model.activationStatus) {
        case 0:
            _isActivation = NO;
            [self addSubview:self.inactivatedMaskView];
            break;
        case 1:
            _isActivation = YES;
            if (_inactivatedMaskView) {
                
                [UIView animateWithDuration:0.3 animations:^{
                    _inactivatedMaskView.alpha = 0;
                } completion:^(BOOL finished) {
                    [_inactivatedMaskView removeFromSuperview];
                    _inactivatedMaskView = nil;
                }];
                
            }
            break;
        default:
            break;
    }
}


-(void)dealloc{
    
    if (self.mapView) {
        self.mapView.delegate = nil;
        self.mapView = nil;
    }
    
    if (self.annotation) {
        self.annotation= nil;
    }
    [[Manager shareManager] deleteDelegate:self];
}

-(void)manager:(Manager *)manager updateGPSMapActivationStatus:(NSInteger)bikeid{
    if (_bikeid == bikeid) {
        [self determineGPSIsActivated:bikeid];
    }
}

-(void)manager:(Manager *)manager updateGPSServiceInfo:(NSInteger)bikeid{
    
    if (_bikeid != bikeid) {
        return;
    }
    PerpheraServicesInfoModel *servicesModel = [[LVFmdbTool queryPerpheraServicesInfoData:[NSString stringWithFormat:@"SELECT * FROM peripheraServicesInfo_modals WHERE type LIKE '%zd' AND bikeid LIKE '%zd'", 1,bikeid]] firstObject];
    if (servicesModel.left_days > 0) {
        if (_viewType == 2) {
            self.maskView.type = 1;
        }else{
            self.coverView.type = 1;
        }
    }
}

@end
