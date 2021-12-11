//
//  GPSDetectionProcessingView.h
//  RideHousekeeper
//
//  Created by Apple on 2020/3/25.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^LeftBtnClick)(void);
typedef void(^RestSearchBtnClick)(void);
NS_ASSUME_NONNULL_BEGIN

@interface GPSDetectionProcessingView : UIView

@property(nonatomic,strong)UILabel *titleLab;
@property(nonatomic,strong)UIImageView* headView;
@property(nonatomic,strong)UILabel *mobileTitle;
@property(nonatomic,strong)YYLabel *promptTitle;
@property(nonatomic,strong)UIButton *scanAgainBtn;
@property(nonatomic,copy)LeftBtnClick btnClick;
@property(nonatomic,copy)RestSearchBtnClick restClick;
@end

NS_ASSUME_NONNULL_END
