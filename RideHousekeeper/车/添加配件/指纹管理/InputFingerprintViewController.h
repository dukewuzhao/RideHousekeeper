//
//  InputFingerprintViewController.h
//  RideHousekeeper
//
//  Created by Apple on 2017/11/21.
//  Copyright © 2017年 Duke Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol inputFingerprinDelegate <NSObject>

@optional

-(void) inputFingerprintOver;

@end

@interface InputFingerprintViewController : BaseViewController
@property(nonatomic,assign) NSInteger deviceNum;
@property (nonatomic,weak) id<inputFingerprinDelegate> delegate;

@end
