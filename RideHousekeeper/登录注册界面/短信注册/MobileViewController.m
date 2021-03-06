//
//  MobileViewController.m
//  阿尔卑斯
//
//  Created by 同时科技 on 16/4/18.
//  Copyright © 2016年 Duke Wu. All rights reserved.
//

#import "MobileViewController.h"
#import "ImprovePersonalViewController.h"
#import "PublicWebpageViewController.h"
@interface MobileViewController ()<UITextFieldDelegate>

@property (nonatomic,weak) UITextField *usernameField;
@property (nonatomic,weak) UITextField *codeField; // 验证码
@property (nonatomic,weak) UIButton *codeBtn; // 获取验证码按钮
@property (nonatomic,assign) int num;  // 倒数计时
@property (nonatomic,strong) MSWeakTimer *countDownTimer;
@property (nonatomic,weak) UIButton *nextBtn; // 提交按钮
@property (nonatomic,copy) NSString *codeStr; // 获取的验证码
@property (nonatomic,copy) NSString *phoneStr; // 填写的手机号

@property (nonatomic,weak) UITextField *passwordField; // 密码
@property (nonatomic) BOOL noRegister;
@property (nonatomic) BOOL isThrough;

@property(nonatomic, assign) BOOL Click;
@end

@implementation MobileViewController
@synthesize noRegister = _noRegister;
@synthesize isThrough = _isThrough;

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupNavView];
    [self setupField];    // 输入框
    [self setupNextBtn];
}

