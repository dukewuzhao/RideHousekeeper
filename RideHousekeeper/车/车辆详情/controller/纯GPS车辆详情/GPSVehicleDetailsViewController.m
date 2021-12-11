//
//  GPSVehicleDetailsViewController.m
//  RideHousekeeper
//
//  Created by Apple on 2019/10/30.
//  Copyright © 2019 Duke Wu. All rights reserved.
//

#import "GPSVehicleDetailsViewController.h"
#import "GPSDetailViewController.h"
#import "nameTextFiledController.h"
#import "BindingUserViewController.h"
#import "MultipleBindingLogicProcessingViewController.h"
#import "ExtendGPSServerViewController.h"
#import "BikeNameTableViewCell.h"
#import "bikeFunctionTableViewCell.h"
#import "GPSAllotedTimeTableViewCell.h"
#import "SearchBleModel.h"
#import "Manager.h"
@interface GPSVehicleDetailsViewController ()<UITableViewDataSource,UITableViewDelegate,BindingUserViewControllerDelegate,ManagerDelegate>
@property (nonatomic, strong)BikeModel *bikeModel;
@property (nonatomic, strong)BrandModel *brandModel;
@property (nonatomic, strong)PeripheralModel *deviceModel;
@property (nonatomic, strong)PerpheraServicesInfoModel *servicesModel;
@property (nonatomic, strong)UITableView *GPSDetailList;
@end

@implementation GPSVehicleDetailsViewController

