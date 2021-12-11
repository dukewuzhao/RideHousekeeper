//
//  QRViewController.h
//  SmartWallitAdv
//
//  Created by AlanWang on 15/8/4.
//  Copyright (c) 2015年 AlanWang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
typedef void(^getScanCodeValue)(NSString* code);
@interface TwoDimensionalCodecanViewController : BaseViewController
@property(nonatomic,copy) NSString *naVtitle;
@property(nonatomic,assign) NSInteger bikeid;
@property(nonatomic,assign) NSInteger type;
@property(nonatomic,assign) NSInteger seq;
@property(nonatomic,copy) getScanCodeValue scanValue;
-(void)setChangeDeviceType:(BindingType)type;
@end
