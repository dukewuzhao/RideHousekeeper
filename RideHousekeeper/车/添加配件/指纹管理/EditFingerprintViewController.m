//
//  EditFingerprintViewController.m
//  RideHousekeeper
//
//  Created by Apple on 2017/11/21.
//  Copyright © 2017年 Duke Wu. All rights reserved.
//

#import "EditFingerprintViewController.h"

@interface EditFingerprintViewController (){
    UITextField * fingerprintFiled;
}

@end

@implementation EditFingerprintViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavView];
    [self setupView];
}

- (void)setupNavView{
    [super setupNavView];
    self.navView.showBottomLabel = NO;
    [self.navView.centerButton setTitle:@"编辑指纹" forState:UIControlStateNormal];
    @weakify(self);
    [self.navView.leftButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    self.navView.leftButtonBlock = ^{
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    };
    NSString *bikeQuerySql = [NSString stringWithFormat:@"SELECT * FROM bike_modals WHERE bikeid = '%zd'", self.deviceNum];
    NSMutableArray *bikemodals = [LVFmdbTool queryBikeData:bikeQuerySql];
    BikeModel *bikemodel = bikemodals.firstObject;
    [self.navView.rightButton setTitle:@"保存" forState:UIControlStateNormal];
    self.navView.rightButtonBlock = ^{
        @strongify(self);
        if (bikemodel.ownerflag == 0) {
            [SVProgressHUD showSimpleText:@"子用户无此权限"];
            return;
        }
        [self saveUserFinger];
    };
}

-(void)setupView{
    
    fingerprintFiled = [[UITextField alloc]init];
    fingerprintFiled.frame = CGRectMake(10, 20 + navHeight, ScreenWidth - 20, 45);
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.alignment = NSTextAlignmentLeft;
    NSAttributedString *attri = [[NSAttributedString alloc] initWithString:self.fpmodel.name attributes:@{NSForegroundColorAttributeName:[QFTools colorWithHexString:@"#adaaa8"], NSParagraphStyleAttributeName:style}];
    fingerprintFiled.attributedPlaceholder = attri;
    fingerprintFiled.layer.cornerRadius = 5;
    fingerprintFiled.clearButtonMode = UITextFieldViewModeWhileEditing;
    fingerprintFiled.textColor = [UIColor blackColor];
    fingerprintFiled.backgroundColor = CellColor;
    fingerprintFiled.layer.borderColor = [UIColor colorWithRed:14/255.0 green:174/255.0 blue:131/255.0 alpha:1].CGColor;
    fingerprintFiled.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    fingerprintFiled.leftViewMode = UITextFieldViewModeAlways;
    @weakify(self);
    UIButton *ClearBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 7.5, 20, 20)];
    [ClearBtn setImage:[UIImage imageNamed:@"clear_btnBg"] forState:UIControlStateNormal];
    [[ClearBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        self->fingerprintFiled.text = nil;
    }];
    fingerprintFiled.rightView = ClearBtn;
    fingerprintFiled.rightViewMode = UITextFieldViewModeWhileEditing;
    [self.view addSubview:fingerprintFiled];
    
    UILabel *promte = [[UILabel alloc] initWithFrame:CGRectMake(fingerprintFiled.x, CGRectGetMaxY(fingerprintFiled.frame)+5, fingerprintFiled.width, 20)];
    promte.textColor = [QFTools colorWithHexString:@"#999999"];
    promte.font = [UIFont systemFontOfSize:14];
    promte.text = @"限4-12字符,每个汉字为两个字符";
    [self.view addSubview:promte];
    
    NSString *bikeQuerySql = [NSString stringWithFormat:@"SELECT * FROM bike_modals WHERE bikeid = '%zd'", self.deviceNum];
    NSMutableArray *bikemodals = [LVFmdbTool queryBikeData:bikeQuerySql];
    BikeModel *bikemodel = bikemodals.firstObject;
    
    UIButton *deleteBtn = [[UIButton alloc] initWithFrame:CGRectMake(25, ScreenHeight - 110, ScreenWidth - 50, 45)];
    deleteBtn.backgroundColor = [UIColor redColor];
    [[deleteBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        if (![CommandDistributionServices isConnect]) {
            
            [SVProgressHUD showSimpleText:@"车辆未连接"];
            return;
        }else if (bikemodel.ownerflag == 0) {
            [SVProgressHUD showSimpleText:@"子用户无此权限"];
            return;
        }
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"是否删除该指纹" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            LoadView *loadview = [LoadView sharedInstance];
            loadview.protetitle.text = @"删除指纹中";
            [loadview show];
            
            @weakify(self);
            
            [CommandDistributionServices deleteFingerPrint:self.fpmodel.pos data:^(id data) {
                @strongify(self);
                if ([data intValue] == ConfigurationSuccess) {
                    [self deleteFingerPrint];
                }else{
                    [loadview hide];
                    [SVProgressHUD showSimpleText:@"删除失败"];
                }
            } error:^(CommandStatus status) {
                switch (status) {
                    case SendSuccess:
                        NSLog(@"清除指令发送成功");
                        break;
                        
                    default:
                        [loadview hide];
                        [SVProgressHUD showSimpleText:@"删除失败"];
                        break;
                }
            }];
        }];
        UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}];
        [alert addAction:action1];
        [alert addAction:action2];
        [self presentViewController:alert animated:YES completion:nil];
    }];
    [deleteBtn setTitle:@"删除指纹" forState:UIControlStateNormal];
    [deleteBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    deleteBtn.backgroundColor = [UIColor redColor];
    [deleteBtn.layer setCornerRadius:10.0]; // 切圆角
    [self.view addSubview:deleteBtn];
    
}

