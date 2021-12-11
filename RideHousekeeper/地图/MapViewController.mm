//
//  MapViewController.m
//  RideHousekeeper
//
//  Created by 同时科技 on 16/6/20.
//  Copyright © 2016年 Duke Wu. All rights reserved.
//

#import "MapViewController.h"
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BMKLocationkit/BMKLocationComponent.h>
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>
#import <QuartzCore/QuartzCore.h>
#import "adressModel.h"
#import "RouteAnnotation.h"
#import "UIImage+Rotate.h"

//#import "OfflineMapViewController.h"
#import "AddressTableViewCell.h"
#import "MapTool.h"
#define NAME        @"userwords"
#define MYBUNDLE_NAME @ "mapapi.bundle"
#define MYBUNDLE_PATH [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: MYBUNDLE_NAME]
#define MYBUNDLE [NSBundle bundleWithPath: MYBUNDLE_PATH]

@interface MapViewController ()<BMKGeoCodeSearchDelegate,UIActionSheetDelegate,BMKRouteSearchDelegate,BMKMapViewDelegate,BMKPoiSearchDelegate,BMKLocationManagerDelegate,UITextFieldDelegate,UITextViewDelegate,UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate>{
    bool isGeoSearch;
    BMKGeoCodeSearch* _geocodesearch;
    BMKPoiSearch* _poisearch;
    BMKRouteSearch* _routesearch;
    int curPage;
}

@property (nonatomic, strong) BMKMapView *mapView;
@property (nonatomic, weak) UITextField *adressField;
@property (nonatomic, strong) BMKLocationManager *locService;

@property (nonatomic, strong) BMKPointAnnotation *annotation;//当前定位的位置
@property (nonatomic, strong) BMKPointAnnotation *annotation2;//导航的终点位置
@property (nonatomic, strong) BMKUserLocation *userLocation; //当前位置对象
@property (nonatomic, strong) NSMutableArray *adressAry;

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIView *footWin;

@property (nonatomic, weak) UITableView *tableview;
@property (nonatomic, copy) NSString *currentCity;
@property (nonatomic, copy) NSString *currentName;
@property (nonatomic, copy) NSString* detailLocation;//目的地
@property (nonatomic, weak) UILabel* ditances;//距离
@property (nonatomic, weak) UILabel* destination;//目的地
@property (nonatomic, weak) UIView *headview;
@property (nonatomic, weak) UIButton *locationBtn;
@property (nonatomic, weak) UIButton *enlarge;
@property (nonatomic, weak) UIButton *narrow;
@property (nonatomic, weak) UILabel *customLab;
@property (nonatomic, assign) CGFloat currentAngle;
@property (nonatomic, assign) BOOL isBack;

@end

@implementation MapViewController

- (NSMutableArray *)adressAry {
    if (!_adressAry) {
        _adressAry = [[NSMutableArray alloc] init];
    }
    return _adressAry;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.mapView viewWillAppear];
    self.mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    _geocodesearch.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    _poisearch.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    _routesearch.delegate = self;
    [self.locService startUpdatingLocation];
    [self.locService startUpdatingHeading];
    self.mapView.zoomLevel = 17;//地图显示比例
}


-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.mapView viewWillDisappear];
    self.mapView.delegate = nil; // 不用时，置nil
    self.locService.delegate = nil;
    _geocodesearch.delegate = nil; // 不用时，置nil
    _poisearch.delegate = nil; // 不用时，置nil
    _routesearch.delegate = nil; // 不用时，置nil
    [self.locService stopUpdatingLocation];
    [self.locService stopUpdatingHeading];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.mapView];
     _routesearch = [[BMKRouteSearch alloc]init];
    _geocodesearch = [[BMKGeoCodeSearch alloc]init];
    _poisearch = [[BMKPoiSearch alloc]init];

    [self setupNavView];
    [self setupHeadView];
    [self setupTable];
    
    UIButton *locationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    locationBtn.frame = CGRectMake(ScreenWidth - 45, ScreenHeight - 50, 35, 35);
    [locationBtn setImage:[UIImage imageNamed:@"location"] forState:UIControlStateNormal];
    locationBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [locationBtn addTarget:self action:@selector(locationClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:locationBtn];
    self.locationBtn = locationBtn;

    UIButton *enlarge = [UIButton buttonWithType:UIButtonTypeCustom];
    enlarge.frame = CGRectMake(ScreenWidth - 45, ScreenHeight - 150, 35, 35);
    enlarge.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [enlarge addTarget:self action:@selector(enlargeClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:enlarge];
    self.enlarge = enlarge;

    UIButton *narrow = [UIButton buttonWithType:UIButtonTypeCustom];
    narrow.frame = CGRectMake(enlarge.x, CGRectGetMaxY(enlarge.frame), 35, 35);
    narrow.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [narrow addTarget:self action:@selector(narrowClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:narrow];
    self.narrow = narrow;

    UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 35, 70)];
    image.image =[UIImage imageNamed:@"fangda"];
    [enlarge addSubview:image];

}

