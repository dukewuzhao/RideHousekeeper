//
//  SideMenuViewController.m
//  RideHousekeeper
//
//  Created by Apple on 2017/8/22.
//  Copyright © 2017年 Duke Wu. All rights reserved.
//
#import "SideMenuViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "PersonalViewController.h"
#import "PublicWebpageViewController.h"
#import "MyGarageViewController.h"
#import "SetUpViewController.h"
#import "BikeMessageViewController.h"
#import "BikeViewController.h"
#import "IdeaViewController.h"
#import "SideMenuTableViewCell.h"
#import "Manager.h"

//#import "GPSServicesViewController.h"

@interface SideMenuViewController ()<UITableViewDelegate, UITableViewDataSource,CLLocationManagerDelegate,ManagerDelegate>

@property (nonatomic, copy) NSArray *imageArray;
@property (nonatomic, copy) NSArray *titleArray;
@property(nonatomic,strong) CLLocationManager *locationManager;
@property(nonatomic, copy) NSString* cityname;//定位到的当前城市名称
@property (nonatomic, weak) UIImageView *userImage;
@property(nonatomic, weak) UIImageView *weathericon;
@property(nonatomic, weak) UILabel *weatherLab;
@property(nonatomic, weak) UILabel *temperatureLab;
@property(nonatomic, weak) UILabel *environmentLab;
@property(nonatomic, weak) UILabel *nameLabel;
@property(nonatomic, weak) UILabel *cityLab;
@property (nonatomic, strong)UIAlertView *LocationAlertView;
@end

@implementation SideMenuViewController

- (UIImage *)buildImage:(CGFloat)startLocations :(CGFloat)endLocations :(CGSize)targetSize{
    UIGraphicsBeginImageContextWithOptions(targetSize, YES, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat components[8]={
        6/255.0, 193/255.0,   174/255.0,  1,
        255/255.0  , 255/255.0, 255/255.0,  1
    };
    CGFloat locations[2]={startLocations,endLocations};
    CGGradientRef gradient= CGGradientCreateWithColorComponents(colorSpace, components, locations, 2);
    CGContextDrawLinearGradient(context, gradient, CGPointZero, CGPointMake(0, targetSize.height), kCGGradientDrawsAfterEndLocation);
    CGColorSpaceRelease(colorSpace);
    CGGradientRelease(gradient);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[Manager shareManager] addDelegate:self];
    self.view.backgroundColor = [UIColor whiteColor];
    _imageArray = @[@"icon_my_Message",@"icon_my_garage",@"help_center", @"fade_back",@"icon_about_us"];
    _titleArray = @[@"我的消息",@"我的车库", @"帮助中心",@"用户反馈",@"关于我们"];
    [self setupHead];
    [self setupTableview];
}