-(void)saveUserFinger{
    
    [self editFingerPrintName];
}

-(void)deleteFingerPrint{
    
    NSString *URLString = [NSString stringWithFormat:@"%@%@",QGJURL,@"app/delfingerprint"];
    NSString *token = [QFTools getdata:@"token"];
    NSNumber *fpid = [NSNumber numberWithInteger:self.fpmodel.fp_id];
    NSNumber *bikeid = [NSNumber numberWithInteger:self.deviceNum];
    NSDictionary *parameters = @{@"token": token, @"bike_id": bikeid,@"fp_id": fpid};
    
    [[HttpRequest sharedInstance] postWithURLString:URLString parameters:parameters success:^(id _Nullable dict) {
        
        if ([dict[@"status"] intValue] == 0) {
            [[LoadView sharedInstance] hide];
            [SVProgressHUD showSimpleText:@"删除成功"];
            
            NSString *deleteFingerSql = [NSString stringWithFormat:@"DELETE FROM fingerprint_modals WHERE bikeid LIKE '%zd' AND pos LIKE '%zd'", self.deviceNum,self.fpmodel.pos];
            [LVFmdbTool deleteFingerprintData:deleteFingerSql];
            
            if([self.delegate respondsToSelector:@selector(deleteFingerprintSuccess)])
            {
                [self.delegate deleteFingerprintSuccess];
            }
            
            [self.navigationController popViewControllerAnimated:YES];
            
        }else{
            [[LoadView sharedInstance] hide];
            [SVProgressHUD showSimpleText:dict[@"status_info"]];
        }
        
    }failure:^(NSError *error) {
        
        NSLog(@"error :%@",error);
        [[LoadView sharedInstance] hide];
        [SVProgressHUD showSimpleText:TIP_OF_NO_NETWORK];
    }];
}

-(void)editFingerPrintName{
    
    if ([QFTools isBlankString:fingerprintFiled.text]) {
        [SVProgressHUD showSimpleText:@"请输入修改名称"];
        return;
    }
    
    LoadView *loadview = [LoadView sharedInstance];
    loadview.protetitle.text = @"修改指纹中";
    [loadview show];
    NSString *URLString = [NSString stringWithFormat:@"%@%@",QGJURL,@"app/changefingerprintname"];
    NSString *token = [QFTools getdata:@"token"];
    NSNumber *fpid = [NSNumber numberWithInteger:self.fpmodel.fp_id];
    NSNumber *pos = [NSNumber numberWithInteger:self.fpmodel.pos];
    NSNumber *bikeid = [NSNumber numberWithInteger:self.deviceNum];
    NSNumber* dTime = [NSNumber numberWithDouble:self.fpmodel.added_time];
    NSDictionary *fp_info = [NSDictionary dictionaryWithObjectsAndKeys:fpid,@"fp_id",pos,@"pos",fingerprintFiled.text,@"name",dTime,@"added_time",nil];
    NSDictionary *parameters = @{@"token": token, @"bike_id": bikeid,@"fp_info": fp_info};
    
    [[HttpRequest sharedInstance] postWithURLString:URLString parameters:parameters success:^(id _Nullable dict) {
        
        if ([dict[@"status"] intValue] == 0) {
            [loadview hide];
            [SVProgressHUD showSimpleText:@"修改成功"];
            
            NSString *updateSql = [NSString stringWithFormat:@"UPDATE fingerprint_modals SET name = '%@' WHERE bikeid = '%zd' AND fp_id LIKE '%zd'",fingerprintFiled.text, self.deviceNum,self.fpmodel.fp_id];
            [LVFmdbTool modifyData:updateSql];
            
            if([self.delegate respondsToSelector:@selector(editFingerprintNameSuccess)]){
                [self.delegate editFingerprintNameSuccess];
            }
            
            [self.navigationController popViewControllerAnimated:YES];
            
        }else{
            [loadview hide];
            NSLog(@" %@",dict[@"status_info"] );
            [SVProgressHUD showSimpleText:dict[@"status_info"]];
        }
        
    }failure:^(NSError *error) {
        
        NSLog(@"error :%@",error);
        [loadview hide];
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

@end
