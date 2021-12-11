//
//  ProductDetailsViewController.m
//  RideHousekeeper
//
//  Created by Apple on 2020/3/12.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import "ProductDetailsViewController.h"
#import "ConfirmOrderUIViewController.h"
#import "HeadPriceTableViewCell.h"
#import "MiddleProductInformationTableViewCell.h"
#import "BottomUserReminderTableViewCell.h"

@interface ProductDetailsViewController ()< UITableViewDelegate, UITableViewDataSource>
@property(nonatomic,strong) UITableView *tableView;
@property(nonatomic,strong) ServiceCommoity *model;
@property(nonatomic,strong) ServiceOrder *serviceOrder;
@property(nonatomic,strong) DeviceInfoModel *deviceModel;
@property(nonatomic,strong) ServiceCard *serviceCard;
@property(nonatomic,assign) NSInteger bikeId;
@property(nonatomic,assign) NSInteger type;
@end

@implementation ProductDetailsViewController

-(void)setCommodityInfo:(ServiceCommoity *)model bikeid:(NSInteger)bikeid{
    _model = model;
    _bikeId = bikeid;
    _type = 1;
}

-(void)setRechargeCardNo:(NSString *)code bikeid:(NSInteger)bikeid{
    _bikeId = bikeid;
    _type = 2;
    [self getServiceCard:code];
}

-(void)getServiceCard:(NSString *)card_no{
    
    NSString *token = [QFTools getdata:@"token"];
    NSString *URLString = [NSString stringWithFormat:@"%@%@",QGJURL,@"app/service/card/get"];
    NSDictionary *parameters = @{@"token":token, @"card_no": card_no,@"bike_id": @(_bikeId)};
    [[HttpRequest sharedInstance] postWithURLString:URLString parameters:parameters success:^(id _Nullable dict) {
        
        if ([dict[@"status"] intValue] == 0) {
            NSDictionary *data = dict[@"data"];
            _serviceCard = [ServiceCard yy_modelWithDictionary:data[@"card"]];
            [self rechargeCardOrderplaceCommodities:card_no];
        }else{
            [[LoadView sharedInstance] hide];
            [SVProgressHUD showSimpleText:dict[@"status_info"]];
        }
        
    }failure:^(NSError *error) {
        NSLog(@"error :%@",error);
        [[LoadView sharedInstance] hide];
        [SVProgressHUD showSimpleText:TIP_OF_NO_NETWORK];
    }];
    
}

-(void)rechargeCardOrderplaceCommodities:(NSString *)card_no{
    NSString *token = [QFTools getdata:@"token"];
    NSNumber * bike_id = @(_bikeId);
    NSString *URLString = [NSString stringWithFormat:@"%@%@",QGJURL,@"app/service/order/pay_by_card"];
    NSDictionary *parameters = @{@"token":token,@"bike_id":bike_id,@"card_no":card_no};
    
    [[HttpRequest sharedInstance] postWithURLString:URLString parameters:parameters success:^(id _Nullable dict) {
        
        if ([dict[@"status"] intValue] == 0) {
            
            NSDictionary *data = dict[@"data"];
            _serviceOrder = [ServiceOrder yy_modelWithDictionary:data[@"order"]];
            _model = _serviceOrder.commodities.firstObject;
            [self.navView.centerButton setTitle:_model.title forState:UIControlStateNormal];
            dispatch_async(dispatch_get_main_queue(), ^{
                [_tableView reloadData];
            });
        }else{
            [SVProgressHUD showSimpleText:dict[@"status_info"]];
        }
        
    }failure:^(NSError *error) {
        [SVProgressHUD showSimpleText:TIP_OF_NO_NETWORK];
        NSLog(@"error :%@",error);
        
    }];
}


-(void)setServiceTransferCode:(NSString *)code bikeid:(NSInteger)bikeid{
    _bikeId = bikeid;
    _type = 3;
    [self getServiceTransferId:code];
}

-(void)getServiceTransferId:(NSString *)code{
    
    NSString *codeName = code;
    NSString *token = [QFTools getdata:@"token"];
    NSString *URLString = [NSString stringWithFormat:@"%@%@",QGJURL,@"app/checkdevice"];
    NSDictionary *parameters = @{@"token": token, @"sn":codeName, @"bike_id":@(_bikeId) };
    
    [[HttpRequest sharedInstance] postWithURLString:URLString parameters:parameters success:^(id _Nullable dict) {
        
        if ([dict[@"status"] intValue] == 0) {
            
            NSDictionary *devicedata = dict[@"data"];
            _deviceModel = [DeviceInfoModel yy_modelWithDictionary:devicedata[@"device_info"]];
            [self getOrderTrans_entityInfo:_deviceModel.device_id];
        }else{
            [SVProgressHUD showSimpleText:dict[@"status_info"]];
        }
    }failure:^(NSError *error) {
        
        NSLog(@"error :%@",error);
        [SVProgressHUD showSimpleText:TIP_OF_NO_NETWORK];
    }];
}

