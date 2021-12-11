//
//  MultipleBindingLogicProcessingViewController.m
//  RideHousekeeper
//
//  Created by Apple on 2019/12/5.
//  Copyright © 2019 Duke Wu. All rights reserved.
//

#import "MultipleBindingLogicProcessingViewController.h"
#import "TwoDimensionalCodecanViewController.h"
#import "MultipleBindingLogicProcessingView.h"
#import "BLEScanPopview.h"
#import "BindingDeviceViewModel.h"
#import "UpdateViewModel.h"
#import "Manager.h"
#import "SearchBleModel.h"
#import "monitorBindingModel.h"
#import "DeviceConfigurationModel.h"
#import "UpdateViewModel.h"
#import "BikeStatusModel.h"
#import "AppDelegate+GetBikeList.h"
#import "NSObject+GPSDeactivation.h"
#import "monitorBindingModel.h"

@interface MultipleBindingLogicProcessingViewController ()
@property (nonatomic,assign) NSInteger bikeid;
@property (nonatomic,assign) ProcessingtType type;
@property(nonatomic,strong) DeviceInfoModel *deviceInfoModel;
@property (nonatomic,strong) MultipleBindingLogicProcessingView *headView;
@property(nonatomic,strong) BLEScanPopview *scanView;
@property (nonatomic,strong) BindingDeviceViewModel *bindingDeviceViewModel;
@property (nonatomic,strong) UpdateViewModel *updateModel;
@property(nonatomic,strong) monitorBindingModel *bindingListModel;
@property (nonatomic,assign) BindingType bindingType;
@end

@implementation MultipleBindingLogicProcessingViewController

-(BindingDeviceViewModel *)bindingDeviceViewModel{
    if (!_bindingDeviceViewModel) {
        _bindingDeviceViewModel = [[BindingDeviceViewModel alloc] init];
    }
    return _bindingDeviceViewModel;
}

-(UpdateViewModel *)updateModel{
    if (!_updateModel) {
        _updateModel = [[UpdateViewModel alloc] init];
    }
    return _updateModel;
}

-(BikeInfoModel *)bikeinfomodel{
    if (!_bikeinfomodel) {
        _bikeinfomodel = [BikeInfoModel new];
        _bikeinfomodel.brand_info = [BikeBrandInfoModel new];
        _bikeinfomodel.model_info = [BikeModelInfoModel new];
        _bikeinfomodel.model_info.model_id = 0;
        _bikeinfomodel.model_info.model_name = @"自定义";
        _bikeinfomodel.model_info.batt_type = 0;
        _bikeinfomodel.model_info.batt_vol = 0;
        _bikeinfomodel.model_info.wheel_size = 0;
    }
    return _bikeinfomodel;
}

-(BLEScanPopview *)scanView{
    
    if (!_scanView) {
        _scanView = [[BLEScanPopview alloc] initWithType:_bindingType];
        @weakify(self);
        self.scanView.bindingBikeClickBlock = ^(NSInteger index) {
            @strongify(self);
            [self bindBike:[self.bindingListModel.rssiList objectAtIndex:index] :self.type :self.bikeid :self.deviceInfoModel];
        };
    }
    return _scanView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupNavView];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)judgmentScanLogic:(ProcessingtType)type :(id)model :(NSInteger)bikeid{
    _bikeid = bikeid;
    _type = type;
    @weakify(self);
        NSString *mac = @"" ;
        switch (type) {
            case SingleGPSBinding:
                mac = [(DeviceInfoModel *)model mac];
                break;
            case DuplicateSingleGPSBinding:
                mac = [(DeviceInfoModel *)model mac];
            break;
            case AccessoriesGPSBinding:
                mac = [(DeviceInfoModel *)model mac];
                break;
            case DuplicateAccessoriesGPSBinding:
                mac = [(DeviceInfoModel *)model mac];
            break;
            case ECUKitWithGPS:
                mac = [(DeviceInfoModel*)model bind_mac];
            break;
            case GPSKitWithECU:
                mac = [(DeviceInfoModel *)model mac];
            break;
            
            case DuplicateGPSKitWithECU:
                mac = [(DeviceInfoModel *)model mac];
            break;
            
            case GPSKitWithOutECU:
                mac = [(DeviceInfoModel *)model mac];
            break;
            
            case DuplicateGPSKitWithOutECU:
                mac = [(DeviceInfoModel *)model mac];
            break;
            
            case DuplicateBindingKitWithGPS:
                mac = [(DeviceInfoModel *)model bind_mac];
            break;
            
            case ChangeGPS:
                mac = [(DeviceInfoModel *)model mac];
            break;
                
            case DuplicateChangeGPS:
                mac = [(DeviceInfoModel *)model mac];
            break;
                
            default:
                break;
        }
        
    [self.bindingDeviceViewModel startblescan:DeviceGPSType :mac :15 scanCallBack:^(id dict) {
            @strongify(self);
            if ([dict[@"status"] intValue] == 0) {
                    //扫描到设备
                if (type == SingleGPSBinding || type == DuplicateSingleGPSBinding) {
                    self.headView.operatingSubtitleLab.text = @"正在搜索当前车辆";
                    [self SingleGPSBindingOpreation:bikeid :(DeviceInfoModel *)model];
                }else if(type == AccessoriesGPSBinding || type == DuplicateAccessoriesGPSBinding){
                    [self AccessoriesGPSBindingOpreation:bikeid :(DeviceInfoModel *)model];
                }else if(type == ECUKitWithGPS){
                    [[LoadView sharedInstance] show];
                    [LoadView sharedInstance].protetitle.text = @"绑定车辆中";
                    [self kitWithGPSBindingOpreation:type :bikeid :(DeviceInfoModel *)model];
                }else if(type == DuplicateBindingKitWithGPS){
                    [[LoadView sharedInstance] show];
                    [LoadView sharedInstance].protetitle.text = @"绑定车辆中";
                    [self kitWithGPSBindingOpreation:type :bikeid :(DeviceInfoModel *)model];
                }else if(type == GPSKitWithECU || type == DuplicateGPSKitWithECU){
                    self.bikeinfomodel.device_info = [NSMutableArray arrayWithObject:(DeviceInfoModel *)model];
                    [self getDefaultBikeBrand:type :bikeid];
                }else if(type == ChangeGPS || type == DuplicateChangeGPS){
                    self.bikeinfomodel.mac = [(DeviceInfoModel *)model bind_mac];
                    self.bikeinfomodel.device_info = [NSMutableArray arrayWithObject:(DeviceInfoModel *)model];
                    [self changeDeviceGPS:type :bikeid :0];
                }
            }else{
                //未扫描到设备
                if (type == SingleGPSBinding || type == DuplicateSingleGPSBinding) {
                    [self.headView bindFailedWithCode:2];
                }else if(type == AccessoriesGPSBinding || type == DuplicateAccessoriesGPSBinding){
                    [self.headView bindFailedWithCode:2];
                }else if(type == ECUKitWithGPS){
                    [self.headView bindFailedWithCode:3];
                }else if(type == DuplicateBindingKitWithGPS){
                    [self.headView bindFailedWithCode:3];
                }else if(type == GPSKitWithECU || type == DuplicateGPSKitWithECU){
                    [self.headView bindFailedWithCode:1];
                }else if(type == ChangeGPS || type == DuplicateChangeGPS){
                    [self.headView bindFailedWithCode:2];
                }
                
            }
        } countDown:^(NSInteger num) {
            @strongify(self);
            if (type == SingleGPSBinding || type == DuplicateSingleGPSBinding) {
                self.headView.operatingSubtitleLab.text = [NSString stringWithFormat:@"正在搜索车辆定位器(%ds)...",num];
            }else if(type == AccessoriesGPSBinding || type == DuplicateAccessoriesGPSBinding){
                self.headView.operatingSubtitleLab.text = [NSString stringWithFormat:@"正在搜索车辆定位器(%ds)...",num];
            }else if(type == ECUKitWithGPS){
                self.headView.operatingSubtitleLab.text = [NSString stringWithFormat:@"正在搜索车辆定位器(%ds)...",num];
            }else if(type == DuplicateBindingKitWithGPS){
                self.headView.operatingSubtitleLab.text = [NSString stringWithFormat:@"正在搜索车辆定位器(%ds)...",num];
            }else if(type == GPSKitWithECU || type == DuplicateGPSKitWithECU){
                self.headView.operatingSubtitleLab.text = [NSString stringWithFormat:@"正在搜索车辆定位器(%ds)...",num];
            }else if(type == ChangeGPS || type == DuplicateChangeGPS){
                self.headView.operatingSubtitleLab.text = [NSString stringWithFormat:@"正在搜索车辆定位器(%ds)...",num];
            }
        }];
}


-(void)switchView:(ProcessingtType)type :(id)model :(NSInteger)bikeid{
    if (type == DuplicateBindingKitWithGPS) {
        [_headView switchScanGPSView];
        [self judgmentScanLogic:type :model :bikeid];
    }else if (type == ECUKitWithGPS){
        [_headView switchScanGPSView];
        [self judgmentScanLogic:type :model :bikeid];
    }else if (type == GPSKitWithECU || type == DuplicateGPSKitWithECU){
        [_headView switchScanGPSView];
        [self judgmentScanLogic:type :model :bikeid];
    }else if (type == SingleGPSBinding || type == DuplicateSingleGPSBinding){
        [_headView switchScanGPSView];
        [self judgmentScanLogic:type :model :bikeid];
    }else if (type == AccessoriesGPSBinding || type == DuplicateAccessoriesGPSBinding){
        [_headView switchScanGPSView];
        [self judgmentScanLogic:type :model :bikeid];
    }else if (type == ChangeGPS || type == DuplicateChangeGPS){
        [_headView switchChangeGPSView];
        [self judgmentScanLogic:type :model :bikeid];
    }
}

