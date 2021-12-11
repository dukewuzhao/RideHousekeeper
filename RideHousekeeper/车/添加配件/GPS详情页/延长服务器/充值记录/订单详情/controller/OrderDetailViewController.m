//
//  OrderDetailViewController.m
//  RideHousekeeper
//
//  Created by Apple on 2020/3/13.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import "OrderDetailViewController.h"
#import "OrderDetailTableViewCell.h"
#import "TwoDimensionalCodecanViewController.h"
#import "FillPrepaidCardActivationCodeViewController.h"
#import "WXApiManager.h"
#import "AlipayApiManager.h"
#import "TimingPaymentView.h"
#import "Manager.h"

@interface OrderDetailViewController ()<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,strong) MSWeakTimer *timer;//订单支付倒计时
@property(nonatomic,strong) MSWeakTimer * monitorTime;//查询订单信息倒计时
@property(nonatomic,strong) UITableView *tableView;
@property(nonatomic,strong) TimingPaymentView *timingPaymentView;//底部视图
@property(nonatomic,strong) ServiceOrder *model;
@property(nonatomic,assign) NSInteger bikeId;
@property(nonatomic,assign) NSInteger type;//cell展示类型
@property(nonatomic,assign) NSInteger payChannel;//支付渠道
@property(nonatomic,assign) NSInteger countTime;//倒计时
@property(nonatomic,assign) NSInteger pay_stat;//0:未支付 1:已支付 2:订单失效
@property(nonatomic,strong) NSMutableDictionary *showDic;
@end

@implementation OrderDetailViewController

-(void)startTimer{
    [_monitorTime invalidate];
    _monitorTime = [MSWeakTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(checkOrderStatus) userInfo:nil repeats:YES dispatchQueue:dispatch_get_main_queue()];
}

-(void)checkOrderStatus{
    _countTime ++;
    if (_countTime == 10) {
        [_monitorTime invalidate];
        _monitorTime = nil;
    }
    [self orderGet];
}
//.查询GPS服务订单，更新状态
-(void)orderCheck:(NSUInteger)success result_info:(NSString *)info{
    [LoadView sharedInstance].protetitle.text = @"刷新订单状态";
    NSString *token = [QFTools getdata:@"token"];
    NSNumber *order_id = @(_model.ID);
    NSString *URLString = [NSString stringWithFormat:@"%@%@",QGJURL,@"app/service/order/check"];
    NSDictionary *parameters = @{@"token":token, @"order_id": order_id,@"success": @(success),@"result_info": info? :@""};
    [[HttpRequest sharedInstance] postWithURLString:URLString parameters:parameters success:^(id _Nullable dict) {
        
        if ([dict[@"status"] intValue] == 0) {
            NSDictionary *data = dict[@"data"];
            ServiceOrder* model = [ServiceOrder yy_modelWithDictionary:data[@"order"]];
            if (self.pay_stat == 1) {
                if (model.stat == 0 && model.pay_stat == 0) {
                    [self startTimer];
                }else if (model.stat == 0 && model.pay_stat == 1){
                    [self startTimer];
                }else if (model.stat == 0 && model.pay_stat == 3){
                    [self startTimer];
                }else{
                    [self orderGet];
                }
            }else{
                [self orderGet];
            }
        }else{
            [self startTimer];
        }
    }failure:^(NSError *error) {
        NSLog(@"error :%@",error);
        [SVProgressHUD showSimpleText:TIP_OF_NO_NETWORK];
        [[LoadView sharedInstance] hide];
    }];
}
//.获取GPS服务订单最新状态
-(void)orderGet{
    
    NSString *token = [QFTools getdata:@"token"];
    NSNumber *order_id = @(_model.ID);
    NSString *URLString = [NSString stringWithFormat:@"%@%@",QGJURL,@"app/service/order/get"];
    NSDictionary *parameters = @{@"token":token, @"order_id": order_id};
    [[HttpRequest sharedInstance] postWithURLString:URLString parameters:parameters success:^(id _Nullable dict) {
        
        if ([dict[@"status"] intValue] == 0) {
            NSDictionary *data = dict[@"data"];
            ServiceOrder* model = [ServiceOrder yy_modelWithDictionary:data[@"order"]];
            
            if (model.stat == 0) {
                
                switch (model.pay_stat) {
                    case 0://未支付
                        self.pay_stat = 0;
                        break;
                     case 1://已支付
                        self.pay_stat = 1;
                        [self setResetTableView:model];
                        [self.navView.centerButton setTitle:@"订单详情"forState:UIControlStateNormal];
                        break;
                    case 2://支付成功
                        self.pay_stat = 1;
                        [self setResetTableView:model];
                        [self.navView.centerButton setTitle:@"订单详情"forState:UIControlStateNormal];
                        break;
                    case 3://支付失败
                        self.pay_stat = 2;
                        [self setResetTableView:model];
                        [self.navView.centerButton setTitle:@"支付失败"forState:UIControlStateNormal];
                        break;
                    
                    default:
                        break;
                }
                
                
            }else{
                [self.navView.centerButton setTitle:@"订单详情"forState:UIControlStateNormal];
                switch (model.stat) {
                    case 3://过期
                        self.pay_stat = 2;
                        [self setResetTableView:model];
                        
                        break;
                    case 2://取消
                        self.pay_stat = 2;
                        [self setResetTableView:model];
                        break;
                    case 1://已支付
                        self.pay_stat = 1;
                        [self setResetTableView:model];
                        break;
                    default:
                        break;
                }
            }
        }else{
            [SVProgressHUD showSimpleText:dict[@"status_info"]];
        }
        [[LoadView sharedInstance] hide];
    }failure:^(NSError *error) {
        NSLog(@"error :%@",error);
        [[LoadView sharedInstance] hide];
        [SVProgressHUD showSimpleText:TIP_OF_NO_NETWORK];
    }];
}

