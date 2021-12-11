//
//  BindingGuidePopView.m
//  RideHousekeeper
//
//  Created by Apple on 2020/4/10.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import "BindingGuidePopView.h"
#import "SelectBikeCell.h"

@interface BindingGuidePopView(){
    UIView *mainView;
    UIView *contentView;
}
@property (nonatomic, strong) WMZBannerParam *param;
@end

@implementation BindingGuidePopView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        [self setupUI];
    }
    return self;
}

-(void)setupUI{
    
    self.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
    
    mainView = [[UIView alloc]initWithFrame:self.frame];
    
    //alpha 0.0  白色   alpha 1 ：黑色   alpha 0～1 ：遮罩颜色，逐渐
    mainView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.25];
//    mainView.userInteractionEnabled = YES;
//    [mainView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(disMissView)]];
    
    if (contentView == nil){
        contentView = [[UIView alloc]initWithFrame:CGRectMake(ScreenWidth * .1, ScreenHeight *.22, ScreenWidth *.8, ScreenHeight * .6)];
        contentView.backgroundColor = [UIColor whiteColor];
        contentView.layer.mask = [self UiviewRoundedRect:contentView.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(10, 10)];
        [mainView addSubview:contentView];
        
        UILabel *findLab = [[UILabel alloc] init];
        findLab.numberOfLines = 0;
        findLab.text = @"发现已绑有智能中控车辆，是否 绑定定位器为车辆配件？";
        findLab.textAlignment = NSTextAlignmentCenter;
        findLab.textColor = [UIColor blackColor];
        findLab.font = FONT_PINGFAN(16);
        [contentView addSubview:findLab];
        [findLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(contentView).offset(contentView.height * .1);
            make.left.equalTo(contentView).offset(20);
            make.right.equalTo(contentView).offset(-20);
        }];
//        self.scandTabView.frame = CGRectMake(0, CGRectGetMaxY(findLab.frame)+contentView.height * .1, contentView.width, contentView.height * .4);
//        [self.scandTabView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
//        [contentView addSubview:self.scandTabView];
        
        [self demoOne];
        UIButton* bindingNewBikeBtn = [[UIButton alloc] init];
        [bindingNewBikeBtn setTitle:@"绑为新车辆" forState:UIControlStateNormal];
        bindingNewBikeBtn.titleLabel.font = FONT_PINGFAN(14);
        [bindingNewBikeBtn setTitleColor:[QFTools colorWithHexString:@"#666666"] forState:UIControlStateNormal];
        bindingNewBikeBtn.backgroundColor = [UIColor whiteColor];
        bindingNewBikeBtn.layer.cornerRadius = 24;
        bindingNewBikeBtn.layer.borderWidth = 1;
        bindingNewBikeBtn.layer.borderColor = [QFTools colorWithHexString:@"#cccccc"].CGColor;
        @weakify(self);
        [[bindingNewBikeBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            if (self.bindingBikeClickBlock) {
                self.bindingBikeClickBlock(-1);
            }
            [self disMissView];
        }];
        [contentView addSubview:bindingNewBikeBtn];
        [bindingNewBikeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(contentView);
            make.bottom.equalTo(contentView).offset(-35);
            make.size.mas_equalTo(CGSizeMake(180, 48));
        }];
        
        UIButton* bindAccessoriesBtn = [[UIButton alloc] init];
        [bindAccessoriesBtn setTitle:@"绑为配件" forState:UIControlStateNormal];
        bindAccessoriesBtn.titleLabel.font = FONT_PINGFAN(14);
        [bindAccessoriesBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        bindAccessoriesBtn.backgroundColor = [QFTools colorWithHexString:@"#06C1AE"];
        bindAccessoriesBtn.layer.cornerRadius = 24;
        [[bindAccessoriesBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            if (self.bindingBikeClickBlock) {
                self.bindingBikeClickBlock(self.bikeListView.bannerControl.currentPage);
            }
            [self disMissView];
        }];
        [contentView addSubview:bindAccessoriesBtn];
        [bindAccessoriesBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(bindingNewBikeBtn);
            make.bottom.equalTo(bindingNewBikeBtn.mas_top).offset(-15);
            make.size.mas_equalTo(CGSizeMake(180, 48));
        }];
        
        UIButton *clearBtn = [[UIButton alloc] init];
        [clearBtn setImage:[UIImage imageNamed:@"signout_input"] forState:UIControlStateNormal];
        [[clearBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            if (self.bindingBikeClickBlock) {
                self.bindingBikeClickBlock(-2);
            }
            [self disMissView];
        }];
        [mainView addSubview:clearBtn];
        [clearBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(bindingNewBikeBtn);
            make.top.equalTo(contentView.mas_bottom).offset(20);
            make.size.mas_equalTo(CGSizeMake(35, 35));
        }];
    }
}

//所有属性
- (void)demoOne{
    _param =
    BannerParam()
    //自定义视图必传
    .wMyCellClassNameSet(@"SelectBikeCell")
    .wMyCellSet(^UICollectionViewCell *(NSIndexPath *indexPath, UICollectionView *collectionView, id model, UIImageView *bgImageView,NSArray*dataArr) {
        //自定义视图
        SelectBikeCell *cell = (SelectBikeCell *)[collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([SelectBikeCell class]) forIndexPath:indexPath];
        //[cell.icon sd_setImageWithURL:[NSURL URLWithString:model[@"icon"]] placeholderImage:nil];
        cell.icon.image = [UIImage imageNamed:@"two_wheeler_icon"];
        cell.leftText.text = [(BikeModel*)model bikename];
        //cell.leftText.text = [NSString stringWithFormat:@"智能电动车%d",indexPath.row + 1];
        //毛玻璃效果必须实现 看实际情况 取最后一个还是中间那个
//        [bgImageView sd_setImageWithURL:[NSURL URLWithString:model[@"icon"]] placeholderImage:nil];
        //[bgImageView sd_setImageWithURL:[NSURL URLWithString:dataArr[(indexPath.row == 0?:(indexPath.row-1))][@"icon"]] placeholderImage:nil];
        
        return cell;
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

-(void)showInView:(UIView *)view withParams:(NSArray *)ary{
    
    _param.wDataSet(ary);
    [self.bikeListView updateUI];
    [self showInView:view];
}

- (void)disMissView{
    NSLog(@"disMissView");
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
