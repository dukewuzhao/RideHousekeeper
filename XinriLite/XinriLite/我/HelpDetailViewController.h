//
//  HelpDetailViewController.h
//  RideHousekeeper
//
//  Created by Apple on 2017/8/28.
//  Copyright © 2017年 Duke Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HelpDetailViewController : BaseViewController

@property (nonatomic , assign) BOOL needPicture;
@property (nonatomic , assign) NSInteger selectNum;
@property(nonatomic,copy) NSString* helpDetail;
@property(nonatomic,copy) NSString* detailLab;

@end