-(void)setResetTableView:(ServiceOrder *)model{
    [self resetView];
    [_monitorTime invalidate];
    _monitorTime = nil;
    _model = model;
    _type = OrderWithOutPayChannel;
    [self getbikelist:model];
    dispatch_async(dispatch_get_main_queue(), ^{
        [_tableView reloadData];
    });
}

//.支付GPS服务订单
-(void)orderPay:(NSInteger)orderid :(NSInteger)channel{
    [LoadView sharedInstance].protetitle.text = @"支付中";
    [[LoadView sharedInstance] show];
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
                [[LoadView sharedInstance] hide];
                [[AlipayApiManager sharedManager] callAlipay:pay_info fromScheme:appScheme];
                [[APPStatusManager sharedManager] setUpdatePaymentStatus:YES];
            }else{
                
                if (![WXApi isWXAppInstalled]) {
                    [SVProgressHUD showSimpleText:@"微信未安装"];
                    [[LoadView sharedInstance] hide];
                    return ;
                }else if(![WXApi isWXAppSupportApi]){
                    [SVProgressHUD showSimpleText:@"微信不支持支付"];
                    [[LoadView sharedInstance] hide];
                    return ;
                }
                
                NSDictionary *weixin = pay_args[@"weixin"];
                [WXApi sendReq:[WXApiRequestHandler jumpToBizPay:weixin] completion:^(BOOL success) {
                    if (success) {
                        NSLog(@"打开微信成功");
                        [[APPStatusManager sharedManager] setUpdatePaymentStatus:YES];
                    }else NSLog(@"打开微信失败");
                }];
            }
            
        }else{
            [[LoadView sharedInstance] hide];
            [SVProgressHUD showSimpleText:dict[@"status_info"]];
        }
        
    }failure:^(NSError *error) {
        [SVProgressHUD showSimpleText:TIP_OF_NO_NETWORK];
        NSLog(@"error :%@",error);
        [[LoadView sharedInstance] hide];
    }];
}
//.刷新GPS服务数据
- (void)getbikelist:(ServiceOrder *)model{
    
    NSString *token = [QFTools getdata:@"token"];
    NSString *userid = [QFTools getdata:@"userid"];
    NSString *URLString = [NSString stringWithFormat:@"%@%@",QGJURL,@"app/getbikelist"];
    NSDictionary *parameters = @{@"token": token, @"user_id":userid};
    
    [[HttpRequest sharedInstance] postWithURLString:URLString parameters:parameters success:^(id _Nullable dict) {
        
        if ([dict[@"status"] intValue] == 0) {
                
            [LVFmdbTool deletePerpheraServicesInfoData:nil];
            NSDictionary *data = dict[@"data"];
            NSMutableArray *bike_info = data[@"bike_info"];
                
            for (NSDictionary *bike in bike_info) {
                BikeInfoModel *bikeInfo = [BikeInfoModel yy_modelWithDictionary:bike];
                
                for (DeviceInfoModel *device in bikeInfo.device_info){
                    for (ServiceInfoModel *servicesInfo in device.service){
                        
                        PerpheraServicesInfoModel *service = [PerpheraServicesInfoModel modelWith:bikeInfo.bike_id deviceid:device.device_id ID:servicesInfo.ID type:servicesInfo.type title:servicesInfo.title brand_id:servicesInfo.brand_id begin_date:servicesInfo.begin_date end_date:servicesInfo.end_date left_days:servicesInfo.left_days];
                        [LVFmdbTool insertPerpheraServicesInfoModel:service];
                    }
                }
            }
            [[Manager shareManager] updateGPSServiceInfo:_bikeId];
        }else{
            [SVProgressHUD showSimpleText:dict[@"status_info"]];
        }
        
    }failure:^(NSError *error) {
        
        NSLog(@"error :%@",error);
        [SVProgressHUD showSimpleText:TIP_OF_NO_NETWORK];
    }];
}

