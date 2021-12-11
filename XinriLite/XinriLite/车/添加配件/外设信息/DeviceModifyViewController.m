//
//  DeviceModifyViewController.m
//  RideHousekeeper
//
//  Created by smartwallit on 16/10/29.
//  Copyright © 2016年 Duke Wu. All rights reserved.
//

#import "DeviceModifyViewController.h"
#import "Manager.h"
@interface DeviceModifyViewController ()

@end

@implementation DeviceModifyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [QFTools colorWithHexString:@"#ebecf2"];
    [self setupNavView];

    [self setupView];
}

- (void)setupNavView{
    [super setupNavView];
    self.navView.backgroundColor = [QFTools colorWithHexString:MainColor];
    self.navView.showBottomLabel = NO;
    [self.navView.centerButton setTitle:NSLocalizedString(@"smart_accessories_info", nil) forState:UIControlStateNormal];
    @weakify(self);
    [self.navView.leftButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    self.navView.leftButtonBlock = ^{
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    };
}

- (void)setupView{
    
    NSString *QuerykeySql = [NSString stringWithFormat:@"SELECT * FROM periphera_modals WHERE deviceid LIKE '%zd' AND bikeid LIKE '%zd'", self.deviceId,self.deviceNum];
    NSMutableArray *keymodals = [LVFmdbTool queryPeripheraData:QuerykeySql];
    PeripheralModel *perModel = keymodals.firstObject;
    
    
    UILabel *topTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, 10 + navHeight, 80, 20)];
    topTitle.text = @"设备信息";
    topTitle.textColor = [QFTools colorWithHexString:@"#cccccc"];
    topTitle.textAlignment = NSTextAlignmentLeft;
    topTitle.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:topTitle];
    
    UIView *model = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(topTitle.frame)+5, ScreenWidth, 40)];
    model.backgroundColor = [UIColor colorWithWhite:1 alpha:0.05];
    [self.view addSubview:model];
    
    UILabel *modelLable = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 80, 20)];
    modelLable.text = NSLocalizedString(@"key_sn", nil);
    modelLable.textColor = [UIColor whiteColor];
    modelLable.textAlignment = NSTextAlignmentLeft;
    modelLable.font = [UIFont systemFontOfSize:15];
    [model addSubview:modelLable];
    
    UILabel *typeLabel = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth - 200, 10, 180, 20)];
    typeLabel.textColor = [QFTools colorWithHexString:@"#666666"];
    typeLabel.text = perModel.sn;
    typeLabel.font = [UIFont systemFontOfSize:14];
    typeLabel.textAlignment = NSTextAlignmentRight;
    [model addSubview:typeLabel];
    
    UIView *bindingNumber = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(model.frame)+5, ScreenWidth, 40)];
    bindingNumber.backgroundColor = [UIColor colorWithWhite:1 alpha:0.05];
    [self.view addSubview:bindingNumber];
    
    
    UILabel *bindingNumberLable = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 80, 20)];
    bindingNumberLable.text = NSLocalizedString(@"mac", nil);
    bindingNumberLable.textColor = [UIColor whiteColor];
    bindingNumberLable.textAlignment = NSTextAlignmentLeft;
    bindingNumberLable.font = [UIFont systemFontOfSize:15];
    [bindingNumber addSubview:bindingNumberLable];
    
    UILabel *numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth - 200, 10, 180, 20)];
    numberLabel.textAlignment = NSTextAlignmentRight;
    numberLabel.textColor = [QFTools colorWithHexString:@"#666666"];
    numberLabel.font = [UIFont systemFontOfSize:14];
    numberLabel.text = perModel.mac;
    [bindingNumber addSubview:numberLabel];
    
    UIView *accessories = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(bindingNumber.frame)+5, ScreenWidth, 40)];
    accessories.backgroundColor = [UIColor colorWithWhite:1 alpha:0.05];
    [self.view addSubview:accessories];
    
    UILabel *accessoriesLable = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 80, 20)];
    accessoriesLable.text = NSLocalizedString(@"key_model", nil);
    accessoriesLable.textColor = [UIColor whiteColor];
    accessoriesLable.textAlignment = NSTextAlignmentLeft;
    accessoriesLable.font = [UIFont systemFontOfSize:15];
    [accessories addSubview:accessoriesLable];
    
    UILabel *battery = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth - 110, 10, 90, 20)];
    battery.textAlignment = NSTextAlignmentRight;
    battery.textColor = [QFTools colorWithHexString:@"#666666"];
    battery.font = [UIFont systemFontOfSize:14];
    [accessories addSubview:battery];
    
    if (perModel.type == 2) {
        
        battery.text = NSLocalizedString(@"key_model_smart", nil);
        
    }else if (perModel.type == 4) {
        
        battery.text = NSLocalizedString(@"key_model_gps", nil);
        
    }else if (perModel.type == 5) {
        
        battery.text = NSLocalizedString(@"key_model_sh", nil);
        
    }else if (perModel.type == 6) {
        
        if (perModel.seq == 1) {
            battery.text = NSLocalizedString(@"front_tire_pressure", nil);
        }else{
            battery.text = NSLocalizedString(@"rear_tire_pressure", nil);
        }
    }
    
    @weakify(self);
    UIButton *deleteBtn = [[UIButton alloc] initWithFrame:CGRectMake(25, ScreenHeight - 110, ScreenWidth - 50, 45)];
    deleteBtn.backgroundColor = [UIColor redColor];
    deleteBtn.layer.mask = [self.view UiviewRoundedRect:deleteBtn.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(10, 10)];
    [[deleteBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        if (![[AppDelegate currentAppDelegate].device isConnected]) {
            
            [SVProgressHUD showSimpleText:NSLocalizedString(@"device_disconnect", nil)];
            return;
        }
        [AppDelegate currentAppDelegate].device.bindingaccessories = YES;
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"reminders", nil) message:NSLocalizedString(@"delete_remind", nil) preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action1 = [UIAlertAction actionWithTitle:NSLocalizedString(@"sure", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            if (perModel.type == 6){
                
                if (![[AppDelegate currentAppDelegate].device isConnected]) {
                    [SVProgressHUD showSimpleText:NSLocalizedString(@"device_disconnect", nil)];
                    return;
                }
                
                LoadView *loadview = [LoadView sharedInstance];
                loadview.protetitle.text = NSLocalizedString(@"delete_tirt_pressure", nil);
                [loadview show];
                
                @weakify(self);
                RACSignal * deallocSignal = [self rac_signalForSelector:@selector(delateKey:)];
                [[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:KNotification_BindingBLEKEY object:nil] takeUntil:deallocSignal] timeout:5 onScheduler:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
                    @strongify(self);
                    NSNotification *userInfo = x;
                    NSString *date = userInfo.userInfo[@"data"];
                    if ([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"3007"]) {
                        if ([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"00"]) {
                            [SVProgressHUD showSimpleText:NSLocalizedString(@"delete_fail", nil)];
                        }else if ([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"01"]){
                            [self delateKey:self.deviceId];
                        }
                    }
                }error:^(NSError *error) {
                    [[LoadView sharedInstance] hide];
                    [SVProgressHUD showSimpleText:NSLocalizedString(@"delete_fail", nil)];
                }];
                
                NSString *fuzzyQuerySql = [NSString stringWithFormat:@"SELECT * FROM periphera_modals WHERE deviceid = '%zd'", self.deviceId];
                NSMutableArray *modals = [LVFmdbTool queryPeripheraData:fuzzyQuerySql];
                PeripheralModel *permodel = modals.firstObject;
                NSString *passwordHEX = [NSString stringWithFormat:@"A500000C3007000%ld%@",permodel.seq-1,permodel.mac];
                [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
            }
        }];
        
        UIAlertAction *action2 = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [AppDelegate currentAppDelegate].device.bindingaccessories = NO;
        }];
        
        [alert addAction:action1];
        [alert addAction:action2];
        [self presentViewController:alert animated:YES completion:nil];
    }];
    [deleteBtn setTitle:NSLocalizedString(@"remove", nil) forState:UIControlStateNormal];
    [deleteBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:deleteBtn];
    
}

- (void)delateKey:(NSInteger)deviceid{
    
    PeripheralModel *pmodel = [[LVFmdbTool queryPeripheraData:[NSString stringWithFormat:@"SELECT * FROM periphera_modals WHERE deviceid = '%zd' AND bikeid = '%zd'",deviceid,self.deviceNum]] firstObject];
    [LVFmdbTool deletePeripheraData:[NSString stringWithFormat:@"DELETE FROM periphera_modals WHERE deviceid = '%zd' AND bikeid = '%zd'", deviceid,self.deviceNum]];
    [[Manager shareManager] deletePeripheralSucceeded:pmodel];
    [self performSelector:@selector(interval) withObject:nil afterDelay:0.5];
    
}

- (void)interval{
    [[LoadView sharedInstance] hide];
    [AppDelegate currentAppDelegate].device.bindingaccessories = NO;
    [self.navigationController popViewControllerAnimated:YES];
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