- (void)setupNavView{
    [super setupNavView];
    self.navView.backgroundColor = [UIColor whiteColor];
    self.navView.showBottomLabel = NO;
    
    if (_type == DuplicateChangeECU) {
        _bindingType = BindingChangeECU;
        [self.navView.centerButton setTitle:@"更换智能中控" forState:UIControlStateNormal];
        [self.navView.centerButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }else if (_type == ChangeGPS){
        _bindingType = BindingChangeGPS;
        [self.navView.centerButton setTitle:@"更换定位器" forState:UIControlStateNormal];
        [self.navView.centerButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }else if (_type == DuplicateChangeGPS){
        _bindingType = BindingChangeGPS;
        [self.navView.centerButton setTitle:@"更换定位器" forState:UIControlStateNormal];
        [self.navView.centerButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    
    @weakify(self);
    [self.navView.leftButton setImage:[UIImage imageNamed:@"icon_add_back"] forState:UIControlStateNormal];
    self.navView.leftButtonBlock = ^{
        @strongify(self);
        [self.navigationController popToRootViewControllerAnimated:YES];
    };
    
    if (_type == GPSKitWithECU || _type == DuplicateGPSKitWithECU || _type == GPSKitWithOutECU || _type == DuplicateGPSKitWithOutECU) {
        
        [self.navView.rightButton setTitle:@"直接绑定" forState:UIControlStateNormal];
        [self.navView.rightButton setTitleColor:[QFTools colorWithHexString:MainColor] forState:UIControlStateNormal];
        self.navView.rightButtonBlock = ^{
            @strongify(self);
            [CommandDistributionServices stopScan];
            self.headView.noGPSBindingBlock(2);
        };
        
    }
}

- (void)showView:(ProcessingtType)type :(id)model :(NSInteger)bikeid{
    if (_headView) {
        return;
    }
    _type = type;
    _bikeid = bikeid;
    _deviceInfoModel = (DeviceInfoModel *)model;
    _headView = [[MultipleBindingLogicProcessingView alloc] initWithType:type];
    [self.view addSubview:_headView];
    [_headView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.top.equalTo(self.view).offset(navHeight);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    
    @weakify(self);
    
    _headView.scanAgainBlock = ^(NSInteger code) {
        @strongify(self);
        [self switchView:type :model :bikeid];
    };
    
    _headView.scanSearchBlock = ^(NSInteger code) {
        //@strongify(self);
        switch (code) {
            case 3:
                //找不到GPS，扫码扫描新的GPS外设
            break;
            case 4:
                //无GPS属性套装，扫码扫描新的GPS外设
            break;
            default:
                
            break;
        }
    };
    
    _headView.noGPSBindingBlock = ^(NSInteger code) {
        @strongify(self);
        switch (code) {
            case 1:
                                
                [[LoadView sharedInstance] show];
                [LoadView sharedInstance].protetitle.text = @"绑定车辆中";
                [self.headView switchBindBikeView];
                [self getDefaultBikeBrand:type :bikeid];
                break;
            
            case 2:
                
                [[LoadView sharedInstance] show];
                [LoadView sharedInstance].protetitle.text = @"绑定车辆中";
                [self.headView switchBindBikeView];
                [self judgmentScanLogic:SingleGPSBinding :model :bikeid];
            break;
                
            case 3:
                [[LoadView sharedInstance] show];
                [LoadView sharedInstance].protetitle.text = @"绑定车辆中";
                [self.headView switchBindBikeView];
                [self getDefaultBikeBrand:type :bikeid];
                break;
            case 4:
                [[LoadView sharedInstance] show];
                [LoadView sharedInstance].protetitle.text = @"绑定车辆中";
                [self.headView switchBindBikeView];
                [self getDefaultBikeBrand:type :bikeid];
            break;
            default:
                break;
        }
    };
    
    _headView.footView.bindingBike = ^{
        @strongify(self);
        
        DW_AlertView *alertView = [[DW_AlertView alloc] initBackroundImage:nil Title:@"提示" contentString:@"强制绑定会清空车辆相关信息，建 议您请车主解绑后再绑定，确定要 强制绑定吗？" sureButtionTitle:@"强制绑定" cancelButtionTitle:@"再想想"];
        [alertView setSureBolck:^(BOOL clickStatu) {
            @strongify(self);
            if (type == DuplicateBindingKitWithGPS) {
                [self switchView:type :model :bikeid];
            }else if (type == DuplicateBindingWithOutGPS){
                [self.headView bindFailedWithCode:4];
            }else if (type == DuplicateBinding){
                [[LoadView sharedInstance] show];
                [LoadView sharedInstance].protetitle.text = @"绑定车辆中";
                [self.headView switchBindBikeView];
                [self getDefaultBikeBrand:type :bikeid];
            }else if (type == DuplicateChangeECU){
                [[LoadView sharedInstance] show];
                [LoadView sharedInstance].protetitle.text = @"更换中控中";
                [self.headView switchBindBikeView];
                [self getDefaultBikeBrand:type :bikeid];
            }else if (type == DuplicateChangeGPS){
                [self.headView switchChangeGPSView];
                [self judgmentScanLogic:type :model :bikeid];
            }else if (type == DuplicateSingleGPSBinding){
                [self.headView switchBindBikeView];
                [self judgmentScanLogic:type :model :bikeid];
            }
        }];
    };
    
    BikeModel *bikemodel = [LVFmdbTool queryBikeData:[NSString stringWithFormat:@"SELECT * FROM bike_modals WHERE bikeid LIKE '%zd'", bikeid]].firstObject;
    
    if (type == UnbindingBike || type == UnbindingGPS || type == UnbindingSingelGPS){
        
        if (bikemodel.ownerflag == 0) {
            
            _headView.footView.forcedUnbundBtn.hidden = YES;
        }
        
        if (type == UnbindingGPS) {
            self.headView.operatingPromptLab.text = @"正在解绑车辆定位器";
        } else {
            self.headView.operatingPromptLab.text = [NSString stringWithFormat:@"正在解绑%@",bikemodel.bikename];
        }
        
        NSMutableArray *peripheraModals = [LVFmdbTool queryPeripheraData:[NSString stringWithFormat:@"SELECT * FROM periphera_modals WHERE type LIKE '%zd' AND bikeid LIKE '%zd'", 4,bikeid]];
        if (peripheraModals.count == 0) {
            _headView.footView.forcedUnbundBtn.hidden = YES;
            _headView.unbindPromptLab.hidden = YES;
        }
    }
    
    _headView.footView.unbindBike = ^{
        @strongify(self);
        
        if (type == UnbindingBike) {
            if (bikemodel.ownerflag == 0) {
                DW_AlertView *alertView = [[DW_AlertView alloc] initBackroundImage:nil Title:@"提示" contentString:@"解绑将删除并清空车辆相关信息，仅保留车辆配件。" sureButtionTitle:@"解绑" cancelButtionTitle:@"再想想"];
                [alertView setSureBolck:^(BOOL clickStatu) {
                    @strongify(self);
                    [LoadView sharedInstance].protetitle.text = @"解绑车辆中";
                    [[LoadView sharedInstance] show];
                    [self UnbundBtnClick:bikeid type:2];
                }];
                return ;
            }
            
            DW_AlertView *alertView = [[DW_AlertView alloc] initBackroundImage:nil Title:@"提示" contentString:@"解绑将删除并清空车辆相关信息，仅保留车辆配件。" sureButtionTitle:@"解绑" cancelButtionTitle:@"再想想"];
            [alertView setSureBolck:^(BOOL clickStatu) {
                @strongify(self);
                [self UnbundBike:bikeid];
            }];
            
        }else if (type == UnbindingGPS){
            
            if (bikemodel.ownerflag == 0) {
                DW_AlertView *alertView = [[DW_AlertView alloc] initBackroundImage:nil Title:@"提示" contentString:@"解绑将删除并清空车辆相关信息，仅保留车辆配件。" sureButtionTitle:@"解绑" cancelButtionTitle:@"再想想"];
                [alertView setSureBolck:^(BOOL clickStatu) {
                    @strongify(self);
                    [LoadView sharedInstance].protetitle.text = @"删除配件中";
                    [[LoadView sharedInstance] show];
                    [self delateGPS:2 bikeid:bikeid];
                }];
                return ;
            }
            
            DW_AlertView *alertView = [[DW_AlertView alloc] initBackroundImage:nil Title:@"提示" contentString:@"解绑将删除并清空车辆相关信息，仅保留车辆配件。" sureButtionTitle:@"解绑" cancelButtionTitle:@"再想想"];
            [alertView setSureBolck:^(BOOL clickStatu) {
                @strongify(self);
                [self UnbundGPSAccessories:bikeid];
            }];
        }else if (type == UnbindingSingelGPS){
            
            if (bikemodel.ownerflag == 0) {
                DW_AlertView *alertView = [[DW_AlertView alloc] initBackroundImage:nil Title:@"提示" contentString:@"解绑将删除并清空车辆相关信息，仅保留车辆配件。" sureButtionTitle:@"解绑" cancelButtionTitle:@"再想想"];
                [alertView setSureBolck:^(BOOL clickStatu) {
                    @strongify(self);
                    [LoadView sharedInstance].protetitle.text = @"解绑车辆中";
                    [[LoadView sharedInstance] show];
                    [self UnbundBtnClick:bikeid type:2];
                }];
                return ;
            }
            
            DW_AlertView *alertView = [[DW_AlertView alloc] initBackroundImage:nil Title:@"提示" contentString:@"解绑将删除并清空车辆相关信息，仅保留车辆配件。" sureButtionTitle:@"解绑" cancelButtionTitle:@"再想想"];
            [alertView setSureBolck:^(BOOL clickStatu) {
                @strongify(self);
                [self UnbundSingelGPS:bikeid];
            }];
        }
        
    };
    
    _headView.footView.forceUnbind = ^{
        
        @strongify(self);
        if (type == UnbindingBike) {
            
            DW_AlertView *alertView = [[DW_AlertView alloc] initBackroundImage:nil Title:@"提示" contentString:@"强制解绑将删除并清空车辆相关信息，用户和车辆数据可能同步不及时。" sureButtionTitle:@"解绑" cancelButtionTitle:@"再想想"];
            [alertView setSureBolck:^(BOOL clickStatu) {
                @strongify(self);
                [LoadView sharedInstance].protetitle.text = @"解绑车辆中";
                [[LoadView sharedInstance] show];
                [self UnbundBtnClick:bikeid type:2];
            }];
            
        }else if (type == UnbindingGPS){
            DW_AlertView *alertView = [[DW_AlertView alloc] initBackroundImage:nil Title:@"提示" contentString:@"解绑将删除并清空车辆相关信息，仅保留车辆配件。" sureButtionTitle:@"解绑" cancelButtionTitle:@"再想想"];
            [alertView setSureBolck:^(BOOL clickStatu) {
                @strongify(self);
                [LoadView sharedInstance].protetitle.text = @"删除配件中";
                [[LoadView sharedInstance] show];
                [self delateGPS:2 bikeid:bikeid];
            }];
        }else if (type == UnbindingSingelGPS){
            DW_AlertView *alertView = [[DW_AlertView alloc] initBackroundImage:nil Title:@"提示" contentString:@"解绑将删除并清空车辆相关信息，仅保留车辆配件。" sureButtionTitle:@"解绑" cancelButtionTitle:@"再想想"];
            [alertView setSureBolck:^(BOOL clickStatu) {
                @strongify(self);
                [LoadView sharedInstance].protetitle.text = @"解绑车辆中";
                [[LoadView sharedInstance] show];
                [self UnbundBtnClick:bikeid type:2];
            }];
        }
        
    };
    
    
    if (type == SingleGPSBinding || type == AccessoriesGPSBinding || type == DuplicateAccessoriesGPSBinding || type == ECUKitWithGPS || type == ChangeGPS) {
        [self judgmentScanLogic:type :model :bikeid];
    }else if (type == GPSKitWithECU || type == DuplicateGPSKitWithECU || type == GPSKitWithOutECU || type == DuplicateGPSKitWithOutECU){
            
        self.bindingListModel=[[monitorBindingModel alloc]init];
        self.bindingListModel.rssiList=[NSMutableArray array];
        
        [RACObserve(self.bindingListModel, rssiList) subscribeNext:^(id x) {
            @strongify(self);
            NSArray *ary = [x copy];
            if (ary.count > 0) {
                [self.scanView showInView:self.view];
            }else{
                [self.scanView disMissView];
                self.scanView = nil;
            }
        }];
        //}
        [self GPSKitBindingOpreation:type :bikeid :model];
    }
}

-(void)SingleGPSBindingOpreation:(NSInteger)bikeid :(DeviceInfoModel *)model{
    
    [self.bindingDeviceViewModel nextStep:bikeid :model success:^(id dict) {
        
        if ([dict[@"status"] intValue] == 0) {
            [[LoadView sharedInstance] hide];
            NSDictionary *data = dict[@"data"];
            NSDictionary *bike_info = data[@"bike_info"];
            BikeInfoModel *bikeInfo = [BikeInfoModel yy_modelWithDictionary:bike_info];
            
            [USER_DEFAULTS setInteger:bikeInfo.bike_id forKey:Key_BikeId];
            [USER_DEFAULTS synchronize];
            
            NSMutableArray *peripherAry = [LVFmdbTool queryPeripheraData:[NSString stringWithFormat:@"SELECT * FROM periphera_modals WHERE type = '%d'",4]];
            
            for (PeripheralModel *Peripheral in peripherAry) {
                if ([Peripheral.mac isEqualToString: model.mac]) {
                    if ([LVFmdbTool deleteSpecifiedData:Peripheral.bikeid]) {
                        [[Manager shareManager] bikeViewUpdateForNewConnect:NO];
                        break;
                    }
                }
            }
            
            if (bikeInfo.brand_info.brand_id == 0) {
                bikeInfo.bike_name = @"智能电动车";
                bikeInfo.brand_info.logo = [QFTools getdata:@"defaultlogo"];
            }
                
            BikeModel *pmodel = [BikeModel modalWith:bikeInfo.bike_id bikename:bikeInfo.bike_name ownerflag:bikeInfo.owner_flag ecu_id:bikeInfo.ecu_id hwversion:bikeInfo.hw_version firmversion:bikeInfo.firm_version keyversion:bikeInfo.key_version mac:bikeInfo.mac.uppercaseString sn:bikeInfo.sn mainpass:bikeInfo.passwd_info.main password:bikeInfo.passwd_info.children.firstObject bindedcount:bikeInfo.binded_count ownerphone:[QFTools getdata:@"phone_num"] fp_func:bikeInfo.fp_func fp_conf_count:bikeInfo.fp_conf_count tpm_func:bikeInfo.tpm_func gps_func:bikeInfo.gps_func vibr_sens_func:bikeInfo.vibr_sens_func wheels:bikeInfo.wheels builtin_gps:bikeInfo.builtin_gps];
            [LVFmdbTool insertBikeModel:pmodel];
            
            BrandModel *bmodel = [BrandModel modalWith:bikeInfo.bike_id brandid:bikeInfo.brand_info.brand_id brandname:bikeInfo.brand_info.brand_name logo:_bikeinfomodel.brand_info.logo bike_pic:bikeInfo.brand_info.bike_pic];
            [LVFmdbTool insertBrandModel:bmodel];
            
            if (bikeInfo.model_info.model_id == 0) {
                
                bikeInfo.model_info.picture_b = [QFTools getdata:@"defaultimage"];
            }
            
            ModelInfo *Infomodel = [ModelInfo modalWith:bikeInfo.bike_id modelid:bikeInfo.model_info.model_id modelname:bikeInfo.model_info.model_name batttype:bikeInfo.model_info.batt_type battvol:bikeInfo.model_info.batt_vol wheelsize:bikeInfo.model_info.wheel_size brandid:bikeInfo.model_info.brand_id pictures:bikeInfo.model_info.picture_s pictureb:bikeInfo.model_info.picture_b];
            [LVFmdbTool insertModelInfo:Infomodel];
            
            for (DeviceInfoModel *device in bikeInfo.device_info){
                
                PeripheralModel *permodel = [PeripheralModel modalWith:bikeInfo.bike_id deviceid:device.device_id type:device.type seq:device.seq mac:device.mac sn:device.sn qr:device.qr firmversion:device.firm_version default_brand_id:device.default_brand_id default_model_id:device.default_model_id prod_date:device.prod_date imei:device.imei imsi:device.imsi sign:device.sign desc:device.desc ts:device.ts bind_sn:device.bind_sn bind_mac:device.bind_mac is_used:device.is_used];
                [LVFmdbTool insertDeviceModel:permodel];
                
                for (ServiceInfoModel *servicesInfo in device.service){
                    
                    PerpheraServicesInfoModel *service = [PerpheraServicesInfoModel modelWith:bikeInfo.bike_id deviceid:device.device_id ID:servicesInfo.ID type:servicesInfo.type title:servicesInfo.title brand_id:servicesInfo.brand_id begin_date:servicesInfo.begin_date end_date:servicesInfo.end_date left_days:servicesInfo.left_days];
                    [LVFmdbTool insertPerpheraServicesInfoModel:service];
                }
            }
            
            if ([[AppDelegate currentAppDelegate].mainController isKindOfClass:NSClassFromString(@"AddBikeViewController")]) {
                
                [[APPStatusManager sharedManager] setActivatedJumpStstus:YES];
                [NSNOTIC_CENTER postNotificationName:KNOTIFICATION_LOGINCHANGE object:@YES];
            }else{
                
                [USER_DEFAULTS removeObjectForKey:Key_DeviceUUID];
                [CommandDistributionServices removePeripheral:nil];
                self.updateModel.logo = bikeInfo.brand_info.logo;
                [[Manager shareManager] bindingBikeSucceeded:bikeInfo :self.updateModel];
            }
            
        }else{
            [[LoadView sharedInstance] hide];
            [SVProgressHUD showSimpleText:dict[@"status_info"]];
            [self.navigationController popViewControllerAnimated:YES];
        }
            
    } failure:^(NSError * error) {
        
        [[LoadView sharedInstance] hide];
        [self.navigationController popViewControllerAnimated:YES];
    }];
}


-(void)AccessoriesGPSBindingOpreation:(NSInteger)bikeid :(DeviceInfoModel *)model{
    @weakify(self);
    [self.bindingDeviceViewModel nextStep:bikeid :model success:^(id dict) {
        @strongify(self);
        if ([dict[@"status"] intValue] == 0) {
            [[LoadView sharedInstance] hide];
            NSDictionary *deviceDiction = dict[@"data"];
            NSMutableArray *deviceinfo = deviceDiction[@"device_info"];
            for (NSDictionary *devicedic in deviceinfo) {
                DeviceInfoModel* deviceInfoModel = [DeviceInfoModel yy_modelWithDictionary:devicedic];
                if ([deviceInfoModel.sn isEqualToString:model.sn]) {
                    
                    NSString *mac = deviceInfoModel.mac;
                    NSInteger deviceid = deviceInfoModel.device_id;
                    PeripheralModel *pmodel = [PeripheralModel modalWith:bikeid deviceid:deviceid type:deviceInfoModel.type seq:deviceInfoModel.seq mac:mac sn:deviceInfoModel.sn qr:deviceInfoModel.qr firmversion:deviceInfoModel.firm_version default_brand_id:deviceInfoModel.default_brand_id default_model_id:deviceInfoModel.default_model_id prod_date:deviceInfoModel.prod_date imei:deviceInfoModel.imei imsi:deviceInfoModel.imsi sign:deviceInfoModel.sign desc:deviceInfoModel.desc ts:deviceInfoModel.ts bind_sn:deviceInfoModel.bind_sn bind_mac:deviceInfoModel.bind_mac is_used:deviceInfoModel.is_used];
                    [LVFmdbTool insertDeviceModel:pmodel];
                    
                    for (ServiceInfoModel *servicesInfo in deviceInfoModel.service){
                        
                        PerpheraServicesInfoModel *service = [PerpheraServicesInfoModel modelWith:bikeid deviceid:deviceid ID:servicesInfo.ID type:servicesInfo.type title:servicesInfo.title brand_id:servicesInfo.brand_id begin_date:servicesInfo.begin_date end_date:servicesInfo.end_date left_days:servicesInfo.left_days];
                        [LVFmdbTool insertPerpheraServicesInfoModel:service];
                    }
                    
                    [[Manager shareManager] bindingPeripheralSucceeded:pmodel];
                }
            }
            
        }else{
            [[LoadView sharedInstance] hide];
            [SVProgressHUD showSimpleText:dict[@"status_info"]];
            [self.navigationController popViewControllerAnimated:YES];
        }
        
    } failure:^(NSError * error) {
        [[LoadView sharedInstance] hide];
        [self.navigationController popViewControllerAnimated:YES];
    }];
}
/// 套件有GPS
-(void)kitWithGPSBindingOpreation:(ProcessingtType)type :(NSInteger)bikeid :(DeviceInfoModel *)model{
    @weakify(self);
    
    NSString *token = [QFTools getdata:@"token"];
    NSString *URLString = [NSString stringWithFormat:@"%@%@",QGJURL,@"app/checkdevice"];
    NSDictionary *parameters = @{@"token": token, @"sn":model.bind_sn, @"bike_id":@(bikeid) };
    
    [[HttpRequest sharedInstance] postWithURLString:URLString parameters:parameters success:^(id dict) {
        
        if (type == ECUKitWithGPS || type == DuplicateBindingKitWithGPS) {
            @strongify(self);
              if ([dict[@"status"] intValue] == 0) {

                  NSDictionary *deviceDiction = dict[@"data"];
                  DeviceInfoModel* deviceInfoModel = [DeviceInfoModel yy_modelWithDictionary:deviceDiction[@"device_info"]];
                  if (![QFTools isBlankString:deviceInfoModel.bind_sn] && deviceInfoModel.type == 4){
                      
                      if (deviceInfoModel.is_used ) {
                          
                          if ([deviceInfoModel.bind_mac isEqualToString:model.mac]) {
                              //能绑定
                              self.bikeinfomodel.device_info = [NSMutableArray arrayWithObject:deviceInfoModel];
                              [self.headView switchBindBikeView];
                              [self getDefaultBikeBrand:type :bikeid];
                          }else{
                              //不能能绑定
                              [[LoadView sharedInstance] hide];
                              [self.headView bindFailedWithCode:2];
                          }
                          
                      }else{
                          //能绑定
                          self.bikeinfomodel.device_info = [NSMutableArray arrayWithObject:deviceInfoModel];
                          [self.headView switchBindBikeView];
                          [self getDefaultBikeBrand:type :bikeid];
                      }
                      
                  }else if([QFTools isBlankString:deviceInfoModel.bind_sn] && deviceInfoModel.type == 4){
                      
                      if (deviceInfoModel.is_used ) {
                          //不能能绑定
                          [[LoadView sharedInstance] hide];
                          [_headView bindFailedWithCode:2];
                      }else{
                          //能绑定
                          self.bikeinfomodel.device_info = [NSMutableArray arrayWithObject:deviceInfoModel];
                          [self.headView switchBindBikeView];
                          [self getDefaultBikeBrand:type :bikeid];
                      }
                      
                  }else{
                      //不能能绑定
                      [_headView bindFailedWithCode:2];
                  }
                  
              }else if ([dict[@"status"] intValue] == 1017){
                  
                  TwoDimensionalCodecanViewController * CodecanVc = [[TwoDimensionalCodecanViewController alloc] init];
                  CodecanVc.type = 12;
                  CodecanVc.naVtitle = @"扫一扫";
                  CodecanVc.scanValue = ^(NSString *code) {
                      
                      NSMutableArray *viewCtrs = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
                      for (UIViewController *controller in viewCtrs){
                         if ([controller isKindOfClass:[self class]]) {
                             NSInteger index = [viewCtrs indexOfObject:controller] + 1;
                             [viewCtrs removeObjectsInRange: NSMakeRange(index, viewCtrs.count - index)];
                             [self.navigationController setViewControllers:viewCtrs animated:YES];
                             break;
                          }
                      }
                      
                      model.bind_sn = code;
                      [self kitWithGPSBindingOpreation:type :bikeid :model];
                      
                  };
                  [self.navigationController pushViewController:CodecanVc animated:YES];
                  
              }else{
                [[LoadView sharedInstance] hide];
                [SVProgressHUD showSimpleText:dict[@"status_info"]];
                [self.navigationController popViewControllerAnimated:YES];
            }
            
        }
        
    } failure:^(NSError * error) {
        [[LoadView sharedInstance] hide];
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

/// 套件有ECU
-(void)GPSKitBindingOpreation:(ProcessingtType)type :(NSInteger)bikeid :(DeviceInfoModel *)model{
    
    @weakify(self);
    [[[NSNOTIC_CENTER rac_addObserverForName:KNotification_BluetoothPowerOn object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id x) {
        @strongify(self);
        if (![[APPStatusManager sharedManager] getBikeBindingStstus]) {
            [self startblescan:type :bikeid :model];
        }
    }];
    
    [[[NSNOTIC_CENTER rac_addObserverForName:KNotification_BluetoothPowerOff object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id x){
        if (![[APPStatusManager sharedManager] getBikeBindingStstus]) {
            [CommandDistributionServices stopScan];
        }
    }];
    
    [self registerObservers:type :bikeid :model];
    [self startblescan:type :bikeid :model];
}

- (void)startblescan:(ProcessingtType)type :(NSInteger)bikeid :(DeviceInfoModel *)deviceModel{
    @weakify(self);
    [CommandDistributionServices stopScan];
    [CommandDistributionServices removePeripheral:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
        [CommandDistributionServices startScan:DeviceBingDingType PeripheralList:^(NSMutableArray * arry) {
            @strongify(self);
            NSLog(@"搜索车辆数目%@",arry);
            //if ([QFTools isBlankString:deviceModel.bind_mac]) {
                //添加绑定车辆选择列表
            //}else{
            for (SearchBleModel *model in arry) {
                if ([model.mac.uppercaseString isEqualToString:deviceModel.bind_mac.uppercaseString]) {
                    [self bindBike:model :type:bikeid :deviceModel];
                    return;
                }
            }
            self.bindingListModel.rssiList = [arry mutableCopy];
            [self.scanView setParams:[arry copy]];
            //}
        }];
    });
}

-(void)bindBike:(SearchBleModel *)model :(ProcessingtType)type :(NSInteger)bikeid :(DeviceInfoModel *)deviceModel{
    
    if (![HttpRequest sharedInstance].available) {
        [SVProgressHUD showSimpleText:@"网络未连接"];
        return;
    }else if (![[APPStatusManager sharedManager] getBLEStstus]) {
        [SVProgressHUD showSimpleText:@"蓝牙未开启"];
        return;
    }
    [[LoadView sharedInstance] show];
    [LoadView sharedInstance].protetitle.text = @"绑定车辆中";
    [[APPStatusManager sharedManager] setBikeBindingStstus:YES];
    self.bikeinfomodel.mac = model.mac.uppercaseString;
    @weakify(self);
    RACSignal * deallocSignal = [self rac_signalForSelector:@selector(receiveConnnectMessageBikeSuccess:::)];
    [[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:KNotification_UpdateDeviceStatus object:nil] takeUntil:deallocSignal] timeout:10 onScheduler:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        @strongify(self);
        NSNotification *userInfo = x;
        BOOL disConnect = [userInfo.object boolValue];
        if (!disConnect) {
            [self receiveConnnectMessageBikeSuccess:type :bikeid :deviceModel];
        }
    }error:^(NSError *error) {
        [self overtime];
    }];
    [CommandDistributionServices stopScan];
    [CommandDistributionServices connectPeripheral:model.peripher];
    [[self.bindingListModel mutableArrayValueForKey:@"rssiList"] removeAllObjects];
    [self unregisterObservers];
}


-(void)receiveConnnectMessageBikeSuccess:(ProcessingtType)type :(NSInteger)bikeid :(DeviceInfoModel *)deviceModel{
    @weakify(self);
    [CommandDistributionServices getDeviceFirmwareRevisionString:^(NSString * _Nonnull revision) {
        @strongify(self);
        self.bikeinfomodel.firm_version = revision;
        [self monitorDiviceVersion:type :bikeid :deviceModel];
    } error:^(CommandStatus status) {
        @strongify(self);
        switch (status) {
            case SendSuccess:
                NSLog(@"固件版本获取成功");
                break;
            default:
                [[LoadView sharedInstance] hide];
                [self overtime];
                break;
        }
    }];
}

-(void)monitorDiviceVersion:(ProcessingtType)type :(NSInteger)bikeid :(DeviceInfoModel *)deviceModel{
    @weakify(self);
    [CommandDistributionServices getDeviceHardwareRevisionString:^(NSString * _Nonnull revision) {
        @strongify(self);
        self.bikeinfomodel.hw_version = revision;
        NSString *last = [self.bikeinfomodel.hw_version substringFromIndex:self.bikeinfomodel.hw_version.length-1];
        if ([last isEqualToString:@"1"]) {
            self.bikeinfomodel.fp_func = 1;
        }
        [self vehicleInformationReading:type :bikeid :deviceModel];
        
    } error:^(CommandStatus status) {
        @strongify(self);
        switch (status) {
            case SendSuccess:
                NSLog(@"硬件版本号成功");
                break;
            default:
                [[LoadView sharedInstance] hide];
                [self overtime];
                break;
        }
        
    }];
}

-(void)vehicleInformationReading:(ProcessingtType)type :(NSInteger)bikeid :(DeviceInfoModel *)deviceModel{
    @weakify(self);
    [CommandDistributionServices readingVehicleInformation:^(id _Nonnull data) {
        @strongify(self);
        if ([data intValue] == 2) {
            self.bikeinfomodel.wheels = 0;
        }else if ([data intValue] == 3){
            self.bikeinfomodel.wheels = 1;
        }else if ([data intValue] == 4){
            self.bikeinfomodel.wheels = 2;
        }
        [self firmwareJudgment:type :bikeid :deviceModel];
        
    } error:^(CommandStatus status) {
        @strongify(self);
        switch (status) {
            case SendSuccess:
                NSLog(@"车轮数获取成功");
                break;
            default:
                [self firmwareJudgment:type :bikeid :deviceModel];
                break;
        }
    }];
    
}

-(void)firmwareJudgment:(ProcessingtType)type :(NSInteger)bikeid :(DeviceInfoModel *)deviceModel{
    
    if (![[self.bikeinfomodel.firm_version substringWithRange:NSMakeRange(0, 4)] isEqualToString:@"X100"]) {
        @weakify(self);
        [CommandDistributionServices getDeviceSupportdata:^(DeviceConfigurationModel *model) {
            @strongify(self);
            if(model.supportFingerprint){
                self.bikeinfomodel.fp_func = 1;
            }
            
            if(model.supportVibrationSensor){
                self.bikeinfomodel.vibr_sens_func = 1;
            }
            
            if(model.supportTirePressure){
                self.bikeinfomodel.tpm_func = 1;
            }
            
            if(model.supportGPS){
                self.bikeinfomodel.gps_func = 1;
            }
            
            if(model.fingerprintConfigurationTimes == 5){
                self.bikeinfomodel.fp_conf_count = 1;
            }
            [self getKeyType:type :bikeid :deviceModel];
        }error:^(CommandStatus status) {
            @strongify(self);
            switch (status) {
                case SendSuccess:
                    NSLog(@"设备支持获取成功");
                    break;
                default:
                    [self getKeyType:type :bikeid :deviceModel];
                    break;
            }
        }];
        
    }else{
        //无指纹和无震动灵敏度
        [self getKeyType:type :bikeid :deviceModel];
    }
}

//发送钥匙码
-(void)getKeyType:(ProcessingtType)type :(NSInteger)bikeid :(DeviceInfoModel *)deviceModel{
    @weakify(self);
    [CommandDistributionServices querykeyVersionNumber:^(NSString * _Nonnull date) {
        @strongify(self);
        self.bikeinfomodel.key_version = nil;
        self.bikeinfomodel.key_version = date;
        [self addCheckdevicenew:type :bikeid :deviceModel];
        
    }error:^(CommandStatus status) {
        @strongify(self);
        switch (status) {
            case SendSuccess:
                NSLog(@"获取钥匙码成功");
                break;
            default:
                [[LoadView sharedInstance] hide];
                [self overtime];
                break;
        }
    }];
}

-(void)overtime{
    [[LoadView sharedInstance] hide];
    [CommandDistributionServices removePeripheral:nil];
    [SVProgressHUD showSimpleText:@"绑定超时"];
    [[APPStatusManager sharedManager] setBikeBindingStstus:NO];
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)addCheckdevicenew:(ProcessingtType)type :(NSInteger)bikeid :(DeviceInfoModel *)deviceModel{

    NSString *URLString = [NSString stringWithFormat:@"%@%@",QGJURL,@"app/checkdevicenew"];
    NSString *token = [QFTools getdata:@"token"];
    NSDictionary *parameters = @{@"token": token,@"sn":self.bikeinfomodel.mac.uppercaseString};
    
    [[HttpRequest sharedInstance] postWithURLString:URLString parameters:parameters success:^(id _Nullable dict) {
        
        if ([dict[@"status"] intValue] == 0) {

            NSDictionary *deviceDiction = dict[@"data"];
            DeviceInfoModel* deviceInfoModel = [DeviceInfoModel yy_modelWithDictionary:deviceDiction[@"device_info"]];
            self.bikeinfomodel.brand_info.brand_id = deviceInfoModel.default_brand_id;
              
            if (type == GPSKitWithECU || type == DuplicateGPSKitWithECU) {
                if (deviceInfoModel.is_used ) {
                    
                    if ([deviceInfoModel.bind_mac isEqualToString:deviceModel.mac]) {
                        //能绑定
                        [[LoadView sharedInstance] hide];
                        [self.headView switchScanGPSView];
                        [self judgmentScanLogic:type :deviceModel :bikeid];
                    }else{
                        //不能能绑定
                        [[LoadView sharedInstance] hide];
                        [self.headView bindFailedWithCode:2];
                    }
                    
                }else{
                    //能绑定
                    [[LoadView sharedInstance] hide];
                    [self.headView switchScanGPSView];
                    [self judgmentScanLogic:type :deviceModel :bikeid];
                }
                
            }else if (type == GPSKitWithOutECU || type == DuplicateGPSKitWithOutECU){
                
                [[LoadView sharedInstance] hide];
                [self.headView switchScanGPSView];
                [self judgmentScanLogic:type :deviceModel :bikeid];
            }
            
          }else{
            [[LoadView sharedInstance] hide];
            [SVProgressHUD showSimpleText:dict[@"status_info"]];
            [self.navigationController popViewControllerAnimated:YES];
        }
            
        
//        if ([dict[@"status"] intValue] == 0) {
//
//            NSDictionary *data = dict[@"data"];
//            NSDictionary *device_info = data[@"device_info"];
//            _bikeinfomodel.brand_info.brand_id = [device_info[@"default_brand_id"] integerValue];
//            [self getDefaultBikeBrand];
//
//        }
        
    }failure:^(NSError *error) {
        [SVProgressHUD showSimpleText:TIP_OF_NO_NETWORK];
        NSLog(@"error :%@",error);
        [self overtime];
        
    }];
    
}

-(void)getDefaultBikeBrand:(ProcessingtType)type :(NSInteger)bikeid{
    
    NSString *URLString = [NSString stringWithFormat:@"%@%@",QGJURL,@"app/getbrandlist"];
    NSString *token = [QFTools getdata:@"token"];
    NSDictionary *parameters = @{@"token": token,@"firm_version":self.bikeinfomodel.firm_version,@"mac":self.bikeinfomodel.mac.uppercaseString};
    
    [[HttpRequest sharedInstance] postWithURLString:URLString parameters:parameters success:^(id _Nullable dict) {
        
        if ([dict[@"status"] intValue] == 0) {
            
            NSDictionary *data = dict[@"data"];
            NSMutableArray *userinfo = data[@"brands"];
            for (NSDictionary *dataDict in userinfo) {
                NSNumber *brand = dataDict[@"brand_id"];
                if (brand.intValue == self.bikeinfomodel.brand_info.brand_id) {
                    self.bikeinfomodel.brand_info.bike_pic = dataDict[@"bike_pic"];
                    self.bikeinfomodel.brand_info.brand_name = dataDict[@"brand_name"];
                    self.bikeinfomodel.brand_info.logo = dataDict[@"logo"];
                }else if (self.bikeinfomodel.brand_info.brand_id == 0){
                    
                    self.bikeinfomodel.brand_info.brand_name = @"骑管家";
                    self.bikeinfomodel.brand_info.logo = [QFTools getdata:@"defaultlogo"];
                }
            }
            
            [self addVcbikebinding:type :bikeid :0];
        }else if([dict[@"status"] intValue] == 1001){
            
            [self overtime];
        }else{
            [self overtime];
        }
        
    }failure:^(NSError *error) {
        [SVProgressHUD showSimpleText:TIP_OF_NO_NETWORK];
        NSLog(@"error :%@",error);
        [self overtime];
    }];
}


- (void)addVcbikebinding:(ProcessingtType)type :(NSInteger)bikeid :(NSInteger)isForce{
    
    if ([LVFmdbTool queryBikeData:nil].count >= 5) {
        
        [SVProgressHUD showSimpleText:@"最多同时只能绑定5辆车"];
        [[LoadView sharedInstance] hide];
        return;
    }
    
    if(self.bikeinfomodel.hw_version == nil){
        self.bikeinfomodel.hw_version = @"000000";//硬件版本号
    }
    
    if(self.bikeinfomodel.key_version == nil){
        self.bikeinfomodel.key_version = @"1";//钥匙版本号
    }
    
    BikeModel* bikeModel = [LVFmdbTool queryBikeData:[NSString stringWithFormat:@"SELECT * FROM bike_modals WHERE bikeid LIKE '%zd'", bikeid]].firstObject;
    
    NSString *token = [QFTools getdata:@"token"];
    NSString *URLString;
    NSDictionary *parameters;
    if (type == DuplicateChangeECU) {
        
        NSNumber* is_force;
        if (bikeModel.gps_func == 1 && self.bikeinfomodel.gps_func != bikeModel.gps_func) {
            is_force = @(1);
        }else{
            is_force = @(0);
        }
        
        URLString = [NSString stringWithFormat:@"%@%@",QGJURL,@"app/changedevice"];
        parameters = @{@"token": token,@"bike_id":@(bikeModel.bikeid),@"device_type": @(1),@"old_device_id":@(bikeModel.ecu_id),@"new_bike_info":[self.bikeinfomodel yy_modelToJSONObject],@"is_force":@(isForce)};
    }else{
        
        URLString = [NSString stringWithFormat:@"%@%@",QGJURL,@"app/bindbike"];
        parameters = @{@"token": token,@"bike_info":[self.bikeinfomodel yy_modelToJSONObject]};
    }
    
    [[HttpRequest sharedInstance] postWithURLString:URLString parameters:parameters success:^(id _Nullable dict) {
        
        if ([dict[@"status"] intValue] == 0) {
            @weakify(self);
            NSDictionary *data = dict[@"data"];
            NSDictionary *bike_info = data[@"bike_info"];
            BikeInfoModel *bikeInfo = [BikeInfoModel yy_modelWithDictionary:bike_info];
            [USER_DEFAULTS setInteger:bikeInfo.bike_id forKey:Key_BikeId];
            [USER_DEFAULTS synchronize];
            NSString *child = @"0";
            NSString *main = bikeInfo.passwd_info.main;
            NSMutableArray *bikeAry = [LVFmdbTool queryBikeData:nil];
            for (BikeModel *bik in bikeAry) {
                if ([bik.mac isEqualToString:(type == DuplicateChangeECU)? bikeModel.mac:bikeInfo.mac]) {
                    if ([LVFmdbTool deleteSpecifiedData:bik.bikeid]) {
                        [[Manager shareManager] bikeViewUpdateForNewConnect:NO];
                    }
                }
            }
            
            BikeModel *pmodel = [BikeModel modalWith:bikeInfo.bike_id bikename:bikeInfo.bike_name ownerflag:bikeInfo.owner_flag ecu_id:bikeInfo.ecu_id hwversion:bikeInfo.hw_version firmversion:bikeInfo.firm_version keyversion:bikeInfo.key_version mac:bikeInfo.mac sn:bikeInfo.mac mainpass:main password:child bindedcount:bikeInfo.binded_count ownerphone:[QFTools getdata:@"phone_num"] fp_func:bikeInfo.fp_func fp_conf_count:bikeInfo.fp_conf_count tpm_func:bikeInfo.tpm_func gps_func:bikeInfo.gps_func vibr_sens_func:bikeInfo.vibr_sens_func wheels:bikeInfo.wheels builtin_gps:bikeInfo.builtin_gps];
            [LVFmdbTool insertBikeModel:pmodel];
            
            BrandModel *bmodel = [BrandModel modalWith:bikeInfo.bike_id brandid:bikeInfo.brand_info.brand_id brandname:bikeInfo.brand_info.brand_name logo:self.bikeinfomodel.brand_info.logo bike_pic:bikeInfo.brand_info.bike_pic];
            [LVFmdbTool insertBrandModel:bmodel];
            
            if (bikeInfo.model_info.model_id == 0) {
                
                bikeInfo.model_info.picture_b = [QFTools getdata:@"defaultimage"];
            }
            
            ModelInfo *Infomodel = [ModelInfo modalWith:bikeInfo.bike_id modelid:bikeInfo.model_info.model_id modelname:bikeInfo.model_info.model_name batttype:bikeInfo.model_info.batt_type battvol:bikeInfo.model_info.batt_vol wheelsize:bikeInfo.model_info.wheel_size brandid:bikeInfo.model_info.brand_id pictures:bikeInfo.model_info.picture_s pictureb:bikeInfo.model_info.picture_b];
            [LVFmdbTool insertModelInfo:Infomodel];
            
            for (DeviceInfoModel *device in bikeInfo.device_info){
                
                PeripheralModel *permodel = [PeripheralModel modalWith:bikeInfo.bike_id deviceid:device.device_id type:device.type seq:device.seq mac:device.mac sn:device.sn qr:device.qr firmversion:device.firm_version default_brand_id:device.default_brand_id default_model_id:device.default_model_id prod_date:device.prod_date imei:device.imei imsi:device.imsi sign:device.sign desc:device.desc ts:device.ts bind_sn:device.bind_sn bind_mac:device.bind_mac is_used:device.is_used];
                [LVFmdbTool insertDeviceModel:permodel];
                
                for (ServiceInfoModel *serviceModel in device.service) {
                    PerpheraServicesInfoModel * services = [PerpheraServicesInfoModel modelWith:bikeInfo.bike_id deviceid:device.device_id ID:serviceModel.ID type:serviceModel.type title:serviceModel.title brand_id:serviceModel.brand_id begin_date:serviceModel.begin_date end_date:serviceModel.end_date left_days:serviceModel.left_days];
                    [LVFmdbTool insertPerpheraServicesInfoModel:services];
                }
            }
            
            for (FingerModel *fpsInfo in bikeInfo.fps){
                
                FingerprintModel *fingermodel = [FingerprintModel modalWith:bikeInfo.bike_id fp_id:fpsInfo.fp_id pos:fpsInfo.pos name:fpsInfo.name added_time:fpsInfo.added_time];
                [LVFmdbTool insertFingerprintModel:fingermodel];
            }
            [CommandDistributionServices bikePasswordConfiguration:bike_info[@"passwd_info"] data:^(id data) {
                @strongify(self);
                [self monitorConnectAgain:[data intValue] :bikeInfo :type];
            } error:^(CommandStatus status) {
                @strongify(self);
                switch (status) {
                    case SendSuccess:
                        NSLog(@"密码配置发送成功");
                        break;
                    default:
                        [self monitorConnectAgain:ConfigurationFail :bikeInfo :type];
                        break;
                }
            }];
        }else if([dict[@"status"] intValue] == 1047){
            
            if (type == DuplicateChangeECU) {
                
                NSMutableArray* peripheraAry = [LVFmdbTool queryPeripheraData:[NSString stringWithFormat:@"SELECT * FROM periphera_modals WHERE type = '%zd' AND bikeid = '%zd'", 4,_bikeid]];
                NSDictionary *data = dict[@"data"];
                ChangeDeviceModel *model = [ChangeDeviceModel yy_modelWithDictionary:data];
                
                if (model.can_not_force == 1) {
                    //跳转更换失败界面
                    [self pushChangeDeviceFail:BindingChangeECUFail];
                    return ;
                }else if (peripheraAry.count > 0 && self.bikeinfomodel.gps_func == 0){
                    [self pushChangeDeviceFail:BindingChangeECUFail];
                    return;
                }
                
                @weakify(self);
                DW_AlertView *alertView = [[DW_AlertView alloc] initBackroundImage:nil Title:@"中控类型不一致" contentString:@"更换的设备类型不一致，更换后可 能影响部分功能使用"  sureButtionTitle:@"确认" cancelButtionTitle:@"取消"];
                [alertView setSureBolck:^(BOOL clickStatu) {
                    @strongify(self);
                    [LoadView sharedInstance].protetitle.text = @"更换中控中";
                    [[LoadView sharedInstance] show];
                    [self addVcbikebinding:type :bikeid :1];
                }];
                [alertView setCancleBolck:^(BOOL clickStatu) {
                    @strongify(self);
                    [self.navigationController popViewControllerAnimated:YES];
                }];
                
            }else{
                [self overtime];
            }
        }else{
            
            if (type == DuplicateChangeECU) {
                [[LoadView sharedInstance] hide];
                [self pushChangeDeviceFail:BindingChangeECUFail];
            }else{
                [self overtime];
            }
        }
        
    }failure:^(NSError *error) {
        NSLog(@"error :%@",error);
        
        if (type == DuplicateChangeECU) {
            [[LoadView sharedInstance] hide];
            [self pushChangeDeviceFail:BindingChangeECUFail];
        }else{
            [self overtime];
        }
    }];
}

-(void)monitorConnectAgain:(CallbackStatus)status :(BikeInfoModel*)bikeInfoModel :(ProcessingtType)type{
    
    if (status == ConfigurationSuccess){
        
        [CommandDistributionServices removePeripheral:nil];
        if ([[AppDelegate currentAppDelegate].mainController isKindOfClass:NSClassFromString(@"AddBikeViewController")]) {
            
            if (![QFTools isBlankString:bikeInfoModel.sn]) {
                if (bikeInfoModel.builtin_gps == 1) {
                    [[APPStatusManager sharedManager] setActivatedJumpStstus:YES];
                }else{
                    NSMutableArray *peripheraModals = [LVFmdbTool queryPeripheraData:[NSString stringWithFormat:@"SELECT * FROM periphera_modals WHERE type LIKE '%zd' AND bikeid LIKE '%zd'", 4,bikeInfoModel.bike_id]];
                    if (peripheraModals.count == 0) {
                        [[APPStatusManager sharedManager] setActivatedJumpStstus:NO];
                    }else{
                        [[APPStatusManager sharedManager] setActivatedJumpStstus:YES];
                    }
                }
            }else{
                [[APPStatusManager sharedManager] setActivatedJumpStstus:YES];
            }
            
            [self bikeBindSuccess:type];
        }else{
            
            [self addVcconnectdevice:bikeInfoModel :type];
        }
    }else{
        [self addVcbindingfail];
    }
}

-(void)bikeBindSuccess:(ProcessingtType)type{
    
    [[LoadView sharedInstance] hide];
    if (![[APPStatusManager sharedManager] getActivatedJumpStstus]) {
        [SVProgressHUD showSimpleText:(type == DuplicateChangeECU)? @"更换设备成功":@"绑定成功"];
    }
    [NSNOTIC_CENTER postNotificationName:KNOTIFICATION_LOGINCHANGE object:@YES];
}

-(void) removebikeDB{
    
    NSString *deleteBikeSql = [NSString stringWithFormat:@"DELETE FROM bike_modals WHERE bikeid LIKE '%zd'", self.bikeinfomodel.bike_id];
    [LVFmdbTool deleteBikeData:deleteBikeSql];
    
    NSString *deleteBrandSql = [NSString stringWithFormat:@"DELETE FROM brand_modals WHERE bikeid LIKE '%zd'", self.bikeinfomodel.bike_id];
    [LVFmdbTool deleteBrandData:deleteBrandSql];
    
    NSString *deleteInfoSql = [NSString stringWithFormat:@"DELETE FROM info_modals WHERE bikeid LIKE '%zd'", self.bikeinfomodel.bike_id];
    [LVFmdbTool deleteModelData:deleteInfoSql];
    
    NSString *deletePeripherSql = [NSString stringWithFormat:@"DELETE FROM periphera_modals WHERE bikeid LIKE '%zd'", self.bikeinfomodel.bike_id];
    [LVFmdbTool deletePeripheraData:deletePeripherSql];
    
    [LVFmdbTool deletePerpheraServicesInfoData:[NSString stringWithFormat:@"DELETE FROM peripheraServicesInfo_modals WHERE bikeid LIKE '%zd'", self.bikeinfomodel.bike_id]];
}

-(void)addVcconnectdevice:(BikeInfoModel*)bikeInfoModel :(ProcessingtType)type{
    [USER_DEFAULTS removeObjectForKey:Key_DeviceUUID];
    [USER_DEFAULTS synchronize];
    if (type == DuplicateChangeECU) {
        [SVProgressHUD showSimpleText:@"更换中控成功"];
    }
    self.updateModel.logo = self.bikeinfomodel.brand_info.logo;
    [[LoadView sharedInstance] hide];
    [[APPStatusManager sharedManager] setChangeDeviceType:self.bindingType];
    [[Manager shareManager] bindingBikeSucceeded:bikeInfoModel :self.updateModel];
}

- (void)addVcbindingfail{
    
    [[LoadView sharedInstance] hide];
    [SVProgressHUD showSimpleText:@"绑定失败"];
    [[APPStatusManager sharedManager] setBikeBindingStstus:NO];
    [self removebikeDB];
    [CommandDistributionServices stopScan];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)registerObservers:(ProcessingtType)type :(NSInteger)bikeid :(DeviceInfoModel *)deviceModel
{
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)])
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:
         [UIUserNotificationSettings
          settingsForTypes: UIUserNotificationTypeAlert|UIUserNotificationTypeSound
          categories:nil]];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterForeground:) name:UIApplicationDidBecomeActiveNotification object:@{@"type":@(type),@"bikeid":@(bikeid),@"deviceModel":deviceModel}];
}

-(void)unregisterObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}

