//
//  VehicleFingerprintViewController.m
//  RideHousekeeper
//
//  Created by Apple on 2017/11/21.
//  Copyright © 2017年 Duke Wu. All rights reserved.
//

#import "VehicleFingerprintViewController.h"
#import "InputFingerprintViewController.h"
#import "EditFingerprintViewController.h"

@interface VehicleFingerprintViewController ()<UITableViewDelegate,UITableViewDataSource,EditFingerprinDelegate,inputFingerprinDelegate>
@property (nonatomic, strong)BikeModel *bikemodel;
@property (nonatomic ,weak) UITableView *fingerTable;
@property (nonatomic, strong) NSMutableArray *fingerAry;
@property (nonatomic ,weak) UILabel *fingerPrompt;
@end

@implementation VehicleFingerprintViewController

- (NSMutableArray *)fingerAry {
    if (!_fingerAry) {
        _fingerAry = [[NSMutableArray alloc] init];
    }
    return _fingerAry;
}

-(void)setDeviceNum:(NSInteger)deviceNum{
    _deviceNum = deviceNum;
    NSMutableArray *bikemodals = [LVFmdbTool queryBikeData:[NSString stringWithFormat:@"SELECT * FROM bike_modals WHERE bikeid LIKE '%zd'", deviceNum]];
    _bikemodel = bikemodals.firstObject;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.fd_fullscreenPopGestureRecognizer.enabled = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString *fingerQuerySql = [NSString stringWithFormat:@"SELECT * FROM fingerprint_modals WHERE bikeid LIKE '%zd'", self.deviceNum];
    NSMutableArray *fingerprintmodals = [LVFmdbTool queryFingerprintData:fingerQuerySql];
    self.fingerAry = fingerprintmodals;
    [self setupNavView];
    [self setupView];
}

