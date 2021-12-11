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
    [self setupNavView];

    [self setupView];
}

- (void)setupNavView{
    [super setupNavView];
    self.navView.showBottomLabel = NO;
    [self.navView.centerButton setTitle:@"配件信息" forState:UIControlStateNormal];
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
    UIView *model = [[UIView alloc] initWithFrame:CGRectMake(0, 10 + navHeight, ScreenWidth, 40)];
    model.backgroundColor =CellColor;
    [self.view addSubview:model];
    
    UILabel *modelLable = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 80, 20)];
    modelLable.text = @"条码";
    modelLable.textColor = [UIColor blackColor];
    modelLable.textAlignment = NSTextAlignmentLeft;
    modelLable.font = [UIFont systemFontOfSize:15];
    [model addSubview:modelLable];
    
    UILabel *typeLabel = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth - 200, 10, 180, 20)];
    typeLabel.textColor = [QFTools colorWithHexString:@"#cccccc"];
    typeLabel.text = perModel.sn;
    typeLabel.font = [UIFont systemFontOfSize:14];
    typeLabel.textAlignment = NSTextAlignmentRight;
    [model addSubview:typeLabel];
    
    UIView *bindingNumber = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(model.frame)+10, ScreenWidth, 40)];
    bindingNumber.backgroundColor = CellColor;
    [self.view addSubview:bindingNumber];
    
    
    UILabel *bindingNumberLable = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 80, 20)];
    bindingNumberLable.text = @"MAC地址";
    bindingNumberLable.textColor = [UIColor blackColor];
    bindingNumberLable.textAlignment = NSTextAlignmentLeft;
    bindingNumberLable.font = [UIFont systemFontOfSize:15];
    [bindingNumber addSubview:bindingNumberLable];
    
    UILabel *numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth - 200, 10, 180, 20)];
    numberLabel.textAlignment = NSTextAlignmentRight;
    numberLabel.textColor = [QFTools colorWithHexString:@"#cccccc"];
    numberLabel.font = [UIFont systemFontOfSize:14];
    numberLabel.text = perModel.mac;
    [bindingNumber addSubview:numberLabel];
    
    UIView *accessories = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(bindingNumber.frame)+10, ScreenWidth, 40)];
    accessories.backgroundColor = CellColor;
    [self.view addSubview:accessories];
    
    UILabel *accessoriesLable = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 80, 20)];
    accessoriesLable.text = @"类型";
    accessoriesLable.textColor = [UIColor blackColor];
    accessoriesLable.textAlignment = NSTextAlignmentLeft;
    accessoriesLable.font = [UIFont systemFontOfSize:15];
    [accessories addSubview:accessoriesLable];
    
    UILabel *battery = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth - 110, 10, 90, 20)];
    battery.textAlignment = NSTextAlignmentRight;
    battery.textColor = [QFTools colorWithHexString:@"#cccccc"];
    battery.font = [UIFont systemFontOfSize:14];
    [accessories addSubview:battery];
    
    if (perModel.type == 2) {
        
        battery.text = @"感应钥匙";
        
    }else if (perModel.type == 3) {
        
        battery.text = @"普通钥匙";
        
    }else if (perModel.type == 4) {
        
        battery.text = @"GPS外设";
        
    }else if (perModel.type == 5) {
        
        battery.text = @"骑行手环";
        
    }else if (perModel.type == 6) {
        
        battery.text = @"车辆胎压";
    }else if (perModel.type == 7) {
        numberLabel.text = @"00000000";
        battery.text = @"智能钥匙";
    }
    
    NSString *bikeQuerySql = [NSString stringWithFormat:@"SELECT * FROM bike_modals WHERE bikeid = '%zd'", self.deviceNum];
    NSMutableArray *bikemodals = [LVFmdbTool queryBikeData:bikeQuerySql];
    BikeModel *bikemodel = bikemodals.firstObject;
    
    @weakify(self);
    UIButton *deleteBtn = [[UIButton alloc] initWithFrame:CGRectMake(25, ScreenHeight - 110, ScreenWidth - 50, 45)];
    deleteBtn.backgroundColor = [UIColor redColor];
    [[deleteBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        if (![CommandDistributionServices isConnect]) {
            
            [SVProgressHUD showSimpleText:@"车辆未连接"];
            return;
        }else if (bikemodel.ownerflag == 0){
            [SVProgressHUD showSimpleText:@"子用户无此权限"];
            return;
        }
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"是否删除该配件" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            if (perModel.type == 2 || perModel.type == 5){
                
                if (![CommandDistributionServices isConnect]) {
                    [SVProgressHUD showSimpleText:@"车辆未连接"];
                    return;
                }
                
                LoadView *loadview = [LoadView sharedInstance];
                loadview.protetitle.text = @"删除配件中";
                [loadview show];
                
                NSString *fuzzyQuerySql = [NSString stringWithFormat:@"SELECT * FROM periphera_modals WHERE deviceid = '%zd'", self.deviceId];
                NSMutableArray *modals = [LVFmdbTool queryPeripheraData:fuzzyQuerySql];
                PeripheralModel *permodel = modals.firstObject;
                
                [CommandDistributionServices deleteInductionKey:permodel.seq mac:permodel.mac data:^(id data) {
                    @strongify(self);
                    if ([data intValue] == ConfigurationFail) {
                        [loadview hide];
                        [SVProgressHUD showSimpleText:@"删除失败"];
                    }else{
                        [self delateKey:self.deviceId];
                    }
                } error:^(CommandStatus status) {
                    switch (status) {
                        case SendSuccess:
                            NSLog(@"删除配件发送成功");
                            break;
                            
                        default:
                            [loadview hide];
                            [SVProgressHUD showSimpleText:@"删除失败"];
                            break;
                    }
                }];
                
            }else if (perModel.type == 6){
                
                if (![CommandDistributionServices isConnect]) {
                    [SVProgressHUD showSimpleText:@"车辆未连接"];
                    return;
                }
                
                LoadView *loadview = [LoadView sharedInstance];
                loadview.protetitle.text = @"删除配件中";
                [loadview show];
                
                @weakify(self);
                PeripheralModel *permodel = [[LVFmdbTool queryPeripheraData:[NSString stringWithFormat:@"SELECT * FROM periphera_modals WHERE deviceid = '%zd'", self.deviceId]] firstObject];
                [CommandDistributionServices deleteTirePressure:permodel.seq-1 mac:permodel.mac data:^(id data) {
                    @strongify(self);
                    if ([data intValue] == ConfigurationFail) {
                        [loadview hide];
                        [SVProgressHUD showSimpleText:@"删除失败"];
                    }else{
                        [self delateKey:self.deviceId];
                    }
                } error:^(CommandStatus status) {
                    switch (status) {
                        case SendSuccess:
                            NSLog(@"删除胎压发送成功");
                            break;
                            
                        default:
                            [loadview hide];
                            [SVProgressHUD showSimpleText:@"删除失败"];
                            break;
                    }
                }];
            }else if (perModel.type == 7){
                
                if (![CommandDistributionServices isConnect]) {
                    [SVProgressHUD showSimpleText:@"车辆未连接"];
                    return;
                }
                
                LoadView *loadview = [LoadView sharedInstance];
                loadview.protetitle.text = @"删除配件中";
                [loadview show];
                
                @weakify(self);
                PeripheralModel *permodel = [[LVFmdbTool queryPeripheraData:[NSString stringWithFormat:@"SELECT * FROM periphera_modals WHERE deviceid = '%zd'", self.deviceId]] firstObject];
                [CommandDistributionServices deleteBLEKey:permodel.seq-1 data:^(id data) {
                    @strongify(self);
                    if ([data intValue] == ConfigurationFail) {
                        [SVProgressHUD showSimpleText:@"删除失败"];
                    }else{
                        [self delateKey:self.deviceId];
                    }
                } error:^(CommandStatus status) {
                    switch (status) {
                        case SendSuccess:
                            NSLog(@"删除配件发送成功");
                            break;
                            
                        default:
                            [[LoadView sharedInstance] hide];
                            [SVProgressHUD showSimpleText:@"删除失败"];
                            break;
                    }
                }];
            }
        }];
        
        UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }];
        
        [alert addAction:action1];
        [alert addAction:action2];
        [self presentViewController:alert animated:YES completion:nil];
    }];
    [deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
    [deleteBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:deleteBtn];
}

