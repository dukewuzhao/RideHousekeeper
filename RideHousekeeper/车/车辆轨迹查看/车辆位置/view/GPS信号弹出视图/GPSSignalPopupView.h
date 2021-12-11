//
//  GPSSignalPopupView.h
//  RideHousekeeper
//
//  Created by Apple on 2019/12/11.
//  Copyright © 2019 Duke Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define CellLineEdgeInsets UIEdgeInsetsMake(0, 10, 0, 10)
#define LeftToView 10.f
#define TopToView 10.f

typedef void(^dismissWithOperation)();

typedef NS_ENUM(NSUInteger, GPSSignalPopupDirection) {
    GPSSignalPopupDirectionLeft = 1,
    GPSSignalPopupDirectionRight
};

@interface GPSSignalPopupView : UIView

@property (nonatomic, strong) dismissWithOperation dismissOperation;

//初始化方法
//传入参数：模型数组，弹出原点，宽度，高度（每个cell的高度）
- (instancetype)initWithModel:(BikeStatusInfoModel *)model
                           origin:(CGPoint)origin
                            width:(CGFloat)width
                           height:(CGFloat)height
                        direction:(GPSSignalPopupDirection)direction;

//弹出
- (void)pop;
//消失
- (void)dismiss;

@end

NS_ASSUME_NONNULL_END
