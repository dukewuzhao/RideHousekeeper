//
//  LoginViewController.m
//  JinBang
//
//  Created by QFApple on 15/2/28.
//  Copyright (c) 2015年 qf365.com. All rights reserved.
//

#import "LoginViewController.h"
#import "MobileViewController.h"
#import "ForgetViewController.h"
//#import "ImprovePersonalViewController.h"

@interface LoginViewController () <UITextFieldDelegate>{
    NSString *child;
    NSString *main;
}
@property (nonatomic,weak) UITextField *usernameField; // 用户名
@property (nonatomic,weak) UITextField *passwordField; // 密码
@property (nonatomic,weak) UILabel *retrieveLabel; // 找回密码
@property (nonatomic,weak) UIButton *logBtn; // 登录按钮
@property (nonatomic,assign) CGFloat offSet;//页面移动距离

@end

@implementation LoginViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
}



- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self initheadView];
    [self setupField];    // 输入框
    [self setupLogBtn];  // 登录按钮
    [self setupResBtn];  // 注册按钮
    [self keyboardMonitor];
}

- (void)initheadView{
    
    UIImageView *logoImage = [[UIImageView alloc] init];
    logoImage.image = [UIImage imageNamed:@"login_logo"];
    [self.view addSubview:logoImage];
    [logoImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.mas_equalTo(ScreenHeight *.15);
    }];
}


#pragma mark - 用户名、密码输入框
- (void)setupField{
    // 用户名
    CGFloat usernameFieldY = ScreenHeight *.36+ 5;
    CGFloat usernameFieldW = ScreenWidth  - 70;
    CGFloat usernameFieldH = 35;
    CGFloat usernameFieldX = 35;
    
    UITextField *usernameField = [self addOneTextFieldWithTitle:@"请输入手机号" imageName:@"" imageNameWidth:10 Frame:CGRectMake(usernameFieldX, usernameFieldY, usernameFieldW, usernameFieldH)];
    usernameField.backgroundColor = [UIColor clearColor];
    if (![QFTools isBlankString:[QFTools getuserInfo:@"username"]]){
        usernameField.text = [QFTools getuserInfo:@"username"];
    }
    [self.view addSubview:usernameField];
    self.usernameField = usernameField;
    
    UIView *lineView =[[UIView alloc] initWithFrame:CGRectMake(usernameField.x, CGRectGetMaxY(usernameField.frame), usernameFieldW, 1)];
    lineView.backgroundColor = [QFTools colorWithHexString:@"#a7a9b0"];
    [self.view addSubview:lineView];
    
    // 密码
    CGFloat passwordFieldY = CGRectGetMaxY(self.usernameField.frame) + 20;
    CGFloat passwordFieldW = usernameFieldW;
    CGFloat passwordFieldH = usernameFieldH;
    CGFloat passwordFieldX = usernameFieldX;
    
    UITextField *passwordField = [self addOneTextFieldWithTitle:@"请输入密码" imageName:@"" imageNameWidth:10 Frame:CGRectMake(passwordFieldX, passwordFieldY, passwordFieldW, passwordFieldH)];
    passwordField.secureTextEntry = YES;
    passwordField.backgroundColor = [UIColor clearColor];
    [self.view addSubview:passwordField];
    self.passwordField = passwordField;
    
    UIView *lineView2 =[[UIView alloc] initWithFrame:CGRectMake(usernameField.x, CGRectGetMaxY(passwordField.frame), usernameFieldW, 1)];
    lineView2.backgroundColor = [QFTools colorWithHexString:@"#a7a9b0"];
    [self.view addSubview:lineView2];
    
    UIButton *forgetBtn = [[UIButton alloc] init];
    forgetBtn.width = 80;
    forgetBtn.height = 35;
    forgetBtn.x = ScreenWidth - 105;
    forgetBtn.y = CGRectGetMaxY(lineView2.frame)+ 5;
    forgetBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [forgetBtn setTitle:@"忘记密码" forState:UIControlStateNormal];
    [forgetBtn addTarget:self action:@selector(forgetBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    forgetBtn.tag = 300 + 2;
    [self.view addSubview:forgetBtn];
    
    [forgetBtn setTitleColor:[QFTools colorWithHexString:@"#c0c0c0"] forState:UIControlStateNormal];
    UIView *lineView3 =[[UIView alloc] initWithFrame:CGRectMake(forgetBtn.x, CGRectGetMaxY(forgetBtn.frame), forgetBtn.width, 1)];
    lineView3.backgroundColor = [QFTools colorWithHexString:@"#a7a9b0"];
    [self.view addSubview:lineView3];
    
}

-(void)secretShowOrHide:(UIButton *)btn{
    btn.selected = !btn.selected;
    //避免明文/密文切换后光标位置偏移
    self.passwordField.enabled = NO;    // the first one;
    self.passwordField.secureTextEntry = btn.selected;
    self.passwordField.enabled = YES;  // the second one;
    [self.passwordField becomeFirstResponder]; // the third one

    if (!btn.selected) {
        [btn setImage:[UIImage imageNamed:@"icon_pwd_show_not"] forState:UIControlStateNormal];
    }else{
        [btn setImage:[UIImage imageNamed:@"icon_pwd_show"] forState:UIControlStateNormal];
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
    if ([title isEqualToString:@"请输入手机号"]) {
        
        @weakify(self);
        field.keyboardType = UIKeyboardTypeNumberPad;
        //field.clearButtonMode = UITextFieldViewModeWhileEditing;
        UIButton *ClearBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 7.5, 20, 20)];
        [ClearBtn setImage:[UIImage imageNamed:@"clear_btnBg"] forState:UIControlStateNormal];
        [[ClearBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            self.usernameField.text = nil;
        }];
        field.rightView = ClearBtn;
        field.rightViewMode = UITextFieldViewModeWhileEditing;
    }else if ([title isEqualToString:@"请输入密码"]){
    
        UIButton *SecretBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 11, 20, 13)];
        [SecretBtn setImage:[UIImage imageNamed:@"icon_pwd_show"] forState:UIControlStateNormal];
        [SecretBtn addTarget:self action:@selector(secretShowOrHide:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:SecretBtn];
        field.rightView = SecretBtn;
        field.rightViewMode = UITextFieldViewModeWhileEditing;
    }
    
    field.delegate = self;
    field.textColor = [UIColor blackColor];
    // 设置内容居中
    field.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    field.leftViewMode = UITextFieldViewModeAlways;
    // 占位符
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.alignment = NSTextAlignmentLeft;
    NSAttributedString *attri = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:[QFTools colorWithHexString:@"#a7a9b0"],NSFontAttributeName:[UIFont fontWithName:@"Arial" size:14], NSParagraphStyleAttributeName:style}];
    field.attributedPlaceholder = attri;
    return field;
}