- (void)delateKey:(NSInteger)deviceid{
    
    NSString *token = [QFTools getdata:@"token"];
    NSNumber *device_id= [NSNumber numberWithInt:(int)deviceid];
    NSNumber *bike_id= [NSNumber numberWithInt:(int)_deviceNum];
    NSString *URLString = [NSString stringWithFormat:@"%@%@",QGJURL,@"app/deldevice"];
    NSDictionary *parameters = @{@"token": token,@"bike_id":bike_id,@"device_id":device_id};
    [[HttpRequest sharedInstance] postWithURLString:URLString parameters:parameters success:^(id _Nullable dict) {
        
        if ([dict[@"status"] intValue] == 0) {
            
            NSString *QuerykeySql = [NSString stringWithFormat:@"SELECT * FROM periphera_modals WHERE deviceid = '%zd'",deviceid];
            PeripheralModel *pmodel = [[LVFmdbTool queryPeripheraData:QuerykeySql] firstObject];
            NSString *deleteSql = [NSString stringWithFormat:@"DELETE FROM periphera_modals WHERE deviceid = '%zd' AND bikeid = '%zd'", deviceid,self.deviceNum];
            [LVFmdbTool deletePeripheraData:deleteSql];
            [[Manager shareManager] deletePeripheralSucceeded:pmodel];
            [self performSelector:@selector(interval) withObject:nil afterDelay:0.5];
        }else{
            [SVProgressHUD showSimpleText:dict[@"status_info"]];
        }
        
    }failure:^(NSError *error) {
        
        [SVProgressHUD showSimpleText:TIP_OF_NO_NETWORK];
    }];
}

- (void)interval{
    [[LoadView sharedInstance] hide];
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