-(void)locationClick{

    [self.mapView setCenterCoordinate:self.annotation.coordinate animated:YES];
    
}

//放大缩小
-(void)enlargeClick{
    
    
    [self.mapView setZoomLevel:self.mapView.zoomLevel+1];//缩小地图
}

-(void)narrowClick{
    
    [self.mapView setZoomLevel:self.mapView.zoomLevel-1];//缩小地图
}

- (void)setupNavView{
    [super setupNavView];
    self.navView.showBottomLabel = NO;
    [self.navView.centerButton setTitle:@"骑行导航" forState:UIControlStateNormal];
    @weakify(self);
    [self.navView.leftButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    self.navView.leftButtonBlock = ^{
        @strongify(self);
        
        [self mapBtnClick];
    };
//    [self.navView.rightButton setImage:[UIImage imageNamed:@"icon_map_set"] forState:UIControlStateNormal];
//    self.navView.rightButtonBlock = ^{
//
//        @strongify(self);
//
//        OfflineMapViewController *offVc = [OfflineMapViewController new];
//        [self.navigationController pushViewController:offVc animated:YES];
//    };
}

-(void)mapBtnClick{

    if (self.isBack) {
        
        [self.mapView removeOverlays:self.mapView.overlays];
        
        NSArray *annotations = [NSArray arrayWithArray:self.mapView.annotations];
        
        [self.mapView setCenterCoordinate:self.annotation.coordinate animated:YES];
        
        for (BMKPointAnnotation *annotation in annotations) {
            if (![[annotation class] isMemberOfClass:[BMKUserLocation class]]) {
                [self.mapView removeAnnotation:annotation];
            }
        }
        [self hidefootView];
        self.isBack = NO;
        
    }else{
    
        [self.navigationController popViewControllerAnimated:YES];
    }
}

//界面绘制
-(void)setupHeadView{
    UIView *headview = [[UIView alloc] init];
    headview.frame = CGRectMake(10, 10 +navHeight , ScreenWidth - 20, 40);
    headview.backgroundColor = [UIColor whiteColor];
    [headview.layer setMasksToBounds:YES];//设置按钮的圆角半径不会被遮挡
    [headview.layer setCornerRadius:5];
    [self.view addSubview:headview];
    self.headview = headview;
    
    UIButton *searchBtn = [[UIButton alloc] init];
    searchBtn.backgroundColor=[UIColor clearColor];
    searchBtn.width = 40;
    searchBtn.height = 40;
    searchBtn.x = headview.width - 40;
    searchBtn.y = 0;
    //[searchBtn setTitle:@"搜索" forState:UIControlStateNormal];
    [searchBtn setImage:[UIImage imageNamed:@"finding"] forState:UIControlStateNormal];
    searchBtn.backgroundColor = [QFTools colorWithHexString:MainColor];
    [searchBtn.layer setMasksToBounds:YES];//设置按钮的圆角半径不会被遮挡
    [searchBtn.layer setCornerRadius:5];
    [searchBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [searchBtn addTarget:self action:@selector(poisearchClick:) forControlEvents:UIControlEventTouchUpInside];
    //[searchBtn addTarget:self action:@selector(onClickRidingSearch:) forControlEvents:UIControlEventTouchUpInside];
    [headview addSubview:searchBtn];
    
    UITextField *adressField = [self addOneTextFieldWithTitle:@"请输入地址" imageName:nil imageNameWidth:10 Frame:CGRectMake(5 , 5, headview.width - 50, 30)];
    [headview addSubview:adressField];
    //[adressField addTarget:self action:@selector(textFieldChanged:) forControlEvents:UIControlEventEditingDidEnd];
    self.adressField = adressField;
}


-(void)setupTable{
    
    _backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    _backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
    _backgroundView.clipsToBounds = YES;
    _backgroundView.layer.cornerRadius = 4;
    _backgroundView.hidden = YES;
    [[UIApplication sharedApplication].keyWindow addSubview:_backgroundView];
    
    UITapGestureRecognizer *addbikeTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(backgroundViewClicked)];
    addbikeTap.delegate = self;
    addbikeTap.numberOfTapsRequired = 1;
    [_backgroundView addGestureRecognizer:addbikeTap];

    _backgroundView.hidden = YES;
    UITableView *tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, ScreenHeight*.3, ScreenWidth, ScreenHeight*.7)];
    tableview.bounces = NO;
    tableview.delegate = self;
    tableview.dataSource = self;
    [tableview registerClass:[AddressTableViewCell class] forCellReuseIdentifier:@"addressCell"];
    [tableview setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    tableview.backgroundColor = [UIColor whiteColor];
    [_backgroundView addSubview:tableview];
    self.tableview = tableview;
    
    _footWin = [[UIView alloc]initWithFrame:CGRectMake(0, ScreenHeight - 130, ScreenWidth, 130)];
    _footWin.backgroundColor = [UIColor clearColor];
    _footWin.clipsToBounds = YES;
    _footWin.layer.cornerRadius = 4;
    _footWin.hidden = YES;
    [self.view addSubview:_footWin];
    [self.view bringSubviewToFront:_footWin];
    
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 50, ScreenWidth, 80)];
    footView.backgroundColor = [UIColor whiteColor];
    [_footWin addSubview:footView];
    
    UILabel *address = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, ScreenWidth- 20, 15)];
    address.textColor = [UIColor blackColor];
    address.font = [UIFont systemFontOfSize:15];
    [footView addSubview:address];
    self.destination = address;
    
    UILabel *distance = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(address.frame) + 10, ScreenWidth - 20, 20)];
    distance.textColor = [QFTools colorWithHexString:@"#CCCCCC"];
    distance.font = [UIFont systemFontOfSize:13];
    [footView addSubview:distance];
    self.ditances= distance;
    
    UIButton *nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    nextBtn.frame = CGRectMake(ScreenWidth - 100, 10, 80, 80);
    nextBtn.backgroundColor = [QFTools colorWithHexString:MainColor];
    [nextBtn.layer setCornerRadius:40]; // 切圆角
    [nextBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [nextBtn setTitle:@"开始导航" forState:UIControlStateNormal];
    nextBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [nextBtn addTarget:self action:@selector(realNavi:) forControlEvents:UIControlEventTouchUpInside];
    [nextBtn setImage:[UIImage imageNamed:@"icon_car_on"] forState:UIControlStateNormal];
    [nextBtn setImageEdgeInsets:UIEdgeInsetsMake(-nextBtn.titleLabel.intrinsicContentSize.height, 0, 0, -nextBtn.titleLabel.intrinsicContentSize.width)];
    [nextBtn setTitleEdgeInsets:UIEdgeInsetsMake(nextBtn.currentImage.size.height + 10, -nextBtn.currentImage.size.width, 0, 0)];
    [_footWin addSubview:nextBtn];
    
}