- (void)setupNavView{
    [super setupNavView];
    self.navView.showBottomLabel = NO;
    [self.navView.centerButton setTitle:@"车辆指纹"forState:UIControlStateNormal];
    @weakify(self);
    [self.navView.leftButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    self.navView.leftButtonBlock = ^{
        @strongify(self);
        
        [self.navigationController popViewControllerAnimated:YES];
    };
    
    if (_bikemodel.ownerflag == 1) {
        FingerprintModel *newFingerModel = [FingerprintModel modalWith:0 fp_id:0 pos:0 name:@"录入新指纹" added_time:0];
        [self.fingerAry addObject:newFingerModel];
        
        [self.navView.rightButton setTitle:@"清空" forState:UIControlStateNormal];
        self.navView.rightButtonBlock = ^{
            @strongify(self);
            if (![CommandDistributionServices isConnect]) {
                
                [SVProgressHUD showSimpleText:@"车辆未连接"];
                return;
            }else if(![HttpRequest sharedInstance].available){
                
                [SVProgressHUD showSimpleText:TIP_OF_NO_NETWORK];
                return;
            }
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"是否清空指纹，清空后请先用手指触摸指纹传感器，直到听到“啵啵啵”提示音后再重新录入指纹使用。" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                LoadView *loadview = [LoadView sharedInstance];
                loadview.protetitle.text = @"删除指纹中";
                [loadview show];
                
                [CommandDistributionServices deleteFingerPrint:0 data:^(id data) {
                    @strongify(self);
                    if ([data intValue] == ConfigurationSuccess) {
                        [self deleteAllFinger];
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
        };
    }
}


-(void)setupView{
    
    UIImageView *fingerprintIcon = [[UIImageView alloc] initWithFrame:CGRectMake(ScreenWidth/2 - 30, 70+ navHeight, 60, 60)];
    fingerprintIcon.image = [UIImage imageNamed:@"fingerprint_bg"];
    [self.view addSubview:fingerprintIcon];
    
    UILabel *TitleLab = [[UILabel alloc] initWithFrame:CGRectMake(40, CGRectGetMaxY(fingerprintIcon.frame)+ 25, ScreenWidth - 80, 20)];
    TitleLab.text = @"智能电动车";
    TitleLab.textColor = [QFTools colorWithHexString:@"#666666"];
    TitleLab.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:TitleLab];
    
    UILabel *fingerPrompt = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(TitleLab.frame)+ 15, ScreenWidth, 10)];
    fingerPrompt.text = _bikemodel.ownerflag == 0? [NSString stringWithFormat:@"指纹列表（%zd/10）",self.fingerAry.count]:[NSString stringWithFormat:@"指纹列表（%zd/10）",self.fingerAry.count-1];
    fingerPrompt.textColor = [QFTools colorWithHexString:@"#999999"];
    fingerPrompt.font = [UIFont systemFontOfSize:13];
    [self.view addSubview:fingerPrompt];
    self.fingerPrompt = fingerPrompt;
    
    UITableView *fingerTable = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(TitleLab.frame)+ 30, ScreenWidth, ScreenHeight - 30 - CGRectGetMaxY(TitleLab.frame))];
    fingerTable.delegate = self;
    fingerTable.dataSource = self;
    fingerTable.backgroundColor = [UIColor clearColor];
    fingerTable.separatorColor =  [QFTools colorWithHexString:SeparatorColor];
    [fingerTable setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    [self.view addSubview:fingerTable];
    self.fingerTable = fingerTable;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.fingerAry.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 45;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellName = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
    }
    UIImageView *arrow = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 8.4, 15)];
    arrow.image = [UIImage imageNamed:@"arrow"];
    cell.accessoryView = arrow;
    if ([self.fingerAry[indexPath.row] bikeid] == 0) {
        
        cell.textLabel.textColor = [QFTools colorWithHexString:MainColor];
    }else{
        
        cell.imageView.image = [UIImage imageNamed:@"user_fingerprint_icon"];
        cell.textLabel.textColor = [UIColor blackColor];
    }
    cell.textLabel.text = [self.fingerAry[indexPath.row] name];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (![HttpRequest sharedInstance].available) {
        
        [SVProgressHUD showSimpleText:@"网络未连接"];
        return;
    }
    
    if ([self.fingerAry[indexPath.row] bikeid] == 0) {
        
        if (![CommandDistributionServices isConnect]) {
            [SVProgressHUD showSimpleText:@"车辆未连接"];
            return;
        }else if (self.fingerAry.count-1 >=10) {
            [SVProgressHUD showSimpleText:@"指纹录入已达上限"];
            return;
        }
        InputFingerprintViewController *inputVc = [InputFingerprintViewController new];
        inputVc.deviceNum = self.deviceNum;
        inputVc.delegate = self;
        [self.navigationController pushViewController:inputVc animated:YES];
    }else{
        
        EditFingerprintViewController *editVc = [EditFingerprintViewController new];
        editVc.deviceNum = self.deviceNum;
        editVc.fpmodel = [self.fingerAry objectAtIndex:indexPath.row];
        editVc.delegate = self;
        [self.navigationController pushViewController:editVc animated:YES];
    }
}

- (void)tableView:( UITableView  *)tableView  willDisplayCell :( UITableViewCell  *)cell  forRowAtIndexPath :( NSIndexPath  *)indexPath{
    cell .backgroundColor  = CellColor;
    if (cell.accessoryType == UITableViewCellAccessoryDisclosureIndicator) {
        UIImage *arrowImage = [UIImage imageNamed:@"arrow"];
        UIImageView *arrowImageView = [[UIImageView alloc] initWithImage:arrowImage];
        cell.accessoryView = arrowImageView;
    }
}

#pragma mark -  EditFingerprinDelegate
-(void)deleteFingerprintSuccess{
    
    [self.fingerAry removeAllObjects];
    NSString *fingerQuerySql = [NSString stringWithFormat:@"SELECT * FROM fingerprint_modals WHERE bikeid LIKE '%zd'", self.deviceNum];
    NSMutableArray *fingerprintmodals = [LVFmdbTool queryFingerprintData:fingerQuerySql];
    self.fingerAry = fingerprintmodals;
    FingerprintModel *newFingerModel = [FingerprintModel modalWith:0 fp_id:0 pos:0 name:@"新建指纹" added_time:0];
    [self.fingerAry addObject:newFingerModel];
    
    self.fingerPrompt.text = [NSString stringWithFormat:@"指纹列表（%lu/10）",self.fingerAry.count-1];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // something
        [self.fingerTable reloadData];
    });
}

