//
//  ExtendGPSServerViewController.m
//  RideHousekeeper
//
//  Created by Apple on 2020/3/2.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import "ExtendGPSServerViewController.h"
#import "ServiceMallViewController.h"
#import "ServiceSelectionCardView.h"
#import "TwoDimensionalCodecanViewController.h"

@interface ExtendGPSServerViewController ()

@end

@implementation ExtendGPSServerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupNavView];
    [self setupView];

}


- (void)setupNavView{
    [super setupNavView];
    self.navView.backgroundColor = [QFTools colorWithHexString:MainColor];
    self.navView.showBottomLabel = NO;
    [self.navView.centerButton setTitle:@"延长服务期"forState:UIControlStateNormal];
    @weakify(self);
    [self.navView.leftButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    self.navView.leftButtonBlock = ^{
        @strongify(self);
        
        [self.navigationController popViewControllerAnimated:YES];
    };
}

-(void)setupView{
    ServiceSelectionCardView *firstView = [[ServiceSelectionCardView alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(self.navView.frame)+30, ScreenWidth - 40, 135)];
    firstView.titleLab.text = @"服务商城";
    firstView.subtitleLab.text = @"适合在线购买服务包方式";
    firstView.icon.image = [UIImage imageNamed:@"mall_services_icon"];
    firstView.enterLab.backgroundColor = [QFTools colorWithHexString:@"#017D70"];
    [self.view addSubview:firstView];
    CGFloat components[8]={
        159/255.0,227/255.0,174/220.0,1,
        6/255.0,193/255.0,174/255.0,1
    };
    firstView.layer.masksToBounds = YES;
    firstView.layer.contents = (id) [self buildImage:0 :1.0 :firstView.bounds.size :components].CGImage;
    firstView.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.16].CGColor;
    firstView.layer.shadowOffset = CGSizeMake(0,3);
    firstView.layer.shadowRadius = 6;
    firstView.layer.cornerRadius = 10;
    @weakify(self);
    firstView.action = ^{
        @strongify(self);
        ServiceMallViewController *MallVc = [[ServiceMallViewController alloc] init];
        MallVc.bikeId = self.bikeId;
        [self.navigationController pushViewController:MallVc animated:YES];
    };
    
    ServiceSelectionCardView *secondView = [[ServiceSelectionCardView alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(firstView.frame)+30, ScreenWidth - 40, 135)];
    //secondView.layer.cornerRadius = 10;
    secondView.titleLab.text = @"兑换卡";
    secondView.subtitleLab.text = @"适合购买实体兑换卡方式";
    secondView.icon.image = [UIImage imageNamed:@"redemption_card_icon"];
    secondView.enterLab.backgroundColor = [QFTools colorWithHexString:@"#2969D2"];
    [self.view addSubview:secondView];
    CGFloat components2[8]={
        33/255.0,184/255.0,252/220.0,1,
        42/255.0,120/255.0,214/255.0,1
    };
    secondView.layer.masksToBounds = YES;
    secondView.layer.contents = (id) [self buildImage:0 :1.0 :secondView.bounds.size :components2].CGImage;
    secondView.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.16].CGColor;
    secondView.layer.shadowOffset = CGSizeMake(0,3);
    secondView.layer.shadowRadius = 6;
    secondView.layer.cornerRadius = 10;
    secondView.action = ^{
        @strongify(self);
        TwoDimensionalCodecanViewController *scanVc = [[TwoDimensionalCodecanViewController alloc] init];
        scanVc.naVtitle = @"兑换卡";
        scanVc.bikeid = self.bikeId;
        [self.navigationController pushViewController:scanVc animated:YES];
    };
    
    ServiceSelectionCardView *thirdView = [[ServiceSelectionCardView alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(secondView.frame)+30, ScreenWidth - 40, 135)];
    //thirdView.layer.cornerRadius = 10;
    thirdView.titleLab.text = @"转移服务";
    thirdView.subtitleLab.text = @"适合已购有服务包转移服务";
    thirdView.icon.image = [UIImage imageNamed:@"transfer_service_icon"];
    thirdView.enterLab.backgroundColor = [QFTools colorWithHexString:@"#2969D2"];
    [self.view addSubview:thirdView];
    [thirdView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(20);
        make.top.equalTo(secondView.mas_bottom).offset(30);
        make.right.equalTo(self.view).offset(-20);
        make.height.mas_equalTo(135);
    }];
    CGFloat components3[8]={
        65/255.0,80/255.0,151/220.0,1,
        53/255.0,48/255.0,101/255.0,1
    };
    thirdView.layer.masksToBounds = YES;
    thirdView.layer.contents = (id) [self buildImage:0 :1.0 :thirdView.bounds.size :components3].CGImage;
    thirdView.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.16].CGColor;
    thirdView.layer.shadowOffset = CGSizeMake(0,3);
    thirdView.layer.shadowRadius = 6;
    thirdView.layer.cornerRadius = 10;
    
    thirdView.action = ^{
        @strongify(self);
        TwoDimensionalCodecanViewController *scanVc = [[TwoDimensionalCodecanViewController alloc] init];
        scanVc.naVtitle = @"转移服务";
        scanVc.bikeid = self.bikeId;
        scanVc.type = 10;
        [self.navigationController pushViewController:scanVc animated:YES];
    };
}

//_gradientImgView.image = [self buildImage:0 :1.0 :_gradientImgView.bounds.size];

- (UIImage *)buildImage:(CGFloat)startLocations :(CGFloat)endLocations :(CGSize)targetSize :(CGFloat *)components{
    UIGraphicsBeginImageContextWithOptions(targetSize, YES, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//    CGFloat components[8]={
//        6/255.0,193/255.0,174/255.0,1,
//        224/255.0,224/255.0,224/255.0,1
//    };
    CGFloat locations[2]={startLocations,endLocations};
    CGGradientRef gradient= CGGradientCreateWithColorComponents(colorSpace, components, locations, 2);
    CGContextDrawLinearGradient(context, gradient, CGPointZero, CGPointMake(0, targetSize.height), kCGGradientDrawsAfterEndLocation);
    CGColorSpaceRelease(colorSpace);
    CGGradientRelease(gradient);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}



@end