-(void)backgroundViewClicked{
    
    _backgroundView.hidden = YES;

}

//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch方法。
#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch  {
    // 输出点击的view的类名
    // 若为UITableViewCellContentView（即点击了tableViewCell），则不截获Touch事件
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
        return NO;
    }
    return  YES;
}

//uitebaleview delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.adressAry.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    return 75;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellName = @"addressCell";
   
    AddressTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    
    UILabel *chooseLabel = cell.chooseLabel;
    chooseLabel.text = [self.adressAry[indexPath.row] placename] ;
    
    UILabel *adressLab = cell.adressLab;
    adressLab.text = [NSString stringWithFormat:@"地址:%@",[self.adressAry[indexPath.row] adress]];
    adressLab.numberOfLines = 0;
    
    //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self onClickRidingSearch:indexPath.row];
    _backgroundView.hidden = YES;
}

- ( void )tableView:( UITableView  *)tableView  willDisplayCell :( UITableViewCell  *)cell  forRowAtIndexPath :( NSIndexPath  *)indexPath
{
    
    cell.backgroundColor = [UIColor whiteColor];
    
}

- (void)onClickRidingSearch:(NSInteger)sender {
    
    adressModel *newmodel = self.adressAry[sender];
    self.destination.text = newmodel.placename;
    self.detailLocation = newmodel.adress;
    
    BMKPlanNode* start = [[BMKPlanNode alloc]init];
    start.name = self.currentName;
    start.cityName = self.currentCity;
    BMKPlanNode* end = [[BMKPlanNode alloc]init];
    end.name = newmodel.placename;
    end.cityName = newmodel.city;
    //NSLog(@"start.name%@ start.cityName%@ end.name%@ end.cityName%@",start.name,start.cityName,end.name,end.cityName);
    self.annotation2.coordinate = newmodel.destinationCoor;
    BMKRidingRoutePlanOption *option = [[BMKRidingRoutePlanOption alloc]init];
    option.from = start;
    option.to = end;
    BOOL flag = [_routesearch ridingSearch:option];
    if (flag){
        NSLog(@"骑行规划检索发送成功");
    }else{
        NSLog(@"骑行规划检索发送失败");
        [SVProgressHUD showSimpleText:@"规划路线失败"];
    }
}

