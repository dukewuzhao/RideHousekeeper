//
//  GPSDetailViewController.m
//  RideHousekeeper
//
//  Created by Apple on 2018/3/27.
//  Copyright © 2018年 Duke Wu. All rights reserved.
//

#import "GPSDetailViewController.h"
#import "ExtendGPSServerViewController.h"
#import "MultipleBindingLogicProcessingViewController.h"
#import "GPSActivationViewController.h"
#import "Manager.h"
@interface GPSDetailViewController ()<ManagerDelegate>
{
    CGRect oldFrame;
    UIImageView *fullScreenIV;
}
@property(nonatomic,strong) CFSettingLabelItem *GPSServiceDeadLineItem;
@property(nonatomic,strong) PeripheralModel *deviceModel;
@property(nonatomic,strong) PerpheraServicesInfoModel *servicesModel;
@property(nonatomic,strong) BikeModel *bikeModel;
@property(nonatomic,assign) NSInteger deviceid;

@end

@implementation GPSDetailViewController

-(void)setpGPSParameters:(BikeModel *)model :(NSInteger)deviceid{
    _deviceid = deviceid;
    _bikeModel = model;
    
    NSMutableArray *keymodals = [LVFmdbTool queryPeripheraData:[NSString stringWithFormat:@"SELECT * FROM periphera_modals WHERE deviceid LIKE '%zd' AND bikeid LIKE '%zd'", _deviceid,model.bikeid]];
    _deviceModel = keymodals.firstObject;
    
    if (_deviceModel.is_used == 1) {
        _servicesModel = [[LVFmdbTool queryPerpheraServicesInfoData:[NSString stringWithFormat:@"SELECT * FROM peripheraServicesInfo_modals WHERE type LIKE '%zd' AND bikeid LIKE '%zd'", 1,model.bikeid]] firstObject];
    }else if (_deviceModel.is_used == 2){
        _servicesModel = [[LVFmdbTool queryPerpheraServicesInfoData:[NSString stringWithFormat:@"SELECT * FROM peripheraServicesInfo_modals WHERE type LIKE '%zd' AND bikeid LIKE '%zd'", 0,model.bikeid]] firstObject];
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[Manager shareManager] addDelegate:self];
    [self setupNavView];
    
    //[self setupView];
    [self setupTableView];
}

