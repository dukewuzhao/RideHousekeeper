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
@property (nonatomic ,weak) UITableView *fingerTable;
@property (nonatomic, strong) NSMutableArray *fingerAry;
@property (nonatomic ,weak) UILabel *fingerPrompt;
@property (nonatomic ,strong) BikeModel *bikemodel;
@end

@implementation VehicleFingerprintViewController

- (NSMutableArray *)fingerAry {
    if (!_fingerAry) {
        _fingerAry = [[NSMutableArray alloc] init];
    }
    return _fingerAry;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.fd_fullscreenPopGestureRecognizer.enabled = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [QFTools colorWithHexString:@"#ebecf2"];
    NSString *fingerQuerySql = [NSString stringWithFormat:@"SELECT * FROM fingerprint_modals WHERE bikeid LIKE '%zd'", self.deviceNum];
    NSMutableArray *fingerprintmodals = [LVFmdbTool queryFingerprintData:fingerQuerySql];
    self.fingerAry = fingerprintmodals;
    [self setupNavView];
    [self setupView];
}

- (void)setupNavView{
    [super setupNavView];
    self.navView.backgroundColor = [QFTools colorWithHexString:MainColor];
    self.navView.showBottomLabel = NO;
    [self.navView.centerButton setTitle:NSLocalizedString(@"bike_fingerpring", nil) forState:UIControlStateNormal];
    @weakify(self);
    [self.navView.leftButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    self.navView.leftButtonBlock = ^{
        @strongify(self);
        
        [self.navigationController popViewControllerAnimated:YES];
    };
    
    NSString *bikeQuerySql = [NSString stringWithFormat:@"SELECT * FROM bike_modals WHERE bikeid LIKE '%zd'", self.deviceNum];
    NSMutableArray *bikemodals = [LVFmdbTool queryBikeData:bikeQuerySql];
    _bikemodel = bikemodals.firstObject;
    if (_bikemodel.ownerflag == 1) {
        FingerprintModel *newFingerModel = [FingerprintModel modalWith:0 fp_id:0 pos:0 name:NSLocalizedString(@"fingerpring_new", nil) added_time:0];
        [self.fingerAry addObject:newFingerModel];
        
        [self.navView.rightButton setTitle:NSLocalizedString(@"empty", nil) forState:UIControlStateNormal];
        self.navView.rightButtonBlock = ^{
            @strongify(self);
            if (![[AppDelegate currentAppDelegate].device isConnected]) {
                
                [SVProgressHUD showSimpleText:NSLocalizedString(@"device_disconnect", nil)];
                return;
            }else if(self.fingerAry.count <= 1){
                NSString *passwordHEX = [NSString stringWithFormat:@"A5000007300500"];
                [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    
                    [SVProgressHUD showSimpleText:NSLocalizedString(@"cleared_successfully", nil)];
                });
                return;
            }
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"reminders", nil) message:NSLocalizedString(@"cleared_all_finger", nil) preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *action1 = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                NSString *passwordHEX = [NSString stringWithFormat:@"A5000007300500"];
                [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
                
                LoadView *loadview = [LoadView sharedInstance];
                loadview.protetitle.text = NSLocalizedString(@"fingerpring_remove", nil);
                [loadview show];
                
                RACSignal * deallocSignal = [self rac_signalForSelector:@selector(deleteAllFinger)];
                [[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:KNotification_DeleteFinger object:nil] takeUntil:deallocSignal] timeout:6 onScheduler:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
                    @strongify(self);
                    NSNotification *userInfo = x;
                    NSString *date = userInfo.userInfo[@"data"];
                    if ([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"3005"]) {
                        
                        if ([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"00"]) {
                            [SVProgressHUD showSimpleText:NSLocalizedString(@"delete_fail", nil)];
                            
                        }else if ([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"01"]){
                            [self deleteAllFinger];
                        }
                    }
                }error:^(NSError *error) {
                    [loadview hide];
                    [SVProgressHUD showSimpleText:NSLocalizedString(@"delete_fail", nil)];
                    NSLog(@"%@",error);
                }];
            }];
            UIAlertAction *action2 = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            
            [alert addAction:action1];
            [alert addAction:action2];
            
            [self presentViewController:alert animated:YES completion:nil];
        };
    }
}


