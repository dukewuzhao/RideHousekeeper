//
//  DW_AlertView.h
//  RideHousekeeper
//
//  Created by Apple on 2019/12/5.
//  Copyright © 2019 Duke Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^sureBtnClick)(BOOL clickStatu);
typedef void(^cancleBtnClick)(BOOL clickStatu);
@interface DW_AlertView : UIView

-(instancetype)initBackroundImage:(NSString *)imageB Title:(NSString *)tltleString contentString:(NSString *)contentString sureButtionTitle:(NSString *)sureBtnstring cancelButtionTitle:(NSString *)cancelBtnString ;

-(instancetype)initTopTitle:(NSString *)tltleString contentImgString:(NSString *)imageStr sureButtionTitle:(NSString *)sureBtnstring;

-(instancetype)initHeadLottiAnimation:(NSString *)name Title:(NSString *)tltleString contentString:(NSString *)contentString cancelButtionTitle:(NSString *)cancelBtnString;

@property (nonatomic,copy)sureBtnClick sureBolck;
@property (nonatomic,copy)cancleBtnClick cancleBolck;

-(void)clickSureBtn:(sureBtnClick) block;
-(void)clickCancleBtn:(cancleBtnClick) block;

@end

NS_ASSUME_NONNULL_END