-(void)appDidEnterBackground:(NSNotification *)_notification
{
    [CommandDistributionServices stopScan];
}

-(void)appDidEnterForeground:(NSNotification *)_notification
{
    NSDictionary * infoDic = [_notification object];
    [self startblescan:[infoDic[@"type"] integerValue]:[infoDic[@"bikeid"] integerValue] :infoDic[@"deviceModel"]];
}

- (UIModalPresentationStyle)modalPresentationStyle {
    return UIModalPresentationFullScreen;
}

-(void)UnbundBike:(NSInteger)bikeid{
    
    [LoadView sharedInstance].protetitle.text = @"解绑车辆中";
    [[LoadView sharedInstance] show];
    
    BikeModel *bikemodel = [LVFmdbTool queryBikeData:[NSString stringWithFormat:@"SELECT * FROM bike_modals WHERE bikeid LIKE '%zd'", bikeid]].firstObject;
    @weakify(self);
    if (![QFTools isBlankString:bikemodel.sn]) {
        if (bikemodel.builtin_gps == 1) {
            
            [self GPSDeactivation:bikemodel.mac :^(id status) {
                @strongify(self);
                if ([status intValue] == 0) {
                    [self UnbundBtnClick:bikeid type:1];
                }else{
                    [self UnbundBtnClick:bikeid type:2];
                }
            }];
            
        }else{
            NSMutableArray *peripheraModals = [LVFmdbTool queryPeripheraData:[NSString stringWithFormat:@"SELECT * FROM periphera_modals WHERE type LIKE '%zd' AND bikeid LIKE '%zd'", 4,bikemodel.bikeid]];
            if (peripheraModals.count != 0) {
                
                [self GPSDeactivation:bikemodel.mac :^(id status) {
                    @strongify(self);
                    if ([status intValue] == 0) {
                        [self UnbundBtnClick:bikeid type:1];
                    }else{
                        [self UnbundBtnClick:bikeid type:2];
                    }
                }];
            }else{
                [self UnbundBtnClick:bikeid type:1];
            }
        }
    }else{
        [self GPSDeactivation:bikemodel.mac :^(id status) {
            @strongify(self);
            if ([status intValue] == 0) {
                [self UnbundBtnClick:bikeid type:1];
            }else{
                [self UnbundBtnClick:bikeid type:2];
            }
        }];
    }
}

