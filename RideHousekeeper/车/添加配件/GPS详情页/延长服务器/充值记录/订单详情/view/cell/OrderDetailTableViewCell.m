//
//  OrderDetailTableViewCell.m
//  RideHousekeeper
//
//  Created by Apple on 2020/3/13.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import "OrderDetailTableViewCell.h"
#import "OrderDetailHeadView.h"
#import "OrderDetailMiddleView.h"
#import "OrderDetailFootView.h"
#import "PayChannelSelectView.h"

@interface OrderDetailTableViewCell()
@property (nonatomic,strong) OrderDetailHeadView *headView;
@property (nonatomic,strong) PayChannelSelectView *payChannelSelectView;
@property (nonatomic,strong) OrderDetailMiddleView *middleView;
@property (nonatomic,strong) OrderDetailFootView *footView;
@end
@implementation OrderDetailTableViewCell

-(void)setOrderInfo:(ServiceOrder *)model type:(OrderType)type{
    [_footView setOrderInfo:model];
    [_middleView setOrderInfo:model];
    
    if (type == OrderWithOutHead) {
        [_headView removeFromSuperview];
        [_payChannelSelectView removeFromSuperview];
        _headView = nil;
        _payChannelSelectView = nil;
        [_middleView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView);
        }];
        
        return;
    }else if (type == OrderWithOutPayChannel){
        [_payChannelSelectView removeFromSuperview];
        _payChannelSelectView = nil;
        
        [_middleView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_headView.mas_bottom);
        }];
        
    }else{
        [self.payChannelSelectView setOrderInfo:model];
    }
    if (model.stat == 0) {
        
        switch (model.pay_stat) {
            case 0:
                _headView.payStatusImg.image = [UIImage imageNamed:@"wait_payment_icon"];
                _headView.promptLab.text = @"您的订单已提交，等待交付中，快去支付吧~\n超过30分钟未支付，订单将自动取消";
                
                break;
             case 1:
                _headView.payStatusImg.image = [UIImage imageNamed:@"payment_completed_icon"];
                _headView.promptLab.text = @"支付完成";
                break;
            case 2:
                _headView.payStatusImg.image = [UIImage imageNamed:@"payment_completed_icon"];
                _headView.promptLab.text = @"支付完成";
                break;
            case 3:
                _headView.payStatusImg.image = [UIImage imageNamed:@"abnormal_payment_icon"];
                _headView.promptLab.text = @"支付异常，请稍后查看订单状态\n若支付状态一直显示异常，请联系客服";
                break;
            
            default:
                break;
        }
        
        
    }else{
        
        switch (model.stat) {
            case 3:
                _headView.payStatusImg.image = [UIImage imageNamed:@"order_timed_out_icon"];
                _headView.promptLab.text = @"您的订单已超时，系统已为您自动取消";
                break;
            case 2:
                _headView.payStatusImg.image = [UIImage imageNamed:@"order_timed_out_icon"];
                _headView.promptLab.text = @"您的订单已超时，系统已为您自动取消";
                break;
            case 1:
                _headView.payStatusImg.image = [UIImage imageNamed:@"payment_completed_icon"];
                _headView.promptLab.text = @"支付完成";
                break;
            default:
                break;
        }
    }
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        _headView = [[OrderDetailHeadView alloc] init];
        [self.contentView addSubview:_headView];
        [_headView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.equalTo(self.contentView);
        }];
        @weakify(self);
        self.payChannelSelectView.updatePayChannelBlock = ^(BOOL select) {
            @strongify(self);
            if(self.updateCellHeight) self.updateCellHeight(select);
            if (select) {
                [self.payChannelSelectView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.height.mas_equalTo(40 + 45*2);
                }];
            }else{
                [self.payChannelSelectView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.height.mas_equalTo(40);
                }];
            }
        } ;
        
        self.payChannelSelectView.selectPayChannel = ^(NSInteger code) {
            @strongify(self);
            if (self.selectPayChannel) {
                self.selectPayChannel(code);
            }
        };
        
        _middleView = [[OrderDetailMiddleView alloc] init];
        [self.contentView addSubview:_middleView];
        [_middleView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.payChannelSelectView.mas_bottom);
            make.left.right.equalTo(self.contentView);
        }];
        
        _footView = [[OrderDetailFootView alloc] init];
        [self.contentView addSubview:_footView];
        [_footView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_middleView.mas_bottom);
            make.left.right.equalTo(self.contentView);
            //make.bottom.equalTo(self.contentView);
        }];
    }
    return self;
}

//-(OrderDetailHeadView *)headView{
//    if (!_headView) {
//        _headView = [[OrderDetailHeadView alloc] init];
//    }
//    return _headView;
//}
//
//-(OrderDetailMiddleView *)middleView{
//    if (!_middleView) {
//        _middleView = [[OrderDetailMiddleView alloc] init];
//    }
//    return _middleView;
//}
//
//-(OrderDetailFootView *)footView{
//    if (!_footView) {
//        _footView = [[OrderDetailFootView alloc] init];
//    }
//    return _footView;
//}

-(PayChannelSelectView *)payChannelSelectView{
    if (!_payChannelSelectView) {
        _payChannelSelectView = [[PayChannelSelectView alloc] init];
        [self.contentView addSubview:_payChannelSelectView];
        [_payChannelSelectView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_headView.mas_bottom);
            make.left.right.equalTo(self.contentView);
            make.height.mas_greaterThanOrEqualTo(40);
        }];
        
    }
    return _payChannelSelectView;
}


@end
