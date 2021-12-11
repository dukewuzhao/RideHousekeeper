//
//  ManualInputViewController.m
//  RideHousekeeper
//
//  Created by Apple on 2017/11/13.
//  Copyright © 2017年 Duke Wu. All rights reserved.
//

#import "ManualInputViewController.h"
#import "BottomBtn.h"
#import "Manager.h"
#define NUM @"0123456789"
#define ALPHA @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
#define ALPHANUM @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
@interface ManualInputViewController ()<UITextFieldDelegate>
@property (nonatomic,weak) UITextField *importField;
@property (nonatomic,weak) UIButton *sureBtn;
@end

@implementation ManualInputViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.fd_fullscreenPopGestureRecognizer.enabled = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupNavView];
    [self setupView];
}

- (void)setupNavView{
    [super setupNavView];
    self.navView.backgroundColor = [QFTools colorWithHexString:MainColor];
    self.navView.showBottomLabel = NO;
    [self.navView.centerButton setTitle:NSLocalizedString(@"bind_smart_accessories", nil) forState:UIControlStateNormal];
    @weakify(self);
    
    [self.navView.rightButton setImage:[UIImage imageNamed:@"signout_input"] forState:UIControlStateNormal];
    self.navView.rightButtonBlock = ^{
      
        @strongify(self);
        UIViewController *accVc = self.navigationController.viewControllers[self.navigationController.viewControllers.count-3];
        [self.navigationController popToViewController:accVc animated:YES];
    };
    
}

