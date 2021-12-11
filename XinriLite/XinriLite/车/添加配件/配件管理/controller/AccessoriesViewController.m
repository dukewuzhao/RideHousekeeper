//
//  AccessoriesViewController.m
//  RideHousekeeper
//
//  Created by smartwallit on 16/7/14.
//  Copyright © 2016年 Duke Wu. All rights reserved.
//

#import "AccessoriesViewController.h"
#import "TwoDimensionalCodecanViewController.h"
#import "BindingkeyViewController.h"
#import "BindingBleKeyViewController.h"
#import "DeviceModifyViewController.h"
#import "CollectionViewCell.h"
#import "DelPopView.h"
#import "CustomFlowLayout.h"
#import "AccessoriesTableViewCell.h"
#import "AccessoriesModel.h"
#import "Manager.h"
@interface AccessoriesViewController ()<UITableViewDelegate,UITableViewDataSource,DelPopViewDelegate,BindingkeyDelegate,BindingBlekeyDelegate,AccessoriesTableViewCellDelegate,ManagerDelegate>{
    NSInteger tableNum;
}
@property (nonatomic, strong) DelPopView *outputView;//右上角弹出按钮
@property (nonatomic, strong) UITableView *AccessoriesView;
@property(nonatomic,assign) NSInteger deviceid;
@property (strong, nonatomic) NSMutableArray *modelArry;
//@property (strong, nonatomic) NSMutableArray *modelArry2;
@property (strong, nonatomic) NSMutableArray *modelArry3;
@property (strong, nonatomic) NSMutableArray *bleKeyArry;
@end

@implementation AccessoriesViewController

-(NSMutableArray *)modelArry{

    if (!_modelArry) {
        _modelArry = [NSMutableArray new];
    }
    return _modelArry;
}

//-(NSMutableArray *)modelArry2{
//
//    if (!_modelArry2) {
//        _modelArry2 = [NSMutableArray new];
//    }
//    return _modelArry2;
//}

-(NSMutableArray *)modelArry3{

    if (!_modelArry3) {
        _modelArry3 = [NSMutableArray new];
    }
    return _modelArry3;
}

-(NSMutableArray *)bleKeyArry{
    
    if (!_bleKeyArry) {
        _bleKeyArry = [NSMutableArray new];
    }
    return _bleKeyArry;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.fd_fullscreenPopGestureRecognizer.enabled = YES;
}

