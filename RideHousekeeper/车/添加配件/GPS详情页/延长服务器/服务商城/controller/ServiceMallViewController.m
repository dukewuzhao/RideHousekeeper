//
//  ServiceMallViewController.m
//  RideHousekeeper
//
//  Created by Apple on 2020/3/16.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import "ServiceMallViewController.h"
#import "RechargeRecordViewController.h"
#import "ShoppingTableViewCell.h"
#import "ProductDetailsViewController.h"
@interface ServiceMallViewController ()< UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) CommodityListModel *commodityModel;
@property (nonatomic, strong) BrandModel *brandModel;
@property (nonatomic, strong) UITableView *rechargeTable;
@end

@implementation ServiceMallViewController

- (void)setBikeId:(NSInteger)bikeId{
    _bikeId = bikeId;
    NSMutableArray *brandmodals = [LVFmdbTool queryBrandData:[NSString stringWithFormat:@"SELECT * FROM brand_modals WHERE bikeid LIKE '%zd'", bikeId]];
    _brandModel = brandmodals.firstObject;
    
}

-(void)getCommodityLlist{
    NSString *token = [QFTools getdata:@"token"];
    NSNumber *brand = @(_brandModel.brandid);
    NSString *URLString = [NSString stringWithFormat:@"%@%@",QGJURL,@"app/service/commodity/list"];
    NSDictionary *parameters = @{@"token":token,@"brand":brand};
    
    [[HttpRequest sharedInstance] postWithURLString:URLString parameters:parameters success:^(id _Nullable dict) {
        
        if ([dict[@"status"] intValue] == 0) {
            
            NSDictionary *data = dict[@"data"];
            self.commodityModel = [CommodityListModel yy_modelWithDictionary:data];
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.rechargeTable reloadData];
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
    [self getCommodityLlist];
}

- (void)setupNavView{
    [super setupNavView];
    self.navView.backgroundColor = [QFTools colorWithHexString:MainColor];
    self.navView.showBottomLabel = NO;
    [self.navView.centerButton setTitle:@"服务商城"forState:UIControlStateNormal];
    @weakify(self);
    [self.navView.leftButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    self.navView.leftButtonBlock = ^{
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    };
    
    [self.navView.rightButton setTitle:@"购买记录" forState:UIControlStateNormal];
    self.navView.rightButtonBlock = ^{
        @strongify(self);
        RechargeRecordViewController *recordVc = [[RechargeRecordViewController alloc] init];
        recordVc.bikeId = self.bikeId;
        [self.navigationController pushViewController:recordVc animated:YES];
    };
}

-(void)setupTableView{
    
    _rechargeTable = [[UITableView alloc] initWithFrame:CGRectMake(0, navHeight, ScreenWidth, ScreenHeight - navHeight) style:UITableViewStyleGrouped];
    _rechargeTable.delegate = self;
    _rechargeTable.dataSource = self;
    //_rechargeTable.bounces = NO;
    _rechargeTable.backgroundColor = [UIColor clearColor];
    _rechargeTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_rechargeTable setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    [self.view addSubview:_rechargeTable];
}

#pragma mark -- TableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.commodityModel.commodities.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 120.0f;
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
    textlab.text = @"GPS服务包";
    
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
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

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section{
    
    view.tintColor = [QFTools colorWithHexString:@"#cccccc"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ShoppingTableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:@"ShoppingTableViewCell"];
    if (!cell) {
        cell = [[ShoppingTableViewCell alloc] initWithStyle:0 reuseIdentifier:@"ShoppingTableViewCell"];
    }
    cell.selectionStyle =  UITableViewCellSelectionStyleNone;
    ServiceCommoity *model = self.commodityModel.commodities[indexPath.row];
    ServiceItem *item = model.items.firstObject;
    cell.mainTitle.text = [NSString stringWithFormat:@"%@-%d",model.title,item.duration] ;
    TFHpple * doc = [[TFHpple alloc] initWithHTMLData:[model.descriptions dataUsingEncoding:NSUTF8StringEncoding]];
    TFHppleElement *e = [doc peekAtSearchWithXPathQuery:@"//text()"];
    cell.usageLab.text = [e content];
    cell.currentPriceLab.text = [NSString stringWithFormat:@"¥%.1f",model.actual_price/100.0];
    cell.originalPriceLab.text = [NSString stringWithFormat:@"¥%.1f",model.price/100.0];
    cell.savePriceLab.text = [NSString stringWithFormat:@"立省%.1f元,1天低至%.1f元",(model.price - model.actual_price)/100.0,(model.price - model.actual_price)/(100.0 * item.duration)];
    @weakify(self);
    cell.clickBtn = ^{
        @strongify(self);
        ProductDetailsViewController *detailVc = [[ProductDetailsViewController alloc] init];
        [detailVc setCommodityInfo:model bikeid:self.bikeId];
        [self.navigationController pushViewController:detailVc animated:YES];
    };
    return cell;
    
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