/**
 *返回骑行搜索结果
 *@param searcher 搜索对象
 *@param result 搜索结果，类型为BMKRidingRouteResult
 *@param error 错误号，@see BMKSearchErrorCode
 */
- (void)onGetRidingRouteResult:(BMKRouteSearch *)searcher result:(BMKRidingRouteResult *)result errorCode:(BMKSearchErrorCode)error {
    NSLog(@"onGetRidingRouteResult error:%d", error);
    NSArray* array = [NSArray arrayWithArray:self.mapView.annotations];
    [self.mapView removeAnnotations:array];
    array = [NSArray arrayWithArray:self.mapView.overlays];
    [self.mapView removeOverlays:array];
    if (error == BMK_SEARCH_NO_ERROR) {
        BMKRidingRouteLine* plan = (BMKRidingRouteLine*)[result.routes objectAtIndex:0];
        NSInteger size = [plan.steps count];
        float lance = plan.distance/1000;
         //self.ditances.text =  [NSString stringWithFormat:@"%.1f公里",lance] ;
        self.ditances.text = [NSString stringWithFormat:@"%@ | %@",[NSString stringWithFormat:@"%.1f公里",lance],self.detailLocation];
        
        int planPointCounts = 0;
        for (int i = 0; i < size; i++) {
            BMKRidingStep* transitStep = [plan.steps objectAtIndex:i];
            if (i == 0) {
                RouteAnnotation* item = [[RouteAnnotation alloc]init];
                item.coordinate = plan.starting.location;
                item.title = @"起点";
                item.type = 0;
                [self.mapView addAnnotation:item]; // 添加起点标注
            } else if(i==size-1){
                RouteAnnotation* item = [[RouteAnnotation alloc]init];
                item.coordinate = plan.terminal.location;
                item.title = @"终点";
                item.type = 1;
                [self.mapView addAnnotation:item]; // 添加起点标注
            }
            //添加annotation节点
            RouteAnnotation* item = [[RouteAnnotation alloc]init];
            item.coordinate = transitStep.entrace.location;
            item.title = transitStep.instruction;
            item.degree = (int)transitStep.direction * 30;
            item.type = 4;
            [self.mapView addAnnotation:item];
            //轨迹点总数累计
            planPointCounts += transitStep.pointsCount;
        }
        
        //轨迹点
        BMKMapPoint * temppoints = new BMKMapPoint[planPointCounts];
        int i = 0;
        for (int j = 0; j < size; j++) {
            BMKRidingStep* transitStep = [plan.steps objectAtIndex:j];
            int k=0;
            for(k=0;k<transitStep.pointsCount;k++) {
                temppoints[i].x = transitStep.points[k].x;
                temppoints[i].y = transitStep.points[k].y;
                i++;
            }
        }
        // 通过points构建BMKPolyline
        BMKPolyline* polyLine = [BMKPolyline polylineWithPoints:temppoints count:planPointCounts];
        [self.mapView addOverlay:polyLine]; // 添加路线overlay
        delete []temppoints;
        [self mapViewFitPolyLine:polyLine];
        [self showfootView];
        
    }else{
        
        RouteAnnotation* item = [[RouteAnnotation alloc]init];
        item.coordinate = self.annotation2.coordinate;
        item.title = @"终点";
        item.type = 1;
        [self.mapView addAnnotation:item]; // 添加起点标注
        [self.mapView setCenterCoordinate:self.annotation2.coordinate animated:YES];
        [self showfootView];
    }
}


