//
//  FillTransferPasswordViewController.m
//  RideHousekeeper
//
//  Created by Apple on 2020/3/4.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import "FillTransferPasswordViewController.h"
#import "OrderDetailViewController.h"
#import "Manager.h"
@interface FillTransferPasswordViewController ()
@property(nonatomic,assign) NSInteger bikeId;
@property(nonatomic,strong) DeviceInfoModel* deviceModel;
@property(nonatomic,strong) UITextField *importField;
@end

@implementation FillTransferPasswordViewController

-(void)setDeviceInfoModel:(DeviceInfoModel *)deviceModel bikeid:(NSInteger)bikeid{
    _bikeId = bikeid;
    _deviceModel = deviceModel;
}

-(void)orderGet:(NSInteger)orderId{
    
    NSString *token = [QFTools getdata:@"token"];
    NSNumber *order_id = @(orderId);
    NSString *URLString = [NSString stringWithFormat:@"%@%@",QGJURL,@"app/service/order/get"];
    NSDictionary *parameters = @{@"token":token, @"order_id": order_id};
    [[HttpRequest sharedInstance] postWithURLString:URLString parameters:parameters success:^(id _Nullable dict) {
        
        if ([dict[@"status"] intValue] == 0) {
            NSDictionary *data = dict[@"data"];
            ServiceOrder* model = [ServiceOrder yy_modelWithDictionary:data[@"order"]];
            if (model.stat != 0) {
                [self getbikelist:model];
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

-(void)getOrderTransEntity:(NSInteger)deviceId :(NSInteger)bikeid{
    NSString *token = [QFTools getdata:@"token"];
    NSNumber * bike_id = @(bikeid);
    NSString *URLString = [NSString stringWithFormat:@"%@%@",QGJURL,@"app/service/order/trans_entity"];
    NSDictionary *parameters = @{@"token":token,@"bike_id":bike_id,@"trans_from_id":@(deviceId),@"is_pay":@(1)};
    
    [[HttpRequest sharedInstance] postWithURLString:URLString parameters:parameters success:^(id _Nullable dict) {
        
        if ([dict[@"status"] intValue] == 0) {
            
            NSDictionary *data = dict[@"data"];
            ServiceOrder* model = [ServiceOrder yy_modelWithDictionary:data[@"order"]];
            [self orderGet:model.ID];
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
    
    [self setupView];
    
    UIButton *payBtn = [[UIButton alloc] init];
    payBtn.backgroundColor = [QFTools colorWithHexString:@"#06C1AE"];
    payBtn.layer.cornerRadius = 22;
    [self.view addSubview:payBtn];
    [payBtn setTitle:@"提交充值" forState:UIControlStateNormal];
    payBtn.titleLabel.font = FONT_PINGFAN(18);
    [payBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [payBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-90);
        make.size.mas_equalTo(CGSizeMake(214, 44));
    }];
    @weakify(self);
    [[payBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        
        if ([QFTools isBlankString:self.importField.text]) {
            [SVProgressHUD showSimpleText:@"请输入密码"];
            return ;
        }else if (![[QFTools getdata:@"password"] isEqualToString:self.importField.text]){
            [SVProgressHUD showSimpleText:@"密码输入错误"];
            return ;
        }
        [self getOrderTransEntity:self.deviceModel.device_id :self.bikeId];
    }];
}

- (void)setupNavView{
    [super setupNavView];
    self.navView.backgroundColor = [QFTools colorWithHexString:MainColor];
    self.navView.showBottomLabel = NO;
    [self.navView.centerButton setTitle:@"填写密码"forState:UIControlStateNormal];
    @weakify(self);
    [self.navView.leftButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    self.navView.leftButtonBlock = ^{
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    };
}

-(void)setupView{
    
    _importField = [self addOneTextFieldWithTitle:@"请输入您的账号密码确认操作" imageName:nil imageNameWidth:10 Frame:CGRectMake(28, CGRectGetMaxY(self.navView.frame) + 58, ScreenWidth - 58, 44)];
    _importField.textColor = [UIColor blackColor];
    _importField.layer.borderColor = [QFTools colorWithHexString:MainColor].CGColor;
    _importField.layer.borderWidth = 1.0;
    [_importField.layer setCornerRadius:22.0];
    _importField.textAlignment = NSTextAlignmentCenter;
    [_importField.rac_textSignal subscribeNext:^(id x) {
        
        NSString *a= x;
        if (a.length >0) {
            
        }
        
    }];
    [self.view addSubview:_importField];
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
    field.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    field.leftViewMode = UITextFieldViewModeAlways;
    field.clearButtonMode = UITextFieldViewModeWhileEditing;
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    //style.alignment = NSTextAlignmentCenter;
    NSAttributedString *attri = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:[QFTools colorWithHexString:@"#cccccc"],NSFontAttributeName:FONT_PINGFAN(13), NSParagraphStyleAttributeName:style}];
    field.attributedPlaceholder = attri;
    [field setFont:FONT_PINGFAN(17)];
    return field;
}

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
            NSMutableArray *viewCtrs = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
            for (UIViewController *controller in viewCtrs){
               if ([controller isKindOfClass:[NSClassFromString(@"ExtendGPSServerViewController") class]]) {
                   NSInteger index = [viewCtrs indexOfObject:controller] + 1;
                   [viewCtrs removeObjectsInRange: NSMakeRange(index, viewCtrs.count - index)];
                   OrderDetailViewController *orderVc = [[OrderDetailViewController alloc] init];
                   [orderVc setOrderInfo:model bikeid:_bikeId type:1];
                   [viewCtrs addObject:orderVc];
                   [self.navigationController setViewControllers:viewCtrs animated:YES];
                   return;
                }
            }
            
        }else{
            [SVProgressHUD showSimpleText:dict[@"status_info"]];
        }
        
    }failure:^(NSError *error) {
        
        NSLog(@"error :%@",error);
        [SVProgressHUD showSimpleText:TIP_OF_NO_NETWORK];
    }];
}

@end
