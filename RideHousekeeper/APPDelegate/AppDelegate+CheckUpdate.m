//
//  AppDelegate+CheckUpdate.m
//  RideHousekeeper
//
//  Created by Apple on 2018/11/16.
//  Copyright © 2018年 Duke Wu. All rights reserved.
//

#import "AppDelegate+CheckUpdate.h"
#import "DGLabel.h"
@implementation AppDelegate (CheckUpdate)

/**
 *  检测软件是否需要升级
 */
- (void)updateApp
{
    if(![self judgeNeedVersionUpdate])  return ;
    //2先获取当前工程项目版本号
    NSDictionary *infoDic=[[NSBundle mainBundle] infoDictionary];
    NSString *currentVersion=infoDic[@"CFBundleShortVersionString"];
    NSString *URLString = [NSString stringWithFormat:@"%@%@",QGJURL,@"app/checkupdate"];
    NSDictionary *parameters = @{@"platform":@"I", @"channel": @"QGJ",@"version": currentVersion};
    
    [[HttpRequest sharedInstance] postWithURLString:URLString parameters:parameters success:^(id _Nullable dict) {
        
        if ([dict[@"status"] intValue] == 0) {
            NSString *currentVersion=infoDic[@"CFBundleShortVersionString"];
            NSDictionary *data = dict[@"data"];
            NSString *appStoreVersion = data[@"latest_version"];
            NSString *description = data[@"description"];
            NSString *nowStoreVersion = data[@"latest_version"];
            //设置版本号
            currentVersion = [currentVersion stringByReplacingOccurrencesOfString:@"." withString:@""];
            if (currentVersion.length==2) {
                currentVersion  = [currentVersion stringByAppendingString:@"0"];
            }else if (currentVersion.length==1){
                currentVersion  = [currentVersion stringByAppendingString:@"00"];
            }
            appStoreVersion = [appStoreVersion stringByReplacingOccurrencesOfString:@"." withString:@""];
            if (appStoreVersion.length==2) {
                appStoreVersion  = [appStoreVersion stringByAppendingString:@"0"];
            }else if (appStoreVersion.length==1){
                appStoreVersion  = [appStoreVersion stringByAppendingString:@"00"];
            }
            //4当前版本号小于商店版本号,就更新
            if([currentVersion floatValue] < [appStoreVersion floatValue]){
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"检测到软件新有版本(%@),是否更新?",nowStoreVersion] message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"更新", nil];
                
                //如果你的系统大于等于7.0
                if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_0){
                    
                    DGLabel *textLabel = [[DGLabel alloc] init];
                    textLabel.font = [UIFont systemFontOfSize:15];
                    textLabel.numberOfLines =0;
                    textLabel.textAlignment =NSTextAlignmentLeft;
                    textLabel.textInsets = UIEdgeInsetsMake(0.f, 20.f, 0.f, 10.f); // 设置左内边距
                    textLabel.text = description;
                    [alert setValue:textLabel forKey:@"accessoryView"];
                    
                }else{
                    NSInteger count = 0;
                    for( UIView * view in alert.subviews )
                    {
                        if( [view isKindOfClass:[UILabel class]] )
                        {
                            count ++;
                            if ( count == 2 ) { //仅对message左对齐
                                UILabel* label = (UILabel*) view;
                                label.textAlignment =NSTextAlignmentLeft;
                            }
                        }
                    }
                }
                
                alert.tag = 3000;
                [alert show];
                
            }else{
                
                NSLog(@"版本号好像比商店大噢!检测到不需要更新");
            }
        }
        
    }failure:^(NSError *error) {
        
        NSLog(@"error :%@",error);
        
    }];
}

//每天进行一次版本判断
- (BOOL)judgeNeedVersionUpdate {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    //获取年-月-日
    NSString *dateString = [formatter stringFromDate:[NSDate date]];
    NSString *currentDate = [USER_DEFAULTS objectForKey:@"currentDate"];
    if ([currentDate isEqualToString:dateString]) {
        return NO;
    }
    [USER_DEFAULTS setObject:dateString forKey:@"currentDate"];
    return YES;
}

@end