//解绑回调
-(void)UnbundBtnClick:(NSInteger)bikeNum type:(NSInteger)type{
    
    NSString *token = [QFTools getdata:@"token"];
    NSString *URLString = [NSString stringWithFormat:@"%@%@",QGJURL,@"app/unbindbike"];
    NSNumber *bikeid = [NSNumber numberWithInteger:bikeNum];
    NSDictionary *parameters = @{@"token": token,@"bike_id":bikeid,@"gps_result":@(type)};
    [[HttpRequest sharedInstance] postWithURLString:URLString parameters:parameters success:^(id _Nullable dict) {
        
        if ([dict[@"status"] intValue] == 0 || [dict[@"status"] intValue] == 1018) {
            
            [LVFmdbTool deleteSpecifiedData:bikeNum];
            [CommandDistributionServices removePeripheral:nil];
            [USER_DEFAULTS removeObjectForKey:Key_DeviceUUID];
            [USER_DEFAULTS removeObjectForKey:Key_BikeId];
            [USER_DEFAULTS synchronize];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if ([LVFmdbTool queryBikeData:nil].count >0) {
                    [[Manager shareManager] unbundBike:bikeNum];
                    [[LoadView sharedInstance] hide];
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }else{
                    
                    [[LoadView sharedInstance] hide];
                    [NSNOTIC_CENTER postNotificationName:KNOTIFICATION_LOGINCHANGE object:@YES];
                }
            });
        }else{
            [[LoadView sharedInstance] hide];
            [SVProgressHUD showSimpleText:@"解绑失败"];
        }
        
    }failure:^(NSError *error) {
        
        [[LoadView sharedInstance] hide];
        NSLog(@"error :%@",error);
        [SVProgressHUD showSimpleText:TIP_OF_NO_NETWORK];
    }];
}