-(void)setupView{
    
    UIImageView *fingerprintIcon = [[UIImageView alloc] initWithFrame:CGRectMake(ScreenWidth/2 - 30, 70+ navHeight, 60, 60)];
    fingerprintIcon.image = [UIImage imageNamed: NSLocalizedString(@"fingerprint_bg", nil)];
    [self.view addSubview:fingerprintIcon];
   
    UILabel *TitleLab = [[UILabel alloc] initWithFrame:CGRectMake(40, CGRectGetMaxY(fingerprintIcon.frame)+ 25, ScreenWidth - 80, 20)];
    TitleLab.text = _bikemodel.bikename;
    TitleLab.textColor = [QFTools colorWithHexString:@"#666666"];
    TitleLab.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:TitleLab];
    
    UILabel *fingerPrompt = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(TitleLab.frame)+ 15, ScreenWidth, 10)];
    fingerPrompt.text = [NSString stringWithFormat:NSLocalizedString(@"fingerpring_list", nil),self.fingerAry.count-1];
    fingerPrompt.textColor = [QFTools colorWithHexString:@"#666666"];
    fingerPrompt.font = [UIFont systemFontOfSize:13];
    [self.view addSubview:fingerPrompt];
    self.fingerPrompt = fingerPrompt;
    
    UITableView *fingerTable = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(TitleLab.frame)+ 30, ScreenWidth, ScreenHeight - 30 - CGRectGetMaxY(TitleLab.frame))];
    fingerTable.delegate = self;
    fingerTable.dataSource = self;
    fingerTable.backgroundColor = [UIColor clearColor];
    fingerTable.separatorColor = [UIColor colorWithWhite:1 alpha:0.06];
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
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
    }
    UIImageView *arrow = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 8.4, 15)];
    arrow.image = [UIImage imageNamed:@"arrow"];
    cell.accessoryView = arrow;
    if ([self.fingerAry[indexPath.row] bikeid] == 0) {
        
        cell.textLabel.textColor = [QFTools colorWithHexString:NSLocalizedString(@"VCControlColor", nil)];
    }else{
        
        cell.imageView.image = [UIImage imageNamed:@"user_fingerprint_icon"];
        cell.textLabel.textColor = [UIColor whiteColor];
    }
    
    cell.textLabel.text = [self.fingerAry[indexPath.row] name];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([self.fingerAry[indexPath.row] bikeid] == 0) {
        
        if (![[AppDelegate currentAppDelegate].device isConnected]) {
            
            [SVProgressHUD showSimpleText:NSLocalizedString(@"device_disconnect", nil)];
            return;
        }
        
        if (self.fingerAry.count-1 >=10) {
            [SVProgressHUD showSimpleText:NSLocalizedString(@"fingerpring_max_langth", nil)];
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

- ( void )tableView:( UITableView  *)tableView  willDisplayCell :( UITableViewCell  *)cell  forRowAtIndexPath :( NSIndexPath  *)indexPath
{
    cell .backgroundColor  = [UIColor colorWithWhite:1 alpha:0.05];
}

#pragma mark -  EditFingerprinDelegate
-(void)deleteFingerprintSuccess{
    
    [self.fingerAry removeAllObjects];
    NSString *fingerQuerySql = [NSString stringWithFormat:@"SELECT * FROM fingerprint_modals WHERE bikeid LIKE '%zd'", self.deviceNum];
    NSMutableArray *fingerprintmodals = [LVFmdbTool queryFingerprintData:fingerQuerySql];
    self.fingerAry = fingerprintmodals;
    FingerprintModel *newFingerModel = [FingerprintModel modalWith:0 fp_id:0 pos:0 name:NSLocalizedString(@"fingerpring_new", nil) added_time:0];
    [self.fingerAry addObject:newFingerModel];
    
    self.fingerPrompt.text = [NSString stringWithFormat:NSLocalizedString(@"fingerpring_list", nil),self.fingerAry.count-1];
    
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
    FingerprintModel *newFingerModel = [FingerprintModel modalWith:0 fp_id:0 pos:0 name:NSLocalizedString(@"fingerpring_new", nil) added_time:0];
    [self.fingerAry addObject:newFingerModel];
    
    self.fingerPrompt.text = [NSString stringWithFormat:NSLocalizedString(@"fingerpring_list", nil),self.fingerAry.count-1];
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
    FingerprintModel *newFingerModel = [FingerprintModel modalWith:0 fp_id:0 pos:0 name:NSLocalizedString(@"fingerpring_new", nil) added_time:0];
    [self.fingerAry addObject:newFingerModel];
    
    self.fingerPrompt.text = [NSString stringWithFormat:NSLocalizedString(@"fingerpring_list", nil),self.fingerAry.count-1];
    dispatch_async(dispatch_get_main_queue(), ^{
        // something
        [self.fingerTable reloadData];
    });
}

-(void)deleteAllFinger{
    
        [[LoadView sharedInstance] hide];
        NSString *deleteFingerSql = [NSString stringWithFormat:@"DELETE FROM fingerprint_modals WHERE bikeid LIKE '%zd'", self.deviceNum];
        [LVFmdbTool deleteFingerprintData:deleteFingerSql];
    
        [self.fingerAry removeAllObjects];
        NSString *fingerQuerySql = [NSString stringWithFormat:@"SELECT * FROM fingerprint_modals WHERE bikeid LIKE '%zd'", self.deviceNum];
        NSMutableArray *fingerprintmodals = [LVFmdbTool queryFingerprintData:fingerQuerySql];
        self.fingerAry = fingerprintmodals;
        FingerprintModel *newFingerModel = [FingerprintModel modalWith:0 fp_id:0 pos:0 name:NSLocalizedString(@"fingerpring_new", nil) added_time:0];
        [self.fingerAry addObject:newFingerModel];
    
        self.fingerPrompt.text = [NSString stringWithFormat:NSLocalizedString(@"fingerpring_list", nil),self.fingerAry.count-1];
    
        dispatch_async(dispatch_get_main_queue(), ^{
            // something
            [self.fingerTable reloadData];
        });
    
        [SVProgressHUD showSimpleText:NSLocalizedString(@"cleared_successfully", nil)];
    
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
