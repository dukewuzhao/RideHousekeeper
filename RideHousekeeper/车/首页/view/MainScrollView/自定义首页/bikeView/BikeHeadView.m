//
//  BikeHeadView.m
//  RideHousekeeper
//
//  Created by Apple on 2018/3/1.
//  Copyright © 2018年 Duke Wu. All rights reserved.
//

#import "BikeHeadView.h"
#import "VehiclePositionViewController.h"
#import "GPSActivationViewController.h"
@interface BikeHeadView()
@property (nonatomic, strong) UIImageView * imageView;
@end

@implementation BikeHeadView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.imageView = [[UIImageView alloc]initWithFrame:self.bounds];
        [self addSubview:self.imageView];
        [self setupUI];
    }
    return self;
}

-(void)setupUI{
    
    _bikeLogo = [[UIImageView alloc] initWithFrame:CGRectMake(20, 5, ScreenWidth *.3, ScreenWidth *.3 *.42)];
    [self addSubview:_bikeLogo];
    
    [self addSubview:self.carCondition];
    [self.carCondition mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right);
        make.top.equalTo(self.bikeLogo.mas_centerY);
        make.width.mas_equalTo(70);
        make.height.mas_equalTo(self.carCondition.mas_width).multipliedBy(.43);
    }];
    
    [self addSubview:self.bikeBrandImg];
    
//    [self setNeedsLayout];
//    [self layoutIfNeeded];
//    int intervalHeight = (self.vehicleStateView.y - self.bikeBrandImg.y - self.bikeBrandImg.height)/2;
//    NSLog(@"%@---%@----%d",self.vehicleStateView,self.bikeBrandImg,self.bikeBrandImg.height);
    [self addSubview:self.vehicleReportView];
}

//-(VehiclePositioningMapView *)vehiclePositioningMapView{
//
//    if (!_vehiclePositioningMapView) {
//        _vehiclePositioningMapView = [[VehiclePositioningMapView alloc] init];
//    }
//
//    return _vehiclePositioningMapView;
//}

-(VehicleReportView *)vehicleReportView{
    
    if (!_vehicleReportView) {
        
        _vehicleReportView = [[VehicleReportView alloc] init];
    }
    return _vehicleReportView;
}

-(UIImageView *)bikeBrandImg{
    
    if (!_bikeBrandImg) {
        _bikeBrandImg = [UIImageView new];
    }
    return _bikeBrandImg;
}

-(InformationHintsView *)carCondition{
    
    if (!_carCondition) {
        _carCondition = [InformationHintsView new];
        _carCondition.layer.contents = (id)[UIImage imageNamed:@"suspension_bg"].CGImage;
        _carCondition.displayLab.text = @"车况";
    }
    return _carCondition;
}



-(VehicleStateView *)vehicleStateView{
    
    if (!_vehicleStateView) {
        _vehicleStateView = [VehicleStateView new];
    }
    return _vehicleStateView;
}

- (void)setBikeid:(NSInteger)bikeid{
    _bikeid = bikeid;
    self.vehicleReportView.bikeid = bikeid;
}

