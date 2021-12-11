//
//  LoadView.h
//  RideHousekeeper
//
//  Created by Apple on 2017/2/18.
//  Copyright © 2017年 Duke Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoadView : UIView

@property(nonatomic, retain)UILabel *protetitle;

+ (instancetype)sharedInstance;

-(void)show;

-(void)hide;

@end