-(void)setDeviceNum:(NSInteger)deviceNum{
    _deviceNum = deviceNum;
    
    NSMutableArray *bikemodels = [LVFmdbTool queryBikeData:[NSString stringWithFormat:@"SELECT * FROM bike_modals WHERE bikeid LIKE '%zd'", _deviceNum]];
    BikeModel *bikeModel = bikemodels.firstObject;
    if (bikeModel.tpm_func == 1) {
        tableNum = 3;
    }else{
        tableNum = 2;
    }
    [_AccessoriesView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [QFTools colorWithHexString:@"#ebecf2"];
    [self setupNavView];
    [[Manager shareManager] addDelegate:self];
    [self setupMainview];
}

- (void)setupNavView{
    [super setupNavView];
    self.navView.backgroundColor = [QFTools colorWithHexString:MainColor];
    self.navView.showBottomLabel = NO;
    [self.navView.centerButton setTitle:NSLocalizedString(@"accessories_manager", nil) forState:UIControlStateNormal];
    @weakify(self);
    [self.navView.leftButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    self.navView.leftButtonBlock = ^{
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    };
}

-(void)setupMainview{
    
    [self getModelAryData];
    _AccessoriesView = [[UITableView alloc] initWithFrame:CGRectMake(0, navHeight, ScreenWidth, ScreenHeight - navHeight)];
    _AccessoriesView.delegate = self;
    _AccessoriesView.dataSource = self;
    _AccessoriesView.bounces = NO;
    _AccessoriesView.backgroundColor = [UIColor clearColor];
    _AccessoriesView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_AccessoriesView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    [self.view addSubview:_AccessoriesView];
}

#pragma mark -- TableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
    
    return tableNum;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return ScreenHeight*.25 + 75;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.01;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *headerView = [UIView new];
    return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    UIView *footerView = [UIView new];
    return footerView;
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section{
    
    view.tintColor = [QFTools colorWithHexString:@"#ebecf2"];
}

- ( void )tableView:( UITableView  *)tableView  willDisplayCell :( UITableViewCell  *)cell  forRowAtIndexPath :( NSIndexPath  *)indexPath{
    
    cell.backgroundColor = [UIColor colorWithWhite:1 alpha:0.05];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AccessoriesTableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:@"AccessoriesCell"];
    if (!cell) {
        cell = [[AccessoriesTableViewCell alloc] initWithStyle:0 reuseIdentifier:@"AccessoriesCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
        cell.deviceNum = self.deviceNum;
    }
    
    if (indexPath.section == 0) {
        
        cell.titleLab.text = NSLocalizedString(@"key_model_normal", nil);
        [cell reloadModel:self.modelArry :indexPath];
        [cell addAnnotationLab:NSLocalizedString(@"normal_accessories_content", nil)];
        
    }else if(indexPath.section == 1){
        cell.titleLab.text = NSLocalizedString(@"smart_key", nil);
        [cell addAnnotationLab:NSLocalizedString(@"BLE_accessories_content", nil)];
        [cell reloadModel:self.bleKeyArry :indexPath];
    }
//    else if(indexPath.section == 2){
//        cell.titleLab.text = NSLocalizedString(@"smart_accessories", nil);
//        [cell addAnnotationLab:NSLocalizedString(@"smart_accessories_content", nil)];
//        [cell reloadModel:self.modelArry2 :indexPath];
//    }
    else{
        cell.titleLab.text = NSLocalizedString(@"tirt_pressure_check", nil);
        [cell reloadModel:self.modelArry3 :indexPath];
    }
    return cell;
}

#pragma mark -DelPopViewDelegate
- (void)didSelectedAtIndexPath:(NSInteger)selectTag :(NSInteger)deviceid{
    self.deviceid = deviceid;
    [AppDelegate currentAppDelegate].device.bindingaccessories = YES;
    if (selectTag == 30) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"reminders", nil) message:NSLocalizedString(@"delete_remind", nil) preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action1 = [UIAlertAction actionWithTitle:NSLocalizedString(@"sure", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (![[AppDelegate currentAppDelegate].device isConnected]) {
                [SVProgressHUD showSimpleText:NSLocalizedString(@"device_disconnect", nil)];
                return;
            }
            
            LoadView *loadview = [LoadView sharedInstance];
            loadview.protetitle.text = NSLocalizedString(@"removing", nil);
            [loadview show];
            
            NSString *QuerySql = [NSString stringWithFormat:@"SELECT * FROM periphera_modals WHERE deviceid = '%zd'", self.deviceid];
            NSMutableArray *keymodals = [LVFmdbTool queryPeripheraData:QuerySql];
            PeripheralModel *keyPermodel = keymodals.firstObject;
            NSString *fuzzyQuerySql = [NSString stringWithFormat:@"SELECT * FROM periphera_modals WHERE type = '%d' AND seq = '%zd' AND bikeid = '%zd'",3,keyPermodel.seq,self.deviceNum];
            NSMutableArray *modals = [LVFmdbTool queryPeripheraData:fuzzyQuerySql];
            PeripheralModel *permodel = modals.firstObject;
            [self delateKey:permodel.deviceid];
            NSString *passwordHEX = [@"A500001730010" stringByAppendingFormat:@"%ld%@%@%@%@",keyPermodel.seq, @"FFFFFFFF", @"FFFFFFFF", @"FFFFFFFF", @"FFFFFFFF"];
            [[AppDelegate currentAppDelegate].device sendHexstring:passwordHEX];
            [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:[passwordHEX substringWithRange:NSMakeRange(0, 40)]]];
        }];
        UIAlertAction *action2 = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [AppDelegate currentAppDelegate].device.bindingaccessories = NO;
        }];
        [alert addAction:action1];
        [alert addAction:action2];
        [self presentViewController:alert animated:YES completion:nil];
        
    }else if (selectTag == 32){
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"reminders", nil) message:NSLocalizedString(@"delete_remind", nil) preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action1 = [UIAlertAction actionWithTitle:NSLocalizedString(@"sure", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (![[AppDelegate currentAppDelegate].device isConnected]) {
                [SVProgressHUD showSimpleText:NSLocalizedString(@"device_disconnect", nil)];
                return;
            }
            
            LoadView *loadview = [LoadView sharedInstance];
            loadview.protetitle.text = NSLocalizedString(@"removing", nil);
            [loadview show];
            
            @weakify(self);
            RACSignal * deallocSignal = [self rac_signalForSelector:@selector(delateKey:)];
            [[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:KNotification_BindingNewBLEKEY object:nil] takeUntil:deallocSignal] timeout:5 onScheduler:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
                @strongify(self);
                NSNotification *userInfo = x;
                NSString *date = userInfo.userInfo[@"data"];
                if ([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"1007"]) {
                    if ([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"00"]) {
                        [SVProgressHUD showSimpleText:NSLocalizedString(@"delete_fail", nil)];
                    }else if ([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"01"]){
                        [self delateKey:self.deviceid];
                    }
                }
            }error:^(NSError *error) {
                [SVProgressHUD showSimpleText:NSLocalizedString(@"delete_fail", nil)];
            }];
            
            NSString *fuzzyQuerySql = [NSString stringWithFormat:@"SELECT * FROM periphera_modals WHERE deviceid = '%zd'", self.deviceid];
            NSMutableArray *modals = [LVFmdbTool queryPeripheraData:fuzzyQuerySql];
            PeripheralModel *permodel = modals.firstObject;
            NSString *passwordHEX = [NSString stringWithFormat:@"A50000081007000%ld",permodel.seq-1];
            [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
        }];
        UIAlertAction *action2 = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [AppDelegate currentAppDelegate].device.bindingaccessories = NO;
        }];
        [alert addAction:action1];
        [alert addAction:action2];
        [self presentViewController:alert animated:YES completion:nil];
    }else if (selectTag == 34){
        
        LoadView *loadview = [LoadView sharedInstance];
        loadview.protetitle.text = NSLocalizedString(@"removing", nil);
        [loadview show];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"reminders", nil) message:NSLocalizedString(@"delete_remind", nil) preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action1 = [UIAlertAction actionWithTitle:NSLocalizedString(@"sure", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (![[AppDelegate currentAppDelegate].device isConnected]) {
                [SVProgressHUD showSimpleText:NSLocalizedString(@"device_disconnect", nil)];
                return;
            }
            @weakify(self);
            RACSignal * deallocSignal = [self rac_signalForSelector:@selector(delateKey:)];
            [[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:KNotification_BindingBLEKEY object:nil] takeUntil:deallocSignal] timeout:5 onScheduler:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
                @strongify(self);
                NSNotification *userInfo = x;
                NSString *date = userInfo.userInfo[@"data"];
                if ([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"3002"]) {
                    if ([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"00"]) {
                        [SVProgressHUD showSimpleText:NSLocalizedString(@"delete_fail", nil)];
                    }else if ([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"01"]){
                        [self delateKey:self.deviceid];
                    }
                }
            }error:^(NSError *error) {
                [SVProgressHUD showSimpleText:NSLocalizedString(@"delete_fail", nil)];
            }];
            
            NSString *fuzzyQuerySql = [NSString stringWithFormat:@"SELECT * FROM periphera_modals WHERE deviceid = '%zd'", self.deviceid];
            NSMutableArray *modals = [LVFmdbTool queryPeripheraData:fuzzyQuerySql];
            PeripheralModel *permodel = modals.firstObject;
            NSInteger number = permodel.seq;
            NSString *passwordHEX = [NSString stringWithFormat:@"A500000E3002010%ld%@",(long)number,permodel.mac];
            [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
        }];
        UIAlertAction *action2 = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [AppDelegate currentAppDelegate].device.bindingaccessories = NO;
        }];
        [alert addAction:action1];
        [alert addAction:action2];
        [self presentViewController:alert animated:YES completion:nil];
        
    }else if (selectTag == 36){
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"reminders", nil) message:NSLocalizedString(@"delete_remind", nil) preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action1 = [UIAlertAction actionWithTitle:NSLocalizedString(@"sure", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
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
                        [self delateKey:self.deviceid];
                    }
                }
            }error:^(NSError *error) {
                [SVProgressHUD showSimpleText:NSLocalizedString(@"delete_fail", nil)];
            }];
            
            NSString *fuzzyQuerySql = [NSString stringWithFormat:@"SELECT * FROM periphera_modals WHERE deviceid = '%zd'", self.deviceid];
            NSMutableArray *modals = [LVFmdbTool queryPeripheraData:fuzzyQuerySql];
            PeripheralModel *permodel = modals.firstObject;
            NSString *passwordHEX = [NSString stringWithFormat:@"A500000C3007000%ld%@",permodel.seq-1,permodel.mac];
            [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
        }];
        UIAlertAction *action2 = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [AppDelegate currentAppDelegate].device.bindingaccessories = NO;
        }];
        [alert addAction:action1];
        [alert addAction:action2];
        [self presentViewController:alert animated:YES completion:nil];
    }
}


