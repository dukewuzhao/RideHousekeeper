//
//  OrderDetailMiddleView.m
//  RideHousekeeper
//
//  Created by Apple on 2020/3/13.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import "OrderDetailMiddleView.h"

@interface OrderDetailMiddleView()
@property(nonatomic,strong) UILabel *orderStatusLab;
@property(nonatomic,strong) UILabel *orderIDLab;
@property(nonatomic,strong) UILabel *orderTime;
@property(nonatomic,strong) UILabel *payChannel;
@property(nonatomic,strong) UILabel *payTime;
@property(nonatomic,strong) UILabel *serviceDeviceLab;
@property(nonatomic,strong) UILabel *serviceDayLab;
@end

@implementation OrderDetailMiddleView

-(void)setOrderInfo:(ServiceOrder *)model{
    _orderIDLab.text = [NSString stringWithFormat:@"订单编号：%d",model.ID];
    _orderTime.text = [NSString stringWithFormat:@"下单时间：%@",[QFTools stringFromInt:nil :model.created_time]];
    _payChannel.text = model.pay_channel == 3 ?@"支付方式：微信":@"支付方式：支付宝";
    _payTime.text = [NSString stringWithFormat:@"付款时间：%@",[QFTools stringFromInt:nil :model.paid_time]];
    _serviceDeviceLab.text = [NSString stringWithFormat:@"服务设备号：%d",model.binded_id];
    _serviceDayLab.text = [NSString stringWithFormat:@"延长服务：%d天",[(ServiceItem*)[(ServiceCommoity *)model.commodities.firstObject items][0] duration]];
    
    
    if (model.stat == 0) {
        
        switch (model.pay_stat) {
            case 0:
                
                _orderStatusLab.text = @"待支付";
                break;
             case 1:
                _orderStatusLab.text = @"已支付";
                break;
            case 2:
                _orderStatusLab.text = @"已支付";
                break;
            case 3:
                _orderStatusLab.text = @"支付失败";
                break;
            
            default:
                break;
        }
        
        
    }else{
        
        switch (model.stat) {
            case 3:
                _orderStatusLab.text = @"已过期";
                break;
            case 2:
                _orderStatusLab.text = @"已取消";
                break;
            case 1:
                _orderStatusLab.text = @"已支付";
                break;
            default:
                break;
        }
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        UIView *mainView = [[UIView alloc] init];
        mainView.backgroundColor = [UIColor whiteColor];
        [self addSubview:mainView];
        [mainView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(15);
            make.right.equalTo(self).offset(-15);
            make.top.equalTo(self).offset(5);
            make.bottom.equalTo(self);
        }];
        
        UIView *lineView = [[UIView alloc] init];
        lineView.backgroundColor = [QFTools colorWithHexString:@"#06C1AE"];
        [mainView addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(mainView).offset(10);
            make.top.equalTo(mainView).offset(13);
            make.size.mas_equalTo(CGSizeMake(2, 16));
        }];
        
        UILabel *titleLab = [[UILabel alloc] init];
        titleLab.text = @"订单信息";
        titleLab.textColor = [QFTools colorWithHexString:@"#333333"];
        titleLab.font = FONT_PINGFAN(15);
        [mainView addSubview:titleLab];
        [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(lineView.mas_right).offset(5);
            make.centerY.equalTo(lineView);
            make.height.mas_equalTo(21);
        }];
        
        _orderStatusLab = [[UILabel alloc] init];
        _orderStatusLab.text = @"已完成";
        _orderStatusLab.textColor = [QFTools colorWithHexString:@"#06C1AE"];
        _orderStatusLab.font = FONT_PINGFAN(13);
        [mainView addSubview:_orderStatusLab];
        [_orderStatusLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(mainView).offset(-10);
            make.centerY.equalTo(lineView);
            make.height.mas_equalTo(18);
        }];
        
        _orderIDLab = [[UILabel alloc] init];
        _orderIDLab.text = @"订单编号：3838138586838438";
        _orderIDLab.textColor = [QFTools colorWithHexString:@"#666666"];
        _orderIDLab.font = FONT_PINGFAN(13);
        [mainView addSubview:_orderIDLab];
        [_orderIDLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(titleLab);
            make.top.equalTo(titleLab.mas_bottom).offset(5);
            make.height.mas_equalTo(18);
        }];
        
        _orderTime = [[UILabel alloc] init];
        _orderTime.text = @"下单时间：2020-02-26 20:48:32";
        _orderTime.textColor = [QFTools colorWithHexString:@"#666666"];
        _orderTime.font = FONT_PINGFAN(13);
        [mainView addSubview:_orderTime];
        [_orderTime mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(titleLab);
            make.top.equalTo(_orderIDLab.mas_bottom).offset(5);
            make.height.mas_equalTo(18);
        }];
        
        _payChannel = [[UILabel alloc] init];
        _payChannel.text = @"支付方式：支付宝";
        _payChannel.textColor = [QFTools colorWithHexString:@"#666666"];
        _payChannel.font = FONT_PINGFAN(13);
        [mainView addSubview:_payChannel];
        [_payChannel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(titleLab);
            make.top.equalTo(_orderTime.mas_bottom).offset(5);
            make.height.mas_equalTo(18);
        }];
        
        _payTime = [[UILabel alloc] init];
        _payTime.text = @"付款时间：2020-02-27 08:08:18";
        _payTime.textColor = [QFTools colorWithHexString:@"#666666"];
        _payTime.font = FONT_PINGFAN(13);
        [mainView addSubview:_payTime];
        [_payTime mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(titleLab);
            make.top.equalTo(_payChannel.mas_bottom).offset(5);
            make.height.mas_equalTo(18);
        }];
        
        UILabel *obtainLab = [[UILabel alloc] init];
        obtainLab.text = @"配送方式：在线充值";
        obtainLab.textColor = [QFTools colorWithHexString:@"#666666"];
        obtainLab.font = FONT_PINGFAN(13);
        [mainView addSubview:obtainLab];
        [obtainLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(titleLab);
            make.top.equalTo(_payTime.mas_bottom).offset(5);
            make.height.mas_equalTo(18);
        }];
        
        _serviceDeviceLab = [[UILabel alloc] init];
        _serviceDeviceLab.text = @"服务设备号：1111111111111111";
        _serviceDeviceLab.textColor = [QFTools colorWithHexString:@"#666666"];
        _serviceDeviceLab.font = FONT_PINGFAN(13);
        [mainView addSubview:_serviceDeviceLab];
        [_serviceDeviceLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(titleLab);
            make.top.equalTo(obtainLab.mas_bottom).offset(5);
            make.height.mas_equalTo(18);;
        }];
        
        _serviceDayLab = [[UILabel alloc] init];
        _serviceDayLab.text = @"延长服务：90天";
        _serviceDayLab.textColor = [QFTools colorWithHexString:@"#666666"];
        _serviceDayLab.font = FONT_PINGFAN(13);
        [mainView addSubview:_serviceDayLab];
        [_serviceDayLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(titleLab);
            make.top.equalTo(_serviceDeviceLab.mas_bottom).offset(5);
            make.height.mas_equalTo(18);
            make.bottom.equalTo(mainView).offset(-5);
        }];
    }
    return self;
}

@end