-(void)setupHead{

    UIImageView *headview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.size.width, ScreenHeight*.337)];
    headview.userInteractionEnabled = YES;
    [self.view addSubview:headview];
    headview.image = [self buildImage:0 :1.0 :headview.bounds.size];
    
    UIImageView *userImage = [UIImageView new];
    userImage.frame = CGRectMake(ScreenWidth *.1, headview.height *.275, headview.height *.311, headview.height *.311);
    //如果为空，从网络请求图片，否则从类存直接取
    if (![QFTools getphoto:[QFTools getuserInfo:@"icon"]]) {
        NSURL *url=[NSURL URLWithString:[QFTools getuserInfo:@"icon"]];
        
        [userImage sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"small_default_imag"] completed:^(UIImage *image, NSError*error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (image) {
                userImage.image = [UIImage pq_ClipCircleImageWithImage:image circleRect:CGRectMake(0, 0, image.size.width, image.size.height)];
            }
        }];
    }else{
        UIImage *image = [QFTools getphoto:[QFTools getuserInfo:@"icon"]];
        userImage.image = [UIImage pq_ClipCircleImageWithImage:image circleRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    }
    
    [headview addSubview:userImage];
    self.userImage = userImage;
    
    [userImage lm_addCorner:headview.height *.311/2.0 borderWidth:2.5 borderColor:[QFTools colorWithHexString:MainColor] backGroundColor:[UIColor clearColor]];
    
    UIButton *btn = [[UIButton alloc] init];
    btn.frame = userImage.frame;
    [btn addTarget:self action:@selector(userIconClicked) forControlEvents:UIControlEventTouchUpInside];
    [headview addSubview:btn];

    UILabel *nameLabel = [UILabel new];
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.font = FONT_PINGFAN(20);
    if ([QFTools getuserInfo:@"nick_name"].length == 0) {
        nameLabel.text = [QFTools getdata:@"phone_num"];
    }else{
        nameLabel.text = [QFTools getuserInfo:@"nick_name"];
    }
    [headview addSubview:nameLabel];
    self.nameLabel = nameLabel;
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(userImage);
        make.top.mas_equalTo(userImage.mas_bottom).offset(15);
    }];
    
    
    UIImageView *weatherIcon = [UIImageView new];
    weatherIcon.image = [UIImage imageNamed:@"duoyun"];
    [headview addSubview:weatherIcon];
    self.weathericon = weatherIcon;
    
    UIView *lineView = [UIView new];
    lineView.backgroundColor = [UIColor whiteColor];
    [headview addSubview:lineView];
    
    UILabel *weatherLab = [[UILabel alloc] init];
    weatherLab.textColor = [UIColor whiteColor];
    weatherLab.font = FONT_PINGFAN(13);
    weatherLab.text = @"天气";
    [headview addSubview:weatherLab];
    self.weatherLab = weatherLab;
    
    UILabel *temperatureLab = [[UILabel alloc] init];
    temperatureLab.textColor = [UIColor whiteColor];
    temperatureLab.text = @"温度";
    temperatureLab.font = FONT_PINGFAN(15);
    [headview addSubview:temperatureLab];
    self.temperatureLab = temperatureLab;
    
    UILabel *environmentLab = [[UILabel alloc] init];
    environmentLab.textColor = [UIColor whiteColor];
    environmentLab.font = FONT_PINGFAN(13);
    environmentLab.text = @"空气";
    [headview addSubview:environmentLab];
    self.environmentLab = environmentLab;
    
    UILabel *cityLab = [[UILabel alloc] init];
    cityLab.textColor = [UIColor whiteColor];
    cityLab.numberOfLines = 1;
    cityLab.font = FONT_PINGFAN(17);
    cityLab.text = @"xxxxxx";
    [headview addSubview:cityLab];
    self.cityLab = cityLab;
    
    [cityLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(userImage.mas_right).offset(20);
        make.top.mas_equalTo(userImage.mas_top).offset(10);
    }];
    
    [weatherIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(cityLab.mas_centerX);
        make.top.equalTo(cityLab.mas_bottom).offset(-5);
        make.size.mas_equalTo(CGSizeMake(headview.height * .162, headview.height * .18));
    }];
    
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(cityLab.mas_right).offset(5);
        make.top.equalTo(userImage.mas_top).offset(5);
        make.size.mas_equalTo(CGSizeMake(0.5, ScreenWidth * .18-10));
    }];
    
    
    [temperatureLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(lineView.mas_right).offset(5);
        make.top.equalTo(lineView.mas_top).offset(-5);
    }];
    [weatherLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(lineView.mas_right).offset(5);
        make.centerY.equalTo(lineView.mas_centerY);
    }];
    [environmentLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(lineView.mas_left).offset(5);
        make.bottom.equalTo(lineView.mas_bottom).offset(5);
    }];
    
    [self locate];
}


-(void)userIconClicked{

    [self XYSidePushViewController:[PersonalViewController new] animated:YES];
}

-(void)setupTableview{
    UITableView *rootTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, ScreenHeight *.374 , self.view.size.width, 300) style:UITableViewStylePlain];
    rootTableView.backgroundColor = [UIColor clearColor];
    rootTableView.delegate = self;
    rootTableView.dataSource = self;
    rootTableView.scrollEnabled = NO;
    rootTableView.separatorStyle = NO;
    [self.view addSubview:rootTableView];
}