- (void)delateKey:(NSInteger)deviceid{

    [[LoadView sharedInstance] hide];
    
    NSString *QuerykeySql = [NSString stringWithFormat:@"SELECT * FROM periphera_modals WHERE deviceid = '%zd'",deviceid];
    PeripheralModel *pmodel = [[LVFmdbTool queryPeripheraData:QuerykeySql] firstObject];
    NSString *deleteSql = [NSString stringWithFormat:@"DELETE FROM periphera_modals WHERE deviceid = '%zd' AND bikeid = '%zd'", deviceid,self.deviceNum];
    [LVFmdbTool deletePeripheraData:deleteSql];
    [[Manager shareManager] deletePeripheralSucceeded:pmodel];
    
    [self performSelector:@selector(interval) withObject:nil afterDelay:0.5];
    
}

- (void)interval{

    [AppDelegate currentAppDelegate].device.bindingaccessories = NO;
}


#pragma mark - BindingkeyDelegate
-(void)bidingKeyOver{
    
    [self getModelAryData];
    dispatch_async(dispatch_get_main_queue(), ^{
        // something
        [self.AccessoriesView reloadData];
    });
}

#pragma mark - BindingBleKeyDelegate
-(void)bidingBleKeyOver{
    
    [self getModelAryData];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.AccessoriesView reloadData];
    });
}