-(void)getOrderTrans_entityInfo:(NSInteger)deviceId{
    
    NSString *token = [QFTools getdata:@"token"];
    NSNumber * bike_id = @(_bikeId);
    NSString *URLString = [NSString stringWithFormat:@"%@%@",QGJURL,@"app/service/order/trans_entity"];
    NSDictionary *parameters = @{@"token":token,@"bike_id":bike_id,@"trans_from_id":@(deviceId),@"is_pay":@(0)};
    
    [[HttpRequest sharedInstance] postWithURLString:URLString parameters:parameters success:^(id _Nullable dict) {
        
        if ([dict[@"status"] intValue] == 0) {
            
            NSDictionary *data = dict[@"data"];
            _serviceOrder = [ServiceOrder yy_modelWithDictionary:data[@"order"]];
            _model = _serviceOrder.commodities.firstObject;
            [self.navView.centerButton setTitle:_model.title forState:UIControlStateNormal];
            dispatch_async(dispatch_get_main_queue(), ^{
                [_tableView reloadData];
            });
        }else{
            [SVProgressHUD showSimpleText:dict[@"status_info"]];
        }
        
    }failure:^(NSError *error) {
        [SVProgressHUD showSimpleText:TIP_OF_NO_NETWORK];
        NSLog(@"error :%@",error);
    }];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupNavView];
    [self setupTableView];
}


- (void)setupNavView{
    [super setupNavView];
    self.navView.backgroundColor = [QFTools colorWithHexString:MainColor];
    self.navView.showBottomLabel = NO;
    [self.navView.centerButton setTitle:_model.title forState:UIControlStateNormal];
    @weakify(self);
    [self.navView.leftButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    self.navView.leftButtonBlock = ^{
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    };
}

-(void)setupTableView{
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, navHeight, ScreenWidth, ScreenHeight - navHeight) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    //_rechargeTable.bounces = NO;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //[_tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    [_tableView registerClass:[HeadPriceTableViewCell class] forCellReuseIdentifier:@"HeadPriceTableViewCell"];
    [_tableView registerClass:[MiddleProductInformationTableViewCell class] forCellReuseIdentifier:@"MiddleProductInformationTableViewCell"];
    [_tableView registerClass:[BottomUserReminderTableViewCell class] forCellReuseIdentifier:@"BottomUserReminderTableViewCell"];
    [self.view addSubview:_tableView];
    
    UIView *footview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 84)];
    footview.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:footview];
    _tableView.tableFooterView = footview;
    
    UIButton *buyBtn = [[UIButton alloc] init];
    buyBtn.layer.cornerRadius = 22;
    buyBtn.backgroundColor = [QFTools colorWithHexString:@"#06C1AE"];
    
    if (_type == 1) {
        [buyBtn setTitle:@"立即购买" forState:UIControlStateNormal];
    }else if (_type == 2){
        [buyBtn setTitle:@"立即兑换" forState:UIControlStateNormal];
    }else if (_type == 3){
        [buyBtn setTitle:@"立即转移" forState:UIControlStateNormal];
    }
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
        
        switch (self.type) {
            case 1:
                [self orderplaceCommodities:@[@(self.model.ID)]];
                break;
            case 2:{
                ConfirmOrderUIViewController *ConfirmOrderVc = [[ConfirmOrderUIViewController alloc] init];
                [ConfirmOrderVc setCommodityInfo:self.serviceOrder deviceInfo:self.deviceModel serviceCardInfo:self.serviceCard  type:self.type bikeid:self.bikeId];
                [self.navigationController pushViewController:ConfirmOrderVc animated:YES];
                break;
            }
            case 3:{
                ConfirmOrderUIViewController *ConfirmOrderVc = [[ConfirmOrderUIViewController alloc] init];
                [ConfirmOrderVc setCommodityInfo:self.serviceOrder deviceInfo:self.deviceModel serviceCardInfo:self.serviceCard  type:self.type bikeid:self.bikeId];
                [self.navigationController pushViewController:ConfirmOrderVc animated:YES];
                break;
            }
            default:
                break;
        }
    }];
}