- (void)setupNavView{
    [super setupNavView];
    self.navView.showBottomLabel = NO;
    [self.navView.centerButton setTitle:@"注册" forState:UIControlStateNormal];
    @weakify(self);
    [self.navView.leftButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    self.navView.leftButtonBlock = ^{
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    };
}

#pragma mark - 用户名、密码输入框
- (void)setupField{
    // 手机号
    CGFloat usernameFieldY = 60 + navHeight;
    CGFloat usernameFieldW = ScreenWidth - 50;
    CGFloat usernameFieldH = 35;
    CGFloat usernameFieldX = 25;
    
    UITextField *usernameField = [self addOneTextFieldWithTitle:@"请输入手机号" imageName:nil imageNameWidth:10 Frame:CGRectMake(usernameFieldX, usernameFieldY, usernameFieldW, usernameFieldH)];
    usernameField.backgroundColor = [UIColor clearColor];
    [self.view addSubview:usernameField];
    self.usernameField = usernameField;
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(usernameField.x, CGRectGetMaxY(usernameField.frame), usernameFieldW, 1)];
    lineView.backgroundColor = [QFTools colorWithHexString:@"#a7a9b0"];
    [self.view addSubview:lineView];
    
    // 验证码
    CGFloat codeFieldY = CGRectGetMaxY(usernameField.frame) + 20;
    CGFloat codeFieldW = ScreenWidth - 160;
    CGFloat codeFieldH = 35;
    CGFloat codeFieldX = 25;
    
    UITextField *codeField = [self addOneTextFieldWithTitle:@"请输入验证码" imageName:nil imageNameWidth:10 Frame:CGRectMake(codeFieldX, codeFieldY, codeFieldW, codeFieldH)];
    codeField.backgroundColor = [UIColor clearColor];
    [self.view addSubview:codeField];
    self.codeField = codeField;
    
    
    UIButton *codeBtn = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth - 126, codeField.y - 5, 100, 35)];
    [codeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
    [codeBtn setTitleColor:[QFTools colorWithHexString:@"#a7a9b0"] forState:UIControlStateNormal];
    codeBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    codeBtn.contentMode = UIViewContentModeCenter;
    [codeBtn.layer setMasksToBounds:YES];//设置按钮的圆角半径不会被遮挡
    [codeBtn.layer setCornerRadius:10];
    [codeBtn.layer setBorderWidth:1];//设置边界的宽度
    //设置按钮的边界颜色
    codeBtn.layer.borderColor = [QFTools colorWithHexString:@"#a7a9b0"].CGColor;
    [codeBtn addTarget:self action:@selector(codeClick:) forControlEvents:UIControlEventTouchUpInside];
    codeBtn.userInteractionEnabled = YES;
    [self.view addSubview:codeBtn];
    self.codeBtn = codeBtn;
    
    UIView *lineView2 = [[UIView alloc] initWithFrame:CGRectMake(codeField.x, CGRectGetMaxY(codeField.frame), usernameFieldW, 1)];
    lineView2.backgroundColor = [QFTools colorWithHexString:@"#a7a9b0"];
    [self.view addSubview:lineView2];
    // 密码
    CGFloat passwordFieldY = CGRectGetMaxY(codeField.frame) + 20;
    CGFloat passwordFieldW = usernameField.width - 20;
    CGFloat passwordFieldH = 35;
    CGFloat passwordFieldX = 25;
    
    UITextField *passwordField = [self addOneTextFieldWithTitle:@"密码（6-20数字、字母）" imageName:nil imageNameWidth:10 Frame:CGRectMake(passwordFieldX, passwordFieldY, passwordFieldW, passwordFieldH)];
     passwordField.secureTextEntry = YES;
    passwordField.backgroundColor = [UIColor clearColor];
    [self.view addSubview:passwordField];
    self.passwordField = passwordField;
    
    
    UIView *lineView3 = [[UIView alloc] initWithFrame:CGRectMake(passwordField.x, CGRectGetMaxY(passwordField.frame), usernameFieldW, 1)];
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

#pragma mark - 登录按钮
- (void)setupNextBtn{
    
    UIButton *agree = [[UIButton alloc] initWithFrame:CGRectMake(25, CGRectGetMaxY(self.passwordField.frame) + 12.5, 25, 25)];
    [agree setImage:[UIImage imageNamed:@"icon_s"] forState:UIControlStateNormal];
    [agree addTarget:self action:@selector(agreeClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:agree];
    
    UILabel * agreementLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(agree.frame) + 5, CGRectGetMaxY(self.passwordField.frame) + 10, ScreenWidth - 40, 30)];

    agreementLabel.text = @"阅读并接受《骑管家用户协议》";
    NSString *contentStr = agreementLabel.text;
    [self setTextColor:agreementLabel FontNumber:[UIFont systemFontOfSize:14] AndRange:NSMakeRange(contentStr.length - 9, 9) AndColor:[QFTools colorWithHexString:MainColor]];
    
    agreementLabel.font = [UIFont systemFontOfSize:14];
    agreementLabel.textColor = [QFTools colorWithHexString:@"#a7a9b0"];
    
    
    agreementLabel.userInteractionEnabled = YES;
    [self.view addSubview:agreementLabel];
    self.Click = YES;
    
    UITapGestureRecognizer *checkAgreementTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(checkAgreementeClicked:)];
    checkAgreementTap.numberOfTapsRequired = 1;
    [agreementLabel addGestureRecognizer:checkAgreementTap];
    
    UIButton *nextBtn = [[UIButton alloc] init];
    nextBtn.frame = CGRectMake(ScreenWidth * .21 , CGRectGetMaxY(agreementLabel.frame) + 40, ScreenWidth * .58, 35);
    nextBtn.backgroundColor = [QFTools colorWithHexString:MainColor];
    [nextBtn setTitle:@"注册" forState:UIControlStateNormal];
    [nextBtn setTitleColor:[QFTools colorWithHexString:@"#FFFFFF"] forState:UIControlStateNormal];
    nextBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    nextBtn.contentMode = UIViewContentModeCenter;
    [nextBtn.layer setCornerRadius:5.0]; // 切圆角
    [nextBtn addTarget:self action:@selector(nextBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nextBtn];
}

- (void)checkAgreementeClicked:(UITapGestureRecognizer *)gesture{
    
    PublicWebpageViewController *agreeVc = [PublicWebpageViewController new];
    agreeVc.topTitle = @"骑管家用户协议";
    agreeVc.userPrivacyUrl = @"http://m.smart-qgj.com/qgj_user_agreement.html";
    [self.navigationController pushViewController:agreeVc animated:YES];
}

-(void)setTextColor:(UILabel *)label FontNumber:(id)font AndRange:(NSRange)range AndColor:(UIColor *)vaColor{
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:label.text];
    //设置字号
    [str addAttribute:NSFontAttributeName value:font range:range];
    //设置文字颜色
    [str addAttribute:NSForegroundColorAttributeName value:vaColor range:range];
    
    label.attributedText = str;
}

- (void)agreeClick:(UIButton *)btn{

    self.Click = !self.Click;
    if (self.Click) {
        [btn setImage:[UIImage imageNamed:@"icon_s"] forState:UIControlStateNormal];
    }else{
        [btn setImage:[UIImage imageNamed:@"n"] forState:UIControlStateNormal];
    }
}