-(void)editFingerprintNameSuccess{
    
    [self.fingerAry removeAllObjects];
    NSString *fingerQuerySql = [NSString stringWithFormat:@"SELECT * FROM fingerprint_modals WHERE bikeid LIKE '%zd'", self.deviceNum];
    NSMutableArray *fingerprintmodals = [LVFmdbTool queryFingerprintData:fingerQuerySql];
    self.fingerAry = fingerprintmodals;
    FingerprintModel *newFingerModel = [FingerprintModel modalWith:0 fp_id:0 pos:0 name:@"新建指纹" added_time:0];
    [self.fingerAry addObject:newFingerModel];
    
    self.fingerPrompt.text = [NSString stringWithFormat:@"指纹列表（%lu/10）",self.fingerAry.count-1];
    dispatch_async(dispatch_get_main_queue(), ^{
        // something
        [self.fingerTable reloadData];
    });
}

#pragma mark -  InputFingerprinDelegate
-(void)inputFingerprintOver{
    
    [self.fingerAry removeAllObjects];
    NSString *fingerQuerySql = [NSString stringWithFormat:@"SELECT * FROM fingerprint_modals WHERE bikeid LIKE '%zd'", self.deviceNum];
    NSMutableArray *fingerprintmodals = [LVFmdbTool queryFingerprintData:fingerQuerySql];
    self.fingerAry = fingerprintmodals;
    FingerprintModel *newFingerModel = [FingerprintModel modalWith:0 fp_id:0 pos:0 name:@"新建指纹" added_time:0];
    [self.fingerAry addObject:newFingerModel];
    
    self.fingerPrompt.text = [NSString stringWithFormat:@"指纹列表（%lu/10）",self.fingerAry.count-1];
    dispatch_async(dispatch_get_main_queue(), ^{
        // something
        [self.fingerTable reloadData];
    });
}

-(void)deleteAllFinger{
    
    NSString *URLString = [NSString stringWithFormat:@"%@%@",QGJURL,@"app/delfingerprint"];
    NSString *token = [QFTools getdata:@"token"];
    NSNumber *fpid = [NSNumber numberWithInteger:-1];
    NSNumber *bikeid = [NSNumber numberWithInteger:self.deviceNum];
    NSDictionary *parameters = @{@"token": token, @"bike_id": bikeid,@"fp_id": fpid};

    [[HttpRequest sharedInstance] postWithURLString:URLString parameters:parameters success:^(id _Nullable dict) {
        
        if ([dict[@"status"] intValue] == 0) {
            [[LoadView sharedInstance] hide];
            NSString *deleteFingerSql = [NSString stringWithFormat:@"DELETE FROM fingerprint_modals WHERE bikeid LIKE '%zd'", self.deviceNum];
            [LVFmdbTool deleteFingerprintData:deleteFingerSql];
            
            [self.fingerAry removeAllObjects];
            NSString *fingerQuerySql = [NSString stringWithFormat:@"SELECT * FROM fingerprint_modals WHERE bikeid LIKE '%zd'", self.deviceNum];
            NSMutableArray *fingerprintmodals = [LVFmdbTool queryFingerprintData:fingerQuerySql];
            self.fingerAry = fingerprintmodals;
            FingerprintModel *newFingerModel = [FingerprintModel modalWith:0 fp_id:0 pos:0 name:@"新建指纹" added_time:0];
            [self.fingerAry addObject:newFingerModel];
            
            self.fingerPrompt.text = [NSString stringWithFormat:@"指纹列表（%lu/10）",self.fingerAry.count-1];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // something
                [self.fingerTable reloadData];
            });
            [SVProgressHUD showSimpleText:@"清空成功"];
            
        }else{
            [[LoadView sharedInstance] hide];
            [SVProgressHUD showSimpleText:dict[@"status_info"]];
        }
        
    }failure:^(NSError *error) {
        
        NSLog(@"error :%@",error);
        [[LoadView sharedInstance] hide];
        [SVProgressHUD showSimpleText:@"删除失败"];
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