- (void)setupNavView{
    [super setupNavView];
    self.navView.backgroundColor = [QFTools colorWithHexString:MainColor];
    self.navView.showBottomLabel = NO;
    [self.navView.centerButton setTitle:@"定位装置"forState:UIControlStateNormal];
    @weakify(self);
    [self.navView.leftButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    self.navView.leftButtonBlock = ^{
        @strongify(self);
        
        [self.navigationController popViewControllerAnimated:YES];
    };
    
}

- (void)setupTableView{
    // cell箭头名称
    self.icon_arrow = @"arrow";
    
    // 设置相关参数
    // cell背景颜色
    self.backgroundColor_Normal = [UIColor whiteColor];
    //cell选中背景颜色
     self.backgroundColor_Selected = CFCellBackgroundColor_Highlighted;
    self.leftLabelFontColor = [UIColor blackColor];
    //cell右边Label字体
     self.rightLabelFont = FONT_PINGFAN(17);
    //cell右边Label文字颜色
     self.rightLabelFontColor = [QFTools colorWithHexString:@"#999999"];
    @weakify(self);
    CFSettingLabelItem *messageItem1 =[CFSettingLabelItem itemWithIcon:@"icon1" title:@"设备名称"];
    messageItem1.text_right = @"骑管家定位追踪器";
    messageItem1.opration = ^{
        
    };
    CFSettingIconItem *messageItem2 = [CFSettingIconItem itemWithIcon:@"icon1" title:@"设备二维码"];
    messageItem2.icon_right = _deviceModel.qr;
    messageItem2.btnOpration = ^(UIButton *btn){
        @strongify(self);
        [self tapForFullScreen:btn];
    };
    
    CFSettingLabelItem *messageItem3 = [CFSettingLabelItem itemWithIcon:@"icon1" title:@"所属车辆"];
    messageItem3.text_right = _bikeModel.bikename;
    CFSettingLabelItem *messageItem5 = [CFSettingLabelItem itemWithIcon:@"icon1" title:@"设备SN号"];
    messageItem5.text_right = _deviceModel.imei;
    
    CFSettingLabelItem *messageItem6 = [CFSettingLabelItem itemWithIcon:@"icon1" title:@"固件版本"];
    messageItem6.text_right = _deviceModel.firmversion;
    
    CFSettingGroup *group1 = [[CFSettingGroup alloc] init];
    //group1.headerHeight = 20;
    group1.items = @[ messageItem1,messageItem2,messageItem3,messageItem5,messageItem6];

    UIView *firstView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 20)];
    firstView.backgroundColor = [QFTools colorWithHexString:@"#F5F5F5"];
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 80, 20)];
    title.text = @"设备信息";
    title.textColor = [QFTools colorWithHexString:@"#666666"];
    title.font = FONT_PINGFAN(10);
    [firstView addSubview:title];
    group1.headerView = firstView;
    
    CFSettingLabelItem *serviceItem = [CFSettingLabelItem itemWithIcon:@"icon1" title:@"绑定时间"];
    serviceItem.rightLab_color = [QFTools colorWithHexString:MainColor];
    serviceItem.text_right = _servicesModel.begin_date;
    _GPSServiceDeadLineItem =[CFSettingLabelItem itemWithIcon:@"icon3" title:@"剩余服务天数"];
    _GPSServiceDeadLineItem.rightLab_color = [QFTools colorWithHexString:MainColor];
    _GPSServiceDeadLineItem.text_right = _servicesModel.type ==0? [NSString stringWithFormat:@"试用期%d天",_servicesModel.left_days]: [NSString stringWithFormat:@"%d天",_servicesModel.left_days];
    CFSettingArrowItem *serviceItem3 =[CFSettingArrowItem itemWithIcon:@"icon3" title:@"延长服务期"];
    serviceItem3.opration = ^(UIButton *btn){
        @strongify(self);
        ExtendGPSServerViewController *extendVc = [[ExtendGPSServerViewController alloc] init];
        extendVc.bikeId = self.bikeModel.bikeid;
        [self.navigationController pushViewController:extendVc animated:YES];
    };
    
    CFSettingGroup *group2 = [[CFSettingGroup alloc] init];
    group2.items = @[ serviceItem,_GPSServiceDeadLineItem,serviceItem3];
    
    UIView *secondView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 20)];
    secondView.backgroundColor = [QFTools colorWithHexString:@"#F5F5F5"];
    UILabel *title2 = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 80, 20)];
    title2.text = @"服务时间";
    title2.font = FONT_PINGFAN(10);
    title2.textColor = [QFTools colorWithHexString:@"#666666"];
    [secondView addSubview:title2];
    group2.headerView = secondView;

    CFSettingArrowItem *equipmentItem = [CFSettingArrowItem itemWithIcon:@"icon4" title:@"删除设备"];
    equipmentItem.opration = ^{
        @strongify(self);
        
         if (self.bikeModel.ownerflag == 0) {
            [SVProgressHUD showSimpleText:@"子用户无此权限"];
            return;
         }
        
        MultipleBindingLogicProcessingViewController *multipleUbBindingLogicVc = [[MultipleBindingLogicProcessingViewController alloc] init];
        [multipleUbBindingLogicVc showView:UnbindingGPS :nil :self.bikeModel.bikeid];
        [self.navigationController pushViewController:multipleUbBindingLogicVc animated:YES];
        
    };
    /*
    CFSettingLabelArrowItem *equipmentItem1 = [CFSettingLabelArrowItem itemWithIcon:@"icon3" title:@"更换设备"];
    equipmentItem1.opration = ^{
        @strongify(self);
        
        if (self.bikeModel.ownerflag == 0) {
            [SVProgressHUD showSimpleText:@"子用户无此权限"];
            return;
        }
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"是否重新绑定" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
//            LoadView *loadview = [LoadView sharedInstance];
//            loadview.protetitle.text = @"重新绑定GPS中";
//            [loadview show];
//            [self changedevice];
        }];
        
        UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }];
        
        [alert addAction:action1];
        [alert addAction:action2];
        [self presentViewController:alert animated:YES completion:nil];
    };
    */
    CFSettingLabelArrowItem *equipmentItem2 = [CFSettingLabelArrowItem itemWithIcon:@"icon3" title:@"更换设备"];
    equipmentItem2.text_right = @"数据丢失等故障,可尝试";
    equipmentItem2.opration = ^{
        @strongify(self);
        Class className = NSClassFromString(@"TwoDimensionalCodecanViewController");
        id CodecanVc = [[className alloc] init];
        [CodecanVc setValue:@"更换定位器" forKey:@"naVtitle"];
        [CodecanVc setValue:@(self.bikeModel.bikeid) forKey:@"bikeid"];
        [CodecanVc setValue:@4 forKey:@"type"];
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wundeclared-selector"
        [QFTools performSelector:@selector(setChangeDeviceType:) withTheObjects:@[@(BindingChangeGPS)] withTarget:CodecanVc];
        #pragma clang diagnostic pop
        [self.navigationController pushViewController:CodecanVc animated:YES];
    };
    
    CFSettingLabelArrowItem *equipmentItem3 = [CFSettingLabelArrowItem itemWithIcon:@"icon3" title:@"定位器检测"];
    equipmentItem3.text_right = @"服务异常，数据初始化操作";
    equipmentItem3.opration = ^{
        @strongify(self);
        GPSActivationViewController *bindingVc = [[GPSActivationViewController alloc] init];
        [bindingVc setpGPSParameters:self.bikeModel];
        [self.navigationController pushViewController:bindingVc animated:YES];
    };
    
    CFSettingGroup *group3 = [[CFSettingGroup alloc] init];
    if (![QFTools isBlankString:_bikeModel.sn]) {
        group3.items = @[equipmentItem,equipmentItem2,equipmentItem3];
    }else{
        group3.items = @[equipmentItem2,equipmentItem3];
    }
    //group3.header = @"操作设备";
    UIView *thirdView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 20)];
    thirdView.backgroundColor = [QFTools colorWithHexString:@"#F5F5F5"];
    UILabel *title3 = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 80, 20)];
    title3.text = @"操作设备";
    title3.font = FONT_PINGFAN(10);
    title3.textColor = [QFTools colorWithHexString:@"#666666"];
    [thirdView addSubview:title3];
    group3.headerView = thirdView;
    
    [self.dataList addObject:group1];
    [self.dataList addObject:group2];
    [self.dataList addObject:group3];
    [self.table reloadData];
}