- (void)nextBtnClick{
    [self.view endEditing:YES];
    [self.countDownTimer invalidate];// 关掉计时器
    self.countDownTimer = nil;
    [self.codeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
    self.codeBtn.userInteractionEnabled = YES;
    if (![QFTools isMobileNumber:self.usernameField.text]) {
        [SVProgressHUD showSimpleText:@"请输入手机号"];
        return;
    }
    
    if (!self.Click) {
        [SVProgressHUD showSimpleText:@"请同意协议"];
        return;
    }
    
    if (self.passwordField.text.length <6 ||self.passwordField.text.length >20){
        [SVProgressHUD showSimpleText:@"密码为6-20位字母、阿拉伯数字、英文符号或组合"];
        return;
        
    }else if ([QFTools isBlankString:self.codeField.text]){
        
        [SVProgressHUD showSimpleText:@"请输入验证码"];
        return;
        
    }else if ([QFTools isBlankString:self.passwordField.text]){
        [SVProgressHUD showSimpleText:@"请输入密码"];
        return;
        
    }
    
    
    NSString *pwd = [NSString stringWithFormat:@"%@%@%@",@"QGJ",self.passwordField.text,@"BLE"];
    NSString * md5=[QFTools md5:pwd];
    
    NSString *URLString = [NSString stringWithFormat:@"%@%@",QGJURL,@"app/register"];
    NSDictionary *parameters = @{@"pn": self.usernameField.text,@"passwd": md5.uppercaseString,@"vc": self.codeField.text};
    [[HttpRequest sharedInstance] postWithURLString:URLString parameters:parameters success:^(id _Nullable dict){
        
        if ([dict[@"status"] intValue] == 0) {
            
            [self login];
        }else{
            
            [SVProgressHUD showSimpleText:dict[@"status_info"]];
        }
        
    } failure:^(NSError * error) {
        NSLog(@"error :%@",error);
        [SVProgressHUD showSimpleText:TIP_OF_NO_NETWORK];
    }];
    
}

- (void)login{

    NSString *pwd = [NSString stringWithFormat:@"%@%@%@",@"QGJ",self.passwordField.text,@"BLE"];
    NSString *md5=[[QFTools md5:pwd] uppercaseString];
    NSString *modelname = [NSString stringWithFormat:@"%@|%@|%@",[[UIDevice currentDevice] model],[[UIDevice currentDevice] systemVersion],[[UIDevice currentDevice].identifierForVendor UUIDString]];
    NSString *did =[[QFTools md5:modelname] uppercaseString];
    NSString *regid = [JPUSHService registrationID]?:@"";
    NSString *URLString = [NSString stringWithFormat:@"%@%@",QGJURL,@"app/login"];
    NSDictionary *push = @{@"device_name": modelname,@"channel": @1,@"reg_id": regid};
    NSDictionary *parameters = @{@"account": self.usernameField.text, @"passwd": md5,@"did": did,@"pkg": [[NSBundle mainBundle] bundleIdentifier],@"push":push};
    
    [[HttpRequest sharedInstance] postWithURLString:URLString parameters:parameters success:^(id _Nullable dict){
        
        if ([dict[@"status"] intValue] == 0) {
            
            [SVProgressHUD showSimpleText:dict[@"status_info"]];
            
            NSDictionary *data = dict[@"data"];
            
            NSDictionary *userinfo = data[@"user_info"];
            NSString * token=[data objectForKey:@"token"];
            NSString * defaultlogo = [data objectForKey:@"default_brand_logo"];
            NSString * defaultimage = [data objectForKey:@"default_model_picture"];
            NSNumber *userId = [userinfo objectForKey:@"user_id"];
            
            NSDictionary *userDic = [NSDictionary dictionaryWithObjectsAndKeys:token,@"token",self.usernameField.text,@"phone_num",self.passwordField.text,@"password",defaultlogo,@"defaultlogo",defaultimage,@"defaultimage",userId,@"userid",nil];
            [USER_DEFAULTS setObject:userDic forKey:logInUSERDIC];
            [USER_DEFAULTS synchronize];
            
            //保存登录信息
            ImprovePersonalViewController *registerVc = [[ImprovePersonalViewController alloc] init];
            [self.navigationController pushViewController:registerVc animated:YES];
            
        }else{
            [SVProgressHUD showSimpleText:dict[@"status_info"]];
        }
        
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"error :%@",error);
        [SVProgressHUD showSimpleText:TIP_OF_NO_NETWORK];
    }];
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
    
    if ([title isEqualToString:@"请输入手机号"] || [title isEqualToString:@"请输入验证码"]) {
        field.keyboardType = UIKeyboardTypeNumberPad;
        //field.clearButtonMode = UITextFieldViewModeWhileEditing;
        @weakify(self);
        UIButton *ClearBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 7.5, 20, 20)];
        [ClearBtn setImage:[UIImage imageNamed:@"clear_btnBg"] forState:UIControlStateNormal];
        [[ClearBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            if ([title isEqualToString:@"请输入手机号"]) {
                self.usernameField.text = nil;
            }else{
                self.codeField.text = nil;
            }
        }];
        field.rightView = ClearBtn;
        field.rightViewMode = UITextFieldViewModeWhileEditing;
    }else if ([title isEqualToString:@"密码（6-20数字、字母）"]){
        
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
    NSAttributedString *attri = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:[QFTools colorWithHexString:@"#a7a9b0"], NSParagraphStyleAttributeName:style}];
    field.attributedPlaceholder = attri;
    
    return field;
}