-(void)UnbundGPSAccessories:(NSInteger)bikeid{
    
    if (![CommandDistributionServices isConnect]){
        [self forcedUnbundling:@"智能中控未连接，是否强制解绑？" bikeid:bikeid];
        return;
    }
    @weakify(self);
    BikeModel *bikemodel = [LVFmdbTool queryBikeData:[NSString stringWithFormat:@"SELECT * FROM bike_modals WHERE bikeid LIKE '%zd'", bikeid]].firstObject;
    [LoadView sharedInstance].protetitle.text = @"删除配件中";
    [[LoadView sharedInstance] show];
    [self accessoryGPSDeactivation:bikemodel.mac :^(id status) {
        @strongify(self);
        if ([status intValue] == 0) {
            [self delateGPS:1 bikeid:bikeid];
        }else{
            [self forcedUnbundling:@"通讯GPS外设失败，是否强制解绑？" bikeid:bikeid];
        }
    }];
}

-(void)forcedUnbundling:(NSString *)title bikeid:(NSInteger)bikeid{
    
    [[LoadView sharedInstance] hide];
    @weakify(self);
    DW_AlertView *alertView = [[DW_AlertView alloc] initBackroundImage:nil Title:@"提示" contentString:title sureButtionTitle:@"强制解绑" cancelButtionTitle:@"再想想"];
    [alertView setSureBolck:^(BOOL clickStatu) {
        @strongify(self);
        [LoadView sharedInstance].protetitle.text = @"删除配件中";
        [[LoadView sharedInstance] show];
        [self delateGPS:2 bikeid:bikeid];
    }];
}

