//
//  EditFingerprintViewController.m
//  RideHousekeeper
//
//  Created by Apple on 2017/11/21.
//  Copyright © 2017年 Duke Wu. All rights reserved.
//

#import "EditFingerprintViewController.h"

@interface EditFingerprintViewController ()<UIAlertViewDelegate>
{
    UITextField * fingerprintFiled;
}

@property (nonatomic, strong)UIAlertView *delFingerAlertView;

@end

@implementation EditFingerprintViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavView];
    self.view.backgroundColor = [QFTools colorWithHexString:@"#ebecf2"];
    
    [AppDelegate currentAppDelegate].device.bindingaccessories = YES;
    
    [self setupView];
    @weakify(self);
    [[[NSNOTIC_CENTER rac_addObserverForName:KNotification_DeleteFinger object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id x) {
        @strongify(self);
        NSNotification *userInfo = x;
        NSString *date = userInfo.userInfo[@"data"];
        if ([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"3005"]) {

            if ([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"00"]) {
                [SVProgressHUD showSimpleText:NSLocalizedString(@"delete_fail", nil)];

            }else if ([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"01"]){
                [self deleteFingerPrint];
            }
        }
    }];
}

- (void)setupNavView{
    [super setupNavView];
    self.navView.backgroundColor = [QFTools colorWithHexString:MainColor];
    self.navView.showBottomLabel = NO;
    [self.navView.centerButton setTitle:NSLocalizedString(@"fingerpring_editname", nil) forState:UIControlStateNormal];
    @weakify(self);
    [self.navView.leftButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    self.navView.leftButtonBlock = ^{
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    };
    [self.navView.rightButton setTitle:NSLocalizedString(@"save", nil) forState:UIControlStateNormal];
    self.navView.rightButtonBlock = ^{
        @strongify(self);
        [self saveUserFinger];
    };
}

-(void)setupView{
    
    fingerprintFiled = [[UITextField alloc]init];
    fingerprintFiled.frame = CGRectMake(10, 20 + navHeight, ScreenWidth - 20, 45);
    NSMutableAttributedString *placeholder = [[NSMutableAttributedString alloc] initWithString:self.fpmodel.name];
    [placeholder addAttribute:NSForegroundColorAttributeName value:[QFTools colorWithHexString:@"#adaaa8"] range:NSMakeRange(0, self.fpmodel.name.length)];
    [placeholder addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Arial" size:14] range:NSMakeRange(0, self.fpmodel.name.length)];
    fingerprintFiled.attributedPlaceholder = placeholder;
    fingerprintFiled.layer.cornerRadius = 5;
    fingerprintFiled.clearButtonMode = UITextFieldViewModeWhileEditing;
    fingerprintFiled.textColor = [UIColor blackColor];
    fingerprintFiled.backgroundColor = [UIColor whiteColor];
    fingerprintFiled.layer.borderColor = [UIColor colorWithRed:14/255.0 green:174/255.0 blue:131/255.0 alpha:1].CGColor;
    fingerprintFiled.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    fingerprintFiled.leftViewMode = UITextFieldViewModeAlways;
    [[UITextField appearance] setTintColor:[QFTools colorWithHexString:NSLocalizedString(@"VCControlColor", nil)]];
    [self.view addSubview:fingerprintFiled];
    
    UILabel *promte = [[UILabel alloc] initWithFrame:CGRectMake(fingerprintFiled.x, CGRectGetMaxY(fingerprintFiled.frame)+5, fingerprintFiled.width, 20)];
    promte.textColor = [QFTools colorWithHexString:@"#999999"];
    promte.font = [UIFont systemFontOfSize:14];
    promte.text = NSLocalizedString(@"bikename_length_show", nil);
    [self.view addSubview:promte];
    
    @weakify(self);
    UIButton *deleteBtn = [[UIButton alloc] initWithFrame:CGRectMake(25, ScreenHeight - 110, ScreenWidth - 50, 45)];
    deleteBtn.backgroundColor = [UIColor redColor];
    [[deleteBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        
        @strongify(self);
        if (![[AppDelegate currentAppDelegate].device isConnected]) {
            
            [SVProgressHUD showSimpleText:NSLocalizedString(@"device_disconnect", nil)];
            return;
        }
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"reminders", nil) message:NSLocalizedString(@"delete_remind", nil) preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action1 = [UIAlertAction actionWithTitle:NSLocalizedString(@"sure", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            NSString *passwordHEX;
            if (self.fpmodel.pos == 10) {
                passwordHEX = [NSString stringWithFormat:@"A500000730050A"];
            }else{
                passwordHEX = [NSString stringWithFormat:@"A500000730050%ld",(long)self.fpmodel.pos];
            }
            
            [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
            
            LoadView *loadview = [LoadView sharedInstance];
            loadview.protetitle.text = NSLocalizedString(@"fingerpring_remove", nil);
            [loadview show];
            
            @weakify(self);
            RACSignal * deallocSignal = [self rac_signalForSelector:@selector(deleteFingerPrint)];
            [[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:KNotification_DeleteFinger object:nil] takeUntil:deallocSignal] timeout:6 onScheduler:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
                @strongify(self);
                NSNotification *userInfo = x;
                NSString *date = userInfo.userInfo[@"data"];
                if ([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"3005"]) {
                    
                    if ([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"00"]) {
                        [SVProgressHUD showSimpleText:NSLocalizedString(@"delete_fail", nil)];
                        
                    }else if ([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"01"]){
                        [self deleteFingerPrint];
                    }
                }
            }error:^(NSError *error) {
                [[LoadView sharedInstance] hide];
                [SVProgressHUD showSimpleText:NSLocalizedString(@"delete_fail", nil)];
                NSLog(@"%@",error);
            }];
        }];
        UIAlertAction *action2 = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        
        [alert addAction:action1];
        [alert addAction:action2];
        
        [self presentViewController:alert animated:YES completion:nil];
        
    }];
    [deleteBtn setTitle:NSLocalizedString(@"fingerpring_remove", nil) forState:UIControlStateNormal];
    [deleteBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    deleteBtn.backgroundColor = [QFTools colorWithHexString:NSLocalizedString(@"VCControlColor", nil)];
    [deleteBtn.layer setCornerRadius:10.0]; // 切圆角
    [self.view addSubview:deleteBtn];
    
}

-(void)saveUserFinger{
    
    [self editFingerPrintName];
}

-(void)deleteFingerPrint{
    
    NSString *deleteFingerSql = [NSString stringWithFormat:@"DELETE FROM fingerprint_modals WHERE bikeid LIKE '%zd' AND pos LIKE '%zd'", self.deviceNum,self.fpmodel.pos];
    BOOL success = [LVFmdbTool deleteFingerprintData:deleteFingerSql];
    if (success) {
        
        [[LoadView sharedInstance] hide];
        [SVProgressHUD showSimpleText:NSLocalizedString(@"delete_success", nil)];
        
        if([self.delegate respondsToSelector:@selector(deleteFingerprintSuccess)])
        {
            [self.delegate deleteFingerprintSuccess];
        }
        
        [self.navigationController popViewControllerAnimated:YES];
        
    }else{
        [[LoadView sharedInstance] hide];
        [SVProgressHUD showSimpleText:@"指纹修改失败"];
    }
}

-(void)editFingerPrintName{
    
    if ([QFTools isBlankString:fingerprintFiled.text]) {
        [SVProgressHUD showSimpleText:NSLocalizedString(@"modify_fingerprint_name", nil)];
        return;
    }else if (fingerprintFiled.text.length > 6 || fingerprintFiled.text.length < 2) {
        [SVProgressHUD showSimpleText:NSLocalizedString(@"bikename_length_big", nil)];
        return ;
    }
    
    LoadView *loadview = [LoadView sharedInstance];
    loadview.protetitle.text = NSLocalizedString(@"fingerprint_modification", nil);
    [loadview show];
    
    
    NSString *updateSql = [NSString stringWithFormat:@"UPDATE fingerprint_modals SET name = '%@' WHERE bikeid = '%zd' AND fp_id LIKE '%zd'",fingerprintFiled.text, self.deviceNum,self.fpmodel.fp_id];
    BOOL success = [LVFmdbTool modifyData:updateSql];
    
    if (success) {
        [loadview hide];
        [SVProgressHUD showSimpleText:NSLocalizedString(@"update_userinfo_success", nil)];
        if([self.delegate respondsToSelector:@selector(editFingerprintNameSuccess)]){
            [self.delegate editFingerprintNameSuccess];
        }
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [loadview hide];
        [SVProgressHUD showSimpleText:NSLocalizedString(@"update_userinfo_fail", nil)];
    }
    
}

-(void)dealloc{
    [AppDelegate currentAppDelegate].device.bindingaccessories = NO;
    if (self.delFingerAlertView) {
        [self.delFingerAlertView dismissWithClickedButtonIndex:0 animated:YES];
        self.delFingerAlertView = nil;
    }
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