-(void)showfootView{
    self.customLab.text = @"骑行路线";
    _footWin.hidden = NO;
    self.isBack = YES;
    //self.navigationItem.hidesBackButton = YES;
    self.navigationItem.rightBarButtonItem.customView.hidden = YES;
    self.headview.hidden = YES;
    self.locationBtn.hidden = YES;
    [UIView animateWithDuration:0.3 animations:^{
    self.locationBtn.transform =CGAffineTransformMakeTranslation(0, -60);
    self.enlarge.transform =CGAffineTransformMakeTranslation(0, -60);
    self.narrow.transform =CGAffineTransformMakeTranslation(0, -60);
    }];
}

-(void)hidefootView{
    self.customLab.text = @"骑行导航";
    _footWin.hidden = YES;
    self.navigationItem.rightBarButtonItem.customView.hidden = NO;
    self.headview.hidden = NO;
    self.locationBtn.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        self.locationBtn.transform =CGAffineTransformMakeTranslation(0, 0);
        self.enlarge.transform =CGAffineTransformMakeTranslation(0, 0);
        self.narrow.transform =CGAffineTransformMakeTranslation(0, 0);
        
    }];
    
}

- (void)mapView:(BMKMapView *)mapView onClickedMapBlank:(CLLocationCoordinate2D)coordinate{
    
    [self.view endEditing:YES];
}

- (BMKOverlayView*)mapView:(BMKMapView *)map viewForOverlay:(id<BMKOverlay>)overlay
{
    if ([overlay isKindOfClass:[BMKPolyline class]]) {
        BMKPolylineView* polylineView = [[BMKPolylineView alloc] initWithOverlay:overlay];
        polylineView.fillColor = [[UIColor alloc] initWithRed:32/255.0 green:200/255.0 blue:172/255.0 alpha:1];
        polylineView.strokeColor = [[UIColor alloc] initWithRed:32/255.0 green:200/255.0 blue:172/255.0 alpha:0.7];
        polylineView.lineWidth = 5.0;
        polylineView.lineDash = NO;
        polylineView.tileTexture = YES;
        polylineView.keepScale = YES;
        return polylineView;
    }
    return nil;
}

#pragma mark - 私有

//根据polyline设置地图范围
- (void)mapViewFitPolyLine:(BMKPolyline *) polyLine {
    CGFloat ltX, ltY, rbX, rbY;
    if (polyLine.pointCount < 1) {
        return;
    }
    BMKMapPoint pt = polyLine.points[0];
    ltX = pt.x, ltY = pt.y;
    rbX = pt.x, rbY = pt.y;
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
    self.mapView.zoomLevel = self.mapView.zoomLevel - 0.3;
}