- (void)delateGPS:(NSInteger)type bikeid:(NSInteger)bikeid{
    NSString *token = [QFTools getdata:@"token"];
    PeripheralModel* peripheraModel = [LVFmdbTool queryPeripheraData:[NSString stringWithFormat:@"SELECT * FROM periphera_modals WHERE type LIKE '%zd' AND bikeid LIKE '%zd'", 4,bikeid]].firstObject;
    NSNumber *device_id= [NSNumber numberWithInteger:peripheraModel.deviceid];
    NSNumber *bike_id= [NSNumber numberWithInteger:bikeid];
    NSString *URLString = [NSString stringWithFormat:@"%@%@",QGJURL,@"app/deldevice"];
    NSDictionary *parameters = @{@"token": token,@"bike_id":bike_id,@"device_id":device_id,@"device_type":@4,@"gps_result":@(type)};
    [[HttpRequest sharedInstance] postWithURLString:URLString parameters:parameters success:^(id _Nullable dict) {
        
        if ([dict[@"status"] intValue] == 0) {
            
            PeripheralModel *pmodel = [[LVFmdbTool queryPeripheraData:[NSString stringWithFormat:@"SELECT * FROM periphera_modals WHERE deviceid = '%zd'",peripheraModel.deviceid]] firstObject];
            
            if([LVFmdbTool deletePeripheraData:[NSString stringWithFormat:@"DELETE FROM periphera_modals WHERE deviceid = '%zd' AND bikeid = '%zd'", peripheraModel.deviceid,bikeid]])
            [[Manager shareManager] deletePeripheralSucceeded:pmodel];
            
            [LVFmdbTool deletePeripheralActivationStatusData:[NSString stringWithFormat:@"DELETE FROM peripheralActivationStatus_models WHERE bikeid = '%zd'",bikeid]];
            
            [LVFmdbTool deletePerpheraServicesInfoData:[NSString stringWithFormat:@"DELETE FROM peripheraServicesInfo_modals WHERE bikeid LIKE '%zd'", bikeid]];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                   [[LoadView sharedInstance] hide];
                   [self.navigationController popToRootViewControllerAnimated:YES];
            });
        }else{
            [[LoadView sharedInstance] hide];
            [SVProgressHUD showSimpleText:dict[@"status_info"]];
        }
        
    }failure:^(NSError *error) {
        [[LoadView sharedInstance] hide];
        [SVProgressHUD showSimpleText:TIP_OF_NO_NETWORK];
    }];
}