#pragma mark - AccessoriesTableViewCellDelegate
-(void)clickWitchItem:(NSMutableArray *)keymodals :(NSIndexPath *)index :(NSIndexPath *)tableIndex{
    
    NSString *bikeQuerySql = [NSString stringWithFormat:@"SELECT * FROM bike_modals WHERE bikeid = '%zd'", self.deviceNum];
    NSMutableArray *bikemodals = [LVFmdbTool queryBikeData:bikeQuerySql];
    BikeModel *bikemodel = bikemodals.firstObject;
    if (tableIndex.section == 0 || tableIndex.section == 1) {
        if (keymodals.count <= 0) {
            if (![[AppDelegate currentAppDelegate].device isConnected]) {

                [SVProgressHUD showSimpleText:NSLocalizedString(@"device_disconnect", nil)];
                return;
            }
            [AppDelegate currentAppDelegate].device.bindingaccessories = YES;
            if (tableIndex.section == 0) {
                NSString *passwordHEX = @"A5000007100301";
                [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
                BindingkeyViewController *bindVc = [BindingkeyViewController new];
                bindVc.deviceNum = self.deviceNum;
                bindVc.delegate = self;
                bindVc.seq = index.row;
                bindVc.keyversion = bikemodel.keyversion;
                [self.navigationController pushViewController:bindVc animated:YES];
            }else{
                BindingBleKeyViewController *bindVc = [BindingBleKeyViewController new];
                bindVc.deviceNum = self.deviceNum;
                bindVc.delegate = self;
                bindVc.seq = index.row + 1;
                [self.navigationController pushViewController:bindVc animated:YES];
            }
        }else if (keymodals.count == 1){
            PeripheralModel *periperMod = keymodals.firstObject;
            if (![[AppDelegate currentAppDelegate].device isConnected]) {

                [SVProgressHUD showSimpleText:NSLocalizedString(@"device_disconnect", nil)];
                return;
            }
            [AppDelegate currentAppDelegate].device.bindingaccessories = YES;
            if (tableIndex.section == 0) {
                
                if (periperMod.seq == 0 && index.row == 0) {
                    [SVProgressHUD showSimpleText:NSLocalizedString(@"device_has_bind", nil)];
                    return;
                }else if (periperMod.seq == 1 && index.row == 1){
                    [SVProgressHUD showSimpleText:NSLocalizedString(@"device_has_bind", nil)];
                    return;
                }
                
                NSString *passwordHEX = @"A5000007100301";
                [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
                BindingkeyViewController *bindVc = [BindingkeyViewController new];
                bindVc.deviceNum = self.deviceNum;
                bindVc.delegate = self;
                bindVc.seq = index.row;
                bindVc.keyversion = bikemodel.keyversion;
                [self.navigationController pushViewController:bindVc animated:YES];
            }else{
                
                if (periperMod.seq == 1 && index.row == 0) {
                    [SVProgressHUD showSimpleText:NSLocalizedString(@"device_has_bind", nil)];
                    return;
                }else if (periperMod.seq == 2 && index.row == 1){
                    [SVProgressHUD showSimpleText:NSLocalizedString(@"device_has_bind", nil)];
                    return;
                }
                
                BindingBleKeyViewController *bindVc = [BindingBleKeyViewController new];
                bindVc.deviceNum = self.deviceNum;
                bindVc.delegate = self;
                bindVc.seq = index.row + 1;
                [self.navigationController pushViewController:bindVc animated:YES];
            }

        }else{

            [SVProgressHUD showSimpleText:NSLocalizedString(@"device_has_bind", nil)];
        }

    }
//    else if (tableIndex.section == 2){
//        if (index.row < keymodals.count) {
//            PeripheralModel *periperMod = keymodals[index.row];
//            DeviceModifyViewController *deviceDetailvc = [DeviceModifyViewController new];
//            deviceDetailvc.deviceNum = self.deviceNum;
//            deviceDetailvc.deviceId = periperMod.deviceid;
//            [self.navigationController pushViewController:deviceDetailvc animated:YES];
//        }else if(index.row >= keymodals.count){
//            if (bikemodel.ownerflag == 0) {
//                [SVProgressHUD showSimpleText:NSLocalizedString(@"fingerpring_child_no", nil)];
//                return;
//            }else if (![[AppDelegate currentAppDelegate].device isConnected]) {
//
//                [SVProgressHUD showSimpleText:NSLocalizedString(@"device_disconnect", nil)];
//                return;
//            }
//            TwoDimensionalCodecanViewController *QRvC = [TwoDimensionalCodecanViewController new];
//            QRvC.deviceNum = self.deviceNum;
//            [self.navigationController pushViewController:QRvC animated:YES];
//        }
//    }
    else{
        
        if (keymodals.count <= 0) {
            if (![[AppDelegate currentAppDelegate].device isConnected]) {
                
                [SVProgressHUD showSimpleText:NSLocalizedString(@"device_disconnect", nil)];
                return;
            }
            [AppDelegate currentAppDelegate].device.bindingaccessories = YES;
            TwoDimensionalCodecanViewController *QRvC = [TwoDimensionalCodecanViewController new];
            QRvC.deviceNum = self.deviceNum;
            QRvC.type = 6;
            QRvC.seq = index.row + 1;
            [self.navigationController pushViewController:QRvC animated:YES];
            
        }else if (keymodals.count == 1){
            PeripheralModel *periperMod = keymodals.firstObject;
            if (periperMod.seq == 1 && index.row == 0) {
                DeviceModifyViewController *deviceDetailvc = [DeviceModifyViewController new];
                deviceDetailvc.deviceNum = self.deviceNum;
                deviceDetailvc.deviceId = periperMod.deviceid;
                [self.navigationController pushViewController:deviceDetailvc animated:YES];
            }else if (periperMod.seq == 2 && index.row == 1){
                DeviceModifyViewController *deviceDetailvc = [DeviceModifyViewController new];
                deviceDetailvc.deviceNum = self.deviceNum;
                deviceDetailvc.deviceId = periperMod.deviceid;
                [self.navigationController pushViewController:deviceDetailvc animated:YES];
            }else{
                if (![[AppDelegate currentAppDelegate].device isConnected]) {
                    
                    [SVProgressHUD showSimpleText:NSLocalizedString(@"device_disconnect", nil)];
                    return;
                }
                [AppDelegate currentAppDelegate].device.bindingaccessories = YES;
                TwoDimensionalCodecanViewController *QRvC = [TwoDimensionalCodecanViewController new];
                QRvC.deviceNum = self.deviceNum;
                QRvC.type = 6;
                QRvC.seq = index.row + 1;
                [self.navigationController pushViewController:QRvC animated:YES];
            }
            
        }else{
            PeripheralModel *periperMod = [keymodals firstObject];
            DeviceModifyViewController *deviceDetailvc = [DeviceModifyViewController new];
            deviceDetailvc.deviceNum = self.deviceNum;
            deviceDetailvc.deviceId = periperMod.deviceid;
            [self.navigationController pushViewController:deviceDetailvc animated:YES];
        }
        
    }
}

-(void)popDeleteView:(UICollectionView *)collectionView :(UILongPressGestureRecognizer *)longPress{
    
    if (longPress.state == UIGestureRecognizerStateBegan){
        NSString *bikeQuerySql = [NSString stringWithFormat:@"SELECT * FROM bike_modals WHERE bikeid = '%zd'", self.deviceNum];
        NSMutableArray *bikemodals = [LVFmdbTool queryBikeData:bikeQuerySql];
        BikeModel *bikemodel = bikemodals.firstObject;
        if (bikemodel.ownerflag == 0) {
            [SVProgressHUD showSimpleText:NSLocalizedString(@"device_disconnect", nil)];
            return;
        }
        UITableViewCell *tableviewCell = (UITableViewCell *)[[collectionView superview] superview];
        NSIndexPath *tableIndexpath = [_AccessoriesView indexPathForCell:tableviewCell];//获取cell对应的indexpath;
        UIView *collectView = [[longPress view] superview];//获取父类view
        CollectionViewCell *cell = (CollectionViewCell *)[collectView superview];//获取cell
        //NSIndexPath *UICollectionIndexpath = [collectionView indexPathForCell:cell];//获取cell对应的indexpath;
        CGRect cellInCollection = [collectionView convertRect:cell.frame toView:[self.view superview]];
        CGFloat x = cellInCollection.origin.x - 7.5;
        CGFloat y = cellInCollection.origin.y;
        NSInteger selectTag ;
        if (tableIndexpath.section == 0) {
            selectTag = 30;
        }else if (tableIndexpath.section == 1){
            selectTag = 32;
        }
//        else if (tableIndexpath.section == 2){
//            selectTag = 34;
//        }
        else{
            selectTag = 36;
        }
        _outputView = [[DelPopView alloc] initWithorigin:CGPointMake(x, y) width:80 height:30 tag:selectTag deviceId:[longPress view].tag];
        _outputView.delegate = self;
        _outputView.dismissOperation = ^(){
            
            _outputView = nil;
        };
        [_outputView pop];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    [self.view endEditing:YES];
}



-(void)getModelAryData{
    
    [self.modelArry removeAllObjects];
    //[self.modelArry2 removeAllObjects];
    [self.modelArry3 removeAllObjects];
    [self.bleKeyArry removeAllObjects];
    NSString *fuzzyQuerySql = [NSString stringWithFormat:@"SELECT * FROM periphera_modals WHERE type = '%d' AND seq = '%d' AND bikeid = '%zd'",3,0,self.deviceNum];
    NSMutableArray *modals = [LVFmdbTool queryPeripheraData:fuzzyQuerySql];

    NSString *fuzzyQuerySql2 = [NSString stringWithFormat:@"SELECT * FROM periphera_modals WHERE type = '%d' AND seq = '%d' AND bikeid = '%zd'",3,1,self.deviceNum];
    NSMutableArray *modals2 = [LVFmdbTool queryPeripheraData:fuzzyQuerySql2];

    PeripheralModel *permodel = modals.firstObject;
    PeripheralModel *permodel2 = modals2.firstObject;
    NSMutableArray *allKeymodals = [NSMutableArray new];

    if (modals.count == 0 && modals2.count != 0) {
        [allKeymodals addObject:permodel2];
    }else if (modals.count != 0 && modals2.count == 0){
        [allKeymodals addObject:permodel];
    }else{
        allKeymodals = [NSMutableArray arrayWithObjects:permodel, permodel2, nil];
    }

    for (int i = 0; i < 2; i++) {
        AccessoriesModel *accessoriesModel = [AccessoriesModel new];
        if (allKeymodals.count == 0) {

            if (i == 0) {
                accessoriesModel.titleName = NSLocalizedString(@"normal_key_one", nil);
                accessoriesModel.pictureName = [UIImage imageNamed:@"addkey"];
            }else{
                accessoriesModel.titleName = NSLocalizedString(@"normal_key_two", nil);
                accessoriesModel.pictureName = [UIImage imageNamed:@"addkey"];
            }

        }else if (allKeymodals.count == 1){

            if (i == 0) {
                accessoriesModel.titleName = NSLocalizedString(@"normal_key_one", nil);

                if (modals.count == 0) {
                    accessoriesModel.pictureName = [UIImage imageNamed:@"addkey"];
                }else{
                    accessoriesModel.pictureName = [UIImage imageNamed:@"nomalkey"];
                    accessoriesModel.addLongPress = YES;
                }

            }else{
                accessoriesModel.titleName = NSLocalizedString(@"normal_key_two", nil);
                if (modals2.count == 0) {
                    accessoriesModel.pictureName = [UIImage imageNamed:@"addkey"];
                }else{
                    accessoriesModel.pictureName = [UIImage imageNamed:@"nomalkey"];
                    accessoriesModel.addLongPress = YES;
                }
            }
        }else if (allKeymodals.count == 2){
            if (i == 0) {
                accessoriesModel.titleName =NSLocalizedString(@"normal_key_one", nil);
                accessoriesModel.pictureName = [UIImage imageNamed:@"nomalkey"];
                accessoriesModel.addLongPress = YES;
            }else{
                accessoriesModel.titleName = NSLocalizedString(@"normal_key_two", nil);
                accessoriesModel.pictureName = [UIImage imageNamed:@"nomalkey"];
                accessoriesModel.addLongPress = YES;
            }
        }
        accessoriesModel.infoAry = allKeymodals;
        [self.modelArry addObject:accessoriesModel];
    }
    
//    NSString *QuerykeySql = [NSString stringWithFormat:@"SELECT * FROM periphera_modals WHERE (type = '%d' OR type = '%d') AND bikeid = '%zd'", 2,5,self.deviceNum];
//    NSMutableArray *keymodals = [LVFmdbTool queryPeripheraData:QuerykeySql];
//    if (keymodals.count == 0) {
//        AccessoriesModel *accessoriesModel = [AccessoriesModel new];
//        accessoriesModel.titleName = NSLocalizedString(@"add_accessories", nil);
//        accessoriesModel.pictureName = [UIImage imageNamed:@"peripheral_add"];
//        [self.modelArry2 addObject:accessoriesModel];
//    }else{
//
//        for (int i = 0; i<keymodals.count; i++) {
//            AccessoriesModel *accessoriesModel = [AccessoriesModel new];
//            accessoriesModel.infoAry = keymodals;
//            [self.modelArry2 addObject:accessoriesModel];
//        }
//
//        AccessoriesModel *accessoriesModel = [AccessoriesModel new];
//        accessoriesModel.titleName = NSLocalizedString(@"add_accessories", nil);
//        accessoriesModel.pictureName = [UIImage imageNamed:@"peripheral_add"];
//        [self.modelArry2 addObject:accessoriesModel];
//    }
    
    //胎压数据获取
    NSString *pressureSql = [NSString stringWithFormat:@"SELECT * FROM periphera_modals WHERE type = '%d' AND seq = '%d' AND bikeid = '%zd'",6,1,self.deviceNum];
    NSMutableArray *pressureModals = [LVFmdbTool queryPeripheraData:pressureSql];

    NSString *pressureSql2 = [NSString stringWithFormat:@"SELECT * FROM periphera_modals WHERE type = '%d' AND seq = '%d' AND bikeid = '%zd'",6,2,self.deviceNum];
    NSMutableArray *pressureModals2 = [LVFmdbTool queryPeripheraData:pressureSql2];

    PeripheralModel *presuremodel = pressureModals.firstObject;
    PeripheralModel *presuremodel2 = pressureModals2.firstObject;
    NSMutableArray *allPresureModals = [NSMutableArray new];

    if (pressureModals.count == 0 && pressureModals2.count != 0) {
        [allPresureModals addObject:presuremodel2];
    }else if (pressureModals.count != 0 && pressureModals2.count == 0){
        [allPresureModals addObject:presuremodel];
    }else{
        allPresureModals = [NSMutableArray arrayWithObjects:presuremodel, presuremodel2, nil];
    }

    for (int i = 0; i < 2; i++) {
        AccessoriesModel *accessoriesModel = [AccessoriesModel new];
        if (allPresureModals.count == 0) {

            if (i == 0) {
                accessoriesModel.titleName = NSLocalizedString(@"front_tire_pressure", nil);
                accessoriesModel.pictureName = [UIImage imageNamed:NSLocalizedString(@"peripheral_pressure_add", nil)];
            }else{
                accessoriesModel.titleName = NSLocalizedString(@"rear_tire_pressure", nil);
                accessoriesModel.pictureName = [UIImage imageNamed:NSLocalizedString(@"peripheral_pressure_add", nil)];
            }

        }else if (allPresureModals.count == 1){

            if (i == 0) {
                accessoriesModel.titleName = NSLocalizedString(@"front_tire_pressure", nil);

                if (pressureModals.count == 0) {
                    accessoriesModel.pictureName = [UIImage imageNamed:NSLocalizedString(@"peripheral_pressure_add", nil)];
                }else{
                    accessoriesModel.pictureName = [UIImage imageNamed:NSLocalizedString(@"peripheral_pressure_frontlwheel", nil)];
                    accessoriesModel.addLongPress = YES;
                }
            }else{
                accessoriesModel.titleName = NSLocalizedString(@"rear_tire_pressure", nil);
                if (pressureModals2.count == 0) {
                    accessoriesModel.pictureName = [UIImage imageNamed:NSLocalizedString(@"peripheral_pressure_add", nil)];
                }else{
                    accessoriesModel.pictureName = [UIImage imageNamed:NSLocalizedString(@"peripheral_pressure_realwheel", nil)];
                    accessoriesModel.addLongPress = YES;
                }
            }
        }else if (allPresureModals.count == 2){
            if (i == 0) {
                accessoriesModel.titleName = NSLocalizedString(@"front_tire_pressure", nil);
                accessoriesModel.pictureName = [UIImage imageNamed:NSLocalizedString(@"peripheral_pressure_frontlwheel", nil)];
                accessoriesModel.addLongPress = YES;
            }else{
                accessoriesModel.titleName = NSLocalizedString(@"rear_tire_pressure", nil);
                accessoriesModel.pictureName = [UIImage imageNamed:NSLocalizedString(@"peripheral_pressure_realwheel", nil)];
                accessoriesModel.addLongPress = YES;
            }
        }
        accessoriesModel.infoAry = allPresureModals;
        [self.modelArry3 addObject:accessoriesModel];
    }
    
    //新版蓝牙钥匙数据
    NSString *bleKeySql = [NSString stringWithFormat:@"SELECT * FROM periphera_modals WHERE type = '%d' AND seq = '%d' AND bikeid = '%zd'",7,1,self.deviceNum];
    NSMutableArray *bleKeyModals = [LVFmdbTool queryPeripheraData:bleKeySql];
    
    NSString *bleKeySql2 = [NSString stringWithFormat:@"SELECT * FROM periphera_modals WHERE type = '%d' AND seq = '%d' AND bikeid = '%zd'",7,2,self.deviceNum];
    NSMutableArray *bleKeyModals2 = [LVFmdbTool queryPeripheraData:bleKeySql2];
    
    PeripheralModel *blepermodel = bleKeyModals.firstObject;
    PeripheralModel *blepermodel2 = bleKeyModals2.firstObject;
    NSMutableArray *allBLEKeymodals = [NSMutableArray new];
    
    if (bleKeyModals.count == 0 && bleKeyModals2.count != 0) {
        [allBLEKeymodals addObject:blepermodel2];
    }else if (bleKeyModals.count != 0 && bleKeyModals2.count == 0){
        [allBLEKeymodals addObject:blepermodel];
    }else{
        allBLEKeymodals = [NSMutableArray arrayWithObjects:blepermodel, blepermodel2, nil];
    }
    
    for (int i = 0; i < 2; i++) {
        AccessoriesModel *accessoriesModel = [AccessoriesModel new];
        if (allBLEKeymodals.count == 0) {
            
            if (i == 0) {
                accessoriesModel.titleName = NSLocalizedString(@"smart_key_one", nil);
                accessoriesModel.pictureName = [UIImage imageNamed:@"icon_nomal_ble_key"];
            }else{
                accessoriesModel.titleName = NSLocalizedString(@"smart_key_two", nil);
                accessoriesModel.pictureName = [UIImage imageNamed:@"icon_nomal_ble_key"];
            }
            
        }else if (allBLEKeymodals.count == 1){
            
            if (i == 0) {
                accessoriesModel.titleName = NSLocalizedString(@"smart_key_one", nil);
                
                if (bleKeyModals.count == 0) {
                    accessoriesModel.pictureName = [UIImage imageNamed:@"icon_nomal_ble_key"];
                }else{
                    accessoriesModel.pictureName = [UIImage imageNamed:@"icon_ble_key"];
                    accessoriesModel.addLongPress = YES;
                }
                
            }else{
                accessoriesModel.titleName = NSLocalizedString(@"smart_key_two", nil);
                if (bleKeyModals2.count == 0) {
                    accessoriesModel.pictureName = [UIImage imageNamed:@"icon_nomal_ble_key"];
                }else{
                    accessoriesModel.pictureName = [UIImage imageNamed:@"icon_ble_key"];
                    accessoriesModel.addLongPress = YES;
                }
            }
        }else if (allBLEKeymodals.count == 2){
            if (i == 0) {
                accessoriesModel.titleName = NSLocalizedString(@"smart_key_one", nil);
                accessoriesModel.pictureName = [UIImage imageNamed:@"icon_ble_key"];
                accessoriesModel.addLongPress = YES;
            }else{
                accessoriesModel.titleName = NSLocalizedString(@"smart_key_two", nil);
                accessoriesModel.pictureName = [UIImage imageNamed:@"icon_ble_key"];
                accessoriesModel.addLongPress = YES;
            }
        }
        accessoriesModel.infoAry = allBLEKeymodals;
        [self.bleKeyArry addObject:accessoriesModel];
    }
}

 #pragma mark - ManagerDelegate
-(void)manager:(Manager *)manager bindingPeripheralSucceeded:(PeripheralModel *)model{
    
    [self getModelAryData];
    [self.AccessoriesView reloadData];
}

-(void)manager:(Manager *)manager deletePeripheralSucceeded:(PeripheralModel *)model{
    
    [self getModelAryData];
    [self.AccessoriesView reloadData];
}

-(void)dealloc{
    
    [[Manager shareManager] deleteDelegate:self];
    [AppDelegate currentAppDelegate].device.bindingaccessories = NO;
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
