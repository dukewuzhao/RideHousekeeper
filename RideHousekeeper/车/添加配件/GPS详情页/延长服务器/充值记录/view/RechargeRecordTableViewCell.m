//
//  RechargeRecordTableViewCell.m
//  RideHousekeeper
//
//  Created by Apple on 2020/3/4.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import "RechargeRecordTableViewCell.h"
#import "OrderCommodityCollectionViewCell.h"
@interface RechargeRecordTableViewCell ()<UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property(nonatomic,strong) UIView *mainView;
@property(nonatomic,strong) UILabel *orderIDLab;
@property(nonatomic,strong) UILabel *tradingStatusLab;
@property(nonatomic,strong) UILabel *orderTime;
@property(nonatomic,strong) UILabel *payTime;
@property(nonatomic,strong) UICollectionView *collectionView;
@property(nonatomic,strong) UIButton *payBtn;
@property(nonatomic,strong) UILabel *priceLab;
@property(nonatomic,strong) UILabel *totalNumLab;
@property(nonatomic,strong) ServiceOrder *serviceOrderModel;
@property(nonatomic,assign) NSInteger bikeid;
@end

@implementation RechargeRecordTableViewCell

-(void)setServiceOrderModel:(ServiceOrder *)model bikeID:(NSInteger)bikeid{
    _serviceOrderModel = model;
    _bikeid = bikeid;
    
    _orderIDLab.text = [NSString stringWithFormat:@"订单号：%d",model.ID];
    _orderTime.text = [NSString stringWithFormat:@"下单时间：%@",[QFTools stringFromInt:nil :model.created_time]];
    _payTime.text = [NSString stringWithFormat:@"付款时间：%@",[QFTools stringFromInt:nil :model.paid_time]];
    _priceLab.text = [NSString stringWithFormat:@"实付：￥%.1f",model.amount/100.0];
    _totalNumLab.text = [NSString stringWithFormat:@"共%d件商品",model.commodities.count];
    
    if (model.stat == 0) {
        
        switch (model.pay_stat) {
            case 0:
                [self setStat:0];
                _tradingStatusLab.text = @"待支付";
                break;
             case 1:
                [self setStat:1];
                _tradingStatusLab.text = @"已支付";
                break;
            case 2:
                [self setStat:2];
                _tradingStatusLab.text = @"已支付";
                break;
            case 3:
                [self setStat:3];
                _tradingStatusLab.text = @"支付失败";
                break;
            
            default:
                break;
        }
        
        
    }else{
        [self setStat:model.stat];
        
        switch (model.stat) {
            case 3:
                _tradingStatusLab.text = @"已过期";
                break;
            case 2:
                _tradingStatusLab.text = @"已取消";
                break;
            case 1:
                _tradingStatusLab.text = @"已支付";
                break;
            default:
                break;
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView reloadData];
    });
    
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        _mainView = [[UIView alloc] init];
        _mainView.layer.cornerRadius = 10;
        _mainView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:_mainView];
        [_mainView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(15);
            make.right.equalTo(self.contentView).offset(-15);
            make.top.equalTo(self.contentView).offset(5);
            make.bottom.equalTo(self.contentView);
        }];
        
        _orderIDLab = [[UILabel alloc] init];
        _orderIDLab.text = @"订单号：390958058923508203";
        _orderIDLab.textColor = [QFTools colorWithHexString:@"#333333"];
        _orderIDLab.font = FONT_PINGFAN(15);
        [_mainView addSubview:_orderIDLab];
        [_orderIDLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_mainView).offset(10);
            make.top.equalTo(_mainView).offset(10);
            make.height.mas_equalTo(21);
        }];
        
        UIImageView *arrow = [[UIImageView alloc] init];
        arrow.image = [UIImage imageNamed:@"arrow"];
        [_mainView addSubview:arrow];
        [arrow mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_orderIDLab.mas_right).offset(10);
            make.centerY.equalTo(_orderIDLab);
        }];
        
        _tradingStatusLab = [[UILabel alloc] init];
        _tradingStatusLab.text = @"待支付";
        _tradingStatusLab.textColor = [QFTools colorWithHexString:@"#06C1AE"];
        _tradingStatusLab.font = FONT_PINGFAN(11);
        [_mainView addSubview:_tradingStatusLab];
        [_tradingStatusLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(_mainView).offset(-10);
            make.centerY.equalTo(_orderIDLab);
            make.height.mas_equalTo(16);
        }];
        
        _orderTime = [[UILabel alloc] init];
        _orderTime.text = @"下单时间：2020-02-16";
        _orderTime.textColor = [QFTools colorWithHexString:@"#999999"];
        _orderTime.font = FONT_PINGFAN(10);
        [_mainView addSubview:_orderTime];
        [_orderTime mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_orderIDLab);
            make.top.equalTo(_orderIDLab.mas_bottom).offset(5);
            make.height.mas_equalTo(14);
        }];
        
        _payTime = [[UILabel alloc] init];
        _payTime.text = @"支付时间：2020-02-17";
        _payTime.textColor = [QFTools colorWithHexString:@"#999999"];
        _payTime.font = FONT_PINGFAN(10);
        [_mainView addSubview:_payTime];
        [_payTime mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_orderTime.mas_right).offset(20);
            make.centerY.equalTo(_orderTime);
            make.height.mas_equalTo(14);
        }];
        
        UIView *lineView = [[UIView alloc] init];
        lineView.backgroundColor = [QFTools colorWithHexString:@"#cccccc"];
        [_mainView addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(_mainView);
            make.top.equalTo(_orderTime.mas_bottom).offset(6);
            make.height.mas_equalTo(0.5);
        }];
        
        [self addSubview:self.collectionView];
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_mainView);
            make.top.equalTo(lineView.mas_bottom).offset(10);
            make.right.equalTo(_mainView);
            make.height.mas_equalTo(60);
        }];
        
        _priceLab = [[UILabel alloc] init];
        _priceLab.text = @"实付：￥49.9";
        _priceLab.textColor = [QFTools colorWithHexString:@"#333333"];
        _priceLab.font = FONT_PINGFAN(15);
        [_mainView addSubview:_priceLab];
        [_priceLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_mainView).offset(15);
            make.bottom.equalTo(_mainView).offset(-12);
            make.height.mas_equalTo(21);
        }];
        
        _totalNumLab = [[UILabel alloc] init];
        _totalNumLab.text = @"共5件商品";
        _totalNumLab.textColor = [QFTools colorWithHexString:@"#666666"];
        _totalNumLab.font = FONT_PINGFAN(10);
        [_mainView addSubview:_totalNumLab];
        [_totalNumLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_priceLab.mas_right).offset(10);
            make.centerY.equalTo(_priceLab);
            make.height.mas_equalTo(21);
        }];
        
    }
    return self;
}