-(void)setBikeid:(NSInteger)bikeid{
    _bikeid = bikeid;
    NSMutableArray *bikemodals = [LVFmdbTool queryBikeData:[NSString stringWithFormat:@"SELECT * FROM bike_modals WHERE bikeid LIKE '%zd'", bikeid]];
    _bikeModel = bikemodals.firstObject;
    NSMutableArray *brandmodals = [LVFmdbTool queryBrandData:[NSString stringWithFormat:@"SELECT * FROM brand_modals WHERE bikeid LIKE '%zd'", _bikeid]];
    _brandModel = brandmodals.firstObject;
    
    _deviceModel = [[LVFmdbTool queryPeripheraData:[NSString stringWithFormat:@"SELECT * FROM periphera_modals WHERE type LIKE '%zd' AND bikeid LIKE '%zd'", 4,_bikeid]] firstObject];
    
    if (_deviceModel.is_used == 1) {
        _servicesModel = [[LVFmdbTool queryPerpheraServicesInfoData:[NSString stringWithFormat:@"SELECT * FROM peripheraServicesInfo_modals WHERE type LIKE '%zd' AND bikeid LIKE '%zd'", 1,_bikeid]] firstObject];
    }else if (_deviceModel.is_used == 2){
        _servicesModel = [[LVFmdbTool queryPerpheraServicesInfoData:[NSString stringWithFormat:@"SELECT * FROM peripheraServicesInfo_modals WHERE type LIKE '%zd' AND bikeid LIKE '%zd'", 0,_bikeid]] firstObject];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[Manager shareManager] addDelegate:self];
    [self setupNavView];
    [self setuplistView];
    
    UIButton *UnbundBtn = [[UIButton alloc] initWithFrame:CGRectMake(80, ScreenHeight - 60, ScreenWidth - 160, 45)];
    UnbundBtn.backgroundColor = [QFTools colorWithHexString:MainColor];
    [UnbundBtn setTitle:@"解绑车辆" forState:UIControlStateNormal];
    UnbundBtn.titleLabel.font = FONT_PINGFAN(15);
    [UnbundBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    UnbundBtn.backgroundColor = [QFTools colorWithHexString:MainColor];
    [UnbundBtn.layer setCornerRadius:10.0];
    [self.view addSubview:UnbundBtn];
    
    @weakify(self);
    [[UnbundBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        
            MultipleBindingLogicProcessingViewController *multipleUbBindingLogicVc = [[MultipleBindingLogicProcessingViewController alloc] init];
            [multipleUbBindingLogicVc showView:UnbindingSingelGPS :nil :self.bikeid];
            [self.navigationController pushViewController:multipleUbBindingLogicVc animated:YES];
        }];
}

- (void)setupNavView{
    [super setupNavView];
    self.navView.showBottomLabel = NO;
    [self.navView.centerButton setTitle:_bikeModel.bikename forState:UIControlStateNormal];
    @weakify(self);
    [self.navView.leftButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    self.navView.leftButtonBlock = ^{
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    };
}

-(void)setuplistView{
    
    _GPSDetailList = [[UITableView alloc] initWithFrame:CGRectMake(0, navHeight, ScreenWidth, ScreenHeight - navHeight)];
    _GPSDetailList.backgroundColor = [QFTools colorWithHexString:@"#F5F5F5"];
    _GPSDetailList.delegate = self;
    _GPSDetailList.dataSource = self;
    _GPSDetailList.bounces = NO;
    [_GPSDetailList setSeparatorColor:[QFTools colorWithHexString:SeparatorColor]];
    [_GPSDetailList setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    [self.view addSubview:_GPSDetailList];
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        
        return ScreenHeight *.13 + 5;
    }else if (indexPath.row == 4){
        return 105;
    }else {
        return 50;
    }
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
- (void)tableView:( UITableView  *)tableView  willDisplayCell :( UITableViewCell  *)cell  forRowAtIndexPath :( NSIndexPath  *)indexPath{
    
    cell.backgroundColor = CellColor;
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section{
    
    view.tintColor = [QFTools colorWithHexString:@"#cccccc"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        BikeNameTableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:@"nameCell"];
        if (!cell) {
            cell = [[BikeNameTableViewCell alloc] initWithStyle:0 reuseIdentifier:@"nameCell"];
        }
        cell.bikeimage.image = [UIImage imageNamed:@"default_logo"];
        cell.nameLab.text = _bikeModel.bikename;
        cell.usericon.image = [UIImage imageNamed:@"smalluserIcon"];
        [cell.modifyBtn setImage:[UIImage imageNamed:@"pen"] forState:UIControlStateNormal];
        NSString* text = _bikeModel.ownerphone;
        cell.phone.text = [QFTools replaceStringWithAsterisk:text startLocation:3 lenght:text.length -7];
        
        UIButton * modifyBtn = cell.modifyBtn;
        [modifyBtn addTarget:self action:@selector(modifyBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }else if (indexPath.row == 4) {
        
        GPSAllotedTimeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GPSAllotedTimeTableViewCell"];
        if (!cell) {
            cell = [[GPSAllotedTimeTableViewCell alloc] initWithStyle:0 reuseIdentifier:@"GPSAllotedTimeTableViewCell"];
        }
        cell.activationTimeLab.text = _servicesModel.begin_date;
        cell.lastDateLab.text = [NSString stringWithFormat:@"%d天",_servicesModel.left_days];
        @weakify(self);
        cell.renewalFeeBtnClick = ^{
            @strongify(self);
            ExtendGPSServerViewController *extendVc = [[ExtendGPSServerViewController alloc] init];
            extendVc.bikeId = self.bikeid;
            [self.navigationController pushViewController:extendVc animated:YES];
        };
        return cell;
    }else {
        bikeFunctionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"bikeFunctionTableViewCell"];
        if (!cell) {
            cell = [[bikeFunctionTableViewCell alloc] initWithStyle:0 reuseIdentifier:@"bikeFunctionTableViewCell"];
        }
        cell.upgrade_red_dot.hidden = YES;
        UIImageView *icon = cell.Icon;
        UILabel *name = cell.nameLab;
        UILabel *detailLab = cell.detailLab;
        
        if (indexPath.row == 1) {
            icon.image = [UIImage imageNamed:@"icon_p1"];
            name.text = @"车辆品牌";
            detailLab.text = [NSString stringWithFormat:@"%@",_brandModel.brandname];
            cell.arrow.hidden = YES;
        }else if (indexPath.row == 2){
            cell.arrow.hidden = NO;
            icon.image = [UIImage imageNamed:@"icon_p2"];
            name.text = @"车辆分享";
            detailLab.text = [NSString stringWithFormat:@"%d",_bikeModel.bindedcount];
        }else if (indexPath.row == 3){
            cell.arrow.hidden = NO;
            icon.image = [UIImage imageNamed:@"icon_GPS"];
            name.text = @"定位装置";
        }
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
        
    if (indexPath.row == 2) {
        
        BindingUserViewController *bindingVc = [BindingUserViewController new];
        bindingVc.bikeid = _bikeid;
        bindingVc.delegate = self;
        [self.navigationController pushViewController:bindingVc animated:YES];
    }else if (indexPath.row == 3){
        
        NSMutableArray *bikemodals = [LVFmdbTool queryBikeData:[NSString stringWithFormat:@"SELECT * FROM bike_modals WHERE bikeid LIKE '%zd'", self.bikeid]];
        _bikeModel = bikemodals.firstObject;
        NSMutableArray *brandmodals = [LVFmdbTool queryBrandData:[NSString stringWithFormat:@"SELECT * FROM brand_modals WHERE bikeid LIKE '%zd'", _bikeid]];
        _brandModel = brandmodals.firstObject;
        
        _deviceModel = [[LVFmdbTool queryPeripheraData:[NSString stringWithFormat:@"SELECT * FROM periphera_modals WHERE type LIKE '%zd' AND bikeid LIKE '%zd'", 4,_bikeid]] firstObject];
        
        GPSDetailViewController *GPSDetailVc = [GPSDetailViewController new];
        [GPSDetailVc setpGPSParameters:_bikeModel :_deviceModel.deviceid];
        [self.navigationController pushViewController:GPSDetailVc animated:YES];
    }
}

- (void)modifyBtnClick:(UIButton *)btn{

    if (_bikeModel.ownerflag == 0) {
        
        [SVProgressHUD showSimpleText:@"子用户无此权限"];
        return;
    }
    
    nameTextFiledController * nameText = [nameTextFiledController new];
    nameText.deviceNum = _bikeid;
    [self.navigationController pushViewController:nameText animated:NO];
}

#pragma mark - BindingUserViewControllerDelegate
-(void)UpdateUsernumberSuccess{
    
    [_GPSDetailList reloadSections:[[NSIndexSet alloc]initWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - ManagerDelegate
-(void)manager:(Manager *)manager updatebikeName:(NSString *)name :(NSInteger)bikeId{
    
    [self.navView.centerButton setTitle:name forState:UIControlStateNormal];
    NSMutableArray *bikemodals = [LVFmdbTool queryBikeData:[NSString stringWithFormat:@"SELECT * FROM bike_modals WHERE bikeid LIKE '%zd'", bikeId]];
    _bikeModel = bikemodals.firstObject;
    [_GPSDetailList reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    
}

-(void)manager:(Manager *)manager updateGPSServiceInfo:(NSInteger)bikeid{
    
    
    _servicesModel = [[LVFmdbTool queryPerpheraServicesInfoData:[NSString stringWithFormat:@"SELECT * FROM peripheraServicesInfo_modals WHERE type LIKE '%zd' AND bikeid LIKE '%zd'", 1,bikeid]] firstObject];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.GPSDetailList reloadData];
    });
}

-(void)dealloc{
    [[Manager shareManager] deleteDelegate:self];
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
