//
//  ConfirmOrderUIViewController.m
//  RideHousekeeper
//
//  Created by Apple on 2020/3/3.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import "ConfirmOrderUIViewController.h"
#import "OrderDetailViewController.h"
#import "FillPrepaidCardActivationCodeViewController.h"
#import "FillTransferPasswordViewController.h"
#import "ConfirmOrderTableViewCell.h"
#import "PaymentOptionsTableViewCell.h"
#import "RechargeCardSelectTableViewCell.h"
#import "BottomPaymentView.h"
#import "WXApiManager.h"
#import "AlipayApiManager.h"

@interface ConfirmOrderUIViewController ()<UITableViewDelegate,UITableViewDataSource,WXApiManagerDelegate>
@property(nonatomic,strong)ServiceOrder *model;
@property(nonatomic,strong)DeviceInfoModel *deviceModel;
@property(nonatomic,strong)ServiceCard *serviceCard;
@property(nonatomic,assign)NSInteger bikeId;
@property(nonatomic,assign)PayChannel channel;
@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,assign)NSInteger type;
@end

@implementation ConfirmOrderUIViewController

-(void)setCommodityInfo:(ServiceOrder *)model deviceInfo:(DeviceInfoModel*)devide serviceCardInfo:(ServiceCard*)card type:(NSInteger)type bikeid:(NSInteger)bikeid{
    _model = model;
    _deviceModel = devide;
    _serviceCard = card;
    _bikeId = bikeid;
    _type = type;
    dispatch_async(dispatch_get_main_queue(), ^{
        [_tableView reloadData];
    });
}


-(void)orderPay:(NSInteger)orderid :(NSInteger)channel{
    
    NSString *token = [QFTools getdata:@"token"];
    NSString *URLString = [NSString stringWithFormat:@"%@%@",QGJURL,@"app/service/order/pay"];
    NSDictionary *parameters = @{@"token":token,@"order_id":@(orderid),@"pay_channel":@(channel)};
    
    [[HttpRequest sharedInstance] postWithURLString:URLString parameters:parameters success:^(id _Nullable dict) {
        
        if ([dict[@"status"] intValue] == 0) {
            
            NSDictionary *data = dict[@"data"];
            NSDictionary *pay_args = data[@"pay_args"];
            
            if (channel == 4) {
                NSDictionary *alipay = pay_args[@"alipay"];
                NSString *pay_info = alipay[@"pay_info"];//支付宝的payinfo
                NSString *appScheme = @"RideHousekeeper";
                
                [self pushNewVc:_model bikeId:_bikeId type:0];
                [[AlipayApiManager sharedManager] callAlipay:pay_info fromScheme:appScheme];
                [[APPStatusManager sharedManager] setUpdatePaymentStatus:YES];
            }else{
                
                if (![WXApi isWXAppInstalled]) {
                    [SVProgressHUD showSimpleText:@"微信未安装"];
                    return ;
                }else if(![WXApi isWXAppSupportApi]){
                    [SVProgressHUD showSimpleText:@"微信不支持支付"];
                    return;
                }
                
                NSDictionary *weixin = pay_args[@"weixin"];
                [WXApi sendReq:[WXApiRequestHandler jumpToBizPay:weixin] completion:^(BOOL success) {
                    if (success) {
                        NSLog(@"打开微信成功");
                        [LoadView sharedInstance].protetitle.text = @"支付中";
                        [[LoadView sharedInstance] show];
                        [self pushNewVc:_model bikeId:_bikeId type:0];
                        [[APPStatusManager sharedManager] setUpdatePaymentStatus:YES];
                    }else NSLog(@"打开微信失败");
                }];
            }
            
        }else{
            [SVProgressHUD showSimpleText:dict[@"status_info"]];
        }
        
    }failure:^(NSError *error) {
        [SVProgressHUD showSimpleText:TIP_OF_NO_NETWORK];
        NSLog(@"error :%@",error);
        
    }];
}