#pragma mark - 登录按钮
- (void)setupLogBtn
{
    UIButton *logBtn = [[UIButton alloc] init];
    logBtn.frame = CGRectMake(ScreenWidth*.15 , CGRectGetMaxY(self.passwordField.frame) + navHeight, ScreenWidth*.7, 44);
    logBtn.backgroundColor = [QFTools colorWithHexString:MainColor];
    [logBtn setTitle:@"登录" forState:UIControlStateNormal];
    [logBtn setTitleColor:[QFTools colorWithHexString:@"#FFFFFF"] forState:UIControlStateNormal];
    logBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    logBtn.contentMode = UIViewContentModeCenter;
    [logBtn.layer setCornerRadius:5.0]; // 切圆角
    [logBtn addTarget:self action:@selector(logBtnBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:logBtn];
    self.logBtn = logBtn;
    
}

#pragma mark - 注册按钮
- (void)setupResBtn{
    UIButton *ResBtn = [[UIButton alloc] init];
    ResBtn.frame = CGRectMake(ScreenWidth*.15 , CGRectGetMaxY(self.logBtn.frame) + 44, ScreenWidth*.7, 44);
    [ResBtn setTitle:@"新用户注册" forState:UIControlStateNormal];
    ResBtn.layer.borderColor = [QFTools colorWithHexString:MainColor].CGColor;
    ResBtn.layer.borderWidth = 1.0;
    ResBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    ResBtn.contentMode = UIViewContentModeCenter;
    [ResBtn setTitleColor:[QFTools colorWithHexString:@"#fdc12b"] forState:UIControlStateNormal];
    [ResBtn.layer setCornerRadius:5.0]; // 切圆角
    [ResBtn addTarget:self action:@selector(registerBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:ResBtn];
    ResBtn.tag = 300 + 1;
}

#pragma mark - 点击登录
- (void)logBtnBtnClick{
    
    if ([QFTools isBlankString:self.usernameField.text] || [QFTools isBlankString:self.passwordField.text]) {
        [SVProgressHUD showSimpleText:@"请输入账号密码"];
        return;
    }
    
    LoadView *loadview = [LoadView sharedInstance];
    loadview.protetitle.text = @"正在登录中";
    [loadview show];
    
    NSString *pwd = [NSString stringWithFormat:@"%@%@%@",@"QGJ",self.passwordField.text,@"BLE"];
    NSString * md5=[[QFTools md5:pwd] uppercaseString];
    NSString*modelname = [NSString stringWithFormat:@"%@|%@|%@",[[UIDevice currentDevice] model],[[UIDevice currentDevice] systemVersion],[[UIDevice currentDevice].identifierForVendor UUIDString]];
    NSString *URLString = [NSString stringWithFormat:@"%@%@",QGJURL,@"app/login"];
    NSString *did =[[QFTools md5:modelname] uppercaseString];
    NSString *regid = [JPUSHService registrationID]?:@"";
    NSDictionary *push = @{@"device_name": modelname,@"channel": @1,@"reg_id": regid};
    NSDictionary *parameters = @{@"account": self.usernameField.text, @"passwd": md5,@"did": did,@"pkg": [[NSBundle mainBundle] bundleIdentifier],@"push":push};
    [[HttpRequest sharedInstance] postWithURLString:URLString parameters:parameters success:^(id _Nullable dict){
       
        if ([dict[@"status"] intValue] == 0) {
            
            NSDictionary *data = dict[@"data"];
            LoginDataModel *loginModel = [LoginDataModel yy_modelWithDictionary:data];
            NSString * token=loginModel.token;
            NSString * defaultlogo = loginModel.default_brand_logo;
            NSString * defaultimage = loginModel.default_model_picture;
            UserInfoModel *userinfo = loginModel.user_info;
            NSString * birthday=userinfo.birthday;
            NSString * nick_name=userinfo.nick_name;
            NSNumber * gender = [NSNumber numberWithInteger:userinfo.gender];
            NSString * icon = userinfo.icon;
            NSString * realName = userinfo.real_name;
            NSString *idcard = userinfo.id_card_no;
            NSNumber *userId = [NSNumber numberWithInteger:userinfo.user_id];
            
            NSDictionary *userDic = [NSDictionary dictionaryWithObjectsAndKeys:token,@"token",self.usernameField.text,@"phone_num",self.passwordField.text,@"password",defaultlogo,@"defaultlogo",defaultimage,@"defaultimage",userId,@"userid",nil];
            [USER_DEFAULTS setObject:userDic forKey:logInUSERDIC];
            [USER_DEFAULTS synchronize];
            
            NSDictionary *userDic2 = [NSDictionary dictionaryWithObjectsAndKeys:self.usernameField.text,@"username",birthday,@"birthday",nick_name,@"nick_name",gender,@"gender",icon,@"icon",realName,@"realname",idcard,@"idcard",nil];
            [USER_DEFAULTS setObject:userDic2 forKey:userInfoDic];
            [USER_DEFAULTS synchronize];
            
            [LVFmdbTool deleteBrandData:nil]; 
            [LVFmdbTool deleteBikeData:nil];
            [LVFmdbTool deleteModelData:nil];
            [LVFmdbTool deletePeripheraData:nil];
            [LVFmdbTool deleteFingerprintData:nil];
            [LVFmdbTool deletePerpheraServicesInfoData:nil];
            
            for (BikeInfoModel *bikeInfo in loginModel.bike_info) {
                
                if (bikeInfo.owner_flag == 1) {
                    self->child = @"0";
                    self->main = bikeInfo.passwd_info.main;
                }else if (bikeInfo.owner_flag == 0){
                    
                    self->child = bikeInfo.passwd_info.children.firstObject;
                    self->main = @"0";
                }
                
                NSString *logo = bikeInfo.brand_info.logo;
                BikeModel *pmodel = [BikeModel modalWith:bikeInfo.bike_id bikename:bikeInfo.bike_name ownerflag:bikeInfo.owner_flag ecu_id:bikeInfo.ecu_id hwversion:bikeInfo.hw_version firmversion:bikeInfo.firm_version keyversion:bikeInfo.key_version mac:bikeInfo.mac sn:bikeInfo.sn mainpass:self->main password:self->child bindedcount:bikeInfo.binded_count ownerphone:bikeInfo.owner_phone fp_func:bikeInfo.fp_func fp_conf_count:bikeInfo.fp_conf_count tpm_func:bikeInfo.tpm_func gps_func:bikeInfo.gps_func vibr_sens_func:bikeInfo.vibr_sens_func wheels:bikeInfo.wheels builtin_gps:bikeInfo.builtin_gps];
                [LVFmdbTool insertBikeModel:pmodel];
                
                if (bikeInfo.brand_info.brand_id == 0) {
                    logo = defaultlogo;
                }
                
                BrandModel *bmodel = [BrandModel modalWith:bikeInfo.bike_id brandid:bikeInfo.brand_info.brand_id brandname:bikeInfo.brand_info.brand_name logo:logo bike_pic:bikeInfo.brand_info.bike_pic];
                [LVFmdbTool insertBrandModel:bmodel];
                
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
                
                for (FingerModel *fpsInfo in bikeInfo.fps){
                    
                    FingerprintModel *fingermodel = [FingerprintModel modalWith:bikeInfo.bike_id fp_id:fpsInfo.fp_id pos:fpsInfo.pos name:fpsInfo.name added_time:fpsInfo.added_time];
                    [LVFmdbTool insertFingerprintModel:fingermodel];
                }
            }
            
            NSMutableArray *bikeAry = [LVFmdbTool queryBikeData:nil];
            
            if (bikeAry.count > 0) {
                BikeModel *firstbikeinfo = bikeAry[0];
                [USER_DEFAULTS setInteger:firstbikeinfo.bikeid forKey:Key_BikeId];
            }
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [loadview hide];
                [NSNOTIC_CENTER postNotificationName:KNOTIFICATION_LOGINCHANGE object:@YES];
            });
                
                /*
                NSURL *url=[NSURL URLWithString:icon];
                [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:url completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
                    if (image && finished) {
                        [loadview hide];
                        [NSNOTIC_CENTER postNotificationName:KNOTIFICATION_LOGINCHANGE object:@YES];
                    }else if (error){
                        [loadview hide];
                        [NSNOTIC_CENTER postNotificationName:KNOTIFICATION_LOGINCHANGE object:@YES];
                    }
                }];
                */

        }else if([dict[@"status"] intValue] == 1001){
            [loadview hide];
            [SVProgressHUD showSimpleText:dict[@"status_info"]];
        }else{
            [loadview hide];
            [SVProgressHUD showSimpleText:dict[@"status_info"]];
        }
        
    } failure:^(NSError * error) {
        NSLog(@"error :%@",error);
        [loadview hide];
        [SVProgressHUD showSimpleText:TIP_OF_NO_NETWORK];
    }];
}