-(void)orderplaceCommodities:(NSArray *)commodities{
    NSString *token = [QFTools getdata:@"token"];
    NSNumber * bike_id = @(_bikeId);
    NSString *URLString = [NSString stringWithFormat:@"%@%@",QGJURL,@"app/service/order/place"];
    NSDictionary *parameters = @{@"token":token,@"bike_id":bike_id,@"commodities":commodities};
    
    [[HttpRequest sharedInstance] postWithURLString:URLString parameters:parameters success:^(id _Nullable dict) {
        
        if ([dict[@"status"] intValue] == 0) {
            
            NSDictionary *data = dict[@"data"];
            NSDictionary *order = data[@"order"];
            ServiceOrder *orderModel = [ServiceOrder yy_modelWithDictionary:order];
            ConfirmOrderUIViewController *ConfirmOrderVc = [[ConfirmOrderUIViewController alloc] init];
            [ConfirmOrderVc setCommodityInfo:orderModel deviceInfo:self.deviceModel serviceCardInfo:self.serviceCard  type:self.type bikeid:self.bikeId];
            [self.navigationController pushViewController:ConfirmOrderVc animated:YES];
            
        }else{
            [SVProgressHUD showSimpleText:dict[@"status_info"]];
        }
        
    }failure:^(NSError *error) {
        [SVProgressHUD showSimpleText:TIP_OF_NO_NETWORK];
        NSLog(@"error :%@",error);
        
    }];
}

#pragma mark -- TableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
    
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 1) {
        return _model.items.count;
    }
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        return [tableView fd_heightForCellWithIdentifier:@"HeadPriceTableViewCell" cacheByIndexPath:indexPath configuration:^(HeadPriceTableViewCell *cell) {

        }];
    }else if (indexPath.section == 1){
        return [tableView fd_heightForCellWithIdentifier:@"MiddleProductInformationTableViewCell" cacheByIndexPath:indexPath configuration:^(MiddleProductInformationTableViewCell *cell) {

        }];
    }else{
        return [tableView fd_heightForCellWithIdentifier:@"BottomUserReminderTableViewCell" cacheByIndexPath:indexPath configuration:^(BottomUserReminderTableViewCell *cell) {

        }];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *header = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 0.1)];
    
    if (section == 1) {
        header.height = 24;
        UILabel *textlab = [[UILabel alloc] init];
        textlab.font = FONT_PINGFAN(14);
        textlab.textColor = [QFTools colorWithHexString:@"#333333"];
        [header addSubview:textlab];
        [textlab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(header).offset(20);
            make.centerY.equalTo(header);
            make.height.mas_equalTo(20);
        }];
        textlab.text = @"服务包详情";
    }else if (section == 2){
        header.height = 24;
        UILabel *textlab = [[UILabel alloc] init];
        textlab.font = FONT_PINGFAN(14);
        textlab.textColor = [QFTools colorWithHexString:@"#333333"];
        [header addSubview:textlab];
        [textlab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(header).offset(20);
            make.centerY.equalTo(header);
            make.height.mas_equalTo(20);
        }];
        textlab.text = @"使用须知";
    }
    
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    
    if (section == 0) {
        return 0.1;
    }
    return 24;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    UIView *header = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 0.1)];
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return 0.1;
}

- ( void )tableView:( UITableView  *)tableView  willDisplayCell :( UITableViewCell  *)cell  forRowAtIndexPath :( NSIndexPath  *)indexPath{
    
    cell.backgroundColor = CellColor;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section{
    
    view.backgroundColor = [UIColor whiteColor];
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section{
    
    view.backgroundColor = [UIColor whiteColor];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        
        HeadPriceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HeadPriceTableViewCell"];
        cell.selectionStyle =  UITableViewCellSelectionStyleNone;
        TFHpple * doc = [[TFHpple alloc] initWithHTMLData:[_model.descriptions dataUsingEncoding:NSUTF8StringEncoding]];
        TFHppleElement *e = [doc peekAtSearchWithXPathQuery:@"//text()"];
        cell.titleLab.text = [e content];
        cell.currentPriceLab.text = [NSString stringWithFormat:@"¥%.1f",_model.actual_price/100.0];
        cell.originalPriceLab.text = [NSString stringWithFormat:@"¥%.1f",_model.price/100.0];
        return cell;
        
    }else if (indexPath.section == 1){
        
        MiddleProductInformationTableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:@"MiddleProductInformationTableViewCell"];
        cell.selectionStyle =  UITableViewCellSelectionStyleNone;
        ServiceItem *iteam = _model.items[indexPath.row];
        cell.durationLab.text = [NSString stringWithFormat:@"%d天",iteam.duration];
        cell.titleLab.text = iteam.title;
        TFHpple * doc = [[TFHpple alloc] initWithHTMLData:[iteam.descriptions dataUsingEncoding:NSUTF8StringEncoding]];
        TFHppleElement *e = [doc peekAtSearchWithXPathQuery:@"//text()"];
        cell.detailLab.text = [e content];
        return cell;
        
    }else{
        BottomUserReminderTableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:@"BottomUserReminderTableViewCell"];
        cell.selectionStyle =  UITableViewCellSelectionStyleNone;
        //cell.detailLab.text = @"";
        return cell;
    }
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
