//
//  OrderCompleteViewController.m
//  RideHousekeeper
//
//  Created by Apple on 2020/3/16.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import "OrderCompleteViewController.h"
#import "OrderDetailViewController.h"
#import "SecondRechargeRecordTableViewCell.h"
#import "OrderListModel.h"
#import "RechargeRecordTableViewCell.h"
#import "PlaceholderView.h"

@interface OrderCompleteViewController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,assign) NSInteger offset;
@property(nonatomic,strong) OrderListModel *model;
@property(nonatomic,strong) UITableView *tableView;
@property(nonatomic,strong) NSMutableArray *serverOrderAry;
@end

@implementation OrderCompleteViewController

-(NSMutableArray *)serverOrderAry{
    if(!_serverOrderAry){
        _serverOrderAry = [NSMutableArray array];
    }
    return _serverOrderAry;
}

-(void)getOrderList:(NSInteger)offsetNum success:(void(^)())success{
    NSString *token = [QFTools getdata:@"token"];
    NSNumber * stat = @1;
    NSNumber * offset = @(offsetNum);
    NSString *URLString = [NSString stringWithFormat:@"%@%@",QGJURL,@"app/service/order/list"];
    NSDictionary *parameters = @{@"token":token,@"stat":stat,@"offset":offset};
    
    [[HttpRequest sharedInstance] postWithURLString:URLString parameters:parameters success:^(id _Nullable dict) {
        
        if ([dict[@"status"] intValue] == 0) {
            
            NSDictionary *data = dict[@"data"];
            _model = [OrderListModel yy_modelWithDictionary:data];
            [self.serverOrderAry addObjectsFromArray:_model.orders];
            _offset += _model.count;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }else{
            [SVProgressHUD showSimpleText:dict[@"status_info"]];
        }
        if (success) success();
    }failure:^(NSError *error) {
        [SVProgressHUD showSimpleText:TIP_OF_NO_NETWORK];
        NSLog(@"error :%@",error);
        if (success) success();
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [QFTools colorWithHexString:@"#F5F5F5"];
    [self setupTableView];
    [self getOrderList:0 success:^{
        
    }];
    @weakify(self);
    [[[NSNOTIC_CENTER rac_addObserverForName:KNOTIFICATION_UPDATEORDERLIST object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id x) {
        @strongify(self);
        [self.tableView.mj_header beginRefreshing];
    }];
}


-(void)setupTableView{
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    [_tableView registerClass:[RechargeRecordTableViewCell class] forCellReuseIdentifier:@"RechargeRecordTableViewCell"];
    [_tableView registerClass:[SecondRechargeRecordTableViewCell class] forCellReuseIdentifier:@"SecondRechargeRecordTableViewCell"];
    [self.view addSubview:_tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        //make.top.equalTo(self.view).offset(10);
        make.edges.equalTo(self.view);
    }];
    
    PlaceholderView *view = [[PlaceholderView alloc]initWithFrame:_tableView imageStr:@"icon_blank_order" title:@"" onTapView:^{
        
    }];
    _tableView.placeHolderView = view.middleView;
    @weakify(self);
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        @strongify(self);
        
        self.offset = 0;
        [self.serverOrderAry removeAllObjects];
        [self getOrderList:0 success:^{
            [self.tableView.mj_header endRefreshing];
            [self.tableView.mj_footer resetNoMoreData];
        }];
    }];
    // Set the ordinary state of animated images
    header.lastUpdatedTimeLabel.hidden = YES;
    _tableView.mj_header = header;
    
    MJRefreshBackNormalFooter *footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        @strongify(self);
        
        if (self.model.total > self.offset) {
            [self getOrderList:self.offset success:^{
                [self.tableView.mj_footer endRefreshing];
            }];
        }else{
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        }
    }];
    _tableView.mj_footer = footer;
}

#pragma mark -- TableView Delegate
//- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
//    
//    return 1;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.serverOrderAry.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 180;

}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *header = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 0.1)];
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
    return 0.1;
}

- ( void )tableView:( UITableView  *)tableView  willDisplayCell :( UITableViewCell  *)cell  forRowAtIndexPath :( NSIndexPath  *)indexPath{
    
    cell.backgroundColor = [QFTools colorWithHexString:@"#F5F5F5"];
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section{
    
    view.tintColor = [QFTools colorWithHexString:@"#cccccc"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([(ServiceOrder *)self.serverOrderAry[indexPath.row] commodities].count >1) {
        
        RechargeRecordTableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:@"RechargeRecordTableViewCell"];
        cell.selectionStyle =  UITableViewCellSelectionStyleNone;
        
        [cell setServiceOrderModel:self.serverOrderAry[indexPath.row] bikeID: _bikeId];
        cell.OrderProcessingCode = ^{
            
        };
        return cell;
    }else{
        
        SecondRechargeRecordTableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:@"SecondRechargeRecordTableViewCell"];
        cell.selectionStyle =  UITableViewCellSelectionStyleNone;
        
        [cell setServiceOrderModel:self.serverOrderAry[indexPath.row] bikeID: _bikeId];
        cell.OrderProcessingCode = ^{
            
        };
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    OrderDetailViewController *orderVc = [[OrderDetailViewController alloc] init];
    if ([(ServiceOrder *)self.serverOrderAry[indexPath.row] stat] == 0 && [(ServiceOrder *)self.serverOrderAry[indexPath.row] pay_stat] == 0) {
        [orderVc setOrderInfo:self.serverOrderAry[indexPath.row] bikeid:_bikeId type:0];
    }else{
        [orderVc setOrderInfo:self.serverOrderAry[indexPath.row] bikeid:_bikeId type:1];
    }
    [self.navigationController pushViewController:orderVc animated:YES];
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