#pragma mark - 点击屏幕取消键盘
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    return YES;
}

#pragma mark - pop
- (void)leftBtnClick:(UIButton *)btn
{
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 找回密码
- (void)forgetBtnClick:(UIButton *)btn
{
    [self.view endEditing:YES];
    [self.navigationController pushViewController:[ForgetViewController new] animated:YES];
    
}

#pragma mark - 注册
- (void)registerBtnClick:(UIButton *)btn
{
    [self.view endEditing:YES];
    [self.navigationController pushViewController:[MobileViewController new] animated:YES];
    //[self.navigationController pushViewController:[ImprovePersonalViewController new] animated:YES];
}

#pragma mark - 监听输入框
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    //明文切换密文后避免被清空
    NSString *toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (textField == self.passwordField && textField.isSecureTextEntry) {
        textField.text = toBeString;
        return NO;
    }
    
    return YES;
    
}


#pragma mark --键盘弹出收起管理
-(void)keyboardWillShow:(NSNotification *)note{
    
    CGRect frame = [self.logBtn convertRect:self.logBtn.bounds toView:self.view];
    //获取键盘高度
    NSDictionary* info = [note userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    //66是按钮的高度，如果你的控件高度不一样，则可以进行不同的调整
    _offSet = frame.origin.y + 66 - (self.view.frame.size.height - kbSize.height);
    //将试图的Y坐标向上移动offset个单位，以使界面腾出开的地方用于软键盘的显示
    if (_offSet > 0.01) {

        //设置动画的名字
        [UIView beginAnimations:@"Animation" context:nil];
        //设置动画的间隔时间
        [UIView setAnimationDuration:0.20];
        //??使用当前正在运行的状态开始下一段动画
        [UIView setAnimationBeginsFromCurrentState: YES];
        //设置视图移动的位移
        self.view.frame = CGRectMake( 0, -_offSet, self.view.frame.size.width, self.view.frame.size.height);
        //设置动画结束
        [UIView commitAnimations];
    }
}

-(void)keyboardWillHide:(NSNotification *)note{
    
    if (_offSet > 0.01) {
        _offSet = 0;
        //设置动画的名字
        [UIView beginAnimations:@"Animation" context:nil];
        //设置动画的间隔时间
        [UIView setAnimationDuration:0.20];
        //??使用当前正在运行的状态开始下一段动画
        [UIView setAnimationBeginsFromCurrentState: YES];
        //设置视图移动的位移
        self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        //设置动画结束
        [UIView commitAnimations];
    }
}


- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if (self.usernameField.text.length && self.passwordField.text.length) {
        self.logBtn.backgroundColor = [QFTools colorWithHexString:MainColor];
    }else {
        self.logBtn.backgroundColor = [QFTools colorWithHexString:MainColor];
    }
    return YES;
    
}


@end