//根据anntation生成对应的View
- (BMKAnnotationView *)mapView:(BMKMapView *)view viewForAnnotation:(id <BMKAnnotation>)annotation
{
//    NSString *AnnotationViewID = @"annotationViewID";
//    //根据指定标识查找一个可被复用的标注View，一般在delegate中使用，用此函数来代替新申请一个View
//    BMKAnnotationView *annotationView = [view dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
//    if (annotationView == nil) {
//        annotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
//        ((BMKPinAnnotationView*)annotationView).pinColor = BMKPinAnnotationColorRed;
//        ((BMKPinAnnotationView*)annotationView).animatesDrop = YES;
//    }
//    
//    annotationView.centerOffset = CGPointMake(0, -(annotationView.frame.size.height * 0.5));
//    annotationView.annotation = annotation;
//    annotationView.canShowCallout = YES;
//    return annotationView;
    if (![annotation isKindOfClass:[RouteAnnotation class]]) return nil;
    return [self getRouteAnnotationView:self.mapView viewForAnnotation:(RouteAnnotation *)annotation];
    
    
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

- (NSString*)getMyBundlePath1:(NSString *)filename {
    
    NSBundle * libBundle = MYBUNDLE ;
    if ( libBundle && filename ) {
        NSString * s=[[libBundle resourcePath ] stringByAppendingPathComponent:filename];
        return s;
    }
    return nil ;
}

//进行检索按钮
-(void)poisearchClick:(UIButton *)btn{
    
    [self.adressField resignFirstResponder];
    
    if (![HttpRequest sharedInstance].available) {
        [SVProgressHUD showSimpleText:@"网络未连接"];

        return;
    }
    
    if ([QFTools isBlankString:self.adressField.text] ) {
        [SVProgressHUD showSimpleText:@"请输入目的地"];
        return;
    }
    
    curPage = 0;
    BMKPOICitySearchOption *citySearchOption = [[BMKPOICitySearchOption alloc]init];
    citySearchOption.pageIndex = curPage;
    citySearchOption.pageSize = 20;
    citySearchOption.city= self.adressField.text;
    citySearchOption.keyword = self.adressField.text;
    BOOL flag = [_poisearch poiSearchInCity:citySearchOption];
    if(flag)
    {
        NSLog(@"城市内检索发送成功");
        
    }
    else
    {
        
        NSLog(@"城市内检索发送失败");
    }
    
}

#pragma mark -
#pragma mark implement BMKSearchDelegate
- (void)onGetPoiResult:(BMKPoiSearch *)searcher result:(BMKPOISearchResult*)result errorCode:(BMKSearchErrorCode)error
{
    [self.adressAry removeAllObjects];
    
    if (error == BMK_SEARCH_NO_ERROR) {
        
        if (result.poiInfoList.count == 0) {
            
            [SVProgressHUD showSimpleText:@"地址不匹配，请重新输入"];
            
        }else{
        
            _backgroundView.hidden = NO;
        }
        
        for (int i = 0; i < result.poiInfoList.count; i++) {
            BMKPoiInfo* poi = [result.poiInfoList objectAtIndex:i];
            adressModel* item = [[adressModel alloc]init];
            item.placename = poi.name;
            item.adress = poi.address;
            item.city = poi.city;
            item.destinationCoor = poi.pt;
            [self.adressAry addObject:item];
        }
        
    } else if (error == BMK_SEARCH_AMBIGUOUS_ROURE_ADDR){
        NSLog(@"起始点有歧义");
        [SVProgressHUD showSimpleText:@"起始点有歧义"];
    } else {
        // 各种情况的判断。。。
        [SVProgressHUD showSimpleText:@"目的地错误,请重新输入"];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.tableview reloadData];
    });
}


#pragma mark - 添加输入框方法
- (UITextField *)addOneTextFieldWithTitle:(NSString *)title imageName:(NSString *)imageName imageNameWidth:(CGFloat)width Frame:(CGRect)rect
{
    UITextField *field = [[UITextField alloc] init];
    field.frame = rect;
    field.backgroundColor = [UIColor whiteColor];
    //  field.borderStyle = UITextBorderStyleRoundedRect;
    field.returnKeyType = UIReturnKeyDone;
    field.autocorrectionType = UITextAutocorrectionTypeNo;
    field.autocapitalizationType = UITextAutocapitalizationTypeNone;
    //    [usernameField becomeFirstResponder];
    field.delegate = self;
    field.textColor = [QFTools colorWithHexString:@"#333333"];
    // 设置内容居中
    field.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    field.leftViewMode = UITextFieldViewModeAlways;
    // 设置清除按钮
    // field.clearButtonMode = UITextFieldViewModeWhileEditing;
    // 占位符
    field.placeholder = title;
    return field;
}