-(void)backView{
    
    [self.view endEditing:YES];
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

#pragma mark - 获取验证码点击
- (void)codeClick:(UIButton *)btn
{
    NSLog(@"%lu",(unsigned long)self.usernameField.text.length);
    if (![QFTools isMobileNumber:self.usernameField.text]) {
        [SVProgressHUD showSimpleText:@"手机号码格式错误，请重新输入"];
        return;
    }
    NSTimeInterval timel=[[NSDate date] timeIntervalSince1970];
    NSNumber *ts = [NSNumber numberWithInt:(int)timel];
    
    NSString *pwd = [NSString stringWithFormat:@"%@%@%d%@",@"QGJ",self.usernameField.text,ts.intValue,@"VC"];
    NSString * sign=[[QFTools md5:pwd] lowercaseString];
    
    self.codeBtn.userInteractionEnabled = NO;
    self.num = 60;
    [self.codeBtn setTitle:[NSString stringWithFormat:@"%ds后重新获取",self.num] forState:UIControlStateNormal];
    self.countDownTimer = [MSWeakTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timeFireMethod) userInfo:nil repeats:YES dispatchQueue:dispatch_get_main_queue()];
    
    NSString *URLString = [NSString stringWithFormat:@"%@%@",QGJURL,@"app/requestvc"];
    NSDictionary *parameters = @{@"pn": self.usernameField.text,@"ts": ts,@"sign": sign};
    
    [[HttpRequest sharedInstance] postWithURLString:URLString parameters:parameters success:^(id _Nullable dict){
        
        if ([dict[@"status"] intValue] == 0) {
            
            //[SVProgressHUD showSimpleText:@"验证码已发送成功"];
            
        }else{
            self.codeBtn.userInteractionEnabled = YES;
            [self.codeBtn setTitle:@"重新获取" forState:UIControlStateNormal];
            [self.countDownTimer invalidate];// 关掉计时器
            self.countDownTimer = nil;
            [SVProgressHUD showSimpleText:dict[@"status_info"]];
        }
        
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"error :%@",error);
        self.codeBtn.userInteractionEnabled = YES;
        [self.codeBtn setTitle:@"重新获取" forState:UIControlStateNormal];
        [self.countDownTimer invalidate];// 关掉计时器
        self.countDownTimer = nil;
        [SVProgressHUD showSimpleText:TIP_OF_NO_NETWORK];
    }];
    
}

#pragma mark - 倒计时
- (void)timeFireMethod{
    self.num--;
    [self.codeBtn setTitle:[NSString stringWithFormat:@"%ds后重新发送",self.num] forState:UIControlStateNormal];
    if (self.num == 0) {
        [self.countDownTimer invalidate];// 关掉计时器
        self.countDownTimer = nil;
        [self.codeBtn setTitle:@"重新获取" forState:UIControlStateNormal];
        self.codeBtn.userInteractionEnabled = YES;
        self.num = 60;
    }
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

-(void)dealloc{
    
    [self.countDownTimer invalidate];
    self.countDownTimer = nil;
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