-(void)UnbundSingelGPS:(NSInteger)bikeid{
    
    [LoadView sharedInstance].protetitle.text = @"解绑车辆中";
    [[LoadView sharedInstance] show];
    PeripheralModel* peripheraModel = [LVFmdbTool queryPeripheraData:[NSString stringWithFormat:@"SELECT * FROM periphera_modals WHERE type LIKE '%zd' AND bikeid LIKE '%zd'", 4,bikeid]].firstObject;
    @weakify(self);
    [self SingleGPSDeactivation:peripheraModel.mac :^(id status) {
        @strongify(self);
        if ([status intValue] == 0) {
            [self UnbundBtnClick:bikeid type:1];
        }else if ([status intValue] == 1){
            [self forcedUnbundGPS:@"车辆未连接，是否强制解绑？" bikeid:bikeid];
        }else{
            [self UnbundBtnClick:bikeid type:1];
        }
    }];
}

-(void)forcedUnbundGPS:(NSString *)title bikeid:(NSInteger)bikeid{
    
    [[LoadView sharedInstance] hide];
    @weakify(self);
    DW_AlertView *alertView = [[DW_AlertView alloc] initBackroundImage:nil Title:@"提示" contentString:title sureButtionTitle:@"强制解绑" cancelButtionTitle:@"再想想"];
    [alertView setSureBolck:^(BOOL clickStatu) {
        @strongify(self);
        [LoadView sharedInstance].protetitle.text = @"解绑车辆中";
        [[LoadView sharedInstance] show];
        [self UnbundBtnClick:bikeid type:2];
    }];
}