-(void)setupView{
    
    UILabel *PromptLal = [[UILabel alloc] initWithFrame:CGRectMake(20, 50+navHeight, ScreenWidth - 40, 40)];
    PromptLal.numberOfLines = 0;
    PromptLal.text = NSLocalizedString(@"input_sn", nil);
    PromptLal.textColor = [QFTools colorWithHexString:@"#666666"];
    PromptLal.font = [UIFont systemFontOfSize:15];
    PromptLal.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:PromptLal];
    
    @weakify(self);
    UITextField *importField = [self addOneTextFieldWithTitle:NSLocalizedString(@"please_input_sn", nil) imageName:nil imageNameWidth:10 Frame:CGRectMake(40, CGRectGetMaxY(PromptLal.frame) + 15, ScreenWidth - 80, 35)];
    importField.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
    importField.textColor = [UIColor whiteColor];
    importField.tintColor = [QFTools colorWithHexString:NSLocalizedString(@"VCControlColor", nil)];
    importField.layer.borderColor = [QFTools colorWithHexString:NSLocalizedString(@"VCControlColor", nil)].CGColor;
    importField.layer.borderWidth = 1.0;
    [importField.layer setCornerRadius:5.0];
    importField.textAlignment = NSTextAlignmentCenter;
    [importField.rac_textSignal subscribeNext:^(id x) {
        @strongify(self);
        NSString *a= x;
        if (a.length >0) {
            [self.sureBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            self.sureBtn.backgroundColor = [QFTools colorWithHexString:NSLocalizedString(@"VCControlColor", nil)];
        }else{
            [self.sureBtn setTitleColor:[QFTools colorWithHexString:@"#666666"] forState:UIControlStateNormal];
            self.sureBtn.backgroundColor = [QFTools colorWithHexString:@"#d9d9d9"];
        }
        
    }];
    [self.view addSubview:importField];
    self.importField = importField;
    
    UIButton *sureBtn = [[UIButton alloc] initWithFrame:CGRectMake(importField.x, CGRectGetMaxY(importField.frame) + 50, importField.width, 35)];
    [sureBtn setTitle:NSLocalizedString(@"sure", nil) forState:UIControlStateNormal];
    [sureBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [sureBtn addTarget:self action:@selector(sureBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [sureBtn.layer setCornerRadius:5.0];
    sureBtn.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:sureBtn];
    self.sureBtn = sureBtn;
    
    BottomBtn *SwitchBtn = [[BottomBtn alloc] init];
    SwitchBtn.direction = @"left";
    SwitchBtn.width = 160;
    SwitchBtn.height = 35;
    SwitchBtn.x = ScreenWidth/2 - 80;
    SwitchBtn.y = CGRectGetMaxY(sureBtn.frame) + 75;
    [SwitchBtn setTitle:NSLocalizedString(@"change_scan", nil) forState:UIControlStateNormal];
    [SwitchBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [SwitchBtn setImage:[UIImage imageNamed:@"sweep_codes"] forState:UIControlStateNormal];
    SwitchBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    SwitchBtn.contentMode = UIViewContentModeCenter;
    [SwitchBtn addTarget:self action:@selector(SwitchBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:SwitchBtn];
    
}

-(void)SwitchBtnClick{
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)sureBtnClick{
    
    if ([QFTools isBlankString:self.importField.text]) {
        
        [SVProgressHUD showSimpleText:NSLocalizedString(@"change_sn", nil)];
        
        return;
    }
    
    if (self.type == 6) {
        
        if (self.importField.text.length != 8) {
            [SVProgressHUD showSimpleText:NSLocalizedString(@"no_tirt_type", nil)];
            return;
        }
        
        NSString *bikeQuerySql = [NSString stringWithFormat:@"SELECT * FROM bike_modals WHERE bikeid LIKE '%zd'", _deviceNum];
        NSMutableArray *bikemodals = [LVFmdbTool queryBikeData:bikeQuerySql];
        BikeModel *bikemodel = bikemodals.firstObject;
        if (bikemodel.tpm_func == 0) {
            
            [SVProgressHUD showSimpleText:NSLocalizedString(@"device_no_tirt_func", nil)];
            return;
        }
        
        NSMutableArray *properModels = [LVFmdbTool queryPeripheraData:[NSString stringWithFormat:@"SELECT * FROM periphera_modals WHERE mac LIKE '%@'", self.importField.text]];
        
        if (properModels.count >0) {
            [SVProgressHUD showSimpleText:NSLocalizedString(@"tire_has", nil)];
            return;
        }
        
        NSString *passwordHEX = [NSString stringWithFormat:@"A500000C3007010%ld%@",_seq - 1,self.importField.text];
        @weakify(self);
        RACSignal * deallocSignal = [self rac_signalForSelector:@selector(bindSuccess)];
        [[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:KNotification_BindingBLEKEY object:nil] takeUntil:deallocSignal] timeout:5 onScheduler:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
            @strongify(self);
            NSNotification *userInfo = x;
            NSString *date = userInfo.userInfo[@"data"];
            if ([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"3007"]){
                if ([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"00"]) {
                    
                    [SVProgressHUD showSimpleText:NSLocalizedString(@"bind_fail", nil)];
                }else if ([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"01"]){
                    [self bindSuccess];
                }
            }
        }error:^(NSError *error) {
            
            [SVProgressHUD showSimpleText:NSLocalizedString(@"bind_fail", nil)];
        }];
        
        [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
    }
}


- (void)bindSuccess{
    
    PeripheralModel *pmodel = [PeripheralModel modalWith:_deviceNum deviceid:_seq + 30 type:_type seq:_seq mac:self.importField.text sn:self.importField.text firmversion:@""];
    [LVFmdbTool insertDeviceModel:pmodel];
    [[Manager shareManager] bindingPeripheralSucceeded:pmodel];
    
    [SVProgressHUD showSimpleText:NSLocalizedString(@"bind_success", nil)];
    UIViewController *accVc = self.navigationController.viewControllers[self.navigationController.viewControllers.count-3];
    [self.navigationController popToViewController:accVc animated:YES];
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
     field.keyboardType = UIKeyboardTypeASCIICapable;
    field.delegate = self;
    field.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    field.leftViewMode = UITextFieldViewModeAlways;
    field.clearButtonMode = UITextFieldViewModeWhileEditing;
    [[UITextField appearance] setTintColor:[QFTools colorWithHexString:MainColor]];
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:ALPHANUM] invertedSet];
    NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    return [string isEqualToString:filtered];
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