#pragma mark --- tableView Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _titleArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SideMenuTableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:@"sideMenuCell"];
    if (!cell) {
        cell = [[SideMenuTableViewCell alloc] initWithStyle:0 reuseIdentifier:@"sideMenuCell"];
    }
    UIImageView *icon = cell.IMG;
    icon.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@", _imageArray[indexPath.row]]];
    [[cell contentView] addSubview:icon];
    
    UILabel *textLab = cell.TITLE;
    textLab.text = [NSString stringWithFormat:@"%@", _titleArray[indexPath.row]];
    textLab.font = [UIFont systemFontOfSize:18];
    [[cell contentView] addSubview:textLab];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row == 0) {
        
        [self XYSidePushViewController:[BikeMessageViewController new] animated:YES];
    }else if (indexPath.row == 1){
        [self XYSidePushViewController:[MyGarageViewController new] animated:YES];
        
    }else if (indexPath.row == 2){
        
        PublicWebpageViewController *helpVc = [PublicWebpageViewController new];
        helpVc.topTitle = @"骑管家帮助中心";
        helpVc.userPrivacyUrl = @"http://m.smart-qgj.com/qgj_help.html";;
        [self XYSidePushViewController:helpVc animated:YES];
    }else if (indexPath.row == 3){
        
        [self XYSidePushViewController:[IdeaViewController new] animated:YES];
    }else if (indexPath.row == 4){
        
        [self XYSidePushViewController:[SetUpViewController new] animated:YES];
    }
}

//- ( void )tableView:( UITableView *)tableView willDisplayCell :( UITableViewCell *)cell forRowAtIndexPath :( NSIndexPath *)indexPath
//{
//    cell .backgroundColor = [UIColor colorWithWhite:0 alpha:0];
//}

- ( void )tableView:( UITableView  *)tableView  willDisplayCell :( UITableViewCell  *)cell  forRowAtIndexPath :( NSIndexPath  *)indexPath{
    
    cell.backgroundColor = [UIColor clearColor];
}


- (void)locate{
    // 开始定位
    [self.locationManager startUpdatingLocation];
    
}

-(CLLocationManager *)locationManager{
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init] ;
        _locationManager.distanceFilter=1000.0f;
        _locationManager.delegate = self;
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0){
            [_locationManager requestWhenInUseAuthorization];
            //[_locationManager requestAlwaysAuthorization];
        }
    }
    return _locationManager;
}

//5.实现定位协议回调方法
#pragma mark - CoreLocation Delegate

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    [manager stopUpdatingLocation];
    //此处locations存储了持续更新的位置坐标值，取最后一个值为最新位置，如果不想让其持续更新位置，则在此方法中获取到一个值之后让locationManager stopUpdatingLocation
    CLLocation *currentLocation = [locations lastObject];
    // 获取当前所在的城市名
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    //根据经纬度反向地理编译出地址信息
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *array, NSError *error){
         
         if (array.count > 0){
             
             CLPlacemark *placemark = [array objectAtIndex:0];
             //获取城市
             NSString *city = placemark.locality;
             
             if (!city) {
                 //四大直辖市的城市信息无法通过locality获得，只能通过获取省份的方法来获得（如果city为空，则可知为直辖市）
                 city = placemark.administrativeArea;
             }
             
             if ([self.cityname isEqualToString:city]) {
                 return ;
             }
             self.cityname = city;
             self.cityLab.text = city;
             [self setupWeather];
         }else if (error == nil && [array count] == 0){
             NSLog(@"No results were returned.");
         }else if (error != nil){
             NSLog(@"An error occurred = %@", error);
         }
     }];
    
    //系统会一直更新数据，直到选择停止更新，因为我们只需要获得一次经纬度即可，所以获取之后就停止更新
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
    if (error.code == kCLErrorDenied) {
        
        // 提示用户出错原因，可按住Option键点击 KCLErrorDenied的查看更多出错信息，可打印error.code值查找原因所在
    }
}


