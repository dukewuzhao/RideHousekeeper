//
//  ManualInputViewController.h
//  RideHousekeeper
//
//  Created by Apple on 2017/11/13.
//  Copyright © 2017年 Duke Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^getTextFeildInput)(NSString* code);
@interface ManualInputViewController : BaseViewController
@property(nonatomic,copy) NSString *naVtitle;
@property(nonatomic,assign) NSInteger bikeid;
@property(nonatomic,assign) NSInteger type;
@property(nonatomic,assign) NSInteger seq;
@property(nonatomic,copy) getTextFeildInput input;
-(void)setChangeDeviceType:(BindingType)type;
@end
