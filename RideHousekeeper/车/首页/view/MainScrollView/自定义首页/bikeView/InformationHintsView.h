//
//  InformationHintsView.h
//  RideHousekeeper
//
//  Created by Apple on 2018/3/27.
//  Copyright © 2018年 Duke Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ClickDelegate <NSObject>

-(void)didClickView;//

@end

@interface InformationHintsView : UIView

@property (nonatomic, strong) UIView     *BLEConnectStatusPointView;
@property (nonatomic, strong) UILabel    *displayLab;
@property (weak, nonatomic) id<ClickDelegate> clickDelegate;
@property (nonatomic, strong) UIView     *caveatView;
@property (nonatomic, strong) UIImageView     *displayImg;

@end