//天气接口处理
- (void)setupWeather{
    NSLog(@"请求天气了");
    if (self.cityname == nil) {
        self.cityname = @"上海";
    }
    
    NSString *URLString = [NSString stringWithFormat:@"%@?location=%@&output=json&ak=u7aBHig996uKKfHf4kzhpzq7LvVhn2dl", baidu,self.cityname];
    NSString *newStr = [URLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:newStr];
    NSURLRequest *requst = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
    //异步链接(形式1,较少用)
    [NSURLConnection sendAsynchronousRequest:requst queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        // self.imageView.image = [UIImage imageWithData:data];
        // 解析
        
        if (response == nil) {
            [SVProgressHUD showSimpleText:TIP_OF_NO_NETWORK];
            return ;
        }
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        NSMutableArray *weatherDict = dic[@"results"];
        NSDictionary *userinfo = weatherDict[0];
        NSMutableArray *dataDict = userinfo[@"weather_data"];
        NSString *pm25 = userinfo[@"pm25"];
        
        NSDictionary *datawe = dataDict[0];
        NSString *weather = datawe[@"weather"];
        
        NSString *dayPictureUrl = datawe[@"dayPictureUrl"];
        NSString *nightPictureUrl = datawe[@"nightPictureUrl"];
        
        self.weatherLab.text = weather;
        self.temperatureLab.text = datawe[@"temperature"];;
        
        NSString *timeStr=[QFTools replyDataAndTime];
        NSString*hourStr=[timeStr substringWithRange:NSMakeRange(11, 2)];
        
        if ([hourStr intValue] <= 17 && [hourStr intValue] >= 5) {
            NSString *weatherName = [dayPictureUrl substringFromIndex:44];
            self.weathericon.image = [UIImage imageNamed:weatherName];
            
        }else{
            
            NSString *weatherName = [nightPictureUrl substringFromIndex:46];
            self.weathericon.image = [UIImage imageNamed:weatherName];
        }
        
        if (pm25.intValue <50) {
            self.environmentLab.text = @"空气：优";
        }else if (pm25.intValue >=50 && pm25.intValue<100){
            self.environmentLab.text = @"空气：良";
        }else if (pm25.intValue >=100 && pm25.intValue<150){
            
            self.environmentLab.text = @"轻度污染";
        }else if (pm25.intValue >=150 && pm25.intValue<200){
            
            self.environmentLab.text = @"中度污染";
        }else if (pm25.intValue >=200 && pm25.intValue<250){
            
            self.environmentLab.text = @"重度污染";
        }else if (pm25.intValue >=250){
            
            self.environmentLab.text = @"橙色预警";
        }
        
    }];
    
}

-(void)startWeatherLocation{
    @weakify(self);
    [APPPermissionDetectionManager openLocationServiceWithBlock:^(BOOL isOpen) {
        @strongify(self);
        if (!isOpen) {
            DW_AlertView *alert = [[DW_AlertView alloc] initBackroundImage:nil Title:@"提示" contentString:@"定位权限未打开，是否去开启定位权限" sureButtionTitle:@"确定" cancelButtionTitle:@"取消"];
            alert.sureBolck = ^(BOOL clickStatu) {
                NSURL * url= [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                if (@available(iOS 10.0, *)) {
                    NSDictionary *options = @{UIApplicationOpenURLOptionsSourceApplicationKey : @YES};
                    [[UIApplication sharedApplication] openURL:url options:options completionHandler:nil];
                } else {
                    // Fallback on earlier versions
                    [[UIApplication sharedApplication] openURL:url];
                }
            };
        }else{
            [self locate];
        }
        
    }];
}


-(void)manager:(Manager *)manager updateUserMessage:(NSString *)name :(UIImage *)img{
    
    self.userImage.image = [UIImage pq_ClipCircleImageWithImage:img circleRect:CGRectMake(0, 0, img.size.width, img.size.height)];
    self.nameLabel.text = name;
    
}

-(void)dealloc{
    
    if (_locationManager != nil) {
        [_locationManager stopUpdatingLocation];
        _locationManager.delegate = nil;
        _locationManager = nil;
    }
    if (self.LocationAlertView) {
        [self.LocationAlertView dismissWithClickedButtonIndex:0 animated:YES];
        self.LocationAlertView = nil;
    }
    [[Manager shareManager] deleteDelegate:self];
}

-(void)stopWeatherLocation{
    [self.locationManager stopUpdatingLocation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