- (void)setViewType:(NSInteger)viewType{
    _viewType = viewType;
    
    if (viewType == 1) {
        self.carCondition.hidden = NO;
        self.carCondition.BLEConnectStatusPointView.hidden = YES;
        self.imageView.image = [self buildImage:0 :0.8 :self.imageView.bounds.size];
        [self.bikeBrandImg mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.mas_centerX);
            make.top.equalTo(self.carCondition.mas_bottom).offset(12);
            make.width.mas_equalTo(ScreenWidth * .7);
            make.height.mas_equalTo(self.bikeBrandImg.mas_width).multipliedBy(.648);
        }];
        
        
        [self addSubview:self.vehicleStateView];
        [self.vehicleStateView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self);
            make.right.equalTo(self);
            make.width.mas_equalTo(ScreenWidth);
            make.bottom.equalTo(self.mas_bottom);
            make.height.mas_equalTo((int)self.height*.217);
        }];
        
        [self setNeedsLayout];
        [self layoutIfNeeded];
        [self.vehicleReportView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.top.equalTo(self.bikeBrandImg.mas_bottom).offset((self.vehicleStateView.y - CGRectGetMaxY(self.bikeBrandImg.frame)) * .3);
            make.height.mas_equalTo(40);
        }];
        
        [self.vehiclePositioningMapView removeFromSuperview];
        self.vehiclePositioningMapView = nil;
        
    }else if (viewType == 2){
        self.carCondition.hidden = NO;
        self.carCondition.BLEConnectStatusPointView.hidden = NO;
        self.imageView.image = [self buildImage:0 :0.5 :self.imageView.bounds.size];
        [self.bikeBrandImg mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.mas_centerX);
            make.top.equalTo(self.carCondition.mas_bottom).offset(12);
            make.width.mas_equalTo(ScreenWidth * .5);
            make.height.mas_equalTo(self.bikeBrandImg.mas_width).multipliedBy(.648);
        }];
        
        [self setNeedsLayout];
        [self layoutIfNeeded];
        
        [_vehiclePositioningMapView removeFromSuperview];
        int mapy = CGRectGetMaxY(self.bikeBrandImg.frame)+ (self.height - self.height *.262 - self.height *.193 - CGRectGetMaxY(self.bikeBrandImg.frame))*.6;
        _vehiclePositioningMapView = [[VehiclePositioningMapView alloc] initWithFrame:CGRectMake(15,mapy, ScreenWidth - 30, (int)self.height*.262)];
        _vehiclePositioningMapView.bikeid = _bikeid;
        [self addSubview:_vehiclePositioningMapView];
        
        @weakify(self);
        _vehiclePositioningMapView.bikeMapClickBlock = ^{
            @strongify(self);
            VehiclePositionViewController *positionVc = [[VehiclePositionViewController alloc] init];
            positionVc.bikeid = self.bikeid;
            [[QFTools viewController:self].navigationController pushViewController:positionVc animated:YES];
        };
        
        _vehiclePositioningMapView.bikeActivatedViewClickBlock = ^{
            @strongify(self);
            GPSActivationViewController *activationVc = [[GPSActivationViewController alloc] init];
            [activationVc setpGPSParameters: [LVFmdbTool queryBikeData:[NSString stringWithFormat:@"SELECT * FROM bike_modals WHERE bikeid = '%zd'", self.bikeid]].firstObject];
            activationVc.isOnlyGPSActivation = YES;
            [[QFTools viewController:self].navigationController pushViewController:activationVc animated:YES];
        };
        
        int height = _vehiclePositioningMapView.y - CGRectGetMaxY(self.bikeBrandImg.frame);
        
        [self.vehicleReportView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self);
            height>30? make.centerY.equalTo(self.bikeBrandImg.mas_bottom).offset(height/2) :make.bottom.equalTo(_vehiclePositioningMapView.mas_top);
            make.right.equalTo(self);
            make.height.mas_equalTo(30);
        }];
        
        [self addSubview:self.vehicleStateView];
        [self.vehicleStateView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self);
            //make.top.equalTo(self.vehiclePositioningMapView.mas_bottom).offset(10);
            make.right.equalTo(self);
            make.height.mas_equalTo(self.height * .2);
            make.bottom.equalTo(self);
        }];
        
        self.vehiclePositioningMapView.viewType = viewType;
        //[self.vehicleReportView getbikestatus:_bikeid];
    }else if (viewType == 3) {
        self.carCondition.hidden = YES;
        self.imageView.image = [self buildImage:0 :0.7 :self.imageView.bounds.size];
        [self.bikeBrandImg mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.mas_centerX);
            make.top.equalTo(self.carCondition.mas_bottom).offset(12);
            make.width.mas_equalTo(ScreenWidth * .5);
            make.height.mas_equalTo(self.bikeBrandImg.mas_width).multipliedBy(.648);
        }];
        
        [self setNeedsLayout];
        [self layoutIfNeeded];
        
        int mapy = self.height - self.height*.038 - self.height*.325;
        [_vehiclePositioningMapView removeFromSuperview];
        _vehiclePositioningMapView = [[VehiclePositioningMapView alloc] initWithFrame:CGRectMake(15, mapy, ScreenWidth - 30, (int)self.height*.325)];
        
        _vehiclePositioningMapView.bikeid = _bikeid;
        [self addSubview:_vehiclePositioningMapView];
        @weakify(self);
        _vehiclePositioningMapView.bikeMapClickBlock = ^{
            @strongify(self);
            VehiclePositionViewController *positionVc = [[VehiclePositionViewController alloc] init];
            positionVc.bikeid = self.bikeid;
            [[QFTools viewController:self].navigationController pushViewController:positionVc animated:YES];
        };
        
        _vehiclePositioningMapView.bikeActivatedViewClickBlock = ^{
            @strongify(self);
            GPSActivationViewController *activationVc = [[GPSActivationViewController alloc] init];
            [activationVc setpGPSParameters: [LVFmdbTool queryBikeData:[NSString stringWithFormat:@"SELECT * FROM bike_modals WHERE bikeid = '%zd'", self.bikeid]].firstObject];
            activationVc.isOnlyGPSActivation = YES;
            [[QFTools viewController:self].navigationController pushViewController:activationVc animated:YES];
        };
        
        
        [self.vehicleReportView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.centerY.equalTo(self.bikeBrandImg.mas_bottom).offset((_vehiclePositioningMapView.y - CGRectGetMaxY(self.bikeBrandImg.frame))*.5);
            make.height.mas_equalTo(40);
        }];
        
        [self.vehicleStateView removeFromSuperview];
        self.vehicleStateView = nil;
        self.vehiclePositioningMapView.viewType = viewType;
        //[self.vehicleReportView getbikestatus:_bikeid];
    }
    self.vehicleReportView.viewType = viewType;
    
}

