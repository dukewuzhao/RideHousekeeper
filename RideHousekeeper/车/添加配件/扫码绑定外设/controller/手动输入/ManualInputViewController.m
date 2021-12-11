//
//  ManualInputViewController.m
//  RideHousekeeper
//
//  Created by Apple on 2017/11/13.
//  Copyright © 2017年 Duke Wu. All rights reserved.
//

#import "ManualInputViewController.h"
#import "BindingDeviceViewModel.h"
#import "MultipleBindingLogicProcessingViewController.h"
#import "ProductDetailsViewController.h"
#import "BindingGuidePopView.h"
#import "BindingHitView.h"
#import "BottomBtn.h"
#import "UpdateViewModel.h"
#import "Manager.h"
#define UNLIMITEDALPHA @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
#define ALPHANUM @"ABCDEFabcdef0123456789"
@interface ManualInputViewController ()<UITextFieldDelegate>
@property(nonatomic,strong)  DeviceInfoModel *deviceInfoModel;
@property (nonatomic,strong) BindingGuidePopView *popview;
@property (nonatomic,weak)   UITextField *importField;
@property (nonatomic,weak)   UIButton *sureBtn;
@property (nonatomic,strong) BikeModel *bikeModel;
@property (nonatomic,strong) BindingDeviceViewModel *deviceModel;
@property (nonatomic,strong) UpdateViewModel *updateModel;
@property (nonatomic,assign) BindingType bindingType;
@end

@implementation ManualInputViewController

-(BindingDeviceViewModel *)deviceModel{
    if (!_deviceModel) {
        _deviceModel = [[BindingDeviceViewModel alloc] init];
    }
    return _deviceModel;
}

-(UpdateViewModel *)updateModel{
    if (!_updateModel) {
        _updateModel = [[UpdateViewModel alloc] init];
    }
    return _updateModel;
}

-(void)setChangeDeviceType:(BindingType)type{
    _bindingType = type;
}

- (void)setBikeid:(NSInteger)bikeid{
    _bikeid = bikeid;
    _bikeModel = [LVFmdbTool queryBikeData:[NSString stringWithFormat:@"SELECT * FROM bike_modals WHERE bikeid LIKE '%zd'", bikeid]].firstObject;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _deviceInfoModel = [DeviceInfoModel new];
    [self setupNavView];
    [self setupView];
    
    if (_bindingType == BindingChangeGPS) {
        BindingHitView *hitView = [[BindingHitView alloc] initWithFrame:CGRectZero title:@"更换中控前请确认车辆配件信息，更换后相关配件和指纹需要重新配置。" color:[UIColor colorWithRed:255/255.0 green:94/255.0 blue:0/255.0 alpha:.15]];
        [self.view addSubview:hitView];
        [hitView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.view);
            make.top.equalTo(self.navView.mas_bottom);
            make.height.mas_equalTo(50);
        }];
    }
}

- (void)setupNavView{
    [super setupNavView];
    self.navView.showBottomLabel = NO;
    [self.navView.centerButton setTitle:_naVtitle forState:UIControlStateNormal];
    @weakify(self);
    
    [self.navView.rightButton setImage:[UIImage imageNamed:@"signout_input"] forState:UIControlStateNormal];
    self.navView.rightButtonBlock = ^{
      
        @strongify(self);
        UIViewController *accVc = self.navigationController.viewControllers[self.navigationController.viewControllers.count-3];
        [self.navigationController popToViewController:accVc animated:YES];
    };
    
}