-(void)changeDeviceGPS:(ProcessingtType)type :(NSInteger)bikeid :(NSInteger)isForce{
    
    PeripheralModel *oldDeviceModel = [LVFmdbTool queryPeripheraData:[NSString stringWithFormat:@"SELECT * FROM periphera_modals WHERE type = '%zd' AND bikeid = '%zd'", 4,bikeid]].firstObject;
    NSString *token = [QFTools getdata:@"token"];
    NSString *URLString = [NSString stringWithFormat:@"%@%@",QGJURL,@"app/changedevice"];
    NSDictionary *parameters = @{@"token": token,@"bike_id":@(bikeid),@"device_type": @(4),@"old_device_id":@(oldDeviceModel.deviceid),@"new_bike_info":[self.bikeinfomodel yy_modelToJSONObject],@"is_force":@(isForce)};
    
    [[HttpRequest sharedInstance] postWithURLString:URLString parameters:parameters success:^(id _Nullable dict) {
        [[LoadView sharedInstance] hide];
        if ([dict[@"status"] intValue] == 0) {
            //[SVProgressHUD showSimpleText:@"更换GPS设备成功"];
            NSDictionary *data = dict[@"data"];
            ChangeDeviceModel *model = [ChangeDeviceModel yy_modelWithDictionary:data];
            BikeInfoModel *bikeInfo = model.bike_info;
            [USER_DEFAULTS setInteger:bikeInfo.bike_id forKey:Key_BikeId];
            [USER_DEFAULTS synchronize];
            
            NSMutableArray *bikeAry = [LVFmdbTool queryBikeData:nil];
            for (BikeModel *bik in bikeAry) {
                if (bik.bikeid == bikeid) {
                    if ([LVFmdbTool deleteSpecifiedData:bik.bikeid]) {
                        [[Manager shareManager] bikeViewUpdateForNewConnect:NO];
                    }
                    break;
                }
            }
            
            if (bikeInfo.brand_info.brand_id == 0) {
                bikeInfo.bike_name = @"智能电动车";
                bikeInfo.brand_info.logo = [QFTools getdata:@"defaultlogo"];
            }
                
            BikeModel *pmodel = [BikeModel modalWith:bikeInfo.bike_id bikename:bikeInfo.bike_name ownerflag:bikeInfo.owner_flag ecu_id:bikeInfo.ecu_id hwversion:bikeInfo.hw_version firmversion:bikeInfo.firm_version keyversion:bikeInfo.key_version mac:bikeInfo.mac.uppercaseString sn:bikeInfo.sn mainpass:bikeInfo.passwd_info.main password:bikeInfo.passwd_info.children.firstObject bindedcount:bikeInfo.binded_count ownerphone:[QFTools getdata:@"phone_num"] fp_func:bikeInfo.fp_func fp_conf_count:bikeInfo.fp_conf_count tpm_func:bikeInfo.tpm_func gps_func:bikeInfo.gps_func vibr_sens_func:bikeInfo.vibr_sens_func wheels:bikeInfo.wheels builtin_gps:bikeInfo.builtin_gps];
            [LVFmdbTool insertBikeModel:pmodel];
            
            BrandModel *bmodel = [BrandModel modalWith:bikeInfo.bike_id brandid:bikeInfo.brand_info.brand_id brandname:bikeInfo.brand_info.brand_name logo:_bikeinfomodel.brand_info.logo bike_pic:bikeInfo.brand_info.bike_pic];
            [LVFmdbTool insertBrandModel:bmodel];
            
            if (bikeInfo.model_info.model_id == 0) {
                
                bikeInfo.model_info.picture_b = [QFTools getdata:@"defaultimage"];
            }
            
            ModelInfo *Infomodel = [ModelInfo modalWith:bikeInfo.bike_id modelid:bikeInfo.model_info.model_id modelname:bikeInfo.model_info.model_name batttype:bikeInfo.model_info.batt_type battvol:bikeInfo.model_info.batt_vol wheelsize:bikeInfo.model_info.wheel_size brandid:bikeInfo.model_info.brand_id pictures:bikeInfo.model_info.picture_s pictureb:bikeInfo.model_info.picture_b];
            [LVFmdbTool insertModelInfo:Infomodel];
            
            for (DeviceInfoModel *device in bikeInfo.device_info){
                
                PeripheralModel *permodel = [PeripheralModel modalWith:bikeInfo.bike_id deviceid:device.device_id type:device.type seq:device.seq mac:device.mac sn:device.sn qr:device.qr firmversion:device.firm_version default_brand_id:device.default_brand_id default_model_id:device.default_model_id prod_date:device.prod_date imei:device.imei imsi:device.imsi sign:device.sign desc:device.desc ts:device.ts bind_sn:device.bind_sn bind_mac:device.bind_mac is_used:device.is_used];
                [LVFmdbTool insertDeviceModel:permodel];
                NSLog(@"鉴权信息  %@ -- %d",permodel.sign,permodel.ts);
                for (ServiceInfoModel *servicesInfo in device.service){
                    
                    PerpheraServicesInfoModel *service = [PerpheraServicesInfoModel modelWith:bikeInfo.bike_id deviceid:device.device_id ID:servicesInfo.ID type:servicesInfo.type title:servicesInfo.title brand_id:servicesInfo.brand_id begin_date:servicesInfo.begin_date end_date:servicesInfo.end_date left_days:servicesInfo.left_days];
                    [LVFmdbTool insertPerpheraServicesInfoModel:service];
                }
            }
            
            [USER_DEFAULTS removeObjectForKey:Key_DeviceUUID];
            //[CommandDistributionServices removePeripheral:nil];
            self.updateModel.logo = bikeInfo.brand_info.logo;
            [[APPStatusManager sharedManager] setChangeDeviceType:self.bindingType];
            [[Manager shareManager] bindingBikeSucceeded:bikeInfo :self.updateModel];
            
        }else{
            [self pushChangeDeviceFail:BindingChangeGPSFail];
        }
        
    }failure:^(NSError *error) {
        NSLog(@"error :%@",error);
        [self pushChangeDeviceFail:BindingChangeGPSFail];
    }];
    
}

-(void)pushChangeDeviceFail:(BindingType)type{
    
    [CommandDistributionServices removePeripheral:nil];
    NSMutableArray *viewCtrs = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    [viewCtrs removeLastObject];
    id vc = [[NSClassFromString(@"ReplaceEquipmentViewController") alloc] init];
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wundeclared-selector"
    [QFTools performSelector:@selector(setChangeDeviceType:) withTheObjects:@[@(type)] withTarget:vc];
    #pragma clang diagnostic pop
    [viewCtrs addObject:vc];
    [self.navigationController setViewControllers:viewCtrs animated:YES];
}

-(void)dealloc{
    
    [[APPStatusManager sharedManager] setBikeBindingStstus:NO];
    [CommandDistributionServices stopScan];
}


@end