- (BMKMapView *)mapView
{
    if (!_mapView) {
        
//        dispatch_queue_t queue = dispatch_queue_create("test", DISPATCH_QUEUE_CONCURRENT);
//        dispatch_async(queue, ^{
//
//        });
        
        _mapView = [[BMKMapView alloc]initWithFrame:CGRectMake(0, navHeight, ScreenWidth, ScreenHeight - navHeight)];
        _mapView.mapType = BMKMapTypeStandard;
        _mapView.showMapScaleBar = YES;
        _mapView.mapScaleBarPosition = CGPointMake(10,ScreenHeight - 50 - navHeight);
        _mapView.showsUserLocation = NO;//先关闭显示的定位图层
        _mapView.userTrackingMode = BMKUserTrackingModeFollow;//设置定位的状态
        _mapView.showsUserLocation = YES;//显示定位图层
        _mapView.rotateEnabled = NO; //设置是否可以旋转
    }
    return _mapView;
}


- (BMKLocationManager *)locService
{
    if (!_locService) {
        _locService = [[BMKLocationManager alloc] init];
        _locService.delegate = self;
        //_locService.distanceFilter = 100;
        //_locService.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;//定位精度
        _locService.coordinateType = BMKLocationCoordinateTypeBMK09LL;
        _locService.desiredAccuracy = kCLLocationAccuracyBest;
        _locService.activityType = CLActivityTypeAutomotiveNavigation;
        _locService.pausesLocationUpdatesAutomatically = NO;
        _locService.allowsBackgroundLocationUpdates = NO;
        _locService.locationTimeout = 10;
    }
    return _locService;
}

- (void)customLocationAccuracyCircle {

    BMKLocationViewDisplayParam* testParam = [[BMKLocationViewDisplayParam alloc] init];
    testParam.isRotateAngleValid = false;// 跟随态旋转角度是否生效
    testParam.isAccuracyCircleShow = false;// 精度圈是否显示
//    testParam.accuracyCircleStrokeColor = [UIColor clearColor];
//    testParam.accuracyCircleFillColor = [UIColor colorWithRed:0 green:1 blue:0 alpha:0.3];
    //testParam.locationViewImgName = @"icon_compass";// 定位图标名称
    testParam.locationViewOffsetX = 0;//定位图标偏移量(经度)
    testParam.locationViewOffsetY = 0;// 定位图标偏移量(纬度)
    
    [self.mapView updateLocationViewWithParam:testParam];
}

/**
 *在地图View将要启动定位时，会调用此函数
 *@param mapView 地图View
 */
- (void)willStartLocatingUser
{
    NSLog(@"start locate");
}

- (void)mapView:(BMKMapView*)mapView onDrawMapFrame:(BMKMapStatus*)status{
    [self setLocationViewAngle:_currentAngle];
}

/**
 *定位失败后，会调用此函数
 *@param mapView 地图View
 *@param error 错误号，参考CLError.h中定义的错误号
 */
- (void)BMKLocationManager:(BMKLocationManager * _Nonnull)manager didFailWithError:(NSError * _Nullable)error {
    
    NSLog(@"定位失败");
}