-(void)setupView{
    NSInteger intervalHeight = 0;
    if (_bindingType == BindingChangeGPS) intervalHeight = 50;
    
    UILabel *PromptLal = [[UILabel alloc] initWithFrame:CGRectMake(50, 50+navHeight +intervalHeight, ScreenWidth - 100, 20)];
    PromptLal.text = @"请输入正确的SN";
    PromptLal.textColor = [QFTools colorWithHexString:@"#666666"];
    PromptLal.font = [UIFont systemFontOfSize:15];
    PromptLal.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:PromptLal];
    
    @weakify(self);
    UITextField *importField = [self addOneTextFieldWithTitle:@"请输入SN" imageName:nil imageNameWidth:10 Frame:CGRectMake(40, CGRectGetMaxY(PromptLal.frame) + 15, ScreenWidth - 80, 35)];
    importField.textColor = [UIColor blackColor];
    importField.layer.borderColor = [QFTools colorWithHexString:MainColor].CGColor;
    importField.layer.borderWidth = 1.0;
    [importField.layer setCornerRadius:5.0];
    importField.textAlignment = NSTextAlignmentCenter;
    [importField.rac_textSignal subscribeNext:^(id x) {
        @strongify(self);
        NSString *a= x;
        if (a.length >0) {
            [self.sureBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            self.sureBtn.backgroundColor = [QFTools colorWithHexString:MainColor];
        }else{
            [self.sureBtn setTitleColor:[QFTools colorWithHexString:@"#666666"] forState:UIControlStateNormal];
            self.sureBtn.backgroundColor = [QFTools colorWithHexString:@"#d9d9d9"];
        }
        
    }];
    [self.view addSubview:importField];
    self.importField = importField;
    
    UIButton *sureBtn = [[UIButton alloc] initWithFrame:CGRectMake(importField.x, CGRectGetMaxY(importField.frame) + 20, importField.width, 35)];
    [sureBtn setTitle:@"确定" forState:UIControlStateNormal];
    [sureBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [sureBtn addTarget:self action:@selector(sureBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [sureBtn.layer setCornerRadius:5.0];
    sureBtn.backgroundColor = [QFTools colorWithHexString:@"#666666"];
    [self.view addSubview:sureBtn];
    self.sureBtn = sureBtn;
    
    BottomBtn *SwitchBtn = [[BottomBtn alloc] init];
    SwitchBtn.direction = @"left";
    SwitchBtn.width = 100;
    SwitchBtn.height = 35;
    SwitchBtn.x = ScreenWidth/2 - 50;
    SwitchBtn.y = CGRectGetMaxY(sureBtn.frame) + 75;
    [SwitchBtn setTitle:@"切换扫码" forState:UIControlStateNormal];
    [SwitchBtn setTitleColor:[QFTools colorWithHexString:@"#666666"] forState:UIControlStateNormal];
    [SwitchBtn setImage:[UIImage imageNamed:@"sweep_codes"] forState:UIControlStateNormal];
    SwitchBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    SwitchBtn.contentMode = UIViewContentModeCenter;
    [SwitchBtn addTarget:self action:@selector(SwitchBtnClick) forControlEvents:UIControlEventTouchUpInside];
    SwitchBtn.backgroundColor = [UIColor clearColor];
    [self.view addSubview:SwitchBtn];
    
    UIView *partingline = [[UIView alloc] initWithFrame:CGRectMake(SwitchBtn.x, CGRectGetMaxY(SwitchBtn.frame)+2, SwitchBtn.width, 1)];
    partingline.backgroundColor = [QFTools colorWithHexString:@"#999999"];
    [self.view addSubview:partingline];
}

-(void)SwitchBtnClick{
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)sureBtnClick{
    
    if ([QFTools isBlankString:self.importField.text]) {
        
        [SVProgressHUD showSimpleText:@"条码不能为空"];
        
        return;
    }
    
    if (_type == 10) {
        //兑换卡
        NSString *codeName = self.importField.text;
        ProductDetailsViewController *productVc = [[ProductDetailsViewController alloc] init];
        [productVc setServiceTransferCode:codeName bikeid:_bikeid];
        [self.navigationController pushViewController:productVc animated:YES];
        
    }else if (_type == 11) {
        //兑换卡
        NSString *codeName = self.importField.text;
        if ([QFTools isBlankString:codeName]) {
            
            [SVProgressHUD showSimpleText:@"请输入正确的兑换卡SN"];
            return;
        }
        if (self.input) self.input(codeName);
    }else if (_type == 12) {
        //兑换卡扫描
        NSString *codeName = self.importField.text;
        if ([QFTools isBlankString:codeName]) {
            
            [SVProgressHUD showSimpleText:@"请输入正确的定位器SN"];
            return;
        }
        if (self.input) self.input(codeName);
        
    }else if (_type == 6) {
        NSString *str = self.importField.text;
        if (str.length != 8) {
            [SVProgressHUD showSimpleText:@"该类型不是胎压"];
            return;
        }
        NSMutableArray *bikemodals = [LVFmdbTool queryBikeData:[NSString stringWithFormat:@"SELECT * FROM bike_modals WHERE bikeid LIKE '%zd'", _bikeid]];
        BikeModel *bikemodel = bikemodals.firstObject;
        if (bikemodel.tpm_func == 0) {
            
            [SVProgressHUD showSimpleText:@"该中控不支持胎压监测"];
            return;
        }
        [LoadView sharedInstance].protetitle.text = @"绑定胎压中";
        [[LoadView sharedInstance] show];
        _deviceInfoModel = [DeviceInfoModel new];
        _deviceInfoModel.device_id = 0;
        _deviceInfoModel.type = self.type;
        _deviceInfoModel.mac = str;
        _deviceInfoModel.sn = [NSString stringWithFormat:@"3000%@",str];
        _deviceInfoModel.seq = self.seq;
        @weakify(self);
        [CommandDistributionServices addTirePressure:_deviceInfoModel.seq - 1 mac:_deviceInfoModel.mac data:^(id data) {
            @strongify(self);
            if ([data intValue] == ConfigurationFail) {
                [[LoadView sharedInstance] hide];
                [SVProgressHUD showSimpleText:@"绑定失败"];
            }else{
                [self.deviceModel bindKey:_bikeid :_deviceInfoModel success:^(id dict) {
                    [[LoadView sharedInstance] hide];
                    if ([dict[@"status"] intValue] == 0) {
                        
                        NSDictionary *deviceDiction = dict[@"data"];
                        NSMutableArray *deviceinfo = deviceDiction[@"device_info"];
                        for (NSDictionary *devicedic in deviceinfo) {
                            DeviceInfoModel* deviceInfoModel = [DeviceInfoModel yy_modelWithDictionary:devicedic];
                            NSString *sn = deviceInfoModel.sn;
                            if ([_deviceInfoModel.sn isEqualToString:sn]) {
                                
                                PeripheralModel *pmodel = [PeripheralModel modalWith:self.bikeid deviceid:deviceInfoModel.device_id type:deviceInfoModel.type seq:deviceInfoModel.seq mac:deviceInfoModel.mac sn:deviceInfoModel.sn qr:deviceInfoModel.qr firmversion:deviceInfoModel.firm_version default_brand_id:deviceInfoModel.default_brand_id default_model_id:deviceInfoModel.default_model_id prod_date:deviceInfoModel.prod_date imei:deviceInfoModel.imei imsi:deviceInfoModel.imsi sign:deviceInfoModel.sign desc:deviceInfoModel.desc ts:deviceInfoModel.ts bind_sn:deviceInfoModel.bind_sn bind_mac:deviceInfoModel.bind_mac is_used:deviceInfoModel.is_used];
                                [LVFmdbTool insertDeviceModel:pmodel];
                                
                                for (ServiceInfoModel *servicesInfo in deviceInfoModel.service){
                                    
                                    PerpheraServicesInfoModel *service = [PerpheraServicesInfoModel modelWith:self.bikeid deviceid:deviceInfoModel.device_id ID:servicesInfo.ID type:servicesInfo.type title:servicesInfo.title brand_id:servicesInfo.brand_id begin_date:servicesInfo.begin_date end_date:servicesInfo.end_date left_days:servicesInfo.left_days];
                                    [LVFmdbTool insertPerpheraServicesInfoModel:service];
                                }
                                
                                [[Manager shareManager] bindingPeripheralSucceeded:pmodel];
                            }
                        }
                        [SVProgressHUD showSimpleText:@"绑定胎压成功"];
                        UIViewController *accVc = self.navigationController.viewControllers[self.navigationController.viewControllers.count-3];
                        [self.navigationController popToViewController:accVc animated:YES];
                    }else{
                        [SVProgressHUD showSimpleText:@"绑定胎压失败"];
                    }
                } failure:^(NSError * error) {
                    [[LoadView sharedInstance] hide];
                }];
            }
        } error:^(CommandStatus status) {
            switch (status) {
                case SendSuccess:
                    NSLog(@"绑定胎压发送成功");
                    break;
                    
                default:
                    [[LoadView sharedInstance] hide];
                    [SVProgressHUD showSimpleText:@"绑定失败"];
                    break;
            }
        }];
        
    }else{
        
        NSString *codeName = self.importField.text;
        [LoadView sharedInstance].protetitle.text = @"添加配件中";
        [[LoadView sharedInstance] show];
        
        [self.deviceModel checkKey:_bikeid :codeName success:^(id dict) {
            
            if ([dict[@"status"] intValue] == 0) {
                
                [[LoadView sharedInstance] hide];
                NSDictionary *deviceDiction = dict[@"data"];
                NSMutableArray *deviceinfo = deviceDiction[@"device_info"];
                for (NSDictionary *devicedic in deviceinfo) {
                    DeviceInfoModel* deviceInfoModel = [DeviceInfoModel yy_modelWithDictionary:devicedic];
                    if ([deviceInfoModel.sn isEqualToString:codeName]) {
                        
                        NSString *mac = deviceInfoModel.mac;
                        NSInteger deviceid = deviceInfoModel.device_id;
                        PeripheralModel *pmodel = [PeripheralModel modalWith:_bikeid deviceid:deviceid type:deviceInfoModel.type seq:deviceInfoModel.seq mac:mac sn:deviceInfoModel.sn qr:deviceInfoModel.qr firmversion:deviceInfoModel.firm_version default_brand_id:deviceInfoModel.default_brand_id default_model_id:deviceInfoModel.default_model_id prod_date:deviceInfoModel.prod_date imei:deviceInfoModel.imei imsi:deviceInfoModel.imsi sign:deviceInfoModel.sign desc:deviceInfoModel.desc ts:deviceInfoModel.ts bind_sn:deviceInfoModel.bind_sn bind_mac:deviceInfoModel.bind_mac is_used:deviceInfoModel.is_used];
                        [LVFmdbTool insertDeviceModel:pmodel];
                        
                        for (ServiceInfoModel *servicesInfo in deviceInfoModel.service){
                            
                            PerpheraServicesInfoModel *service = [PerpheraServicesInfoModel modelWith:self.bikeid deviceid:deviceInfoModel.device_id ID:servicesInfo.ID type:servicesInfo.type title:servicesInfo.title brand_id:servicesInfo.brand_id begin_date:servicesInfo.begin_date end_date:servicesInfo.end_date left_days:servicesInfo.left_days];
                            [LVFmdbTool insertPerpheraServicesInfoModel:service];
                        }
                        
                        [[Manager shareManager] bindingPeripheralSucceeded:pmodel];
                    }
                }
                        
                [SVProgressHUD showSimpleText:@"绑定成功"];
                [self.navigationController popViewControllerAnimated:YES];
            }else if([dict[@"status"] intValue] == 2000){
                //GPS被使用
                [[LoadView sharedInstance] hide];
                
                if (self.bikeModel.gps_func == 0 && self.bikeid != 0 && self.bindingType == BindingBike) {
                    [SVProgressHUD showSimpleText:@"无效的设备"];
                    return;
                }
                
                NSDictionary *data = dict[@"data"];
                DeviceInfoModel *deviceInfo = [DeviceInfoModel yy_modelWithDictionary:data[@"device_info"]];
                MultipleBindingLogicProcessingViewController* vc = [[MultipleBindingLogicProcessingViewController alloc] init];
                if (self.bindingType == BindingChangeGPS) {
                    [vc showView:ChangeGPS :deviceInfo :self.bikeid];
                }else{
                    [vc showView:GPSKitWithECU :deviceInfo :self.bikeid];
                }
                [self.navigationController pushViewController:vc animated:YES];
            }else if([dict[@"status"] intValue] == 2100){
                //GPS被使用
                [[LoadView sharedInstance] hide];
                
                if (self.bikeModel.gps_func == 0 && self.bikeid != 0 && self.bindingType == BindingBike) {
                    [SVProgressHUD showSimpleText:@"无效的设备"];
                    return;
                }
                
                NSDictionary *data = dict[@"data"];
                DeviceInfoModel *deviceInfo = [DeviceInfoModel yy_modelWithDictionary:data[@"device_info"]];
                MultipleBindingLogicProcessingViewController* vc = [[MultipleBindingLogicProcessingViewController alloc] init];
                if (self.bindingType == BindingChangeGPS) {
                    [vc showView:DuplicateChangeGPS :deviceInfo :self.bikeid];
                }else{
                    [vc showView:DuplicateGPSKitWithECU :deviceInfo :self.bikeid];
                }
                [self.navigationController pushViewController:vc animated:YES];
            }else if([dict[@"status"] intValue] == 3000){
                [[LoadView sharedInstance] hide];
                
                if (self.bikeModel.gps_func == 0 && self.bikeid != 0 && self.bindingType == BindingBike) {
                    [SVProgressHUD showSimpleText:@"无效的设备"];
                    return;
                }
                
                NSDictionary *data = dict[@"data"];
                DeviceInfoModel *deviceInfo = [DeviceInfoModel yy_modelWithDictionary:data[@"device_info"]];
                MultipleBindingLogicProcessingViewController* vc = [[MultipleBindingLogicProcessingViewController alloc] init];
                if (_bikeid == 0) {
                    [self matchingScanLogic:SingleGPSBinding :deviceInfo :vc];
                }else{
                    if (self.bindingType == BindingChangeGPS) {
                        [vc showView:ChangeGPS :deviceInfo :self.bikeid];
                    }else{
                        [vc showView:AccessoriesGPSBinding :deviceInfo :self.bikeid];
                    }
                    [self.navigationController pushViewController:vc animated:YES];
                }
                
            }else if([dict[@"status"] intValue] == 3100){
                [[LoadView sharedInstance] hide];
                
                if (self.bikeModel.gps_func == 0 && self.bikeid != 0 && self.bindingType == BindingBike) {
                    [SVProgressHUD showSimpleText:@"无效的设备"];
                    return;
                }
                
                NSDictionary *data = dict[@"data"];
                DeviceInfoModel *deviceInfo = [DeviceInfoModel yy_modelWithDictionary:data[@"device_info"]];
                MultipleBindingLogicProcessingViewController* vc = [[MultipleBindingLogicProcessingViewController alloc] init];
                if (_bikeid == 0) {
                    [self matchingScanLogic:DuplicateSingleGPSBinding :deviceInfo :vc];
                }else{
                    if (self.bindingType == BindingChangeGPS) {
                        [vc showView:DuplicateChangeGPS :deviceInfo :self.bikeid];
                    }else{
                        [vc showView:DuplicateAccessoriesGPSBinding :deviceInfo :self.bikeid];
                    }
                    [self.navigationController pushViewController:vc animated:YES];
                }
                
            }else if([dict[@"status"] intValue] == 4000){
                //GPSKitWithOutECU
                [[LoadView sharedInstance] hide];
                
                if (self.bikeModel.gps_func == 0 && self.bikeid != 0 && self.bindingType == BindingBike) {
                    [SVProgressHUD showSimpleText:@"无效的设备"];
                    return;
                }
                
                NSDictionary *data = dict[@"data"];
                DeviceInfoModel *deviceInfo = [DeviceInfoModel yy_modelWithDictionary:data[@"device_info"]];
                MultipleBindingLogicProcessingViewController* vc = [[MultipleBindingLogicProcessingViewController alloc] init];
                if (self.bindingType == BindingChangeGPS) {
                    [vc showView:ChangeGPS :deviceInfo :self.bikeid];
                }else{
                    [vc showView:GPSKitWithOutECU :deviceInfo :self.bikeid];//需要检测是否要配成套件
                }
                [self.navigationController pushViewController:vc animated:YES];
            }else if([dict[@"status"] intValue] == 4100){
                //GPSKitWithOutECU
                [[LoadView sharedInstance] hide];
                
                if (self.bikeModel.gps_func == 0 && self.bikeid != 0 && self.bindingType == BindingBike) {
                    [SVProgressHUD showSimpleText:@"无效的设备"];
                    return;
                }
                
                NSDictionary *data = dict[@"data"];
                DeviceInfoModel *deviceInfo = [DeviceInfoModel yy_modelWithDictionary:data[@"device_info"]];
                MultipleBindingLogicProcessingViewController* vc = [[MultipleBindingLogicProcessingViewController alloc] init];
                if (self.bindingType == BindingChangeGPS) {
                    [vc showView:DuplicateChangeGPS :deviceInfo :self.bikeid];
                }else{
                    [vc showView:DuplicateGPSKitWithOutECU :deviceInfo :self.bikeid];//需要检测是否要配成套件
                }
                [self.navigationController pushViewController:vc animated:YES];
            }else if([dict[@"status"] intValue] == 6000){
                //GPSKitWithOutECU
                [[LoadView sharedInstance] hide];
                
                if (self.bikeModel.gps_func == 0 && self.bikeid != 0 && self.bindingType == BindingBike) {
                    [SVProgressHUD showSimpleText:@"无效的设备"];
                    return;
                }
                
                [SVProgressHUD showSimpleText:@"该配件已被绑定"];
            }else if([dict[@"status"] intValue] == 1042){
                [[LoadView sharedInstance] hide];
                
                NSMutableArray *peripheraModals = [LVFmdbTool queryPeripheraData:[NSString stringWithFormat:@"SELECT * FROM periphera_modals WHERE type LIKE '%zd' AND bikeid LIKE '%zd'", 4,self.bikeModel.bikeid]];
                if (peripheraModals.count == 0) {
                    [SVProgressHUD showSimpleText:@"无效的设备"];
                    return;
                }
                
                ProductDetailsViewController *productVc = [[ProductDetailsViewController alloc] init];
                [productVc setRechargeCardNo:codeName bikeid:_bikeid];
                [self.navigationController pushViewController:productVc animated:YES];
                
            }else{
                [[LoadView sharedInstance] hide];
                [SVProgressHUD showSimpleText:dict[@"status_info"]];
            }
            
        } failure:^(NSError * error) {
            [[LoadView sharedInstance] hide];
        }];
    }
    
}

-(void)matchingScanLogic:(ProcessingtType)type :(DeviceInfoModel *)deviceInfo :(MultipleBindingLogicProcessingViewController*)vc{
     
    NSMutableArray *bikeAry = [LVFmdbTool queryBikeData:nil];
    NSMutableArray *copyBikeAry = [bikeAry mutableCopy];
    [bikeAry enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        BikeModel *model = (BikeModel *)obj;
        if (![QFTools isBlankString:model.sn]) {
            if (model.builtin_gps == 1) {
                [copyBikeAry removeObject:obj];
            }else{
                NSMutableArray *peripheraModals = [LVFmdbTool queryPeripheraData:[NSString stringWithFormat:@"SELECT * FROM periphera_modals WHERE type LIKE '%zd' AND bikeid LIKE '%zd'", 4,model.bikeid]];
                if (peripheraModals.count != 0 || model.gps_func == 0) {
                    [copyBikeAry removeObject:obj];
                }
            }
        }else{
            [copyBikeAry removeObject:obj];
        }
    }];
    if (copyBikeAry.count > 0) {
        _popview = [[BindingGuidePopView alloc] init];
        [_popview showInView:self.view withParams:copyBikeAry];
        @weakify(self);
        _popview.bindingBikeClickBlock = ^(NSInteger index) {
            @strongify(self);
            switch (index) {
                case -1:{//单GPS
                    [vc showView:SingleGPSBinding :deviceInfo :self.bikeid];
                    [self.navigationController pushViewController:vc animated:YES];
                    break;
                }
                    
                case -2:
                    break;
                default:
                    //变成配件
                    [vc showView:AccessoriesGPSBinding :deviceInfo :[(BikeModel *)copyBikeAry[index] bikeid]];
                    [self.navigationController pushViewController:vc animated:YES];
                    break;
            }
        };
    }else{
        [vc showView:SingleGPSBinding :deviceInfo :_bikeid];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - 添加输入框
- (UITextField *)addOneTextFieldWithTitle:(NSString *)title imageName:(NSString *)imageName imageNameWidth:(CGFloat)width Frame:(CGRect)rect
{
    UITextField *field = [[UITextField alloc] init];
    field.frame = rect;
    field.backgroundColor = [UIColor whiteColor];
    field.borderStyle = UITextBorderStyleNone;
    field.returnKeyType = UIReturnKeyDone;
    field.autocorrectionType = UITextAutocorrectionTypeNo;
    field.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [field becomeFirstResponder];
     field.keyboardType = UIKeyboardTypeDefault;
    field.delegate = self;
    field.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    field.leftViewMode = UITextFieldViewModeAlways;
    field.clearButtonMode = UITextFieldViewModeWhileEditing;
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.alignment = NSTextAlignmentCenter;
    NSAttributedString *attri = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:[QFTools colorWithHexString:@"#adaaa8"],NSFontAttributeName:[UIFont fontWithName:@"Arial" size:14], NSParagraphStyleAttributeName:style}];
    field.attributedPlaceholder = attri;
    [field setFont:[UIFont fontWithName:@"Helvetica-Bold" size:17]];
    return field;
}

#pragma mark - 点击屏幕取消键盘
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (_type == 4) {
        NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:UNLIMITEDALPHA] invertedSet];
        NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
        return [string isEqualToString:filtered];
    }
    
    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:ALPHANUM] invertedSet];
    NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    return [string isEqualToString:filtered];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    return YES;
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
