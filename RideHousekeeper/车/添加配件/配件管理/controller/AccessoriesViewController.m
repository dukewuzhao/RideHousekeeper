//
//  AccessoriesViewController.m
//  RideHousekeeper
//
//  Created by smartwallit on 16/7/14.
//  Copyright © 2016年 Duke Wu. All rights reserved.
//

#import "AccessoriesViewController.h"
#import "GPSDetailViewController.h"
#import "SmartCentralViewController.h"
#import "TwoDimensionalCodecanViewController.h"
#import "ExtendGPSServerViewController.h"
#import "CustomFlowLayout.h"
#import "SmartAccessoriesListTableViewCell.h"
#import "CenterControlTableViewCell.h"
#import "GPSTableViewCell.h"
#import "AccessoriesModel.h"
#import "Manager.h"
@interface AccessoriesViewController ()<UITableViewDelegate,UITableViewDataSource,ManagerDelegate>
@property (nonatomic, strong) UITableView *AccessoriesView;
@property(nonatomic,assign) NSInteger deviceid;
@property (strong, nonatomic) NSMutableArray *peripheraAry;
@property (strong, nonatomic) BikeModel *bikeModel;
@property (strong, nonatomic) BrandModel *brandModel;

@end

@implementation AccessoriesViewController

- (void)setDeviceNum:(NSInteger)deviceNum{
    _deviceNum = deviceNum;
    NSMutableArray *bikemodals = [LVFmdbTool queryBikeData:[NSString stringWithFormat:@"SELECT * FROM bike_modals WHERE bikeid LIKE '%zd'", deviceNum]];
    _bikeModel = bikemodals.firstObject;
    
    NSMutableArray *brandmodals = [LVFmdbTool queryBrandData:[NSString stringWithFormat:@"SELECT * FROM brand_modals WHERE bikeid LIKE '%zd'", deviceNum]];
    _brandModel = brandmodals.firstObject;
    
    _peripheraAry = [LVFmdbTool queryPeripheraData:[NSString stringWithFormat:@"SELECT * FROM periphera_modals WHERE type LIKE '%zd' AND bikeid LIKE '%zd'", 4,deviceNum]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[Manager shareManager] addDelegate:self];
    [self setupNavView];
    
    [self setupMainview];
}

- (void)setupNavView{
    [super setupNavView];
    self.navView.showBottomLabel = NO;
    [self.navView.centerButton setTitle:@"配件管理" forState:UIControlStateNormal];
    @weakify(self);
    [self.navView.leftButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    self.navView.leftButtonBlock = ^{
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    };
}

-(void)setupMainview{
    
    _AccessoriesView = [[UITableView alloc] initWithFrame:CGRectMake(0, navHeight, ScreenWidth, ScreenHeight - navHeight)];
    _AccessoriesView.delegate = self;
    _AccessoriesView.dataSource = self;
    _AccessoriesView.bounces = NO;
    _AccessoriesView.backgroundColor = [UIColor clearColor];
    _AccessoriesView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_AccessoriesView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    [self.view addSubview:_AccessoriesView];
}

#pragma mark -- TableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
    
    if (_bikeModel.gps_func == 1) {
        return 3;
    }
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        
        if (_bikeModel.tpm_func == 1) {
            return 260;
        }else{
            return 130;
        }
        
    }else if (indexPath.section == 2){
        return 180;
    }
    return 170;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *headerView = [UIView new];
    return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    UIView *footerView = [UIView new];
    return footerView;
}

- (void)tableView:( UITableView  *)tableView  willDisplayCell :( UITableViewCell  *)cell  forRowAtIndexPath :( NSIndexPath  *)indexPath{
    
    cell.backgroundColor = [UIColor clearColor];
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section{
    
    view.tintColor = [QFTools colorWithHexString:@"#ebecf2"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        SmartAccessoriesListTableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:@"SmartAccessoriesCell"];
        if (!cell) {
            cell = [[SmartAccessoriesListTableViewCell alloc] initWithStyle:0 reuseIdentifier:@"SmartAccessoriesCell"];
        }
        cell.bikeid = _deviceNum;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }else if (indexPath.section == 1){
        CenterControlTableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:@"CenterControlTableViewCell"];
        if (!cell) {
            cell = [[CenterControlTableViewCell alloc] initWithStyle:0 reuseIdentifier:@"CenterControlTableViewCell"];
        }
            cell.title.text = @"智能中控";
            cell.deviceDesc.text = @"骑管家智能中控";
        cell.brandLab.text = _bikeModel.bikename;
            cell.icon.image = [UIImage imageNamed:@"icon_control_real"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }else{
        GPSTableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:@"GPSTableViewCell"];
        if (!cell) {
            cell = [[GPSTableViewCell alloc] initWithStyle:0 reuseIdentifier:@"GPSTableViewCell"];
        }
        [cell setBikeModel:_bikeModel brandModel:_brandModel peripheraAry:[_peripheraAry copy]];
        cell.title.text = @"定位装置";
        cell.icon.image = [UIImage imageNamed:@"icon_gps_real"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        @weakify(self);
        cell.rechargeBtnClick = ^{
            @strongify(self);
            ExtendGPSServerViewController *extendVc = [[ExtendGPSServerViewController alloc] init];
            extendVc.bikeId = self.deviceNum;
            [self.navigationController pushViewController:extendVc animated:YES];
        };
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.section == 1) {
        
        SmartCentralViewController *vc = [[SmartCentralViewController alloc] init];
        [vc setpGPSParameters:_bikeModel];
        [self.navigationController pushViewController:vc animated:YES];
    }else if (indexPath.section == 2){
        if (_peripheraAry.count == 0) {
            TwoDimensionalCodecanViewController *scanVc = [[TwoDimensionalCodecanViewController alloc] init];
            scanVc.naVtitle = @"添加配件";
            scanVc.bikeid = _deviceNum;
            scanVc.type = 4;
            scanVc.seq = 0;
            [self.navigationController pushViewController:scanVc animated:YES];
            return;
        }
        PeripheralModel *model = _peripheraAry.firstObject;
        GPSDetailViewController *gpsVc = [[GPSDetailViewController alloc] init];
        [gpsVc setpGPSParameters:_bikeModel :model.deviceid];
        [self.navigationController pushViewController:gpsVc animated:YES];
    }

}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    [self.view endEditing:YES];
}

#pragma mark - ManagerDelegate
-(void)manager:(Manager *)manager bindingPeripheralSucceeded:(PeripheralModel *)model{
    
    [self setDeviceNum:model.bikeid];
    [_AccessoriesView reloadData];
}

-(void)manager:(Manager *)manager deletePeripheralSucceeded:(PeripheralModel *)model{
    
    [self setDeviceNum:model.bikeid];
    [_AccessoriesView reloadData];
}

-(void)manager:(Manager *)manager updateGPSServiceInfo:(NSInteger)bikeid{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_AccessoriesView reloadData];
    });
    
}

-(void)dealloc{
    
    [[Manager shareManager] deleteDelegate:self];
}
 
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
