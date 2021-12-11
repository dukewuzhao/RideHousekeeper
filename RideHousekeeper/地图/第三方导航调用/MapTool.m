//
//  MapTool.m
//  xss
//
//  Created by wzh on 2017/8/14.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#import "MapTool.h"

@implementation MapTool


+ (MapTool *)sharedMapTool{


  static MapTool *mapTool = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    mapTool = [[MapTool alloc] init];
  });
  
  return mapTool;
  
}
/**
 调用三方导航
 
 @param coordinate 经纬度
 @param name 地图上显示的名字
 @param tager 当前控制器
 */
- (void)navigationActionWithCoordinate:(CLLocationCoordinate2D)fromcoordinate fromName:(NSString *)fromName tocoordinate:(CLLocationCoordinate2D)coordinate WithENDName:(NSString *)name tager:(UIViewController *)tager{

    @weakify(self);
  UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"导航到设备" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
  
  //判断是否安装了百度地图，如果安装了百度地图，则使用百度地图导航
  if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"baidumap://"]]) {
    [alertController addAction:[UIAlertAction actionWithTitle:@"百度地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        @strongify(self);
      NSLog(@"alertController -- 百度地图");
      [self baiduNaviWithCoordinate:coordinate andWithMapTitle:name];
      
    }]];
  }
    
    //判断是否安装了高德地图，如果安装了高德地图，则使用高德地图导航
    if ( [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"iosamap://"]]) {
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"高德地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            @strongify(self);
            NSLog(@"alertController -- 高德地图");
            [self aNaviWithCoordinate:coordinate andWithMapTitle:name];
            
        }]];
    }
    
    //判断是否安装了腾讯地图，如果安装了腾讯地图，则使用腾讯地图导航
    if ( [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"qqmap://"]]) {
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"腾讯地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            @strongify(self);
            NSLog(@"alertController -- 腾讯地图");
            [self qqNaviWithCoordinate:fromcoordinate fromName:fromName tocoordinate:coordinate andWithMapTitle:name];
            
        }]];
    }
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"苹果自带地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        @strongify(self);
        [self appleNaiWithCoordinate:coordinate andWithMapTitle:name];
        
    }]];
    
  //添加取消选项
  [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
  }]];
  
  //显示alertController
  [tager presentViewController:alertController animated:YES completion:nil];
}

//唤醒苹果自带导航
- (void)appleNaiWithCoordinate:(CLLocationCoordinate2D)coordinate andWithMapTitle:(NSString *)map_title{
  
    MKMapItem *currentLocation = [MKMapItem mapItemForCurrentLocation];
    MKMapItem *tolocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:coordinate addressDictionary:nil]];
    tolocation.name = map_title;
    [MKMapItem openMapsWithItems:@[currentLocation,tolocation] launchOptions:@{MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving,
                                                                               MKLaunchOptionsShowsTrafficKey:[NSNumber numberWithBool:YES]}];
}


/**
 高德导航
 */
- (void)aNaviWithCoordinate:(CLLocationCoordinate2D)coordinate andWithMapTitle:(NSString *)map_title{
  
    NSString *urlsting =[[NSString stringWithFormat:@"iosamap://navi?sourceApplication=骑管家 &backScheme= &lat=%f&lon=%f&dev=0&style=2",coordinate.latitude,coordinate.longitude]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    if ([[UIDevice currentDevice].systemVersion integerValue] >= 10){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlsting] options:@{} completionHandler:^(BOOL success)
         { NSLog(@"scheme调用结束");
        }];
        
    }else{
        [[UIApplication  sharedApplication]openURL:[NSURL URLWithString:urlsting]];
    }
}

- (void)baiduNaviWithCoordinate:(CLLocationCoordinate2D)coordinate andWithMapTitle:(NSString *)map_title{
  
    NSString *urlsting =[[NSString stringWithFormat:@"baidumap://map/direction?origin={{我的位置}}&destination=latlng:%f,%f|name=目的地&mode=riding&src=ios.kuyi.ridehouse&coord_type=gcj02",coordinate.latitude,coordinate.longitude] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if ([[UIDevice currentDevice].systemVersion integerValue] >= 10){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlsting] options:@{} completionHandler:^(BOOL success)
         { NSLog(@"scheme调用结束");
         }];
        
    }else{
        [[UIApplication  sharedApplication]openURL:[NSURL URLWithString:urlsting]];
    }
}

- (void)qqNaviWithCoordinate:(CLLocationCoordinate2D)fromcoordinate fromName:(NSString *)fromname tocoordinate:(CLLocationCoordinate2D)coordinate andWithMapTitle:(NSString *)map_title{
    
    
    NSString *urlsting =[[NSString stringWithFormat:@"qqmap://map/routeplan?type=bike&from=%@&fromcoord=%f,%f&to=%@&tocoord=%f,%f&referer=PTDBZ-GAEC4-ZLFUR-X7IUG-6ZXSH-URBNN",fromname,fromcoordinate.latitude,fromcoordinate.longitude,map_title,coordinate.latitude,coordinate.longitude] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if ([[UIDevice currentDevice].systemVersion integerValue] >= 10){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlsting] options:@{} completionHandler:^(BOOL success)
         { NSLog(@"scheme调用结束");
         }];
        
    }else{
        [[UIApplication  sharedApplication]openURL:[NSURL URLWithString:urlsting]];
    }
}

@end
