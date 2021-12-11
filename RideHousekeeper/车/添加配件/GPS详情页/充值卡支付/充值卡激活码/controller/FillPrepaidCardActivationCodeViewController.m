//
//  FillPrepaidCardActivationCodeViewController.m
//  RideHousekeeper
//
//  Created by Apple on 2020/3/4.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import "FillPrepaidCardActivationCodeViewController.h"
#import "OrderDetailViewController.h"
#import <CRBoxInputView/CRBoxInputView.h>
#import "Manager.h"
@interface FillPrepaidCardActivationCodeViewController ()
@property(nonatomic, strong) CRBoxInputView *boxInputView;
@property(nonatomic, strong) ServiceOrder *serviceOrder;
@property(nonatomic, strong) ServiceCard *cardModel;
@property(nonatomic, assign) NSInteger bikeid;
@end

@implementation FillPrepaidCardActivationCodeViewController

-(void)setOrderInfo:(ServiceOrder *)model serviceCardModel:(ServiceCard *)cardModel bikeid:(NSInteger)bikeid{
    _serviceOrder = model;
    _cardModel = cardModel;
    _bikeid = bikeid;
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

-(void)orderCardPay{
    
    NSString *token = [QFTools getdata:@"token"];
    NSString *URLString = [NSString stringWithFormat:@"%@%@",QGJURL,@"app/service/order/pay_by_card"];
    //NSDictionary *pay_params = @{@"card_no":_cardModel.card_no,@"card_password":_boxInputView.textField.text,@"promotion_id":@(_serviceOrder.promotion_id)};
    //NSDictionary *parameters = @{@"token":token,@"order_id":@(_serviceOrder.ID),@"pay_channel":@(1),@"pay_params":pay_params};
    NSDictionary *parameters = @{@"token":token,@"bike_id":@(_bikeid),@"card_no":_cardModel.card_no,@"card_password":_boxInputView.textField.text};
    [[HttpRequest sharedInstance] postWithURLString:URLString parameters:parameters success:^(id _Nullable dict) {
        
        if ([dict[@"status"] intValue] == 0) {
            
            NSDictionary *data = dict[@"data"];
            ServiceOrder* model = [ServiceOrder yy_modelWithDictionary:data[@"order"]];
            
            if (self.payOrderSuccess) {
                self.payOrderSuccess();
                [self.navigationController popViewControllerAnimated:YES];
                return ;
            }
            [self orderGet:model.ID];
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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupNavView];
    [self setupView];
}

- (void)setupNavView{
    [super setupNavView];
    self.navView.backgroundColor = [QFTools colorWithHexString:MainColor];
    self.navView.showBottomLabel = NO;
    [self.navView.centerButton setTitle:@"填写激活码"forState:UIControlStateNormal];
    @weakify(self);
    [self.navView.leftButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    self.navView.leftButtonBlock = ^{
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    };
}

-(void)setupView{
    
    UILabel *promptLab = [[UILabel alloc] init];
    promptLab.text = @"请刮出卡号下的激活码后输入";
    promptLab.font = FONT_PINGFAN(13);
    promptLab.textColor = [QFTools colorWithHexString:@"#333333"];
    [self.view addSubview:promptLab];
    [promptLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(20);
        make.top.equalTo(self.navView.mas_bottom).offset(20);
        make.height.mas_equalTo(18);
    }];
    
    _boxInputView = [self generateBoxInputView_customBox];
    _boxInputView.textDidChangeblock = ^(NSString *text, BOOL isFinished) {
        
        if (text.length > 0) {

        }
    };
    [self.view addSubview:_boxInputView];
    [_boxInputView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.view).offset(28);
//        make.right.equalTo(self.view).offset(-28);
        make.width.mas_equalTo(ScreenWidth - 56);
        make.height.mas_equalTo(45);
        make.centerX.offset(0);
        make.top.equalTo(promptLab.mas_bottom).offset(20);
    }];
    
    UIButton *payBtn = [[UIButton alloc] init];
    payBtn.backgroundColor = [QFTools colorWithHexString:@"#06C1AE"];
    payBtn.layer.cornerRadius = 22;
    payBtn.layer.masksToBounds = YES;
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
        [self orderCardPay];
    }];
    
}

#pragma mark - Normal
- (CRBoxInputView *)generateBoxInputView_normal
{
    CRBoxInputView *boxInputView = [CRBoxInputView new];
    [boxInputView loadAndPrepareViewWithBeginEdit:YES];
    
    if (@available(iOS 12.0, *)) {
        boxInputView.textContentType = UITextContentTypeOneTimeCode;
    }else if (@available(iOS 10.0, *)) {
        boxInputView.textContentType = @"one-time-code";
    }
    
    return boxInputView;
}

- (CRBoxInputView *)generateBoxInputView_placeholder
{
    CRBoxInputCellProperty *cellProperty = [CRBoxInputCellProperty new];
    cellProperty.cellPlaceholderTextColor = [UIColor colorWithRed:114/255.0 green:116/255.0 blue:124/255.0 alpha:0.3];
    cellProperty.cellPlaceholderFont = [UIFont systemFontOfSize:20];
    
    CRBoxInputView *_boxInputView = [CRBoxInputView new];
    _boxInputView.ifNeedCursor = NO;
    _boxInputView.placeholderText = @"露可娜娜";
    _boxInputView.customCellProperty = cellProperty;
    [_boxInputView loadAndPrepareViewWithBeginEdit:YES];
    
    return _boxInputView;
}

#pragma mark - CustomBox
- (CRBoxInputView *)generateBoxInputView_customBox
{
    CRBoxInputCellProperty *cellProperty = [CRBoxInputCellProperty new];
    cellProperty.cellBgColorNormal = [UIColor whiteColor];
    cellProperty.cellBgColorSelected = [UIColor whiteColor];
    cellProperty.cellCursorColor = [QFTools colorWithHexString:MainColor];
    cellProperty.cellCursorWidth = 2;
    cellProperty.cellCursorHeight = 27;
    cellProperty.cornerRadius = 4;
    cellProperty.borderWidth = 0;
    cellProperty.cellFont = [UIFont boldSystemFontOfSize:24];
    cellProperty.cellTextColor = [QFTools colorWithHexString:MainColor];
    cellProperty.configCellShadowBlock = ^(CALayer * _Nonnull layer) {
        layer.shadowColor = [QFTools colorWithHexString:@"#999999"].CGColor;
        layer.shadowOpacity = 1;
        layer.shadowOffset = CGSizeMake(0, 2);
        layer.shadowRadius = 4;
    };

    CRBoxInputView *_boxInputView = [CRBoxInputView new];
    _boxInputView.codeLength = 6;
    _boxInputView.boxFlowLayout.itemSize = CGSizeMake(45, 45);
    _boxInputView.customCellProperty = cellProperty;
    [_boxInputView loadAndPrepareViewWithBeginEdit:YES];

    return _boxInputView;
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
            [[Manager shareManager] updateGPSServiceInfo:_bikeid];
            
            NSMutableArray *viewCtrs = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
            for (UIViewController *controller in viewCtrs){
               if ([controller isKindOfClass:[NSClassFromString(@"ExtendGPSServerViewController") class]]) {
                   NSInteger index = [viewCtrs indexOfObject:controller] + 1;
                   [viewCtrs removeObjectsInRange: NSMakeRange(index, viewCtrs.count - index)];
                   OrderDetailViewController *orderVc = [[OrderDetailViewController alloc] init];
                   [orderVc setOrderInfo:model bikeid:_bikeid type:1];
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
