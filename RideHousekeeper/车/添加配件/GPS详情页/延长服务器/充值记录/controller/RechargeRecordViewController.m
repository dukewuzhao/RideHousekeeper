//
//  RechargeRecordViewController.m
//  RideHousekeeper
//
//  Created by Apple on 2020/3/4.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import "RechargeRecordViewController.h"
#import "HGSegmentedPageViewController.h"
#import "RechargeRecordTableViewCell.h"
#import "AllOrderListViewController.h"
#import "WaitPayOrderViewController.h"
#import "OrderCompleteViewController.h"
#import "OrderCancelViewController.h"

@interface RechargeRecordViewController ()
@property (nonatomic, strong) HGSegmentedPageViewController *segmentedPageViewController;
@end

@implementation RechargeRecordViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupNavView];
    [self addChildViewController:self.segmentedPageViewController];
    [self.view addSubview:self.segmentedPageViewController.view];
    [self.segmentedPageViewController didMoveToParentViewController:self];
    [self.segmentedPageViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.equalTo(self.view);
        make.top.equalTo(self.navView.mas_bottom);
        make.left.right.bottom.equalTo(self.view);
    }];
    
    
}

- (void)setupNavView{
    [super setupNavView];
    self.navView.backgroundColor = [QFTools colorWithHexString:MainColor];
    self.navView.showBottomLabel = NO;
    [self.navView.centerButton setTitle:@"购买记录"forState:UIControlStateNormal];
    @weakify(self);
    [self.navView.leftButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    self.navView.leftButtonBlock = ^{
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    };
}

#pragma mark Getters
- (HGSegmentedPageViewController *)segmentedPageViewController {
    if (!_segmentedPageViewController) {
        NSMutableArray *controllers = [NSMutableArray array];
        NSArray *titles = @[@"全部", @"待付款", @"已完成",@"已取消"];
        for (int i = 0; i < titles.count; i++) {
            UIViewController *controller;
            if (i == 0) {
                controller = [[AllOrderListViewController alloc] init];
            } else if (i == 1) {
                controller = [[WaitPayOrderViewController alloc] init];
            } else if (i == 2){
                controller = [[OrderCompleteViewController alloc] init];
            }else {
                controller = [[OrderCancelViewController alloc] init];
            }
            [controller setValue:@(_bikeId) forKey:@"bikeId"];
            [controllers addObject:controller];
        }
        _segmentedPageViewController = [[HGSegmentedPageViewController alloc] init];
        _segmentedPageViewController.pageViewControllers = controllers.copy;
        _segmentedPageViewController.categoryView.titles = titles;
        _segmentedPageViewController.categoryView.collectionView.backgroundColor = [QFTools colorWithHexString:@"#F5F5F5"];
        _segmentedPageViewController.categoryView.backgroundColor = [QFTools colorWithHexString:@"#F5F5F5"];
        _segmentedPageViewController.categoryView.titleNormalColor = [QFTools colorWithHexString:@"#666666"];
        _segmentedPageViewController.categoryView.titleSelectedColor = [QFTools colorWithHexString:@"#333333"];
        _segmentedPageViewController.categoryView.titleNomalFont = FONT_PINGFAN(13);
        _segmentedPageViewController.categoryView.titleSelectedFont = FONT_PINGFAN(13);
        _segmentedPageViewController.categoryView.underline.backgroundColor = [QFTools colorWithHexString:MainColor];
        _segmentedPageViewController.categoryView.originalIndex = 0;
    }
    return _segmentedPageViewController;
}



@end