-(void)pushNewVc:(ServiceOrder *)model bikeId:(NSInteger)bikeid type:(NSInteger)type{
    
    NSMutableArray *viewCtrs = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    for (UIViewController *controller in viewCtrs){
       if ([controller isKindOfClass:[NSClassFromString(@"ServiceMallViewController") class]]) {
           NSInteger index = [viewCtrs indexOfObject:controller] + 1;
           [viewCtrs removeObjectsInRange: NSMakeRange(index, viewCtrs.count - index)];
           OrderDetailViewController *orderVc = [[OrderDetailViewController alloc] init];
           [orderVc setOrderInfo:model bikeid:bikeid type:type];
           [viewCtrs addObject:orderVc];
           [self.navigationController setViewControllers:viewCtrs animated:YES];
           return;
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupNavView];
    [self setupTableView];
    
    if (_type == 1) {
        
        BottomPaymentView *footView = [[BottomPaymentView alloc] initWithFrame:CGRectMake(15, ScreenHeight - 76, ScreenWidth - 30, 66)];
        footView.currentPriceLab.text = [NSString stringWithFormat:@"¥%.1f",_model.amount/100.0];
        footView.savePriceLab.text = [NSString stringWithFormat:@"已优惠¥%.1f",_model.promotion_amount/100.0];
        @weakify(self);
        footView.selectAction = ^ {
            @strongify(self);
            if (self.channel == SelectNone) {
                [SVProgressHUD showSimpleText:@"请选择支付方式"];
                return ;
            }
            switch (self.channel) {
                case WeChat:
                    [self orderPay:self.model.ID :3];
                    break;
                case Alipay:
                   [self orderPay:self.model.ID :4];
                    break;
                default:
                    break;
            }
        };
        [self.view addSubview:footView];
        
    }else if (_type == 2){
        
        UIView *footview = [[UIView alloc] initWithFrame:CGRectMake(0, ScreenHeight - 84, ScreenWidth, 84)];
        footview.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:footview];
        UIButton *buyBtn = [[UIButton alloc] init];
        buyBtn.layer.cornerRadius = 22;
        buyBtn.backgroundColor = [QFTools colorWithHexString:@"#06C1AE"];
        [buyBtn setTitle:@"确认兑换" forState:UIControlStateNormal];
        [buyBtn setTitleColor:[QFTools colorWithHexString:@"#FFFFFF"] forState:UIControlStateNormal];
        buyBtn.titleLabel.font = FONT_PINGFAN(17);
        [footview addSubview:buyBtn];
        [buyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(footview);
            make.centerY.equalTo(footview);
            make.size.mas_equalTo(CGSizeMake(214, 44));
        }];
        @weakify(self);
        [[buyBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            
            if (self.channel == SelectNone) {
                [SVProgressHUD showSimpleText:@"请选择支付方式"];
                return ;
            }
            
            FillPrepaidCardActivationCodeViewController *vc = [[FillPrepaidCardActivationCodeViewController alloc] init];
            [vc setOrderInfo:self.model serviceCardModel:self.serviceCard bikeid:self.bikeId];
            [self.navigationController pushViewController:vc animated:YES];
        }];
    }else if (_type == 3){
        
        UIView *footview = [[UIView alloc] initWithFrame:CGRectMake(0, ScreenHeight - 84, ScreenWidth, 84)];
        footview.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:footview];
        UIButton *buyBtn = [[UIButton alloc] init];
        buyBtn.layer.cornerRadius = 22;
        buyBtn.backgroundColor = [QFTools colorWithHexString:@"#06C1AE"];
        [buyBtn setTitle:@"确认转移" forState:UIControlStateNormal];
        [buyBtn setTitleColor:[QFTools colorWithHexString:@"#FFFFFF"] forState:UIControlStateNormal];
        buyBtn.titleLabel.font = FONT_PINGFAN(17);
        [footview addSubview:buyBtn];
        [buyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(footview);
            make.centerY.equalTo(footview);
            make.size.mas_equalTo(CGSizeMake(214, 44));
        }];
        @weakify(self);
        [[buyBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            FillTransferPasswordViewController *fillTransferPasswordVc = [[FillTransferPasswordViewController alloc] init];
            [fillTransferPasswordVc setDeviceInfoModel:self.deviceModel bikeid:self.bikeId];
            [self.navigationController pushViewController:fillTransferPasswordVc animated:YES];
        }];
    }
}