-(void)tapForFullScreen:(UIButton *)btn{
    UIImageView *avatarIV = (UIImageView *)btn.imageView;
    oldFrame = [avatarIV convertRect:avatarIV.frame toView:[UIApplication sharedApplication].keyWindow];
    if (fullScreenIV==nil) {
        fullScreenIV= [[UIImageView alloc]initWithFrame:avatarIV.frame];
    }
    fullScreenIV.backgroundColor = [UIColor blackColor];
    fullScreenIV.userInteractionEnabled = YES;
    fullScreenIV.image = [SGQRCodeObtain generateQRCodeWithData:_deviceModel.qr size:ScreenWidth];
    fullScreenIV.contentMode = UIViewContentModeScaleAspectFit;
    [[UIApplication sharedApplication].keyWindow addSubview:fullScreenIV];
    
    [UIView animateWithDuration:0.3 animations:^{
        fullScreenIV.frame = CGRectMake(0,0,ScreenWidth, ScreenHeight);
    }];
    UITapGestureRecognizer *originalTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapForOriginal:)];
    originalTap.numberOfTapsRequired = 1;
    [fullScreenIV addGestureRecognizer:originalTap];
    
}

-(void)tapForOriginal:(UITapGestureRecognizer *)tap{
    [UIView animateWithDuration:0.3 animations:^{
        fullScreenIV.frame = oldFrame;
        fullScreenIV.alpha = 0.03;
    } completion:^(BOOL finished) {
        fullScreenIV.alpha = 1;
        [fullScreenIV removeFromSuperview];
    }];
}

- (void)changedevice{
    NSString *token = [QFTools getdata:@"token"];
    NSNumber *device_id= [NSNumber numberWithInteger:_deviceid];
    NSNumber *bike_id= [NSNumber numberWithInteger:_bikeModel.bikeid];
    NSString *new_sn= @"new_sn";
    NSString *URLString = [NSString stringWithFormat:@"%@%@",QGJURL,@"app/changedevice"];
    NSDictionary *parameters = @{@"token": token,@"bike_id":bike_id,@"old_device_id":device_id,@"new_sn":new_sn};
    [[HttpRequest sharedInstance] postWithURLString:URLString parameters:parameters success:^(id _Nullable dict) {
        [[LoadView sharedInstance] hide];
        if ([dict[@"status"] intValue] == 0) {
            
        }else{
            [SVProgressHUD showSimpleText:dict[@"status_info"]];
        }
        
    }failure:^(NSError *error) {
        
        [SVProgressHUD showSimpleText:TIP_OF_NO_NETWORK];
    }];
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

-(void)manager:(Manager *)manager updateGPSServiceInfo:(NSInteger)bikeid{
    
    
    _servicesModel = [[LVFmdbTool queryPerpheraServicesInfoData:[NSString stringWithFormat:@"SELECT * FROM peripheraServicesInfo_modals WHERE type LIKE '%zd' AND bikeid LIKE '%zd'", 1,bikeid]] firstObject];
    _GPSServiceDeadLineItem.text_right = _servicesModel.type ==0? [NSString stringWithFormat:@"试用期%d天",_servicesModel.left_days]: [NSString stringWithFormat:@"%d天",_servicesModel.left_days];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.table reloadData];
    });
}

@end