- (NSMutableDictionary *)showDic {
    if (_showDic == nil) {
        _showDic = [NSMutableDictionary dictionary];
    }
    
    return _showDic;
}

-(TimingPaymentView *)timingPaymentView{
    if (!_timingPaymentView) {
        _timingPaymentView = [[TimingPaymentView alloc] initWithFrame:CGRectMake(0, ScreenHeight - 60, ScreenWidth, 60)];
        [self.view addSubview:_timingPaymentView];
    }
    return _timingPaymentView;
}

-(void)resetView{
    [UIView animateWithDuration:0.3 animations:^{
        self.timingPaymentView.alpha = 0;
    } completion:^(BOOL finished) {
        [_timer invalidate];
        _timer = nil;
        [_timingPaymentView removeFromSuperview];
        _timingPaymentView = nil;
        _tableView.height = ScreenHeight - navHeight;
    }];
    [NSNOTIC_CENTER postNotificationName:KNOTIFICATION_UPDATEORDERLIST object:nil];
}
//1.设置初始值
-(void)setOrderInfo:(ServiceOrder *)model bikeid:(NSInteger)bikeid type:(NSUInteger)type{
    
    _model = model;
    _bikeId = bikeid;
    _type = type;
    
    switch (model.pay_channel) {
        case 0:
            self.payChannel = 0;
            break;
        case 1:
            self.payChannel = 2;
        break;
        case 3:
            self.payChannel = 1;
            break;
        case 4:
            self.payChannel = 0;
            break;
        default:
            break;
    }
    
    if (_model.stat == 0 && _model.pay_stat == 0) {
        NSString *price = [NSString stringWithFormat:@"总计：￥%.1f",model.amount/100.0];
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:price attributes:@{NSFontAttributeName: FONT_PINGFAN(17), NSForegroundColorAttributeName: [QFTools colorWithHexString:@"#FF5E00"]}];
        [string addAttributes:@{NSFontAttributeName: FONT_PINGFAN(13), NSForegroundColorAttributeName: [QFTools colorWithHexString:@"#333333"]} range:NSMakeRange(0, 4)];
        self.timingPaymentView.totalPriceLab.attributedText = string;
        [self.timingPaymentView.payBtn setTitle:[NSString stringWithFormat:@"抢先支付 %@",[QFTools remainingTimeMethodAction:model.expire_time]] forState:UIControlStateNormal];
        _timer = [MSWeakTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updatePaymentTime) userInfo:nil repeats:YES dispatchQueue:dispatch_get_main_queue()];
        @weakify(self);
        self.timingPaymentView.selectAction = ^{
            @strongify(self);
            switch (self.payChannel) {
                case 0:
                    [self orderPay:self.model.ID :4];
                    break;
                case 1:
                    [self orderPay:self.model.ID :3];
                    break;
                default:
                    break;
            }
        };
        
        [[[NSNOTIC_CENTER rac_addObserverForName:KNOTIFICATION_UPDATEORDERLIST object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id x) {
            @strongify(self);
            if (self.pay_stat == 0) {
                [self orderCheck:0 result_info:nil];
            }
        }];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_tableView reloadData];
    });
}