#pragma mark - UICollectionViewDataSource method
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return _serviceOrderModel.commodities.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    OrderCommodityCollectionViewCell *cell = (OrderCommodityCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"OrderCommodityCollectionViewCell" forIndexPath:indexPath];
    cell.icon.image = [UIImage imageNamed:@"discounted_good_icon"];
    return cell;
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 10, 0, 0);//分别为上、左、下、右
}

#pragma mark - UICollectionViewDelegate method
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor clearColor];
}

- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.contentView.backgroundColor = nil;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    cell.backgroundColor = [UIColor clearColor];
}


- (void)setStat:(NSInteger)stat{
    if (stat == 0) {
        
        if (_payBtn) {
            return;
        }
        
        _tradingStatusLab.textColor = [QFTools colorWithHexString:@"#FF5E00"];
        
        [_mainView addSubview:self.payBtn];
        [self.payBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(_mainView).offset(-11);
            make.bottom.equalTo(_mainView).offset(-10);
            make.size.mas_equalTo(CGSizeMake(95, 26));
        }];
        @weakify(self);
        [[_payBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);

        }];

    }else{
        
        [_payBtn removeFromSuperview];
        _payBtn = nil;
        _tradingStatusLab.textColor = [QFTools colorWithHexString:@"#06C1AE"];
    }
    
}

-(UIButton *)payBtn{
    if (!_payBtn) {
        _payBtn = [[UIButton alloc] init];
        _payBtn.backgroundColor = [QFTools colorWithHexString:@"#06C1AE"];
        [_payBtn setTitle:@"立即支付" forState:UIControlStateNormal];
        _payBtn.titleLabel.font = FONT_PINGFAN(10);
        _payBtn.titleLabel.textColor = [UIColor whiteColor];
        _payBtn.layer.cornerRadius = 13;
        @weakify(self);
        [[_payBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            if (self.OrderProcessingCode) {
                self.OrderProcessingCode();
            }
        }];
    }
    return _payBtn;
}

-(UICollectionView *)collectionView{
    
    if (!_collectionView) {
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumInteritemSpacing = 5;
        layout.minimumLineSpacing = 10;
        layout.itemSize = CGSizeMake(73, 50);
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        //注册
        [_collectionView registerClass:[OrderCommodityCollectionViewCell class] forCellWithReuseIdentifier:@"OrderCommodityCollectionViewCell"];
    }
    return _collectionView;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
