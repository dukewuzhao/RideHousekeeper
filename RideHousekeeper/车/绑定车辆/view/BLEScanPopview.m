//
//  BLEScanPopview.m
//  RideHousekeeper
//
//  Created by Apple on 2018/4/24.
//  Copyright © 2018年 Duke Wu. All rights reserved.
//

#import "BLEScanPopview.h"
#import "SelectECUTableViewCell.h"
#import "SelectBikeCell.h"

@interface BLEScanPopview(){
    UIView *mainView;
    UIView *contentView;
}
@property(nonatomic,assign) BindingType bindingType;
@property (nonatomic, strong) WMZBannerParam *param;
@end
@implementation BLEScanPopview

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(instancetype)initWithType:(BindingType)type{
    if (self = [super init]) {
        _bindingType = type;
        self.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
            
        mainView = [[UIView alloc]initWithFrame:self.frame];
        
        //alpha 0.0  白色   alpha 1 ：黑色   alpha 0～1 ：遮罩颜色，逐渐
        mainView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.25];
    //    mainView.userInteractionEnabled = YES;
    //    [mainView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(disMissView)]];
        
        if (contentView == nil){
            contentView = [[UIView alloc]initWithFrame:CGRectMake(ScreenWidth * .1, ScreenHeight *.22, ScreenWidth *.8, ScreenHeight * .56)];
            contentView.backgroundColor = [UIColor whiteColor];
            contentView.layer.mask = [self UiviewRoundedRect:contentView.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(10, 10)];
            [mainView addSubview:contentView];
            
            UILabel *findLab = [[UILabel alloc] initWithFrame:CGRectMake(0, contentView.height * .1, contentView.width, 20)];
            findLab.text = (type == BindingBike)? @"发现附近车辆":@"发现附近中控";
            findLab.textAlignment = NSTextAlignmentCenter;
            findLab.textColor = [QFTools colorWithHexString:@"#666666"];
            findLab.font = FONT_PINGFAN(18);
            [contentView addSubview:findLab];
            
    //        self.scandTabView.frame = CGRectMake(0, CGRectGetMaxY(findLab.frame)+contentView.height * .1, contentView.width, contentView.height * .4);
    //        [self.scandTabView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    //        [contentView addSubview:self.scandTabView];
            
            [self demoOne];
            _bindingBtn = [[UIButton alloc] initWithFrame:CGRectMake(contentView.width/2 - 90, contentView.height - contentView.height *.1 - 40 , 180, 40)];
            [_bindingBtn setTitle:(type == BindingBike)? @"绑定车辆":@"立即更换" forState:UIControlStateNormal];
            _bindingBtn.titleLabel.font = FONT_PINGFAN(15);
            _bindingBtn.backgroundColor = [QFTools colorWithHexString:MainColor];
            _bindingBtn.layer.mask = [self UiviewRoundedRect:_bindingBtn.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(10, 10)];
            [_bindingBtn addTarget:self action:@selector(bindingBike) forControlEvents:UIControlEventTouchUpInside];
            [contentView addSubview:_bindingBtn];
            
            if (type == BindingBike) {
                UILabel *titlelab = [[UILabel alloc] init];
                titlelab.text = @"智能电动车";
                titlelab.font = FONT_PINGFAN(14);
                titlelab.textColor = [QFTools colorWithHexString:@"#666666"];
                [contentView addSubview:titlelab];
                [titlelab mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.equalTo(contentView);
                    make.bottom.equalTo(_bindingBtn.mas_top).offset(-(NSInteger)contentView.height *.1);
                    make.height.mas_equalTo(17);
                }];
            }
        }
    }
    return self;
}
//所有属性
- (void)demoOne{
    @weakify(self);
    _param =
    BannerParam()
    //自定义视图必传
    .wMyCellClassNameSet((_bindingType == BindingBike)? @"SelectBikeCell": @"SelectECUTableViewCell")
    .wMyCellSet(^UICollectionViewCell *(NSIndexPath *indexPath, UICollectionView *collectionView, id model, UIImageView *bgImageView,NSArray*dataArr) {
        @strongify(self);
        //自定义视图
        if (self.bindingType == BindingBike) {
            SelectBikeCell *cell = (SelectBikeCell *)[collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([SelectBikeCell class]) forIndexPath:indexPath];
            //[cell.icon sd_setImageWithURL:[NSURL URLWithString:model[@"icon"]] placeholderImage:nil];
            cell.icon.image = [UIImage imageNamed:@"two_wheeler_icon"];
            return cell;
        }else{
            
            SelectECUTableViewCell *cell = (SelectECUTableViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([SelectECUTableViewCell class]) forIndexPath:indexPath];
            //[cell.icon sd_setImageWithURL:[NSURL URLWithString:model[@"icon"]] placeholderImage:nil];
            cell.icon.image = [UIImage imageNamed:@"icon_ecu"];
            cell.titleLab.text = [NSString stringWithFormat:@"智能中控%d",indexPath.row + 1];
            return cell;
        }
        
        //cell.leftText.text = model[@"name"];
        //cell.leftText.text = [NSString stringWithFormat:@"智能电动车%d",indexPath.row + 1];
        //毛玻璃效果必须实现 看实际情况 取最后一个还是中间那个
//        [bgImageView sd_setImageWithURL:[NSURL URLWithString:model[@"icon"]] placeholderImage:nil];
        //[bgImageView sd_setImageWithURL:[NSURL URLWithString:dataArr[(indexPath.row == 0?:(indexPath.row-1))][@"icon"]] placeholderImage:nil];
        
        
    })
    .wEventClickSet(^(id anyID, NSInteger index) {
        //NSLog(@"点击 %@ %ld",anyID,index);
    })
    .wFrameSet(CGRectMake(0, contentView.height * .25, contentView.width, contentView.height*.75))
    .wImageFillSet(YES)
    .wLineSpacingSet(10)
    .wScaleSet(YES)
    .wEffectSet(YES)
    .wActiveDistanceSet(400)
    .wScaleFactorSet(0.5)
    .wItemSizeSet(CGSizeMake(contentView.width*0.5, contentView.height - 20))
    .wContentOffsetXSet(0.5)
    .wSelectIndexSet(0)
    .wRepeatSet(NO)
    .wAutoScrollSecondSet(3)
    .wAutoScrollSet(NO)
    .wPositionSet(BannerCellPositionCenter)
    .wBannerControlSelectColorSet([QFTools colorWithHexString:@"#a7a9b0"])
    .wBannerControlColorSet([QFTools colorWithHexString:MainColor])
//    .wBannerControlImageSet(@"slideCirclePoint")
//    .wBannerControlSelectImageSet(@"slidePoint")
    .wBannerControlImageSizeSet(CGSizeMake(5, 5))
    .wBannerControlSelectImageSizeSet(CGSizeMake(5, 5))
    .wBannerControlImageRadiusSet(5)
    .wHideBannerControlSet(NO)
    .wCanFingerSlidingSet(YES)
    //整体缩小
//    .wScreenScaleSet(0.8)
    //左右半透明 中间不透明
    .wAlphaSet(0.5)
    //开启跑马灯效果
    .wMarqueeSet(NO)
    //开启纵向
    .wVerticalSet(NO)
    .wBannerControlPositionSet(BannerControlCenter)
    //左右偏移 让第一个和最后一个可以居中
    .wSectionInsetSet(UIEdgeInsetsMake(0,contentView.width*0.25, 0, contentView.width*0.25));
    self.bikeListView = [[WMZBannerView alloc]initConfigureWithModel:_param withView:contentView];
}

-(void)setParams:(NSArray *)ary{
    _param.wDataSet(ary);
    [self.bikeListView updateUI];
}

-(void)bindingBike{
    if (self.bindingBikeClickBlock) {
        self.bindingBikeClickBlock(self.bikeListView.bannerControl.currentPage);
    }
}


- (void)disMissView
{
    [UIView animateWithDuration:0.3f
                     animations:^{
                         
                         mainView.alpha = 0.0;
                     }
                     completion:^(BOOL finished){
                         
                         [mainView removeFromSuperview];
                     }];
    
}

-(void)showInView:(UIView *)view{
    
    if (!view){
        return;
    }
    //UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [view addSubview:mainView];
    
    [UIView animateWithDuration:0.3 animations:^{
        
        self.alpha = 1.0;
                
    } completion:nil];
}

@end