-(void)updatePaymentTime{
    [self.timingPaymentView.payBtn setTitle:[NSString stringWithFormat:@"抢先支付 %@",[QFTools remainingTimeMethodAction:_model.expire_time]] forState:UIControlStateNormal];;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavView];
    [self setupTableView];
    @weakify(self);
    [WXApiManager sharedManager].wechatResp = ^(BaseResp *resp) {
        @strongify(self);
        [[APPStatusManager sharedManager] setUpdatePaymentStatus:NO];
        switch (resp.errCode) {
            case WXSuccess:/**< 成功    */
                NSLog(@"支付成功－PaySuccess，retcode = %d", resp.errCode);
                self.pay_stat = 1;
                [self orderCheck:1 result_info:nil];
                break;

            default:{
                NSLog(@"错误，retcode = %d, retstr = %@", resp.errCode,resp.errStr);
                self.pay_stat = 0;
                [self orderGet];
                break;
            }
        }
    };
    
    [WXApiManager sharedManager].wechatReq = ^(BaseReq *req) {
        //@strongify(self);
    };
    
    [AlipayApiManager sharedManager].alipayCallback = ^(NSDictionary * _Nullable resultDic) {
        @strongify(self);
        [[APPStatusManager sharedManager] setUpdatePaymentStatus:NO];
        switch ([resultDic[@"resultStatus"] intValue]) {
            case 9000:/**< 订单支付成功    */
                self.pay_stat = 1;
                [self orderCheck:1 result_info:resultDic[@"result"]];
                break;
                
            case 8000:/**< 正在处理中，支付结果未知（有可能已经支付成功），请查询商户订单列表中订单的支付状态    */
                self.pay_stat = 1;
                [self orderCheck:0 result_info:resultDic[@"result"]];
            break;
                
            default:{
                self.pay_stat = 0;
                [self orderGet];
                break;
            }
        }
    };
}

- (void)setupNavView{
    [super setupNavView];
    self.navView.backgroundColor = [QFTools colorWithHexString:MainColor];
    self.navView.showBottomLabel = NO;
    [self.navView.centerButton setTitle: _type == 0?@"待支付": @"订单详情"forState:UIControlStateNormal];
    @weakify(self);
    [self.navView.leftButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    self.navView.leftButtonBlock = ^{
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    };
}

-(void)setupTableView{
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, navHeight, ScreenWidth, ScreenHeight - navHeight)];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.bounces = NO;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    [_tableView registerClass:[OrderDetailTableViewCell class] forCellReuseIdentifier:@"OrderDetailTableViewCell"];
    [self.view addSubview:_tableView];
    
    if (_model.stat == 0 && _model.pay_stat == 0) {
        _tableView.height = ScreenHeight - navHeight - 60;
    }else{
        _tableView.height = ScreenHeight - navHeight;
    }
}

#pragma mark -- TableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (_type) {
        case 0:
            if ([self.showDic objectForKey:@"pay"]) {
                
                return 625 + [_model.commodities.firstObject items].count*55 + 40 + 45*2;
            }else{
                
                return 625 + [_model.commodities.firstObject items].count*55 + 40;
            }
            break;
        case 1:
            return 625 + [_model.commodities.firstObject items].count*55 - 164;
            break;
        default:
            break;
    }
    
    return 625 + [_model.commodities.firstObject items].count*55;
    
//    return [tableView fd_heightForCellWithIdentifier:@"OrderDetailTableViewCell" cacheByIndexPath:indexPath configuration:^(OrderDetailTableViewCell *cell) {
//
//    }];
    
}

- ( void )tableView:( UITableView  *)tableView  willDisplayCell :( UITableViewCell  *)cell  forRowAtIndexPath :( NSIndexPath  *)indexPath{
    
    cell.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section{
    
    view.backgroundColor = [UIColor whiteColor];
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section{
    
    view.backgroundColor = [UIColor whiteColor];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    OrderDetailTableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:@"OrderDetailTableViewCell"];
    cell.selectionStyle =  UITableViewCellSelectionStyleNone;
    [cell setOrderInfo:_model type:_type];
    @weakify(self);
    cell.updateCellHeight = ^(BOOL update) {
        @strongify(self);
        
        NSString *key = @"pay";
        if (![self.showDic objectForKey:key]) {
            [self.showDic setObject:@"1" forKey:key];
        }else{
            [self.showDic removeObjectForKey:key];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
        
//        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:0 inSection:0],nil] withRowAnimation:UITableViewRowAnimationFade];
        //[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
        
    };
    
    cell.selectPayChannel = ^(NSInteger code) {
        @strongify(self);
        self.payChannel = code;
        
        switch (code) {
            case 0:
                self.model.pay_channel = 4;
                break;
            case 1:
                self.model.pay_channel = 3;
            break;
            case 2:
                self.model.pay_channel = 1;
                break;
            default:
                break;
        }
        
    };
    
    return cell;
    
}

-(void)dealloc{
    [_monitorTime invalidate];
    _monitorTime = nil;
}

@end