/**
 *用户方向更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)BMKLocationManager:(BMKLocationManager *)manager didUpdateHeading:(CLHeading *)heading {
    if (!heading) {
        return;
    }
    NSLog(@"heading is %@",self.userLocation.heading);
    //self.userLocation.heading = heading;
    [self.mapView updateLocationData:self.userLocation];
    CGFloat angle = self.userLocation.heading.magneticHeading*M_PI/180;
    _currentAngle= angle;
    [self setLocationViewAngle:_currentAngle];
}

#pragma mark设置定位图标的旋转角度
- (void)setLocationViewAngle:(CGFloat)angle{
    BMKAnnotationView*locationView = [self.mapView valueForKey:@"_locationView"];
    if(locationView){
        locationView.transform=CGAffineTransformMakeRotation(_currentAngle);
        //不设置位置样式的话 直接设置图片
        //locationView.image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"images/bnavi_icon_location_fixed"]];
    }
}

//地图区域发生变化时调用
- (void)mapView:(BMKMapView *)mapView regionWillChangeAnimated:(BOOL)animated{
    
}

/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)BMKLocationManager:(BMKLocationManager *)manager didUpdateLocation:(BMKLocation *)location orError:(NSError *)error {
    
    if (error) {
        NSLog(@"locError:{%ld - %@};", (long)error.code, error.localizedDescription);
    }
    if (!location) {
        return;
    }
    
    CLLocationCoordinate2D coor;
    coor.latitude = location.location.coordinate.latitude;
    coor.longitude = location.location.coordinate.longitude;
    if (self.annotation.coordinate.latitude == location.location.coordinate.latitude && self.annotation.coordinate.longitude == location.location.coordinate.longitude) {
        return;
    }
    
    self.annotation.coordinate = coor;
    self.userLocation.location = location.location;
    [self.mapView updateLocationData:self.userLocation];
    [self customLocationAccuracyCircle];
    //发起反向地理编码检索
    CLLocationCoordinate2D pt = (CLLocationCoordinate2D){coor.latitude, coor.longitude};
    BMKReverseGeoCodeSearchOption *reverseGeoCodeSearchOption = [[BMKReverseGeoCodeSearchOption alloc]init];
    reverseGeoCodeSearchOption.location = pt;
    [_geocodesearch reverseGeoCode:reverseGeoCodeSearchOption];
}

//接收反向地理编码结果
-(void) onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:
(BMKReverseGeoCodeSearchResult *)result
errorCode:(BMKSearchErrorCode)error{
  if (error == BMK_SEARCH_NO_ERROR) {
      
      BMKPoiInfo* poi = [result.poiList objectAtIndex:0];
      if ([self.currentName isEqualToString:poi.name]) {
          
          return;
      }
      
      self.currentCity = result.addressDetail.city;
      self.currentName = poi.name;
      //NSLog(@"%@---%@ ---%@  城市:%@,地址：%@",result.address,result.addressDetail.city,result.addressDetail.streetNumber,self.currentCity,self.currentName);
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


- (BMKPointAnnotation *)annotation
{
    if (!_annotation) {
        _annotation = [[BMKPointAnnotation alloc] init];
    }
    return _annotation;
}

- (BMKPointAnnotation *)annotation2
{
    if (!_annotation2) {
        _annotation2 = [[BMKPointAnnotation alloc] init];
    }
    return _annotation2;
}

- (BMKUserLocation *)userLocation {
    if (!_userLocation) {
        _userLocation = [[BMKUserLocation alloc] init];
    }
    return _userLocation;
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    return YES;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    int a;
    a = (int)self.annotation2.coordinate.longitude;
    
    if (a == 0 ) {
        
        
    }else if (a != 0){
        
        CLLocationCoordinate2D coor;
        coor.latitude = 0.00;
        coor.longitude = 0.00;
        self.annotation2.coordinate = coor;
    }
    
    return YES;
}

///////////////////导航//////////////////////////

//真实GPS导航
- (void)realNavi:(UIButton*)button
{
    if ([QFTools isBlankString:self.adressField.text] ) {
        [SVProgressHUD showSimpleText:@"请输入目的地"];
        return;
    }
    
    int a;
    a = (int)self.annotation2.coordinate.longitude;
    
    if (a == 0 ) {
        [SVProgressHUD showSimpleText:@"请先查询目的地"];
        return;
    }
    
    [[MapTool sharedMapTool] navigationActionWithCoordinate:self.annotation.coordinate fromName:self.currentName tocoordinate:self.annotation2.coordinate WithENDName:self.detailLocation tager:self];
}


- (void)dealloc {
    [self.mapView removeFromSuperview];
    
    if (_poisearch != nil) {
        _poisearch = nil;
    }
    if (_geocodesearch) {
        _geocodesearch = nil;
    }
    if (_routesearch != nil) {
        _routesearch = nil;
    }
    if (self.locService != nil) {
        self.locService = nil;
    }
    if (self.mapView != nil) {
        self.mapView.delegate = nil;
        self.mapView = nil;
    }
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