- (UIImage *)buildImage:(CGFloat)startLocations :(CGFloat)endLocations :(CGSize)targetSize{
    UIGraphicsBeginImageContextWithOptions(targetSize, YES, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    //使用rgb颜色空间
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

    /*指定渐变色
     space:颜色空间
     components:颜色数组,注意由于指定了RGB颜色空间，那么四个数组元素表示一个颜色（red、green、blue、alpha），
     如果有三个颜色则这个数组有4*3个元素
     locations:颜色所在位置（范围0~1），这个数组的个数不小于components中存放颜色的个数
     count:渐变个数，等于locations的个数
     */

    CGFloat components[8]={
        6/255.0, 193/255.0,   174/255.0,  1,
        255/255.0  , 255/255.0, 255/255.0,  1
    };
    CGFloat locations[2]={startLocations,endLocations};
    CGGradientRef gradient= CGGradientCreateWithColorComponents(colorSpace, components, locations, 2);

    /*绘制线性渐变
     context:图形上下文
     gradient:渐变色
     startPoint:起始位置
     endPoint:终止位置
     options:绘制方式,kCGGradientDrawsBeforeStartLocation 开始位置之前就进行绘制，到结束位置之后不再绘制，
     kCGGradientDrawsAfterEndLocation开始位置之前不进行绘制，到结束点之后继续填充
     */
    CGContextDrawLinearGradient(context, gradient, CGPointZero, CGPointMake(0, targetSize.height), kCGGradientDrawsAfterEndLocation);

    //释放颜色空间
    CGColorSpaceRelease(colorSpace);
    CGGradientRelease(gradient);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

-(void)layoutSubviews{
    
}

//-(void)setFrame:(CGRect)frame{
//
//
//}

@end