- (void)setupNavView{
    [super setupNavView];
    self.navView.backgroundColor = [QFTools colorWithHexString:MainColor];
    self.navView.showBottomLabel = NO;
    [self.navView.centerButton setTitle:@"确认订单"forState:UIControlStateNormal];
    @weakify(self);
    [self.navView.leftButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    self.navView.leftButtonBlock = ^{
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    };
}

-(void)setupTableView{
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, navHeight, ScreenWidth, ScreenHeight - navHeight - 84)];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.bounces = NO;
    _tableView.backgroundColor = [UIColor clearColor];
    [_tableView setSeparatorColor:[QFTools colorWithHexString:SeparatorColor]];
    [_tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    [self.view addSubview:_tableView];
}

#pragma mark -- TableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
    
    if (_type == 3) {
        return 1;
    }
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1) {
        
        if (_type == 1) {
            return 135.f;
        }else{
            return 73.f;
        }
    }else{
        return 178.0f +_model.commodities.count * 55;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *header = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 24)];
    UILabel *textlab = [[UILabel alloc] init];
    textlab.font = FONT_PINGFAN(10);
    textlab.textColor = [QFTools colorWithHexString:@"#999999"];
    [header addSubview:textlab];
    [textlab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(header).offset(10);
        make.centerY.equalTo(header);
    }];
    
    switch (section) {
        case 0:
            textlab.text = @"订单信息";
            break;
            case 1:
            textlab.text = @"请选择支付方式";
            break;
        default:
            break;
    }
    
    return header;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    UIView *header = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 0.1)];
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 24;
}

- ( void )tableView:( UITableView  *)tableView  willDisplayCell :( UITableViewCell  *)cell  forRowAtIndexPath :( NSIndexPath  *)indexPath{
    
    cell.backgroundColor = CellColor;
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section{
    
    view.tintColor = [QFTools colorWithHexString:@"#cccccc"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.section == 0) {
        ConfirmOrderTableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:@"ConfirmOrderTableViewCell"];
        if (!cell) {
            cell = [[ConfirmOrderTableViewCell alloc] initWithStyle:0 reuseIdentifier:@"ConfirmOrderTableViewCell"];
        }
        cell.selectionStyle =  UITableViewCellSelectionStyleNone;
        [cell setOrderInfo:_model];
        return cell;
    }else{
        if (_type == 1) {
            PaymentOptionsTableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:@"PaymentOptionsTableViewCell"];
            if (!cell) {
                cell = [[PaymentOptionsTableViewCell alloc] initWithStyle:0 reuseIdentifier:@"PaymentOptionsTableViewCell"];
            }
            cell.selectionStyle =  UITableViewCellSelectionStyleNone;
            @weakify(self);
            cell.selectPayChannel = ^(PayChannel code) {
                @strongify(self);
                self.channel = code;
            };
            return cell;
        }else{
            RechargeCardSelectTableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:@"RechargeCardSelectTableViewCell"];
            if (!cell) {
                cell = [[RechargeCardSelectTableViewCell alloc] initWithStyle:0 reuseIdentifier:@"RechargeCardSelectTableViewCell"];
            }
            cell.selectionStyle =  UITableViewCellSelectionStyleNone;
            @weakify(self);
            cell.selectPayChannel = ^(NSInteger code) {
                @strongify(self);
                self.channel = code;
            };
            return cell;
        }
    }
}


@end
