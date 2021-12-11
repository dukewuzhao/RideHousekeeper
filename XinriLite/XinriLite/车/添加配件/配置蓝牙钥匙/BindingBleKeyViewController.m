//
//  BindingBleKeyViewController.m
//  RideHousekeeper
//
//  Created by Apple on 2019/2/13.
//  Copyright © 2019年 Duke Wu. All rights reserved.
//

#import "BindingBleKeyViewController.h"

@interface BindingBleKeyViewController ()
{
    NSInteger time;
}
@property(nonatomic,strong)UILabel *countNumLab;
@property(nonatomic,strong)MSWeakTimer *mytime;
@end

@implementation BindingBleKeyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    time = 10;
    [self setupNavView];
    [self setupView];
    @weakify(self);
    [[[NSNOTIC_CENTER rac_addObserverForName:KNotification_BindingNewBLEKEY object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id x) {
        @strongify(self);
        [self.mytime invalidate];
        self.mytime = nil;
        NSNotification *userInfo = x;
        NSString *date = userInfo.userInfo[@"data"];
        if ([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"1007"]) {
            
            if ([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"00"]) {
                [SVProgressHUD showSimpleText:NSLocalizedString(@"bind_fail", nil)];
            }else if ([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"01"]){
                
                [self bindBleKey];
            }
        }
    }];
    
    NSString *passwordHEX =  [NSString stringWithFormat:@"A50000081007010%ld",self.seq - 1];
    [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
}

- (void)setupNavView{
    [super setupNavView];
    self.navView.backgroundColor = [QFTools colorWithHexString:MainColor];
    self.navView.showBottomLabel = NO;
    [self.navView.centerButton setTitle:NSLocalizedString(@"Bluetooth_key_configuration", nil) forState:UIControlStateNormal];
    @weakify(self);
    [self.navView.leftButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    self.navView.leftButtonBlock = ^{
        @strongify(self);
        
        [self.navigationController popViewControllerAnimated:YES];
    };
}

-(void)setupView{
    
    UILabel *binding = [[UILabel alloc] initWithFrame:CGRectMake(0, 55+navHeight, ScreenWidth, 25)];
    binding.textAlignment = NSTextAlignmentCenter;
    binding.text = NSLocalizedString(@"button_click_prompt", nil);
    binding.textColor = [UIColor whiteColor];
    binding.font = FONT_PINGFAN(13);
    [self.view addSubview:binding];
    
    UIImageView *clickIcon = [UIImageView new];
    clickIcon.image = [UIImage imageNamed:@"binding_lock_key_ok"];
    [self.view addSubview:clickIcon];
    
    [clickIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(binding.mas_top).offset(70);
        make.size.mas_equalTo(CGSizeMake(70, 70));
    }];
    
    _countNumLab = [UILabel new];
    _countNumLab.text = @"10s";
    _countNumLab.textColor = [UIColor whiteColor];
    _countNumLab.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_countNumLab];
    [_countNumLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(clickIcon.mas_bottom).offset(40);
        make.size.mas_equalTo(CGSizeMake(70, 20));
    }];
    
    UIButton *cancleBtn = [UIButton new];
    [cancleBtn setTitle:NSLocalizedString(@"no_bing_now", nil) forState:UIControlStateNormal];
    [cancleBtn setTitleColor:[QFTools colorWithHexString:NSLocalizedString(@"VCControlColor", nil)] forState:UIControlStateNormal];
    [self.view addSubview:cancleBtn];
    [cancleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.bottom.equalTo(self.view.mas_bottom).offset(-75);
        make.size.mas_equalTo(CGSizeMake(150, 45));
    }];
    @weakify(self);
    [[cancleBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    _mytime = [MSWeakTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timeFired:) userInfo:nil repeats:YES dispatchQueue:dispatch_get_main_queue()];
}

- (void)timeFired:(MSWeakTimer *)timer{
    
    time--;
    _countNumLab.text = [NSString stringWithFormat:@"%ld",time];
    
    if (time == 0) {
        [AppDelegate currentAppDelegate].device.bindingaccessories = NO;
        [timer invalidate];
        [SVProgressHUD showSimpleText:NSLocalizedString(@"bind_fail", nil)];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)bindBleKey{
    
    [LoadView sharedInstance].protetitle.text = NSLocalizedString(@"bind_BLE_key", nil);
    [[LoadView sharedInstance] show];
    NSString *sn = @"R000000000";
    
    NSString *fuzzyQuerySql = [NSString stringWithFormat:@"SELECT * FROM periphera_modals WHERE bikeid LIKE '%zd' AND seq LIKE '%zd' AND type LIKE '%d'",self.deviceNum,self.seq,7];
    NSMutableArray *modals = [LVFmdbTool queryPeripheraData:fuzzyQuerySql];
    
    if (modals.count > 0) {
        
        NSString *delateKeySql = [NSString stringWithFormat:@"DELETE FROM periphera_modals WHERE bikeid LIKE '%zd' AND seq LIKE '%zd' AND type LIKE '%d'",self.deviceNum,self.seq,7];
        [LVFmdbTool deletePeripheraData:delateKeySql];
    }
    
    
    PeripheralModel *pmodel = [PeripheralModel modalWith:self.deviceNum deviceid:self.seq + 20 type:7 seq:self.seq mac:@"" sn:sn firmversion:@""];
    BOOL success =  [LVFmdbTool insertDeviceModel:pmodel];
    
    if (success) {
        if ([self.delegate respondsToSelector:@selector(bidingBleKeyOver)]) {
            [self.delegate bidingBleKeyOver];
        }
    }else{
        [SVProgressHUD showSimpleText:NSLocalizedString(@"bind_fail", nil)];
    }
    [[LoadView sharedInstance] hide];
    [self.navigationController popViewControllerAnimated:YES];
    
    
}

-(void)dealloc{
    [self.mytime invalidate];
    self.mytime = nil;
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
